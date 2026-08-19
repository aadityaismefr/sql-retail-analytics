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
