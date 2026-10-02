-- =========================================================================
-- UNIVERSITY FOOD COURT MANAGEMENT SYSTEM - IMPROVED REALISTIC VERSION v3
-- =========================================================================
-- Changes from v2:
--   * Vendors 3, 4, 5 replaced with real campus vendors from provided menus:
--       - Campus Burger Spot  → Pablo
--       - Quick Bites         → Bites
--       - Crispy Corner       → Food Friends
--   * Full menus extracted from provided menu images/PDF
--   * All original functionality preserved:
--       - Queue System
--       - Estimated Waiting Time
--       - Loyalty Points System
--       - Campus Delivery
--       - Analytics Queries
--       - 150-order Simulation
--
-- VENDORS:
--   1. The Breakfast Bus       (real menu - unchanged)
--   2. Santa Cafe              (real menu - unchanged)
--   3. Pablo                   (NEW - pizza, pasta, sandwiches, waffles, crepes)
--   4. Bites                   (NEW - coffee, drinks, desserts, bakery, pizza)
--   5. Food Friends            (NEW - Syrian fries, crepes, burgers)
--   6. Pasta Express           (unchanged)
--   7. Study Break Cafe        (unchanged)
--   8. Fresh Juice Point       (unchanged)
--   9. Late Night Snacks       (unchanged)
-- =========================================================================

-- =========================================================================
-- SECTION 1 - DATABASE CREATION
-- =========================================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'UniversityFoodCourtDB')
BEGIN
    ALTER DATABASE UniversityFoodCourtDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UniversityFoodCourtDB;
END
GO

CREATE DATABASE UniversityFoodCourtDB;
GO

USE UniversityFoodCourtDB;
GO

-- =========================================================================
-- SECTION 2 - TABLE DEFINITIONS
-- =========================================================================

-- ------------------------------------------------------------------
-- Users (Students, Professors, Staff)
-- ------------------------------------------------------------------
CREATE TABLE Users (
    UserID               INT           IDENTITY(1,1) PRIMARY KEY,
    FirstName            NVARCHAR(50)  NOT NULL,
    LastName             NVARCHAR(50)  NOT NULL,
    Role                 NVARCHAR(50)  NOT NULL
        CHECK (Role IN ('Student','Professor','Staff')),
    Email                NVARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber          NVARCHAR(20)  NULL,
    CreatedAt            DATETIME      NOT NULL DEFAULT GETDATE(),
    TotalPointsEarned    INT           NOT NULL DEFAULT 0,
    PointsRedeemed       INT           NOT NULL DEFAULT 0,
    CurrentPointsBalance INT           NOT NULL DEFAULT 0
);
GO

-- ------------------------------------------------------------------
-- FoodVendors
-- ------------------------------------------------------------------
CREATE TABLE FoodVendors (
    VendorID   INT           IDENTITY(1,1) PRIMARY KEY,
    VendorName NVARCHAR(100) NOT NULL,
    Location   NVARCHAR(100) NOT NULL,
    Status     NVARCHAR(20)  NOT NULL DEFAULT 'Active'
        CHECK (Status IN ('Active','Closed'))
);
GO

-- ------------------------------------------------------------------
-- MenuItems
-- ------------------------------------------------------------------
CREATE TABLE MenuItems (
    MenuID            INT           IDENTITY(1,1) PRIMARY KEY,
    VendorID          INT           NOT NULL,
    ItemName          NVARCHAR(150) NOT NULL,
    Category          NVARCHAR(50)  NOT NULL,
    Price             DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    EstimatedPrepTime INT           NOT NULL DEFAULT 10
        CHECK (EstimatedPrepTime > 0),
    IsAvailable       BIT           NOT NULL DEFAULT 1,
    FOREIGN KEY (VendorID) REFERENCES FoodVendors(VendorID) ON DELETE CASCADE
);
GO

-- ------------------------------------------------------------------
-- FoodCourtTables
-- ------------------------------------------------------------------
CREATE TABLE FoodCourtTables (
    TableID     INT          IDENTITY(1,1) PRIMARY KEY,
    TableNumber NVARCHAR(20) NOT NULL UNIQUE,
    AreaName    NVARCHAR(50) NOT NULL
        CHECK (AreaName IN ('Quiet Zone','Study Area','Main Hall',
                            'Outdoor Area','Group Tables','Coffee Area')),
    Capacity    INT          NOT NULL CHECK (Capacity > 0),
    Status      NVARCHAR(20) NOT NULL DEFAULT 'Available'
        CHECK (Status IN ('Available','Occupied','Reserved','Maintenance'))
);
GO

-- ------------------------------------------------------------------
-- Orders
-- ------------------------------------------------------------------
CREATE TABLE Orders (
    OrderID              INT           IDENTITY(1,1) PRIMARY KEY,
    UserID               INT           NOT NULL,
    TableID              INT           NULL,
    OrderDate            DATETIME      NOT NULL DEFAULT GETDATE(),
    OrderType            NVARCHAR(50)  NOT NULL DEFAULT 'Dine-in'
        CHECK (OrderType IN ('Dine-in','Takeaway','Campus Delivery')),
    OrderStatus          NVARCHAR(50)  NOT NULL DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending','Preparing','Ready','Completed','Cancelled')),
    QueueNumber          NVARCHAR(20)  NULL,
    QueueStatus          NVARCHAR(50)  NOT NULL DEFAULT 'Waiting'
        CHECK (QueueStatus IN ('Waiting','Preparing','Ready','Completed','Cancelled')),
    QueueCreatedTime     DATETIME      NOT NULL DEFAULT GETDATE(),
    EstimatedWaitingTime INT           NOT NULL DEFAULT 0,
    TotalAmount          DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID)  REFERENCES Users(UserID),
    FOREIGN KEY (TableID) REFERENCES FoodCourtTables(TableID)
);
GO

-- ------------------------------------------------------------------
-- OrderDetails
-- ------------------------------------------------------------------
CREATE TABLE OrderDetails (
    OrderDetailID INT           IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT           NOT NULL,
    MenuID        INT           NOT NULL,
    Quantity      INT           NOT NULL CHECK (Quantity > 0),
    UnitPrice     DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    SubTotal      DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (MenuID)  REFERENCES MenuItems(MenuID)
);
GO

-- ------------------------------------------------------------------
-- Payments
-- ------------------------------------------------------------------
CREATE TABLE Payments (
    PaymentID     INT           IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT           NOT NULL UNIQUE,
    PaymentDate   DATETIME      NOT NULL DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50)  NOT NULL
        CHECK (PaymentMethod IN ('Cash','Student Card','Credit Card',
                                 'Online Payment','Loyalty Points')),
    Amount        DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    PaymentStatus NVARCHAR(50)  NOT NULL DEFAULT 'Completed'
        CHECK (PaymentStatus IN ('Pending','Completed','Failed','Refunded')),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);
GO

-- =========================================================================
-- SECTION 3 - TRIGGERS
-- =========================================================================

-- T1: Mark table Occupied when a Dine-in order is inserted
CREATE TRIGGER trg_UpdateTableStatus_OnOrder
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE fct
    SET    fct.Status = 'Occupied'
    FROM   FoodCourtTables fct
    INNER  JOIN inserted i ON fct.TableID = i.TableID
    WHERE  i.OrderType = 'Dine-in'
      AND  i.TableID   IS NOT NULL;
END;
GO

-- T2: Free the table when an order is Completed or Cancelled
CREATE TRIGGER trg_UpdateTableStatus_OnOrderComplete
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(QueueStatus) OR UPDATE(OrderStatus)
    BEGIN
        UPDATE fct
        SET    fct.Status = 'Available'
        FROM   FoodCourtTables fct
        INNER  JOIN inserted i ON fct.TableID = i.TableID
        WHERE  i.TableID IS NOT NULL
          AND  (i.QueueStatus IN ('Completed','Cancelled')
             OR i.OrderStatus IN ('Completed','Cancelled'));
    END
END;
GO

-- T3: Auto-calculate SubTotal, TotalAmount, EstimatedWaitingTime
CREATE TRIGGER trg_CalculateTotalsAndWaitTime
ON OrderDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE od
        SET    od.SubTotal = od.Quantity * od.UnitPrice
        FROM   OrderDetails od
        INNER  JOIN inserted i ON od.OrderDetailID = i.OrderDetailID;
    END

    DECLARE @Affected TABLE (OrderID INT PRIMARY KEY);
    INSERT INTO @Affected (OrderID)
        SELECT DISTINCT OrderID FROM inserted
        UNION
        SELECT DISTINCT OrderID FROM deleted;

    UPDATE o
    SET
        o.TotalAmount = ISNULL(
            (SELECT SUM(od.SubTotal)
             FROM   OrderDetails od
             WHERE  od.OrderID = o.OrderID), 0),
        o.EstimatedWaitingTime = ISNULL(
            (SELECT SUM(mi.EstimatedPrepTime)
             FROM   OrderDetails od
             JOIN   MenuItems    mi ON od.MenuID = mi.MenuID
             WHERE  od.OrderID = o.OrderID), 0)
    FROM  Orders o
    INNER JOIN @Affected a ON o.OrderID = a.OrderID;
END;
GO

