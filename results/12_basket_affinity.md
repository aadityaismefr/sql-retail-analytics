# 12_basket_affinity

> Q: Which categories get bought together? Input for bundling and cross-sell.
> Technique: self-join on order_id with a < guard to avoid mirrored pairs.

```sql
-- Q: Which categories get bought together? Input for bundling and cross-sell.
-- Technique: self-join on order_id with a < guard to avoid mirrored pairs.
WITH order_cats AS (
    SELECT DISTINCT oi.order_id, p.category
    FROM order_items oi JOIN products p USING (product_id)
),
pairs AS (
    SELECT a.category AS cat_a, b.category AS cat_b, count(*) AS baskets
    FROM order_cats a
    JOIN order_cats b ON a.order_id = b.order_id AND a.category < b.category
    GROUP BY 1, 2
),
totals AS (SELECT count(DISTINCT order_id) AS all_orders FROM order_cats)
SELECT cat_a, cat_b, baskets,
       round(100.0 * baskets / (SELECT all_orders FROM totals), 2) AS pct_of_orders
FROM pairs
ORDER BY baskets DESC
LIMIT 10;
```

**10 row(s)**

| cat_a        | cat_b         |   baskets |   pct_of_orders |
|:-------------|:--------------|----------:|----------------:|
| Accessories  | Coffee        |       832 |           17.55 |
| Brewing Gear | Coffee        |       643 |           13.57 |
| Coffee       | Subscriptions |       521 |           10.99 |
| Accessories  | Brewing Gear  |       391 |            8.25 |
| Coffee       | Grinders      |       352 |            7.43 |
| Accessories  | Subscriptions |       292 |            6.16 |
| Brewing Gear | Subscriptions |       229 |            4.83 |
| Accessories  | Grinders      |       218 |            4.6  |
| Brewing Gear | Grinders      |       170 |            3.59 |
| Grinders     | Subscriptions |       144 |            3.04 |
