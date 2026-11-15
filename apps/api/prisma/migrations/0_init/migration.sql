--
-- PostgreSQL database dump
--

\restrict JMubMyzsg4Nm8bKv067fQk6jdYWqvlD68m2PgcVPldfumYwVTYHfA1AbuDpBJ3D

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: discount_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.discount_type AS ENUM (
    'PERCENT',
    'FIXED'
);


--
-- Name: loyalty_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.loyalty_type AS ENUM (
    'EARN',
    'REDEEM',
    'REVERSAL'
);


--
-- Name: order_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_status AS ENUM (
    'PENDING',
    'PAID',
    'PAYMENT_FAILED',
    'PREPARING',
    'READY',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_status AS ENUM (
    'PENDING',
    'SUCCESS',
    'FAILED'
);


--
-- Name: product_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_size AS ENUM (
    'S',
    'M',
    'L'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    discount_type public.discount_type NOT NULL,
    discount_value numeric(12,2) NOT NULL,
    min_order_value numeric(12,2) DEFAULT 0 NOT NULL,
    max_uses integer NOT NULL,
    used_count integer DEFAULT 0 NOT NULL,
    reserved_count integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    valid_from timestamp with time zone NOT NULL,
    valid_to timestamp with time zone NOT NULL,
    CONSTRAINT chk_coupons_dates CHECK ((valid_to > valid_from)),
    CONSTRAINT chk_coupons_discount CHECK ((((discount_type = 'PERCENT'::public.discount_type) AND (discount_value > (0)::numeric) AND (discount_value <= (100)::numeric)) OR ((discount_type = 'FIXED'::public.discount_type) AND (discount_value > (0)::numeric)))),
    CONSTRAINT chk_coupons_min_order CHECK ((min_order_value >= (0)::numeric)),
    CONSTRAINT chk_coupons_reservations CHECK (((reserved_count >= 0) AND ((used_count + reserved_count) <= max_uses))),
    CONSTRAINT chk_coupons_uses CHECK (((max_uses > 0) AND (used_count >= 0) AND (used_count <= max_uses)))
);


--
-- Name: ingredient_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredient_movements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ingredient_id uuid NOT NULL,
    order_id uuid,
    performed_by uuid,
    movement_type character varying(20) NOT NULL,
    expected_version integer NOT NULL,
    quantity_change numeric(14,3) NOT NULL,
    stock_before numeric(14,3) NOT NULL,
    stock_after numeric(14,3) NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_movement_balance CHECK ((stock_after = (stock_before + quantity_change))),
    CONSTRAINT chk_movement_direction CHECK (((((movement_type)::text = ANY ((ARRAY['OPENING'::character varying, 'RESTOCK'::character varying])::text[])) AND (quantity_change > (0)::numeric)) OR (((movement_type)::text = ANY ((ARRAY['CONSUMPTION'::character varying, 'WASTE'::character varying])::text[])) AND (quantity_change < (0)::numeric)) OR ((movement_type)::text = 'ADJUST'::text))),
    CONSTRAINT chk_movement_order_ref CHECK ((((movement_type)::text <> 'CONSUMPTION'::text) OR (order_id IS NOT NULL))),
    CONSTRAINT ingredient_movements_expected_version_check CHECK ((expected_version >= 0)),
    CONSTRAINT ingredient_movements_movement_type_check CHECK (((movement_type)::text = ANY ((ARRAY['OPENING'::character varying, 'RESTOCK'::character varying, 'CONSUMPTION'::character varying, 'WASTE'::character varying, 'ADJUST'::character varying])::text[]))),
    CONSTRAINT ingredient_movements_quantity_change_check CHECK ((quantity_change <> (0)::numeric)),
    CONSTRAINT ingredient_movements_stock_after_check CHECK ((stock_after >= (0)::numeric)),
    CONSTRAINT ingredient_movements_stock_before_check CHECK ((stock_before >= (0)::numeric))
);


