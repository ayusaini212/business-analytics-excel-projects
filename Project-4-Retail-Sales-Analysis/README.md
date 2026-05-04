# Project 4 — Retail Sales & Operations Performance Analysis

**Tools Used:** SQL (DB Browser SQLite) · Power BI  
**Dataset:** US Retail Superstore — 9,995 transactions · 22 columns · 4 regions · 2014 to 2017  
**Skills:** Data Analysis · SQL Querying · DAX Measures · Dashboard Design · Business Insights

---

## What This Project Is About

This project analyzes 4 years of retail sales data across the United States — covering revenue, profit, discounting behavior, shipping performance, and regional sales patterns.

Unlike my previous projects where I created the dataset myself, this one uses a real external dataset with nearly 10,000 rows. The goal was to write SQL queries to find the key business problems, then build a Power BI dashboard to present the findings visually.

The main question I was trying to answer: **why is overall profit margin only 12.5% despite $2.3M in revenue — and where is the money going?**

---

## Dashboard Preview

![Project 4 Dashboard](project4_dashboard.png)

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
| Time Period | 2014 — 2017 |
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

## Power BI Dashboard — Visuals Built

| Visual | Type | What It Shows |
|---|---|---|
| KPI Cards | Cards | Total Sales, Total Profit, Total Orders, Overall Margin % |
| Monthly Trend | Line Chart | Revenue by month across 2014-2017 — shows seasonality |
| Regional Performance | Bar Chart | Revenue comparison across West, East, Central, South |
| Category Sales | Bar Chart | Technology vs Furniture vs Office Supplies |
| Ship Mode Distribution | Donut Chart | Order share by shipping method |
| Top 7 Products | Bar Chart | Highest revenue products |
| US State Map | Filled Map | Revenue by state — color intensity shows performance |
| Region Slicer | Button Slicer | Filter entire dashboard by region |

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
   └── project4_dashboard.pbix         ← Power BI file (if uploaded)
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