-- T4: Reject invalid OrderDetails rows
CREATE TRIGGER trg_PreventInvalidData
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE Quantity <= 0 OR UnitPrice < 0)
    BEGIN
        RAISERROR('Quantity must be > 0 and UnitPrice cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- T5: Auto-generate QueueNumber after Orders INSERT
CREATE TRIGGER trg_GenerateQueueNumber
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE o
    SET    o.QueueNumber = 'Q' + RIGHT('000' + CAST(i.OrderID AS NVARCHAR(10)), 3)
    FROM   Orders   o
    INNER  JOIN inserted i ON o.OrderID = i.OrderID;
END;
GO

-- T6: On payment completion - move queue to Preparing + award loyalty
CREATE TRIGGER trg_ProcessPaymentEffects
ON Payments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET    o.QueueStatus = 'Preparing',
           o.OrderStatus = 'Preparing'
    FROM   Orders   o
    INNER  JOIN inserted i ON o.OrderID = i.OrderID
    WHERE  i.PaymentStatus = 'Completed'
      AND  o.QueueStatus   = 'Waiting';

    IF TRIGGER_NESTLEVEL() <= 1
    BEGIN
        DECLARE @Pts TABLE (UserID INT, Pts INT);

        INSERT INTO @Pts (UserID, Pts)
        SELECT o.UserID,
               CAST(i.Amount / 10 AS INT)
        FROM   inserted i
        JOIN   Orders   o ON i.OrderID = o.OrderID
        WHERE  i.PaymentStatus  = 'Completed'
          AND  i.PaymentMethod <> 'Loyalty Points'
          AND  NOT EXISTS (
                   SELECT 1 FROM deleted d
                   WHERE  d.PaymentID     = i.PaymentID
                     AND  d.PaymentStatus = 'Completed');

        UPDATE u
        SET    u.TotalPointsEarned    = u.TotalPointsEarned    + p.Pts,
               u.CurrentPointsBalance = u.CurrentPointsBalance + p.Pts
        FROM   Users u
        JOIN   @Pts  p ON u.UserID = p.UserID
        WHERE  p.Pts > 0;
    END
END;
GO

-- =========================================================================
-- SECTION 4 - STORED PROCEDURES
-- =========================================================================

-- SP1: Place an order (up to 3 items)
CREATE PROCEDURE sp_ProcessFoodCourtOrder
    @UserID     INT,
    @TableID    INT           = NULL,
    @OrderType  NVARCHAR(50),
    @MenuID1    INT,           @Qty1  INT,
    @MenuID2    INT           = NULL, @Qty2  INT = NULL,
    @MenuID3    INT           = NULL, @Qty3  INT = NULL,
    @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @OrderType IS NULL
            SET @OrderType = 'Dine-in';

        INSERT INTO Orders (UserID, TableID, OrderType, OrderStatus, QueueStatus)
        VALUES (@UserID, @TableID, @OrderType, 'Pending', 'Waiting');
        SET @NewOrderID = SCOPE_IDENTITY();

        DECLARE @Price DECIMAL(10,2);

        SELECT @Price = Price FROM MenuItems WHERE MenuID = @MenuID1 AND IsAvailable = 1;
        IF @Price IS NULL
            RAISERROR('MenuID1 not found or unavailable.', 16, 1);
        INSERT INTO OrderDetails (OrderID, MenuID, Quantity, UnitPrice)
        VALUES (@NewOrderID, @MenuID1, @Qty1, @Price);

        IF @MenuID2 IS NOT NULL AND @Qty2 > 0
        BEGIN
            SELECT @Price = Price FROM MenuItems WHERE MenuID = @MenuID2 AND IsAvailable = 1;
            IF @Price IS NOT NULL
                INSERT INTO OrderDetails (OrderID, MenuID, Quantity, UnitPrice)
                VALUES (@NewOrderID, @MenuID2, @Qty2, @Price);
        END

        IF @MenuID3 IS NOT NULL AND @Qty3 > 0
        BEGIN
            SELECT @Price = Price FROM MenuItems WHERE MenuID = @MenuID3 AND IsAvailable = 1;
            IF @Price IS NOT NULL
                INSERT INTO OrderDetails (OrderID, MenuID, Quantity, UnitPrice)
                VALUES (@NewOrderID, @MenuID3, @Qty3, @Price);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP2: Campus delivery shorthand
CREATE PROCEDURE sp_CampusDeliveryOrder
    @UserID  INT,
    @MenuID1 INT,         @Qty1 INT,
    @MenuID2 INT = NULL,  @Qty2 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OID INT;
    EXEC sp_ProcessFoodCourtOrder
        @UserID    = @UserID,
        @TableID   = NULL,
        @OrderType = 'Campus Delivery',
        @MenuID1   = @MenuID1, @Qty1 = @Qty1,
        @MenuID2   = @MenuID2, @Qty2 = @Qty2,
        @NewOrderID = @OID OUTPUT;
END;
GO

-- SP3: Complete payment
CREATE PROCEDURE sp_CompletePayment
    @OrderID       INT,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @PaymentMethod IS NULL OR @PaymentMethod = ''
            SET @PaymentMethod = 'Cash';

        DECLARE @Total DECIMAL(10,2);
        SELECT @Total = TotalAmount FROM Orders WHERE OrderID = @OrderID;
        IF @Total IS NULL
            RAISERROR('Order %d not found.', 16, 1, @OrderID);

        IF NOT EXISTS (SELECT 1 FROM Payments WHERE OrderID = @OrderID)
        BEGIN
            INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentStatus)
            VALUES (@OrderID, @PaymentMethod, ISNULL(@Total, 0), 'Completed');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP4: Advance queue status
CREATE PROCEDURE sp_UpdateQueueStatus
    @OrderID        INT,
    @NewQueueStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Orders
        SET
            QueueStatus = @NewQueueStatus,
            OrderStatus = CASE
                WHEN @NewQueueStatus = 'Completed' THEN 'Completed'
                WHEN @NewQueueStatus = 'Ready'     THEN 'Ready'
                WHEN @NewQueueStatus = 'Cancelled' THEN 'Cancelled'
                ELSE OrderStatus
            END
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP5: Redeem loyalty points (1 point = 1 LE discount)
CREATE PROCEDURE sp_RedeemLoyaltyPoints
    @UserID         INT,
    @PointsToRedeem INT,
    @OrderID        INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Balance  INT;
        DECLARE @Discount DECIMAL(10,2);

        SELECT @Balance = CurrentPointsBalance FROM Users WHERE UserID = @UserID;
        IF @Balance IS NULL
            RAISERROR('UserID %d not found.', 16, 1, @UserID);
        IF @Balance < @PointsToRedeem
            RAISERROR('Insufficient loyalty points (balance: %d, requested: %d).',
                      16, 1, @Balance, @PointsToRedeem);

        SET @Discount = CAST(@PointsToRedeem AS DECIMAL(10,2));

        UPDATE Users
        SET CurrentPointsBalance = CurrentPointsBalance - @PointsToRedeem,
            PointsRedeemed       = PointsRedeemed       + @PointsToRedeem
        WHERE UserID = @UserID;

        UPDATE Orders
        SET TotalAmount = CASE
                            WHEN TotalAmount >= @Discount THEN TotalAmount - @Discount
                            ELSE 0
                          END
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP6: Cancel order
CREATE PROCEDURE sp_CancelOrder
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Orders
        SET OrderStatus = 'Cancelled',
            QueueStatus = 'Cancelled'
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =========================================================================
-- SECTION 5 - SEED DATA
-- =========================================================================

-- ------------------------------------------------------------------
-- 5A. USERS (40 Students | 15 Professors | 15 Staff = 70 total)
-- ------------------------------------------------------------------
INSERT INTO Users (FirstName, LastName, Role, Email, PhoneNumber) VALUES
-- Students (1-40)
('James',       'Smith',       'Student',   'j.smith@student.edu',       '555-0101'),
('Mary',        'Johnson',     'Student',   'm.johnson@student.edu',     '555-0102'),
('Robert',      'Williams',    'Student',   'r.williams@student.edu',    '555-0103'),
('Patricia',    'Brown',       'Student',   'p.brown@student.edu',       '555-0104'),
('John',        'Jones',       'Student',   'j.jones@student.edu',       '555-0105'),
('Jennifer',    'Garcia',      'Student',   'j.garcia@student.edu',      '555-0106'),
('Michael',     'Miller',      'Student',   'm.miller@student.edu',      '555-0107'),
('Linda',       'Davis',       'Student',   'l.davis@student.edu',       '555-0108'),
('William',     'Rodriguez',   'Student',   'w.rodriguez@student.edu',   '555-0109'),
('Elizabeth',   'Martinez',    'Student',   'e.martinez@student.edu',    '555-0110'),
('David',       'Hernandez',   'Student',   'd.hernandez@student.edu',   '555-0111'),
('Barbara',     'Lopez',       'Student',   'b.lopez@student.edu',       '555-0112'),
('Richard',     'Gonzalez',    'Student',   'r.gonzalez@student.edu',    '555-0113'),
('Susan',       'Wilson',      'Student',   's.wilson@student.edu',      '555-0114'),
('Joseph',      'Anderson',    'Student',   'j.anderson@student.edu',    '555-0115'),
('Jessica',     'Thomas',      'Student',   'j.thomas@student.edu',      '555-0116'),
('Thomas',      'Taylor',      'Student',   't.taylor@student.edu',      '555-0117'),
('Sarah',       'Moore',       'Student',   's.moore@student.edu',       '555-0118'),
('Charles',     'Jackson',     'Student',   'c.jackson@student.edu',     '555-0119'),
('Karen',       'Martin',      'Student',   'k.martin@student.edu',      '555-0120'),
('Christopher', 'Lee',         'Student',   'c.lee@student.edu',         '555-0121'),
('Nancy',       'Perez',       'Student',   'n.perez@student.edu',       '555-0122'),
('Daniel',      'Thompson',    'Student',   'd.thompson@student.edu',    '555-0123'),
('Lisa',        'White',       'Student',   'l.white@student.edu',       '555-0124'),
('Matthew',     'Harris',      'Student',   'm.harris@student.edu',      '555-0125'),
('Betty',       'Sanchez',     'Student',   'b.sanchez@student.edu',     '555-0126'),
('Anthony',     'Clark',       'Student',   'a.clark@student.edu',       '555-0127'),
('Margaret',    'Ramirez',     'Student',   'm.ramirez@student.edu',     '555-0128'),
('Mark',        'Lewis',       'Student',   'm.lewis@student.edu',       '555-0129'),
('Sandra',      'Robinson',    'Student',   's.robinson@student.edu',    '555-0130'),
('Donald',      'Walker',      'Student',   'd.walker@student.edu',      '555-0131'),
('Ashley',      'Young',       'Student',   'a.young@student.edu',       '555-0132'),
('Steven',      'Allen',       'Student',   's.allen@student.edu',       '555-0133'),
('Kimberly',    'King',        'Student',   'k.king@student.edu',        '555-0134'),
('Paul',        'Wright',      'Student',   'p.wright@student.edu',      '555-0135'),
('Emily',       'Scott',       'Student',   'e.scott@student.edu',       '555-0136'),
('Andrew',      'Torres',      'Student',   'a.torres@student.edu',      '555-0137'),
('Donna',       'Nguyen',      'Student',   'd.nguyen@student.edu',      '555-0138'),
('Joshua',      'Hill',        'Student',   'j.hill@student.edu',        '555-0139'),
('Michelle',    'Flores',      'Student',   'm.flores@student.edu',      '555-0140'),
-- Professors (41-55)
('Dr. Alan',    'Turing',      'Professor', 'a.turing@faculty.edu',      '555-0201'),
('Dr. Grace',   'Hopper',      'Professor', 'g.hopper@faculty.edu',      '555-0202'),
('Dr. Ada',     'Lovelace',    'Professor', 'a.lovelace@faculty.edu',    '555-0203'),
('Dr. John',    'von Neumann', 'Professor', 'j.neumann@faculty.edu',     '555-0204'),
('Dr. Margaret','Hamilton',    'Professor', 'm.hamilton@faculty.edu',    '555-0205'),
('Dr. Richard', 'Feynman',     'Professor', 'r.feynman@faculty.edu',     '555-0206'),
('Dr. Marie',   'Curie',       'Professor', 'm.curie@faculty.edu',       '555-0207'),
('Dr. Albert',  'Einstein',    'Professor', 'a.einstein@faculty.edu',    '555-0208'),
('Dr. Isaac',   'Newton',      'Professor', 'i.newton@faculty.edu',      '555-0209'),
('Dr. Galileo', 'Galilei',     'Professor', 'g.galilei@faculty.edu',     '555-0210'),
('Dr. Charles', 'Darwin',      'Professor', 'c.darwin@faculty.edu',      '555-0211'),
('Dr. Nikola',  'Tesla',       'Professor', 'n.tesla@faculty.edu',       '555-0212'),
('Dr. Stephen', 'Hawking',     'Professor', 's.hawking@faculty.edu',     '555-0213'),
('Dr. Jane',    'Goodall',     'Professor', 'j.goodall@faculty.edu',     '555-0214'),
('Dr. Carl',    'Sagan',       'Professor', 'c.sagan@faculty.edu',       '555-0215'),
-- Staff (56-70)
('Oliver',      'Green',       'Staff',     'o.green@admin.edu',         '555-0301'),
('Sophia',      'Baker',       'Staff',     's.baker@admin.edu',         '555-0302'),
('Liam',        'Adams',       'Staff',     'l.adams@admin.edu',         '555-0303'),
('Emma',        'Nelson',      'Staff',     'e.nelson@admin.edu',        '555-0304'),
('Noah',        'Carter',      'Staff',     'n.carter@admin.edu',        '555-0305'),
('Ava',         'Mitchell',    'Staff',     'a.mitchell@admin.edu',      '555-0306'),
('Elijah',      'Perez',       'Staff',     'e.perez@admin.edu',         '555-0307'),
('Isabella',    'Roberts',     'Staff',     'i.roberts@admin.edu',       '555-0308'),
('Lucas',       'Turner',      'Staff',     'l.turner@admin.edu',        '555-0309'),
('Mia',         'Phillips',    'Staff',     'm.phillips@admin.edu',      '555-0310'),
('Mason',       'Campbell',    'Staff',     'm.campbell@admin.edu',      '555-0311'),
('Amelia',      'Parker',      'Staff',     'a.parker@admin.edu',        '555-0312'),
('Logan',       'Evans',       'Staff',     'l.evans@admin.edu',         '555-0313'),
('Harper',      'Edwards',     'Staff',     'h.edwards@admin.edu',       '555-0314'),
('Ethan',       'Collins',     'Staff',     'e.collins@admin.edu',       '555-0315');
GO