--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(255) NOT NULL,
    unit character varying(10) NOT NULL,
    stock_quantity numeric(14,3) DEFAULT 0 NOT NULL,
    reserved_quantity numeric(14,3) DEFAULT 0 NOT NULL,
    min_stock_quantity numeric(14,3) DEFAULT 0 NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_ingredients_reservations CHECK (((reserved_quantity >= (0)::numeric) AND (reserved_quantity <= stock_quantity))),
    CONSTRAINT ingredients_min_stock_quantity_check CHECK ((min_stock_quantity >= (0)::numeric)),
    CONSTRAINT ingredients_stock_quantity_check CHECK ((stock_quantity >= (0)::numeric)),
    CONSTRAINT ingredients_unit_check CHECK (((unit)::text = ANY ((ARRAY['g'::character varying, 'ml'::character varying, 'cai'::character varying])::text[]))),
    CONSTRAINT ingredients_version_check CHECK ((version >= 0))
);


--
-- Name: loyalty_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loyalty_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    order_id uuid,
    points integer NOT NULL,
    transaction_type public.loyalty_type NOT NULL,
    reverses_transaction_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_loyalty_not_self_reverse CHECK ((reverses_transaction_id IS DISTINCT FROM id)),
    CONSTRAINT chk_loyalty_points_positive CHECK ((points > 0)),
    CONSTRAINT chk_loyalty_reversal_reference CHECK ((((transaction_type = 'REVERSAL'::public.loyalty_type) AND (reverses_transaction_id IS NOT NULL)) OR ((transaction_type <> 'REVERSAL'::public.loyalty_type) AND (reverses_transaction_id IS NULL))))
);


--
-- Name: order_ingredient_reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_ingredient_reservations (
    order_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    quantity numeric(14,3) NOT NULL,
    CONSTRAINT order_ingredient_reservations_quantity_check CHECK ((quantity > (0)::numeric))
);


--
-- Name: order_item_toppings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_item_toppings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_item_id uuid NOT NULL,
    topping_id uuid NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    servings integer DEFAULT 1 NOT NULL,
    CONSTRAINT chk_oit_servings CHECK ((servings > 0)),
    CONSTRAINT chk_oit_unit_price CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    size public.product_size NOT NULL,
    quantity integer NOT NULL,
    base_price numeric(12,2) NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    line_total numeric(12,2) NOT NULL,
    sugar character varying(20) DEFAULT '100%'::character varying NOT NULL,
    ice character varying(20) DEFAULT '100%'::character varying NOT NULL,
    note character varying(250),
    CONSTRAINT chk_order_items_ice CHECK (((ice)::text = ANY ((ARRAY['100%'::character varying, '70%'::character varying, '50%'::character varying, '├ìt ─æ├í'::character varying, '─É├í ri├¬ng'::character varying])::text[]))),
    CONSTRAINT chk_order_items_price CHECK (((base_price >= (0)::numeric) AND (unit_price >= base_price) AND (line_total = (unit_price * (quantity)::numeric)))),
    CONSTRAINT chk_order_items_quantity CHECK ((quantity > 0)),
    CONSTRAINT chk_order_items_sugar CHECK (((sugar)::text = ANY ((ARRAY['100%'::character varying, '70%'::character varying, '50%'::character varying, '30%'::character varying, '├ìt ─æ╞░ß╗¥ng'::character varying])::text[])))
);


