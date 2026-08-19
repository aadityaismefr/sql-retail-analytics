# 11_revenue_concentration

> Q: How dependent are we on a handful of customers? (Pareto check)
> Technique: cumulative SUM() OVER an ordered window.

```sql
-- Q: How dependent are we on a handful of customers? (Pareto check)
-- Technique: cumulative SUM() OVER an ordered window.
WITH per_customer AS (
    SELECT customer_id, sum(order_total) AS revenue
    FROM orders GROUP BY customer_id
),
ranked AS (
    SELECT customer_id,
           revenue,
           row_number() OVER (ORDER BY revenue DESC)                       AS rn,
           sum(revenue) OVER (ORDER BY revenue DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
           sum(revenue) OVER ()                                            AS total_revenue,
           count(*)     OVER ()                                            AS total_customers
    FROM per_customer
)
SELECT decile,
       count(*)                       AS customers,
       round(sum(revenue), 2)         AS revenue,
       round(100.0 * sum(revenue) / max(total_revenue), 1) AS pct_of_revenue
FROM (SELECT *, ntile(10) OVER (ORDER BY revenue DESC) AS decile FROM ranked)
GROUP BY decile
ORDER BY decile;
```

**10 row(s)**

|   decile |   customers |   revenue |   pct_of_revenue |
|---------:|------------:|----------:|-----------------:|
|        1 |         278 | 217333    |             34.8 |
|        2 |         278 | 121788    |             19.5 |
|        3 |         278 |  87323    |             14   |
|        4 |         277 |  63113.9  |             10.1 |
|        5 |         277 |  47636.9  |              7.6 |
|        6 |         277 |  35089.1  |              5.6 |
|        7 |         277 |  24641.1  |              3.9 |
|        8 |         277 |  15540.2  |              2.5 |
|        9 |         277 |   8605.7  |              1.4 |
|       10 |         277 |   3836.54 |              0.6 |