-- ------------------------------------------------------------------
-- 5B. FOOD VENDORS (9 total)
-- ------------------------------------------------------------------
INSERT INTO FoodVendors (VendorName, Location) VALUES
('The Breakfast Bus',  'Food Court East Wing'),   -- VendorID 1 (real menu - unchanged)
('Santa Cafe',         'Food Court West Wing'),   -- VendorID 2 (real menu - unchanged)
('Pablo',              'Main Hall Center'),        -- VendorID 3 (NEW - pizza, pasta, sandwiches)
('Bites',              'Food Court East Wing'),   -- VendorID 4 (NEW - coffee, desserts, bakery)
('Food Friends',       'Food Court North Wing'),  -- VendorID 5 (NEW - Syrian fries, crepes, burgers)
('Pasta Express',      'Food Court South Wing'),  -- VendorID 6 (unchanged)
('Study Break Cafe',   'Library Area'),           -- VendorID 7 (unchanged)
('Fresh Juice Point',  'Main Hall Entrance'),     -- VendorID 8 (unchanged)
('Late Night Snacks',  'Food Court Center');      -- VendorID 9 (unchanged)
GO

-- ------------------------------------------------------------------
-- 5C. MENU ITEMS
-- ------------------------------------------------------------------

-- ================================================================
-- VENDOR 1 - THE BREAKFAST BUS (real menu, unchanged)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Foul (Fava Bean dishes)
(1, 'Classic Foul',                                  'Mains',     15.00,  5),
(1, 'Spicy Oil Foul',                                'Mains',     15.00,  5),
(1, 'Lemon Foul',                                    'Mains',     20.00,  5),
(1, 'Foul with Egg',                                 'Mains',     25.00,  8),
(1, 'Alexandrian Foul',                              'Mains',     20.00,  5),
(1, 'Foul with Sausage',                             'Mains',     25.00,  8),
(1, 'Foul with Ghee',                                'Mains',     25.00,  5),
(1, 'Spicy Mix Foul',                                'Mains',     20.00,  5),
-- Falafel
(1, 'Classic Falafel',                               'Mains',     15.00,  5),
(1, 'Spiced Tomato Falafel',                         'Mains',     20.00,  7),
(1, 'Stuffed Falafel',                               'Mains',     20.00,  8),
(1, 'Falafel with Egg',                              'Mains',     25.00,  8),
(1, 'Curry Falafel',                                 'Mains',     25.00,  8),
-- Potatoes
(1, 'Fried Potatoes',                                'Sides',     15.00, 10),
(1, 'Potatoes with Ketchup and Mayo',                'Sides',     20.00, 10),
(1, 'Mashed Potatoes',                               'Sides',     20.00, 10),
(1, 'Shrimp Potatoes',                               'Sides',     20.00, 12),
(1, 'Rumi Cheese Potatoes',                          'Sides',     30.00, 12),
(1, 'Potatoes with Egg',                             'Sides',     25.00, 10),
(1, 'Puree with Pastrami',                           'Sides',     30.00, 12),
-- Eggs and Cheese
(1, 'Boiled Eggs',                                   'Mains',     15.00,  5),
(1, 'Eggs with Rumi Cheese',                         'Mains',     25.00,  8),
(1, 'Eggs Mixed Cheese',                             'Mains',     25.00,  8),
(1, 'Eggs Slanesh Style',                            'Mains',     25.00,  8),
(1, 'Eggs with Sausage',                             'Mains',     30.00,  8),
(1, 'Eggs with Pastrami',                            'Mains',     30.00,  8),
(1, 'Fried Cheese',                                  'Sides',     35.00,  8),
(1, 'White Cheese with Tomato and Thyme',            'Sides',     25.00,  5),
(1, 'Rumi Cheese with Tomato',                       'Sides',     25.00,  5),
(1, 'Rumi Cheese with Pastrami',                     'Sides',     30.00,  5),
-- Potato Bucket
(1, 'Potato Bucket',                                 'Sides',     25.00, 10),
(1, 'Stress Potato Bucket',                          'Sides',     50.00, 12),
-- Snacks
(1, 'Chips',                                         'Snacks',    10.00,  1),
(1, 'Molto',                                         'Snacks',    20.00,  1),
(1, 'Twix Bar',                                      'Snacks',    10.00,  1),
(1, 'Hohos',                                         'Snacks',     5.00,  1),
-- Beverages
(1, 'Water',                                         'Beverages',  5.00,  1),
(1, 'Soft Drinks',                                   'Beverages', 20.00,  1),
(1, 'Tea with Milk',                                 'Beverages', 15.00,  3),
(1, 'Mint Tea',                                      'Beverages', 10.00,  3),
-- Special Sandwiches
(1, 'Bazooka Sandwich',                              'Mains',     30.00, 12),
(1, 'Giant Sandwich',                                'Mains',     50.00, 15),
(1, 'Valentino Sandwich',                            'Mains',     40.00, 12),
(1, 'Hawawshi',                                      'Mains',     50.00, 15),
(1, 'Tuna Shami Salad',                              'Sides',     20.00,  5),
(1, 'Tuna Fino Salad',                               'Sides',     25.00,  5),
(1, 'Shami Sausage Sandwich',                        'Mains',     35.00, 10),
(1, 'Fino Sausage Sandwich',                         'Mains',     45.00, 10),
(1, 'Shish Fino',                                    'Mains',     75.00, 15),
(1, 'Stress Fino',                                   'Mains',     65.00, 12),
(1, 'Hot Dog',                                       'Mains',     30.00, 10),
(1, 'Alexandrian Liver Sandwich',                    'Mains',     40.00, 10),
(1, 'Syrian Meat Shawarma',                          'Mains',     75.00, 15),
(1, 'Syrian Chicken Shawarma',                       'Mains',     70.00, 15),
-- Combo
(1, 'Full Breakfast Box (Foul + Falafel + Potatoes + Tea)', 'Combo', 60.00, 15),
(1, 'Al-Jadaan Deal (Stress Fino + Sausage)',         'Combo',    85.00, 15);
GO

