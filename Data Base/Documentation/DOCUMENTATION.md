# University Restaurant Ordering System
## Complete Database Project Documentation

---

## 1. Project Explanation

This project designs and implements a **University Restaurant Ordering System** using Microsoft SQL Server. The system manages food ordering across multiple campus cafeterias and restaurants, allowing students and staff to place orders, track their status, and make payments. It supports both **dine-in** and **takeaway** orders and provides management views for revenue reporting and popular dish analysis.

---

## 2. Problem Statement

University cafeterias face challenges managing high volumes of student orders, tracking table availability, monitoring popular items, and generating daily revenue reports — all manually or with disconnected systems. This leads to:
- Long wait times and order confusion
- No visibility into popular or unpopular menu items
- Manual, error-prone payment tracking
- No real-time table availability updates

---

## 3. Solution

A relational database system with **7 normalized tables**, automated business logic via stored procedures and triggers, and dashboard views that provide:
- Centralized ordering across 4 campus restaurants
- Automatic table status updates when orders are placed or completed
- Popular dish rankings to guide menu planning
- Daily revenue reports broken down by restaurant, order type, and payment method
- Full order history per customer

---

## 4. Database Tables

| # | Table Name | Purpose |
|---|---|---|
| 1 | Restaurants | Campus cafeterias/food outlets |
| 2 | Customers | Students and staff who place orders |
| 3 | DiningTables | Physical seating tables in each restaurant |
| 4 | Menu | Food and drink items offered per restaurant |
| 5 | Orders | Order header: who ordered, where, when |
| 6 | OrderItems | Line items inside each order (Menu to Orders) |
| 7 | Payments | Payment linked to each completed order |

---

## 5. ERD Explanation

The Entity-Relationship Diagram contains:

- **Restaurants** is the parent of DiningTables and Menu (one restaurant has many tables and many menu items)
- **Customers** place **Orders** (one customer, many orders)
- **Orders** are placed at a **DiningTable** (optional — NULL for takeaway)
- **Orders** belong to one **Restaurant**
- **OrderItems** is the bridge table between Orders and Menu (many-to-many resolved)
- Each **Order** has one **Payment**

Relationships:
- Restaurants --< DiningTables (1 to many)
- Restaurants --< Menu (1 to many)
- Restaurants --< Orders (1 to many)
- Customers --< Orders (1 to many)
- Orders --< OrderItems >-- Menu (many to many resolved)
- Orders -- Payments (1 to 1)

---

## 6. Relationships Between Tables

| Relationship | Type | Description |
|---|---|---|
| Restaurants to DiningTables | One-to-Many | A restaurant has multiple tables |
| Restaurants to Menu | One-to-Many | A restaurant offers multiple menu items |
| Restaurants to Orders | One-to-Many | A restaurant receives many orders |
| Customers to Orders | One-to-Many | A customer can place many orders |
| Orders to OrderItems | One-to-Many | An order has multiple line items |
| Menu to OrderItems | One-to-Many | A menu item appears in many orders |
| Orders to Payments | One-to-One | Each order has exactly one payment |
| DiningTables to Orders | One-to-Many | A table can host multiple orders over time |

---

## 7. Normalization Up to 3NF

### First Normal Form (1NF)
- All tables have a single-valued primary key
- Every column holds atomic (indivisible) values
- No repeating groups — order items are in a separate OrderItems table

### Second Normal Form (2NF)
- All non-key attributes fully depend on the entire primary key
- OrderItems uses a surrogate OrderItemID as PK
- Menu.Price depends only on MenuItemID, not on which order it appears in

### Third Normal Form (3NF)
- No transitive dependencies
- Restaurant.Location depends on RestaurantID directly
- Customer.CustomerType is stored directly, not derived from StudentID
- LineTotal is a computed column (Quantity x UnitPrice) — avoids redundancy
- Payment details are in a separate Payments table, not embedded in Orders

---

## 8. SQL Objects Summary

### Tables (7)
Restaurants, Customers, DiningTables, Menu, Orders, OrderItems, Payments

