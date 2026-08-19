"""
Generate a synthetic but realistically-shaped e-commerce dataset.

The data is SYNTHETIC. It is generated with deliberate structure so that the
analytical queries in ../sql have something meaningful to find:

  * seasonality      - Q4 uplift, summer dip
  * channel quality  - paid_social acquires cheap, low-LTV customers;
                       organic/referral acquire fewer, better ones
  * cohort decay     - retention decays geometrically, later cohorts retain worse
  * pareto skew      - a small share of customers drives most revenue
  * funnel drop-off  - view -> cart -> order at realistic conversion rates

Run:  python data/generate_data.py
Out:  data/retail.duckdb
"""

from __future__ import annotations

import math
import random
from datetime import date, timedelta
from pathlib import Path

import duckdb
import pandas as pd

SEED = 42
START = date(2024, 1, 1)
END = date(2025, 12, 31)
N_CUSTOMERS = 6_000

HERE = Path(__file__).resolve().parent
DB_PATH = HERE / "retail.duckdb"

random.seed(SEED)

CHANNELS = {
    #  name          share  ltv_mult  retention_mult
    "paid_social": (0.34, 0.72, 0.75),
    "paid_search": (0.24, 1.00, 0.95),
    "organic":     (0.21, 1.35, 1.30),
    "referral":    (0.13, 1.45, 1.35),
    "email":       (0.08, 1.15, 1.20),
}

CATEGORIES = {
    #  name         n_products  price_lo  price_hi  margin
    "Coffee":        (14,  8.0,   34.0, 0.42),
    "Brewing Gear":  (10, 24.0,  189.0, 0.35),
    "Grinders":      (6,  49.0,  429.0, 0.31),
    "Accessories":   (18,  4.0,   59.0, 0.55),
    "Subscriptions": (4,  19.0,   79.0, 0.61),
}

COUNTRIES = [("DE", 0.58), ("AT", 0.12), ("CH", 0.10), ("NL", 0.08),
             ("FR", 0.07), ("IT", 0.05)]


def weighted_choice(pairs):
    r, acc = random.random(), 0.0
    for name, w in pairs:
        acc += w
        if r <= acc:
            return name
    return pairs[-1][0]


def season_factor(d: date) -> float:
    """Q4 uplift, August dip."""
    m = d.month
    base = {1: 0.86, 2: 0.84, 3: 0.95, 4: 0.98, 5: 1.00, 6: 0.95,
            7: 0.88, 8: 0.78, 9: 1.02, 10: 1.12, 11: 1.38, 12: 1.30}[m]
    # gentle year-over-year growth
    growth = 1.0 + 0.18 * ((d.year - START.year) + (m - 1) / 12)
    return base * growth


def build_products():
    rows, pid = [], 1
    for cat, (n, lo, hi, margin) in CATEGORIES.items():
        for i in range(n):
            # log-uniform price so cheap items dominate by count
            price = round(math.exp(random.uniform(math.log(lo), math.log(hi))), 2)
            rows.append((pid, f"{cat[:3].upper()}-{i + 1:03d}", cat,
                         round(price, 2), round(margin + random.uniform(-.06, .06), 3)))
            pid += 1
    return rows


def build_customers():
    rows = []
    span = (END - START).days
    for cid in range(1, N_CUSTOMERS + 1):
        # signups accelerate over time
        u = random.random() ** 0.78
        signup = START + timedelta(days=int(u * span))
        channel = weighted_choice([(c, v[0]) for c, v in CHANNELS.items()])
        rows.append((cid, signup, channel, weighted_choice(COUNTRIES)))
    return rows