-- ================================================================
-- VENDOR 2 - SANTA CAFE (real menu, unchanged)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Ice Coffee
(2, 'Ice Latte',                           'Ice Coffee',  40.00, 5),
(2, 'Ice Mocha',                           'Ice Coffee',  45.00, 5),
(2, 'Frappuccino',                         'Ice Coffee',  55.00, 7),
(2, 'Frappe Caramel',                      'Ice Coffee',  65.00, 8),
(2, 'Frappe Lotts',                        'Ice Coffee',  65.00, 8),
(2, 'Oreo Frappe',                         'Ice Coffee',  70.00, 8),
(2, 'Frappe Vanilla',                      'Ice Coffee',  60.00, 7),
(2, 'Frappe Bastachio',                    'Ice Coffee',  85.00, 8),
(2, 'Spanish Latte',                       'Ice Coffee',  55.00, 6),
(2, 'Spanish Mocha Latte',                 'Ice Coffee',  60.00, 6),
(2, 'Spanish Bastachio Latte',             'Ice Coffee',  75.00, 7),
(2, 'Ice Matcha',                          'Ice Coffee',  45.00, 5),
(2, 'Ice Tea',                             'Ice Coffee',  35.00, 3),
-- Milk Shake
(2, 'Milk Shake Vanilla',                  'Milk Shake',  55.00, 7),
(2, 'Milk Shake Chocolate',                'Milk Shake',  55.00, 7),
(2, 'Shake Blue Berry',                    'Milk Shake',  60.00, 7),
(2, 'Milk Shake Mix Berry',                'Milk Shake',  60.00, 7),
(2, 'Milk Shake Flaver',                   'Milk Shake',  60.00, 7),
(2, 'Milk Shake Mango',                    'Milk Shake',  65.00, 7),
(2, 'Milk Shake Strawberry',               'Milk Shake',  65.00, 7),
(2, 'Milk Shake Lotus',                    'Milk Shake',  65.00, 7),
(2, 'Milk Shake Caramel',                  'Milk Shake',  70.00, 8),
(2, 'Milk Shake Oreo',                     'Milk Shake',  70.00, 8),
(2, 'Milk Shake Bastachio',                'Milk Shake',  85.00, 8),
-- Hot Drinks
(2, 'Tea',                                 'Hot Drinks',  10.00, 3),
(2, 'Green Tea / Yanson / Mint / Carcadie','Hot Drinks',  15.00, 3),
(2, 'Tea with Milk',                       'Hot Drinks',  30.00, 4),
(2, 'Flavours Coffee',                     'Hot Drinks',  40.00, 5),
(2, 'Turkish Coffee',                      'Hot Drinks',  30.00, 5),
(2, 'French Coffee',                       'Hot Drinks',  35.00, 5),
(2, 'Hazelnut Coffee',                     'Hot Drinks',  45.00, 5),
(2, 'Espresso',                            'Hot Drinks',  35.00, 3),
(2, 'Latte',                               'Hot Drinks',  35.00, 5),
(2, 'Cappuccino',                          'Hot Drinks',  40.00, 5),
(2, 'Mocha',                               'Hot Drinks',  40.00, 5),
(2, 'Hot Cedar',                           'Hot Drinks',  30.00, 4),
(2, 'Hot Chocolate',                       'Hot Drinks',  35.00, 5),
(2, 'Sahlab',                              'Hot Drinks',  35.00, 5),
(2, 'Nescafe',                             'Hot Drinks',  40.00, 3),
(2, 'Nescafe Black',                       'Hot Drinks',  30.00, 3),
(2, 'Flat White',                          'Hot Drinks',  45.00, 5),
(2, 'American Coffee',                     'Hot Drinks',  40.00, 4),
(2, 'Cortado',                             'Hot Drinks',  40.00, 4),
(2, 'Caffe Macchiato',                     'Hot Drinks',  40.00, 4),
-- Breakfast (Croissant-based)
(2, 'Rumi Cheese Corason',                 'Breakfast',   40.00, 3),
(2, 'Kerry Cheese Corason',                'Breakfast',   40.00, 3),
(2, 'White Cheese Corason',                'Breakfast',   40.00, 3),
(2, 'Turkey and Cheese Corason',           'Breakfast',   45.00, 3),
(2, 'Mix Cheese Bastrami',                 'Breakfast',   60.00, 5),
(2, 'Nutella Corason',                     'Breakfast',   50.00, 3),
(2, 'White Nutella Corason',               'Breakfast',   50.00, 3),
(2, 'Lotus Corason',                       'Breakfast',   55.00, 3),
(2, 'Caramel Corason',                     'Breakfast',   65.00, 3),
(2, 'Bastachio Corason',                   'Breakfast',   75.00, 3),
-- Fresh Juices
(2, 'Fresh Mango',                         'Fresh Juice', 55.00, 5),
(2, 'Fresh Strawberry',                    'Fresh Juice', 55.00, 5),
(2, 'Fresh Guava',                         'Fresh Juice', 40.00, 5),
(2, 'Fresh Orange',                        'Fresh Juice', 55.00, 5),
(2, 'Fresh Lemon',                         'Fresh Juice', 30.00, 5),
(2, 'Fresh Lemon Mint',                    'Fresh Juice', 35.00, 5),
(2, 'Fresh Cocktail',                      'Fresh Juice', 50.00, 6),
(2, 'Fresh Guava with Milk',               'Fresh Juice', 45.00, 5),
(2, 'Fresh Strawberry with Milk',          'Fresh Juice', 60.00, 5),
(2, 'Fresh Watermelon',                    'Fresh Juice', 50.00, 5),
-- Smoothies
(2, 'Smoothy Lemon',                       'Smoothie',    30.00, 6),
(2, 'Smoothy Lemon Mint',                  'Smoothie',    40.00, 6),
(2, 'Smoothy Blue Berry',                  'Smoothie',    50.00, 6),
(2, 'Smoothy Mix Berry',                   'Smoothie',    50.00, 6),
(2, 'Smoothy Peach',                       'Smoothie',    50.00, 6),
(2, 'Smoothy Pineapple',                   'Smoothie',    50.00, 6),
(2, 'Smoothy Passion Fruit',               'Smoothie',    50.00, 6),
(2, 'Smoothy Fresh Mango',                 'Smoothie',    60.00, 6),
(2, 'Smoothy Fresh Strawberry',            'Smoothie',    60.00, 6),
(2, 'Smoothy Fresh Watermelon',            'Smoothie',    55.00, 6),
(2, 'Smoothy Fresh Watermelon Mint',       'Smoothie',    60.00, 6),
(2, 'Smoothy Pina Colada',                 'Smoothie',    60.00, 6),
(2, 'Smoothy Cola',                        'Smoothie',    50.00, 6),
(2, 'Smoothy Redbull',                     'Smoothie',    50.00, 6),
(2, 'Smoothy Mango Kiwi',                  'Smoothie',    65.00, 7),
(2, 'Smoothy Mango Passion Fruit',         'Smoothie',    65.00, 7),
(2, 'Smoothy Mango Peach',                 'Smoothie',    65.00, 7),
(2, 'Smoothy Mango Passion Fruit Kiwi',    'Smoothie',    65.00, 7),
(2, 'Smoothy Passion Fruit Pineapple',     'Smoothie',    65.00, 7),
(2, 'Smoothy Lemon Pineapple',             'Smoothie',    65.00, 7),
-- Soft Drinks
(2, 'Bottled Water',                       'Soft Drinks',  8.00, 1),
(2, 'Cans',                                'Soft Drinks', 20.00, 1),
(2, 'Fury',                                'Soft Drinks', 25.00, 1),
(2, 'Redbull',                             'Soft Drinks', 55.00, 1),
(2, 'Mojito Redbull Blue Berry',           'Soft Drinks', 75.00, 5),
(2, 'Mojito Redbull Flaver',               'Soft Drinks', 75.00, 5),
(2, 'Mojito',                              'Soft Drinks', 40.00, 5),
(2, 'Mojito Blue Berry',                   'Soft Drinks', 40.00, 5),
(2, 'Mojito Flaver',                       'Soft Drinks', 40.00, 5),
(2, 'Blue Hawai',                          'Soft Drinks', 50.00, 5),
(2, 'Sun Shaine',                          'Soft Drinks', 50.00, 5),
(2, 'Sun Rise',                            'Soft Drinks', 50.00, 5),
(2, 'Scotch Mint',                         'Soft Drinks', 45.00, 5),
-- Desserts
(2, 'Waffle Nutella',                      'Desserts',    40.00, 12),
(2, 'Waffle Lotus',                        'Desserts',    45.00, 12),
(2, 'Waffle Caramel',                      'Desserts',    45.00, 12),
(2, 'Waffle Oreo',                         'Desserts',    55.00, 12),
(2, 'Waffle Bastachio',                    'Desserts',    75.00, 12),
(2, 'Pancake Nutella',                     'Desserts',    30.00, 10),
(2, 'Pancake Lotus',                       'Desserts',    30.00, 10),
(2, 'Pancake Caramel',                     'Desserts',    40.00, 10),
(2, 'Pancake Oreo',                        'Desserts',    40.00, 10),
(2, 'Pancake Bastachio',                   'Desserts',    70.00, 10),
(2, 'Fresca Nutella',                      'Desserts',    20.00,  5),
(2, 'Fresca Lotus',                        'Desserts',    25.00,  5),
(2, 'Fresca Caramel',                      'Desserts',    30.00,  5),
(2, 'Fresca Oreo',                         'Desserts',    30.00,  5),
(2, 'Fresca Bastachio',                    'Desserts',    50.00,  5),
(2, 'Tajen Nutella',                       'Desserts',    60.00, 15),
(2, 'Tajen Bastachio',                     'Desserts',    90.00, 15),
-- Extras
(2, 'Extra Milk',                          'Extra',       15.00,  1),
(2, 'Extra Skimmed Milk',                  'Extra',       15.00,  1),
(2, 'Extra Coconut Milk',                  'Extra',       25.00,  1),
(2, 'Extra Espresso Shot',                 'Extra',       20.00,  1),
(2, 'Extra Flaver',                        'Extra',       15.00,  1),
(2, 'Extra Whipped Cream',                 'Extra',       15.00,  1);
GO

-- ================================================================
-- VENDOR 3 - PABLO
-- Main categories first: Pizza, Sandwiches, Pasta, Crepe
-- Then: Waffle, Mini Pancake, Sides, Combo
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- === MAIN CATEGORY 1: Pizza ===
-- Medium (M) sizes listed; combo 55 LE noted in menu header
(3, 'Pizza Ranch (M)',                     'Pizza',       115.00, 15),
(3, 'Pizza BBQ (M)',                       'Pizza',       115.00, 15),
(3, 'Pizza Strips (M)',                    'Pizza',       120.00, 15),
(3, 'Pizza Crispy (M)',                    'Pizza',       115.00, 15),
(3, 'Pizza Pepperoni (M)',                 'Pizza',       115.00, 15),
(3, 'Pizza Sausage (M)',                   'Pizza',       115.00, 15),
(3, 'Pizza Margherita (M)',                'Pizza',        70.00, 12),
(3, 'Pizza Vegetable (M)',                 'Pizza',        85.00, 12),
(3, 'Pizza Pastrami (M)',                  'Pizza',       120.00, 15),
(3, 'Pizza Ranch (S)',                     'Pizza',        90.00, 12),
(3, 'Pizza BBQ (S)',                       'Pizza',        90.00, 12),
(3, 'Pizza Strips (S)',                    'Pizza',        95.00, 12),
(3, 'Pizza Crispy (S)',                    'Pizza',        90.00, 12),
(3, 'Pizza Pepperoni (S)',                 'Pizza',        90.00, 12),
(3, 'Pizza Sausage (S)',                   'Pizza',        90.00, 12),
(3, 'Pizza Margherita (S)',                'Pizza',        60.00, 10),
(3, 'Pizza Vegetable (S)',                 'Pizza',        70.00, 10),
(3, 'Pizza Pastrami (S)',                  'Pizza',        95.00, 12),
-- === MAIN CATEGORY 2: Sandwiches ===
(3, 'Crunchy Burger',                      'Sandwiches',   80.00, 10),
(3, 'Beef Burger',                         'Sandwiches',   70.00, 10),
(3, 'Hawawshi',                            'Sandwiches',   55.00, 12),
(3, 'Mozzarella Hawawshi',                 'Sandwiches',   65.00, 12),
(3, 'Syrian Fries Sandwich',               'Sandwiches',   50.00,  8),
(3, 'Mozzarella Syrian Fries Sandwich',    'Sandwiches',   60.00,  8),
(3, 'Syrian Strips Sandwich',              'Sandwiches',   50.00, 10),
(3, 'Burger + Fries',                      'Sandwiches',   90.00, 12),
(3, 'Strips + Fries',                      'Sandwiches',   90.00, 12),
-- === MAIN CATEGORY 3: Pasta ===
(3, 'White Sauce Pasta',                   'Pasta',        50.00, 12),
(3, 'White Pasta with Strips',             'Pasta',        80.00, 15),
(3, 'Red Sauce Pasta',                     'Pasta',        45.00, 12),
(3, 'Red Sauce Pasta with Strips',         'Pasta',        75.00, 15),
-- === MAIN CATEGORY 4: Crepe ===
(3, 'Potato Crepe',                        'Crepe',        65.00, 10),
(3, 'Strips Crepe',                        'Crepe',        95.00, 12),
(3, 'Crispy Crepe',                        'Crepe',        80.00, 12),
(3, 'Sausage Crepe',                       'Crepe',        80.00, 12),
(3, 'Chicken Crepe',                       'Crepe',        90.00, 12),
(3, 'Burger Crepe',                        'Crepe',        85.00, 12),
(3, 'Mixed Chicken Crepe',                 'Crepe',       120.00, 15),
-- === Waffle ===
(3, 'Waffle Chocolate',                    'Waffle',       60.00, 12),
(3, 'Waffle White',                        'Waffle',       60.00, 12),
(3, 'Waffle Lotus',                        'Waffle',       60.00, 12),
(3, 'Waffle Kinder',                       'Waffle',       80.00, 12),
(3, 'Waffle Pistachio',                    'Waffle',       80.00, 12),
(3, 'Waffle Mix',                          'Waffle',       85.00, 12),
-- === Mini Pancake ===
(3, 'Mini Pancake Chocolate',              'Mini Pancake', 60.00, 10),
(3, 'Mini Pancake White',                  'Mini Pancake', 60.00, 10),
(3, 'Mini Pancake Lotus',                  'Mini Pancake', 60.00, 10),
(3, 'Mini Pancake Kinder',                 'Mini Pancake', 80.00, 10),
(3, 'Mini Pancake Pistachio',              'Mini Pancake', 75.00, 10),
-- === Sides ===
(3, 'Potato Packet',                       'Sides',        40.00,  8),
(3, 'Potato Packet + Mozzarella + Cheddar','Sides',        50.00, 10),
(3, 'Fries with Ketchup and Mayo',         'Sides',        45.00,  8),
(3, 'Strips on Fries',                     'Sides',        35.00, 10),
-- === Combo ===
(3, 'Meal Deal - Strips + Fries',          'Combo',        80.00, 15),
(3, 'Meal Deal - Strips + Pasta',          'Combo',        80.00, 15);
GO