### Queries (10)
1. Projection: all available menu items
2. Popular dishes ranked by quantity ordered
3. Daily revenue report per restaurant per day
4. Full order details with multiple JOINs
5. Revenue and orders per restaurant (aggregation)
6. Customers who spent more than average (subquery)
7. Menu items never ordered (subquery with NOT IN)
8. Payment method breakdown with percentages
9. Category popularity analysis
10. Student vs Staff spending comparison

### Stored Procedure (1)
PlaceOrder: validates inputs, creates order header, parses item list, inserts OrderItems, calculates TotalAmount — all in a single transaction with error handling and rollback.

### Trigger (1)
trg_UpdateTableStatus: fires AFTER INSERT/UPDATE on Orders. Sets table to Occupied when an active dine-in order exists; resets to Available when order is Delivered or Cancelled.

### Views (4)
| View | Purpose |
|---|---|
| vw_PopularDishes | Top menu items by quantity ordered |
| vw_DailyRevenue | Daily revenue per restaurant |
| vw_TableOccupancy | Real-time table status with current order info |
| vw_CustomerOrderHistory | Full order history per customer |

---

## 9. Testing Results

| Test | Input | Expected Result | Pass |
|---|---|---|---|
| PlaceOrder valid | CustomerID=1, Restaurant=1, Items=1:1 pipe 6:2 | New OrderID returned, table Occupied | Yes |
| Trigger on INSERT | New order on TableID=1 | DiningTables.TableStatus = Occupied | Yes |
| Trigger on UPDATE Delivered | OrderStatus to Delivered | TableStatus = Available | Yes |
| PlaceOrder invalid customer | CustomerID=999 | Error: Invalid CustomerID: 999 | Yes |
| Popular dishes view | SELECT TOP 5 FROM vw_PopularDishes | Returns Chicken Machboos at top | Yes |
| Daily revenue view | SELECT from vw_DailyRevenue | Revenue grouped by date and restaurant | Yes |
| Subquery above average | Customers with more than average spending | Returns Noura, Mariam, Omar | Yes |
| Items never ordered | NOT IN subquery | Returns items with zero orders | Yes |

---

## 10. Bonus Idea: Online Food Ordering System

### Concept: UniEats — Campus Mobile Ordering App

**Problem Solved:** Students waste time waiting in cafeteria queues between classes.

**Solution:** A mobile/web app where students:
1. Browse menus from all campus restaurants in one place
2. Pre-order food and schedule a pickup time
3. Pay via university Meal Plan card, mobile wallet, or card
4. Track order status in real-time
5. Receive a push notification when food is ready

**Additional Database Tables Needed:**
- OnlineOrders: links to Orders with OrderChannel = Online
- PickupSlots: available time windows at each restaurant
- PushNotifications: log of notifications per order
- Ratings: student star ratings per menu item

**Technology Stack:**
- Backend: REST API (Node.js or Python Django)
- Database: Microsoft SQL Server (same schema, extended)
- Frontend: React Native (iOS and Android)
- Auth: University SSO (Single Sign-On)
- Payments: Stripe plus Meal Plan integration

**Benefits for University:**
- Reduces queue times by 60-70%
- Provides analytics for cafeteria management
- Reduces food waste through demand forecasting
- Increases student satisfaction scores

---

# PPT SLIDE CONTENT (Ready to Copy into PowerPoint)

---

## SLIDE 1 - Title Slide
Title: University Restaurant Ordering System
Subtitle: A Microsoft SQL Server Database Project
Course: Database Systems
Team Members: [Your Names]
Date: April 2026

---

## SLIDE 2 - Problem Statement
Title: The Problem

- University cafeterias handle hundreds of orders daily with no digital system
- Students waste time in long queues between classes
- No way to track which food items are popular
- Manual revenue tracking leads to errors
- Table availability is managed manually, not by data

---

## SLIDE 3 - Our Solution
Title: Our Solution

- A fully relational SQL Server database for campus food ordering
- Manages 4 campus restaurants with tables, menus, and orders
- Tracks every order from placement to payment
- Automated table status using triggers
- Revenue and popularity reports via SQL views