--
-- Name: order_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_status_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    from_status public.order_status,
    to_status public.order_status NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by uuid,
    CONSTRAINT chk_history_transition_not_same CHECK ((from_status IS DISTINCT FROM to_status))
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_code integer NOT NULL,
    user_id uuid NOT NULL,
    coupon_id uuid,
    status public.order_status DEFAULT 'PENDING'::public.order_status NOT NULL,
    reservation_status character varying(16) DEFAULT 'NONE'::character varying NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    discount_amount numeric(12,2) DEFAULT 0 NOT NULL,
    points_used integer DEFAULT 0 NOT NULL,
    points_discount_amount numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:20:00'::interval) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    idempotency_key character varying(128),
    request_hash character varying(64),
    CONSTRAINT chk_orders_amounts CHECK (((subtotal >= (0)::numeric) AND (discount_amount >= (0)::numeric) AND (points_used >= 0) AND (points_discount_amount >= (0)::numeric) AND (total >= (0)::numeric) AND ((discount_amount + points_discount_amount) <= subtotal) AND (total = ((subtotal - discount_amount) - points_discount_amount)))),
    CONSTRAINT chk_orders_coupon_discount CHECK (((coupon_id IS NOT NULL) OR (discount_amount = (0)::numeric))),
    CONSTRAINT chk_orders_idempotency_pair CHECK (((idempotency_key IS NULL) = (request_hash IS NULL))),
    CONSTRAINT chk_orders_reservation_status CHECK (((reservation_status)::text = ANY ((ARRAY['NONE'::character varying, 'HELD'::character varying, 'CONSUMED'::character varying, 'RELEASED'::character varying])::text[])))
);


--
-- Name: orders_order_code_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.orders ALTER COLUMN order_code ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_order_code_seq
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment_gateway_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_gateway_transactions (
    payment_id uuid NOT NULL,
    gateway_order_id character varying(128),
    gateway_transaction_id character varying(255),
    provider_ref character varying(255),
    checkout_url character varying(2048),
    qr_content text,
    response_code character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_payment_methods_code CHECK (((length(btrim((code)::text)) > 0) AND ((code)::text = upper((code)::text)))),
    CONSTRAINT chk_payment_methods_name CHECK ((length(btrim((name)::text)) > 0)),
    CONSTRAINT chk_payment_methods_type CHECK (((type)::text = ANY ((ARRAY['GATEWAY'::character varying, 'INTERNAL'::character varying])::text[])))
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    idempotency_key character varying(128) NOT NULL,
    amount numeric(12,2) NOT NULL,
    method_code character varying(20) NOT NULL,
    status public.payment_status NOT NULL,
    paid_at timestamp with time zone,
    refunded_amount numeric(12,2) DEFAULT 0 NOT NULL,
    refunded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_payments_amount CHECK ((amount >= (0)::numeric)),
    CONSTRAINT chk_payments_idempotency CHECK (((length(btrim((idempotency_key)::text)) >= 8) AND (length(btrim((idempotency_key)::text)) <= 128))),
    CONSTRAINT chk_payments_refund CHECK (((refunded_amount >= (0)::numeric) AND (refunded_amount <= amount) AND (((refunded_amount = (0)::numeric) AND (refunded_at IS NULL)) OR ((refunded_amount > (0)::numeric) AND (refunded_at IS NOT NULL))))),
    CONSTRAINT chk_payments_refund_only_success CHECK (((refunded_amount = (0)::numeric) OR (status = 'SUCCESS'::public.payment_status)))
);


--
-- Name: product_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_ingredients (
    product_id uuid NOT NULL,
    size public.product_size NOT NULL,
    ingredient_id uuid NOT NULL,
    quantity numeric(14,3) NOT NULL,
    CONSTRAINT product_ingredients_quantity_check CHECK ((quantity > (0)::numeric))
);


--
-- Name: product_size_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_size_prices (
    product_id uuid NOT NULL,
    size public.product_size NOT NULL,
    price numeric(12,2) NOT NULL,
    CONSTRAINT chk_product_size_prices_price CHECK ((price >= (0)::numeric))
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    category character varying(50) NOT NULL,
    description character varying(1000),
    image_url character varying(500),
    image_key character varying(100),
    version integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_products_category CHECK ((length(btrim((category)::text)) > 0)),
    CONSTRAINT chk_products_code CHECK ((length(btrim((code)::text)) > 0)),
    CONSTRAINT chk_products_version CHECK ((version >= 0))
);


--
-- Name: topping_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topping_ingredients (
    topping_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    quantity numeric(14,3) NOT NULL,
    CONSTRAINT topping_ingredients_quantity_check CHECK ((quantity > (0)::numeric))
);


--
-- Name: toppings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.toppings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(12,2) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_toppings_price CHECK ((price >= (0)::numeric))
);


