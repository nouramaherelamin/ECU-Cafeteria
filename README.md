# 🍽️ ECU Cafeteria — Dalla3 Kershak

### University Food Court Management & Ordering System

> Dalla3 Kershak is a university-focused food court management and ordering project developed for the Egyptian Chinese University (ECU).

🌐 **Live Website:** [ecucafeteria.com](https://ecucafeteria.com/)

---

## 📌 About the Project

**Dalla3 Kershak (دلع كرشك)** is a university food court project designed to improve the food ordering and restaurant management experience inside the university.

The project addresses common cafeteria problems such as:

- Long queues
- Order confusion
- Limited break time between lectures
- Manual order management
- Difficult payment tracking
- Inefficient table management
- Lack of structured restaurant analytics

The system combines a **relational database** with business and entrepreneurship analysis to model the complete food court operation.

> **My contribution to this project was focused on Entrepreneurship and Database Systems. I did not work on the Web part of the project.**

---

## 🎯 Project Objectives

The main objectives of the project are:

- Automate order processing
- Manage university food vendors
- Manage menus and menu items
- Track customer orders
- Manage food court tables
- Handle payments
- Generate queue numbers
- Estimate waiting times
- Manage loyalty points
- Maintain data integrity
- Analyze revenue and vendor performance

The database documentation describes the system as a centralized platform for vendors, menus, tables, queues, payments, loyalty programs, and analytics.

---

## 🗄️ Database System

The database is designed as a normalized relational database for managing the university food court.

### Core Tables

| Table | Description |
|---|---|
| `Users` | Students, professors, and staff |
| `FoodVendors` | Food vendors and restaurants |
| `MenuItems` | Food and drink items |
| `FoodCourtTables` | Food court tables |
| `Orders` | Customer orders |
| `OrderDetails` | Items included in each order |
| `Payments` | Payment records |

### Relationships

```text
Users
  │
  └──< Orders
          │
          ├──< OrderDetails >── MenuItems >── FoodVendors
          │
          ├── Payments
          │
          └── FoodCourtTables
```

The main relationships include:

- One User → Many Orders
- One Food Vendor → Many Menu Items
- One Menu Item → Many Order Details
- One Order → Many Order Details
- One Food Court Table → Many Orders over time
- One Order → One Payment

---

## 🔑 Database Design

The database uses:

- Primary Keys
- Foreign Keys
- Unique Constraints
- Check Constraints
- Referential Integrity
- Cascading Relationships
- Normalized relational design

Examples of validation rules include:

- Positive item prices
- Positive quantities
- Non-negative payment amounts
- Valid user roles
- Valid order statuses
- Unique user emails
- Unique table numbers
- Unique payment per order

---

## ⚙️ Stored Procedures & Triggers

The project applies database automation through **Stored Procedures and Triggers**.

### Main Automated Operations

- Order processing
- Order cancellation
- Payment processing
- Queue management
- Table status updates
- Loyalty point handling
- Transaction management

These mechanisms help keep business rules inside the database and maintain data consistency.

---

## 📊 SQL Queries & Analytics

The database includes advanced SQL queries for business intelligence and operational analysis.

### Main Analysis Areas

1. Revenue calculation
2. Overall order statistics
3. Peak ordering hours
4. Top food categories
5. Most loyal customers
6. Orders by user role
7. Vendor performance
8. Wait-time analysis
9. Cancellation analysis
10. Payment methods
11. Daily revenue
12. Vendor pricing vs. sales volume
13. Live queue information
14. Best-selling menu items
15. Table utilization

These queries use SQL concepts such as:

- `JOIN`
- `GROUP BY`
- Aggregation
- Subqueries
- Window Functions
- `RANK()`
- `DATEPART`

---

## 🧪 Testing & Validation

The database project includes simulated data used to test different operational scenarios.

Testing covers:

- Multi-item orders
- Payment processing
- Order cancellation
- Queue updates
- Table availability
- Loyalty point calculation
- Data integrity
- Transaction consistency

The documented database contains sample data including:

- 70 users
- 9 food vendors
- Hundreds of menu items
- 150 simulated orders

---

# 💼 Entrepreneurship

The project was also developed from an entrepreneurship perspective.

## 💡 Problem

University students often have limited time between lectures and may spend a significant portion of their break waiting in cafeteria queues.

The project identifies problems including:

- Long queues
- Wasted time
- Order mistakes
- Staff pressure
- Lack of organized digital ordering

---

## 🎯 Target Customers

### Primary Customers

**University Students**

Students are the main target users because they frequently need quick food ordering during short breaks.

### Secondary Customers

- Professors
- Teaching Assistants
- University Staff

### Partners

- University cafeterias
- Restaurants
- Food vendors

---

## 💎 Value Proposition

> **Order your food with no queues and pick it up exactly on time.**

The proposed solution provides:

- Online ordering
- Scheduled pickup
- Estimated preparation time
- Ready notifications
- Digital wallet
- Loyalty system
- Restaurant analytics

---

## 🧩 Business Model Canvas

The entrepreneurship work covers:

- Customer Segments
- Value Propositions
- Channels
- Customer Relationships
- Revenue Streams
- Key Resources
- Key Activities
- Key Partnerships
- Cost Structure

---

## 🧠 Customer & Market Analysis

The project also includes:

- Empathy Map
- Customer Personas
- Customer Pain Points
- Customer Gains
- Risky Assumptions
- MVP Validation
- SWOT Analysis
- PESTLE Analysis
- Market Analysis
- Go-To-Market Strategy

---

## 🧪 MVP & Hypothesis Testing

The project identified key assumptions that needed validation, including:

### 1. Vendor Adoption

Whether campus food vendors would consistently use a digital ordering system.

### 2. Student Pre-Ordering

Whether students would place their orders before reaching the cafeteria.

### 3. Digital Wallet

Whether students would preload money into a closed-loop wallet.

The MVP approach was designed to test these assumptions before larger-scale implementation.

---

## 💰 Business Model

Potential revenue streams include:

- Commission per successful order
- Featured vendor listings
- Sponsored placements
- In-platform advertising

---

## 🏗️ Project Scope

My work in this project focused on:

```text
ENTREPRENEURSHIP
       │
       ├── Problem Analysis
       ├── Customer Segmentation
       ├── Value Proposition
       ├── Business Model Canvas
       ├── Empathy Map
       ├── MVP
       ├── Risky Assumptions
       ├── Market Analysis
       ├── SWOT
       └── PESTLE

DATABASE SYSTEMS
       │
       ├── Database Design
       ├── Normalization
       ├── ERD
       ├── Tables
       ├── Relationships
       ├── Constraints
       ├── SQL Queries
       ├── Stored Procedures
       ├── Triggers
       └── Data Analysis
```

### ❗ Contribution Note

**I worked on the Entrepreneurship and Database Systems parts of the project. I was not responsible for the Web Application development.**

---

## 🛠️ Technologies & Concepts Used

### Database

- Microsoft SQL Server
- T-SQL
- Relational Database Design
- Database Normalization
- ERD
- SQL Queries
- Stored Procedures
- Triggers
- Constraints
- Transactions
- Data Analysis

### Entrepreneurship

- Business Model Canvas
- Empathy Mapping
- Customer Segmentation
- MVP
- Hypothesis Testing
- SWOT Analysis
- PESTLE Analysis
- Market Analysis
- Business Model Development

---

## 📁 Project Components

```text
ECU Cafeteria
│
├── 🌐 Web Application
│
├── 🗄️ Database System
│   ├── Database Design
│   ├── Tables
│   ├── Relationships
│   ├── SQL Queries
│   ├── Stored Procedures
│   └── Triggers
│
├── 💼 Entrepreneurship
│   ├── Business Model Canvas
│   ├── Empathy Map
│   ├── MVP
│   ├── Market Analysis
│   ├── SWOT
│   └── PESTLE
│
└── 📚 Documentation
```

---

## 🌐 Live Website

The complete project includes a web application:

👉 **[ECU Cafeteria](https://ecucafeteria.com/)**

**Note:** The website was developed as another part of the overall team project and was **not part of my personal contribution**.

---

## 👥 Team

### Team Masterpiece

The project was developed by **Team Masterpiece** at the Egyptian Chinese University.

---

## 👩‍💻 My Contribution

### Noura Maher

**Areas of Contribution:**

- 💼 Entrepreneurship
- 🗄️ Database Systems
- 🧩 Database Design
- 📊 SQL Queries & Analytics
- ⚙️ Stored Procedures
- 🔄 Triggers
- 📚 Project Documentation
- 📈 Business Analysis
---

## 🎓 Academic Project

**University:** Egyptian Chinese University (ECU)

**Project:** Dalla3 Kershak — ECU Cafeteria

**Team:** Masterpiece

**Areas:** Entrepreneurship & Database Systems

---

## 📜 License

This project was developed as an academic project for the Egyptian Chinese University.
