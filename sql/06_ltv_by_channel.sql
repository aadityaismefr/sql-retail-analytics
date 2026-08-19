-- Q: Which acquisition channel produces the most valuable customers?
-- This is the query that changes budget decisions: paid_social wins on volume
-- and loses on value.
WITH per_customer AS (
    SELECT c.customer_id,
           c.acquisition_channel,
           count(o.order_id)          AS orders,
           sum(o.order_total)         AS lifetime_revenue
    FROM customers c
    LEFT JOIN orders o USING (customer_id)
    GROUP BY 1, 2
)
SELECT acquisition_channel,
       count(*)                                                    AS customers,
       round(100.0 * count(*) FILTER (WHERE orders > 0) / count(*), 1) AS pct_ever_ordered,
       round(avg(orders), 2)                                       AS avg_orders,
       round(avg(lifetime_revenue), 2)                             AS avg_ltv,
       round(median(lifetime_revenue), 2)                          AS median_ltv,
       round(sum(lifetime_revenue), 2)                             AS total_revenue
FROM per_customer
GROUP BY acquisition_channel
ORDER BY avg_ltv DESC NULLS LAST;
