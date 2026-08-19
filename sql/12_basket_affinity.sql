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
