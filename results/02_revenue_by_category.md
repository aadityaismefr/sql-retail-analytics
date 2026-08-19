# 02_revenue_by_category

> Q: Which categories carry the business, and how concentrated is revenue?
> Technique: aggregate + SUM() OVER () for share-of-total without a second pass.

```sql
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
```

**5 row(s)**

| category      |   orders |   units |   revenue |   pct_of_revenue |
|:--------------|---------:|--------:|----------:|-----------------:|
| Brewing Gear  |     1332 |    2169 |  197037   |             31.5 |
| Grinders      |      713 |    1133 |  141597   |             22.7 |
| Coffee        |     2893 |    5955 |  111029   |             17.8 |
| Subscriptions |     1018 |    1710 |  100680   |             16.1 |
| Accessories   |     1711 |    3071 |   74563.7 |             11.9 |
