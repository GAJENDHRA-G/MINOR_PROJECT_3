# MINOR_PROJECT_3

# 🚩 RedFlag – The Fraud Files

> **Build a Fraud Detection Engine using Pure SQL**

---

# 📖 Project Description

**RedFlag** is an industry-inspired SQL project that simulates the responsibilities of a **Fraud Analyst** at **PayFast**, a fictional Indian payment aggregator handling over **200,000 financial transactions** across a six-month period.

The objective of this project is to detect **12 real-world fraud patterns** using **pure SQL**, without relying on Python, machine learning, or external analytics tools. By applying advanced SQL techniques such as aggregations, joins, subqueries, Common Table Expressions (CTEs), and window functions, the project identifies suspicious user behaviour, fraudulent transaction patterns, and high-risk merchant activities commonly encountered in modern fintech systems.  [oai_citation:1‡RedFlag_Project_Brief.pdf](sediment://file_000000004ba081faa8ff4775c82153c7)

---

# 📸 Sample Query Result

<img width="358" height="404" alt="refund_ratio" src="https://github.com/user-attachments/assets/86f68a4c-902f-4377-8724-a178fbe1d211" />
<img width="163" height="341" alt="just_under_threshold" src="https://github.com/user-attachments/assets/4593df87-23de-41cd-8555-a0088f3fd70c" />
<img width="553" height="564" alt="Geographical_Impossibilty" src="https://github.com/user-attachments/assets/b056f483-27f8-44ac-a23c-63e9e3fff3a9" />


---

# 🚨 Fraud Patterns Detected

| Tier | Fraud Pattern |
|------|---------------|
| **Tier 1** | Velocity Fraud |
| | Round-Amount Clustering |
| | Card Testing |
| | Failed-Then-Succeeded Transactions |
| | Odd-Hour Transaction Concentration |
| **Tier 2** | Mule Accounts |
| | Refund Abuse |
| | Merchant Collusion |
| | Just-Under-Threshold (Structuring) |
| | Dormant-Then-Active Accounts |
| **Tier 3** | Velocity Spike |
| | Geographic Impossibility |

*These fraud patterns are based on real-world financial fraud scenarios commonly encountered by fintech fraud analytics teams.*  [oai_citation:3‡RedFlag_Project_Brief.pdf](sediment://file_000000004ba081faa8ff4775c82153c7)

---

# 🛠 Tech Stack

| Category | Technologies |
|-----------|--------------|
| **Database** | MySQL 8.0 |
| **Language** | SQL |
| **IDE** | MySQL Workbench |
| **Version Control** | Git |
| **Repository** | GitHub |

### SQL Concepts Used

- Common Table Expressions (CTEs)
- Window Functions (`LAG`, `ROW_NUMBER`, `OVER`)
- Aggregate Functions
- GROUP BY & HAVING
- CASE WHEN
- Joins
- Subqueries
- Correlated Subqueries
- EXISTS
- DATE()
- HOUR()
- DATE_FORMAT()
- TIMESTAMPDIFF() RedFlag_Project_Brief.pdf

---
