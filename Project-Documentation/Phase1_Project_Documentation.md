# Phase 1 — Project Documentation

## Dalla3 Kershak: University Food Ordering Platform

---

| **Document Property** | **Detail** |
|---|---|
| **Project Title** | Dalla3 Kershak — University Campus Food Ordering Platform |
| **Institution** | Egyptian Chinese University (ECU) — Faculty of Computer Science & Information Systems |
| **Course Code** | AHU20XX |
| **Supervisor** | Dr. Ahmed Mahran |
| **Team Name** | Masterpiece |
| **Document Phase** | Phase 1 — Planning, Requirements, Design & Development |
| **Document Version** | 2.0 |
| **Last Updated** | April 16, 2026 |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Planning and Requirements](#2-planning-and-requirements)
   - 2.1 Project Objectives
   - 2.2 Target Audience & Stakeholder Analysis
   - 2.3 Problem Statement & Core Needs
   - 2.4 Strategic Motivation
   - 2.5 Scope Definition
3. [Design and Development](#3-design-and-development)
   - 3.1 Software Vision
   - 3.2 Key Features
   - 3.3 System Architecture
   - 3.4 Database Design Strategy
   - 3.5 API Architecture
   - 3.6 Security & Authentication Model
4. [User Interface](#4-user-interface)
   - 4.1 Design Philosophy & Principles
   - 4.2 Responsive Implementation
   - 4.3 Interface Modules Description
   - 4.4 Navigation & Information Architecture
5. [System Concept](#5-system-concept)
   - 5.1 Operational Workflow
   - 5.2 Technical Data Flow
   - 5.3 Economic & Revenue Model
   - 5.4 Key Performance Indicators (KPIs)
6. [Implementation & Market Strategy](#6-implementation--market-strategy)
   - 6.1 Strategic Alignment & Market Positioning
   - 6.2 Go-To-Market Plan
   - 6.3 Risk Assessment & Mitigation
7. [Phase 1 Development Timeline](#7-phase-1-development-timeline)
8. [Conclusion](#8-conclusion)
9. [Appendices](#9-appendices)

---

## 1. Introduction

The rapid digitization of consumer services has fundamentally reshaped expectations across every demographic — yet university campuses, particularly in the MENA region, remain conspicuously underserved in the food-technology vertical. The **Dalla3 Kershak** project ("Your Order Now" — دلع كرشك) addresses this gap by delivering a purpose-built digital food ordering ecosystem tailored to the specific constraints, rhythms, and demands of university life.

This document constitutes the **Phase 1 deliverable** for the project, encompassing a complete and structured treatment of the planning rationale, technical design decisions, description of the finalized user interface, the full system concept, and a pragmatic, timeline-driven implementation plan. The document is intended to serve as the authoritative reference for all stakeholders — academic supervisors, development team members, and prospective commercial partners — throughout the project lifecycle.

> **Note:** The frontend user interface has been fully designed and implemented as a responsive React application. This document describes the existing UI; no new prototypes or design mockups are introduced.

---

## 2. Planning and Requirements

### 2.1 Project Objectives

The **Dalla3 Kershak** platform pursues the following formally defined objectives:

| **ID** | **Objective** | **Category** |
|---|---|---|
| OBJ-01 | Eliminate physical queuing at campus food outlets by enabling digital pre-ordering with scheduled pickup times. | Operational |
| OBJ-02 | Reduce average student food procurement time from ~25 minutes to under 5 minutes. | Performance |
| OBJ-03 | Provide campus food vendors with a real-time digital order management dashboard to improve throughput and reduce errors. | Vendor Enablement |
| OBJ-04 | Establish a closed-loop digital wallet system for frictionless on-campus transactions. | Financial |
| OBJ-05 | Aggregate all campus food providers into a single, searchable digital marketplace. | Aggregation |
| OBJ-06 | Build a loyalty and engagement system that drives sustained user retention. | Growth |
| OBJ-07 | Create a scalable, revenue-generating platform via micro-commissions and promoted listings. | Commercial |

### 2.2 Target Audience & Stakeholder Analysis

The platform serves a **three-tier user ecosystem** operating within the bounded environment of a university campus:

#### 2.2.1 Primary Users — Students (Consumers)

University students represent the dominant user segment. These users are characterized by:

- **Time-constrained schedules** with narrow 10–15 minute intervals between lectures.
- **High smartphone penetration** and native comfort with digital ordering paradigms.
- **Price sensitivity** — value-oriented purchasing behavior with strong responsiveness to loyalty incentives.
- **Expected daily interaction frequency:** 1–3 sessions during standard academic days.

#### 2.2.2 Secondary Users — University Staff (Consumers)

Academic and administrative personnel, including professors (Doctors), Teaching Assistants (TAs), and university employees. This segment:

- Values convenience and reliability over price sensitivity.
- Expects professional-grade service quality and accurate order fulfillment.
- Represents a lower-volume but higher average-order-value cohort.

#### 2.2.3 Service Providers — Campus Food Vendors

Cafeterias, kiosks, and restaurant operators on campus. These stakeholders:

- Currently lack structured digital infrastructure for order management.
- Experience extreme operational load during peak hours (lecture breaks).
- Require real-time dashboards with analytics to manage throughput and track performance.
- Will interact with the platform through a dedicated **Vendor Command Center** interface.

#### 2.2.4 Stakeholder Matrix

| **Stakeholder** | **Interest** | **Influence** | **Engagement Strategy** |
|---|---|---|---|
| Students | High — Direct daily users | High — Adoption drives viability | Loyalty rewards, social marketing |
| University Staff | Medium — Convenience-driven | Low — Secondary segment | Feature parity, professional UX |
| Campus Vendors | High — Revenue impact | High — Supply-side dependency | Commission model, analytics dashboards |
| University Administration | Medium — Campus improvement | Medium — Governance oversight | Compliance, partnership alignment |

### 2.3 Problem Statement & Core Needs

#### 2.3.1 Problem Statement

> *University students and staff currently face significant daily inefficiencies when procuring food on campus — characterized by long physical queues, order errors due to high-pressure environments, and wasted time between lectures. Simultaneously, campus food vendors lack digital tools to manage order volume, leading to operational bottlenecks and lost revenue. No existing solution addresses this localized, high-frequency problem within the Egyptian university ecosystem.*

#### 2.3.2 Core Needs Analysis

| **Need ID** | **Description** | **Affected Stakeholder** | **Severity** |
|---|---|---|---|
| N-01 | Eliminate or drastically reduce physical wait time for food orders. | Students, Staff | Critical |
| N-02 | Provide accurate, scheduled pickup times to synchronize with academic schedules. | Students | Critical |
| N-03 | Reduce order errors caused by verbal communication under pressure. | Vendors, Students | High |
| N-04 | Offer vendors a digital system to manage, batch, and analyze incoming orders. | Vendors | High |
| N-05 | Enable cashless, frictionless payment within the campus ecosystem. | Students, Vendors | Medium |
| N-06 | Provide a centralized directory of all campus food options. | Students, Staff | Medium |
| N-07 | Deliver engagement mechanics (loyalty, rewards) to drive platform stickiness. | Students | Medium |

#### 2.3.3 Root Cause Analysis

The underlying causes of the identified problems are:

1. **Absence of Digital Infrastructure:** No platform currently digitalizes the food ordering workflow on campus — all transactions are manual, verbal, and queue-based.
2. **Temporal Compression:** University schedules create severe, predictable demand spikes during 10–15 minute recess windows, overwhelming manual systems.
3. **Information Asymmetry:** Students have no visibility into real-time menu availability, expected wait times, or vendor capacity before physically committing to a queue.
4. **Fragmented Vendor Landscape:** Multiple independent food operators, each with their own ad-hoc processes, prevent any unified operational efficiency.

### 2.4 Strategic Motivation

The strategic rationale for Dalla3 Kershak is grounded in three intersecting factors:

1. **Validated Pain Point:** The problem of wasted time and overcrowded queues is universally experienced, daily, by every student — representing a high-frequency, high-frustration use case with strong organic demand.

2. **First-Mover Advantage:** No direct competitor currently offers a campus-specific food ordering platform within the Egyptian university ecosystem. Early market entry establishes **localized monopoly dynamics** that create significant switching costs for both users and vendors once adoption reaches critical mass.

3. **Scalable Architecture:** The technology stack (React + Node.js) and business model (micro-commissions + promoted listings) are inherently scalable. A successful deployment at one campus can be replicated across the broader ECU system and extended to other Egyptian universities with minimal architectural modification.

This strategic foundation aligns with the **Hedgehog Concept** (Collins, 2001): the intersection of what the team is deeply passionate about (solving a real student problem), what it can be the best at (university-specific food tech), and what drives the economic engine (per-order commission revenue).

### 2.5 Scope Definition

#### 2.5.1 In-Scope (Phase 1)

- Student and staff user registration and authentication.
- Aggregated vendor/restaurant directory with menu browsing.
- Digital order placement with scheduled pickup times.
- In-app digital wallet with balance management.
- Real-time order status notifications.
- Vendor dashboard for order management.
- Loyalty points system (basic implementation).
- Responsive web application (desktop and mobile).

#### 2.5.2 Out-of-Scope (Deferred to Phase 2+)

- Native mobile applications (iOS/Android).
- Integration with external payment gateways (e.g., Fawry, Vodafone Cash).
- Advanced analytics and business intelligence dashboards.
- Multi-campus deployment.
- AI-powered menu recommendations.
- Delivery infrastructure (Phase 1 is pickup-only).

---

## 3. Design and Development

### 3.1 Software Vision

Dalla3 Kershak envisions becoming the **definitive digital food court** for university campuses — a centralized platform that unifies all campus food providers under a single, intelligent digital canopy. The platform operates as the exclusive digital intermediary between consumers and vendors, transforming the fragmented, manual food procurement process into a streamlined, data-driven digital experience.

The long-term vision extends beyond a simple ordering tool: Dalla3 Kershak aims to become an **indispensable campus utility** — as essential to the daily university experience as the learning management system itself.

### 3.2 Key Features

The platform's feature set is organized into three functional domains:

#### 3.2.1 Consumer-Facing Features

| **Feature** | **Description** |
|---|---|
| **Aggregated Vendor Directory** | A consolidated, searchable catalog of all campus food outlets with rich menu displays, pricing, and availability indicators. |
| **Smart Order Scheduling** | Time-based order staging allowing users to specify a pickup window synchronized with their academic schedule. |
| **Predictive Preparation Estimation** | Algorithmic estimation of food preparation time to optimize the alignment between order placement and pickup readiness. |
| **Real-Time Order Tracking** | Live status notifications (Received → Preparing → Ready) pushed to the consumer's interface at each state transition. |
| **Digital Wallet** | A closed-loop, proprietary financial system enabling instant cashless transactions with top-up functionality. |
| **Loyalty & Rewards Engine** | Points-based engagement system rewarding repeat orders with credits, discounts, or promotional benefits. |
| **Rating & Review System** | User-generated feedback mechanism (similar to Amazon-style ratings) enabling quality transparency across vendors. |

#### 3.2.2 Vendor-Facing Features

| **Feature** | **Description** |
|---|---|
| **Vendor Command Center** | A dedicated real-time dashboard for restaurant staff to receive, accept, batch, and fulfill incoming orders. |
| **Order Analytics** | Data visualization tools providing insights into order volume, peak demand periods, popular items, and revenue tracking. |
| **Menu Management** | Self-service interface for vendors to update menus, pricing, availability, and item descriptions. |
| **Promoted Listings** | Paid promotional slots enabling vendors to boost visibility in the consumer discovery feed. |

#### 3.2.3 Platform Features

| **Feature** | **Description** |
|---|---|
| **User Authentication** | Secure registration and login system with role-based access (Student, Staff, Vendor, Admin). |
| **Notification Service** | Multi-channel notification delivery (in-app, browser push) for order lifecycle events. |
| **Admin Panel** | System-level management for user oversight, vendor onboarding, content moderation, and platform configuration. |

### 3.3 System Architecture

The application is built upon a modern, decoupled **client-server architecture** designed to sustain the high-concurrency demands of a university campus during peak ordering periods.

#### 3.3.1 Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                                  │
│    ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │
│    │  Student UI   │  │   Staff UI   │  │  Vendor Dashboard    │     │
│    │   (React)     │  │   (React)    │  │     (React)          │     │
│    └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘     │
│           │                 │                      │                  │
└───────────┼─────────────────┼──────────────────────┼─────────────────┘
            │                 │                      │
            ▼                 ▼                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     API GATEWAY / REST LAYER                         │
│                        (Node.js + Express)                           │
│   ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ ┌────────────┐  │
│   │  Auth   │ │  Orders  │ │  Menus   │ │ Wallet │ │ Notifications│ │
│   │ Module  │ │  Module  │ │  Module  │ │ Module │ │   Module    │  │
│   └─────────┘ └──────────┘ └──────────┘ └────────┘ └────────────┘  │
└──────────────────────────┬───────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                     │
│    ┌──────────────────┐           ┌──────────────────────┐          │
│    │   PostgreSQL     │           │     MongoDB           │          │
│    │  (Relational)    │           │   (Document Store)    │          │
│    │                  │           │                       │          │
│    │ • Users          │           │ • Menu Catalogs       │          │
│    │ • Orders         │           │ • Vendor Profiles     │          │
│    │ • Transactions   │           │ • Reviews / Ratings   │          │
│    │ • Wallet Ledgers │           │ • Notification Logs   │          │
│    └──────────────────┘           └──────────────────────┘          │
└──────────────────────────────────────────────────────────────────────┘
```

#### 3.3.2 Technology Stack

| **Layer** | **Technology** | **Rationale** |
|---|---|---|
| **Frontend** | React (JavaScript) | Component-driven architecture enables modular, reactive UI development. Established ecosystem with extensive community support. The student-facing and vendor-facing interfaces are built as separate React modules within a unified application. |
| **Backend** | Node.js with Express.js | Asynchronous, event-driven runtime optimized for high-concurrency I/O operations. Ideal for handling burst traffic during lecture break ordering surges. JavaScript full-stack consistency reduces cognitive switching between frontend and backend. |
| **Database** | *Flexible — Recommended: Hybrid PostgreSQL + MongoDB* | Final selection remains open to accommodate evolving requirements. See Section 3.4 for detailed analysis. |
| **Real-Time Communication** | WebSockets (Socket.io) | Enables bidirectional real-time data flow for live order tracking and vendor dashboard updates without polling overhead. |
| **Authentication** | JSON Web Tokens (JWT) | Stateless, scalable token-based authentication suitable for distributed client-server architectures. |

### 3.4 Database Design Strategy

The database selection remains flexible per project requirements. The following analysis presents the recommended approach:

#### 3.4.1 Recommended Architecture: Hybrid Approach

**Primary Database — PostgreSQL (Relational)**

PostgreSQL is recommended as the core transactional database for data requiring strict relational integrity and ACID compliance:

- **User Accounts:** Registration data, credentials, roles, and profile information.
- **Order Records:** Full order lifecycle data with foreign key relationships to users, vendors, and menu items.
- **Financial Transactions:** Wallet balances, top-up records, and payment ledgers requiring absolute transactional consistency.
- **Loyalty Points:** Accrual and redemption records tied to user accounts and order history.

**Secondary Database — MongoDB (Document Store)**

MongoDB is recommended as a complementary data store for semi-structured, rapidly evolving content:

- **Menu Catalogs:** Vendor menus with variable item attributes, nested categories, and frequently updated pricing — naturally suited to JSON document structures.
- **Vendor Profiles:** Rich media content, operating hours, and promotional data with flexible schema requirements.
- **User Reviews & Ratings:** Variable-length text content with nested reply threads.
- **Notification Logs:** High-volume, append-only event data.

#### 3.4.2 Alternative: Single-Database Approach

If operational simplicity is prioritized over optimization:

- **PostgreSQL only:** Viable with JSONB columns for semi-structured menu data. Sacrifices some query flexibility for operational simplicity.
- **MongoDB only:** Viable for rapid prototyping but introduces risk for financial transaction integrity without careful schema design and application-level enforcement of consistency.

### 3.5 API Architecture

The backend exposes a RESTful API organized by domain modules:

| **Module** | **Key Endpoints** | **Description** |
|---|---|---|
| **Authentication** | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh` | User registration, login with JWT issuance, and token refresh. |
| **Users** | `GET /users/profile`, `PUT /users/profile` | Profile retrieval and update operations. |
| **Vendors** | `GET /vendors`, `GET /vendors/:id`, `GET /vendors/:id/menu` | Vendor listing, detail retrieval, and menu fetching. |
| **Orders** | `POST /orders`, `GET /orders/:id`, `PUT /orders/:id/status` | Order creation, tracking, and status updates (vendor-side). |
| **Wallet** | `GET /wallet/balance`, `POST /wallet/topup`, `POST /wallet/pay` | Balance inquiry, wallet funding, and payment processing. |
| **Reviews** | `POST /reviews`, `GET /vendors/:id/reviews` | Review submission and vendor-specific review retrieval. |
| **Notifications** | `GET /notifications`, `PUT /notifications/:id/read` | Notification listing and read-status updates. |

### 3.6 Security & Authentication Model

| **Security Layer** | **Implementation** |
|---|---|
| **Authentication** | JWT-based stateless authentication with access and refresh token pairs. |
| **Password Storage** | bcrypt hashing with configurable salt rounds. |
| **API Protection** | Role-based middleware enforcing Student, Vendor, and Admin access levels per endpoint. |
| **Data Transport** | HTTPS (TLS 1.3) enforced for all client-server communication. |
| **Input Validation** | Server-side request validation using schema libraries (e.g., Joi, Zod) to prevent injection attacks. |
| **CORS Policy** | Strict origin whitelisting limiting API access to authorized client domains. |
| **Rate Limiting** | Request throttling on authentication endpoints to mitigate brute-force attacks. |

---

## 4. User Interface

> **Note:** The user interface has been fully designed and implemented as a responsive React application. The following sections describe the existing, finalized interface — no new prototypes or mock-ups are included in this document.

### 4.1 Design Philosophy & Principles

The Dalla3 Kershak interface is built upon the following design principles drawn from contemporary digital product standards:

1. **Cognitive Simplicity:** The interface minimizes user cognitive load by presenting clear visual hierarchies, intuitive navigation patterns, and immediately comprehensible iconography. Every screen is designed to be understood within seconds.

2. **Action-Oriented Layout:** Primary user actions (browse menus, place orders, check status) are surfaced with maximum visual prominence, reducing the number of interactions required to complete core tasks.

3. **Visual Consistency:** A unified design system governs typography, color palette, spacing, and component styles across all interface modules — ensuring a cohesive brand experience from registration through order fulfillment.

4. **Accessibility Considerations:** The design accommodates varying visual abilities through appropriate contrast ratios, legible font sizing, and clear interactive state indicators.

### 4.2 Responsive Implementation

The platform supports **both desktop and mobile devices** through a responsive design architecture implemented within the React application. Key responsive characteristics include:

- **Fluid Grid System:** Layout components adapt proportionally to viewport dimensions, maintaining visual balance across screen sizes.
- **Breakpoint-Driven Adaptation:** The interface restructures at defined breakpoints to optimize content presentation for desktop (≥1024px), tablet (768px–1023px), and mobile (<768px) viewports.
- **Mobile-First Priority:** Given that the majority of anticipated user interactions will occur on smartphones (students accessing the platform between lectures), the mobile experience is the primary design target, with desktop serving as an enhanced extension.
- **Touch-Optimized Interactions:** Interactive elements on mobile viewports are sized and spaced according to minimum touch target guidelines (≥44px × 44px) to ensure reliable touch input.

### 4.3 Interface Modules Description

The finalized user interface is organized into the following distinct interface modules:

#### 4.3.1 The Discovery Layer (Consumer Home)

The primary engagement surface for students and staff. This module provides:

- A visually rich, scrollable feed of partnered campus restaurants.
- Search and filtering capabilities by food category, vendor name, or dietary preferences.
- Restaurant cards displaying key information at a glance: vendor name, cuisine type, estimated preparation time, and user rating.
- Promotional banners and featured listing placements for sponsored vendors.
- Quick-access navigation to active orders and wallet balance.

#### 4.3.2 Restaurant & Menu View

Upon selecting a vendor from the discovery feed, users enter a detailed restaurant view featuring:

- Full menu organized by categories (e.g., Sandwiches, Beverages, Combos).
- Individual item cards with descriptions, pricing (in EGP), and add-to-cart functionality.
- Item customization options where applicable (e.g., size, extras).
- Vendor information section including operating hours, location on campus, and aggregate rating.

#### 4.3.3 The Fulfillment Path (Order & Checkout)

The transactional workflow guiding users from cart to confirmed order:

- **Cart Summary:** Itemized order review with quantity adjustment, item removal, and running total.
- **Pickup Time Selection:** Interface for specifying the desired pickup window, with system-suggested optimal times based on current vendor load.
- **Payment Processing:** Wallet-based payment execution with balance display and one-tap confirmation.
- **Order Confirmation:** Success screen displaying the order number, estimated preparation time, and pickup instructions.

#### 4.3.4 Order Tracking View

A real-time status interface providing post-order transparency:

- Visual progress indicator showing the current order state (Confirmed → Preparing → Ready for Pickup).
- Estimated time remaining until the order is ready.
- Push notification triggers at each state transition.
- Order history accessible from the user profile.

#### 4.3.5 Digital Wallet Interface

A self-contained financial management module:

- Current balance display with recent transaction history.
- Top-up functionality with amount selection.
- Transaction detail view for individual payment records.

#### 4.3.6 User Profile & Settings

Personal account management:

- Profile information display and editing (name, email, phone).
- Order history with re-order functionality.
- Loyalty points balance and rewards catalog.
- Notification preferences and account settings.

#### 4.3.7 The Vendor Command Center (Vendor Dashboard)

A utility-focused administration interface for restaurant operators:

- **Live Order Queue:** Real-time incoming order feed with accept/reject actions and preparation timer controls.
- **Order History & Analytics:** Tabular and visual displays of daily/weekly order volume, revenue, and popular items.
- **Menu Management Panel:** CRUD interface for adding, editing, enabling/disabling, and pricing menu items.
- **Notification Center:** System alerts for new orders, cancellations, and operational updates.

### 4.4 Navigation & Information Architecture

The application employs a streamlined navigation hierarchy minimizing depth while maximizing discoverability:

```
Home (Discovery Feed)
├── Search / Filter
├── Restaurant View
│   ├── Menu Browsing
│   └── Add to Cart
├── Cart → Checkout → Order Confirmation
├── Active Order Tracking
├── Wallet
│   ├── Balance
│   ├── Top Up
│   └── Transaction History
├── Profile
│   ├── Personal Info
│   ├── Order History
│   ├── Loyalty Points
│   └── Settings
└── Vendor Dashboard (Vendor role only)
    ├── Live Orders
    ├── Analytics
    └── Menu Management
```

---

## 5. System Concept

### 5.1 Operational Workflow

The Dalla3 Kershak platform facilitates a structured, four-stage operational workflow that transforms the traditional food procurement experience:

#### Stage 1 — Discovery & Selection

A student, between or during lectures, opens the Dalla3 Kershak platform on their device. They browse the aggregated vendor directory, search for specific food types, or explore promoted listings. The interface displays real-time menu availability and estimated preparation times for each vendor.

#### Stage 2 — Order & Payment

The user assembles their order by adding items to their cart, selects a preferred pickup time aligned with their lecture schedule (e.g., their current class ends at 11:30 AM, so they schedule pickup for 11:35 AM). Payment is processed instantly via the integrated digital wallet — eliminating the need for cash handling at the point of collection.

#### Stage 3 — Preparation & Logistics

The corresponding vendor's Command Center dashboard registers the incoming order with full item details and the scheduled pickup time. The system's predictive preparation algorithm advises kitchen staff on precisely when to begin food preparation — ensuring freshness at the exact pickup moment. Real-time status updates (Received → Preparing → Ready) are pushed to the student's interface.

#### Stage 4 — Collection & Completion

A notification alerts the student that their order is ready. They proceed directly to the vendor, present their digital order confirmation, collect their food, and return to their next lecture — the entire post-class food procurement completed in under 5 minutes, with zero time spent in a queue.

### 5.2 Technical Data Flow

```
┌──────────┐    HTTPS/WSS     ┌──────────────┐     Query      ┌────────────┐
│  React   │ ◄──────────────► │   Node.js    │ ◄────────────► │ PostgreSQL │
│  Client  │   REST + WS     │   Express    │   SQL / ORM    │  (ACID)    │
│          │                  │   Server     │                │            │
└──────────┘                  │              │     Query      ┌────────────┐
                              │              │ ◄────────────► │  MongoDB   │
                              │              │   Mongoose     │  (NoSQL)   │
                              └──────┬───────┘                └────────────┘
                                     │
                              ┌──────┴───────┐
                              │ Socket.io    │
                              │ (Real-Time)  │
                              └──────┬───────┘
                                     │
                    ┌────────────────┼────────────────┐
                    ▼                ▼                ▼
             ┌──────────┐    ┌──────────┐    ┌──────────────┐
             │ Student  │    │ Vendor   │    │ Admin        │
             │ Client   │    │ Dashboard│    │ Panel        │
             └──────────┘    └──────────┘    └──────────────┘
```

**Data Flow Sequence for a Typical Order:**

1. **Client → Server:** User submits order via `POST /orders` with item IDs, quantities, pickup time, and wallet payment authorization.
2. **Server → PostgreSQL:** Order record created with status `CONFIRMED`; wallet balance debited in a single atomic transaction.
3. **Server → MongoDB:** Order metadata appended to vendor's active queue document.
4. **Server → Vendor (WebSocket):** Real-time push notification delivered to the vendor's Command Center.
5. **Vendor → Server:** Vendor accepts the order; status updated to `PREPARING`.
6. **Server → Student (WebSocket):** Status change pushed to the student's order tracking interface.
7. **Vendor → Server:** Vendor marks the order as `READY`.
8. **Server → Student (WebSocket + Push):** Final notification delivered — order is available for collection.

### 5.3 Economic & Revenue Model

The platform generates revenue through a diversified, friction-minimized model:

| **Revenue Stream** | **Mechanism** | **Projected Contribution** |
|---|---|---|
| **Per-Order Commission** | A fixed micro-commission (e.g., 5 EGP) deducted from each successful order transaction. Low enough to avoid vendor resistance, high enough to generate meaningful aggregate revenue at scale. | Primary (60–70%) |
| **Featured Listings** | Paid promotional slots allowing vendors to boost their visibility in the consumer discovery feed. Priced on a daily or weekly basis. | Secondary (20–25%) |
| **In-Platform Advertising** | Banner advertisement placements within the consumer interface, available to both campus vendors and external advertisers. | Tertiary (5–15%) |

#### 5.3.1 Unit Economics (Projected)

| **Metric** | **Estimate** |
|---|---|
| Average orders per day (at scale) | 300–500 |
| Commission per order | 5 EGP |
| Daily commission revenue | 1,500–2,500 EGP |
| Monthly commission revenue | 39,000–65,000 EGP |
| Featured listing revenue (monthly) | 5,000–15,000 EGP |
| **Total projected monthly revenue** | **44,000–80,000 EGP** |

### 5.4 Key Performance Indicators (KPIs)

The following metrics will be actively monitored to evaluate platform health and market fit:

| **KPI** | **Definition** | **Target (Phase 1)** |
|---|---|---|
| Daily Active Users (DAU) | Unique users engaging with the platform per day. | 100+ within 4 weeks of launch |
| Daily Order Volume | Total orders processed per day. | 50+ within 4 weeks of launch |
| Average Order Completion Time | Time from order placement to pickup. | < 15 minutes |
| Order Accuracy Rate | Percentage of orders fulfilled without errors. | > 95% |
| User Retention Rate (7-day) | Percentage of users returning within 7 days of first use. | > 40% |
| Vendor Satisfaction Score | Periodic survey-based satisfaction metric from onboarded vendors. | > 4.0 / 5.0 |
| Number of Partnered Restaurants | Total active vendors on the platform. | 3–5 at launch |

---

## 6. Implementation & Market Strategy

### 6.1 Strategic Alignment & Market Positioning

Dalla3 Kershak occupies a **blue ocean position** within the Egyptian university food-tech market — there are currently no direct competitors offering a localized, campus-specific food ordering platform. This absence creates a strategic window for first-mover market capture.

The implementation strategy is guided by three "Brutal Facts" that constrain early-stage execution:

| **Constraint** | **Description** | **Mitigation** |
|---|---|---|
| **Provider Acquisition Resistance** | Campus vendors may resist digital adoption due to unfamiliarity or skepticism. | Target high-traffic "anchor" vendors first. Demonstrate verifiable volume increases within the first 2 weeks. Use success metrics to convert remaining vendors. |
| **Executive Infancy** | The founding team is in its early operational stage, with limited organizational maturity. | Leverage the university environment as a contained, low-risk testing ground. Iterate rapidly based on direct user feedback. |
| **Capital Constraints** | Limited financial resources restrict paid marketing and infrastructure investment. | Utilize lightweight Node.js/React deployments to minimize hosting costs. Execute zero-cost organic marketing via university Facebook groups and physical on-campus poster campaigns. |

### 6.2 Go-To-Market Plan

| **Phase** | **Activity** | **Timeline** | **Outcome** |
|---|---|---|---|
| **Pre-Launch** | Onboard 3–5 anchor vendors; seed 50+ beta user accounts. | Weeks 7–8 | Functional vendor pipeline and initial user base. |
| **Soft Launch** | Limited deployment to a single faculty or department. | Week 8 | Real-world validation of the ordering workflow. |
| **Campus Rollout** | University-wide availability with organic marketing push. | Weeks 9–10 | Campus-wide awareness and adoption. |
| **Optimization** | Data-driven iteration on UX, vendor tools, and performance. | Ongoing | Sustained DAU growth and retention improvement. |

**Marketing Channels:**

- **University Facebook Groups:** High-reach, zero-cost organic distribution channel. Post engaging content (launch announcements, promo codes, student testimonials).
- **On-Campus Posters:** Physical marketing at high-traffic locations (lecture halls, cafeteria entrances, dormitories) with QR codes linking directly to the platform.
- **Word-of-Mouth & Referral Incentives:** Loyalty point bonuses for users who refer new sign-ups.

### 6.3 Risk Assessment & Mitigation

| **Risk** | **Probability** | **Impact** | **Mitigation Strategy** |
|---|---|---|---|
| Low initial user adoption | Medium | High | Aggressive launch promotions; loyalty point sign-up bonuses; anchor vendor partnerships. |
| Vendor refusal to participate | Medium | Critical | Demonstrate ROI with pilot data; offer zero-commission introductory period. |
| Technical downtime during peak hours | Low | High | Load testing before launch; auto-scaling infrastructure; monitoring alerts. |
| Payment/wallet security vulnerabilities | Low | Critical | JWT + HTTPS enforcement; bcrypt hashing; input validation; rate limiting; security audit before launch. |
| Competitor entry | Low (short-term) | Medium | Rapid iteration; deep user relationship; data-driven feature development. |
| Scope creep delaying Phase 1 delivery | Medium | Medium | Strict scope definition (Section 2.5); weekly progress reviews; milestone-based timeline. |

---

## 7. Phase 1 Development Timeline

Given that the **frontend React UI is fully designed and implemented**, Phase 1 focuses on backend architecture, API development, system integration, testing, and preparation for market entry. The following **8-week timeline** provides a realistic, milestone-driven path from requirements finalization to MVP deployment.

---

### Week 1 — Requirements Validation & Architecture Finalization

| **Area** | **Tasks** |
|---|---|
| **Requirements** | Final review of all functional and non-functional requirements against this document. Confirm feature scope with all stakeholders. |
| **Architecture** | Finalize database technology selection (PostgreSQL + MongoDB or single-database approach). Define final API endpoint specifications. |
| **Environment** | Provision development environments. Setup version control (Git) repository with branching strategy. Configure project management tooling (e.g., Trello, Jira). |
| **Deliverable** | ✅ Approved requirements document. Finalized architecture decision record. Development environment operational. |

---

### Week 2 — Database Design & Backend Foundation

| **Area** | **Tasks** |
|---|---|
| **Database** | Design and implement database schemas: Users, Roles, Vendors, MenuItems, Orders, Transactions, WalletLedger, Reviews, Notifications. |
| **Backend Setup** | Initialize Node.js project with Express.js. Configure middleware stack (CORS, body parsing, error handling, logging). |
| **Authentication** | Implement user registration and login endpoints with JWT issuance, bcrypt password hashing, and role-based access control middleware. |
| **Deliverable** | ✅ Database deployed with seed data. Authentication system functional. Backend server running with health-check endpoint. |

---

### Week 3 — Core API Development (Consumer Modules)

| **Area** | **Tasks** |
|---|---|
| **Vendor & Menu APIs** | Build endpoints for vendor listing, search/filter, menu retrieval, and item detail views. |
| **Order System** | Develop the order creation, retrieval, and lifecycle management endpoints. Implement order status state machine (CONFIRMED → PREPARING → READY → COMPLETED). |
| **Wallet System** | Build wallet balance inquiry, top-up, and payment deduction logic with transactional integrity. |
| **Deliverable** | ✅ All consumer-facing API endpoints functional and tested via Postman/Insomnia. |

---

### Week 4 — Core API Development (Vendor & Platform Modules)

| **Area** | **Tasks** |
|---|---|
| **Vendor Dashboard APIs** | Build endpoints for vendor order queue management (accept, reject, update status), menu CRUD operations, and basic analytics queries. |
| **Notification System** | Implement notification creation, retrieval, and read-status endpoints. Configure WebSocket (Socket.io) channels for real-time order event broadcasting. |
| **Loyalty System** | Develop points accrual logic (points per order) and balance tracking endpoints. |
| **Deliverable** | ✅ Vendor-facing APIs functional. Real-time notification pipeline operational. |

---

### Week 5 — Frontend-Backend Integration

| **Area** | **Tasks** |
|---|---|
| **Consumer Integration** | Connect all React consumer screens (Discovery Feed, Restaurant View, Cart, Checkout, Order Tracking, Wallet, Profile) to live API endpoints. Replace static/mock data with real-time API responses. |
| **State Management** | Implement centralized state management for authentication tokens, user session, cart state, and active order tracking. |
| **Error Handling** | Implement client-side error states, loading indicators, and graceful fallbacks for API failures. |
| **Deliverable** | ✅ Consumer-facing application fully functional with live backend data. |

---

### Week 6 — Vendor Dashboard Integration & Real-Time Features

| **Area** | **Tasks** |
|---|---|
| **Vendor Integration** | Connect the Vendor Command Center React module to backend APIs. Implement live order feed via WebSocket subscription. |
| **Real-Time Tracking** | Integrate WebSocket-driven order status updates into the student-facing order tracking view. Verify bidirectional real-time communication (vendor updates → student receives). |
| **Wallet Flow** | End-to-end testing of the wallet top-up → payment → vendor settlement workflow. |
| **Deliverable** | ✅ Vendor dashboard operational with real-time order management. Full order lifecycle functional end-to-end. |

---

### Week 7 — Testing, QA & Performance Optimization

| **Area** | **Tasks** |
|---|---|
| **End-to-End Testing** | Execute complete order lifecycle tests: registration → browse → order → pay → vendor accept → prepare → ready → pickup. Test across Chrome, Firefox, Safari, and mobile browsers. |
| **Load Testing** | Simulate concurrent user loads reflecting peak ordering periods (100+ simultaneous users). Identify and resolve performance bottlenecks. |
| **Security Audit** | Verify JWT expiration and refresh logic. Test input validation against SQL injection and XSS vectors. Confirm HTTPS enforcement. |
| **Bug Resolution** | Systematic triage and resolution of all identified defects from integration and testing phases. |
| **Deliverable** | ✅ All critical and high-severity bugs resolved. Performance benchmarks met. Security audit passed. |

---

### Week 8 — Vendor Onboarding, Soft Launch & MVP Deployment

| **Area** | **Tasks** |
|---|---|
| **Vendor Onboarding** | Onboard 3–5 anchor campus vendors. Populate live menus and configure vendor accounts. Conduct vendor training sessions on the Command Center dashboard. |
| **Beta Deployment** | Deploy the MVP to production infrastructure. Seed initial beta user accounts (50+ students). |
| **Soft Launch** | Release the platform to a limited user group (single faculty or department). Monitor real-time system behavior and user feedback. |
| **Documentation** | Finalize user guides for students and vendor operators. Prepare Phase 2 backlog based on soft launch learnings. |
| **Deliverable** | ✅ MVP deployed and operational. Anchor vendors live. Beta users transacting. Phase 2 planning initiated. |

---

### Timeline Summary

```
Week     1    2    3    4    5    6    7    8
        ┌────┬────┬────┬────┬────┬────┬────┬────┐
REQ     │████│    │    │    │    │    │    │    │  Requirements & Architecture
DB/AUTH │    │████│    │    │    │    │    │    │  Database & Auth Setup
API-C   │    │    │████│    │    │    │    │    │  Consumer APIs
API-V   │    │    │    │████│    │    │    │    │  Vendor & Platform APIs
INT-C   │    │    │    │    │████│    │    │    │  Consumer Integration
INT-V   │    │    │    │    │    │████│    │    │  Vendor Integration & Real-Time
QA      │    │    │    │    │    │    │████│    │  Testing & Optimization
LAUNCH  │    │    │    │    │    │    │    │████│  Onboarding & Soft Launch
        └────┴────┴────┴────┴────┴────┴────┴────┘
```

---

## 8. Conclusion

Phase 1 of the Dalla3 Kershak project establishes a comprehensive foundation for transforming campus food procurement at the Egyptian Chinese University. Through disciplined requirements analysis, a scalable technical architecture built on React and Node.js, and a pragmatic 8-week implementation timeline, the project is positioned to deliver a functional MVP that addresses validated, high-frequency user pain points.

The platform's first-mover advantage within the Egyptian university food-tech vertical, combined with a lean cost structure and organic go-to-market strategy, creates a realistic path to rapid market capture. Success in Phase 1 will be measured by tangible KPIs — daily active users, order volume, and vendor satisfaction — providing the data foundation for informed Phase 2 expansion decisions.

The frontend has been fully designed and implemented as a responsive React application. Phase 1's execution focus is squarely on backend development, system integration, rigorous testing, and the critical first vendor partnerships that will validate the market thesis.

---

## 9. Appendices

### Appendix A — Business Model Canvas (BMC)

The project's Business Model Canvas, supervised by Dr. Ahmed Mahran, is referenced below and provides a high-level strategic view of the platform's value proposition, customer segments, revenue streams, and cost structure.

| **BMC Component** | **Summary** |
|---|---|
| **Problem** | Long queues, order mix-ups, wasted time between lectures, vendor staff stress, no digital order management. |
| **Customer Segments** | University students (primary), University staff — Doctors, TAs, Employees (secondary). |
| **Unique Value Proposition** | Order your food with no queues and pick it up exactly on time. |
| **Solution** | Aggregated campus restaurants, online ordering, scheduled pickup, preparation estimation, notifications, in-app wallet, ratings, vendor dashboard, loyalty system. |
| **Key Metrics** | Daily orders, active users, average order time, partnered restaurants, retention rate. |
| **Revenue Streams** | Per-order commission, featured listings, in-platform advertisements. |
| **Channels** | University Facebook groups, on-campus posters. |
| **Cost Structure** | Website development (frontend + backend), hosting & servers, payment gateway fees, on-campus marketing. |
| **Unfair Advantage** | Strong university focus, fast execution & iteration, data analytics for restaurants, deep user understanding. |

### Appendix B — Glossary

| **Term** | **Definition** |
|---|---|
| **MVP** | Minimum Viable Product — the initial deployable version with core functionality. |
| **DAU** | Daily Active Users — unique users per day. |
| **ACID** | Atomicity, Consistency, Isolation, Durability — properties of reliable database transactions. |
| **JWT** | JSON Web Token — a compact, URL-safe token format for stateless authentication. |
| **CORS** | Cross-Origin Resource Sharing — a browser security mechanism for controlling cross-domain API access. |
| **EGP** | Egyptian Pound — the local currency for all platform transactions. |
| **WebSocket** | A protocol enabling persistent, bidirectional communication between client and server. |
| **ORM** | Object-Relational Mapping — a technique for querying databases using application-level objects. |

---

*Document prepared by Team Masterpiece — Egyptian Chinese University, Faculty of Computer Science & Information Systems.*
*Phase 1 — Version 2.0 — April 2026*