-- ================================================================
-- VENDOR 4 - BITES
-- Main categories first: Hot Drinks, Iced Coffee, Sandwiches, Pizza
-- Then: Waffle, Dessert, Ice Cream, Bakery, Smoothie & Fresh Juice,
--       Shake, Mojito, Non Coffee, Soft Drink, Extra
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- === MAIN CATEGORY 1: Hot Drinks ===
(4, 'Turkish Coffee',                      'Hot Drinks',   30.00,  5),
(4, 'Turkish Coffee (Large)',              'Hot Drinks',   40.00,  5),
(4, 'French Coffee',                       'Hot Drinks',   40.00,  5),
(4, 'Hazelnut Coffee',                     'Hot Drinks',   45.00,  5),
(4, 'Espresso',                            'Hot Drinks',   35.00,  3),
(4, 'Espresso (Large)',                    'Hot Drinks',   45.00,  3),
(4, 'Macchiato',                           'Hot Drinks',   45.00,  5),
(4, 'Cortado',                             'Hot Drinks',   50.00,  5),
(4, 'Flat White',                          'Hot Drinks',   60.00,  5),
(4, 'Latte',                               'Hot Drinks',   50.00,  5),
(4, 'Cappuccino',                          'Hot Drinks',   55.00,  5),
(4, 'Mocha',                               'Hot Drinks',   55.00,  5),
(4, 'Spanish Latte',                       'Hot Drinks',   65.00,  5),
(4, 'Classic Hot Chocolate',               'Hot Drinks',   55.00,  5),
(4, 'Bites Hot Chocolate',                 'Hot Drinks',   75.00,  5),
-- === MAIN CATEGORY 2: Iced Coffee ===
(4, 'Iced American',                       'Iced Coffee',  45.00,  5),
(4, 'Ice Latte',                           'Iced Coffee',  55.00,  5),
(4, 'Matcha Latte Iced',                   'Iced Coffee',  60.00,  5),
(4, 'Pistachio Latte Iced',                'Iced Coffee',  75.00,  5),
(4, 'Spanish Latte Iced',                  'Iced Coffee',  65.00,  5),
(4, 'Ice Mocha',                           'Iced Coffee',  60.00,  5),
(4, 'White Mocha Latte',                   'Iced Coffee',  65.00,  5),
(4, 'Caramel Latte',                       'Iced Coffee',  65.00,  5),
(4, 'Pistachio Latte',                     'Iced Coffee',  65.00,  5),
(4, 'Salted Caramel Latte',                'Iced Coffee',  60.00,  5),
(4, 'Cookies Caramel Latte',               'Iced Coffee',  75.00,  5),
-- === MAIN CATEGORY 3: Sandwiches ===
(4, 'Chicken Pane Sandwich',               'Sandwiches',   60.00, 10),
(4, 'Zinger Sandwich',                     'Sandwiches',   65.00, 10),
(4, 'French Fries Sandwich',               'Sandwiches',   40.00,  8),
(4, 'French Fries Cheese Sandwich',        'Sandwiches',   50.00,  8),
(4, 'Shawrma Chicken Sandwich',            'Sandwiches',   75.00, 10),
(4, 'Cordon Bleu Sandwich',                'Sandwiches',   75.00, 12),
(4, 'Kofta Sandwich',                      'Sandwiches',   80.00, 12),
(4, 'Tawook Sandwich',                     'Sandwiches',   75.00, 10),
(4, 'Shawrma Meat Sandwich',               'Sandwiches',   90.00, 12),
(4, 'Fried Chicken Sandwich',              'Sandwiches',   90.00, 12),
(4, 'Smash Burger Sandwich',               'Sandwiches',  100.00, 12),
(4, 'Fata Shawrma Sandwich',               'Sandwiches',   90.00, 12),
-- === MAIN CATEGORY 4: Pizza ===
(4, 'Pizza Margrita',                      'Pizza',        70.00, 12),
(4, 'Pizza Vegetables',                    'Pizza',        75.00, 12),
(4, 'Pizza Tuna',                          'Pizza',        90.00, 15),
(4, 'Pizza Sausage',                       'Pizza',        85.00, 15),
(4, 'Pizza Chicken',                       'Pizza',       110.00, 15),
-- === Crepe ===
(4, 'Crepe Chicken Pane',                  'Crepe',        75.00, 10),
(4, 'Crepe Zinger',                        'Crepe',        80.00, 10),
(4, 'Crepe French Fries',                  'Crepe',        60.00,  8),
(4, 'Crepe Tawook',                        'Crepe',        90.00, 10),
(4, 'Crepe Mix Meat',                      'Crepe',        90.00, 12),
(4, 'Crepe Mix Chicken',                   'Crepe',        90.00, 12),
(4, 'Crepe Mix Bites',                     'Crepe',       100.00, 12),
-- === Waffle ===
(4, 'Waffle Chocolate',                    'Waffle',       50.00, 12),
(4, 'Waffle Kinder',                       'Waffle',       50.00, 12),
(4, 'Waffle Lotus',                        'Waffle',       50.00, 12),
(4, 'Waffle Caramel',                      'Waffle',       60.00, 12),
(4, 'Waffle Pistachio',                    'Waffle',       65.00, 12),
-- === Dessert ===
(4, 'Molten Cake',                         'Dessert',      60.00,  8),
(4, 'Eclairs',                             'Dessert',      35.00,  3),
(4, 'Cup Cake',                            'Dessert',      25.00,  2),
-- === Ice Cream ===
(4, 'Ice Cream Cone',                      'Ice Cream',    25.00,  2),
(4, 'Ice Cream Cup',                       'Ice Cream',    25.00,  2),
(4, 'Ice Cream Stick',                     'Ice Cream',    25.00,  2),
(4, 'Ice Cream Witth',                     'Ice Cream',    30.00,  2),
(4, 'Ice Cream Healthy',                   'Ice Cream',    45.00,  2),
(4, 'Ice Cream Kery',                      'Ice Cream',    45.00,  2),
-- === Bakery ===
(4, 'Croissant Plain',                     'Bakery',       40.00,  3),
(4, 'Croissant Cheese',                    'Bakery',       50.00,  3),
(4, 'Croissant Chocolate',                 'Bakery',       50.00,  3),
(4, 'Croissant Pistachio',                 'Bakery',       65.00,  3),
(4, 'Croissant Cold Cuts',                 'Bakery',       50.00,  3),
(4, 'Sausage Croissant Roll',              'Bakery',       50.00,  3),
(4, 'Cheese Croissant Roll',               'Bakery',       50.00,  3),
(4, 'Eftkasa Small Cup',                   'Bakery',       65.00,  5),
(4, 'Eftkasa Large Cup',                   'Bakery',      100.00,  5),
-- === Smoothie & Fresh Juice ===
(4, 'Smoothie Blueberry',                  'Smoothie',     50.00,  6),
(4, 'Smoothie Peach',                      'Smoothie',     50.00,  6),
(4, 'Smoothie Mango',                      'Smoothie',     50.00,  6),
(4, 'Smoothie Passion Fruit',              'Smoothie',     50.00,  6),
(4, 'Smoothie Lemon Mint',                 'Smoothie',     45.00,  6),
(4, 'Smoothie Watermelon Mint',            'Smoothie',     55.00,  6),
(4, 'Smoothie Blue Sky',                   'Smoothie',     55.00,  6),
-- === Shakes ===
(4, 'Shake Ice Chocolate',                 'Shakes',       65.00,  7),
(4, 'Shake Chocolate',                     'Shakes',       70.00,  7),
(4, 'Shake Vanilla',                       'Shakes',       70.00,  7),
(4, 'Shake Oreo',                          'Shakes',       75.00,  7),
(4, 'Shake Strawberry',                    'Shakes',       70.00,  7),
(4, 'Shake Pistachio',                     'Shakes',       75.00,  7),
-- === Mojito ===
(4, 'Mojito Classic',                      'Mojito',       50.00,  5),
(4, 'Mojito Blue Berry',                   'Mojito',       55.00,  5),
(4, 'Mojito Redbull',                      'Mojito',       95.00,  5),
(4, 'Mojito Passion Fruit',                'Mojito',       55.00,  5),
-- === Non Coffee ===
(4, 'Tea',                                 'Non Coffee',   15.00,  3),
(4, 'Green Tea',                           'Non Coffee',   20.00,  3),
(4, 'Milk Tea',                            'Non Coffee',   25.00,  4),
(4, 'Boba Flavour',                        'Non Coffee',   55.00,  5),
-- === Soft Drink ===
(4, 'Water',                               'Soft Drink',   10.00,  1),
(4, 'Redbull',                             'Soft Drink',   70.00,  1),
(4, 'Cans',                                'Soft Drink',   25.00,  1),
-- === Extra ===
(4, 'Extra Flavour',                       'Extra',        10.00,  1),
(4, 'Extra Frappe',                        'Extra',        15.00,  1),
(4, 'Extra Ice',                           'Extra',        10.00,  1),
(4, 'Extra Mozarilla',                     'Extra',        10.00,  1),
(4, 'Extra Chedar',                        'Extra',        15.00,  1),
(4, 'Strips on Fries',                     'Extra',        35.00, 10),
(4, 'Cono',                                'Extra',        20.00,  2);
GO

