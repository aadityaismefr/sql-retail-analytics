-- Q: Do discounts pay for themselves? Compare basket size and gross margin
--    at each discount level.
SELECT o.discount_rate,
       count(*)                                              AS orders,
       round(avg(o.order_total), 2)                          AS avg_order_value,
       round(avg(items.n_lines), 2)                          AS avg_lines_per_order,
       round(sum(o.order_total), 2)                          AS revenue,
       round(sum(items.gross_margin), 2)                     AS gross_margin,
       round(100.0 * sum(items.gross_margin) / sum(o.order_total), 1) AS margin_pct
FROM orders o
JOIN (
    SELECT oi.order_id,
           count(*) AS n_lines,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)
               - oi.quantity * oi.unit_price * (1 - p.margin_rate)) AS gross_margin
    FROM order_items oi JOIN products p USING (product_id)
    GROUP BY oi.order_id
) items USING (order_id)
GROUP BY o.discount_rate
ORDER BY o.discount_rate;
