# Entrepreneurship Assignments: Dalla3 Kershak

This document contains the deliverables for Assignment 6 and Assignment 7, tailored to the **Dalla3 Kershak** university campus food ordering platform.

---

## Assignment 6: Business Model Canvas & Customer Understanding

### 1. Business Model Canvas (BMC)

| Component | Description |
| :--- | :--- |
| **Customer Segments** | **Primary:** University students (time-constrained, price-sensitive).<br>**Secondary:** University staff, teaching assistants, doctors.<br>**Partners:** Campus cafeterias, kiosks, and food vendors. |
| **Value Propositions** | **For Students:** Zero queueing, exact scheduled pickup times, cashless convenience, and daily time savings.<br>**For Vendors:** Digital order management, reduced verbal errors, increased throughput during rush hours, centralized dashboard. |
| **Channels** | University Facebook & social media groups, targeted physical posters/QR codes on campus, word-of-mouth (students). |
| **Customer Relationships** | Self-service automated platform, real-time push notifications, loyalty/rewards program to drive retention. |
| **Revenue Streams** | **Primary:** Flat per-order micro-commission (e.g., 5 EGP).<br>**Secondary:** Featured "Sponsored" listings for vendors, in-app banner ads. |
| **Key Resources** | Technology infrastructure (React/Node.js app), vendor network agreements, active student user base. |
| **Key Activities** | Platform development and maintenance, vendor onboarding and training, localized marketing & user acquisition, customer support. |
| **Key Partnerships** | Anchor campus food vendors, university administration (for operational approval and potential integration). |
| **Cost Structure** | Cloud hosting and infrastructure, payment gateway transaction fees, marketing materials, software development and maintenance. |

### 2. Empathy Map (Primary Segment: University Students)

| Thinking & Feeling | Seeing |
| :--- | :--- |
| • *Frustrated* by the massive waste of time standing in lines.<br>• *Anxious* about being late to the next lecture if they wait for food.<br>• *Craving* a quick, reliable meal during their short 10-15 minute breaks.<br>• *Relieved* when they can guarantee their food is ready. | • Chaotic, crowded spaces in front of campus food kiosks.<br>• Fellow students looking stressed or checking their watches.<br>• No clear visual indication of how long the wait will actually be. |
| **Hearing** | **Saying & Doing** |
| • Loud, noisy environments making communication with vendors difficult.<br>• Vendors shouting order numbers or mixing up verbal orders.<br>• Peers complaining: *"I'm going to skip lunch, the line is too long."* | • Often skips meals entirely to avoid being late to class.<br>• Sometimes leaves the queue after 5 minutes of waiting.<br>• Scrutinizes cash and struggles to find exact change or small bills. |
| **Pains** | **Gains** |
| • Missing lunch entirely.<br>• Arriving late to lectures.<br>• Receiving the wrong order due to miscommunication.<br>• Dealing with the hassle of cash and physical change. | • Gaining an extra 15 minutes to socialize or study.<br>• A guaranteed hot meal between classes.<br>• Seamless, modern payment experience. |

### 3. Top 5 Key Assumptions to Validate

1. **Student Pre-Ordering Behavior:** Students are proactive enough to plan ahead and schedule their orders *before* their lecture ends, rather than relying on spontaneous ordering.
2. **Vendor Operational Compliance:** Vendors will actively use a digital dashboard (tablet/screen) and faithfully update order statuses (Received → Preparing → Ready) precisely during high-pressure peak rush hours.
3. **Digital Wallet Adoption:** Students will trust a closed-loop digital wallet and be willing to pre-load balances rather than relying solely on cash on delivery.
4. **Commission Acceptance:** A fixed per-order commission (e.g., 5 EGP) is acceptable to users without deterring them from using the platform daily.
5. **Accurate Time Estimation:** The system can accurately predict food preparation times despite fluctuating vendor loads, ensuring the food is hot exactly when the student arrives.

---

## Assignment 7: Hypothesis Testing & MVP Design

### 1. The Top 3 Most Critical Risky Assumptions

We have isolated the top 3 assumptions that, if proven false, would cause the Dalla3 Kershak business model to fail.

1. **Vendor Operational Compliance** (If vendors ignore the tablet during a rush, students will arrive, the food won't be ready, and trust in the app is destroyed).
2. **Student Pre-Ordering Behavior** (If students refuse to use an app and prefer walking up to the counter instinctively, there is no demand).
3. **Closed-Loop Wallet Pre-loading** (If students refuse to pre-load money into the app, the transaction friction remains too high).

### 2. Hypotheses, MVP Designs, and Success Metrics

#### Test 1: Vendor Operational Compliance
* **Hypothesis:** If we provide a fast-paced campus vendor with a simplified digital interface (only "Accept" and "Ready" buttons), they will update the status of at least 85% of digital orders without manual intervention during the peak rush hour (12:00 PM - 2:00 PM).
* **MVP Design (Concierge / Shadow Testing):** 
  Equip one anchor vendor with a basic tablet displaying a simplified order queue (no backend required, can be a simple web view or mocked UI). A team member stands beside the vendor during rush hour to observe. We send test orders to the screen. We watch to see if the vendor interacts with the tablet naturally or if they ignore it / require the team member to tap the buttons for them.
* **Measurable Success Metrics:**
  * Percentage (%) of orders updated correctly by the vendor staff alone.
  * Number of times the vendor complains about the tablet being a distraction.

#### Test 2: Student Pre-Ordering Behavior
* **Hypothesis:** If provided with a digital menu link, at least 20% of a specific cafeteria's daily customers will choose to pre-order an hour in advance rather than waiting in the physical queue.
* **MVP Design (WhatsApp Bot / Landing Page):**
  Generate a QR code linked to a simple Google Form or a WhatsApp Business number. Distribute the QR code on flyers handed to students standing in the long queue of a specific vendor. The flyer says: *"Skip this line tomorrow. Scan to pre-order."* Orders are received on WhatsApp by the team, who manually relay them to the vendor.
* **Measurable Success Metrics:**
  * Number of WhatsApp pre-orders received per day.
  * Conversion rate: (Number of pre-orders) / (Number of flyers handed out).
  * Repeat usage: Percentage of students who order via WhatsApp more than once in a week.

#### Test 3: Closed-Loop Wallet Pre-loading
* **Hypothesis:** If we offer a 10% credit bonus, at least 30% of our early-adopter students will be willing to deposit an initial sum of 50 EGP cash into our digital platform to use for future orders.
* **MVP Design (Physical Booth & Ledger):**
  Set up a physical "Dalla3 Kershak" activation booth on campus. We offer students a deal: Give us 50 EGP in cash now, and we will give you 55 EGP in "Digital Credit" to use for their WhatsApp pre-orders (from Test 2). We manually track the balances on an Excel Spreadsheet. 
* **Measurable Success Metrics:**
  * Total number of students who agree to deposit funds.
  * Average initial deposit amount.
  * Qualitative feedback on why students who refused chose not to deposit (e.g., lack of trust, don't have enough cash on hand).