-- ================================================================
-- VENDOR 5 - FOOD FRIENDS
-- Main categories first: Syrian Fries, Crepe Hot, Sides & Sauces, Burgers
-- Then: Crepe (savory), Sweet Crepe
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- === MAIN CATEGORY 1: Syrian Fries ===
-- Three sizes available (Small/Medium/Large): using Medium as base price
(5, 'Syrian Fries Plain (S)',              'Syrian Fries', 20.00,  8),
(5, 'Syrian Fries Plain (M)',              'Syrian Fries', 35.00,  8),
(5, 'Syrian Fries Plain (L)',              'Syrian Fries', 45.00,  8),
(5, 'Syrian Fries Mozzarella (S)',         'Syrian Fries', 30.00,  8),
(5, 'Syrian Fries Mozzarella (M)',         'Syrian Fries', 45.00,  8),
(5, 'Syrian Fries Mozzarella (L)',         'Syrian Fries', 55.00,  8),
(5, 'Syrian Fries Cheddar (S)',            'Syrian Fries', 30.00,  8),
(5, 'Syrian Fries Cheddar (M)',            'Syrian Fries', 45.00,  8),
(5, 'Syrian Fries Cheddar (L)',            'Syrian Fries', 55.00,  8),
(5, 'Syrian Fries Ranch (S)',              'Syrian Fries', 30.00,  8),
(5, 'Syrian Fries Ranch (M)',              'Syrian Fries', 45.00,  8),
(5, 'Syrian Fries Ranch (L)',              'Syrian Fries', 55.00,  8),
(5, 'Syrian Fries BBQ (S)',                'Syrian Fries', 30.00,  8),
(5, 'Syrian Fries BBQ (M)',                'Syrian Fries', 45.00,  8),
(5, 'Syrian Fries BBQ (L)',                'Syrian Fries', 55.00,  8),
-- === MAIN CATEGORY 2: Burgers ===
(5, 'Burger Zinger (S)',                   'Burgers',      45.00, 10),
(5, 'Burger Zinger (M)',                   'Burgers',      65.00, 10),
(5, 'Burger Zinger (L)',                   'Burgers',      70.00, 10),
(5, 'Burger Strips (S)',                   'Burgers',      45.00, 10),
(5, 'Burger Strips (M)',                   'Burgers',      65.00, 10),
(5, 'Burger Strips (L)',                   'Burgers',      70.00, 10),
(5, 'Burger Beef (S)',                     'Burgers',      35.00, 10),
(5, 'Burger Beef (M)',                     'Burgers',      65.00, 10),
(5, 'Burger Beef (L)',                     'Burgers',      75.00, 10),
(5, 'Burger Egg Beef (S)',                 'Burgers',      40.00, 10),
(5, 'Burger Egg Beef (M)',                 'Burgers',      70.00, 10),
(5, 'Burger Egg Beef (L)',                 'Burgers',      75.00, 10),
(5, 'Burger Mix (S)',                      'Burgers',      45.00, 12),
(5, 'Burger Mix (M)',                      'Burgers',      75.00, 12),
(5, 'Burger Mix (L)',                      'Burgers',      80.00, 12),
(5, 'Kofta (S)',                           'Burgers',      40.00, 10),
(5, 'Kofta (M)',                           'Burgers',      65.00, 10),
(5, 'Kofta (L)',                           'Burgers',      70.00, 10),
-- === MAIN CATEGORY 3: Shawarma & Chicken ===
(5, 'Hot Dog (S)',                         'Shawarma',     35.00,  8),
(5, 'Hot Dog (M)',                         'Shawarma',     55.00,  8),
(5, 'Hot Dog (L)',                         'Shawarma',     60.00,  8),
(5, 'Shawarma Chicken (S)',                'Shawarma',     45.00, 10),
(5, 'Shawarma Chicken (M)',                'Shawarma',     75.00, 10),
(5, 'Shawarma Chicken (L)',                'Shawarma',     80.00, 10),
(5, 'Chicken Ranch (S)',                   'Shawarma',     45.00, 10),
(5, 'Chicken Ranch (M)',                   'Shawarma',     80.00, 10),
(5, 'Chicken Ranch (L)',                   'Shawarma',     85.00, 10),
(5, 'Chicken BBQ (S)',                     'Shawarma',     45.00, 10),
(5, 'Chicken BBQ (M)',                     'Shawarma',     80.00, 10),
(5, 'Chicken BBQ (L)',                     'Shawarma',     85.00, 10),
(5, 'Mix Chicken (S)',                     'Shawarma',     50.00, 12),
(5, 'Mix Chicken (M)',                     'Shawarma',     85.00, 12),
(5, 'Mix Chicken (L)',                     'Shawarma',     90.00, 12),
(5, 'Fahita (S)',                          'Shawarma',     50.00, 12),
(5, 'Fahita (M)',                          'Shawarma',     85.00, 12),
(5, 'Fahita (L)',                          'Shawarma',     90.00, 12),
(5, 'Pastie Fries (S)',                    'Shawarma',     45.00,  8),
(5, 'Pastie Fries (M)',                    'Shawarma',     70.00,  8),
(5, 'Pastie Fries (L)',                    'Shawarma',     75.00,  8),
(5, 'Pastie Crispy (S)',                   'Shawarma',     30.00,  8),
(5, 'Pastie Crispy (M)',                   'Shawarma',     55.00,  8),
(5, 'Pastie Crispy (L)',                   'Shawarma',     60.00,  8),
-- === MAIN CATEGORY 4: Savory Crepes ===
(5, 'Crepe Potato Fries',                  'Savory Crepe', 50.00, 10),
(5, 'Crepe Potato Mozzarella',             'Savory Crepe', 60.00, 10),
(5, 'Crepe Potato Cheddar',                'Savory Crepe', 60.00, 10),
(5, 'Crepe Potato Ranch',                  'Savory Crepe', 60.00, 10),
(5, 'Crepe Potato BBQ',                    'Savory Crepe', 60.00, 10),
(5, 'Crepe Zinger',                        'Savory Crepe', 80.00, 12),
(5, 'Crepe Strips',                        'Savory Crepe', 80.00, 12),
(5, 'Crepe Burger Beef',                   'Savory Crepe', 70.00, 12),
(5, 'Crepe Kofta',                         'Savory Crepe', 70.00, 12),
(5, 'Crepe Hot Dog',                       'Savory Crepe', 65.00, 10),
(5, 'Crepe Shawarma Chicken',              'Savory Crepe', 85.00, 12),
(5, 'Crepe Chicken Ranch',                 'Savory Crepe', 90.00, 12),
(5, 'Crepe Chicken BBQ',                   'Savory Crepe', 90.00, 12),
(5, 'Crepe Mix Chicken',                   'Savory Crepe', 95.00, 12),
(5, 'Crepe Fahita',                        'Savory Crepe', 95.00, 12),
(5, 'Crepe Pastie Fries',                  'Savory Crepe', 80.00, 10),
(5, 'Crepe Pastie Crispy',                 'Savory Crepe', 60.00, 10),
(5, 'Crepe Mix Meat',                      'Savory Crepe', 95.00, 12),
-- === Sweet Crepes ===
(5, 'Crepe Sweet Chocolate',               'Sweet Crepe',  45.00,  8),
(5, 'Crepe Sweet Chocolate Oreo',          'Sweet Crepe',  55.00,  8),
(5, 'Crepe Sweet Chocolate Hoho',          'Sweet Crepe',  55.00,  8),
(5, 'Crepe Sweet Chocolate Hoho Oreo',     'Sweet Crepe',  60.00,  8),
-- === Sides & Sauces ===
(5, 'Potato Packet 25 LE',                 'Sides',        25.00,  8),
(5, 'Sauce Cheddar',                       'Sides',        15.00,  1),
(5, 'Sauce Spicy',                         'Sides',        10.00,  1),
(5, 'Sauce Ranch',                         'Sides',        15.00,  1),
(5, 'Sauce BBQ',                           'Sides',        15.00,  1),
(5, 'Sauce Katchab Spicy',                 'Sides',        10.00,  1),
(5, 'Sauce Mayo',                          'Sides',        15.00,  1),
(5, 'Sauce Ketchup',                       'Sides',        10.00,  1),
(5, 'Sauce BBQ Alo',                       'Sides',        20.00,  1);
GO

-- ================================================================
-- VENDOR 6 - PASTA EXPRESS (unchanged from v2)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Pasta Bowls
(6, 'Spaghetti Bolognese',           'Pasta',    50.00, 12),
(6, 'Fettuccine Alfredo',            'Pasta',    50.00, 12),
(6, 'Penne Arrabbiata',              'Pasta',    45.00, 10),
(6, 'Pesto Fusilli',                 'Pasta',    50.00, 10),
(6, 'Macaroni Bechamel',             'Pasta',    55.00, 15),
(6, 'Creamy Chicken Pasta',          'Pasta',    65.00, 15),
(6, 'Tuna Pasta',                    'Pasta',    55.00, 10),
(6, 'Macaroni and Cheese',           'Pasta',    40.00, 10),
(6, 'Spicy Sausage Pasta',           'Pasta',    60.00, 12),
-- Rice Dishes
(6, 'Chicken Rice Bowl',             'Rice',     55.00, 12),
(6, 'Mixed Fried Rice',              'Rice',     50.00, 12),
(6, 'Grilled Chicken with Rice',     'Rice',     65.00, 15),
-- Sides
(6, 'Garlic Bread',                  'Sides',    15.00,  5),
(6, 'Cheesy Garlic Bread',           'Sides',    25.00,  7),
(6, 'Side Salad',                    'Sides',    15.00,  3),
(6, 'Extra Cheese Topping',          'Extras',   10.00,  1),
-- Combos
(6, 'Pasta Meal (Pasta + Garlic Bread + Drink)', 'Combo', 75.00, 15),
(6, 'Student Rice Box (Rice + Salad + Drink)',   'Combo', 75.00, 15),
-- Drinks
(6, 'Water Bottle',                  'Drinks',    8.00,  1),
(6, 'Cola Can',                      'Drinks',   20.00,  1),
(6, 'Lemon Juice',                   'Drinks',   25.00,  5);
GO

-- ================================================================
-- VENDOR 7 - STUDY BREAK CAFE (unchanged from v2)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Hot Coffee
(7, 'Espresso',                      'Hot Coffee', 25.00, 3),
(7, 'Double Espresso',               'Hot Coffee', 35.00, 3),
(7, 'Americano',                     'Hot Coffee', 30.00, 3),
(7, 'Cappuccino',                    'Hot Coffee', 40.00, 5),
(7, 'Cafe Latte',                    'Hot Coffee', 40.00, 5),
(7, 'Mocha',                         'Hot Coffee', 45.00, 5),
(7, 'Hazelnut Latte',                'Hot Coffee', 50.00, 5),
(7, 'Caramel Latte',                 'Hot Coffee', 50.00, 5),
(7, 'Turkish Coffee',                'Hot Coffee', 25.00, 5),
(7, 'Nescafe',                       'Hot Coffee', 30.00, 3),
-- Iced Coffee
(7, 'Iced Latte',                    'Iced Coffee',45.00, 5),
(7, 'Iced Mocha',                    'Iced Coffee',50.00, 5),
(7, 'Iced Caramel Latte',            'Iced Coffee',55.00, 5),
(7, 'Iced Hazelnut Latte',           'Iced Coffee',55.00, 5),
(7, 'Cold Brew',                     'Iced Coffee',50.00, 3),
(7, 'Frappe Classic',                'Iced Coffee',55.00, 7),
(7, 'Frappe Caramel',                'Iced Coffee',65.00, 7),
(7, 'Oreo Frappe',                   'Iced Coffee',70.00, 7),
-- Hot Drinks (non-coffee)
(7, 'Hot Tea',                       'Hot Drinks', 10.00, 3),
(7, 'Mint Tea',                      'Hot Drinks', 15.00, 3),
(7, 'Green Tea',                     'Hot Drinks', 15.00, 3),
(7, 'Hot Chocolate',                 'Hot Drinks', 35.00, 5),
(7, 'Sahlab',                        'Hot Drinks', 30.00, 5),
(7, 'Tea with Milk',                 'Hot Drinks', 25.00, 4),
-- Bakery & Light Bites
(7, 'Chocolate Croissant',           'Bakery',     30.00, 2),
(7, 'Plain Croissant',               'Bakery',     20.00, 2),
(7, 'Cheese Croissant',              'Bakery',     30.00, 2),
(7, 'Chocolate Muffin',              'Bakery',     25.00, 2),
(7, 'Blueberry Muffin',              'Bakery',     25.00, 2),
(7, 'Banana Bread Slice',            'Bakery',     20.00, 2),
(7, 'Cinnamon Roll',                 'Bakery',     30.00, 3),
(7, 'Cookies (2 pcs)',               'Bakery',     20.00, 1),
-- Study Combos
(7, 'Coffee + Croissant Deal',       'Combo',      60.00, 5),
(7, 'Study Bundle (Latte + Muffin)', 'Combo',      60.00, 5);
GO