def build_orders(customers, products):
    """Each customer gets a geometric-ish number of orders, decayed by cohort age."""
    orders, items = [], []
    oid, iid = 1, 1
    prod_by_cat = {}
    for p in products:
        prod_by_cat.setdefault(p[2], []).append(p)

    for cid, signup, channel, country in customers:
        _, ltv_mult, ret_mult = CHANNELS[channel]
        # heavy tail: a few customers order a lot
        spend_power = random.lognormvariate(0, 0.62) * ltv_mult

        # A large share of signups never convert at all, and the share is
        # worse for the cheap paid channels. This is what makes query 06
        # (LTV by channel) interesting rather than tautological.
        if random.random() > min(0.92, 0.46 * ret_mult):
            continue

        p_repeat = min(0.74, 0.40 * ret_mult * (0.85 + 0.3 * random.random()))

        order_date = signup + timedelta(days=random.randint(0, 6))
        n = 0
        while order_date <= END and n < 26:
            n += 1
            sf = season_factor(order_date)
            n_lines = 1 + int(random.random() ** 1.9 * 4)
            discount = 0.0
            if random.random() < 0.22:
                discount = random.choice([0.05, 0.10, 0.15, 0.20])

            line_rows = []
            for _ in range(n_lines):
                cat = weighted_choice([("Coffee", .42), ("Accessories", .22),
                                       ("Brewing Gear", .16), ("Grinders", .08),
                                       ("Subscriptions", .12)])
                p = random.choice(prod_by_cat[cat])
                qty = 1 + int(random.random() ** 2.6 * 3)
                unit = round(p[3] * random.uniform(0.97, 1.03) * min(1.6, spend_power ** 0.35), 2)
                line_rows.append((iid, oid, p[0], qty, unit, discount))
                iid += 1

            gross = sum(q * u for _, _, _, q, u, _ in line_rows)
            orders.append((oid, cid, order_date, channel, round(discount, 2),
                           round(gross * (1 - discount), 2)))
            items.extend(line_rows)
            oid += 1

            # decide on a repeat order
            if random.random() > p_repeat * (0.93 ** n) * min(1.4, sf):
                break
            gap = int(random.lognormvariate(math.log(46), 0.75))
            order_date += timedelta(days=max(4, gap))

    return orders, items


def build_sessions(customers, orders):
    """Funnel events. Orders are a subset of sessions that converted."""
    by_cust_date = {}
    for oid, cid, d, ch, _, _ in orders:
        by_cust_date.setdefault((cid, d), oid)

    rows, sid = [], 1
    span = (END - START).days
    for cid, signup, channel, _country in customers:
        n_sessions = 2 + int(random.random() ** 1.5 * 22)
        for _ in range(n_sessions):
            d = signup + timedelta(days=int(random.random() * max(1, (END - signup).days or 1)))
            if d > END:
                continue
            viewed = random.random() < 0.71
            carted = viewed and random.random() < 0.34
            oid = by_cust_date.get((cid, d))
            ordered = bool(oid) and carted
            if bool(oid) and not carted:      # keep funnel consistent
                carted = viewed = True
                ordered = True
            rows.append((sid, cid, d, channel, viewed, carted, ordered,
                         oid if ordered else None))
            sid += 1
    return rows


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()
    con = duckdb.connect(str(DB_PATH))

    products = build_products()
    customers = build_customers()
    orders, items = build_orders(customers, products)
    sessions = build_sessions(customers, orders)

    con.execute(open(HERE.parent / "sql" / "00_schema.sql").read())

    frames = {
        "products":    pd.DataFrame(products, columns=[
            "product_id", "sku", "category", "list_price", "margin_rate"]),
        "customers":   pd.DataFrame(customers, columns=[
            "customer_id", "signup_date", "acquisition_channel", "country"]),
        "orders":      pd.DataFrame(orders, columns=[
            "order_id", "customer_id", "order_date", "channel",
            "discount_rate", "order_total"]),
        "order_items": pd.DataFrame(items, columns=[
            "order_item_id", "order_id", "product_id", "quantity",
            "unit_price", "discount_rate"]),
        "sessions":    pd.DataFrame(sessions, columns=[
            "session_id", "customer_id", "session_date", "channel",
            "viewed_product", "added_to_cart", "placed_order", "order_id"]),
    }
    for name, df in frames.items():
        con.register(f"_{name}", df)
        con.execute(f"INSERT INTO {name} SELECT * FROM _{name}")

    for t in ("customers", "products", "orders", "order_items", "sessions"):
        n = con.execute(f"SELECT count(*) FROM {t}").fetchone()[0]
        print(f"{t:>12}: {n:,}")
    con.close()
    print(f"\nwrote {DB_PATH}")


if __name__ == "__main__":
    main()