---

## SLIDE 4 - System Overview
Title: System Architecture

Components:
- 4 Campus Restaurants (entities in database)
- 10 Students and Staff (customers)
- Orders: Dine-In and Takeaway supported
- Payments: Cash, Card, Meal Plan, Online

---

## SLIDE 5 - Database Tables
Title: 7 Normalized Tables

Restaurants: Campus cafeterias
Customers: Students and staff
DiningTables: Seating tables
Menu: Food and drink items
Orders: Order header
OrderItems: Items in each order
Payments: Payment records

---

## SLIDE 6 - ERD Diagram
Title: Entity-Relationship Diagram

Key Relationships:
- Customers place Orders (1 to Many)
- Orders contain OrderItems (1 to Many)
- Menu items appear in OrderItems (1 to Many)
- Orders tied to DiningTables (Many to 1)
- Each Order has one Payment (1 to 1)

---

## SLIDE 7 - Normalization
Title: Normalization to 3NF

1NF: Atomic values, unique PKs, no repeating groups
2NF: All non-key attributes depend on full PK
3NF: No transitive dependencies, Price stays in Menu table
LineTotal is a computed column — no data duplication

---

## SLIDE 8 - Popular Dishes Query
Title: Query: Most Popular Dishes

SELECT TOP 10 M.ItemName, SUM(OI.Quantity) AS TotalOrdered
FROM OrderItems OI
INNER JOIN Menu M ON OI.MenuItemID = M.MenuItemID
GROUP BY M.ItemName
ORDER BY TotalOrdered DESC;

Result: Chicken Machboos is number 1 with 5 orders!

---

## SLIDE 9 - Daily Revenue Report
Title: Query: Daily Revenue Report

SELECT CAST(O.OrderDate AS DATE) AS OrderDay,
R.RestaurantName, SUM(P.AmountPaid) AS TotalRevenue
FROM Orders O
JOIN Payments P ON O.OrderID = P.OrderID
JOIN Restaurants R ON O.RestaurantID = R.RestaurantID
GROUP BY CAST(O.OrderDate AS DATE), R.RestaurantName;

---

## SLIDE 10 - Stored Procedure
Title: Stored Procedure: PlaceOrder

- Validates customer and restaurant exist
- Checks table belongs to correct restaurant
- Parses item list and verifies menu availability
- Inserts Order and OrderItems in one transaction
- Calculates TotalAmount automatically
- Rolls back everything if any step fails

---

## SLIDE 11 - Trigger Demo
Title: Trigger: Auto-Update Table Status

Trigger fires AFTER INSERT or UPDATE on Orders table:
- When order status is Pending/Preparing/Ready: table becomes Occupied
- When order status is Delivered or Cancelled: table becomes Available
- Smart check: table only frees up if no other active order exists

Before order: Status = Available
After order placed: Status = Occupied
After delivery: Status = Available

---

## SLIDE 12 - Dashboard Views
Title: 4 SQL Views for Dashboard

vw_PopularDishes: Top items by quantity ordered
vw_DailyRevenue: Revenue per day per restaurant
vw_TableOccupancy: Live table status with customer info
vw_CustomerOrderHistory: Full customer order history

---

## SLIDE 13 - Bonus: Online Ordering
Title: Bonus Idea: UniEats Mobile App

Students pre-order food from their phones
Pick up at scheduled time with no queue
Pay via Meal Plan, card, or mobile wallet
Real-time status updates: Pending to Preparing to Ready
Push notification when food is ready for pickup
Star ratings for menu items after each visit

---

## SLIDE 14 - Conclusion
Title: Conclusion and Summary

7 normalized tables up to 3NF
10 SQL queries using JOINs, aggregation, and subqueries
1 Stored procedure with full transaction and error handling
1 Trigger for automatic table status management
4 Dashboard views for reports and analytics
Realistic sample data: 4 restaurants, 10 customers, 17 orders
Bonus: UniEats online ordering concept presented

Thank You!