-- ================================================================
-- VENDOR 8 - FRESH JUICE POINT (unchanged from v2)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Fresh Juices
(8, 'Fresh Orange Juice',            'Fresh Juice', 40.00, 5),
(8, 'Fresh Mango Juice',             'Fresh Juice', 50.00, 5),
(8, 'Fresh Strawberry Juice',        'Fresh Juice', 50.00, 5),
(8, 'Fresh Watermelon Juice',        'Fresh Juice', 35.00, 5),
(8, 'Fresh Guava Juice',             'Fresh Juice', 35.00, 5),
(8, 'Fresh Apple Juice',             'Fresh Juice', 35.00, 5),
(8, 'Fresh Pomegranate Juice',       'Fresh Juice', 55.00, 5),
(8, 'Carrot and Orange Juice',       'Fresh Juice', 40.00, 5),
(8, 'Mixed Tropical Juice',          'Fresh Juice', 55.00, 6),
-- Lemonade
(8, 'Classic Lemonade',              'Lemonade',    25.00, 5),
(8, 'Mint Lemonade',                 'Lemonade',    30.00, 5),
(8, 'Strawberry Lemonade',           'Lemonade',    40.00, 5),
(8, 'Mango Lemonade',                'Lemonade',    40.00, 5),
(8, 'Watermelon Lemonade',           'Lemonade',    35.00, 5),
-- Smoothies
(8, 'Mango Smoothie',                'Smoothie',    50.00, 6),
(8, 'Strawberry Smoothie',           'Smoothie',    50.00, 6),
(8, 'Mixed Berry Smoothie',          'Smoothie',    55.00, 6),
(8, 'Banana Peanut Butter Smoothie', 'Smoothie',    55.00, 6),
(8, 'Green Boost Smoothie',          'Smoothie',    55.00, 6),
(8, 'Tropical Fruit Smoothie',       'Smoothie',    60.00, 6),
(8, 'Peach Mango Smoothie',          'Smoothie',    55.00, 6),
-- Milkshakes
(8, 'Vanilla Milkshake',             'Milkshake',   50.00, 7),
(8, 'Chocolate Milkshake',           'Milkshake',   50.00, 7),
(8, 'Strawberry Milkshake',          'Milkshake',   55.00, 7),
(8, 'Oreo Milkshake',                'Milkshake',   65.00, 7),
(8, 'Lotus Milkshake',               'Milkshake',   65.00, 7),
(8, 'Nutella Milkshake',             'Milkshake',   65.00, 7),
(8, 'Bastachio Milkshake',           'Milkshake',   80.00, 7),
-- Cold Drinks
(8, 'Iced Tea (Lemon)',              'Cold Drinks', 25.00, 3),
(8, 'Iced Tea (Peach)',              'Cold Drinks', 25.00, 3),
(8, 'Mojito (Classic)',              'Cold Drinks', 35.00, 5),
(8, 'Mojito (Blue Berry)',           'Cold Drinks', 40.00, 5),
(8, 'Redbull Can',                   'Cold Drinks', 55.00, 1);
GO

-- ================================================================
-- VENDOR 9 - LATE NIGHT SNACKS (unchanged from v2)
-- ================================================================
INSERT INTO MenuItems (VendorID, ItemName, Category, Price, EstimatedPrepTime) VALUES
-- Waffles
(9, 'Waffle Nutella',                'Waffles',    40.00, 12),
(9, 'Waffle Lotus',                  'Waffles',    45.00, 12),
(9, 'Waffle Caramel',                'Waffles',    45.00, 12),
(9, 'Waffle Oreo',                   'Waffles',    55.00, 12),
(9, 'Waffle Bastachio',              'Waffles',    70.00, 12),
(9, 'Waffle Mixed Fruits',           'Waffles',    50.00, 12),
-- Crepes
(9, 'Crepe Nutella',                 'Crepes',     35.00,  8),
(9, 'Crepe Lotus',                   'Crepes',     40.00,  8),
(9, 'Crepe Caramel',                 'Crepes',     40.00,  8),
(9, 'Crepe Oreo',                    'Crepes',     45.00,  8),
(9, 'Crepe Bastachio',               'Crepes',     55.00,  8),
(9, 'Crepe Strawberry',              'Crepes',     40.00,  8),
(9, 'Crepe Banana Nutella',          'Crepes',     45.00,  8),
-- Donuts
(9, 'Classic Glazed Donut',          'Donuts',     20.00,  2),
(9, 'Chocolate Donut',               'Donuts',     25.00,  2),
(9, 'Lotus Donut',                   'Donuts',     30.00,  2),
(9, 'Nutella Filled Donut',          'Donuts',     30.00,  2),
(9, 'Sprinkle Donut',                'Donuts',     20.00,  2),
(9, 'Donut Box (6 pcs)',             'Donuts',    110.00,  3),
-- Cakes & Brownies
(9, 'Chocolate Brownie',             'Desserts',   30.00,  3),
(9, 'Nutella Brownie',               'Desserts',   35.00,  3),
(9, 'Molten Chocolate Cake',         'Desserts',   45.00,  8),
(9, 'Cheesecake Slice',              'Desserts',   40.00,  3),
(9, 'Red Velvet Slice',              'Desserts',   40.00,  3),
(9, 'Tiramisu Cup',                  'Desserts',   45.00,  3),
(9, 'Lotus Cheesecake Slice',        'Desserts',   50.00,  3),
-- Ice Cream
(9, 'Ice Cream Scoop (Vanilla)',     'Ice Cream',  20.00,  2),
(9, 'Ice Cream Scoop (Chocolate)',   'Ice Cream',  20.00,  2),
(9, 'Ice Cream Sandwich',            'Ice Cream',  35.00,  3),
(9, 'Sundae Cup (Caramel)',          'Ice Cream',  40.00,  3),
(9, 'Sundae Cup (Oreo)',             'Ice Cream',  40.00,  3),
-- Sweet Drinks
(9, 'Hot Chocolate',                 'Drinks',     35.00,  5),
(9, 'Nutella Hot Milk',              'Drinks',     40.00,  5),
(9, 'Cola Can',                      'Drinks',     20.00,  1),
(9, 'Water Bottle',                  'Drinks',      8.00,  1);
GO

-- ------------------------------------------------------------------
-- 5D. FOOD COURT TABLES (35 tables)
-- ------------------------------------------------------------------
INSERT INTO FoodCourtTables (TableNumber, AreaName, Capacity) VALUES
('QZ-01','Quiet Zone', 2),('QZ-02','Quiet Zone', 2),('QZ-03','Quiet Zone', 2),
('QZ-04','Quiet Zone', 2),('QZ-05','Quiet Zone', 2),
('SA-01','Study Area', 4),('SA-02','Study Area', 4),('SA-03','Study Area', 4),
('SA-04','Study Area', 4),('SA-05','Study Area', 4),
('MH-01','Main Hall',  4),('MH-02','Main Hall',  4),('MH-03','Main Hall',  6),
('MH-04','Main Hall',  6),('MH-05','Main Hall',  6),('MH-06','Main Hall',  4),
('MH-07','Main Hall',  4),('MH-08','Main Hall',  8),('MH-09','Main Hall',  8),
('MH-10','Main Hall',  8),
('OA-01','Outdoor Area',4),('OA-02','Outdoor Area',4),('OA-03','Outdoor Area',6),
('OA-04','Outdoor Area',8),('OA-05','Outdoor Area',8),
('GT-01','Group Tables',8), ('GT-02','Group Tables', 8),('GT-03','Group Tables',10),
('GT-04','Group Tables',10),('GT-05','Group Tables',12),
('CA-01','Coffee Area', 2),('CA-02','Coffee Area', 2),('CA-03','Coffee Area', 2),
('CA-04','Coffee Area', 4),('CA-05','Coffee Area', 4);
GO

-- =========================================================================
-- SECTION 6 - ORDER SIMULATION (150 orders)
-- =========================================================================
SET NOCOUNT ON;
GO

DECLARE @Counter    INT = 1;
DECLARE @TotalUsers INT = (SELECT COUNT(*) FROM Users);
DECLARE @UID   INT;
DECLARE @TID   INT;
DECLARE @MID1  INT;
DECLARE @MID2  INT;
DECLARE @VID   INT;
DECLARE @OTYPE   NVARCHAR(50);
DECLARE @PMETHOD NVARCHAR(50);
DECLARE @QSTATUS NVARCHAR(50);
DECLARE @GenOrderID INT;
DECLARE @RandQ  INT;
DECLARE @Bal    INT;

