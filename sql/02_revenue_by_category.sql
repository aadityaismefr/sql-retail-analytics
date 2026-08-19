-- Q: Which categories carry the business, and how concentrated is revenue?
-- Technique: aggregate + SUM() OVER () for share-of-total without a second pass.
SELECT p.category,
       count(DISTINCT oi.order_id)                                   AS orders,
       sum(oi.quantity)                                              AS units,
       round(sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
       round(100.0 * sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate))
             / sum(sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate))) OVER (), 1) AS pct_of_revenue
FROM order_items oi
JOIN products p USING (product_id)
GROUP BY p.category
ORDER BY revenue DESC;