--
-- Name: user_vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_vouchers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    coupon_id uuid NOT NULL,
    reward_id character varying(30) NOT NULL,
    request_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    used_at timestamp with time zone,
    used_order_id uuid,
    reserved_order_id uuid,
    CONSTRAINT chk_user_voucher_reservation CHECK (((reserved_order_id IS NULL) OR ((used_at IS NULL) AND (used_order_id IS NULL)))),
    CONSTRAINT chk_uv_used CHECK (((used_at IS NULL) = (used_order_id IS NULL)))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(20),
    role character varying(16) DEFAULT 'CUSTOMER'::character varying NOT NULL,
    loyalty_points integer DEFAULT 0 NOT NULL,
    reserved_points integer DEFAULT 0 NOT NULL,
    loyalty_debt integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_url character varying(500),
    favorite_branch character varying(255),
    CONSTRAINT chk_users_fullname CHECK ((length(btrim((full_name)::text)) >= 2)),
    CONSTRAINT chk_users_loyalty CHECK ((loyalty_points >= 0)),
    CONSTRAINT chk_users_reserved_points CHECK (((reserved_points >= 0) AND (reserved_points <= loyalty_points))),
    CONSTRAINT chk_users_role CHECK (((role)::text = ANY (ARRAY[('CUSTOMER'::character varying)::text, ('STAFF'::character varying)::text, ('ADMIN'::character varying)::text]))),
    CONSTRAINT users_loyalty_debt_check CHECK ((loyalty_debt >= 0))
);


--
-- Name: coupons coupons_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_code_key UNIQUE (code);


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- Name: ingredient_movements ingredient_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_movements
    ADD CONSTRAINT ingredient_movements_pkey PRIMARY KEY (id);


--
-- Name: ingredients ingredients_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_code_key UNIQUE (code);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: loyalty_transactions loyalty_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_pkey PRIMARY KEY (id);


--
-- Name: order_ingredient_reservations order_ingredient_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_ingredient_reservations
    ADD CONSTRAINT order_ingredient_reservations_pkey PRIMARY KEY (order_id, ingredient_id);


--
-- Name: order_item_toppings order_item_toppings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_toppings
    ADD CONSTRAINT order_item_toppings_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: order_status_history order_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT order_status_history_pkey PRIMARY KEY (id);


