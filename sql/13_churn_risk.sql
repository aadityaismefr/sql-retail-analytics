-- Q: How much revenue sits with customers who have gone quiet for 90+ days?
-- Technique: HAVING on an aggregate + conditional bucketing.
WITH last_seen AS (
    SELECT c.customer_id,
           c.acquisition_channel,
           max(o.order_date)                                     AS last_order,
           date_diff('day', max(o.order_date), DATE '2025-12-31') AS days_since,
           sum(o.order_total)                                    AS lifetime_revenue
    FROM customers c JOIN orders o USING (customer_id)
    GROUP BY 1, 2
)
SELECT CASE WHEN days_since <= 30  THEN '0-30 days'
            WHEN days_since <= 90  THEN '31-90 days'
            WHEN days_since <= 180 THEN '91-180 days'
            WHEN days_since <= 365 THEN '181-365 days'
            ELSE '365+ days' END                     AS recency_bucket,
       count(*)                                      AS customers,
       round(sum(lifetime_revenue), 2)               AS revenue_at_stake,
       round(avg(lifetime_revenue), 2)               AS avg_ltv
FROM last_seen
GROUP BY 1
ORDER BY min(days_since);
