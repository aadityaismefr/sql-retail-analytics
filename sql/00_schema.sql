-- Schema for the synthetic coffee-retail dataset.
-- DuckDB dialect; the SQL in this repo is standard enough to run on
-- Postgres with only trivial changes (noted where they apply).

CREATE TABLE customers (
    customer_id      INTEGER PRIMARY KEY,
    signup_date      DATE      NOT NULL,
    acquisition_channel VARCHAR NOT NULL,   -- paid_social | paid_search | organic | referral | email
    country          VARCHAR   NOT NULL
);

CREATE TABLE products (
    product_id   INTEGER PRIMARY KEY,
    sku          VARCHAR NOT NULL,
    category     VARCHAR NOT NULL,
    list_price   DECIMAL(10,2) NOT NULL,
    margin_rate  DECIMAL(5,3)  NOT NULL     -- gross margin as a fraction of price
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date    DATE    NOT NULL,
    channel       VARCHAR NOT NULL,
    discount_rate DECIMAL(4,2) NOT NULL,    -- 0.00 - 0.20
    order_total   DECIMAL(12,2) NOT NULL    -- net of discount
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL REFERENCES orders(order_id),
    product_id    INTEGER NOT NULL REFERENCES products(product_id),
    quantity      INTEGER NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(4,2) NOT NULL
);

CREATE TABLE sessions (
    session_id     INTEGER PRIMARY KEY,
    customer_id    INTEGER NOT NULL REFERENCES customers(customer_id),
    session_date   DATE    NOT NULL,
    channel        VARCHAR NOT NULL,
    viewed_product BOOLEAN NOT NULL,
    added_to_cart  BOOLEAN NOT NULL,
    placed_order   BOOLEAN NOT NULL,
    order_id       INTEGER
);
