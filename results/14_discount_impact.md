# 14_discount_impact

> Q: Do discounts pay for themselves? Compare basket size and gross margin
> at each discount level.

```sql
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
```

**5 row(s)**

|   discount_rate |   orders |   avg_order_value |   avg_lines_per_order |   revenue |   gross_margin |   margin_pct |
|----------------:|---------:|------------------:|----------------------:|----------:|---------------:|-------------:|
|            0    |     3681 |            136.2  |                  1.99 |  501346   |      211041    |         42.1 |
|            0.05 |      276 |            125.26 |                  1.96 |   34572.7 |       13578.1  |         39.3 |
|            0.1  |      277 |            123.36 |                  2.03 |   34170.8 |       11888.8  |         34.8 |
|            0.15 |      245 |            101.44 |                  1.91 |   24852.6 |        7901.06 |         31.8 |
|            0.2  |      261 |            114.81 |                  2.04 |   29965.7 |        8137.17 |         27.2 |