WHILE @Counter <= 150
BEGIN
    -- Pick a random user
    SET @UID = (ABS(CHECKSUM(NEWID())) % @TotalUsers) + 1;

    -- Pick OrderType (never NULL)
    SET @OTYPE = CHOOSE(
        (ABS(CHECKSUM(NEWID())) % 3) + 1,
        'Dine-in', 'Takeaway', 'Campus Delivery'
    );
    IF @OTYPE IS NULL OR @OTYPE = ''
        SET @OTYPE = 'Dine-in';

    -- Pick PaymentMethod (never NULL)
    SET @PMETHOD = CHOOSE(
        (ABS(CHECKSUM(NEWID())) % 4) + 1,
        'Cash', 'Student Card', 'Credit Card', 'Online Payment'
    );
    IF @PMETHOD IS NULL OR @PMETHOD = ''
        SET @PMETHOD = 'Cash';

    -- Pick a random vendor (1-9)
    SET @VID = (ABS(CHECKSUM(NEWID())) % 9) + 1;

    -- Pick two distinct menu items from that vendor
    SELECT TOP 1 @MID1 = MenuID
    FROM   MenuItems
    WHERE  VendorID = @VID AND IsAvailable = 1
    ORDER  BY NEWID();

    SELECT TOP 1 @MID2 = MenuID
    FROM   MenuItems
    WHERE  VendorID = @VID AND IsAvailable = 1 AND MenuID <> ISNULL(@MID1, 0)
    ORDER  BY NEWID();

    IF @MID2 IS NULL
        SET @MID2 = @MID1;

    IF @MID1 IS NULL
    BEGIN
        SET @Counter = @Counter + 1;
        CONTINUE;
    END

    -- Pick an available table for Dine-in
    SET @TID = NULL;
    IF @OTYPE = 'Dine-in'
    BEGIN
        SELECT TOP 1 @TID = TableID
        FROM   FoodCourtTables
        WHERE  Status = 'Available'
        ORDER  BY NEWID();
        IF @TID IS NULL
            SET @OTYPE = 'Takeaway';
    END

    -- Place the order
    BEGIN TRY
        EXEC sp_ProcessFoodCourtOrder
            @UserID    = @UID,
            @TableID   = @TID,
            @OrderType = @OTYPE,
            @MenuID1   = @MID1, @Qty1 = 1,
            @MenuID2   = @MID2, @Qty2 = 1,
            @NewOrderID = @GenOrderID OUTPUT;
    END TRY
    BEGIN CATCH
        SET @Counter = @Counter + 1;
        CONTINUE;
    END CATCH

    -- 90% paid, 10% cancelled
    IF (ABS(CHECKSUM(NEWID())) % 100) < 90
    BEGIN
        BEGIN TRY
            EXEC sp_CompletePayment
                @OrderID       = @GenOrderID,
                @PaymentMethod = @PMETHOD;
        END TRY
        BEGIN CATCH
        END CATCH

        -- Distribute queue statuses
        SET @RandQ = ABS(CHECKSUM(NEWID())) % 100;
        IF      @RandQ < 10  SET @QSTATUS = 'Waiting';
        ELSE IF @RandQ < 40  SET @QSTATUS = 'Preparing';
        ELSE IF @RandQ < 60  SET @QSTATUS = 'Ready';
        ELSE                 SET @QSTATUS = 'Completed';

        BEGIN TRY
            EXEC sp_UpdateQueueStatus
                @OrderID        = @GenOrderID,
                @NewQueueStatus = @QSTATUS;
        END TRY
        BEGIN CATCH
        END CATCH

        -- Redeem loyalty points (15% chance, min 10 pts)
        IF (ABS(CHECKSUM(NEWID())) % 100) < 15
        BEGIN
            SELECT @Bal = CurrentPointsBalance
            FROM   Users
            WHERE  UserID = @UID;

            IF ISNULL(@Bal, 0) >= 10
            BEGIN
                BEGIN TRY
                    EXEC sp_RedeemLoyaltyPoints
                        @UserID         = @UID,
                        @PointsToRedeem = 10,
                        @OrderID        = @GenOrderID;
                END TRY
                BEGIN CATCH
                END CATCH
            END
        END
    END
    ELSE
    BEGIN
        BEGIN TRY
            EXEC sp_CancelOrder @OrderID = @GenOrderID;
        END TRY
        BEGIN CATCH
        END CATCH
    END

    SET @Counter = @Counter + 1;
END
GO

SET NOCOUNT OFF;
GO

-- =========================================================================
-- SECTION 7 - ADVANCED ANALYTICAL QUERIES
-- =========================================================================

-- Q1: Most profitable vendor
SELECT
    fv.VendorName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.SubTotal)          AS TotalRevenue
FROM  FoodVendors  fv
JOIN  MenuItems    mi ON fv.VendorID = mi.VendorID
JOIN  OrderDetails od ON mi.MenuID   = od.MenuID
JOIN  Orders        o ON od.OrderID  = o.OrderID
WHERE o.OrderStatus IN ('Completed','Ready','Preparing')
GROUP BY fv.VendorName
ORDER BY TotalRevenue DESC;
GO

-- Q2: Overall order statistics
SELECT
    COUNT(OrderID)                                AS TotalSuccessfulOrders,
    CAST(AVG(TotalAmount) AS DECIMAL(10,2))       AS AverageOrderValue,
    CAST(SUM(TotalAmount) AS DECIMAL(10,2))       AS GrandTotalRevenue
FROM  Orders
WHERE OrderStatus IN ('Completed','Ready','Preparing');
GO

-- Q3: Top 5 busiest ordering hours
SELECT TOP 5
    DATEPART(HOUR, OrderDate) AS OrderingHour,
    COUNT(OrderID)            AS OrdersPlaced
FROM  Orders
GROUP BY DATEPART(HOUR, OrderDate)
ORDER BY OrdersPlaced DESC;
GO

-- Q4: Top 5 categories by items sold and revenue
SELECT TOP 5
    mi.Category,
    SUM(od.Quantity) AS ItemsSold,
    SUM(od.SubTotal) AS RevenueGenerated
FROM  MenuItems    mi
JOIN  OrderDetails od ON mi.MenuID  = od.MenuID
JOIN  Orders        o ON od.OrderID = o.OrderID
WHERE o.OrderStatus NOT IN ('Cancelled','Pending')
GROUP BY mi.Category
ORDER BY ItemsSold DESC;
GO

-- Q5: Most loyal customers (top 10 by points earned)
SELECT TOP 10
    FirstName + ' ' + LastName AS CustomerName,
    Role,
    TotalPointsEarned,
    PointsRedeemed,
    CurrentPointsBalance
FROM  Users
ORDER BY TotalPointsEarned DESC;
GO

-- Q6: Orders and revenue per role
SELECT
    u.Role,
    COUNT(o.OrderID)   AS TotalOrders,
    SUM(o.TotalAmount) AS TotalRevenue
FROM  Users  u
JOIN  Orders o ON u.UserID = o.UserID
WHERE o.OrderStatus <> 'Cancelled'
GROUP BY u.Role
ORDER BY TotalOrders DESC;
GO

-- Q7: Vendor performance ranking
SELECT
    RANK() OVER (ORDER BY SUM(od.SubTotal) DESC) AS VendorRank,
    fv.VendorName,
    COUNT(DISTINCT od.OrderID) AS TotalOrders,
    SUM(od.Quantity)           AS TotalItemsSold,
    SUM(od.SubTotal)           AS TotalRevenue
FROM  FoodVendors  fv
JOIN  MenuItems    mi ON fv.VendorID = mi.VendorID
JOIN  OrderDetails od ON mi.MenuID   = od.MenuID
JOIN  Orders        o ON od.OrderID  = o.OrderID
WHERE o.OrderStatus <> 'Cancelled'
GROUP BY fv.VendorName
ORDER BY VendorRank;
GO

-- Q8: Average and max estimated wait time per vendor
SELECT
    fv.VendorName,
    AVG(o.EstimatedWaitingTime) AS AvgEstWaitTime_Min,
    MAX(o.EstimatedWaitingTime) AS MaxWaitTime_Min
FROM  FoodVendors  fv
JOIN  MenuItems    mi ON fv.VendorID = mi.VendorID
JOIN  OrderDetails od ON mi.MenuID   = od.MenuID
JOIN  Orders        o ON od.OrderID  = o.OrderID
WHERE o.OrderStatus <> 'Cancelled'
GROUP BY fv.VendorName
ORDER BY AvgEstWaitTime_Min DESC;
GO

-- Q9: Cancelled order analysis
SELECT
    COUNT(OrderID)                                        AS TotalCancelledOrders,
    ISNULL(SUM(TotalAmount), 0)                           AS LostRevenue,
    CAST(COUNT(OrderID) * 100.0
         / NULLIF((SELECT COUNT(*) FROM Orders), 0)
         AS DECIMAL(5,2))                                 AS CancellationRatePct
FROM  Orders
WHERE OrderStatus = 'Cancelled';
GO

-- Q10: Most used payment method
SELECT
    PaymentMethod,
    COUNT(PaymentID)  AS TimesUsed,
    SUM(Amount)       AS TotalVolumeProcessed
FROM  Payments
WHERE PaymentStatus = 'Completed'
GROUP BY PaymentMethod
ORDER BY TimesUsed DESC;
GO

-- Q11: Daily revenue (top 10 days)
SELECT TOP 10
    CAST(PaymentDate AS DATE) AS SalesDate,
    COUNT(PaymentID)          AS TotalTransactions,
    SUM(Amount)               AS DailyRevenue
FROM  Payments
WHERE PaymentStatus = 'Completed'
GROUP BY CAST(PaymentDate AS DATE)
ORDER BY SalesDate DESC;
GO

-- Q12: Vendor avg price vs volume sold
SELECT
    fv.VendorName,
    CAST(AVG(mi.Price) AS DECIMAL(10,2)) AS AvgItemPrice,
    SUM(od.Quantity)                     AS VolumeSold,
    SUM(od.SubTotal)                     AS TotalRevenue
FROM  FoodVendors  fv
JOIN  MenuItems    mi ON fv.VendorID = mi.VendorID
JOIN  OrderDetails od ON mi.MenuID   = od.MenuID
JOIN  Orders        o ON od.OrderID  = o.OrderID
WHERE o.OrderStatus <> 'Cancelled'
GROUP BY fv.VendorName
ORDER BY VolumeSold DESC;
GO

-- Q13: Live queue dashboard
SELECT
    o.QueueNumber,
    u.FirstName + ' ' + u.LastName AS CustomerName,
    fv.VendorName,
    o.OrderType,
    o.QueueStatus,
    o.EstimatedWaitingTime         AS EstWait_Min,
    o.TotalAmount
FROM  Orders       o
JOIN  Users        u  ON o.UserID  = u.UserID
JOIN  OrderDetails od ON o.OrderID = od.OrderID
JOIN  MenuItems    mi ON od.MenuID = mi.MenuID
JOIN  FoodVendors  fv ON mi.VendorID = fv.VendorID
WHERE o.QueueStatus IN ('Waiting','Preparing','Ready')
GROUP BY o.QueueNumber, u.FirstName, u.LastName, fv.VendorName,
         o.OrderType, o.QueueStatus, o.EstimatedWaitingTime, o.TotalAmount
ORDER BY o.QueueCreatedTime;
GO

-- Q14: Top 10 most ordered items
SELECT TOP 10
    mi.ItemName,
    fv.VendorName,
    SUM(od.Quantity) AS TotalQtySold,
    SUM(od.SubTotal) AS TotalRevenue
FROM  OrderDetails od
JOIN  MenuItems    mi ON od.MenuID   = mi.MenuID
JOIN  FoodVendors  fv ON mi.VendorID = fv.VendorID
JOIN  Orders        o ON od.OrderID  = o.OrderID
WHERE o.OrderStatus <> 'Cancelled'
GROUP BY mi.ItemName, fv.VendorName
ORDER BY TotalQtySold DESC;
GO

-- Q15: Table utilization summary
SELECT
    fct.AreaName,
    fct.TableNumber,
    fct.Capacity,
    fct.Status,
    COUNT(o.OrderID) AS TotalOrdersServed
FROM  FoodCourtTables fct
LEFT  JOIN Orders     o ON fct.TableID = o.TableID
                        AND o.OrderStatus <> 'Cancelled'
GROUP BY fct.AreaName, fct.TableNumber, fct.Capacity, fct.Status
ORDER BY fct.AreaName, TotalOrdersServed DESC;
GO