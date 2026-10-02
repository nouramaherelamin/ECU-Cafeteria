-- =========================================================================
-- RESTAURANT MANAGEMENT SYSTEM - COMPLETE T-SQL SCRIPT
-- =========================================================================
-- This script creates the Database, Tables, Triggers, Stored Procedures, 
-- inserts sample data, and includes all required queries.
-- Execute this script entirely in Microsoft SQL Server Management Studio (SSMS).
-- =========================================================================

-- 1. Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RestaurantDB')
BEGIN
    CREATE DATABASE RestaurantDB;
END
GO

USE RestaurantDB;
GO

-- =========================================================================
-- 2. CREATE TABLES
-- =========================================================================

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NULL
);
GO

-- RestaurantTables Table
CREATE TABLE RestaurantTables (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Available' 
        CHECK (Status IN ('Available', 'Occupied', 'Reserved'))
);
GO

-- Menu Table
CREATE TABLE Menu (
    MenuID INT IDENTITY(1,1) PRIMARY KEY,
    DishName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Availability BIT NOT NULL DEFAULT 1 -- 1 for True (Available), 0 for False (Not Available)
);
GO

-- Orders Table
-- Bonus feature: TableID is nullable to support Delivery/Takeaway (Online Orders)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    TableID INT NULL, 
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus NVARCHAR(20) DEFAULT 'Pending' 
        CHECK (OrderStatus IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    OrderType NVARCHAR(20) DEFAULT 'Dine-in' 
        CHECK (OrderType IN ('Dine-in', 'Delivery', 'Takeaway')),
    TotalAmount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTables(TableID)
);
GO

-- OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    SubTotal DECIMAL(10,2) NULL, 
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID)
);
GO

-- Payments Table
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE, -- 1-to-1 Relationship (One order has one payment)
    PaymentMethod NVARCHAR(50) NOT NULL 
        CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Online')),
    AmountPaid DECIMAL(10,2) NOT NULL CHECK (AmountPaid >= 0),
    PaymentDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

-- =========================================================================
-- 3. TRIGGERS
-- =========================================================================

-- Trigger 1: Automatically updating table status to Occupied when an order is created
CREATE TRIGGER trg_UpdateTable_OrderCreated
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RestaurantTables
    SET Status = 'Occupied'
    FROM RestaurantTables RT
    INNER JOIN inserted i ON RT.TableID = i.TableID
    WHERE i.TableID IS NOT NULL AND i.OrderType = 'Dine-in';
END;
GO

-- Trigger 2: Automatically changing table status back to Available after payment completion
CREATE TRIGGER trg_UpdateTable_PaymentCompleted
ON Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RestaurantTables
    SET Status = 'Available'
    FROM RestaurantTables RT
    INNER JOIN Orders O ON RT.TableID = O.TableID
    INNER JOIN inserted i ON O.OrderID = i.OrderID
    WHERE O.TableID IS NOT NULL;
END;
GO