--
-- Name: orders orders_order_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_code_key UNIQUE (order_code);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payment_gateway_transactions payment_gateway_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_gateway_transactions
    ADD CONSTRAINT payment_gateway_transactions_pkey PRIMARY KEY (payment_id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (code);


--
-- Name: payments payments_idempotency_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_idempotency_key UNIQUE (idempotency_key);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: product_ingredients product_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_pkey PRIMARY KEY (product_id, size, ingredient_id);


--
-- Name: product_size_prices product_size_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_size_prices
    ADD CONSTRAINT product_size_prices_pkey PRIMARY KEY (product_id, size);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: topping_ingredients topping_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topping_ingredients
    ADD CONSTRAINT topping_ingredients_pkey PRIMARY KEY (topping_id, ingredient_id);


--
-- Name: toppings toppings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.toppings
    ADD CONSTRAINT toppings_pkey PRIMARY KEY (id);


--
-- Name: order_item_toppings uq_order_item_topping; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_toppings
    ADD CONSTRAINT uq_order_item_topping UNIQUE (order_item_id, topping_id);


--
-- Name: user_vouchers uq_user_vouchers_user_coupon; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT uq_user_vouchers_user_coupon UNIQUE (user_id, coupon_id);


--
-- Name: user_vouchers user_vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT user_vouchers_pkey PRIMARY KEY (id);


--
-- Name: user_vouchers user_vouchers_request_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT user_vouchers_request_id_key UNIQUE (request_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_loyalty_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_loyalty_user ON public.loyalty_transactions USING btree (user_id);


--
-- Name: idx_movements_ingredient_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_ingredient_date ON public.ingredient_movements USING btree (ingredient_id, created_at);


--
-- Name: idx_movements_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_order ON public.ingredient_movements USING btree (order_id);


--
-- Name: idx_movements_performed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_performed_by ON public.ingredient_movements USING btree (performed_by);


--
-- Name: idx_oit_order_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oit_order_item ON public.order_item_toppings USING btree (order_item_id);


--
-- Name: idx_order_ingredient_reservations_ingredient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_ingredient_reservations_ingredient ON public.order_ingredient_reservations USING btree (ingredient_id);


--
-- Name: idx_order_items_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_order ON public.order_items USING btree (order_id);


--
-- Name: idx_order_items_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_product ON public.order_items USING btree (product_id);


--
-- Name: idx_orders_coupon; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_coupon ON public.orders USING btree (coupon_id);


--
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- Name: idx_orders_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_user_created ON public.orders USING btree (user_id, created_at);


--
-- Name: idx_payments_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_order ON public.payments USING btree (order_id);


--
-- Name: idx_recipe_ingredient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipe_ingredient ON public.product_ingredients USING btree (ingredient_id);


--
-- Name: idx_status_history_changed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_history_changed_by ON public.order_status_history USING btree (changed_by);


--
-- Name: idx_status_history_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_history_order ON public.order_status_history USING btree (order_id);


--
-- Name: idx_topping_recipe_ingredient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_topping_recipe_ingredient ON public.topping_ingredients USING btree (ingredient_id);


--
-- Name: idx_user_vouchers_reserved_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_vouchers_reserved_order ON public.user_vouchers USING btree (reserved_order_id);


--
-- Name: idx_user_vouchers_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_vouchers_user ON public.user_vouchers USING btree (user_id);


--
-- Name: ux_loyalty_order_transaction_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_loyalty_order_transaction_type ON public.loyalty_transactions USING btree (order_id, transaction_type) WHERE ((order_id IS NOT NULL) AND (transaction_type = ANY (ARRAY['EARN'::public.loyalty_type, 'REDEEM'::public.loyalty_type])));


--
-- Name: ux_loyalty_reversal_origin; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_loyalty_reversal_origin ON public.loyalty_transactions USING btree (reverses_transaction_id) WHERE (reverses_transaction_id IS NOT NULL);


--
-- Name: ux_one_consumption_per_ingredient_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_one_consumption_per_ingredient_order ON public.ingredient_movements USING btree (order_id, ingredient_id) WHERE (((movement_type)::text = 'CONSUMPTION'::text) AND (order_id IS NOT NULL));


--
-- Name: ux_one_opening_per_ingredient; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_one_opening_per_ingredient ON public.ingredient_movements USING btree (ingredient_id) WHERE ((movement_type)::text = 'OPENING'::text);


--
-- Name: ux_orders_idempotency_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_orders_idempotency_key ON public.orders USING btree (idempotency_key);


--
-- Name: ux_payment_gateway_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_payment_gateway_order_id ON public.payment_gateway_transactions USING btree (gateway_order_id);


--
-- Name: ux_payment_gateway_provider_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_payment_gateway_provider_ref ON public.payment_gateway_transactions USING btree (provider_ref);


--
-- Name: ux_payment_gateway_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_payment_gateway_transaction_id ON public.payment_gateway_transactions USING btree (gateway_transaction_id);


--
-- Name: ux_payments_one_pending_per_method_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_payments_one_pending_per_method_order ON public.payments USING btree (order_id, method_code) WHERE (status = 'PENDING'::public.payment_status);


--
-- Name: ux_payments_one_success_per_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_payments_one_success_per_order ON public.payments USING btree (order_id) WHERE (status = 'SUCCESS'::public.payment_status);


--
-- Name: ux_products_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_products_code ON public.products USING btree (code);


--
-- Name: ux_products_image_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_products_image_key ON public.products USING btree (image_key);


--
-- Name: ux_toppings_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_toppings_code ON public.toppings USING btree (code);


--
-- Name: ux_user_vouchers_used_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_user_vouchers_used_order ON public.user_vouchers USING btree (used_order_id) WHERE (used_order_id IS NOT NULL);


--
-- Name: ux_users_email_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_users_email_lower ON public.users USING btree (lower((email)::text));


--
-- Name: loyalty_transactions fk_loyalty_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT fk_loyalty_order FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: loyalty_transactions fk_loyalty_reverses; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT fk_loyalty_reverses FOREIGN KEY (reverses_transaction_id) REFERENCES public.loyalty_transactions(id) ON DELETE RESTRICT;


--
-- Name: loyalty_transactions fk_loyalty_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT fk_loyalty_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: order_item_toppings fk_oit_order_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_toppings
    ADD CONSTRAINT fk_oit_order_item FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON DELETE CASCADE;


--
-- Name: order_item_toppings fk_oit_topping; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_toppings
    ADD CONSTRAINT fk_oit_topping FOREIGN KEY (topping_id) REFERENCES public.toppings(id);


--
-- Name: order_items fk_order_items_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items fk_order_items_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: order_items fk_order_items_valid_size; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_valid_size FOREIGN KEY (product_id, size) REFERENCES public.product_size_prices(product_id, size);


--
-- Name: order_status_history fk_order_status_history_changed_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT fk_order_status_history_changed_by FOREIGN KEY (changed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: order_status_history fk_order_status_history_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders fk_orders_coupon; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_coupon FOREIGN KEY (coupon_id) REFERENCES public.coupons(id);


--
-- Name: orders fk_orders_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_gateway_transactions fk_payment_gateway_payment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_gateway_transactions
    ADD CONSTRAINT fk_payment_gateway_payment FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE CASCADE;


--
-- Name: payments fk_payments_method; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_method FOREIGN KEY (method_code) REFERENCES public.payment_methods(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: payments fk_payments_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: product_size_prices fk_psp_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_size_prices
    ADD CONSTRAINT fk_psp_product FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_ingredients fk_recipe_ingredient; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT fk_recipe_ingredient FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- Name: product_ingredients fk_recipe_product_size; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT fk_recipe_product_size FOREIGN KEY (product_id, size) REFERENCES public.product_size_prices(product_id, size) ON DELETE CASCADE;


--
-- Name: topping_ingredients fk_topping_recipe_ingredient; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topping_ingredients
    ADD CONSTRAINT fk_topping_recipe_ingredient FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- Name: topping_ingredients fk_topping_recipe_topping; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topping_ingredients
    ADD CONSTRAINT fk_topping_recipe_topping FOREIGN KEY (topping_id) REFERENCES public.toppings(id) ON DELETE CASCADE;


--
-- Name: user_vouchers fk_uv_coupon; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT fk_uv_coupon FOREIGN KEY (coupon_id) REFERENCES public.coupons(id);


--
-- Name: user_vouchers fk_uv_reserved_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT fk_uv_reserved_order FOREIGN KEY (reserved_order_id) REFERENCES public.orders(id);


--
-- Name: user_vouchers fk_uv_used_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT fk_uv_used_order FOREIGN KEY (used_order_id) REFERENCES public.orders(id);


--
-- Name: user_vouchers fk_uv_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_vouchers
    ADD CONSTRAINT fk_uv_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ingredient_movements ingredient_movements_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_movements
    ADD CONSTRAINT ingredient_movements_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- Name: ingredient_movements ingredient_movements_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_movements
    ADD CONSTRAINT ingredient_movements_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE RESTRICT;


--
-- Name: ingredient_movements ingredient_movements_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_movements
    ADD CONSTRAINT ingredient_movements_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: order_ingredient_reservations order_ingredient_reservations_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_ingredient_reservations
    ADD CONSTRAINT order_ingredient_reservations_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE RESTRICT;


--
-- Name: order_ingredient_reservations order_ingredient_reservations_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_ingredient_reservations
    ADD CONSTRAINT order_ingredient_reservations_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict JMubMyzsg4Nm8bKv067fQk6jdYWqvlD68m2PgcVPldfumYwVTYHfA1AbuDpBJ3D

