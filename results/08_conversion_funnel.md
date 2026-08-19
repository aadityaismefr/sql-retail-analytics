# 08_conversion_funnel

> Q: Where do we lose people between landing and paying, and does it differ by channel?
> Technique: FILTER-ed aggregates to build a funnel in a single scan.

```sql
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
```

**5 row(s)**

| channel     |   sessions |   viewed |   carted |   ordered |   pct_view |   pct_view_to_cart |   pct_cart_to_order |   pct_overall |
|:------------|-----------:|---------:|---------:|----------:|-----------:|-------------------:|--------------------:|--------------:|
| paid_social |      20328 |    14423 |     5068 |        68 |       71   |               35.1 |                 1.3 |          0.33 |
| paid_search |      14391 |    10281 |     3518 |        72 |       71.4 |               34.2 |                 2   |          0.5  |
| organic     |      13265 |     9425 |     3313 |       117 |       71.1 |               35.2 |                 3.5 |          0.88 |
| referral    |       8408 |     6002 |     2104 |        73 |       71.4 |               35.1 |                 3.5 |          0.87 |
| email       |       5191 |     3708 |     1304 |        36 |       71.4 |               35.2 |                 2.8 |          0.69 |