-- Trigger 3 & 4: Prevent negative quantities/prices and calculate subtotal/total
CREATE TRIGGER trg_OrderDetails_Logic
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Prevent negative quantities or prices (Redundant with CHECK constraint but explicit for requirement)
    IF EXISTS (SELECT 1 FROM inserted WHERE Quantity < 0 OR UnitPrice < 0)
    BEGIN
        RAISERROR ('Quantity and Unit Price cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Prevent nested trigger calls
    IF TRIGGER_NESTLEVEL() > 1 
        RETURN;

    -- Calculate SubTotal automatically in OrderDetails
    UPDATE OrderDetails
    SET SubTotal = Quantity * UnitPrice
    WHERE OrderDetailID IN (SELECT OrderDetailID FROM inserted);

    -- Calculate TotalAmount automatically in Orders
    UPDATE Orders
    SET TotalAmount = (
        SELECT ISNULL(SUM(SubTotal), 0)
        FROM OrderDetails
        WHERE OrderID = Orders.OrderID
    )
    WHERE OrderID IN (SELECT OrderID FROM inserted);
END;
GO

-- =========================================================================
-- 4. STORED PROCEDURES
-- =========================================================================

-- Stored Procedure 1: Processing a new order
CREATE PROCEDURE sp_ProcessNewOrder
    @CustomerID INT,
    @TableID INT = NULL,
    @OrderType NVARCHAR(20) = 'Dine-in',
    @MenuID1 INT, @Qty1 INT,
    @MenuID2 INT = NULL, @Qty2 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Create the order
        DECLARE @NewOrderID INT;
        INSERT INTO Orders (CustomerID, TableID, OrderType, OrderStatus)
        VALUES (@CustomerID, @TableID, @OrderType, 'In Progress');
        
        SET @NewOrderID = SCOPE_IDENTITY();

        -- 2. Insert order details 
        -- Trigger trg_OrderDetails_Logic will automatically calculate the subtotal and total amount.
        -- Trigger trg_UpdateTable_OrderCreated automatically updates table status.
        DECLARE @UnitPrice1 DECIMAL(10,2) = (SELECT Price FROM Menu WHERE MenuID = @MenuID1);
        INSERT INTO OrderDetails (OrderID, MenuID, Quantity, UnitPrice)
        VALUES (@NewOrderID, @MenuID1, @Qty1, @UnitPrice1);

        -- Insert second item if provided
        IF @MenuID2 IS NOT NULL AND @Qty2 IS NOT NULL
        BEGIN
            DECLARE @UnitPrice2 DECIMAL(10,2) = (SELECT Price FROM Menu WHERE MenuID = @MenuID2);
            INSERT INTO OrderDetails (OrderID, MenuID, Quantity, UnitPrice)
            VALUES (@NewOrderID, @MenuID2, @Qty2, @UnitPrice2);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Stored Procedure 2: Completing payment
CREATE PROCEDURE sp_CompletePayment
    @OrderID INT,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get Amount to Pay
        DECLARE @TotalAmount DECIMAL(10,2);
        SELECT @TotalAmount = TotalAmount FROM Orders WHERE OrderID = @OrderID;

        -- 1. Insert Payment 
        -- Trigger trg_UpdateTable_PaymentCompleted will automatically free the table!
        INSERT INTO Payments (OrderID, PaymentMethod, AmountPaid)
        VALUES (@OrderID, @PaymentMethod, @TotalAmount);

        -- 2. Mark Order as completed
        UPDATE Orders
        SET OrderStatus = 'Completed'
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =========================================================================
-- 5. INSERT SAMPLE DATA
-- =========================================================================

-- Insert 10 Customers
INSERT INTO Customers (FullName, PhoneNumber, Email) VALUES 
('Ahmed Ali', '0501234567', 'ahmed.ali@email.com'),
('Sara Mansour', '0501112222', 'sara.m@email.com'),
('Khalid Omar', '0509998888', 'khalid.o@email.com'),
('Fatima Saeed', '0504445555', 'fatima.s@email.com'),
('Mohammed Hassan', '0506667777', 'mohammed.h@email.com'),
('Noura Abdullah', '0503332222', 'noura.a@email.com'),
('Omar Zaid', '0508889999', 'omar.z@email.com'),
('Layla Majed', '0507776666', 'layla.m@email.com'),
('Youssef Ibrahim', '0505554444', 'youssef.i@email.com'),
('Maha Tariq', '0502223333', 'maha.t@email.com');
GO

-- Insert 10 Menu Items
INSERT INTO Menu (DishName, Category, Price) VALUES 
('Grilled Chicken', 'Main Course', 45.00),
('Beef Steak', 'Main Course', 85.00),
('Margherita Pizza', 'Main Course', 35.00),
('Caesar Salad', 'Appetizers', 25.00),
('Lentil Soup', 'Appetizers', 15.00),
('French Fries', 'Side Dish', 12.00),
('Chocolate Lava Cake', 'Desserts', 30.00),
('Cheesecake', 'Desserts', 28.00),
('Fresh Orange Juice', 'Beverages', 15.00),
('Iced Tea', 'Beverages', 10.00);
GO

-- Insert 5 Restaurant Tables
INSERT INTO RestaurantTables (Capacity) VALUES 
(2), (4), (4), (6), (8);
GO

-- Insert Orders via Stored Procedure (Simulates creating orders properly)
-- 1. Dine-in Order
EXEC sp_ProcessNewOrder @CustomerID = 1, @TableID = 1, @OrderType = 'Dine-in', @MenuID1 = 1, @Qty1 = 2, @MenuID2 = 9, @Qty2 = 2;
-- 2. Dine-in Order
EXEC sp_ProcessNewOrder @CustomerID = 2, @TableID = 2, @OrderType = 'Dine-in', @MenuID1 = 2, @Qty1 = 1, @MenuID2 = 4, @Qty2 = 1;
-- 3. Delivery Order (Bonus Feature: TableID is NULL)
EXEC sp_ProcessNewOrder @CustomerID = 3, @TableID = NULL, @OrderType = 'Delivery', @MenuID1 = 3, @Qty1 = 3, @MenuID2 = 6, @Qty2 = 2;
-- 4. Takeaway Order (Bonus Feature: TableID is NULL)
EXEC sp_ProcessNewOrder @CustomerID = 4, @TableID = NULL, @OrderType = 'Takeaway', @MenuID1 = 7, @Qty1 = 4;
-- 5. Dine-in Order
EXEC sp_ProcessNewOrder @CustomerID = 5, @TableID = 3, @OrderType = 'Dine-in', @MenuID1 = 2, @Qty1 = 2, @MenuID2 = 8, @Qty2 = 2;

-- Complete some payments (This will free Tables 1 and 2, and complete Orders 1, 2, 3)
EXEC sp_CompletePayment @OrderID = 1, @PaymentMethod = 'Credit Card';
EXEC sp_CompletePayment @OrderID = 2, @PaymentMethod = 'Cash';
EXEC sp_CompletePayment @OrderID = 3, @PaymentMethod = 'Online';
GO

-- =========================================================================
-- 6. SQL QUERIES REQUIRED
-- =========================================================================

-- 1. Popular dishes (Show most ordered dishes, Include total quantity ordered)
SELECT 
    M.DishName, 
    M.Category, 
    SUM(OD.Quantity) AS TotalQuantityOrdered
FROM OrderDetails OD
JOIN Menu M ON OD.MenuID = M.MenuID
GROUP BY M.DishName, M.Category
ORDER BY TotalQuantityOrdered DESC;
GO

-- 2. Daily revenue reports (Show total revenue per day)
SELECT 
    CAST(PaymentDate AS DATE) AS RevenueDate,
    SUM(AmountPaid) AS TotalRevenue
FROM Payments
GROUP BY CAST(PaymentDate AS DATE)
ORDER BY RevenueDate DESC;
GO

-- 3. Available tables
SELECT 
    TableID, 
    Capacity, 
    Status
FROM RestaurantTables
WHERE Status = 'Available';
GO

-- 4. Customer order history
SELECT 
    C.FullName, 
    O.OrderID, 
    O.OrderDate, 
    O.OrderType,
    O.OrderStatus, 
    O.TotalAmount
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
ORDER BY C.FullName, O.OrderDate DESC;
GO

-- 5. Highest spending customers
SELECT TOP 5
    C.FullName, 
    SUM(O.TotalAmount) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.OrderStatus = 'Completed'
GROUP BY C.FullName
ORDER BY TotalSpent DESC;
GO

-- 6. Orders with payment details
SELECT 
    O.OrderID, 
    C.FullName AS CustomerName,
    O.OrderType,
    O.TotalAmount, 
    P.PaymentMethod, 
    P.AmountPaid, 
    P.PaymentDate
FROM Orders O
JOIN Payments P ON O.OrderID = P.OrderID
JOIN Customers C ON O.CustomerID = C.CustomerID;
GO