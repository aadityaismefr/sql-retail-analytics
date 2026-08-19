-- Q: Where do we lose people between landing and paying, and does it differ by channel?
-- Technique: FILTER-ed aggregates to build a funnel in a single scan.
SELECT channel,
       count(*)                                                 AS sessions,
       count(*) FILTER (WHERE viewed_product)                   AS viewed,
       count(*) FILTER (WHERE added_to_cart)                    AS carted,
       count(*) FILTER (WHERE placed_order)                     AS ordered,
       round(100.0 * count(*) FILTER (WHERE viewed_product) / count(*), 1)                          AS pct_view,
       round(100.0 * count(*) FILTER (WHERE added_to_cart)
             / nullif(count(*) FILTER (WHERE viewed_product), 0), 1)                                AS pct_view_to_cart,
       round(100.0 * count(*) FILTER (WHERE placed_order)
             / nullif(count(*) FILTER (WHERE added_to_cart), 0), 1)                                 AS pct_cart_to_order,
       round(100.0 * count(*) FILTER (WHERE placed_order) / count(*), 2)                            AS pct_overall
FROM sessions
GROUP BY channel
ORDER BY sessions DESC;
