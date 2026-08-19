# 03_top_products

> Q: What are the top 3 products inside each category by revenue?
> Technique: RANK() partitioned by category, filtered with QUALIFY.

```sql
-- Q: What are the top 3 products inside each category by revenue?
-- Technique: RANK() partitioned by category, filtered with QUALIFY.
SELECT category, sku, revenue, units, rnk
FROM (
    SELECT p.category,
           p.sku,
           sum(oi.quantity)                                                    AS units,
           round(sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
           rank() OVER (PARTITION BY p.category
                        ORDER BY sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) DESC) AS rnk
    FROM order_items oi
    JOIN products p USING (product_id)
    GROUP BY p.category, p.sku
)
WHERE rnk <= 3
ORDER BY category, rnk;
```

**15 row(s)**

| category      | sku     |   revenue |   units |   rnk |
|:--------------|:--------|----------:|--------:|------:|
| Accessories   | ACC-014 |  11910    |     192 |     1 |
| Accessories   | ACC-001 |   9108.51 |     153 |     2 |
| Accessories   | ACC-007 |   8131.25 |     193 |     3 |
| Brewing Gear  | BRE-001 |  33567.2  |     230 |     1 |
| Brewing Gear  | BRE-002 |  33002.7  |     250 |     2 |
| Brewing Gear  | BRE-006 |  31962.6  |     218 |     3 |
| Coffee        | COF-013 |  13662.7  |     405 |     1 |
| Coffee        | COF-004 |  13311.1  |     451 |     2 |
| Coffee        | COF-011 |  11476    |     425 |     3 |
| Grinders      | GRI-001 |  41541.1  |     201 |     1 |
| Grinders      | GRI-004 |  35345.4  |     172 |     2 |
| Grinders      | GRI-003 |  18985.8  |     209 |     3 |
| Subscriptions | SUB-001 |  36000.8  |     437 |     1 |
| Subscriptions | SUB-002 |  33683.4  |     431 |     2 |
| Subscriptions | SUB-004 |  23259.1  |     457 |     3 |
