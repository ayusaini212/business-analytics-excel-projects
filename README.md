# 📊 Data & Business Analytics Projects — Excel, power BI, SQL

**By Ayush Saini | Operations & Data Analyst**

🔗 [LinkedIn — Ayush Saini](https://www.linkedin.com/in/ayusaini) · 📧 Open to Operations Analyst & Business Analyst roles

---

## 👋 What This Repo Is About

This repository contains two business analytics projects I built while learning Excel and business analytics with a focus on operations and supply chain roles.

second project is built in power bi which is a retail sales transaction data - where i use powwer query, DAX formulas and suggested requirements agains business purposes and write meanigful insights.

first projects is built entirely in Excel — from raw data to pivot tables to interactive dashboards with real business insights. No fancy tools, just structured thinking and clean execution.


---

## 📁 Projects Overview

| Project 2 — Retail sales & operations performance dashboard  | covering revenue, profit, discounting behavior, shipping performance, and regional sales patterns |
| Project 1 — Inventory Profitability & Operations Dashboard | Profitability analysis, dead stock detection, supplier performance | Advanced formulas, Scatter plot, Supplier scorecard, Business insights |

---

# Project 2 — Retail Sales & Operations Performance Analysis

**Tools Used:** SQL (DB Browser SQLite) · Power BI  
**Dataset:** US Retail Superstore — 9,995 transactions · 22 columns · 4 regions · 2022 to 2025
**Skills:** Data Analysis · SQL Querying · DAX Measures · Dashboard Design · Business Insights

---

## What This Project Is About

This project analyzes 4 years of retail sales data across the United States — covering revenue, profit, discounting behavior, shipping performance, and regional sales patterns.

Unlike my previous projects where I created the dataset myself, this one uses a real external dataset with nearly 10,000 rows. The goal was to write SQL queries to find the key business problems, then build a Power BI dashboard to present the findings visually.

The main question I was trying to answer: **why is overall profit margin only 12.5% despite $2.3M in revenue — and where is the money going?**

---

## Dashboard Preview

[Project 2 Dashboard]
<img width="1033" height="544" alt="Screenshot 2026-05-04 125455" src="https://github.com/user-attachments/assets/638308cb-a41b-4c20-bc1f-66a4a791f3d5" />




---

## Dataset Overview

| Metric | Value |
|---|---|
| Total Transactions | 9,995 rows |
| Unique Orders | 5,009 |
| Total Revenue | $2,297,201 |
| Total Profit | $286,398 |
| Overall Margin | 12.5% |
| Avg Discount | 15.6% |
| Time Period | 2022 — 2025 |
| Regions | West, East, Central, South |
| Categories | Technology, Furniture, Office Supplies |

---

## SQL Analysis — Key Queries & Findings

All queries written in SQLite via DB Browser for SQLite.

---

### Query 1 — Overall Business KPIs

```sql
SELECT
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Discount) * 100, 1) AS avg_discount_percent,
    ROUND(SUM(Profit) * 100 / SUM(Sales), 1) AS overall_margin_percent
FROM sales;
```

**Result:** 5,009 orders · $2.3M revenue · $286K profit · 12.5% margin · 15.6% avg discount

**Insight:** A 12.5% margin on $2.3M revenue is well below the healthy retail benchmark of 20%+. With an average discount of 15.6% across all orders, discounting is clearly the primary driver of margin erosion.

---

### Query 2 — Regional Performance

```sql
SELECT Region,
       COUNT(DISTINCT "Order ID") AS total_orders,
       ROUND(SUM(Sales), 0) AS total_revenue,
       ROUND(SUM(Profit), 0) AS total_profit,
       ROUND(SUM(Profit) * 100 / SUM(Sales), 1) AS margin_percent
FROM sales
GROUP BY Region
ORDER BY total_profit DESC;
```

**Result:**

| Region | Orders | Revenue | Profit | Margin |
|---|---|---|---|---|
| West | 1,611 | $725,458 | $108,419 | 14.9% |
| East | 1,401 | $678,781 | $91,523 | 13.5% |
| South | 822 | $391,722 | $46,750 | 11.9% |
| Central | 1,175 | $501,240 | $39,706 | 7.9% |

**Insight:** West is the strongest region both in revenue and margin. Central is the biggest concern — despite $501K in revenue it only generates 7.9% margin, the lowest of all regions. South has the fewest orders which suggests untapped market potential.

---

### Query 3 — Category & Sub-Category Performance

```sql
SELECT Category,
       ROUND(SUM(Sales), 0) AS total_revenue,
       ROUND(SUM(Profit), 0) AS total_profit,
       SUM(Quantity) AS total_units_sold,
       ROUND(SUM(Profit) * 100 / SUM(Sales), 1) AS margin_percent
FROM sales
GROUP BY Category
ORDER BY total_profit DESC;
```

**Result:**

| Category | Revenue | Profit | Units Sold | Margin |
|---|---|---|---|---|
| Technology | $836,154 | $145,456 | 6,939 | 17.4% |
| Office Supplies | $719,047 | $122,491 | 22,906 | 17.0% |
| Furniture | $742,000 | $18,451 | 8,028 | 2.5% |

**Insight:** Furniture generates $742K in revenue but only $18,451 in profit — a 2.5% margin that is dangerously thin. Office Supplies sells the most units (22,906) with a solid 17% margin. Technology has the best balance of high revenue and strong margin at 17.4%.

---

### Query 4 — Discount Impact on Profit

```sql
SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.2 THEN 'Low (up to 20%)'
        WHEN Discount <= 0.4 THEN 'Medium (20-40%)'
        ELSE 'High (above 40%)'
    END AS discount_tier,
    COUNT(*) AS total_orders,
    ROUND(AVG(Profit), 2) AS avg_profit,
    ROUND(SUM(Profit), 0) AS total_profit
FROM sales
GROUP BY discount_tier
ORDER BY avg_profit DESC;
```

**Result:**

| Discount Tier | Orders | Avg Profit | Total Profit |
|---|---|---|---|
| No Discount | 4,798 | $66.90 | $320,988 |
| Low (up to 20%) | 3,803 | $26.50 | $100,786 |
| Medium (20-40%) | 460 | -$77.86 | -$35,818 |
| High (above 40%) | 933 | -$106.71 | -$99,559 |

**Insight:** This is the most important finding in the entire dataset. Orders with medium discounts (20-40%) lose an average of $77.86 per order. Orders with high discounts (above 40%) lose $106.71 per order. Together these discounted orders are destroying $135,377 in profit. Without these orders the overall business margin would be significantly healthier.

---

### Query 5 — Shipping Performance

```sql
SELECT Ship_Mode,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales), 0) AS total_revenue,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days
FROM sales
GROUP BY Ship_Mode
ORDER BY avg_delivery_days ASC;
```

**Result:**

| Ship Mode | Orders | Revenue | Avg Delivery Days |
|---|---|---|---|
| Same Day | 543 | $128,363 | 0.9 days |
| First Class | 1,538 | $351,428 | 23.5 days |
| Second Class | 1,945 | $459,193 | 30.6 days |
| Standard Class | 5,968 | $1,358,216 | 41.9 days |

**Insight:** Standard Class handles 59% of all orders but takes 41.9 days on average to deliver. First Class is significantly faster at 23.5 days. For high value orders, the business should consider nudging customers toward faster shipping modes to improve customer satisfaction.

---

### Query 6 — Returns Impact

```sql
SELECT Returned,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales), 0) AS total_revenue,
       ROUND(SUM(Profit), 0) AS total_profit
FROM sales
GROUP BY Returned;
```

**Result:**

| Returned | Orders | Revenue | Profit |
|---|---|---|---|
| No | 9,194 | $2,116,697 | $263,165 |
| Yes | 800 | $180,504 | $23,232 |

**Insight:** 800 orders (8% of total) were returned — generating $180K in revenue but only $23K in profit. Returns are relatively contained and not the primary profit problem — discounting is the bigger issue.

---


## Key Business Insights

1. **Discounting is the #1 profit killer** — orders with 20%+ discounts generate negative profit. Medium and high discount orders together destroy $135K in profit annually.

2. **Furniture has a critical margin problem** — $742K in revenue but only 2.5% margin. This category needs a pricing or cost review urgently.

3. **West region leads, Central underperforms** — West generates the highest profit at $108K with 14.9% margin. Central has the worst margin at just 7.9% despite being the second largest region by orders.

4. **Technology is the healthiest category** — highest revenue at $836K and strongest margin at 17.4%. This should be the primary focus for growth investment.

5. **Standard Class dominates but is slow** — 59% of orders use Standard Class with 41.9 day average delivery. For premium products, faster shipping options should be encouraged.

6. **Returns are manageable** — only 8% return rate, not a primary business concern compared to discounting issues.

---

## Recommendations

- **Immediately review discount policy** — cap discounts at 20% maximum. Orders above this threshold are loss-making.
- **Investigate Furniture category** — 2.5% margin is unsustainable. Either renegotiate supplier costs or increase pricing.
- **Focus growth investment on West region** — highest margin and revenue, proven market.
- **Develop South region** — lowest order count but 11.9% margin suggests quality demand exists with room to scale.
- **Promote First Class shipping** for Technology orders — faster delivery for high value products improves customer experience.

---

## Files in This Project

```
📁 Project-4-Retail-Sales-Analysis/
   └── project4_sales_analysis.sql     ← All SQL queries
   └── project4_dashboard.png          ← Power BI dashboard screenshot
   └── project4_dashboard.pbix         ← Power BI file
```

---

## Skills Demonstrated

| Skill | How Used |
|---|---|
| SQL — GROUP BY, CASE WHEN, ROUND | All 8 analysis queries |
| SQL — Aggregate functions | SUM, AVG, COUNT, DISTINCT |
| SQL — Date functions | Delivery day calculation |
| Power BI — DAX | Calculated columns and measures |
| Power BI — Visuals | Line, bar, donut, map, slicer |
| Business thinking | Identified root cause of low margin |
| Data storytelling | Insights and recommendations section |

---

*Analyzed using SQL (DB Browser SQLite) and visualized in Microsoft Power BI · 2025*




## 🗂️ Project 1 — Inventory Profitability & Operations Dashboard

This is the more advanced one. I wanted to go beyond just tracking stock — I wanted to understand **which products are actually making money, which suppliers are worth working with, and where the business is quietly losing cash.**

The dataset has 15 products across 6 suppliers and covers everything from profit margins to dead stock to supplier lead times.

---

### 📸 Dashboard Preview
<img width="1029" height="545" alt="Screenshot 2026-05-05 112915" src="https://github.com/user-attachments/assets/3f08861c-62d0-4c58-a0c6-670be96b6c85" />



> *Interactive dashboard with slicers— filter by supplier to see how metrics change*

---

### 🔍 What I Analyzed

**Profitability**
- Calculated Profit per Unit, Profit Margin %, Total Profit, and Revenue for every product
- Classified products into High / Medium / Low profit tiers
- Found that Smartphones drive the highest total profit (₹12,50,000) but only at 33% margin — meaning it's volume, not efficiency, doing the heavy lifting

**Dead Stock Detection**
- Flagged products with zero or near-zero sales movement
- Screen Protector identified as the only confirmed dead stock item — ₹500 stuck in inventory with 0 revenue and 0.00 turnover
- Flagged 3 additional slow-moving products at financial risk

**Supplier Performance**
- Built a supplier scorecard comparing Total Profit Contribution vs Average Lead Time
- Found that Supplier D contributes 80% of total profit — but also carries the longest lead time at 15 days
- That's a real business trade-off — high dependency on one supplier with slow delivery

**Inventory Health**
- Calculated Holding Cost, Inventory Turnover, Months of Stock, and Movement Type (Fast / Normal / Slow) for each product
- Stationary items showed better profit-to-revenue ratio compared to electronics despite lower absolute numbers

---

### 📊 Charts Built

- Stacked chart — Top 10 products by profit
- Scatter plot — Cost per unit vs Profit margin (pricing efficiency)
- Bar graph — Supplier profit contribution breakdown
- Pie chart — Dead stock vs Active stock distribution
- Bar chart — Category-wise Revenue vs Total Profit comparison

---

### 💡 Key Business Insights

These are the actual findings I wrote on the dashboard — not just describing the data, but what it means:

1. Smartphones and CPU are top profit contributors but their high cost makes them risky to overstock
2. Pen Pack, Notebook, and Webcam have strong profit margins with very low cost — good candidates for increased stocking
3. Supplier D drives the most profit but a 15-day lead time is a supply chain risk worth monitoring
4. ₹500 is currently stuck in dead stock — small number, but the 3 slow-moving products nearby could become the next problem
5. Electronics dominate revenue but stationary items have a healthier revenue-to-profit ratio

---

### 🛠️ Excel Skills Used

- IF, IFS, AVERAGEIF, SUMIF, COUNTIF
- Nested logical formulas for product classification
- Pivot Tables with multi-level grouping
- Dynamic charts with slicer connectivity
- Conditional formatting for risk and status flags
- KPI card design with color-coded metrics
- Data labels and custom axis formatting on scatter plot

---




If you're hiring for operations analyst or business analyst roles in Delhi NCR, feel free to reach out.

📧 ayushajmera2004@gmail.com
🔗 [LinkedIn](https://www.linkedin.com/in/ayusaini)

---
