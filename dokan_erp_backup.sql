--
-- PostgreSQL database dump
--

\restrict B8GZS2xgbHNr4g6CCuELT754gr7UEIpv0Y47sHx4mYiNFUaG2jQ6jazLHsIFGiE

-- Dumped from database version 18.4 (Homebrew)
-- Dumped by pg_dump version 18.4 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS '';


--
-- Name: AppType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."AppType" AS ENUM (
    'WEB',
    'MOBILE'
);


ALTER TYPE public."AppType" OWNER TO macbookair;

--
-- Name: BankAccountStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."BankAccountStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'CLOSED'
);


ALTER TYPE public."BankAccountStatus" OWNER TO macbookair;

--
-- Name: BankAccountType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."BankAccountType" AS ENUM (
    'CURRENT',
    'SAVINGS'
);


ALTER TYPE public."BankAccountType" OWNER TO macbookair;

--
-- Name: BarcodeStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."BarcodeStatus" AS ENUM (
    'MAPPED',
    'UNMAPPED',
    'ARCHIVED'
);


ALTER TYPE public."BarcodeStatus" OWNER TO macbookair;

--
-- Name: BrandStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."BrandStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."BrandStatus" OWNER TO macbookair;

--
-- Name: CategoryLogAction; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."CategoryLogAction" AS ENUM (
    'CREATED',
    'UPDATED',
    'STATUS_CHANGED',
    'ARCHIVED',
    'RESTORED',
    'DELETE_BLOCKED'
);


ALTER TYPE public."CategoryLogAction" OWNER TO macbookair;

--
-- Name: CategoryStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."CategoryStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."CategoryStatus" OWNER TO macbookair;

--
-- Name: CustomerLedgerEntryType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."CustomerLedgerEntryType" AS ENUM (
    'OPENING_DUE',
    'SALE',
    'PAYMENT',
    'ADJUSTMENT'
);


ALTER TYPE public."CustomerLedgerEntryType" OWNER TO macbookair;

--
-- Name: CustomerStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."CustomerStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."CustomerStatus" OWNER TO macbookair;

--
-- Name: InventoryBinStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."InventoryBinStatus" AS ENUM (
    'EMPTY',
    'LOW',
    'FULL',
    'EXPIRED'
);


ALTER TYPE public."InventoryBinStatus" OWNER TO macbookair;

--
-- Name: InventoryMode; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."InventoryMode" AS ENUM (
    'GENERAL',
    'RACK'
);


ALTER TYPE public."InventoryMode" OWNER TO macbookair;

--
-- Name: InvoiceStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."InvoiceStatus" AS ENUM (
    'UNPAID',
    'PAID',
    'PARTIAL',
    'OVERDUE',
    'CANCELLED'
);


ALTER TYPE public."InvoiceStatus" OWNER TO macbookair;

--
-- Name: MasterProductRequestStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."MasterProductRequestStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."MasterProductRequestStatus" OWNER TO macbookair;

--
-- Name: MasterProductStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."MasterProductStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."MasterProductStatus" OWNER TO macbookair;

--
-- Name: MoneyBoxStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."MoneyBoxStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE'
);


ALTER TYPE public."MoneyBoxStatus" OWNER TO macbookair;

--
-- Name: MoneyBoxType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."MoneyBoxType" AS ENUM (
    'CASH',
    'BKASH',
    'NAGAD'
);


ALTER TYPE public."MoneyBoxType" OWNER TO macbookair;

--
-- Name: OtpChannel; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."OtpChannel" AS ENUM (
    'SMS',
    'WHATSAPP',
    'EMAIL'
);


ALTER TYPE public."OtpChannel" OWNER TO macbookair;

--
-- Name: OtpPurpose; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."OtpPurpose" AS ENUM (
    'LOGIN',
    'REGISTRATION',
    'PASSWORD_RESET',
    'PIN_SETUP'
);


ALTER TYPE public."OtpPurpose" OWNER TO macbookair;

--
-- Name: OtpStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."OtpStatus" AS ENUM (
    'PENDING',
    'VERIFIED',
    'EXPIRED',
    'CONSUMED',
    'CANCELLED'
);


ALTER TYPE public."OtpStatus" OWNER TO macbookair;

--
-- Name: PasswordResetStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."PasswordResetStatus" AS ENUM (
    'PENDING',
    'COMPLETED',
    'EXPIRED',
    'CANCELLED'
);


ALTER TYPE public."PasswordResetStatus" OWNER TO macbookair;

--
-- Name: PaymentStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."PaymentStatus" AS ENUM (
    'PENDING',
    'SUCCESS',
    'FAILED',
    'CANCELLED'
);


ALTER TYPE public."PaymentStatus" OWNER TO macbookair;

--
-- Name: PlatformRole; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."PlatformRole" AS ENUM (
    'SUPER_ADMIN',
    'ADMIN'
);


ALTER TYPE public."PlatformRole" OWNER TO macbookair;

--
-- Name: ProductTemplateStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."ProductTemplateStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."ProductTemplateStatus" OWNER TO macbookair;

--
-- Name: PurchaseReturnStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."PurchaseReturnStatus" AS ENUM (
    'PENDING_APPROVAL',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."PurchaseReturnStatus" OWNER TO macbookair;

--
-- Name: PurchaseStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."PurchaseStatus" AS ENUM (
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."PurchaseStatus" OWNER TO macbookair;

--
-- Name: RegistrationDraftStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."RegistrationDraftStatus" AS ENUM (
    'PENDING',
    'OTP_SENT',
    'OTP_VERIFIED',
    'PIN_SET',
    'COMPLETED',
    'CANCELLED',
    'EXPIRED'
);


ALTER TYPE public."RegistrationDraftStatus" OWNER TO macbookair;

--
-- Name: ShopProductSource; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."ShopProductSource" AS ENUM (
    'MASTER',
    'SHOP_LOCAL'
);


ALTER TYPE public."ShopProductSource" OWNER TO macbookair;

--
-- Name: ShopRole; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."ShopRole" AS ENUM (
    'SHOP_OWNER',
    'SALESMAN'
);


ALTER TYPE public."ShopRole" OWNER TO macbookair;

--
-- Name: ShopStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."ShopStatus" AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'GRACE',
    'BLOCKED'
);


ALTER TYPE public."ShopStatus" OWNER TO macbookair;

--
-- Name: SubscriptionStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."SubscriptionStatus" AS ENUM (
    'TRIAL',
    'ACTIVE',
    'GRACE',
    'SUSPENDED',
    'CANCELLED'
);


ALTER TYPE public."SubscriptionStatus" OWNER TO macbookair;

--
-- Name: SupplierLedgerEntryType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."SupplierLedgerEntryType" AS ENUM (
    'OPENING_DUE',
    'PURCHASE',
    'PAYMENT',
    'ADJUSTMENT',
    'PURCHASE_RETURN'
);


ALTER TYPE public."SupplierLedgerEntryType" OWNER TO macbookair;

--
-- Name: SupplierStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."SupplierStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."SupplierStatus" OWNER TO macbookair;

--
-- Name: UnitStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."UnitStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."UnitStatus" OWNER TO macbookair;

--
-- Name: UnitType; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."UnitType" AS ENUM (
    'COUNTABLE',
    'WEIGHT',
    'VOLUME',
    'PACKAGING',
    'LENGTH',
    'AREA'
);


ALTER TYPE public."UnitType" OWNER TO macbookair;

--
-- Name: UserPinStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."UserPinStatus" AS ENUM (
    'ACTIVE',
    'RESET_REQUIRED',
    'LOCKED',
    'DISABLED'
);


ALTER TYPE public."UserPinStatus" OWNER TO macbookair;

--
-- Name: UserStatus; Type: TYPE; Schema: public; Owner: macbookair
--

CREATE TYPE public."UserStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED'
);


ALTER TYPE public."UserStatus" OWNER TO macbookair;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.bank_accounts (
    id text NOT NULL,
    shop_id text NOT NULL,
    account_name character varying(160) NOT NULL,
    bank_name character varying(160) NOT NULL,
    branch_name character varying(160),
    account_number character varying(80) NOT NULL,
    account_type public."BankAccountType" NOT NULL,
    opening_balance numeric(12,2) DEFAULT 0 NOT NULL,
    current_balance numeric(12,2) DEFAULT 0 NOT NULL,
    currency character varying(10) DEFAULT 'BDT'::character varying NOT NULL,
    status public."BankAccountStatus" DEFAULT 'ACTIVE'::public."BankAccountStatus" NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.bank_accounts OWNER TO macbookair;

--
-- Name: brands; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.brands (
    id text NOT NULL,
    name character varying(120) NOT NULL,
    description text,
    logo_url text,
    status public."BrandStatus" DEFAULT 'ACTIVE'::public."BrandStatus" NOT NULL,
    created_by text,
    updated_by text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.brands OWNER TO macbookair;

--
-- Name: category_logs; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.category_logs (
    id text NOT NULL,
    category_id text NOT NULL,
    action public."CategoryLogAction" NOT NULL,
    old_data jsonb,
    new_data jsonb,
    performed_by text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.category_logs OWNER TO macbookair;

--
-- Name: customer_ledgers; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.customer_ledgers (
    id text NOT NULL,
    shop_id text NOT NULL,
    customer_id text NOT NULL,
    entry_type public."CustomerLedgerEntryType" NOT NULL,
    customer_sale_id text,
    customer_payment_id text,
    reference_no character varying(80),
    debit numeric(10,2) DEFAULT 0 NOT NULL,
    credit numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    entry_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.customer_ledgers OWNER TO macbookair;

--
-- Name: customer_payments; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.customer_payments (
    id text NOT NULL,
    shop_id text NOT NULL,
    customer_id text NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(50),
    money_box_id character varying(80),
    reference_no character varying(80),
    notes text,
    paid_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_meta jsonb
);


ALTER TABLE public.customer_payments OWNER TO macbookair;

--
-- Name: customer_sale_items; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.customer_sale_items (
    id text NOT NULL,
    customer_sale_id text NOT NULL,
    master_product_id text NOT NULL,
    quantity numeric(12,3) NOT NULL,
    sale_price numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    batch_no character varying(80),
    purchase_price numeric(10,2)
);


ALTER TABLE public.customer_sale_items OWNER TO macbookair;

--
-- Name: customer_sales; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.customer_sales (
    id text NOT NULL,
    shop_id text NOT NULL,
    customer_id text NOT NULL,
    invoice_no character varying(80),
    sale_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    paid_amount numeric(10,2) DEFAULT 0 NOT NULL,
    due_amount numeric(10,2) DEFAULT 0 NOT NULL,
    payment_method character varying(50),
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    cancel_notes text,
    cancel_reason text,
    cancelled_at timestamp(3) without time zone,
    refund_amount numeric(10,2) DEFAULT 0 NOT NULL,
    refund_method character varying(50),
    status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_by_user_id text,
    charge_amount numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(10,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.customer_sales OWNER TO macbookair;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.customers (
    id text NOT NULL,
    customer_code character varying(50) NOT NULL,
    name character varying(160) NOT NULL,
    mobile character varying(30),
    email character varying(150),
    address text,
    notes text,
    status public."CustomerStatus" DEFAULT 'ACTIVE'::public."CustomerStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone,
    store_credit numeric(10,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.customers OWNER TO macbookair;

--
-- Name: expenses; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.expenses (
    id text NOT NULL,
    shop_id text NOT NULL,
    category character varying(80) NOT NULL,
    amount numeric(10,2) NOT NULL,
    expense_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    description text,
    payment_method character varying(30),
    money_box_id character varying(80),
    bank_account_id text,
    status character varying(30) DEFAULT 'PAID'::character varying NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.expenses OWNER TO macbookair;

--
-- Name: in_app_notifications; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.in_app_notifications (
    id text NOT NULL,
    shop_id text NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    "timestamp" text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_read boolean DEFAULT false NOT NULL
);


ALTER TABLE public.in_app_notifications OWNER TO macbookair;

--
-- Name: inventory_bin_items; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.inventory_bin_items (
    id text NOT NULL,
    shop_id text NOT NULL,
    bin_id text NOT NULL,
    master_product_id text NOT NULL,
    purchase_item_id text,
    quantity numeric(12,3) NOT NULL,
    batch_no character varying(80),
    expiry_date timestamp(3) without time zone,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    purchase_price numeric(10,2),
    sale_price numeric(10,2)
);


ALTER TABLE public.inventory_bin_items OWNER TO macbookair;

--
-- Name: inventory_bins; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.inventory_bins (
    id text NOT NULL,
    shop_id text NOT NULL,
    zone_id text NOT NULL,
    rack_id text NOT NULL,
    shelf_id text NOT NULL,
    code character varying(80) NOT NULL,
    product_name character varying(160),
    status public."InventoryBinStatus" DEFAULT 'EMPTY'::public."InventoryBinStatus" NOT NULL,
    quantity_label character varying(40),
    days_label character varying(40),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.inventory_bins OWNER TO macbookair;

--
-- Name: inventory_racks; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.inventory_racks (
    id text NOT NULL,
    shop_id text NOT NULL,
    zone_id text NOT NULL,
    name character varying(120) NOT NULL,
    note text,
    shelf_count integer DEFAULT 0 NOT NULL,
    total_bins integer DEFAULT 0 NOT NULL,
    used_bins integer DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.inventory_racks OWNER TO macbookair;

--
-- Name: inventory_shelves; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.inventory_shelves (
    id text NOT NULL,
    shop_id text NOT NULL,
    zone_id text NOT NULL,
    rack_id text NOT NULL,
    name character varying(120) NOT NULL,
    total_bins integer DEFAULT 0 NOT NULL,
    used_bins integer DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.inventory_shelves OWNER TO macbookair;

--
-- Name: inventory_zones; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.inventory_zones (
    id text NOT NULL,
    shop_id text NOT NULL,
    name character varying(120) NOT NULL,
    subtitle character varying(255),
    icon character varying(40),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.inventory_zones OWNER TO macbookair;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.invoices (
    id text NOT NULL,
    subscription_id text NOT NULL,
    shop_id text NOT NULL,
    billing_date timestamp(3) without time zone NOT NULL,
    billable_accounts integer NOT NULL,
    rate_per_account numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    paid_amount numeric(10,2) DEFAULT 0 NOT NULL,
    status public."InvoiceStatus" DEFAULT 'UNPAID'::public."InvoiceStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.invoices OWNER TO macbookair;

--
-- Name: master_product_barcodes; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.master_product_barcodes (
    id text NOT NULL,
    master_product_id text,
    barcode character varying(80) NOT NULL,
    pack_size character varying(80),
    status public."BarcodeStatus" DEFAULT 'UNMAPPED'::public."BarcodeStatus" NOT NULL,
    created_by text,
    updated_by text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.master_product_barcodes OWNER TO macbookair;

--
-- Name: master_product_requests; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.master_product_requests (
    id text NOT NULL,
    shop_id text NOT NULL,
    shop_product_id text,
    created_by_user_id text,
    reviewed_by_user_id text,
    master_product_id text,
    name character varying(160) NOT NULL,
    category character varying(120),
    brand character varying(120),
    unit character varying(60),
    barcode character varying(120),
    "pictureUrl" text,
    purchase_price numeric(10,2),
    sale_price numeric(10,2),
    opening_stock numeric(12,3) DEFAULT 0 NOT NULL,
    low_stock_limit numeric(12,3) DEFAULT 0 NOT NULL,
    status public."MasterProductRequestStatus" DEFAULT 'PENDING'::public."MasterProductRequestStatus" NOT NULL,
    rejection_reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.master_product_requests OWNER TO macbookair;

--
-- Name: master_products; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.master_products (
    id text NOT NULL,
    sku character varying(60) NOT NULL,
    name character varying(160) NOT NULL,
    description text,
    category_id text,
    status public."MasterProductStatus" DEFAULT 'ACTIVE'::public."MasterProductStatus" NOT NULL,
    created_by text,
    updated_by text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    brand_id text,
    package_size character varying(80),
    picture_url text,
    price numeric(10,2),
    suggested_price numeric(10,2),
    unit_id text
);


ALTER TABLE public.master_products OWNER TO macbookair;

--
-- Name: money_boxes; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.money_boxes (
    id character varying(80) NOT NULL,
    shop_id text NOT NULL,
    box_name character varying(150) NOT NULL,
    code character varying(80) NOT NULL,
    type public."MoneyBoxType" NOT NULL,
    opening_balance numeric(12,2) DEFAULT 0 NOT NULL,
    current_balance numeric(12,2) DEFAULT 0 NOT NULL,
    details text,
    status public."MoneyBoxStatus" DEFAULT 'ACTIVE'::public."MoneyBoxStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.money_boxes OWNER TO macbookair;

--
-- Name: notification_settings; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.notification_settings (
    id text NOT NULL,
    shop_id text NOT NULL,
    low_stock boolean DEFAULT true NOT NULL,
    bin_low_stock boolean DEFAULT true NOT NULL,
    new_sale boolean DEFAULT true NOT NULL,
    due_reminder boolean DEFAULT true NOT NULL,
    new_customer boolean DEFAULT true NOT NULL,
    expiry_alert boolean DEFAULT true NOT NULL,
    daily_report boolean DEFAULT true NOT NULL,
    weekly_report boolean DEFAULT true NOT NULL,
    quiet_hours boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.notification_settings OWNER TO macbookair;

--
-- Name: otp_verifications; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.otp_verifications (
    id text NOT NULL,
    user_id text,
    shop_id text,
    app_type public."AppType" NOT NULL,
    purpose public."OtpPurpose" NOT NULL,
    channel public."OtpChannel" DEFAULT 'SMS'::public."OtpChannel" NOT NULL,
    recipient character varying(160) NOT NULL,
    country_code character varying(8),
    code_hash text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 5 NOT NULL,
    sent_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    verified_at timestamp(3) without time zone,
    consumed_at timestamp(3) without time zone,
    status public."OtpStatus" DEFAULT 'PENDING'::public."OtpStatus" NOT NULL,
    request_ip character varying(64),
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.otp_verifications OWNER TO macbookair;

--
-- Name: owner_registration_drafts; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.owner_registration_drafts (
    id text NOT NULL,
    name character varying(120) NOT NULL,
    mobile character varying(30) NOT NULL,
    email character varying(150),
    password_hash text NOT NULL,
    shop_id text,
    shop_name character varying(150) NOT NULL,
    shop_address text NOT NULL,
    shop_category character varying(120) NOT NULL,
    shop_location_label character varying(160),
    latitude numeric(10,7),
    longitude numeric(10,7),
    otp_verification_id text,
    pin_hash text,
    otp_verified_at timestamp(3) without time zone,
    pin_set_at timestamp(3) without time zone,
    completed_at timestamp(3) without time zone,
    status public."RegistrationDraftStatus" DEFAULT 'PENDING'::public."RegistrationDraftStatus" NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.owner_registration_drafts OWNER TO macbookair;

--
-- Name: password_reset_requests; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.password_reset_requests (
    id text NOT NULL,
    user_id text NOT NULL,
    shop_id text,
    app_type public."AppType" NOT NULL,
    otp_verification_id text,
    requested_for character varying(160) NOT NULL,
    status public."PasswordResetStatus" DEFAULT 'PENDING'::public."PasswordResetStatus" NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    completed_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.password_reset_requests OWNER TO macbookair;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.payments (
    id text NOT NULL,
    invoice_id text NOT NULL,
    shop_id text NOT NULL,
    amount numeric(10,2) NOT NULL,
    method character varying(50),
    trx_id character varying(120),
    status public."PaymentStatus" DEFAULT 'PENDING'::public."PaymentStatus" NOT NULL,
    paid_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.payments OWNER TO macbookair;

--
-- Name: platform_users; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.platform_users (
    id text NOT NULL,
    user_id text NOT NULL,
    role public."PlatformRole" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.platform_users OWNER TO macbookair;

--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.product_categories (
    id text NOT NULL,
    name character varying(120) NOT NULL,
    description text,
    status public."CategoryStatus" DEFAULT 'ACTIVE'::public."CategoryStatus" NOT NULL,
    created_by text,
    updated_by text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    is_approved boolean DEFAULT true NOT NULL,
    is_global boolean DEFAULT true NOT NULL,
    shop_id text
);


ALTER TABLE public.product_categories OWNER TO macbookair;

--
-- Name: product_template_items; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.product_template_items (
    id text NOT NULL,
    template_id text NOT NULL,
    master_product_id text NOT NULL
);


ALTER TABLE public.product_template_items OWNER TO macbookair;

--
-- Name: product_templates; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.product_templates (
    id text NOT NULL,
    code character varying(80) NOT NULL,
    name character varying(160) NOT NULL,
    description text,
    status public."ProductTemplateStatus" DEFAULT 'ACTIVE'::public."ProductTemplateStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.product_templates OWNER TO macbookair;

--
-- Name: purchase_items; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.purchase_items (
    id text NOT NULL,
    purchase_id text NOT NULL,
    master_product_id text NOT NULL,
    quantity numeric(12,3) NOT NULL,
    purchase_price numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    batch_no character varying(80),
    expiry_date timestamp(3) without time zone
);


ALTER TABLE public.purchase_items OWNER TO macbookair;

--
-- Name: purchase_return_items; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.purchase_return_items (
    id text NOT NULL,
    purchase_return_id text NOT NULL,
    purchase_item_id text NOT NULL,
    master_product_id text NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    reason character varying(120)
);


ALTER TABLE public.purchase_return_items OWNER TO macbookair;

--
-- Name: purchase_returns; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.purchase_returns (
    id text NOT NULL,
    shop_id text NOT NULL,
    purchase_id text NOT NULL,
    supplier_id text,
    created_by_user_id text,
    approved_by_user_id text,
    return_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public."PurchaseReturnStatus" DEFAULT 'APPROVED'::public."PurchaseReturnStatus" NOT NULL,
    refund_method character varying(50),
    refund_amount numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.purchase_returns OWNER TO macbookair;

--
-- Name: purchases; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.purchases (
    id text NOT NULL,
    shop_id text NOT NULL,
    supplier_id text,
    invoice_no character varying(80),
    purchase_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    paid_amount numeric(10,2) DEFAULT 0 NOT NULL,
    due_amount numeric(10,2) DEFAULT 0 NOT NULL,
    payment_method character varying(50),
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    payment_meta jsonb,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    extra_charge_amount numeric(10,2) DEFAULT 0 NOT NULL,
    invoice_file_name character varying(255),
    subtotal_amount numeric(10,2) DEFAULT 0 NOT NULL,
    approved_at timestamp(3) without time zone,
    approved_by_user_id text,
    created_by_user_id text,
    rejected_at timestamp(3) without time zone,
    rejection_reason text,
    status public."PurchaseStatus" DEFAULT 'APPROVED'::public."PurchaseStatus" NOT NULL
);


ALTER TABLE public.purchases OWNER TO macbookair;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.refresh_tokens (
    id text NOT NULL,
    user_id text NOT NULL,
    token_hash text NOT NULL,
    family text NOT NULL,
    app_type public."AppType" NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    revoked_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO macbookair;

--
-- Name: salesman_permissions; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.salesman_permissions (
    id text NOT NULL,
    shop_user_id text NOT NULL,
    can_sell boolean DEFAULT false NOT NULL,
    can_view_stock boolean DEFAULT false NOT NULL,
    can_view_reports boolean DEFAULT false NOT NULL,
    can_change_price boolean DEFAULT false NOT NULL,
    can_collect_due boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.salesman_permissions OWNER TO macbookair;

--
-- Name: shop_charges; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_charges (
    id text NOT NULL,
    shop_id text NOT NULL,
    name character varying(100) NOT NULL,
    amount numeric(10,2) NOT NULL,
    type text DEFAULT 'FIXED'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.shop_charges OWNER TO macbookair;

--
-- Name: shop_inventory_settings; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_inventory_settings (
    id text NOT NULL,
    shop_id text NOT NULL,
    mode public."InventoryMode" DEFAULT 'GENERAL'::public."InventoryMode" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    allow_negative_stock boolean DEFAULT false NOT NULL,
    auto_low_stock_alert boolean DEFAULT true NOT NULL,
    demand_based_reorder boolean DEFAULT false NOT NULL,
    low_stock_default integer DEFAULT 10 NOT NULL,
    low_stock_grocery integer DEFAULT 5 NOT NULL,
    reduce_stock_on_sale boolean DEFAULT true NOT NULL,
    require_bin_assignment boolean DEFAULT false NOT NULL,
    show_bin_during_sale boolean DEFAULT true NOT NULL,
    stock_method text DEFAULT 'FIFO'::text NOT NULL,
    manual_stock_approval boolean DEFAULT false NOT NULL
);


ALTER TABLE public.shop_inventory_settings OWNER TO macbookair;

--
-- Name: shop_products; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_products (
    id text NOT NULL,
    shop_id text NOT NULL,
    master_product_id text,
    opening_stock numeric(12,3) DEFAULT 0 NOT NULL,
    sale_price numeric(10,2),
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    approval_request_id text,
    local_barcode character varying(120),
    local_brand character varying(120),
    local_category character varying(120),
    local_name character varying(160),
    local_picture_url text,
    local_unit character varying(60),
    low_stock_limit numeric(12,3) DEFAULT 0 NOT NULL,
    purchase_price numeric(10,2),
    source public."ShopProductSource" DEFAULT 'MASTER'::public."ShopProductSource" NOT NULL
);


ALTER TABLE public.shop_products OWNER TO macbookair;

--
-- Name: shop_receipt_settings; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_receipt_settings (
    id text NOT NULL,
    shop_id text NOT NULL,
    printer_type character varying(80),
    paper_size character varying(40),
    show_logo boolean DEFAULT false NOT NULL,
    show_address boolean DEFAULT true NOT NULL,
    show_phone boolean DEFAULT true NOT NULL,
    show_vat_info boolean DEFAULT false NOT NULL,
    header_text text,
    footer_text text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.shop_receipt_settings OWNER TO macbookair;

--
-- Name: shop_taxes; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_taxes (
    id text NOT NULL,
    shop_id text NOT NULL,
    name character varying(100) NOT NULL,
    rate numeric(5,2) NOT NULL,
    type text DEFAULT 'PERCENTAGE'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.shop_taxes OWNER TO macbookair;

--
-- Name: shop_users; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shop_users (
    id text NOT NULL,
    shop_id text NOT NULL,
    user_id text NOT NULL,
    role public."ShopRole" DEFAULT 'SALESMAN'::public."ShopRole" NOT NULL,
    is_billable boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.shop_users OWNER TO macbookair;

--
-- Name: shops; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.shops (
    id text NOT NULL,
    shop_name character varying(150) NOT NULL,
    owner_user_id text,
    phone character varying(30),
    email character varying(150),
    address text,
    district character varying(100),
    status public."ShopStatus" DEFAULT 'ACTIVE'::public."ShopStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    area character varying(100),
    business_type character varying(80),
    closing_time character varying(20),
    logo_url text,
    opening_time character varying(20),
    postal_code character varying(20),
    tin_no character varying(100),
    trade_license_no character varying(100),
    vat_reg_no character varying(100),
    weekly_holiday character varying(30),
    shop_code character varying(30)
);


ALTER TABLE public.shops OWNER TO macbookair;

--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.stock_movements (
    id text NOT NULL,
    shop_id text NOT NULL,
    shop_product_id text NOT NULL,
    master_product_id text,
    movement_type character varying(40) NOT NULL,
    quantity_delta numeric(12,3) DEFAULT 0 NOT NULL,
    stock_before numeric(12,3),
    stock_after numeric(12,3),
    purchase_price numeric(10,2),
    sale_price numeric(10,2),
    unit_price numeric(10,2),
    reference_type character varying(40),
    reference_id text,
    reference_no character varying(80),
    note text,
    metadata jsonb,
    created_by_user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.stock_movements OWNER TO macbookair;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.subscriptions (
    id text NOT NULL,
    shop_id text NOT NULL,
    status public."SubscriptionStatus" DEFAULT 'TRIAL'::public."SubscriptionStatus" NOT NULL,
    trial_started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial_ends_at timestamp(3) without time zone NOT NULL,
    billing_started_at timestamp(3) without time zone,
    daily_rate_per_account numeric(10,2) DEFAULT 10.00 NOT NULL,
    grace_ends_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO macbookair;

--
-- Name: supplier_ledgers; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.supplier_ledgers (
    id text NOT NULL,
    shop_id text NOT NULL,
    supplier_id text NOT NULL,
    entry_type public."SupplierLedgerEntryType" NOT NULL,
    purchase_id text,
    supplier_payment_id text,
    reference_no character varying(80),
    debit numeric(10,2) DEFAULT 0 NOT NULL,
    credit numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    entry_date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.supplier_ledgers OWNER TO macbookair;

--
-- Name: supplier_payments; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.supplier_payments (
    id text NOT NULL,
    shop_id text NOT NULL,
    supplier_id text NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(50),
    money_box_id character varying(80),
    notes text,
    paid_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_meta jsonb,
    bank_account_id text
);


ALTER TABLE public.supplier_payments OWNER TO macbookair;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.suppliers (
    id text NOT NULL,
    supplier_code character varying(50) NOT NULL,
    name character varying(160) NOT NULL,
    mobile character varying(30),
    email character varying(150),
    address text,
    contact_person character varying(120),
    notes text,
    status public."SupplierStatus" DEFAULT 'ACTIVE'::public."SupplierStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone,
    contact_person_mobile character varying(30)
);


ALTER TABLE public.suppliers OWNER TO macbookair;

--
-- Name: units; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.units (
    id text NOT NULL,
    name character varying(120) NOT NULL,
    short_name character varying(40) NOT NULL,
    type public."UnitType" NOT NULL,
    description text,
    status public."UnitStatus" DEFAULT 'ACTIVE'::public."UnitStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    is_approved boolean DEFAULT true NOT NULL,
    is_global boolean DEFAULT true NOT NULL,
    shop_id text
);


ALTER TABLE public.units OWNER TO macbookair;

--
-- Name: user_pins; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.user_pins (
    id text NOT NULL,
    user_id text NOT NULL,
    pin_hash text NOT NULL,
    status public."UserPinStatus" DEFAULT 'ACTIVE'::public."UserPinStatus" NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    locked_until timestamp(3) without time zone,
    last_changed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.user_pins OWNER TO macbookair;

--
-- Name: users; Type: TABLE; Schema: public; Owner: macbookair
--

CREATE TABLE public.users (
    id text NOT NULL,
    name character varying(120) NOT NULL,
    phone character varying(30),
    email character varying(150),
    password_hash text NOT NULL,
    status public."UserStatus" DEFAULT 'ACTIVE'::public."UserStatus" NOT NULL,
    last_login_at timestamp(3) without time zone,
    created_by_user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    profile_image_url text,
    phone_verified_at timestamp(3) without time zone
);


ALTER TABLE public.users OWNER TO macbookair;

--
-- Data for Name: bank_accounts; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.bank_accounts (id, shop_id, account_name, bank_name, branch_name, account_number, account_type, opening_balance, current_balance, currency, status, is_default, notes, created_at, updated_at) FROM stdin;
cmr35v09p000zw8yo7in0fqxh	cmr0gdhu7005kw8g06c2lngfc	Main Business Account	Default Bank	\N	default-cmr0gdhu-1782975976477	CURRENT	0.00	-3000.00	BDT	ACTIVE	t	\N	2026-07-02 07:06:16.477	2026-07-02 07:06:16.487
\.


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.brands (id, name, description, logo_url, status, created_by, updated_by, created_at, updated_at) FROM stdin;
cmqnjn4wn006blxbxd15pi839	RFL	RFL brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQU_K5q5yPgQsPR2ap_3PiW4G64IATwgB1qg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.047	2026-06-21 08:47:45.047
cmqnjn4xw006dlxbx4ubu9p0o	ACI Pure	ACI Pure brand	https://d2t8nl1y0ie1km.cloudfront.net/images/6630d41fca37603714fd6b80_aci%20pure.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.092	2026-06-21 08:47:45.092
cmqnjn4yw006flxbxpb80qh5j	Teer	Teer brand	https://www.citygroup.com.bd/storage/brand_logo/2026-01-18-696ccb993cfda.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.128	2026-06-21 08:47:45.128
cmqnjn4zo006hlxbx7ijp3o5u	Pusti	Pusti brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrDdnejpBpB6lS-IjWtz_1YOAhk36Vcf7mWw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.156	2026-06-21 08:47:45.156
cmqnjn50g006jlxbxd70w178b	Rupchanda	Rupchanda brand	https://beol-bd.com/wp-content/uploads/2024/12/Rupchanda-oil-logo-2-Converted2.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.184	2026-06-21 08:47:45.184
cmqnjn514006llxbxi3uovtli	Bashundhara	Bashundhara brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-ZjviUDptiVQI7qIDOrDIoFvV0Z0wW9gs7g&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 08:47:45.208	2026-06-21 08:47:45.208
cmqnk4g0f0001lx9acp77paum	Olympic	Olympic brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTB9QV2D8mResXjVAXrg20tI5EoQiAfQm8m6w&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.591	2026-06-21 09:01:12.591
cmqnk4g170003lx9a61bc57i4	Haque	Haque brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpmyoBiz9TZFi9chwrjN7WXO55_ObVSvSJ7w&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.62	2026-06-21 09:01:12.62
cmqnk4g1s0005lx9aolx2a0b5	Danish	Danish brand	https://media.potatopro.com/danish-foods-550x270.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.641	2026-06-21 09:01:12.641
cmqnk4g2c0007lx9ae9klzie3	Nabisco	Nabisco brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMtzN5KEZV4xwzI3zdVD8YiMenxvA-AzxDNw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.66	2026-06-21 09:01:12.66
cmqnk4g2w0009lx9ay5sc8fc5	Ifad	Ifad brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-Mp0SX_li8KNfrCwvRTQ1s1oIxi823-ntnQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.68	2026-06-21 09:01:12.68
cmqnk4g3g000blx9aevdtrt7n	Fu-Wang	Fu-Wang brand	https://www.tbsnews.net/sites/default/files/styles/amp_metadata_content_image_min_696px_wide/public/images/2021/08/11/fuwang_foods.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.7	2026-06-21 09:01:12.7
cmqnk4g3y000dlx9ax2nbokf5	Coca-Cola	Coca-Cola brand	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4dTRtmNLrk7qw_wjauuAHbc0rxpdBgQ-INA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.718	2026-06-21 09:01:12.718
cmqnk4g4h000flx9ahlrl8zov	Pepsi	Pepsi brand	https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Pepsi_2023.svg/1280px-Pepsi_2023.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.737	2026-06-21 09:01:12.737
cmqnk4g53000hlx9azj7teo7q	7UP	7UP brand	https://images.seeklogo.com/logo-png/46/1/7up-logo-png_seeklogo-468194.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.76	2026-06-21 09:01:12.76
cmqnk4g5s000jlx9amzuxh1wr	Sprite	Sprite brand	https://upload.wikimedia.org/wikipedia/commons/b/b9/Sprite_Logo.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.784	2026-06-21 09:01:12.784
cmqnk4g6m000llx9ath09utxi	Fanta	Fanta brand	https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Fanta_logo_%282009%29.svg/960px-Fanta_logo_%282009%29.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:01:12.814	2026-06-21 09:01:12.814
cmqnc6tyr000flxvs82yi8mp2	PRAN	Food & Beverage Products	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDc1DgldFvNOYJuX_0xCKLVPULWicokg5Ygw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.059	2026-06-21 10:42:33.668
cmqnc6tz5000jlxvs02kaifnp	Radhuni	Spices & Cooking Essentials	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZWYFvd3sqCpSnrWD-JE33XdPp-2IajXdxdw&s	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.073	2026-06-21 10:43:28.05
cmqnkywgo000rlx9ao4pyirt8	Meizan	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://beol-bd.com/wp-content/uploads/2024/12/mejan11-1.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.592	2026-06-21 10:43:57.101
cmqnkywip000tlx9a0eqatmsh	Igloo	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://nazmulweb.github.io/eCommerce-html-template/assets/img/logo/logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.665	2026-06-21 10:44:17.725
cmqnkywkx000vlx9aclw7xbxf	Polar	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://images.seeklogo.com/logo-png/42/1/polar-logo-png_seeklogo-427672.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.741	2026-06-21 10:44:39.568
cmqnkywm7000xlx9ag55rr555	Lovello	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKR7gh-QCuNx0NZV8iSAJK-Yb-06CDH71Zeg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.791	2026-06-21 10:45:05.756
cmqnkywnf0011lx9agc2d8h0l	Bombay Sweets	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/4/46/Bombay_Sweets_Ltd_Logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.836	2026-06-21 10:46:04.955
cmqnkywnz0013lx9a0qn3au9y	BD Food	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://vectorseek.com/wp-content/uploads/2023/09/BD-Food-Logo-Vector.svg-.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.856	2026-06-21 10:46:41.717
cmqnkywoj0015lx9andafivin	Arku	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX6erXOaCfvcMps700Vvg4QMOzF2mKOOKO9Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.876	2026-06-21 10:47:02.067
cmqnkywpe0017lx9avm4xq6q9	Starship	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6B-FkQxNU7HqyRxcNiT75xi_6DRM1b_qFeQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.906	2026-06-21 10:47:39.27
cmqnkywpv0019lx9aznkeiqka	Mr. Noodles	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://media.licdn.com/dms/image/v2/C4E22AQGps-pNuRTdzw/feedshare-shrink_800/feedshare-shrink_800/0/1576877606907?e=2147483647&v=beta&t=SNnhI6Afd3Q17oggELn6WHCMrxiD91LRyD_7k8TtKdY	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.923	2026-06-21 10:48:07.513
cmqnkywqg001blx9apo7ng5y1	Doodles	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa7kiDjhLxgU8ttCCf2y4si0VKmyMAxeAqrQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.944	2026-06-21 10:48:30.264
cmqnkywwu001rlx9azinqpzex	Kazi & Kazi Tea	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kazitea.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.174	2026-06-21 09:24:54.174
cmqnkyxne002plx9amk0g5mzn	Akij Food & Beverage	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://akijfood.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.13	2026-06-21 09:24:55.13
cmqnkyxoa002tlx9anzk50dxd	Shezan	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://shezan.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.162	2026-06-21 09:24:55.162
cmqnkywrr001flx9afbh7rk49	Mr. Cookie	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqgN1MKo_gdUYpVaKjUyw9NajVlMF_Vwd50Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.992	2026-06-21 10:49:11.438
cmqnkywsc001hlx9ao0fomxpb	Cocola	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1Bw6uF2NZDZ06Amyhfx0fYGr08Xdmghy7nw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.013	2026-06-21 10:49:28.46
cmqnkywt2001jlx9a3laq7f3w	Romania	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvuNr73Wd09JQC_6yt2HVFd78b88sXcrH3hg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.039	2026-06-21 10:49:45.145
cmqnkywty001llx9az1yt97fx	Kishwan	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRynPzsWCLu7PfokkPlq2XLWLt8DbO9uvkWhA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.071	2026-06-21 10:50:04.451
cmqnkywvn001nlx9ajoggkj5f	Ispahani	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6HTavDgRM-gw3LUQr0312T-1mFD2JmE2p5Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.132	2026-06-21 10:50:20.55
cmqnkywwb001plx9a2vgsyi88	Finlay	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTB2P87nfSyZEZvc4k2_Ao3CgfHRfvzRU5Oyg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.156	2026-06-21 10:50:46.651
cmqnkywxc001tlx9a0tnmy33s	Taaza	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTD8dkeqoiEIcRPG4Ko17f9lAiC9x0me53ztQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.192	2026-06-21 10:51:13.668
cmqnkywxv001vlx9ayd688ph4	Seylon	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://cdn2.arogga.com/eyJidWNrZXQiOiJhcm9nZ2EiLCJrZXkiOiJQcm9kdWN0QnJhbmQtcGJfYmFubmVyXC8xMDE0MzVcLzEwMTQzNS1VbnRpdGxlZC0zMy1zYnA0ZTkucG5nIiwiZWRpdHMiOltdfQ==	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.211	2026-06-21 10:51:45.623
cmqnkywz3001zlx9a0tgles9u	Marks	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://d2t8nl1y0ie1km.cloudfront.net/images/65ffdcb1d2372028bed5f8a4_Marks.jpeg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.256	2026-06-21 10:52:53.832
cmqnkyx3n0021lx9a8dcp3z3q	Diploma	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjQVwBlv0jSIlxEPMcCrL-3JYP9_XyuV3P8Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.419	2026-06-21 10:53:29.285
cmqnkyx5d0023lx9ahdtdnjef	Dano	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNVN4OrVKrOmd-iYn0m9EJmqPvn6o8GcJ2iw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.482	2026-06-21 10:53:46.954
cmqnkyx6v0025lx9aah5kigxv	Arla	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-jbnpmh2q7UoQZUxgGC6SJShHToHWUKd2jg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.535	2026-06-21 10:54:07.184
cmqnkyx8l0027lx9ae7e5s5sj	Farm Fresh	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsKFgeVBJwwEofQpjZtEVEiFfH4A4_XMcwkg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.596	2026-06-21 10:54:25.528
cmqnkyxad0029lx9afklvzmlm	Aarong Dairy	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://dgikh81ssvyrj.cloudfront.net/media/images/Enterprise4.2e16d0ba.fill-300x200-c100.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.661	2026-06-21 10:54:46.013
cmqnkyxdc002blx9aci5w37sr	Milk Vita	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/en/7/7e/Seal_of_Milk_Vita.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:54.769	2026-06-21 10:55:11.388
cmqnkyxu6003blx9a1eplz83p	Bengal Meat	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bengalmeat.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.375	2026-06-21 09:24:55.375
cmqnkyxus003dlx9a8drpytip	Golden Harvest	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://goldenharvestbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.396	2026-06-21 09:24:55.396
cmqnkyxvd003flx9afte0ib6g	CP Bangladesh	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cpbangladesh.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.417	2026-06-21 09:24:55.417
cmqnkyxxg003llx9auf0oznxr	RC Cola Bangladesh	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rccolainternational.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.492	2026-06-21 09:24:55.492
cmqnkyxp9002xlx9asdts5yd1	Well Food	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://wellfoodonline.com/wp-content/uploads/2024/12/Artboard-1@4x.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.197	2026-06-21 10:59:10.632
cmqnkyxpo002zlx9a87nnc7sw	Coopers	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqYHxwzfYYht2LTr4zdxvXvJTkjGqndiN7lQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.213	2026-06-21 10:59:30.719
cmqnkyxq90031lx9avsinhina	Tasty Treat	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/en/3/3b/Tasty_Treat_logo.webp	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.234	2026-06-21 10:59:52.116
cmqnkyxso0037lx9awwm3myao	Aftab	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYGKGktfLO5hNOLy1jiZX4XgpP0FcWq0lL-Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.32	2026-06-21 11:01:17.693
cmqnkyxtb0039lx9amtp0als5	Kazi Farms	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT13TK2PIwe_tvNPzaf9v4-RjxsXJCDibn9Fw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.343	2026-06-21 11:01:37.598
cmqnkyxvy003hlx9adoqmad7j	Partex Beverage	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7DXNMlm5W3sSjeIU3INr4Mks9G_HPxRDN_g&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.439	2026-06-21 11:02:15.541
cmqnkyy13003xlx9a0a3atdkj	Keya	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://keyagroupbd.com/wp-content/uploads/2020/12/Keya-Group-Logo-.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.623	2026-06-21 11:04:22.952
cmqnkyy1x003zlx9a6ikspn22	Kohinoor Chemical	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.bangladeshyp.com/img/bd/m/1668503018-92-kohinoor-chemical-co-bd-ltd.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.653	2026-06-21 11:04:51.15
cmqnkyy470045lx9ay137jozd	Square Toiletries Ltd	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFzUryEv7Dfyewud8nnLpl1nKRTuBq3p0D6w&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.735	2026-06-21 11:07:04.727
cmqnkyy570047lx9a2v50euec	Jui	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7t2WE8Dc2IC41HxQRcNhj1r-C50TIqvoFVw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.771	2026-06-21 11:07:54.455
cmqnkyy5q0049lx9az715gxn3	Revive	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSP5gpzON4NwEwFMPW_Ggj_rCxFOAAGupggxA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.791	2026-06-21 11:08:39.207
cmqnkyy6d004blx9arh7mozsf	Sepnil	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCSM-CV6r25GbZ99Pq5kvI6mqAIkYoTAyUBQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.813	2026-06-21 11:09:30.229
cmqnkyy82004flx9a095u86wl	Aci Aerosol	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aci-bd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.874	2026-06-21 09:24:55.874
cmqnkyy9u004llx9amcnpkdxe	Vim Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.939	2026-06-21 09:24:55.939
cmqnkyyae004nlx9aaosdj1v0	Wheel Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.957	2026-06-21 09:24:55.957
cmqnkyyaw004plx9ay7uo6yp0	Surf Excel Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.975	2026-06-21 09:24:55.975
cmqnkyybm004rlx9a9093ro6v	Rin Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.003	2026-06-21 09:24:56.003
cmqnkyyc9004tlx9azswt47o6	Lux Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.026	2026-06-21 09:24:56.026
cmqnkyycx004vlx9a1jq0pqtp	Lifebuoy Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.049	2026-06-21 09:24:56.049
cmqnkyydg004xlx9ajl2dlaz8	Sunsilk Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.068	2026-06-21 09:24:56.068
cmqnkyydy004zlx9abldjjjjk	Closeup Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.086	2026-06-21 09:24:56.086
cmqnkyyel0051lx9ao40f8kd2	Ponds Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.109	2026-06-21 09:24:56.109
cmqnkyyfp0053lx9arfipsy5u	Fair & Lovely Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.149	2026-06-21 09:24:56.149
cmqnkyyh00055lx9a8wbe71n2	Parachute Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://marico.com/bangladesh	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.196	2026-06-21 09:24:56.196
cmqnkyyhh0057lx9ao7cbb0p5	Dabur Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dabur.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.214	2026-06-21 09:24:56.214
cmqnkyyi10059lx9aeya1rmke	Emami Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://emamiltd.in	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.233	2026-06-21 09:24:56.233
cmqnkyyiu005blx9ae3argjen	Harpic Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://reckitt.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.262	2026-06-21 09:24:56.262
cmqnkyyjj005dlx9aex1ltuti	Dettol Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://reckitt.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.288	2026-06-21 09:24:56.288
cmqnkyykh005flx9aq2zwitpo	Veet Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://reckitt.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.321	2026-06-21 09:24:56.321
cmqnkyyl1005hlx9ac5n7el3a	Garnier Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://loreal.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.341	2026-06-21 09:24:56.341
cmqnkyylm005jlx9agoy2l3ub	L'Oréal Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://loreal.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.363	2026-06-21 09:24:56.363
cmqnkyymg005llx9akv0h9qip	Walton	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://waltonbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.392	2026-06-21 09:24:56.392
cmqnkyyn4005nlx9axaz2605h	Marcel	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://marcelbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.416	2026-06-21 09:24:56.416
cmqnkyynm005plx9agqd3usbg	Vision Electronics	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://vision.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.435	2026-06-21 09:24:56.435
cmqnkyyo4005rlx9a856r72v0	Minister	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ministerbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.452	2026-06-21 09:24:56.452
cmqnkyy8u004hlx9a5lypty45	Godrej Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQY3wR31coMdqEluaIxJ7tKGaPkl4PlxbuXjQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.902	2026-06-21 11:10:44.469
cmqnkyyon005tlx9aalskpbca	Jamuna Electronics	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://jamunagroup.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.471	2026-06-21 09:24:56.471
cmqnkyyp5005vlx9aqde2tl3v	MyOne	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://myonebd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.489	2026-06-21 09:24:56.489
cmqnkyypm005xlx9agedcgaxo	Singer Bangladesh	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://singerbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.506	2026-06-21 09:24:56.506
cmqnkyyq9005zlx9ailpg5awq	Butterfly	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://butterflygroupbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.529	2026-06-21 09:24:56.529
cmqnkyyqp0061lx9ady113iki	Transcom Digital	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://transcomdigital.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.545	2026-06-21 09:24:56.545
cmqnkyyr50063lx9aa2h97pf9	Rangs Electronics	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rangselectronics.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.561	2026-06-21 09:24:56.561
cmqnkyyrn0065lx9awpymyzgy	Best Electronics	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bestelectronics.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.579	2026-06-21 09:24:56.579
cmqnkyysh0067lx9adntemw71	Fair Electronics	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://fairelectronics.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.609	2026-06-21 09:24:56.609
cmqnkyyt60069lx9afrxh2gpm	Edison	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://edison-bd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.635	2026-06-21 09:24:56.635
cmqnkyyu9006blx9a26nuyuqb	Symphony	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://symphony-mobile.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.673	2026-06-21 09:24:56.673
cmqnkyyvf006dlx9alf2lqs37	Helio	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://edison-bd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.715	2026-06-21 09:24:56.715
cmqnkyywj006flx9ad4zlbzl4	WE	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://we.net.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.755	2026-06-21 09:24:56.755
cmqnkyyxb006hlx9adzhotv75	Aamra	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aamra.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.783	2026-06-21 09:24:56.783
cmqnkyyy0006jlx9ap0hj2den	Bijoy Digital	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bijoydigital.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.808	2026-06-21 09:24:56.808
cmqnkyyyw006llx9a9rgbhnjn	Doel Laptop	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://doellaptop.gov.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.841	2026-06-21 09:24:56.841
cmqnkyyzj006nlx9aeba6cr4z	Amber IT	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://amberit.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.864	2026-06-21 09:24:56.864
cmqnkyz0a006plx9a9yas7n8x	Link3	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://link3.net	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.89	2026-06-21 09:24:56.89
cmqnkyz16006rlx9asuytggn3	Carnival Internet	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://carnival.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.922	2026-06-21 09:24:56.922
cmqnkyz1v006tlx9agdpxrp83	Bikroy	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bikroy.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.947	2026-06-21 09:24:56.947
cmqnkyz2c006vlx9azkupvm7z	Chaldal	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://chaldal.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.964	2026-06-21 09:24:56.964
cmqnkyz2z006xlx9ajhfmgssl	Pickaboo	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pickaboo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:56.987	2026-06-21 09:24:56.987
cmqnkyz3r006zlx9a7z7epnfp	Daraz Bangladesh	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://daraz.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.015	2026-06-21 09:24:57.015
cmqnkyz470071lx9ak874ukk1	AjkerDeal	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ajkerdeal.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.031	2026-06-21 09:24:57.031
cmqnkyz4s0073lx9a20jxz23x	Rokomari	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rokomari.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.052	2026-06-21 09:24:57.052
cmqnkyz5b0075lx9abh7gcf0f	Othoba	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://othoba.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.071	2026-06-21 09:24:57.071
cmqnkyz5w0077lx9axnvtj174	Evaly	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://evaly.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.092	2026-06-21 09:24:57.092
cmqnkyz6j0079lx9a0ebc1nvn	Pathao	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pathao.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.115	2026-06-21 09:24:57.115
cmqnkyz7b007blx9a3l42gtgh	Shohoz	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://shohoz.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.144	2026-06-21 09:24:57.144
cmqnkyz7t007dlx9aquya83k5	Foodpanda Bangladesh	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://foodpanda.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.162	2026-06-21 09:24:57.162
cmqnkyz8e007flx9ax2gufbcj	HungryNaki	Bangladesh Electronics/Appliance/Tech brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hungrynaki.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.182	2026-06-21 09:24:57.182
cmqnkyz8x007hlx9au0uxfd2a	Aarong	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aarong.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.201	2026-06-21 09:24:57.201
cmqnkyz9i007jlx9a8v391v6g	Yellow	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://yellowclothing.net	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.222	2026-06-21 09:24:57.222
cmqnkyz9y007llx9au5yvc4i2	Ecstasy	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ecstasybd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.239	2026-06-21 09:24:57.239
cmqnkyzah007nlx9agcaleik9	Cats Eye	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://catseye.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.257	2026-06-21 09:24:57.257
cmqnkyzb3007plx9aj6989o1g	Richman	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://richmanbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.279	2026-06-21 09:24:57.279
cmqnkyzbk007rlx9anvryx860	Sailor	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sailor.clothing	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.296	2026-06-21 09:24:57.296
cmqnkyzc1007tlx9aiz9bpfhk	Le Reve	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lerevecraze.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.313	2026-06-21 09:24:57.313
cmqnkyzch007vlx9ay85x7ng8	Kay Kraft	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kaykraft.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.329	2026-06-21 09:24:57.329
cmqnkyzcy007xlx9ah2cg1bpz	Anjan's	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://anjans.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.347	2026-06-21 09:24:57.347
cmqnkyzdf007zlx9ad5ghq79p	Rang Bangladesh	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rang-bd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.364	2026-06-21 09:24:57.364
cmqnkyze10081lx9a227rv7f2	Deshal	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://deshal.net	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.385	2026-06-21 09:24:57.385
cmqnkyzeh0083lx9aozb5rs59	Nipun	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nipuncraft.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.402	2026-06-21 09:24:57.402
cmqnkyzf10085lx9aj2rjd0sq	Aranya	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aranya.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.421	2026-06-21 09:24:57.421
cmqnkyzfh0087lx9a4tjnjinz	Artisan	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://artisancraftbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.438	2026-06-21 09:24:57.438
cmqnkyzfy0089lx9adu6fmnxq	Gentle Park	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://gentlepark.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.454	2026-06-21 09:24:57.454
cmqnkyzge008blx9auozuk92o	Twelve Clothing	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://twelvebd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.47	2026-06-21 09:24:57.47
cmqnkyzgu008dlx9abic3sn5x	Infinity Mega Mall	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://infinitymegamall.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.487	2026-06-21 09:24:57.487
cmqnkyzhc008flx9awy3e5jtr	Apex	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://apex4u.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.504	2026-06-21 09:24:57.504
cmqnkyzhz008hlx9a8q71a4gy	Bata Bangladesh	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bata.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.526	2026-06-21 09:24:57.526
cmqnkyzih008jlx9aclg3saz2	Bay Emporium	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bayemporiumbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.546	2026-06-21 09:24:57.546
cmqnkyziy008llx9act8p5toh	Jennys Shoes	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://jennysshoes.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.563	2026-06-21 09:24:57.563
cmqnkyzjk008nlx9a9ykz0110	Walkar	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://walkarfootwear.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.584	2026-06-21 09:24:57.584
cmqnkyzk1008plx9aegsvtdma	Lotto Bangladesh	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lottobd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.601	2026-06-21 09:24:57.601
cmqnkyzkh008rlx9av5wmu2ob	Turaag Active	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://turaag.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.618	2026-06-21 09:24:57.618
cmqnkyzkz008tlx9avmmm2lqq	Rise	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rise.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.635	2026-06-21 09:24:57.635
cmqnkyzlf008vlx9akgjlbeks	Noir	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://noir.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.652	2026-06-21 09:24:57.652
cmqnkyzlz008xlx9a91znvhw8	Dorjibari	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dorjibari.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.671	2026-06-21 09:24:57.671
cmqnkyzmg008zlx9aogitegya	Freeland	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://freeland.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.689	2026-06-21 09:24:57.689
cmqnkyzmz0091lx9aft4vl6fi	Grameen UNIQLO	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://uniqlo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.707	2026-06-21 09:24:57.707
cmqnkyzng0093lx9adj94zhe7	Sara Lifestyle	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://saralifestyle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.724	2026-06-21 09:24:57.724
cmqnkyznx0095lx9a29nwc9jt	Bibiana	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bibiana.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.741	2026-06-21 09:24:57.741
cmqnkyzof0097lx9a9cahmy4u	Nogordola	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nogordola.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.759	2026-06-21 09:24:57.759
cmqnkyzow0099lx9aa41f5vfx	Kraftz	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kraftz.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.776	2026-06-21 09:24:57.776
cmqnkyzpc009blx9aouibvopz	La Reve	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lerevecraze.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.793	2026-06-21 09:24:57.793
cmqnkyzpw009dlx9ai3q1cydc	Shada Kalo	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://shadakalo.net	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.812	2026-06-21 09:24:57.812
cmqnkyzqg009flx9awmm96yra	Aadi	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aadibd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.832	2026-06-21 09:24:57.832
cmqnkyzqz009hlx9albsyc613	Texmart	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://texmartbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.852	2026-06-21 09:24:57.852
cmqnkyzrj009jlx9an9r8e3rj	Pride	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pridegrp.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.871	2026-06-21 09:24:57.871
cmqnkyzs1009llx9akmo4tp3g	Lubnan	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lubnan.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.889	2026-06-21 09:24:57.889
cmqnkyzsi009nlx9agifm6izf	Top Ten Mart	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://toptenmartltd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.906	2026-06-21 09:24:57.906
cmqnkyzt3009plx9a47uk5vmm	Blucheez	Bangladesh Fashion/Lifestyle/Retail brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://blucheez.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.928	2026-06-21 09:24:57.928
cmqnkyztp009rlx9agp3684ra	Square Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://squarepharma.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.949	2026-06-21 09:24:57.949
cmqnkyzu7009tlx9a6nwgcrfi	Beximco Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://beximcopharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.967	2026-06-21 09:24:57.967
cmqnkyzul009vlx9auc0ogozd	Incepta Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://inceptapharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.982	2026-06-21 09:24:57.982
cmqnkyzv1009xlx9a7qvf1ll1	Renata	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://renata-ltd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:57.997	2026-06-21 09:24:57.997
cmqnkyzvm009zlx9a3d2f3ia1	Opsonin Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://opsonin-pharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.018	2026-06-21 09:24:58.018
cmqnkyzw500a1lx9ar5q0lr7r	Eskayef	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://skfbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.037	2026-06-21 09:24:58.037
cmqnkyzwk00a3lx9aqnet34oe	Acme Laboratories	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://acmelab.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.052	2026-06-21 09:24:58.052
cmqnkyzx100a5lx9ae2revsp2	Aristopharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aristopharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.069	2026-06-21 09:24:58.069
cmqnkyzxj00a7lx9ahga0z3t1	Healthcare Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hplbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.088	2026-06-21 09:24:58.088
cmqnkyzy100a9lx9au60ywbtd	Drug International	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://drug-international.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.105	2026-06-21 09:24:58.105
cmqnkyzyh00ablx9aqbksmgak	Beacon Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://beaconpharma.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.122	2026-06-21 09:24:58.122
cmqnkyzyy00adlx9a01gkqpq4	Orion Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://orionpharmabd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.139	2026-06-21 09:24:58.139
cmqnkyzzd00aflx9afiv1bv86	General Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://generalpharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.154	2026-06-21 09:24:58.154
cmqnkyzzs00ahlx9a9t4u9hjb	Ibn Sina Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ibnsinapharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.169	2026-06-21 09:24:58.169
cmqnkz00800ajlx9aspabk2fg	Delta Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://deltapharmabd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.184	2026-06-21 09:24:58.184
cmqnkz00n00allx9adicwkpgm	Popular Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://popular-pharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.199	2026-06-21 09:24:58.199
cmqnkz01a00anlx9a8zr5yf0m	Nuvista Pharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nuvistapharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.222	2026-06-21 09:24:58.222
cmqnkz01y00aplx9a7wja8psc	Radiant Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://radiantpharmabd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.246	2026-06-21 09:24:58.246
cmqnkz02k00arlx9a7binn8aw	Sanofi Bangladesh	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sanofi.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.268	2026-06-21 09:24:58.268
cmqnkz03c00atlx9a48nb9wlm	Novartis Bangladesh	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://novartis.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.297	2026-06-21 09:24:58.297
cmqnkz03w00avlx9ap90mn06s	GlaxoSmithKline Bangladesh	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://gsk.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.316	2026-06-21 09:24:58.316
cmqnkz0nx00cjlx9a6j7jay94	Atlas Bangladesh	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://atlas.gov.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.037	2026-06-21 09:24:59.037
cmqnkz0oi00cllx9aodlbc9py	Bangladesh Honda	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bdhonda.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.058	2026-06-21 09:24:59.058
cmqnkz0p500cnlx9au6ymoqty	Uttara Motors	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://uttaramotorsltd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.082	2026-06-21 09:24:59.082
cmqnkz0pw00cplx9apo14p3js	Nitol Motors	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nitolmotors.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.109	2026-06-21 09:24:59.109
cmqnkz0qc00crlx9ab9yqwkxg	IFAD Autos	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ifadautos.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.124	2026-06-21 09:24:59.124
cmqnkz0qs00ctlx9aqpn3y8tz	ACI Motors	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aci-bd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.141	2026-06-21 09:24:59.141
cmqnkz0r800cvlx9agmdhh9eg	Rangs Motors	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rangsgroup.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.157	2026-06-21 09:24:59.157
cmqnkz0rq00cxlx9adq607mgn	Energypac	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://energypac.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.175	2026-06-21 09:24:59.175
cmqnkz0sg00czlx9agpr7p901	Rahimafrooz	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://rahimafrooz.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.2	2026-06-21 09:24:59.2
cmqnkz0sv00d1lx9an717r72d	Hamko	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hamko.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.215	2026-06-21 09:24:59.215
cmqnkz0t900d3lx9aeomo8irt	Confidence Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://confidencecement.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.229	2026-06-21 09:24:59.229
cmqnkz0u800d5lx9ankzzavx1	Crown Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://crowncement.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.264	2026-06-21 09:24:59.264
cmqnkz0v100d7lx9aumgesuqy	Shah Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://shahcement.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.294	2026-06-21 09:24:59.294
cmqnkz0vk00d9lx9apin8gu01	Seven Rings Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sevenringscement.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.313	2026-06-21 09:24:59.313
cmqnkz0vz00dblx9a976khwcg	Premier Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://premiercement.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.327	2026-06-21 09:24:59.327
cmqnkz04o00axlx9aozd7nlib	Unimed Unihealth	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unimedunihealth.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.345	2026-06-21 09:24:58.345
cmqnkz05900azlx9aweg5dvll	Ziska Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ziskapharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.365	2026-06-21 09:24:58.365
cmqnkz05u00b1lx9agyzgz7no	Navana Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://navanapharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.386	2026-06-21 09:24:58.386
cmqnkz06f00b3lx9alonjp4ha	Jayson Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://jaysonbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.408	2026-06-21 09:24:58.408
cmqnkz06w00b5lx9ao7epc4fx	Ad-din Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://addinpharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.424	2026-06-21 09:24:58.424
cmqnkz07f00b7lx9as5x390qp	Kemiko Pharmaceuticals	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kemikopharma.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.443	2026-06-21 09:24:58.443
cmqnkz08500b9lx9a0ooghbeo	Biopharma	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://biopharma.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.47	2026-06-21 09:24:58.47
cmqnkz08t00bblx9aisv9h6nu	Labaid	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://labaidgroup.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.493	2026-06-21 09:24:58.493
cmqnkz09c00bdlx9a4u3jr5ed	Popular Diagnostic	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://popular-diagnostic.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.513	2026-06-21 09:24:58.513
cmqnkz09s00bflx9a0d0q45i8	Ibn Sina Diagnostic	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ibnsinatrust.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.528	2026-06-21 09:24:58.528
cmqnkz0a700bhlx9aziky4eg7	Square Hospital	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://squarehospital.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.544	2026-06-21 09:24:58.544
cmqnkz0ao00bjlx9a7g3coqj8	Evercare Hospital Dhaka	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://evercarebd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.56	2026-06-21 09:24:58.56
cmqnkz0bf00bllx9agxsrmjo4	United Hospital	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://uhlbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.587	2026-06-21 09:24:58.587
cmqnkz0ce00bnlx9aqqhh1f00	Praava Health	Bangladesh Pharma/Healthcare brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://praavahealth.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.623	2026-06-21 09:24:58.623
cmqnkz0dc00bplx9azco3j7ot	Akij	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://akij.net	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.656	2026-06-21 09:24:58.656
cmqnkz0ec00brlx9a7vp4byrs	Beximco	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://beximco.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.692	2026-06-21 09:24:58.692
cmqnkz0fr00btlx9aa8ymofyk	City Group	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://citygroup.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.744	2026-06-21 09:24:58.744
cmqnkz0gb00bvlx9a0pb7b6dd	Meghna Group	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://meghnagroup.biz	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.763	2026-06-21 09:24:58.763
cmqnkz0h200bxlx9aan7fqy6b	Abul Khair	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://abulkhairgroup.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.79	2026-06-21 09:24:58.79
cmqnkz0ik00bzlx9akoglvwzm	S Alam	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://s.alamgroupbd.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.844	2026-06-21 09:24:58.844
cmqnkz0j000c1lx9a9og2ycrf	PHP	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://phpfamily.co	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.861	2026-06-21 09:24:58.861
cmqnkz0ji00c3lx9awzs2bctq	KSRM	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ksrm.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.878	2026-06-21 09:24:58.878
cmqnkz0jy00c5lx9at2swprrg	BSRM	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bsrm.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.894	2026-06-21 09:24:58.894
cmqnkz0km00c7lx9aoaiedc6v	GPH Ispat	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://gphispat.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.918	2026-06-21 09:24:58.918
cmqnkz0l500c9lx9aruo63u1s	Anwar Group	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://anwargroup.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.937	2026-06-21 09:24:58.937
cmqnkz0lk00cblx9actzpr5ws	Navana	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://navana.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.953	2026-06-21 09:24:58.953
cmqnkz0m500cdlx9acoj0qkge	Aftab Automobiles	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://aftabautomobiles.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.973	2026-06-21 09:24:58.973
cmqnkz0ml00cflx9aansbpqve	Runner	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://runnerautomobiles.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:58.989	2026-06-21 09:24:58.989
cmqnkz0nc00chlx9a1zssawwo	Runner Automobiles	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://runnerautomobiles.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.016	2026-06-21 09:24:59.016
cmqnkz1cj00exlx9aunriwz66	Red Bull	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://redbull.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.923	2026-06-21 09:24:59.923
cmqnkz1dc00ezlx9a2bav4wb2	Nestlé	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.952	2026-06-21 09:24:59.952
cmqnkz1i500fflx9aw4wy117p	Nespray	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.125	2026-06-21 09:25:00.125
cmqnkz1iv00fhlx9a8zanr826	Everyday	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.151	2026-06-21 09:25:00.151
cmqnkz1j900fjlx9atimelqq2	Tang	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://tang.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.165	2026-06-21 09:25:00.165
cmqnkz1jt00fllx9aqajwnf32	Oreo	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://oreo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.186	2026-06-21 09:25:00.186
cmqnkz1kg00fnlx9a0uxjkmix	Cadbury	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cadbury.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.209	2026-06-21 09:25:00.209
cmqnkz1le00frlx9aiix6ilhz	Dairy Milk	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cadbury.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.242	2026-06-21 09:25:00.242
cmqnkz1lu00ftlx9a42og1jui	Bournvita	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cadbury.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.258	2026-06-21 09:25:00.258
cmqnkz1m900fvlx9au3g6v12h	Horlicks	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://horlicks.in	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.273	2026-06-21 09:25:00.273
cmqnkz1mt00fxlx9adf35b9e9	Complan	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://complan.in	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.293	2026-06-21 09:25:00.293
cmqnkz1nh00fzlx9aimn4praa	Kellogg's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kelloggs.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.317	2026-06-21 09:25:00.317
cmqnkz1oi00g1lx9a4i83j2tg	Quaker	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://quakeroats.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.354	2026-06-21 09:25:00.354
cmqnkz1pz00g3lx9aa1v5bl6o	Kraft	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kraftheinzcompany.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.407	2026-06-21 09:25:00.407
cmqnkz1ql00g5lx9aa5lc9bfe	Heinz	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://heinz.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.43	2026-06-21 09:25:00.43
cmqnkz1r800g7lx9aovumruz1	Hellmann's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hellmanns.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.452	2026-06-21 09:25:00.452
cmqnkz1rr00g9lx9a7d7i8ko2	Knorr	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://knorr.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.471	2026-06-21 09:25:00.471
cmqnkz1s500gblx9a14d689rs	Lipton	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lipton.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.486	2026-06-21 09:25:00.486
cmqnkz1sq00gdlx9awd1xm8zt	Brooke Bond	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.506	2026-06-21 09:25:00.506
cmqnkz0we00ddlx9avdfwvov2	Mir Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mircement.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.343	2026-06-21 09:24:59.343
cmqnkz0xf00dflx9ajiumtd63	Fresh Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://meghnagroup.biz	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.379	2026-06-21 09:24:59.379
cmqnkz0yx00dhlx9a30xsqoum	Bashundhara Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bashundharacement.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.433	2026-06-21 09:24:59.433
cmqnkz0ze00djlx9at56axf6k	Scan Cement	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lafargeholcim.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.45	2026-06-21 09:24:59.45
cmqnkz0zx00dllx9a69rgmj9r	Holcim Bangladesh	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lafargeholcim.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.469	2026-06-21 09:24:59.469
cmqnkz10i00dnlx9a9zlch3qv	LafargeHolcim Bangladesh	Bangladesh Industrial/Construction/Auto/Finance brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lafargeholcim.com.bd	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.49	2026-06-21 09:24:59.49
cmqnkz1bd00etlx9ag0z7ttrr	Mountain Dew	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mountaindew.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.881	2026-06-21 09:24:59.881
cmqnkz1c000evlx9aa1t49orv	Mirinda	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pepsico.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.904	2026-06-21 09:24:59.904
cmqnkz1e200f1lx9ab443sz5u	Nescafé	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nescafe.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.978	2026-06-21 09:24:59.978
cmqnkz1ek00f3lx9a651y4i3v	Maggi	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://maggi.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:59.996	2026-06-21 09:24:59.996
cmqnkz1f600f5lx9axbvjqexw	KitKat	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kitkat.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.018	2026-06-21 09:25:00.018
cmqnkz1fq00f7lx9ahu5ez9kq	Milo	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://milo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.039	2026-06-21 09:25:00.039
cmqnkz1g800f9lx9ac1qwfq27	Cerelac	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.056	2026-06-21 09:25:00.056
cmqnkz1gt00fblx9a1wnga4v7	Lactogen	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.077	2026-06-21 09:25:00.077
cmqnkz1ho00fdlx9a1iqretdh	Nido	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nestle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.109	2026-06-21 09:25:00.109
cmqnkz36v00k9lx9axmg0ygoo	Procter & Gamble	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pg.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.311	2026-06-21 09:25:02.311
cmqnkz38s00kflx9api6dsiul	Herbal Essences	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://herbalessences.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.38	2026-06-21 09:25:02.38
cmqnkz39a00khlx9aj2xzt70n	Olay	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://olay.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.398	2026-06-21 09:25:02.398
cmqnkz3bd00kplx9aytc1r13g	Tide	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://tide.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.473	2026-06-21 09:25:02.473
cmqnkz3c900ktlx9a1izzh3xa	Pampers	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pampers.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.505	2026-06-21 09:25:02.505
cmqnkz3cp00kvlx9a2lxnmc01	Always	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://1000logos.net/wp-content/uploads/2020/04/Always-Logo-2010.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.521	2026-06-21 10:15:43.798
cmqnkz3bs00krlx9a3j7qkcrv	Downy	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE2sEyMWyZ8MbxE_Zy595V_Eb2shH-L9GT2A&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.489	2026-06-21 10:16:11.933
cmqnkz3aw00knlx9aejiym28n	Ariel	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4shK3KxEhBbVU3QK_s-UIMIcVMiJ4P_8eIw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.457	2026-06-21 10:16:28.703
cmqnkz3ab00kllx9a02u2ssnh	Oral-B	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://images.seeklogo.com/logo-png/10/1/oral-b-logo-png_seeklogo-103851.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.435	2026-06-21 10:16:51.875
cmqnkz39t00kjlx9ah69xyerb	Gillette	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://1000logos.net/wp-content/uploads/2020/04/Logo-Gillette.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.417	2026-06-21 10:17:13.993
cmqnkz38800kdlx9ap6es6kgx	Head & Shoulders	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://allvectorlogo.com/img/2021/12/head-shoulders-logo-vector.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.36	2026-06-21 10:17:37.367
cmqnkz37h00kblx9ayhdktwb2	Pantene	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaNmpMlxChpXkWaKEk445QImmSG_9pf3v2pg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.333	2026-06-21 10:18:02.094
cmqnkz35500k5lx9ahz5906oj	Vim	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEi5QzqGdPRcJiF9kV8fFoxI7tREDCNYyQJg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.25	2026-06-21 10:18:47.642
cmqnkz34q00k3lx9awm1heaqj	Wheel	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://cdn2.arogga.com/eyJidWNrZXQiOiJhcm9nZ2EiLCJrZXkiOiJQcm9kdWN0QnJhbmQtcGJfYmFubmVyXC8xMDIxOTNcLzEwMjE5My1VbnRpdGxlZC00MC1hMG5pc3oucG5nIiwiZWRpdHMiOltdfQ==	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.235	2026-06-21 10:19:27.828
cmqnkz34800k1lx9ayyai1665	Rin	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHDYar2XOPxgDie87JWUNAD7kaSnVYbbCeTQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.216	2026-06-21 10:19:48.264
cmqnkz33l00jzlx9amirmqh49	Surf Excel	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://cdn2.arogga.com/eyJidWNrZXQiOiJhcm9nZ2EiLCJrZXkiOiJQcm9kdWN0QnJhbmQtcGJfYmFubmVyXC8xMDIxNTNcLzEwMjE1My1TdXJmLUV4Y2VsLWl5c2lkOS5wbmciLCJlZGl0cyI6W119	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.194	2026-06-21 10:20:11.98
cmqnkz1wy00grlx9aopf9376a	Nutella	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nutella.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.659	2026-06-21 09:25:00.659
cmqnkz1xw00gtlx9aysizw2z2	Kinder	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kinder.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.693	2026-06-21 09:25:00.693
cmqnkz1zo00gxlx9ab6p37x2w	Snickers	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://snickers.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.756	2026-06-21 09:25:00.756
cmqnkz20400gzlx9aiuzu5tez	Twix	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://twix.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.772	2026-06-21 09:25:00.772
cmqnkz20z00h1lx9aoktifhot	M&M's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mms.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.8	2026-06-21 09:25:00.8
cmqnkz21v00h3lx9a7isk331t	Bounty	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mars.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.836	2026-06-21 09:25:00.836
cmqnkz22i00h5lx9a3dmoxidb	Hershey's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hersheyland.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.858	2026-06-21 09:25:00.858
cmqnkz23000h7lx9agsxypi2a	Reese's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://reeses.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.876	2026-06-21 09:25:00.876
cmqnkz23y00h9lx9aiygldd6p	Pringles	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://pringles.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.91	2026-06-21 09:25:00.91
cmqnkz25e00hblx9a4s4unr6o	Lay's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lays.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.963	2026-06-21 09:25:00.963
cmqnkz26400hdlx9aabsjon6k	Cheetos	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cheetos.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:00.988	2026-06-21 09:25:00.988
cmqnkz27300hflx9a3g5x6qh6	Doritos	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://doritos.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.023	2026-06-21 09:25:01.023
cmqnkz28l00hhlx9a4rjze7fb	Ruffles	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ruffles.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.078	2026-06-21 09:25:01.078
cmqnkz29b00hjlx9a3ez5rk36	Kurkure	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://kurkure.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.103	2026-06-21 09:25:01.103
cmqnkz2a900hllx9a4ict2rjk	Sunfeast	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sunfeastworld.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.137	2026-06-21 09:25:01.137
cmqnkz2bn00hnlx9auuyba419	Britannia	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://britannia.co.in	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.188	2026-06-21 09:25:01.188
cmqnkz2ci00hplx9ary5n4jfw	Parle	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://parleproducts.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.218	2026-06-21 09:25:01.218
cmqnkz2d400hrlx9actz7ot60	Haldiram's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://haldirams.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.241	2026-06-21 09:25:01.241
cmqnkz2e000htlx9aht12w2d6	Amul	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://amul.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.272	2026-06-21 09:25:01.272
cmqnkz2ep00hvlx9a4cvtttkj	Mother Dairy	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://motherdairy.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.297	2026-06-21 09:25:01.297
cmqnkz2fl00hxlx9aonx5qhkg	McVitie's	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mcvities.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.329	2026-06-21 09:25:01.329
cmqnkz2gl00i1lx9ajprpg1vx	Tic Tac	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://tictac.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.365	2026-06-21 09:25:01.365
cmqnkz2h800i3lx9atr4eahm7	Chupa Chups	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://chupachups.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.389	2026-06-21 09:25:01.389
cmqnkz2ht00i5lx9a4a3v1a6f	Mentos	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mentos.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.409	2026-06-21 09:25:01.409
cmqnkz2i900i7lx9a48ey6bra	Alpenliebe	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://perfettivanmelle.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.425	2026-06-21 09:25:01.425
cmqnkz2mp00illx9akkhq5024	Saffola	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://saffola.in	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.585	2026-06-21 09:25:01.585
cmqnkz2sz00j7lx9aob1u454m	Unilever	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://unilever.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.811	2026-06-21 09:25:01.811
cmqnkz2tr00j9lx9an382ikol	Dove	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dove.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.839	2026-06-21 09:25:01.839
cmqnkz2wx00jjlx9anvsdk50k	Clear	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.unilever.com.bd/content-images/92ui5egz/production/6d3654ed7cdfa6d3ffae547b355f0d48118eddaa-1080x1080.png?w=160&h=160&fit=crop&auto=format	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.953	2026-06-21 10:22:31.692
cmqnkz2wc00jhlx9ae0pix3iu	Tresemmé	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/7/7b/Tresemme_new_logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.932	2026-06-21 10:22:56.358
cmqnkz2vt00jflx9a7hmfz75j	Sunsilk	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.unilever.com.bd/content-images/92ui5egz/production/0ebcc26e0f4ddde097e8e87215061106a52f7a50-1080x1080.png?w=160&h=160&fit=crop&auto=format	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.913	2026-06-21 10:23:19.342
cmqnkz2ug00jblx9a0hru0a7u	Lux	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/en/8/82/LUX_%28soap%29_logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.864	2026-06-21 10:23:59.194
cmqnkz2kv00ihlx9ajpmt4xbp	Blue Band	International FMCG/Food sold in BD brand commonly used/sold in Bangladesh market	https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/b13be0175279467.64b155fc032fe.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.519	2026-06-21 10:31:46.117
cmqnkz30t00jrlx9a5zqqm4qo	Vaseline	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://vaseline.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.093	2026-06-21 09:25:02.093
cmqnkz31k00jtlx9arsgohpij	Axe	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://axe.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.119	2026-06-21 09:25:02.119
cmqnkz4iv00oxlx9a1x5b8v09	Epson	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://epson.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.039	2026-06-21 09:25:04.039
cmqnkz51h00qhlx9aby3a3gia	JBL	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://jbl.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.709	2026-06-21 09:25:04.709
cmqnkz52400qjlx9axnzp29tk	Bose	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://bose.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.733	2026-06-21 09:25:04.733
cmqnkz52p00qllx9alco37etl	Sennheiser	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sennheiser-hearing.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.753	2026-06-21 09:25:04.753
cmqnkz53800qnlx9alghompfs	Sony Audio	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://sony.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.772	2026-06-21 09:25:04.772
cmqnkz53q00qplx9a7paoon7b	Beats	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://beatsbydre.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.79	2026-06-21 09:25:04.79
cmqnkz54800qrlx9ady8njo9s	Skullcandy	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://skullcandy.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.808	2026-06-21 09:25:04.808
cmqnkz55n00qxlx9arm1oca0h	Havit	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://prohavit.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.859	2026-06-21 09:25:04.859
cmqnkz56700qzlx9a9lca7az9	TP-Link	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://tp-link.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.88	2026-06-21 09:25:04.88
cmqnkz57r00r5lx9awk5mtige	Netgear	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://netgear.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.936	2026-06-21 09:25:04.936
cmqnkz58c00r7lx9a3di56muv	MikroTik	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mikrotik.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.956	2026-06-21 09:25:04.956
cmqnkz59100r9lx9aj4kkmzdo	Cisco	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cisco.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.981	2026-06-21 09:25:04.981
cmqnkz56n00r1lx9aspwi48p6	D-Link	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQkdI5ff96v4wLs2mb_nlMtdDPuxCOpxuiVSQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.896	2026-06-21 09:39:14.152
cmqnkz55800qvlx9a4lj9mlgc	Microlab	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjvAgR7bbDce7KJgFF8nLE2DDi8ZHCCM2hQw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.844	2026-06-21 09:42:41.057
cmqnkz50v00qflx9ay35w8ukq	Belkin	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOr6abrbp_KJyoTd2kfa1BBMYoGirU4pmUzw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.687	2026-06-21 09:43:46.813
cmqnkz50b00qdlx9aipb87e39	Ugreen	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://gadgetbd.com/wp-content/uploads/2025/05/UGREEN-logo.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.667	2026-06-21 09:44:18.081
cmqnkz4zw00qblx9a1gekfzcs	Baseus	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtaVgG-yMOtBZbs3uVYC2XvJQqYz-kqjnebg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.653	2026-06-21 09:45:36.588
cmqnkz4zg00q9lx9a46cv1zsu	Anker	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Anker_logo.svg/960px-Anker_logo.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.636	2026-06-21 09:46:21.813
cmqnkz4jl00ozlx9avvv77f9y	Brother	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCuKtECbCt86DOJMaZupDEeycaDYNJzAXysw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.065	2026-06-21 09:57:04.773
cmqnkz33200jxlx9asfpvvglt	Fair & Lovely	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://images.seeklogo.com/logo-png/36/2/fair-lovely-logo-png_seeklogo-366381.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.175	2026-06-21 10:20:33.412
cmqnkz32e00jvlx9aqv7gv2o4	Rexona	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmIRa4Rmw0hO_GPI3kF2xqww-emC8YAuPqCA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.151	2026-06-21 10:20:54.134
cmqnkz2z600jplx9ab02icyc2	Pond's	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScv2u8TAaQvAYFUDMx2-i_39CeeV-7mjICRA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.034	2026-06-21 10:21:25.887
cmqnkz2y500jnlx9af7czh7gm	Pepsodent	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgL_bwFIQ3MnU0LV5VHoAd977qgTToEuikpg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.998	2026-06-21 10:21:44.866
cmqnkz3dw00kzlx9az94bcjjv	Himalaya	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://himalayawellness.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.565	2026-06-21 09:25:02.565
cmqnkz3eb00l1lx9apgecg90p	Dabur	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dabur.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.58	2026-06-21 09:25:02.58
cmqnkz3f700l5lx9a4154ev2a	Parachute	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://marico.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.611	2026-06-21 09:25:02.611
cmqnkz3fv00l7lx9a6b56s434	Johnson & Johnson	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://jnj.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.636	2026-06-21 09:25:02.636
cmqnkz3gi00l9lx9aalv76r3y	Johnson's Baby	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://johnsonsbaby.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.658	2026-06-21 09:25:02.658
cmqnkz3h600lblx9ajhbw5qcf	Neutrogena	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://neutrogena.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.682	2026-06-21 09:25:02.682
cmqnkz3i000ldlx9auck182r4	Clean & Clear	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cleanandclear.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.712	2026-06-21 09:25:02.712
cmqnkz3iq00lflx9adqaoo8eg	Nivea	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nivea.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.738	2026-06-21 09:25:02.738
cmqnkz3jb00lhlx9aozinp6zd	Garnier	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://garnierusa.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.759	2026-06-21 09:25:02.759
cmqnkz3k000ljlx9a05zebpas	L'Oréal Paris	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lorealparisusa.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.785	2026-06-21 09:25:02.785
cmqnkz3kl00lllx9aa89tgt9c	Maybelline	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://maybelline.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.805	2026-06-21 09:25:02.805
cmqnkz3l900lnlx9anuwm0d6o	Lakmé	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lakmeindia.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.829	2026-06-21 09:25:02.829
cmqnkz3lt00lplx9abhnmhj9k	Revlon	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://revlon.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.849	2026-06-21 09:25:02.849
cmqnkz3mm00lrlx9acv686rs3	The Body Shop	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://thebodyshop.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.878	2026-06-21 09:25:02.878
cmqnkz3ne00ltlx9a9oepkrd4	Simple	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://simpleskincare.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.907	2026-06-21 09:25:02.907
cmqnkz3oh00lvlx9awtj0hjyg	Cetaphil	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cetaphil.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.945	2026-06-21 09:25:02.945
cmqnkz3p200lxlx9anayy5xtl	CeraVe	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://cerave.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.967	2026-06-21 09:25:02.967
cmqnkz3tp00mblx9a49skpbrm	Vanish	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7LiVOb20H1TxdIsFaYST6LJfElUGJH6r0Mw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.133	2026-06-21 10:05:46.531
cmqnkz3t600m9lx9a8jmh1fwy	Lizol	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLyPwyEszncgg8RZAgooMRdpZV3U_Hux-Q3Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.114	2026-06-21 10:06:22.84
cmqnkz3sp00m7lx9airbqiupn	Harpic	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://eu-images.contentstack.com/v3/assets/blt5088c07559fc83f1/blt00fa179afe639f39/670ce72f1690d657948d93f7/harpic_new_logo_(1).png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.098	2026-06-21 10:06:47.376
cmqnkz3ry00m5lx9alb5re37a	Dettol	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmwJqOYkXLKEdAvla8ZCuyImbZVmqMxg2hJQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.07	2026-06-21 10:07:58.619
cmqnkz3rf00m3lx9a8qtxwbni	Durex	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfNjxW_sgvUfvvfRy9VL9Yi-kocgi7R2tVzg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.051	2026-06-21 10:08:19.348
cmqnkz3q900lzlx9ah3qhexzy	Bioderma	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSF0CVKMCyZUWEibqk2z5usw7ZMZ94VDGM-7g&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.009	2026-06-21 10:09:03.891
cmqnkz3eq00l3lx9a1yvk0oo4	Vatika	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://mir-s3-cdn-cf.behance.net/projects/404/d5e43f93315841.Y3JvcCwxMzgwLDEwODAsMjcwLDA.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.594	2026-06-21 10:14:41.536
cmqnkz3x900mnlx9avkqhn6fl	Palmolive	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://palmolive.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.261	2026-06-21 09:25:03.261
cmqnkz41e00n3lx9atc6ameqm	Apple	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://apple.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.41	2026-06-21 09:25:03.41
cmqnkz41t00n5lx9a4ymj5lae	Xiaomi	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mi.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.425	2026-06-21 09:25:03.425
cmqnkz42800n7lx9ai0a2v3qi	Redmi	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://mi.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.441	2026-06-21 09:25:03.441
cmqnkz42p00n9lx9aou8d00zw	POCO	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://po.co	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.458	2026-06-21 09:25:03.458
cmqnkz43500nblx9a6p9qf5y1	Realme	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://realme.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.473	2026-06-21 09:25:03.473
cmqnkz43k00ndlx9a3ka0gemr	Oppo	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://oppo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.488	2026-06-21 09:25:03.488
cmqnkz43z00nflx9anwtysacb	Vivo	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://vivo.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.504	2026-06-21 09:25:03.504
cmqnkz44e00nhlx9a1ye898oj	OnePlus	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://oneplus.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.518	2026-06-21 09:25:03.518
cmqnkz44u00njlx9ao7h0hzho	Huawei	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://huawei.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.534	2026-06-21 09:25:03.534
cmqnkz45800nllx9ab5blz2mn	Honor	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://honor.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.548	2026-06-21 09:25:03.548
cmqnkz45q00nnlx9alq3uhavf	Nokia	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nokia.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.566	2026-06-21 09:25:03.566
cmqnkz46400nplx9akzl2vqed	Motorola	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://motorola.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.58	2026-06-21 09:25:03.58
cmqnkz46i00nrlx9at93l2n8b	Tecno	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://tecno-mobile.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.595	2026-06-21 09:25:03.595
cmqnkz47000ntlx9aokh6sjwt	Infinix	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://infinixmobility.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.612	2026-06-21 09:25:03.612
cmqnkz47j00nvlx9ahrxoe96h	Itel	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://itel-life.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.631	2026-06-21 09:25:03.631
cmqnkz40100mxlx9a4ytkv6p0	Fogg	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR22V8CnIeDoNwEHffq4uXCN0txXG6z3n4D6w&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.361	2026-06-21 10:00:15.829
cmqnkz3zh00mvlx9a7u1dvvvc	Enchanteur	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR02G0cdDUHDGcv_KwFNm7CEQfHXXxwK7jELg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.341	2026-06-21 10:01:13.65
cmqnkz3yw00mtlx9a881pnaxe	Listerine	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/5/56/Listerine_logo.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.32	2026-06-21 10:01:56.381
cmqnkz3xu00mplx9aqrgd68et	Sensodyne	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://w7.pngwing.com/pngs/649/78/png-transparent-sensodyne-logo-product-logos.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.282	2026-06-21 10:03:00.423
cmqnkz3wu00mllx9ayfr5iuer	Colgate	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Colgate.svg/1280px-Colgate.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.246	2026-06-21 10:03:34.294
cmqnkz3wc00mjlx9a2zd9fth5	Strepsils	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdEa3JXm72hM8Hp_F1vuUz49afhOwfhGJl-Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.228	2026-06-21 10:04:03.042
cmqnkz3vs00mhlx9a2kfpq2w0	Veet	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSh5ZseGAbb2xeRUK7K33rD4X2o5hZpHOYe0g&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.206	2026-06-21 10:04:35.466
cmqnkz3uy00mflx9a3u6ui9zj	Mortein	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://cdn.cookielaw.org/logos/402f6106-e8f6-48e2-9a63-c8534c7b1778/019b275e-e0df-7c3d-b7b1-084b081d8ec3/4c9b5db1-77e3-4c36-aff3-5c0a962eb8eb/mortein-logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.178	2026-06-21 10:05:01.734
cmqnkz40y00n1lx9awiiszji4	Samsung	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/6/61/Samsung_old_logo_before_year_2015.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.394	2026-06-21 10:13:40.864
cmqnkz48z00o1lx9aqiwvsoca	LG	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://lg.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.683	2026-06-21 09:25:03.683
cmqnkz4ci00odlx9arpbhdq8o	Hisense	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hisense.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.81	2026-06-21 09:25:03.81
cmqnkz4d500oflx9asxq4nnbj	Haier	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://haier.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.834	2026-06-21 09:25:03.834
cmqnkz4dn00ohlx9a9b851gn4	Whirlpool	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://whirlpool.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.851	2026-06-21 09:25:03.851
cmqnkz4e200ojlx9a6krdnfsh	Midea	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://midea.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.867	2026-06-21 09:25:03.867
cmqnkz4el00ollx9a5ms05xwp	Gree	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://gree.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.885	2026-06-21 09:25:03.885
cmqnkz4fi00onlx9a4cy7vvhy	General	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://fujitsu-general.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.918	2026-06-21 09:25:03.918
cmqnkz4hn00otlx9a5f84bzn2	Nikon	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nikon.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.995	2026-06-21 09:25:03.995
cmqnkz4i800ovlx9att3bme77	Fujifilm	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://fujifilm.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.017	2026-06-21 09:25:04.017
cmqnkz4k600p1lx9aowl0gv5t	HP	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hp.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.087	2026-06-21 09:25:04.087
cmqnkz4kp00p3lx9asnm9xlqd	Dell	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dell.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.106	2026-06-21 09:25:04.106
cmqnkz4mq00p9lx9axh90k1oe	Acer	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://acer.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.178	2026-06-21 09:25:04.178
cmqnkz4q000pflx9ayjkal7d1	Intel	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://intel.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.297	2026-06-21 09:25:04.297
cmqnkz4pf00pdlx9ag78crou1	Gigabyte	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://images.seeklogo.com/logo-png/26/1/gigabyte-logo-png_seeklogo-264946.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.275	2026-06-21 09:53:21.69
cmqnkz4og00pblx9aqaz2e8zc	MSI	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/1/13/Msi-Logo.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.241	2026-06-21 09:53:48.936
cmqnkz4lo00p7lx9aczwbqiis	Asus	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/d/de/AsusTek-black-logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.14	2026-06-21 09:55:16.282
cmqnkz4l700p5lx9ave0zdmwy	Lenovo	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Lenovo_Global_Corporate_Logo.png/3840px-Lenovo_Global_Corporate_Logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.123	2026-06-21 09:55:41.462
cmqnkz4h000orlx9a8hwtv0y5	Canon	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Canon_logo.svg/1280px-Canon_logo.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.973	2026-06-21 10:09:47.37
cmqnkz4g500oplx9a2l2paky4	Daikin	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/DAIKIN_logo.svg/3840px-DAIKIN_logo.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.941	2026-06-21 10:10:16.208
cmqnkz4bf00o9lx9apynaw8jy	Toshiba	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSz4iTxFVEXBgZSnE2HRNXND92IdWN_olJ0Gg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.771	2026-06-21 10:11:01.936
cmqnkz4ay00o7lx9aty0rdma4	Philips	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZYeOS78xTRBaTCf8mrdiVUw5MUi43gb_aFg&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.752	2026-06-21 10:11:29.265
cmqnkz4a800o5lx9a7zsbkcad	Sharp	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/c/c8/Logo_of_the_Sharp_Corporation.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.728	2026-06-21 10:11:54.098
cmqnkz49g00o3lx9a6rjzuqli	Panasonic	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7zhC6t6fkm1ALVlfLYwNnRERnKVdKydnn0w&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.7	2026-06-21 10:12:13.238
cmqnkz48j00nzlx9akpryd8eq	Sony	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.667	2026-06-21 10:12:37.645
cmqnkz48100nxlx9a0e9kjpii	Nothing	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://cdn.nothing.community/2025-12-14/1765733320-179713-nothing-01.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.649	2026-06-21 10:13:10.13
cmqnkz4rd00pjlx9alo1xt7qx	NVIDIA	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://nvidia.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.346	2026-06-21 09:25:04.346
cmqnkz4sb00pllx9ahshn5xpj	Logitech	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://logitech.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.379	2026-06-21 09:25:04.379
cmqnkz4yk00q5lx9az58q0afh	Transcend	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://transcend-info.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.604	2026-06-21 09:25:04.604
cmqnkz4z000q7lx9a9trw5yld	ADATA	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://w7.pngwing.com/pngs/502/545/png-transparent-adata-hd-logo-thumbnail.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.62	2026-06-21 09:46:51.689
cmqnkz4y300q3lx9adw0463du	Seagate	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.seagate.com/content/dam/seagate/assets/stories/media-assets/company-logos/seagate_PMS_stacked_pos.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.587	2026-06-21 09:47:21.732
cmqnkz4xc00q1lx9adhnj41g0	Western Digital	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://w7.pngwing.com/pngs/46/437/png-transparent-western-digital-my-book-hard-drives-my-cloud-hgst-others-blue-text-digital.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.561	2026-06-21 09:47:54.814
cmqnkz4wv00pzlx9ae4v9s3gm	SanDisk	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.logo.wine/a/logo/SanDisk/SanDisk-Logo.wine.svg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.543	2026-06-21 09:48:27.94
cmqnkz4wc00pxlx9az2i23bqo	Kingston	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6gLQ46yYmzgr9Eem6y2Gjq3eTc4Enl5PDew&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.524	2026-06-21 09:49:02.102
cmqnkz4vg00pvlx9a77h70vsg	Corsair	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK7HxPKivG9Zq16GNTcdKQDVg60OYQnP3QYw&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.492	2026-06-21 09:49:32.357
cmqnkz4uw00ptlx9a82xc8a9x	Razer	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://1000logos.net/wp-content/uploads/2019/09/Razer-logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.47	2026-06-21 09:50:22.551
cmqnkz4u300prlx9a6cmqscbz	Fantech	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.jayacom.my/image/jayacom/image/data/AIMAN/lfQgJaJ11616658983.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.443	2026-06-21 09:50:53.623
cmqnkz4tg00pplx9ap2r2k30o	A4Tech	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://img.favpng.com/18/12/8/a4tech-logo-stuNekAX.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.42	2026-06-21 09:51:48.073
cmqnkz4sx00pnlx9acsadykzv	Rapoo	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://images.seeklogo.com/logo-png/52/3/rapoo-logo-png_seeklogo-524126.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.401	2026-06-21 09:52:17.117
cmqnkz59r00rblx9acsa3ssj5	Hikvision	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://hikvision.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:05.007	2026-06-21 09:25:05.007
cmqnkz5a900rdlx9ajbnwam2s	Dahua	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://dahuasecurity.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:05.025	2026-06-21 09:25:05.025
cmqnkz5ap00rflx9a101krxnv	Ezviz	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://www.google.com/s2/favicons?sz=128&domain_url=https://ezviz.com	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:05.041	2026-06-21 09:25:05.041
cmqnkz5b400rhlx9ad08i6n6h	Imou	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://brandlogos.net/wp-content/uploads/2025/03/imou-logo_brandlogos.net_i0qhd.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:05.056	2026-06-21 09:34:31.659
cmqnkz57500r3lx9a1luxla1p	Tenda	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://w7.pngwing.com/pngs/253/559/png-transparent-tenda-hd-logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.913	2026-06-21 09:35:50.061
cmqnkz54r00qtlx9awafq2o5o	Edifier	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMOJq7lF65eNQ45-FI1ReTfh5eS1fpqI2ZTQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.827	2026-06-21 09:43:09.76
cmqnkz4qn00phlx9a4te0c5u7	AMD	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://1000logos.net/wp-content/uploads/2020/05/AMD-Logo.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:04.319	2026-06-21 09:52:55.137
cmqnkz40i00mzlx9a9d32dyau	Nihar	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnD8AAc_TF4wmpxig-iPtEWbotDhlf22kImQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.378	2026-06-21 09:59:03.81
cmqnkz3ye00mrlx9awk14l5ag	Aquafresh	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLgqA7tA4cRyLkhipcw18wrAdW5l537q_-vA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.303	2026-06-21 10:02:24.421
cmqnkz3ua00mdlx9awwt4jzsq	Air Wick	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://p7.hiclipart.com/preview/310/243/784/air-wick-air-fresheners-reckitt-benckiser-aerosol-spray-rose-air-wick.jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.154	2026-06-21 10:05:25.357
cmqnkz3qx00m1lx9agc2uq2tw	La Roche-Posay	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/La_Roche-Posay_%28brand%29.svg/3840px-La_Roche-Posay_%28brand%29.svg.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.034	2026-06-21 10:08:42.358
cmqnkz4bz00oblx9alrwr2ax5	Hitachi	International Electronics/Tech sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_FQpwO1xbIIVYnnvT25-U3_9MM-UhDbR5Ag&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:03.791	2026-06-21 10:10:42.178
cmqnkz3d600kxlx9adzjlhl5b	Whisper	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://banner2.cleanpng.com/20180520/ica/avqjvlwi3.webp	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.538	2026-06-21 10:15:16.102
cmqnkz36000k7lx9asw0i862o	Domex	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://www.unilever.com.bd/content-images/92ui5egz/production/66a5f18cc6d8f88cd0e771530b602931997e55a9-1080x1080.png?rect=0,257,1080,567&w=1200&h=630&fm=jpg	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:02.28	2026-06-21 10:18:24.478
cmqnkz2xe00jllx9a0jl67gk3	Closeup	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://cdn2.arogga.com/eyJidWNrZXQiOiJhcm9nZ2EiLCJrZXkiOiJQcm9kdWN0QnJhbmQtcGJfYmFubmVyXC8xMDA4NTlcLzEwMDg1OS1DbG9zZXVwLXgwcTBuci5wbmciLCJlZGl0cyI6W119	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.971	2026-06-21 10:22:10.074
cmqnkz2v300jdlx9aq1yrq2j1	Lifebuoy	International Personal Care/Cleaning sold in BD brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFLOD-ubAWY6xcDbwevtfmFa4GusyaqgSdiA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:25:01.887	2026-06-21 10:23:39.498
cmqnc6tyz000hlxvsvyc2jrr9	Fresh	Dairy & Grocery Products	https://bbf.digital/wp-content/uploads/2016/01/Fresh-1.jpg	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.067	2026-06-21 10:43:02.962
cmqnkywqy001dlx9at5ypshzj	Mama Noodles	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7SOwykDXJty78CqMkcjaCy4s9khEH7EaM8Q&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:53.962	2026-06-21 10:48:49.622
cmqnkyxos002vlx9apy46zprn	Meridian	Bangladesh FMCG/Food & Beverage brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIFoBYDXQrjvfIMGvCKL0JE3koCrQoXjeXZA&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.18	2026-06-21 10:58:50.316
cmqnkyy76004dlx9aqipvpv9u	Savlon Bangladesh	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWIbJNqN1v8WdgGk57IxxW9nPUR4ujeuytZQ&s	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.843	2026-06-21 11:09:53.129
cmqnkyy9e004jlx9azuad6o74	Finis	Bangladesh Household/Toiletries/Personal Care brand commonly used/sold in Bangladesh market	https://ibos.io/wp-content/uploads/2022/12/FINIS-has-signed-agreement-for-PeopleDesk-with-iBOS-Limited-e1709619500559.png	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 09:24:55.922	2026-06-21 11:11:39.12
\.


--
-- Data for Name: category_logs; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.category_logs (id, category_id, action, old_data, new_data, performed_by, created_at) FROM stdin;
cmr693jb7001zw8l3cpo2dxjs	cmr693jb2001xw8l3cqbj9ka3	CREATED	\N	{"name": "sakib", "shopId": "cmr0gdhu7005kw8g06c2lngfc", "status": "ACTIVE", "isGlobal": false, "isApproved": false, "description": "sdfasfdsfaf"}	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:00:11.775
\.


--
-- Data for Name: customer_ledgers; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.customer_ledgers (id, shop_id, customer_id, entry_type, customer_sale_id, customer_payment_id, reference_no, debit, credit, notes, entry_date, created_at) FROM stdin;
cmqtf1e6p0026lxj693skx31u	cmqtek0us0002lxj6zzrnqalp	cmqtf1e610024lxj6b04g862g	OPENING_DUE	\N	\N	\N	0.00	0.00	Linked customer to shop during sale checkout	2026-06-25 11:25:29.231	2026-06-25 11:25:29.233
cmqw3owlo002clxug0odpr742	cmqtek0us0002lxj6zzrnqalp	cmqtf1e610024lxj6b04g862g	SALE	cmqw3owkm0027lxugwbjjro4j	\N	order-1782549068656150	230.00	0.00	\N	2026-06-27 08:31:09.21	2026-06-27 08:31:09.325
cmqw3owm5002glxugd44t1c34	cmqtek0us0002lxj6zzrnqalp	cmqtf1e610024lxj6b04g862g	PAYMENT	cmqw3owkm0027lxugwbjjro4j	cmqw3owlx002elxug8l86c96g	order-1782549068656150	0.00	230.00	\N	2026-06-27 08:31:09.21	2026-06-27 08:31:09.341
cmqw8h8oj003ilx9fs8d2rl8k	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	OPENING_DUE	\N	\N	REG-SAJIB-978811	500.00	0.00	প্রারম্ভিক বকেয়া	2026-06-27 10:45:09.808	2026-06-27 10:45:09.811
cmqxfmeot004ilxgfj95j3poc	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	SALE	cmqxfmenl004dlxgfzegearqc	\N	order-1782629573050284	115.00	0.00	\N	2026-06-28 06:52:54.228	2026-06-28 06:52:54.365
cmqxiie6p005alx0bqg39vjpe	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	SALE	cmqxiie5p0055lx0b1ofzi029	\N	order-1782634425172502	115.00	0.00	\N	2026-06-28 08:13:45.806	2026-06-28 08:13:45.938
cmqxny79x0003lxzdcsuvliq1	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	PAYMENT	\N	cmqxny77a0001lxzd3o4k6g8m	TEST-PAY	0.00	100.00	\N	2026-06-28 10:46:01.556	2026-06-28 10:46:01.557
cmr0f1xbc002ww8g0iesx96vi	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	SALE	cmr0f1xay002rw8g01c2ysu5o	\N	order-1782810016873499	115.00	0.00	\N	2026-06-30 09:00:17.215	2026-06-30 09:00:17.256
cmr0gioe4005yw8g0lvniu58v	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	OPENING_DUE	\N	\N	REG-DID-842526	100.00	0.00	প্রারম্ভিক বকেয়া	2026-06-30 09:41:18.457	2026-06-30 09:41:18.458
cmr0gjh5i0061w8g0axguhlzx	cmr0gdhu7005kw8g06c2lngfc	cmr0gjh5a005zw8g05zjs8d5m	OPENING_DUE	\N	\N	REG-RRR-572477	300.00	0.00	প্রারম্ভিক বকেয়া	2026-06-30 09:41:55.733	2026-06-30 09:41:55.734
cmr0gkggu0065w8g0jb9zseif	cmr0gdhu7005kw8g06c2lngfc	cmr0gjh5a005zw8g05zjs8d5m	PAYMENT	\N	cmr0gkggj0063w8g0x3l3pluz	RRR-572477	0.00	300.00	Due payment collected via Mobile UI	2026-06-30 09:42:41.368	2026-06-30 09:42:41.502
cmr0glvx00069w8g0sh234mwr	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	PAYMENT	\N	cmr0glvwd0067w8g0fsr78ibs	DID-842526	0.00	100.00	Due payment collected via Mobile UI	2026-06-30 09:43:48.047	2026-06-30 09:43:48.18
cmr0gmstd006cw8g0dslyxmha	cmr0gdhu7005kw8g06c2lngfc	cmr0gmst3006aw8g0mj6044cw	OPENING_DUE	\N	\N	REG-EEE-080190	22.00	0.00	প্রারম্ভিক বকেয়া	2026-06-30 09:44:30.816	2026-06-30 09:44:30.817
cmr0gn1hm006gw8g083fgclu3	cmr0gdhu7005kw8g06c2lngfc	cmr0gmst3006aw8g0mj6044cw	PAYMENT	\N	cmr0gn1h8006ew8g0lj5aqrz5	EEE-080190	0.00	22.00	Due payment collected via Mobile UI	2026-06-30 09:44:41.963	2026-06-30 09:44:42.059
cmr0go0bn006jw8g00wzznoix	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	OPENING_DUE	\N	\N	REG-FFF-718961	200.00	0.00	প্রারম্ভিক বকেয়া	2026-06-30 09:45:27.202	2026-06-30 09:45:27.204
cmr0go9zq006mw8g07cvvhqi2	cmr0gdhu7005kw8g06c2lngfc	cmr0go9zm006kw8g06xsi3i2b	OPENING_DUE	\N	\N	REG-TTT-972652	100.00	0.00	প্রারম্ভিক বকেয়া	2026-06-30 09:45:39.733	2026-06-30 09:45:39.734
cmr0gyn6j006qw8g0b56okl43	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	PAYMENT	\N	cmr0gyn6b006ow8g0eh62cro4	FFF-718961	0.00	100.00	Due payment collected via Mobile UI	2026-06-30 09:53:43.295	2026-06-30 09:53:43.388
cmr0jifxz000zw8s3g6zd17tp	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	OPENING_DUE	\N	\N	\N	0.00	0.00	Linked customer to shop during sale checkout	2026-06-30 11:05:06.357	2026-06-30 11:05:06.358
cmr0jig1g001gw8s327rc1zeb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr0jig0y0011w8s3kobfd8t8	\N	order-1782817506202494	465.00	0.00	\N	2026-06-30 11:05:06.373	2026-06-30 11:05:06.485
cmr0jig1q001kw8s3goqp9drs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr0jig0y0011w8s3kobfd8t8	cmr0jig1i001iw8s3k3bhv65n	order-1782817506202494	0.00	465.00	\N	2026-06-30 11:05:06.373	2026-06-30 11:05:06.495
cmr1no4pc0003w8xnmhx387fz	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	OPENING_DUE	\N	\N	\N	0.00	0.00	Linked customer to shop during sale checkout	2026-07-01 05:49:16.366	2026-07-01 05:49:16.367
cmr1no4ua000ew8xnjc0z7ri8	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	SALE	cmr1no4sf0005w8xngt8jjzub	\N	order-1782884956237169	260.00	0.00	\N	2026-07-01 05:49:16.394	2026-07-01 05:49:16.547
cmr1no4ul000iw8xnxx3d8uiz	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	PAYMENT	cmr1no4sf0005w8xngt8jjzub	cmr1no4uc000gw8xncr8mr1vk	order-1782884956237169	0.00	260.00	\N	2026-07-01 05:49:16.394	2026-07-01 05:49:16.557
cmr1nslh9000rw8xnpyqrkffn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr1nslf7000kw8xnal3umoza	\N	order-1782885164491997	120.00	0.00	\N	2026-07-01 05:52:44.632	2026-07-01 05:52:44.733
cmr1nslhd000vw8xnt42n29pn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr1nslf7000kw8xnal3umoza	cmr1nslhb000tw8xn5dfna9v1	order-1782885164491997	0.00	20.00	\N	2026-07-01 05:52:44.632	2026-07-01 05:52:44.737
cmr1o9zze0016w8xnpfc4fllg	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	SALE	cmr1o9zyu000zw8xncty4nm7k	\N	order-1782885976431074	120.00	0.00	\N	2026-07-01 06:06:16.57	2026-07-01 06:06:16.682
cmr1oh70p001lw8xngqfojz9t	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	SALE	cmr1oh6zz0018w8xnimfbggnk	\N	order-1782886311925459	360.00	0.00	\N	2026-07-01 06:11:52.276	2026-07-01 06:11:52.394
cmr1oi6l5001ow8xnha9l8cuk	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	OPENING_DUE	\N	\N	REG-SAKIB-847203	0.00	0.00	গ্রাহক নিবন্ধন	2026-07-01 06:12:38.489	2026-07-01 06:12:38.49
cmr1oidml001xw8xn24dvfq1h	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	SALE	cmr1oidm6001qw8xngi8dedjm	\N	order-1782886367340247	120.00	0.00	\N	2026-07-01 06:12:47.528	2026-07-01 06:12:47.613
cmr1ok9y80020w8xn13wnwnrz	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	OPENING_DUE	\N	\N	REG-MONJUR-614867	0.00	0.00	গ্রাহক নিবন্ধন	2026-07-01 06:14:16.159	2026-07-01 06:14:16.16
cmr1okhb70029w8xnkvgb0qh6	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr1okhaa0022w8xn2jd7fnjv	\N	order-1782886464811078	120.00	0.00	\N	2026-07-01 06:14:25.473	2026-07-01 06:14:25.7
cmr1oyp4s002fw8xnulg1doxl	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	PAYMENT	\N	cmr1oyp3d002dw8xnma5z1p5v	FFF-718961	0.00	50.00	Due payment collected via Mobile UI	2026-07-01 06:25:28.751	2026-07-01 06:25:29.018
cmr1oze3k002jw8xnor6t18ww	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	PAYMENT	\N	cmr1oze2r002hw8xntex6fepf	FFF-718961	0.00	50.00	Due payment collected via Mobile UI	2026-07-01 06:25:59.615	2026-07-01 06:26:01.377
cmr1p8hp5002pw8xnw2mgdh8s	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr1p8hof002nw8xnnr1g8er4	MONJUR-614867	0.00	20.00	Due payment collected via Mobile UI	2026-07-01 06:33:05.397	2026-07-01 06:33:05.944
cmr1pebu3002yw8xnxcte9lr4	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr1pebtd002rw8xn1jj2kt77	\N	order-1782887857899575	120.00	0.00	\N	2026-07-01 06:37:38.193	2026-07-01 06:37:38.283
cmr1pftgh003hw8xndzbg1kxl	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr1pftau0030w8xnssm2a49w	\N	order-1782887927325817	530.00	0.00	\N	2026-07-01 06:38:47.416	2026-07-01 06:38:47.777
cmr1pg4x0003lw8xnjn204zwp	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr1pg4wq003jw8xnajyyuwvo	MONJUR-614867	0.00	500.00	Due payment collected via Mobile UI	2026-07-01 06:39:02.548	2026-07-01 06:39:02.628
cmr1phigy003pw8xn56a02kid	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr1phigm003nw8xnqzvoxhdn	MONJUR-614867	0.00	100.00	Due payment collected via Mobile UI	2026-07-01 06:40:06.761	2026-07-01 06:40:06.851
cmr1pio3l004aw8xn26nihpzd	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr1pinxr003rw8xn6rmhpkbk	\N	order-1782888060390645	620.00	0.00	\N	2026-07-01 06:41:00.471	2026-07-01 06:41:00.801
cmr1pj6lb004ew8xn6ybn1375	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr1pj6l6004cw8xnl7mvdgzb	MONJUR-614867	0.00	500.00	Due payment collected via Mobile UI	2026-07-01 06:41:24.673	2026-07-01 06:41:24.768
cmr1pjlui004iw8xn96nbki2y	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr1pjlu7004gw8xneg1xuow3	MONJUR-614867	0.00	270.00	Due payment collected via Mobile UI	2026-07-01 06:41:44.445	2026-07-01 06:41:44.538
cmr1ppymi004mw8xn2wkjqgk4	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	\N	cmr1ppylz004kw8xn6a28wvf7	GUESTC-917913	0.00	100.00	Due payment collected via Mobile UI	2026-07-01 06:46:40.941	2026-07-01 06:46:41.035
cmr1q43r40003w8kngncaawz2	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	PAYMENT	\N	cmr1q43px0001w8knljamu5l1	DID-842526	0.00	360.00	Due payment collected via Mobile UI	2026-07-01 06:57:40.689	2026-07-01 06:57:40.864
cmr2zrnux00b5w82p32jboehq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr2zrnuj00ayw82p28oypxwf	\N	order-1782965742623287	80.00	0.00	\N	2026-07-02 04:15:42.683	2026-07-02 04:15:42.729
cmr2zrnv900b9w82pr5yh00iy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr2zrnuj00ayw82p28oypxwf	cmr2zrnv200b7w82ppp0ehbxm	order-1782965742623287	0.00	80.00	\N	2026-07-02 04:15:42.683	2026-07-02 04:15:42.742
cmr2zscug00c6w82pjtgn1sye	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr2zscu400bzw82pv10yb4mg	\N	order-1782965775034919	80.00	0.00	\N	2026-07-02 04:16:15.071	2026-07-02 04:16:15.112
cmr2zscul00caw82psgrsqjdk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr2zscu400bzw82pv10yb4mg	cmr2zscui00c8w82ptm3k3qhq	order-1782965775034919	0.00	80.00	\N	2026-07-02 04:16:15.071	2026-07-02 04:16:15.117
cmr31oagd0020w8fuj5aai6px	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr31oafs001vw8fu7txff0d0	\N	order-1782968944530467	40.00	0.00	\N	2026-07-02 05:09:04.578	2026-07-02 05:09:04.621
cmr31oago0024w8fuhbh5b3fb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr31oafs001vw8fu7txff0d0	cmr31oagj0022w8fucak20fu0	order-1782968944530467	0.00	40.00	\N	2026-07-02 05:09:04.578	2026-07-02 05:09:04.632
cmr31qgyd0035w8fu4cujxipy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr31qgxv0030w8fuijd3gq0m	\N	order-1782969046286832	240.00	0.00	\N	2026-07-02 05:10:46.327	2026-07-02 05:10:46.357
cmr31qgym0039w8fujlhv5o3r	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr31qgxv0030w8fuijd3gq0m	cmr31qgyi0037w8fugg9cpaok	order-1782969046286832	0.00	240.00	\N	2026-07-02 05:10:46.327	2026-07-02 05:10:46.366
cmr31s2lj003yw8fu5x1n55h5	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr31s2l5003tw8fux6usv7ok	\N	order-1782969120955758	1240.00	0.00	\N	2026-07-02 05:12:01.037	2026-07-02 05:12:01.063
cmr31s2lq0042w8fue9j90e5z	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr31s2l5003tw8fux6usv7ok	cmr31s2ln0040w8fud9pqo3jn	order-1782969120955758	0.00	1240.00	\N	2026-07-02 05:12:01.037	2026-07-02 05:12:01.071
cmr3255im005fw8fu7jajmx1v	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr3255i30058w8fub48dq6ol	\N	order-1782969730744493	200.00	0.00	\N	2026-07-02 05:22:11.148	2026-07-02 05:22:11.375
cmr3255it005jw8fuko6zozmm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr3255i30058w8fub48dq6ol	cmr3255ip005hw8fudrddsa0e	order-1782969730744493	0.00	200.00	\N	2026-07-02 05:22:11.148	2026-07-02 05:22:11.382
cmr328k95007cw8fud6zila1h	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr328k8o0077w8fupldcu09r	\N	order-1782969890336516	120.00	0.00	\N	2026-07-02 05:24:50.405	2026-07-02 05:24:50.441
cmr328k9d007gw8fu1f7qohyw	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr328k8o0077w8fupldcu09r	cmr328k99007ew8fu786tvwvl	order-1782969890336516	0.00	120.00	\N	2026-07-02 05:24:50.405	2026-07-02 05:24:50.45
cmr32ceb9008zw8fufijydlo1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr32ceaj008uw8fux35w5uur	\N	order-1782970069263492	40.00	0.00	\N	2026-07-02 05:27:49.32	2026-07-02 05:27:49.365
cmr32cebg0093w8fuibziwv5q	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr32ceaj008uw8fux35w5uur	cmr32cebd0091w8fugv6rt49x	order-1782970069263492	0.00	40.00	\N	2026-07-02 05:27:49.32	2026-07-02 05:27:49.372
cmr32e28u009kw8fu58xdz74m	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr32e26y009fw8fuun6fzbyj	\N	order-1782970146794165	80.00	0.00	\N	2026-07-02 05:29:06.949	2026-07-02 05:29:07.038
cmr32e298009ow8fuz0m0o7er	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr32e26y009fw8fuun6fzbyj	cmr32e293009mw8fu1uf5lg6q	order-1782970146794165	0.00	80.00	\N	2026-07-02 05:29:06.949	2026-07-02 05:29:07.052
cmr32h9mf00azw8fug0harqly	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr32h9lm00auw8fu9ayyqcyz	\N	order-1782970296388461	40.00	0.00	\N	2026-07-02 05:31:36.505	2026-07-02 05:31:36.567
cmr32h9nn00b3w8fub28uxydu	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr32h9lm00auw8fu9ayyqcyz	cmr32h9nk00b1w8futpsxqgl2	order-1782970296388461	0.00	40.00	\N	2026-07-02 05:31:36.505	2026-07-02 05:31:36.612
cmr33onwm00cww8fufziamumz	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	SALE	cmr33onsq00crw8fukjgzra0y	\N	order-1782972320673438	40.00	0.00	\N	2026-07-02 06:05:21.097	2026-07-02 06:05:21.286
cmr33qolf00dzw8fuygten06j	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr33qohd00duw8fuf0fun1r2	\N	order-1782972415271005	120.00	0.00	\N	2026-07-02 06:06:55.293	2026-07-02 06:06:55.491
cmr37ybul00bcw8yovbcdhda9	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr37ybtt00avw8yo9ja0diki	\N	order-1782979490408070	990.00	0.00	\N	2026-07-02 08:04:50.521	2026-07-02 08:04:50.685
cmr37ybur00bgw8yoctgh4f76	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr37ybtt00avw8yo9ja0diki	cmr37ybuo00bew8yosmk7nyxt	order-1782979490408070	0.00	990.00	\N	2026-07-02 08:04:50.521	2026-07-02 08:04:50.691
cmr37yvub00cdw8yoqqm7h4ul	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr37yvu100c8w8yoitpqhsgx	\N	order-1782979516530188	880.00	0.00	\N	2026-07-02 08:05:16.573	2026-07-02 08:05:16.595
cmr37yvui00chw8yoys15n1vw	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr37yvu100c8w8yoitpqhsgx	cmr37yvuf00cfw8yo16lx4vya	order-1782979516530188	0.00	880.00	\N	2026-07-02 08:05:16.573	2026-07-02 08:05:16.603
cmr38lhs10070w896n7ii7a53	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr38lhk8006vw896c2xboxoc	\N	order-1782980571008090	500.00	0.00	\N	2026-07-02 08:22:51.142	2026-07-02 08:22:51.458
cmr38lhsf0074w8967hl32lib	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr38lhk8006vw896c2xboxoc	cmr38lhs80072w896gvxiz015	order-1782980571008090	0.00	500.00	\N	2026-07-02 08:22:51.142	2026-07-02 08:22:51.471
cmr38ur4q00bkw896bfl899l8	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr38ur0m00bfw896rwkp0xor	\N	order-1782981003161065	600.00	0.00	\N	2026-07-02 08:30:03.29	2026-07-02 08:30:03.482
cmr38ur7100bow896uhqizlyh	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr38ur0m00bfw896rwkp0xor	cmr38ur6m00bmw896n55k4oc7	order-1782981003161065	0.00	550.00	\N	2026-07-02 08:30:03.29	2026-07-02 08:30:03.565
cmr394f1j00dnw896u42lpvqa	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr394f0x00diw89684amqowy	\N	order-1782981454228054	1200.00	0.00	\N	2026-07-02 08:37:34.311	2026-07-02 08:37:34.375
cmr394f1q00drw896eoknjpxp	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr394f0x00diw89684amqowy	cmr394f1m00dpw896jcjwu7s7	order-1782981454228054	0.00	1200.00	\N	2026-07-02 08:37:34.311	2026-07-02 08:37:34.382
cmr398sii00eow8963cdpf9qm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr398sfz00ejw896c6pn0a2l	\N	order-1782981658225179	1000.00	0.00	\N	2026-07-02 08:40:58.35	2026-07-02 08:40:58.459
cmr398slr00esw896nzsuuihu	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr398sfz00ejw896c6pn0a2l	cmr398sl000eqw896io80u6dt	order-1782981658225179	0.00	1000.00	\N	2026-07-02 08:40:58.35	2026-07-02 08:40:58.576
cmr5t744m000mw8ohons1b3pm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t7440000hw8oh9jijldwg	\N	order-1782984223741471	2000.00	0.00	\N	2026-07-04 03:35:04.772	2026-07-04 03:35:04.871
cmr5t744x000qw8ohaw0ea0h0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t7440000hw8oh9jijldwg	cmr5t744s000ow8oh2omqoasy	order-1782984223741471	0.00	2000.00	\N	2026-07-04 03:35:04.772	2026-07-04 03:35:04.881
cmr5t74ba0011w8ohsc6imvko	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74b7000ww8ohlnovfe8c	\N	order-1782984429516632	2000.00	0.00	\N	2026-07-04 03:35:05.101	2026-07-04 03:35:05.111
cmr5t74bc0015w8ohtfkxcxno	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74b7000ww8ohlnovfe8c	cmr5t74bb0013w8ohukbln3eo	order-1782984429516632	0.00	2000.00	\N	2026-07-04 03:35:05.101	2026-07-04 03:35:05.113
cmr5t74cg001mw8ohcrz8k5dq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74cc001hw8ohqnga9y5s	\N	order-1782988352184264	1400.00	0.00	\N	2026-07-04 03:35:05.137	2026-07-04 03:35:05.153
cmr5t74cj001qw8ohnk86ytvy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74cc001hw8ohqnga9y5s	cmr5t74ch001ow8oh66p5gt4o	order-1782988352184264	0.00	1400.00	\N	2026-07-04 03:35:05.137	2026-07-04 03:35:05.155
cmr5t74ex0027w8ohzzlf8nhd	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74eu0020w8oh96w6nn2e	\N	order-1782988765786637	450.00	0.00	\N	2026-07-04 03:35:05.214	2026-07-04 03:35:05.242
cmr5t74f0002bw8ohnls6g5zt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74eu0020w8oh96w6nn2e	cmr5t74ey0029w8ohaoqspvut	order-1782988765786637	0.00	450.00	\N	2026-07-04 03:35:05.214	2026-07-04 03:35:05.244
cmr5t74gl002ow8ohbs7q5d0h	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74fv002hw8ohmtpbzdwn	\N	order-1782989488117954	1785.00	0.00	\N	2026-07-04 03:35:05.265	2026-07-04 03:35:05.302
cmr5t74gv002sw8oho0roo890	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74fv002hw8ohmtpbzdwn	cmr5t74gm002qw8ohcskaviun	order-1782989488117954	0.00	1785.00	\N	2026-07-04 03:35:05.265	2026-07-04 03:35:05.311
cmr5t74ix0035w8ohcnpm4192	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74is002yw8oh5ewrx1d5	\N	order-1782989561900135	1050.00	0.00	\N	2026-07-04 03:35:05.353	2026-07-04 03:35:05.385
cmr5t74j00039w8oh7eao824e	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74is002yw8oh5ewrx1d5	cmr5t74iy0037w8ohn6ipdas1	order-1782989561900135	0.00	1050.00	\N	2026-07-04 03:35:05.353	2026-07-04 03:35:05.389
cmr5t74k9003kw8ohsnp5pv77	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74k6003fw8ohd5stmjlo	\N	order-1782989724275542	600.00	0.00	\N	2026-07-04 03:35:05.425	2026-07-04 03:35:05.433
cmr5t74kb003ow8ohsah8ofp7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74k6003fw8ohd5stmjlo	cmr5t74ka003mw8ohkfsh9yxr	order-1782989724275542	0.00	600.00	\N	2026-07-04 03:35:05.425	2026-07-04 03:35:05.436
cmr5t74n1003zw8ohg835vd81	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5t74mz003uw8ohjykya0u0	\N	order-1782989874728370	800.00	0.00	\N	2026-07-04 03:35:05.526	2026-07-04 03:35:05.533
cmr5t74n20043w8oht0hxjmtf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5t74mz003uw8ohjykya0u0	cmr5t74n10041w8ohsp555iab	order-1782989874728370	0.00	800.00	\N	2026-07-04 03:35:05.526	2026-07-04 03:35:05.535
cmr5tc8mp007ow8ohi6nck8wp	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5tc8mc007jw8oh3hyy1y8z	\N	order-1783136343914525	1375.00	0.00	\N	2026-07-04 03:39:03.947	2026-07-04 03:39:03.985
cmr5tc8ms007sw8ohyxd9bygh	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5tc8mc007jw8oh3hyy1y8z	cmr5tc8mq007qw8ohkfh06ty7	order-1783136343914525	0.00	1375.00	\N	2026-07-04 03:39:03.947	2026-07-04 03:39:03.988
cmr5tdejr008hw8ohm4s254av	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5tdejb008cw8ohwq77sfih	\N	order-1783136398210273	2625.00	0.00	\N	2026-07-04 03:39:58.264	2026-07-04 03:39:58.312
cmr5tdejy008lw8ohjvy4znak	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5tdejb008cw8ohwq77sfih	cmr5tdejv008jw8ohv9bu8wnk	order-1783136398210273	0.00	2625.00	\N	2026-07-04 03:39:58.264	2026-07-04 03:39:58.318
cmr5tg1rf009sw8oh06sg4uum	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5tg1qz009nw8oh4r4hxepw	\N	order-1783136521456132	1900.00	0.00	\N	2026-07-04 03:42:01.548	2026-07-04 03:42:01.708
cmr5tg1rk009ww8oh8pu5qaf6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5tg1qz009nw8oh4r4hxepw	cmr5tg1ri009uw8ohr4ou3qwm	order-1783136521456132	0.00	1900.00	\N	2026-07-04 03:42:01.548	2026-07-04 03:42:01.713
cmr5th1xd00ajw8ohr336b4ev	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5th1w400aew8oh4xqrw7bt	\N	order-1783136568435451	4150.00	0.00	\N	2026-07-04 03:42:48.482	2026-07-04 03:42:48.577
cmr5th1xi00anw8ohsipioncd	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5th1w400aew8oh4xqrw7bt	cmr5th1xg00alw8oh62npfrf2	order-1783136568435451	0.00	4150.00	\N	2026-07-04 03:42:48.482	2026-07-04 03:42:48.582
cmr5tjv7b00bqw8oh5xiodynk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5tjv6800bjw8ohaktljm9n	\N	order-1783136699638405	9250.00	0.00	\N	2026-07-04 03:44:59.698	2026-07-04 03:44:59.832
cmr5tjv7l00buw8ohg96gtvi9	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5tjv6800bjw8ohaktljm9n	cmr5tjv7i00bsw8ohfwbsaccu	order-1783136699638405	0.00	9250.00	\N	2026-07-04 03:44:59.698	2026-07-04 03:44:59.841
cmr5tz38g00czw8ohhmorpptf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5tz38000cuw8oht64glxo3	\N	order-1783137409956409	1000.00	0.00	\N	2026-07-04 03:56:50.011	2026-07-04 03:56:50.08
cmr5tz38m00d3w8ohk5meip2h	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5tz38000cuw8oht64glxo3	cmr5tz38j00d1w8oh08pks3vs	order-1783137409956409	0.00	1000.00	\N	2026-07-04 03:56:50.011	2026-07-04 03:56:50.086
cmr5u7ip2000iw83rg2krzb1j	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5u7iom0009w83raonzgeai	\N	order-1783137803231398	275.00	0.00	\N	2026-07-04 04:03:23.305	2026-07-04 04:03:23.366
cmr5u7ip6000mw83rqwl27abs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5u7iom0009w83raonzgeai	cmr5u7ip4000kw83ri8k3uyjm	order-1783137803231398	0.00	275.00	\N	2026-07-04 04:03:23.305	2026-07-04 04:03:23.371
cmr5u8099001xw83rfbtj9qry	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5u8090001qw83rmylwgnpf	\N	order-1783137826017241	150.00	0.00	\N	2026-07-04 04:03:46.074	2026-07-04 04:03:46.126
cmr5u809e0021w83rao4ghstw	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5u8090001qw83rmylwgnpf	cmr5u809b001zw83rnu7kleqq	order-1783137826017241	0.00	150.00	\N	2026-07-04 04:03:46.074	2026-07-04 04:03:46.131
cmr5u8pa0002uw83rh3ffiuub	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5u8p9j002nw83rfwcwsy3n	\N	order-1783137858446586	150.00	0.00	\N	2026-07-04 04:04:18.502	2026-07-04 04:04:18.553
cmr5u8pa5002yw83r7vlg14rp	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5u8p9j002nw83rfwcwsy3n	cmr5u8pa2002ww83r413bc3rg	order-1783137858446586	0.00	150.00	\N	2026-07-04 04:04:18.502	2026-07-04 04:04:18.557
cmr5ukn3t0008w8plq0nd7hyt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5ukn3c0003w8pld8eh0h18	\N	GUESTC-917913	100.00	0.00	\N	2026-07-04 04:13:35.572	2026-07-04 04:13:35.609
cmr5ukn3y000cw8pl36shlgxu	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5ukn3c0003w8pld8eh0h18	cmr5ukn3w000aw8pl1p3wy2fe	GUESTC-917913	0.00	100.00	\N	2026-07-04 04:13:35.572	2026-07-04 04:13:35.614
cmr5uov5j004jw83re9mk3cwm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5uov5a004ew83ravww52uk	\N	order-1783138612599249	125.00	0.00	\N	2026-07-04 04:16:52.637	2026-07-04 04:16:52.664
cmr5uov5o004nw83r45dwcn2d	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5uov5a004ew83ravww52uk	cmr5uov5m004lw83rpxbovrrk	order-1783138612599249	0.00	125.00	\N	2026-07-04 04:16:52.637	2026-07-04 04:16:52.669
cmr5ur49d006aw83ru5sh5uwk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5ur48x0063w83rqlvf99en	\N	order-1783138717706159	150.00	0.00	\N	2026-07-04 04:18:37.736	2026-07-04 04:18:37.777
cmr5ur49h006ew83rdttamjxn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5ur48x0063w83rqlvf99en	cmr5ur49f006cw83rp4q20h5m	order-1783138717706159	0.00	150.00	\N	2026-07-04 04:18:37.736	2026-07-04 04:18:37.782
cmr5uredk0075w83ryofei149	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5uredd0070w83rxss2c5b6	\N	order-1783138730822851	700.00	0.00	\N	2026-07-04 04:18:50.86	2026-07-04 04:18:50.889
cmr5uredq0079w83r7pnvnj27	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5uredd0070w83rxss2c5b6	cmr5uredn0077w83r7y9y60qb	order-1783138730822851	0.00	700.00	\N	2026-07-04 04:18:50.86	2026-07-04 04:18:50.894
cmr5wdqdq00dow83rwzzj1ngo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5wdqcq00djw83rwognoxcb	\N	order-1783141452161662	300.00	0.00	\N	2026-07-04 05:04:12.224	2026-07-04 05:04:12.494
cmr5wdqeg00dsw83r8bdekc3l	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5wdqcq00djw83rwognoxcb	cmr5wdqe300dqw83ryuc18dka	order-1783141452161662	0.00	300.00	\N	2026-07-04 05:04:12.224	2026-07-04 05:04:12.52
cmr5xsoec00gjw83ra45u9d67	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr5xsodq00gew83rab2b6ii1	\N	order-1783143828880819	400.00	0.00	\N	2026-07-04 05:43:49.234	2026-07-04 05:43:49.38
cmr5xsoen00gnw83re93dv7do	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr5xsodq00gew83rab2b6ii1	cmr5xsoei00glw83rrx00b99j	order-1783143828880819	0.00	400.00	\N	2026-07-04 05:43:49.234	2026-07-04 05:43:49.391
cmr67ddp200g0w8jfj2pf5qf5	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr67ddof00fvw8jflwx020z3	\N	order-1783159911673064	100.00	0.00	\N	2026-07-04 10:11:51.727	2026-07-04 10:11:51.83
cmr67ddpe00g4w8jffh76p28q	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr67ddof00fvw8jflwx020z3	cmr67ddp700g2w8jfptfburpo	order-1783159911673064	0.00	195.00	\N	2026-07-04 10:11:51.727	2026-07-04 10:11:51.842
cmr67ex1700gzw8jfdobh9ixl	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr67ex0v00guw8jfiu3vyot6	\N	order-1783159983431419	100.00	0.00	\N	2026-07-04 10:13:03.498	2026-07-04 10:13:03.548
cmr67ex1f00h3w8jfg7nm9go9	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr67ex0v00guw8jfiu3vyot6	cmr67ex1c00h1w8jfrfq0lwae	order-1783159983431419	0.00	200.00	\N	2026-07-04 10:13:03.498	2026-07-04 10:13:03.555
cmr67jrls00igw8jfa8u7zftq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr67jrkp00ibw8jf2lzswu2s	\N	order-1783160209649060	300.00	0.00	\N	2026-07-04 10:16:49.718	2026-07-04 10:16:49.791
cmr67jrmn00ikw8jf3a67fry0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr67jrkp00ibw8jf2lzswu2s	cmr67jrmk00iiw8jf9yxi41pe	order-1783160209649060	0.00	400.00	\N	2026-07-04 10:16:49.718	2026-07-04 10:16:49.823
cmr6801sz00l5w8jf8o571ode	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	SALE	cmr6801s800l0w8jfqh7ha07s	\N	order-1783160969148133	50.00	0.00	\N	2026-07-04 10:29:29.443	2026-07-04 10:29:29.507
cmr69b1v3003uw8l3zk186scx	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr69b1mb003pw8l334eerwnv	\N	order-1783163161947181	50.00	0.00	\N	2026-07-04 11:06:02.035	2026-07-04 11:06:02.416
cmr69b25j003yw8l3omsrzyf1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr69b1mb003pw8l334eerwnv	cmr69b20t003ww8l3hmrsfba3	order-1783163161947181	0.00	153.00	\N	2026-07-04 11:06:02.035	2026-07-04 11:06:02.792
cmr69bh2h004pw8l3h96b3rx7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr69bh21004kw8l3zha0nhrt	\N	order-1783163181977373	100.00	0.00	\N	2026-07-04 11:06:22.066	2026-07-04 11:06:22.122
cmr69bh3a004tw8l3opu603lr	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr69bh21004kw8l3zha0nhrt	cmr69bh2t004rw8l3anyh1mz4	order-1783163181977373	0.00	205.00	\N	2026-07-04 11:06:22.066	2026-07-04 11:06:22.15
cmr69bqf8005gw8l39l6irl2w	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr69bqeu005bw8l355nkc51n	\N	order-1783163194138034	100.00	0.00	\N	2026-07-04 11:06:34.179	2026-07-04 11:06:34.244
cmr69bqfw005kw8l3kt4ee3n5	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr69bqeu005bw8l355nkc51n	cmr69bqfc005iw8l3giiew1no	order-1783163194138034	0.00	205.00	\N	2026-07-04 11:06:34.179	2026-07-04 11:06:34.269
cmr69defj0073w8l31oouuxhm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr69deeh006yw8l3k4wtbkuc	\N	order-1783163271902402	50.00	0.00	\N	2026-07-04 11:07:51.945	2026-07-04 11:07:52.015
cmr69defp0077w8l3lsk4qf1a	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr69deeh006yw8l3k4wtbkuc	cmr69defm0075w8l3nc18ncnq	order-1783163271902402	0.00	153.00	\N	2026-07-04 11:07:51.945	2026-07-04 11:07:52.022
cmr78w8nx00gpw8mpga0w40cf	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr78w8na00gnw8mps64fvknq	MONJUR-614867	0.00	100.00	Due payment collected via Mobile UI	2026-07-05 03:42:17.243	2026-07-05 03:42:17.565
cmr78wxth00jnw8mp2r1zrzev	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	PAYMENT	\N	cmr78wxsp00jlw8mp6qzqjtge	SAKIB-847203	0.00	100.00	Due payment collected via Mobile UI	2026-07-05 03:42:50.109	2026-07-05 03:42:50.165
cmr78y32m00lzw8mpfjk4g7r6	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	PAYMENT	\N	cmr78y31t00lxw8mpt0tsl3ld	SAJIB-978811	0.00	100.00	Due payment collected via Mobile UI	2026-07-05 03:43:43.555	2026-07-05 03:43:43.631
cmr78z1lk00nbw8mp0k1hlvpd	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr78z1l700n9w8mpl2whdcbd	MONJUR-614867	0.00	50.00	Due payment collected via Mobile UI	2026-07-05 03:44:28.321	2026-07-05 03:44:28.376
cmr797pce00rvw8mp7uxyutiq	cmr0gdhu7005kw8g06c2lngfc	cmr0go9zm006kw8g06xsi3i2b	PAYMENT	\N	cmr797pc400rtw8mpoqexf6vz	TTT-972652	0.00	50.00	Due payment collected via Mobile UI	2026-07-05 03:51:12.351	2026-07-05 03:51:12.398
cmr799yb800uhw8mprgmxlkuw	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	PAYMENT	\N	cmr799yaw00ufw8mp2tayx6c1	SAKIB-847203	0.00	10.00	Due payment collected via Mobile UI	2026-07-05 03:52:57.281	2026-07-05 03:52:57.333
cmr79om2b00y9w8mp44la95za	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	PAYMENT	\N	cmr79om2000y7w8mpoihbmomi	SAKIB-847203	0.00	10.00	Due payment collected via Mobile UI	2026-07-05 04:04:21.244	2026-07-05 04:04:21.299
cmr79p3p000z9w8mpuyrv0bct	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	PAYMENT	\N	cmr79p3lk00z7w8mpyeh0rrwo	SAKIB-847203	0.00	10.00	Due payment collected via Mobile UI	2026-07-05 04:04:43.909	2026-07-05 04:04:44.148
cmr79q8s00113w8mp6nhvygyn	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	PAYMENT	\N	cmr79q8rp0111w8mp4jl9qcz3	MONJUR-614867	0.00	20.00	Due payment collected via Mobile UI	2026-07-05 04:05:37.34	2026-07-05 04:05:37.393
cmr7a6mzy01d8w8mp9ugr30mb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7a6mz401d3w8mpvi2m30t7	\N	order-1783225102228046	200.00	0.00	\N	2026-07-05 04:18:22.272	2026-07-05 04:18:22.319
cmr7a6n0d01dcw8mpe0ogqrk0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7a6mz401d3w8mpvi2m30t7	cmr7a6n0601daw8mpt6tm5mca	order-1783225102228046	0.00	310.00	\N	2026-07-05 04:18:22.272	2026-07-05 04:18:22.334
cmr7a7gq901enw8mpmytuh6lf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7a7gpe01eiw8mpyvjz4us7	\N	order-1783225140757277	50.00	0.00	\N	2026-07-05 04:19:00.805	2026-07-05 04:19:00.85
cmr7a7gqr01erw8mps58hccvs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7a7gpe01eiw8mpyvjz4us7	cmr7a7gqd01epw8mp8a4m8y8u	order-1783225140757277	0.00	153.00	\N	2026-07-05 04:19:00.805	2026-07-05 04:19:00.867
cmr7ahtk601prw8mpid35c96q	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ahtjk01pmw8mp70bq37w9	\N	order-1783225623805475	100.00	0.00	\N	2026-07-05 04:27:03.895	2026-07-05 04:27:04.038
cmr7ahtke01pvw8mps7l6oiq8	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ahtjk01pmw8mp70bq37w9	cmr7ahtk901ptw8mpzy049p22	order-1783225623805475	0.00	205.00	\N	2026-07-05 04:27:03.895	2026-07-05 04:27:04.046
cmr7ai9m101r2w8mpjbspr85d	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ai9lp01qxw8mp32tyd6so	\N	order-1783225644685231	100.00	0.00	\N	2026-07-05 04:27:24.809	2026-07-05 04:27:24.841
cmr7ai9m601r6w8mp8vlh1u27	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ai9lp01qxw8mp32tyd6so	cmr7ai9m301r4w8mp7rm4miae	order-1783225644685231	0.00	205.00	\N	2026-07-05 04:27:24.809	2026-07-05 04:27:24.847
cmr7au59v01xyw8mpi6v7iswa	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7au59h01xtw8mpkv8sfjfy	\N	order-1783226198916591	15.00	0.00	\N	2026-07-05 04:36:38.992	2026-07-05 04:36:39.091
cmr7au5aq01y2w8mpogjyk2bn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7au59h01xtw8mpkv8sfjfy	cmr7au59z01y0w8mpsnf5t6ea	order-1783226198916591	0.00	116.00	\N	2026-07-05 04:36:38.992	2026-07-05 04:36:39.122
cmr7b8vou023tw8mpaaatkm6j	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7b8voh023ow8mpabdnjxb7	\N	order-1783226886456747	15.00	0.00	\N	2026-07-05 04:48:06.485	2026-07-05 04:48:06.511
cmr7b8vp0023xw8mpjx2rdgzd	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7b8voh023ow8mpabdnjxb7	cmr7b8vox023vw8mp52jjr0xy	order-1783226886456747	0.00	116.00	\N	2026-07-05 04:48:06.485	2026-07-05 04:48:06.516
cmr7b9je2025ew8mpa6kz1p9r	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7b9jdr0259w8mp42oo1gfs	\N	order-1783226917151718	15.00	0.00	\N	2026-07-05 04:48:37.192	2026-07-05 04:48:37.226
cmr7b9jec025iw8mp1hu29zim	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7b9jdr0259w8mp42oo1gfs	cmr7b9je5025gw8mp71wweijg	order-1783226917151718	0.00	116.00	\N	2026-07-05 04:48:37.192	2026-07-05 04:48:37.236
cmr7bqws1027fw8mpph4qd07r	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7bqwrh027aw8mp3732z6z1	\N	order-1783227727601180	15.00	0.00	\N	2026-07-05 05:02:07.675	2026-07-05 05:02:07.73
cmr7bqws8027jw8mp9engllpp	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7bqwrh027aw8mp3732z6z1	cmr7bqws5027hw8mp2irybqto	order-1783227727601180	0.00	116.00	\N	2026-07-05 05:02:07.675	2026-07-05 05:02:07.737
cmr7brcyi028qw8mp095tvuxb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7brcyc028lw8mpptk47njy	\N	order-1783227748584257	15.00	0.00	\N	2026-07-05 05:02:28.669	2026-07-05 05:02:28.698
cmr7brcyn028uw8mpl5bas7ni	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7brcyc028lw8mpptk47njy	cmr7brcyk028sw8mpvd6rxji3	order-1783227748584257	0.00	116.00	\N	2026-07-05 05:02:28.669	2026-07-05 05:02:28.703
cmr7ch6lp001mw8rfbctweok6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ch6l3001hw8rfp3ijhzp6	\N	order-1783228953442400	15.00	0.00	\N	2026-07-05 05:22:33.478	2026-07-05 05:22:33.517
cmr7ch6lz001qw8rff11sg7ce	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ch6l3001hw8rfp3ijhzp6	cmr7ch6lu001ow8rfkms9btv1	order-1783228953442400	0.00	116.00	\N	2026-07-05 05:22:33.478	2026-07-05 05:22:33.528
cmr7crv0p0043w8rfz0ujn62u	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7cruy0003yw8rfr3ofdtd4	\N	order-1783229451501504	15.00	0.00	\N	2026-07-05 05:30:51.555	2026-07-05 05:30:51.722
cmr7crv0w0047w8rf9pf60sxl	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7cruy0003yw8rfr3ofdtd4	cmr7crv0u0045w8rf8wnof0mo	order-1783229451501504	0.00	116.00	\N	2026-07-05 05:30:51.555	2026-07-05 05:30:51.728
cmr7cs7t7005gw8rf0ftckzp3	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7cs7sx005bw8rf3vlwbvgz	\N	order-1783229468239989	15.00	0.00	\N	2026-07-05 05:31:08.275	2026-07-05 05:31:08.299
cmr7cs7te005kw8rfetqeo347	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7cs7sx005bw8rf3vlwbvgz	cmr7cs7ta005iw8rfphhg4u3h	order-1783229468239989	0.00	116.00	\N	2026-07-05 05:31:08.275	2026-07-05 05:31:08.306
cmr7ct6j6006rw8rfab0yh2xg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ct6in006mw8rfjc6mzr64	\N	order-1783229513071520	15.00	0.00	\N	2026-07-05 05:31:53.239	2026-07-05 05:31:53.298
cmr7ct6jd006vw8rfc8hetd3x	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ct6in006mw8rfjc6mzr64	cmr7ct6j9006tw8rfb914l361	order-1783229513071520	0.00	116.00	\N	2026-07-05 05:31:53.239	2026-07-05 05:31:53.305
cmr7da96v0094w8rfraj4dfjb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7da96g008zw8rfmdetx8bs	\N	order-1783230309830192	15.00	0.00	\N	2026-07-05 05:45:09.864	2026-07-05 05:45:09.895
cmr7da9720098w8rf3cg5wj69	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7da96g008zw8rfmdetx8bs	cmr7da96z0096w8rfby2h4xx4	order-1783230309830192	0.00	116.00	\N	2026-07-05 05:45:09.864	2026-07-05 05:45:09.902
cmr7dav9v00adw8rfqeqgl40d	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7dav9n00a8w8rfb2bm7rwa	\N	order-1783230338460629	15.00	0.00	\N	2026-07-05 05:45:38.496	2026-07-05 05:45:38.516
cmr7dav9z00ahw8rfvl84k70v	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7dav9n00a8w8rfb2bm7rwa	cmr7dav9x00afw8rfcu2zs410	order-1783230338460629	0.00	116.00	\N	2026-07-05 05:45:38.496	2026-07-05 05:45:38.52
cmr7db7w100bkw8rfrn1nzrn6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7db7vj00bfw8rfyxfeitv7	\N	order-1783230354809690	100.00	0.00	\N	2026-07-05 05:45:54.834	2026-07-05 05:45:54.866
cmr7db7w700bow8rf8v9xxsv1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7db7vj00bfw8rfyxfeitv7	cmr7db7w300bmw8rfkupxegqt	order-1783230354809690	0.00	205.00	\N	2026-07-05 05:45:54.834	2026-07-05 05:45:54.871
cmr7dbm7q00crw8rf3ywffgcl	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7dbm7d00cmw8rfj2unpzqh	\N	order-1783230373374524	15.00	0.00	\N	2026-07-05 05:46:13.404	2026-07-05 05:46:13.43
cmr7dbm7t00cvw8rfcap9mwi6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7dbm7d00cmw8rfj2unpzqh	cmr7dbm7r00ctw8rf6xhdt7a1	order-1783230373374524	0.00	116.00	\N	2026-07-05 05:46:13.404	2026-07-05 05:46:13.434
cmr7dbwxi00e2w8rfs8bqiak5	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7dbwxd00dxw8rfl1w5fsrt	\N	order-1783230387173358	15.00	0.00	\N	2026-07-05 05:46:27.266	2026-07-05 05:46:27.318
cmr7dbwxo00e6w8rfeyfb82ix	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7dbwxd00dxw8rfl1w5fsrt	cmr7dbwxj00e4w8rfucaib5wf	order-1783230387173358	0.00	116.00	\N	2026-07-05 05:46:27.266	2026-07-05 05:46:27.325
cmr7dq6km00mlw8rfxvo9gaqs	cmr0gdhu7005kw8g06c2lngfc	cmr0go9zm006kw8g06xsi3i2b	PAYMENT	\N	cmr7dq6ke00mjw8rfejdva57e	TTT-972652	0.00	50.00	Due payment collected via Mobile UI	2026-07-05 05:57:32.932	2026-07-05 05:57:32.998
cmr7ds3ix00osw8rfn8cmr8cd	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ds3ib00onw8rf32cafk45	\N	order-1783231142268610	15.00	0.00	\N	2026-07-05 05:59:02.317	2026-07-05 05:59:02.361
cmr7ds3j400oww8rfzsgdpuee	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ds3ib00onw8rf32cafk45	cmr7ds3j000ouw8rfv50uvb6j	order-1783231142268610	0.00	116.00	\N	2026-07-05 05:59:02.317	2026-07-05 05:59:02.368
cmr7dsva500qvw8rfyqnwyslf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7dsv9h00qqw8rfr5tro5zx	\N	order-1783231178229393	15.00	0.00	\N	2026-07-05 05:59:38.276	2026-07-05 05:59:38.333
cmr7dsva900qzw8rflu18dnub	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7dsv9h00qqw8rfr5tro5zx	cmr7dsva700qxw8rfjrqfx1fm	order-1783231178229393	0.00	116.00	\N	2026-07-05 05:59:38.276	2026-07-05 05:59:38.338
cmr7duude00wbw8rfhzudcfn8	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7duud100w6w8rfsdcn8e48	\N	order-1783231270413070	15.00	0.00	\N	2026-07-05 06:01:10.437	2026-07-05 06:01:10.466
cmr7duudj00wfw8rfy6rd524d	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7duud100w6w8rfsdcn8e48	cmr7duudh00wdw8rf4vnwskam	order-1783231270413070	0.00	116.00	\N	2026-07-05 06:01:10.437	2026-07-05 06:01:10.472
cmr7e5p5s0020w8w9fg87mfqk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7e5p57001vw8w9zlmbqngc	\N	order-1783231776848542	150.00	0.00	\N	2026-07-05 06:09:36.883	2026-07-05 06:09:36.928
cmr7e5p6k0024w8w9vebqr3nh	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7e5p57001vw8w9zlmbqngc	cmr7e5p5z0022w8w95kxwswhj	order-1783231776848542	0.00	258.00	\N	2026-07-05 06:09:36.883	2026-07-05 06:09:36.956
cmr7e6bjy003hw8w9y4g0boey	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7e6bjj003cw8w9g3eylzxe	\N	order-1783231805878432	150.00	0.00	\N	2026-07-05 06:10:05.919	2026-07-05 06:10:05.95
cmr7e6bk3003lw8w9cnsdeeyo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7e6bjj003cw8w9g3eylzxe	cmr7e6bk0003jw8w9tuodzv2g	order-1783231805878432	0.00	258.00	\N	2026-07-05 06:10:05.919	2026-07-05 06:10:05.956
cmr7ephp40082w8w9hxgsy5sg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ephoi007xw8w9dleyqsui	\N	order-1783232700285199	15.00	0.00	\N	2026-07-05 06:25:00.328	2026-07-05 06:25:00.377
cmr7ephpi0086w8w9cuf2b9ly	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ephoi007xw8w9dleyqsui	cmr7ephpb0084w8w9mbexfwzi	order-1783232700285199	0.00	116.00	\N	2026-07-05 06:25:00.328	2026-07-05 06:25:00.39
cmr7ewzxd0026w8l6fdf3qbni	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7ewzw70021w8l6fqz6979e	\N	order-1783233050042231	105.00	0.00	\N	2026-07-05 06:30:50.494	2026-07-05 06:30:50.593
cmr7ewzxt002aw8l625mwzcck	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7ewzw70021w8l6fqz6979e	cmr7ewzxo0028w8l6ahzkqbwh	order-1783233050042231	0.00	210.00	\N	2026-07-05 06:30:50.494	2026-07-05 06:30:50.609
cmr7f1unf005hw8l6u6l7yxaw	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7f1umi005cw8l6ynkeks7b	\N	order-1783233276914395	100.00	0.00	\N	2026-07-05 06:34:36.976	2026-07-05 06:34:37.035
cmr7f1uoc005lw8l6ugfau1w1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7f1umi005cw8l6ynkeks7b	cmr7f1uns005jw8l646sj2fhq	order-1783233276914395	0.00	205.00	\N	2026-07-05 06:34:36.976	2026-07-05 06:34:37.068
cmr7f28df006ow8l65gygfg70	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	SALE	cmr7f28ab006jw8l65cchhz4n	\N	order-1783233294609736	100.00	0.00	\N	2026-07-05 06:34:54.671	2026-07-05 06:34:54.82
cmr7f28dr006sw8l62ig5mds2	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	PAYMENT	cmr7f28ab006jw8l65cchhz4n	cmr7f28dl006qw8l6sycrmb8v	order-1783233294609736	0.00	205.00	\N	2026-07-05 06:34:54.671	2026-07-05 06:34:54.832
\.


--
-- Data for Name: customer_payments; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.customer_payments (id, shop_id, customer_id, amount, payment_method, money_box_id, reference_no, notes, paid_at, created_at, payment_meta) FROM stdin;
cmqw3owlx002elxug8l86c96g	cmqtek0us0002lxj6zzrnqalp	cmqtf1e610024lxj6b04g862g	230.00	CASH	\N	order-1782549068656150	\N	2026-06-27 08:31:09.21	2026-06-27 08:31:09.333	null
cmqxny77a0001lxzd3o4k6g8m	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	100.00	CASH	\N	\N	\N	2026-06-28 10:46:01.456	2026-06-28 10:46:01.462	\N
cmr0gkggj0063w8g0x3l3pluz	cmr0gdhu7005kw8g06c2lngfc	cmr0gjh5a005zw8g05zjs8d5m	300.00	CASH	\N	\N	Due payment collected via Mobile UI	2026-06-30 09:42:41.368	2026-06-30 09:42:41.49	null
cmr0glvwd0067w8g0fsr78ibs	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	100.00	CASH	\N	\N	Due payment collected via Mobile UI	2026-06-30 09:43:48.047	2026-06-30 09:43:48.157	null
cmr0gn1h8006ew8g0lj5aqrz5	cmr0gdhu7005kw8g06c2lngfc	cmr0gmst3006aw8g0mj6044cw	22.00	CASH	\N	\N	Due payment collected via Mobile UI	2026-06-30 09:44:41.963	2026-06-30 09:44:42.044	null
cmr0gyn6b006ow8g0eh62cro4	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	100.00	CASH	\N	\N	Due payment collected via Mobile UI	2026-06-30 09:53:43.295	2026-06-30 09:53:43.379	null
cmr0jig1i001iw8s3k3bhv65n	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	465.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782817506202494	\N	2026-06-30 11:05:06.373	2026-06-30 11:05:06.487	null
cmr1no4uc000gw8xncr8mr1vk	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	260.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782884956237169	\N	2026-07-01 05:49:16.394	2026-07-01 05:49:16.548	null
cmr1nslhb000tw8xn5dfna9v1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	20.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782885164491997	\N	2026-07-01 05:52:44.632	2026-07-01 05:52:44.735	null
cmr1oyp3d002dw8xnma5z1p5v	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	50.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:25:28.751	2026-07-01 06:25:28.967	null
cmr1oze2r002hw8xntex6fepf	cmr0gdhu7005kw8g06c2lngfc	cmr0go0be006hw8g03bro81us	50.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:25:59.615	2026-07-01 06:26:01.347	null
cmr1p8hof002nw8xnnr1g8er4	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	20.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:33:05.397	2026-07-01 06:33:05.919	null
cmr1pg4wq003jw8xnajyyuwvo	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	500.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:39:02.548	2026-07-01 06:39:02.619	null
cmr1phigm003nw8xnqzvoxhdn	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:40:06.761	2026-07-01 06:40:06.838	null
cmr1pj6l6004cw8xnl7mvdgzb	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	500.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:41:24.673	2026-07-01 06:41:24.762	null
cmr1pjlu7004gw8xneg1xuow3	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	270.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:41:44.445	2026-07-01 06:41:44.527	null
cmr1ppylz004kw8xn6a28wvf7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:46:40.941	2026-07-01 06:46:41.015	null
cmr1q43px0001w8knljamu5l1	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	360.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-01 06:57:40.689	2026-07-01 06:57:40.82	null
cmr2zrnv200b7w82ppp0ehbxm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	80.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782965742623287	\N	2026-07-02 04:15:42.683	2026-07-02 04:15:42.735	null
cmr2zscui00c8w82ptm3k3qhq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	80.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782965775034919	\N	2026-07-02 04:16:15.071	2026-07-02 04:16:15.114	null
cmr31oagj0022w8fucak20fu0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	40.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782968944530467	\N	2026-07-02 05:09:04.578	2026-07-02 05:09:04.627	null
cmr31qgyi0037w8fugg9cpaok	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	240.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782969046286832	\N	2026-07-02 05:10:46.327	2026-07-02 05:10:46.363	null
cmr31s2ln0040w8fud9pqo3jn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1240.00	BKASH	cmr2z1235001ew8hocgj716rm	order-1782969120955758	\N	2026-07-02 05:12:01.037	2026-07-02 05:12:01.067	{"senderNumber": "N/A", "transactionId": "N/A"}
cmr3255ip005hw8fudrddsa0e	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	200.00	BKASH	cmr2z1235001ew8hocgj716rm	order-1782969730744493	\N	2026-07-02 05:22:11.148	2026-07-02 05:22:11.378	{"senderNumber": "N/A", "transactionId": "N/A"}
cmr328k99007ew8fu786tvwvl	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	120.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782969890336516	\N	2026-07-02 05:24:50.405	2026-07-02 05:24:50.445	null
cmr32cebd0091w8fugv6rt49x	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	40.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782970069263492	\N	2026-07-02 05:27:49.32	2026-07-02 05:27:49.37	null
cmr32e293009mw8fu1uf5lg6q	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	80.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782970146794165	\N	2026-07-02 05:29:06.949	2026-07-02 05:29:07.047	null
cmr32h9nk00b1w8futpsxqgl2	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	40.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782970296388461	\N	2026-07-02 05:31:36.505	2026-07-02 05:31:36.607	null
cmr37ybuo00bew8yosmk7nyxt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	990.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782979490408070	\N	2026-07-02 08:04:50.521	2026-07-02 08:04:50.689	null
cmr37yvuf00cfw8yo16lx4vya	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	880.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782979516530188	\N	2026-07-02 08:05:16.573	2026-07-02 08:05:16.6	null
cmr38lhs80072w896gvxiz015	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	500.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782980571008090	\N	2026-07-02 08:22:51.142	2026-07-02 08:22:51.464	null
cmr38ur6m00bmw896n55k4oc7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	550.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782981003161065	\N	2026-07-02 08:30:03.29	2026-07-02 08:30:03.549	null
cmr394f1m00dpw896jcjwu7s7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1200.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782981454228054	\N	2026-07-02 08:37:34.311	2026-07-02 08:37:34.379	null
cmr398sl000eqw896io80u6dt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1000.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782981658225179	\N	2026-07-02 08:40:58.35	2026-07-02 08:40:58.548	null
cmr5t744s000ow8oh2omqoasy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	2000.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782984223741471	\N	2026-07-04 03:35:04.772	2026-07-04 03:35:04.876	null
cmr5t74bb0013w8ohukbln3eo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	2000.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782984429516632	\N	2026-07-04 03:35:05.101	2026-07-04 03:35:05.112	null
cmr5t74ch001ow8oh66p5gt4o	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1400.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782988352184264	\N	2026-07-04 03:35:05.137	2026-07-04 03:35:05.154	null
cmr5t74ey0029w8ohaoqspvut	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	450.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782988765786637	\N	2026-07-04 03:35:05.214	2026-07-04 03:35:05.243	null
cmr5t74gm002qw8ohcskaviun	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1785.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782989488117954	\N	2026-07-04 03:35:05.265	2026-07-04 03:35:05.303	null
cmr5t74iy0037w8ohn6ipdas1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1050.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782989561900135	\N	2026-07-04 03:35:05.353	2026-07-04 03:35:05.387	null
cmr5t74ka003mw8ohkfsh9yxr	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	600.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782989724275542	\N	2026-07-04 03:35:05.425	2026-07-04 03:35:05.434	null
cmr5t74n10041w8ohsp555iab	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	800.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1782989874728370	\N	2026-07-04 03:35:05.526	2026-07-04 03:35:05.534	null
cmr5tc8mq007qw8ohkfh06ty7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1375.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783136343914525	\N	2026-07-04 03:39:03.947	2026-07-04 03:39:03.986	null
cmr5tdejv008jw8ohv9bu8wnk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	2625.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783136398210273	\N	2026-07-04 03:39:58.264	2026-07-04 03:39:58.315	null
cmr5tg1ri009uw8ohr4ou3qwm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1900.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783136521456132	\N	2026-07-04 03:42:01.548	2026-07-04 03:42:01.71	null
cmr5th1xg00alw8oh62npfrf2	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	4150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783136568435451	\N	2026-07-04 03:42:48.482	2026-07-04 03:42:48.58	null
cmr5tjv7i00bsw8ohfwbsaccu	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	9250.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783136699638405	\N	2026-07-04 03:44:59.698	2026-07-04 03:44:59.838	null
cmr5tz38j00d1w8oh08pks3vs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	1000.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783137409956409	\N	2026-07-04 03:56:50.011	2026-07-04 03:56:50.084	null
cmr5u7ip4000kw83ri8k3uyjm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	275.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783137803231398	\N	2026-07-04 04:03:23.305	2026-07-04 04:03:23.368	null
cmr5u809b001zw83rnu7kleqq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783137826017241	\N	2026-07-04 04:03:46.074	2026-07-04 04:03:46.127	null
cmr5u8pa2002ww83r413bc3rg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783137858446586	\N	2026-07-04 04:04:18.502	2026-07-04 04:04:18.555	null
cmr5ukn3w000aw8pl1p3wy2fe	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	\N	2026-07-04 04:13:35.572	2026-07-04 04:13:35.612	null
cmr5uov5m004lw83rpxbovrrk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	125.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783138612599249	\N	2026-07-04 04:16:52.637	2026-07-04 04:16:52.667	null
cmr5ur49f006cw83rp4q20h5m	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783138717706159	\N	2026-07-04 04:18:37.736	2026-07-04 04:18:37.779	null
cmr5uredn0077w83r7y9y60qb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	700.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783138730822851	\N	2026-07-04 04:18:50.86	2026-07-04 04:18:50.892	null
cmr5wdqe300dqw83ryuc18dka	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	300.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783141452161662	\N	2026-07-04 05:04:12.224	2026-07-04 05:04:12.507	null
cmr5xsoei00glw83rrx00b99j	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	400.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783143828880819	\N	2026-07-04 05:43:49.234	2026-07-04 05:43:49.386	null
cmr67ddp700g2w8jfptfburpo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	195.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783159911673064	\N	2026-07-04 10:11:51.727	2026-07-04 10:11:51.836	null
cmr67ex1c00h1w8jfrfq0lwae	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	200.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783159983431419	\N	2026-07-04 10:13:03.498	2026-07-04 10:13:03.553	null
cmr67jrmk00iiw8jf9yxi41pe	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	400.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783160209649060	\N	2026-07-04 10:16:49.718	2026-07-04 10:16:49.82	null
cmr69b20t003ww8l3hmrsfba3	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	153.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783163161947181	\N	2026-07-04 11:06:02.035	2026-07-04 11:06:02.621	null
cmr69bh2t004rw8l3anyh1mz4	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783163181977373	\N	2026-07-04 11:06:22.066	2026-07-04 11:06:22.13	null
cmr69bqfc005iw8l3giiew1no	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783163194138034	\N	2026-07-04 11:06:34.179	2026-07-04 11:06:34.248	null
cmr69defm0075w8l3nc18ncnq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	153.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783163271902402	\N	2026-07-04 11:07:51.945	2026-07-04 11:07:52.018	null
cmr78w8na00gnw8mps64fvknq	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:42:17.243	2026-07-05 03:42:17.542	null
cmr78wxsp00jlw8mp6qzqjtge	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:42:50.109	2026-07-05 03:42:50.138	null
cmr78y31t00lxw8mpt0tsl3ld	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:43:43.555	2026-07-05 03:43:43.601	null
cmr78z1l700n9w8mpl2whdcbd	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	50.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:44:28.321	2026-07-05 03:44:28.363	null
cmr797pc400rtw8mpoqexf6vz	cmr0gdhu7005kw8g06c2lngfc	cmr0go9zm006kw8g06xsi3i2b	50.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:51:12.351	2026-07-05 03:51:12.388	null
cmr799yaw00ufw8mp2tayx6c1	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	10.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 03:52:57.281	2026-07-05 03:52:57.32	null
cmr79om2000y7w8mpoihbmomi	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	10.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 04:04:21.244	2026-07-05 04:04:21.288	null
cmr79p3lk00z7w8mpyeh0rrwo	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	10.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 04:04:43.909	2026-07-05 04:04:44.024	null
cmr79q8rp0111w8mp4jl9qcz3	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	20.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 04:05:37.34	2026-07-05 04:05:37.381	null
cmr7a6n0601daw8mpt6tm5mca	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	310.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783225102228046	\N	2026-07-05 04:18:22.272	2026-07-05 04:18:22.326	null
cmr7a7gqd01epw8mp8a4m8y8u	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	153.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783225140757277	\N	2026-07-05 04:19:00.805	2026-07-05 04:19:00.853	null
cmr7ahtk901ptw8mpzy049p22	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783225623805475	\N	2026-07-05 04:27:03.895	2026-07-05 04:27:04.042	null
cmr7ai9m301r4w8mp7rm4miae	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783225644685231	\N	2026-07-05 04:27:24.809	2026-07-05 04:27:24.843	null
cmr7au59z01y0w8mpsnf5t6ea	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783226198916591	\N	2026-07-05 04:36:38.992	2026-07-05 04:36:39.095	null
cmr7b8vox023vw8mp52jjr0xy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783226886456747	\N	2026-07-05 04:48:06.485	2026-07-05 04:48:06.514	null
cmr7b9je5025gw8mp71wweijg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783226917151718	\N	2026-07-05 04:48:37.192	2026-07-05 04:48:37.229	null
cmr7bqws5027hw8mp2irybqto	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783227727601180	\N	2026-07-05 05:02:07.675	2026-07-05 05:02:07.733	null
cmr7brcyk028sw8mpvd6rxji3	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783227748584257	\N	2026-07-05 05:02:28.669	2026-07-05 05:02:28.7	null
cmr7ch6lu001ow8rfkms9btv1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783228953442400	\N	2026-07-05 05:22:33.478	2026-07-05 05:22:33.523	null
cmr7crv0u0045w8rf8wnof0mo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783229451501504	\N	2026-07-05 05:30:51.555	2026-07-05 05:30:51.726	null
cmr7cs7ta005iw8rfphhg4u3h	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783229468239989	\N	2026-07-05 05:31:08.275	2026-07-05 05:31:08.303	null
cmr7ct6j9006tw8rfb914l361	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783229513071520	\N	2026-07-05 05:31:53.239	2026-07-05 05:31:53.302	null
cmr7da96z0096w8rfby2h4xx4	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783230309830192	\N	2026-07-05 05:45:09.864	2026-07-05 05:45:09.899	null
cmr7dav9x00afw8rfcu2zs410	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783230338460629	\N	2026-07-05 05:45:38.496	2026-07-05 05:45:38.517	null
cmr7db7w300bmw8rfkupxegqt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783230354809690	\N	2026-07-05 05:45:54.834	2026-07-05 05:45:54.868	null
cmr7dbm7r00ctw8rf6xhdt7a1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783230373374524	\N	2026-07-05 05:46:13.404	2026-07-05 05:46:13.432	null
cmr7dbwxj00e4w8rfucaib5wf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783230387173358	\N	2026-07-05 05:46:27.266	2026-07-05 05:46:27.32	null
cmr7dq6ke00mjw8rfejdva57e	cmr0gdhu7005kw8g06c2lngfc	cmr0go9zm006kw8g06xsi3i2b	50.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	Due payment collected via Mobile UI	2026-07-05 05:57:32.932	2026-07-05 05:57:32.99	null
cmr7ds3j000ouw8rfv50uvb6j	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783231142268610	\N	2026-07-05 05:59:02.317	2026-07-05 05:59:02.364	null
cmr7dsva700qxw8rfjrqfx1fm	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783231178229393	\N	2026-07-05 05:59:38.276	2026-07-05 05:59:38.335	null
cmr7duudh00wdw8rf4vnwskam	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783231270413070	\N	2026-07-05 06:01:10.437	2026-07-05 06:01:10.469	null
cmr7e5p5z0022w8w95kxwswhj	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	258.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783231776848542	\N	2026-07-05 06:09:36.883	2026-07-05 06:09:36.935	null
cmr7e6bk0003jw8w9tuodzv2g	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	258.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783231805878432	\N	2026-07-05 06:10:05.919	2026-07-05 06:10:05.952	null
cmr7ephpb0084w8w9mbexfwzi	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	116.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783232700285199	\N	2026-07-05 06:25:00.328	2026-07-05 06:25:00.383	null
cmr7ewzxo0028w8l6ahzkqbwh	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	210.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783233050042231	\N	2026-07-05 06:30:50.494	2026-07-05 06:30:50.604	null
cmr7f1uns005jw8l646sj2fhq	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783233276914395	\N	2026-07-05 06:34:36.976	2026-07-05 06:34:37.048	null
cmr7f28dl006qw8l6sycrmb8v	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	205.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	order-1783233294609736	\N	2026-07-05 06:34:54.671	2026-07-05 06:34:54.825	null
\.


--
-- Data for Name: customer_sale_items; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.customer_sale_items (id, customer_sale_id, master_product_id, quantity, sale_price, total_amount, batch_no, purchase_price) FROM stdin;
cmqw3owkm0029lxugzixt3gc8	cmqw3owkm0027lxugwbjjro4j	cmqnq97x4001flx4upjb4nzcm	2.000	115.00	230.00	1	\N
cmqxfmenl004flxgf6h6k35qi	cmqxfmenl004dlxgfzegearqc	cmqnq97x4001flx4upjb4nzcm	1.000	115.00	115.00	1	105.00
cmqxiie5q0057lx0butljg13o	cmqxiie5p0055lx0b1ofzi029	cmqnq97x4001flx4upjb4nzcm	1.000	115.00	115.00	1	105.00
cmr0f1xay002tw8g0n0s6cf31	cmr0f1xay002rw8g01c2ysu5o	cmqnq97x4001flx4upjb4nzcm	1.000	115.00	115.00	1	105.00
cmr0jig0y0013w8s3g4vxwo7i	cmr0jig0y0011w8s3kobfd8t8	cmqnq97p4000rlx4updfrju1f	2.000	60.00	120.00	\N	55.00
cmr0jig0y0014w8s32mtdqxgn	cmr0jig0y0011w8s3kobfd8t8	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	\N	30.00
cmr0jig0y0015w8s3uq0urwql	cmr0jig0y0011w8s3kobfd8t8	cmqnq97kz000jlx4uxdu3s9ws	1.000	20.00	20.00	\N	20.00
cmr0jig0y0016w8s3py9qwxke	cmr0jig0y0011w8s3kobfd8t8	cmqnq97r6000vlx4usqsalrhi	1.000	115.00	115.00	\N	105.00
cmr0jig0y0017w8s3mppkeamu	cmr0jig0y0011w8s3kobfd8t8	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	120.00
cmr0jig0y0018w8s34ikqsz9e	cmr0jig0y0011w8s3kobfd8t8	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1no4sh0007w8xnxvt2dmax	cmr1no4sf0005w8xngt8jjzub	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	\N	30.00
cmr1no4sh0008w8xns1xa225m	cmr1no4sf0005w8xngt8jjzub	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	\N	105.00
cmr1no4sh0009w8xnl393slqq	cmr1no4sf0005w8xngt8jjzub	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	\N	125.00
cmr1nslf7000mw8xnjveuelo6	cmr1nslf7000kw8xnal3umoza	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1nslf7000nw8xnym6bmq1x	cmr1nslf7000kw8xnal3umoza	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1o9zyu0011w8xnem2o9yzt	cmr1o9zyu000zw8xncty4nm7k	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1o9zyu0012w8xnm0j9k3jg	cmr1o9zyu000zw8xncty4nm7k	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1oh700001aw8xnnvpaav82	cmr1oh6zz0018w8xnimfbggnk	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1oh700001bw8xnpwvhie0k	cmr1oh6zz0018w8xnimfbggnk	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1oh700001cw8xngrtg746t	cmr1oh6zz0018w8xnimfbggnk	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	105.00
cmr1oh700001dw8xnlei5yzxw	cmr1oh6zz0018w8xnimfbggnk	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	15.00
cmr1oh700001ew8xn8xw3lrrr	cmr1oh6zz0018w8xnimfbggnk	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	120.00
cmr1oidm6001sw8xnd5zgogpo	cmr1oidm6001qw8xngi8dedjm	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	105.00
cmr1oidm6001tw8xnb2s61m01	cmr1oidm6001qw8xngi8dedjm	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	15.00
cmr1okhab0024w8xn2tgecfq0	cmr1okhaa0022w8xn2jd7fnjv	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1okhab0025w8xn2nl6yh4i	cmr1okhaa0022w8xn2jd7fnjv	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1pebtd002tw8xnifbjxaev	cmr1pebtd002rw8xn1jj2kt77	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1pebtd002uw8xnws5ihv01	cmr1pebtd002rw8xn1jj2kt77	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1pftav0032w8xn88oge9hr	cmr1pftau0030w8xnssm2a49w	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1pftav0033w8xnbll25t0k	cmr1pftau0030w8xnssm2a49w	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1pftav0034w8xn3r7ah5ly	cmr1pftau0030w8xnssm2a49w	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	\N	30.00
cmr1pftav0035w8xnzttw4rl3	cmr1pftau0030w8xnssm2a49w	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	\N	105.00
cmr1pftav0036w8xnk6an29th	cmr1pftau0030w8xnssm2a49w	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	\N	125.00
cmr1pftav0037w8xnzm1l1s2l	cmr1pftau0030w8xnssm2a49w	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	30.00
cmr1pftav0038w8xngnlmasus	cmr1pftau0030w8xnssm2a49w	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	120.00
cmr1pinxs003tw8xn9sjqh65b	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr1pinxs003uw8xn6pkko74h	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97p4000rlx4updfrju1f	1.000	60.00	60.00	\N	55.00
cmr1pinxs003vw8xnm7nyioxh	cmr1pinxr003rw8xn6rmhpkbk	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	120.00
cmr1pinxs003ww8xn8wonizlw	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	30.00
cmr1pinxs003xw8xn463d7aij	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	105.00
cmr1pinxs003yw8xnvn8p8w6r	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	15.00
cmr1pinxs003zw8xn4y89s3su	cmr1pinxr003rw8xn6rmhpkbk	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	\N	105.00
cmr1pinxt0040w8xnv3w7xyp1	cmr1pinxr003rw8xn6rmhpkbk	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	\N	125.00
cmr2zrnuj00b0w82paibuksh4	cmr2zrnuj00ayw82p28oypxwf	cmqnq97ut0013lx4ueqfkijq8	1.000	20.00	20.00	1	20.00
cmr2zrnuj00b1w82pgb3xv4e3	cmr2zrnuj00ayw82p28oypxwf	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr2zscu400c1w82p1chvqpzc	cmr2zscu400bzw82pv10yb4mg	cmqnq97ut0013lx4ueqfkijq8	1.000	20.00	20.00	1	20.00
cmr2zscu400c2w82p7sgwzybf	cmr2zscu400bzw82pv10yb4mg	cmqnq97wg001blx4ueh3hh29z	1.000	60.00	60.00	\N	55.00
cmr31oaft001xw8fubnpxtlti	cmr31oafs001vw8fu7txff0d0	cmr31oafe001tw8fube0vfpyq	1.000	40.00	40.00	\N	20.00
cmr31qgxw0032w8fu2ovuaq0n	cmr31qgxv0030w8fuijd3gq0m	cmr31oafe001tw8fube0vfpyq	6.000	40.00	240.00	\N	20.00
cmr31s2l6003vw8fun6p6vy2o	cmr31s2l5003tw8fux6usv7ok	cmr31oafe001tw8fube0vfpyq	31.000	40.00	1240.00	\N	20.00
cmr3255i3005aw8futc7x0d5d	cmr3255i30058w8fub48dq6ol	cmr31oafe001tw8fube0vfpyq	3.000	40.00	120.00	\N	20.00
cmr3255i3005bw8fuiptwpala	cmr3255i30058w8fub48dq6ol	cmqnq97ut0013lx4ueqfkijq8	4.000	20.00	80.00	1	20.00
cmr328k8p0079w8fupnxr07y2	cmr328k8o0077w8fupldcu09r	cmr31oafe001tw8fube0vfpyq	3.000	40.00	120.00	\N	20.00
cmr32ceaj008ww8fugsx9h1qj	cmr32ceaj008uw8fux35w5uur	cmr31oafe001tw8fube0vfpyq	1.000	40.00	40.00	\N	20.00
cmr32e26y009hw8fu5hlf5dlh	cmr32e26y009fw8fuun6fzbyj	cmr31oafe001tw8fube0vfpyq	2.000	40.00	80.00	\N	20.00
cmr32h9lm00aww8fuj3klx8y4	cmr32h9lm00auw8fu9ayyqcyz	cmr31oafe001tw8fube0vfpyq	1.000	40.00	40.00	\N	20.00
cmr33onsq00ctw8fue5craxpv	cmr33onsq00crw8fukjgzra0y	cmr31oafe001tw8fube0vfpyq	1.000	40.00	40.00	\N	20.00
cmr33qohd00dww8furgi39x7y	cmr33qohd00duw8fuf0fun1r2	cmr31oafe001tw8fube0vfpyq	3.000	40.00	120.00	\N	20.00
cmr37ybtv00axw8yof9y3p908	cmr37ybtt00avw8yo9ja0diki	cmr31oafe001tw8fube0vfpyq	10.000	40.00	400.00	\N	20.00
cmr37ybtv00ayw8yon3fw06qn	cmr37ybtt00avw8yo9ja0diki	cmqnq97wg001blx4ueh3hh29z	4.000	55.00	220.00	\N	55.00
cmr37ybtv00azw8yod9qra8uq	cmr37ybtt00avw8yo9ja0diki	cmqnq97wg001blx4ueh3hh29z	1.000	55.00	55.00	1	55.00
cmr37ybtv00b0w8yokoaulqrk	cmr37ybtt00avw8yo9ja0diki	cmqnq97p4000rlx4updfrju1f	1.000	55.00	55.00	\N	55.00
cmr37ybtv00b1w8yo6526vro5	cmr37ybtt00avw8yo9ja0diki	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	\N	30.00
cmr37ybtv00b2w8yo3neoou36	cmr37ybtt00avw8yo9ja0diki	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	\N	105.00
cmr37ybtv00b3w8yodbbd875r	cmr37ybtt00avw8yo9ja0diki	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	\N	125.00
cmr37yvu100caw8yo1j4zheof	cmr37yvu100c8w8yoitpqhsgx	cmr31oafe001tw8fube0vfpyq	22.000	40.00	880.00	\N	20.00
cmr38lhk8006xw896853covug	cmr38lhk8006vw896c2xboxoc	cmr38lhjj006tw896tmrl2wl3	5.000	100.00	500.00	\N	50.00
cmr38ur0m00bhw896inlb49zq	cmr38ur0m00bfw896rwkp0xor	cmr38uqzi00bdw896uur2erb3	3.000	200.00	600.00	\N	150.00
cmr394f0x00dkw89606zkv1gt	cmr394f0x00diw89684amqowy	cmr394f0b00dgw89676gha1f1	6.000	200.00	1200.00	\N	150.00
cmr398sfz00elw896itimhwkl	cmr398sfz00ejw896c6pn0a2l	cmr394f0b00dgw89676gha1f1	5.000	200.00	1000.00	\N	150.00
cmr5t7440000jw8ohpnwoxyx5	cmr5t7440000hw8oh9jijldwg	cmr5t7422000bw8oh1hhykio7	10.000	200.00	2000.00	1	100.00
cmr5t74b7000yw8ohyok1jqk1	cmr5t74b7000ww8ohlnovfe8c	cmr5t7422000bw8oh1hhykio7	10.000	200.00	2000.00	1	100.00
cmr5t74cc001jw8ohilts7931	cmr5t74cc001hw8ohqnga9y5s	cmr5t74c3001bw8oh2k59ek9v	7.000	200.00	1400.00	1	100.00
cmr5t74eu0022w8oh0b67s86m	cmr5t74eu0020w8oh96w6nn2e	cmr394f0b00dgw89676gha1f1	1.000	150.00	150.00	1	150.00
cmr5t74eu0023w8ohoyjm6eo8	cmr5t74eu0020w8oh96w6nn2e	cmr394f0b00dgw89676gha1f1	2.000	150.00	300.00	1	150.00
cmr5t74fw002jw8ohi1cszu25	cmr5t74fv002hw8ohmtpbzdwn	cmqnq97p4000rlx4updfrju1f	7.000	55.00	385.00	\N	55.00
cmr5t74fw002kw8ohv6qutvz6	cmr5t74fv002hw8ohmtpbzdwn	cmr5t74c3001bw8oh2k59ek9v	7.000	200.00	1400.00	1	100.00
cmr5t74is0030w8oha686xsm8	cmr5t74is002yw8oh5ewrx1d5	cmr394f0b00dgw89676gha1f1	1.000	150.00	150.00	1	150.00
cmr5t74is0031w8ohe3y2foos	cmr5t74is002yw8oh5ewrx1d5	cmr394f0b00dgw89676gha1f1	6.000	150.00	900.00	1	150.00
cmr5t74k6003hw8ohg6vi6rzx	cmr5t74k6003fw8ohd5stmjlo	cmr5t74c3001bw8oh2k59ek9v	3.000	200.00	600.00	1	100.00
cmr5t74mz003ww8ohzk1e2p29	cmr5t74mz003uw8ohjykya0u0	cmr5t7422000bw8oh1hhykio7	4.000	200.00	800.00	1	100.00
cmr5tc8mc007lw8oh8cbk6tqy	cmr5tc8mc007jw8oh3hyy1y8z	cmr5tc8lq007dw8ohq06pd1ho	11.000	125.00	1375.00	1	120.00
cmr5tdejb008ew8ohtlzq5k9b	cmr5tdejb008cw8ohwq77sfih	cmr5tc8lq007dw8ohq06pd1ho	21.000	125.00	2625.00	1	120.00
cmr5tg1qz009pw8ohsf9v9vsb	cmr5tg1qz009nw8oh4r4hxepw	cmr5tg1ne009hw8ohfuwwn9r4	38.000	50.00	1900.00	1	10.00
cmr5th1w400agw8ohfnzgfcs4	cmr5th1w400aew8oh4xqrw7bt	cmr5tg1ne009hw8ohfuwwn9r4	83.000	50.00	4150.00	1	10.00
cmr5tjv6800blw8ohb20r73wj	cmr5tjv6800bjw8ohaktljm9n	cmr5tjv3u00bdw8oh5bm4rax4	78.000	100.00	7800.00	1	10.00
cmr5tjv6800bmw8ohqdz8r8mf	cmr5tjv6800bjw8ohaktljm9n	cmr5tg1ne009hw8ohfuwwn9r4	29.000	50.00	1450.00	1	10.00
cmr5tz38000cww8ohxz9yk5ow	cmr5tz38000cuw8oht64glxo3	cmr5tjv3u00bdw8oh5bm4rax4	10.000	100.00	1000.00	1	10.00
cmr5u7iom000bw83roehythk9	cmr5u7iom0009w83raonzgeai	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr5u7iom000cw83rcwmn9cnd	cmr5u7iom0009w83raonzgeai	cmr5tg1ne009hw8ohfuwwn9r4	1.000	50.00	50.00	1	10.00
cmr5u7iom000dw83r1z0bh1w4	cmr5u7iom0009w83raonzgeai	cmr5tc8lq007dw8ohq06pd1ho	1.000	125.00	125.00	1	120.00
cmr5u8090001sw83rpujoqija	cmr5u8090001qw83rmylwgnpf	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr5u8090001tw83rsblfctia	cmr5u8090001qw83rmylwgnpf	cmr5tg1ne009hw8ohfuwwn9r4	1.000	50.00	50.00	1	10.00
cmr5u8p9j002pw83rf8zhmm6w	cmr5u8p9j002nw83rfwcwsy3n	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr5u8p9j002qw83r3dxjfkst	cmr5u8p9j002nw83rfwcwsy3n	cmr5tg1ne009hw8ohfuwwn9r4	1.000	50.00	50.00	1	10.00
cmr5ukn3c0005w8pla396z9qh	cmr5ukn3c0003w8pld8eh0h18	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr5uov5a004gw83rthqvxngf	cmr5uov5a004ew83ravww52uk	cmr5tc8lq007dw8ohq06pd1ho	1.000	125.00	125.00	1	120.00
cmr5ur48x0065w83rgqisa8mu	cmr5ur48x0063w83rqlvf99en	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr5ur48x0066w83rs8kuc8j9	cmr5ur48x0063w83rqlvf99en	cmr5tg1ne009hw8ohfuwwn9r4	1.000	50.00	50.00	1	10.00
cmr5uredd0072w83rr8n5e6qz	cmr5uredd0070w83rxss2c5b6	cmr5tjv3u00bdw8oh5bm4rax4	7.000	100.00	700.00	1	10.00
cmr5wdqcq00dlw83r5iyttx60	cmr5wdqcq00djw83rwognoxcb	cmr5wdq6p00ddw83rw50pbwz8	6.000	50.00	300.00	1	25.00
cmr5xsodq00ggw83r1wqq92c3	cmr5xsodq00gew83rab2b6ii1	cmr5wdq6p00ddw83rw50pbwz8	8.000	50.00	400.00	1	25.00
cmr67ddof00fxw8jfic4a6st4	cmr67ddof00fvw8jflwx020z3	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr67ex0v00gww8jfct7j8gck	cmr67ex0v00guw8jfiu3vyot6	cmr5tg1ne009hw8ohfuwwn9r4	2.000	50.00	100.00	1	10.00
cmr67jrkp00idw8jf2aw9zihg	cmr67jrkp00ibw8jf2lzswu2s	cmr394f0b00dgw89676gha1f1	2.000	150.00	300.00	1	150.00
cmr6801s800l2w8jf56gxftk4	cmr6801s800l0w8jfqh7ha07s	cmr5wdq6p00ddw83rw50pbwz8	1.000	50.00	50.00	1	25.00
cmr69b1mb003rw8l3gfw3lwwa	cmr69b1mb003pw8l334eerwnv	cmr5wdq6p00ddw83rw50pbwz8	1.000	50.00	50.00	1	25.00
cmr69bh21004mw8l3v1cj5zfg	cmr69bh21004kw8l3zha0nhrt	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr69bqeu005dw8l3qf3u8p5p	cmr69bqeu005bw8l355nkc51n	cmr38lhjj006tw896tmrl2wl3	1.000	100.00	100.00	1	50.00
cmr69deeh0070w8l3iws5p575	cmr69deeh006yw8l3k4wtbkuc	cmr5wdq6p00ddw83rw50pbwz8	1.000	50.00	50.00	1	25.00
cmr7a6mz401d5w8mpni5rsx67	cmr7a6mz401d3w8mpvi2m30t7	cmr5wdq6p00ddw83rw50pbwz8	4.000	50.00	200.00	1	25.00
cmr7a7gpe01ekw8mpf6ofwdgo	cmr7a7gpe01eiw8mpyvjz4us7	cmr5tg1ne009hw8ohfuwwn9r4	1.000	50.00	50.00	1	10.00
cmr7ahtjk01pow8mpj2tqs5uz	cmr7ahtjk01pmw8mp70bq37w9	cmr7ahth001pgw8mp81w4l2i8	1.000	100.00	100.00	1	50.00
cmr7ai9lp01qzw8mprynzakl1	cmr7ai9lp01qxw8mp32tyd6so	cmr7ahth001pgw8mp81w4l2i8	1.000	100.00	100.00	1	50.00
cmr7au59h01xvw8mp3zka9jwh	cmr7au59h01xtw8mpkv8sfjfy	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7b8voi023qw8mpm1zrj4qu	cmr7b8voh023ow8mpabdnjxb7	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7b9jdr025bw8mp96wdei24	cmr7b9jdr0259w8mp42oo1gfs	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7bqwrh027cw8mps0lw6zb5	cmr7bqwrh027aw8mp3732z6z1	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7brcyc028nw8mpjvlfo5uj	cmr7brcyc028lw8mpptk47njy	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7ch6l3001jw8rfmvaaw4uk	cmr7ch6l3001hw8rfp3ijhzp6	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7cruy10040w8rfgfrkxs6d	cmr7cruy0003yw8rfr3ofdtd4	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7cs7sx005dw8rfa3w7l4pr	cmr7cs7sx005bw8rf3vlwbvgz	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7ct6in006ow8rftlhlnqv0	cmr7ct6in006mw8rfjc6mzr64	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7da96g0091w8rf5re1t23s	cmr7da96g008zw8rfmdetx8bs	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7dav9n00aaw8rfndqds2za	cmr7dav9n00a8w8rfb2bm7rwa	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7db7vj00bhw8rfmdeedb4u	cmr7db7vj00bfw8rfyxfeitv7	cmr7ahth001pgw8mp81w4l2i8	1.000	100.00	100.00	1	50.00
cmr7dbm7d00cow8rf5nupihfv	cmr7dbm7d00cmw8rfj2unpzqh	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7dbwxd00dzw8rfq5vczzgm	cmr7dbwxd00dxw8rfl1w5fsrt	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7ds3ib00opw8rfg8q6grtv	cmr7ds3ib00onw8rf32cafk45	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7dsv9h00qsw8rffgd7zany	cmr7dsv9h00qqw8rfr5tro5zx	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7duud100w8w8rf0360uyl0	cmr7duud100w6w8rfsdcn8e48	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7e5p57001xw8w9eyrp2wlu	cmr7e5p57001vw8w9zlmbqngc	cmr5wdq6p00ddw83rw50pbwz8	3.000	50.00	150.00	1	25.00
cmr7e6bjj003ew8w9ttvwsiz8	cmr7e6bjj003cw8w9g3eylzxe	cmr5wdq6p00ddw83rw50pbwz8	3.000	50.00	150.00	1	25.00
cmr7ephoi007zw8w9872znude	cmr7ephoi007xw8w9dleyqsui	cmr7au57l01xnw8mp4h6bwy62	1.000	15.00	15.00	1	10.00
cmr7ewzw70023w8l6avkan69d	cmr7ewzw70021w8l6fqz6979e	cmr7au57l01xnw8mp4h6bwy62	7.000	15.00	105.00	1	10.00
cmr7f1umi005ew8l6ru8x2anp	cmr7f1umi005cw8l6ynkeks7b	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
cmr7f28ab006lw8l6sid7qs1s	cmr7f28ab006jw8l65cchhz4n	cmr5tjv3u00bdw8oh5bm4rax4	1.000	100.00	100.00	1	10.00
\.


--
-- Data for Name: customer_sales; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.customer_sales (id, shop_id, customer_id, invoice_no, sale_date, total_amount, paid_amount, due_amount, payment_method, notes, created_at, updated_at, cancel_notes, cancel_reason, cancelled_at, refund_amount, refund_method, status, created_by_user_id, charge_amount, discount_amount, tax_amount) FROM stdin;
cmqw3owkm0027lxugwbjjro4j	cmqtek0us0002lxj6zzrnqalp	cmqtf1e610024lxj6b04g862g	order-1782549068656150	2026-06-27 08:31:09.21	230.00	230.00	0.00	CASH	\N	2026-06-27 08:31:09.286	2026-06-27 08:31:09.286	\N	\N	\N	0.00	\N	ACTIVE	cmqtek0uk0000lxj659fzko6g	0.00	0.00	0.00
cmqxiie5p0055lx0b1ofzi029	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	order-1782634425172502	2026-06-28 08:13:45.806	115.00	0.00	115.00	DUE	\N	2026-06-28 08:13:45.9	2026-06-28 08:13:45.9	\N	\N	\N	0.00	\N	ACTIVE	cmqtek0uk0000lxj659fzko6g	0.00	0.00	0.00
cmqxfmenl004dlxgfzegearqc	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	order-1782629573050284	2026-06-28 06:52:54.228	115.00	100.00	15.00	DUE	\N	2026-06-28 06:52:54.321	2026-06-28 10:46:01.55	\N	\N	\N	0.00	\N	ACTIVE	cmqtek0uk0000lxj659fzko6g	0.00	0.00	0.00
cmr0f1xay002rw8g01c2ysu5o	cmqtek0us0002lxj6zzrnqalp	cmqw8h8o9003glx9fsnajo23e	order-1782810016873499	2026-06-30 09:00:17.215	115.00	0.00	115.00	DUE	\N	2026-06-30 09:00:17.242	2026-06-30 09:00:17.242	\N	\N	\N	0.00	\N	ACTIVE	cmqtek0uk0000lxj659fzko6g	0.00	0.00	0.00
cmr0jig0y0011w8s3kobfd8t8	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782817506202494	2026-06-30 11:05:06.373	465.00	465.00	0.00	CASH	\N	2026-06-30 11:05:06.465	2026-06-30 11:05:06.465	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1no4sf0005w8xngt8jjzub	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	order-1782884956237169	2026-07-01 05:49:16.394	260.00	260.00	0.00	CASH	\N	2026-07-01 05:49:16.48	2026-07-01 05:49:16.48	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr32e26y009fw8fuun6fzbyj	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782970146794165	2026-07-02 05:29:06.949	80.00	80.00	0.00	CASH	\N	2026-07-02 05:29:06.97	2026-07-02 05:29:06.97	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1okhaa0022w8xn2jd7fnjv	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1782886464811078	2026-07-01 06:14:25.473	120.00	120.00	0.00	DUE	\N	2026-07-01 06:14:25.666	2026-07-01 06:39:02.624	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1pebtd002rw8xn1jj2kt77	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1782887857899575	2026-07-01 06:37:38.193	120.00	120.00	0.00	DUE	\N	2026-07-01 06:37:38.257	2026-07-01 06:39:02.625	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr32h9lm00auw8fu9ayyqcyz	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782970296388461	2026-07-02 05:31:36.505	40.00	40.00	0.00	CASH	\N	2026-07-02 05:31:36.538	2026-07-02 05:31:36.538	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1pftau0030w8xnssm2a49w	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1782887927325817	2026-07-01 06:38:47.416	530.00	530.00	0.00	DUE	\N	2026-07-01 06:38:47.573	2026-07-01 06:41:24.765	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1pinxr003rw8xn6rmhpkbk	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1782888060390645	2026-07-01 06:41:00.471	620.00	620.00	0.00	DUE	\N	2026-07-01 06:41:00.591	2026-07-01 06:41:44.533	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1nslf7000kw8xnal3umoza	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782885164491997	2026-07-01 05:52:44.632	120.00	120.00	0.00	CASH	\N	2026-07-01 05:52:44.659	2026-07-01 06:46:41.028	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1oh6zz0018w8xnimfbggnk	cmr0gdhu7005kw8g06c2lngfc	cmr0giodp005ww8g0flg381zs	order-1782886311925459	2026-07-01 06:11:52.276	360.00	360.00	0.00	DUE	\N	2026-07-01 06:11:52.367	2026-07-01 06:57:40.859	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr2zrnuj00ayw82p28oypxwf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782965742623287	2026-07-02 04:15:42.683	80.00	80.00	0.00	CASH	\N	2026-07-02 04:15:42.715	2026-07-02 04:15:42.715	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr2zscu400bzw82pv10yb4mg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782965775034919	2026-07-02 04:16:15.071	80.00	80.00	0.00	CASH	\N	2026-07-02 04:16:15.1	2026-07-02 04:16:15.1	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr31oafs001vw8fu7txff0d0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782968944530467	2026-07-02 05:09:04.578	40.00	40.00	0.00	CASH	\N	2026-07-02 05:09:04.601	2026-07-02 05:09:04.601	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr31qgxv0030w8fuijd3gq0m	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782969046286832	2026-07-02 05:10:46.327	240.00	240.00	0.00	CASH	\N	2026-07-02 05:10:46.34	2026-07-02 05:10:46.34	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr31s2l5003tw8fux6usv7ok	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782969120955758	2026-07-02 05:12:01.037	1240.00	1240.00	0.00	BKASH	\N	2026-07-02 05:12:01.05	2026-07-02 05:12:01.05	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr3255i30058w8fub48dq6ol	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782969730744493	2026-07-02 05:22:11.148	200.00	200.00	0.00	BKASH	\N	2026-07-02 05:22:11.355	2026-07-02 05:22:11.355	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr328k8o0077w8fupldcu09r	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782969890336516	2026-07-02 05:24:50.405	120.00	120.00	0.00	CASH	\N	2026-07-02 05:24:50.425	2026-07-02 05:24:50.425	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr32ceaj008uw8fux35w5uur	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782970069263492	2026-07-02 05:27:49.32	40.00	40.00	0.00	CASH	\N	2026-07-02 05:27:49.34	2026-07-02 05:27:49.34	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr37ybtt00avw8yo9ja0diki	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782979490408070	2026-07-02 08:04:50.521	990.00	990.00	0.00	CASH	\N	2026-07-02 08:04:50.656	2026-07-02 08:04:50.656	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr37yvu100c8w8yoitpqhsgx	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782979516530188	2026-07-02 08:05:16.573	880.00	880.00	0.00	CASH	\N	2026-07-02 08:05:16.586	2026-07-02 08:05:16.586	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr38lhk8006vw896c2xboxoc	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782980571008090	2026-07-02 08:22:51.142	500.00	500.00	0.00	CASH	\N	2026-07-02 08:22:51.176	2026-07-02 08:22:51.176	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr38ur0m00bfw896rwkp0xor	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782981003161065	2026-07-02 08:30:03.29	600.00	550.00	0.00	CASH	\N	2026-07-02 08:30:03.334	2026-07-02 08:30:03.334	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	50.00	0.00
cmr394f0x00diw89684amqowy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782981454228054	2026-07-02 08:37:34.311	1200.00	1200.00	0.00	CASH	\N	2026-07-02 08:37:34.353	2026-07-02 08:37:34.353	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr398sfz00ejw896c6pn0a2l	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782981658225179	2026-07-02 08:40:58.35	1000.00	1000.00	0.00	CASH	\N	2026-07-02 08:40:58.368	2026-07-02 08:40:58.368	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t7440000hw8oh9jijldwg	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782984223741471	2026-07-04 03:35:04.772	2000.00	2000.00	0.00	CASH	\N	2026-07-04 03:35:04.848	2026-07-04 03:35:04.848	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74b7000ww8ohlnovfe8c	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782984429516632	2026-07-04 03:35:05.101	2000.00	2000.00	0.00	CASH	\N	2026-07-04 03:35:05.107	2026-07-04 03:35:05.107	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1oidm6001qw8xngi8dedjm	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	order-1782886367340247	2026-07-01 06:12:47.528	120.00	120.00	0.00	DUE	\N	2026-07-01 06:12:47.598	2026-07-05 04:04:21.295	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr1o9zyu000zw8xncty4nm7k	cmr0gdhu7005kw8g06c2lngfc	cmqw8h8o9003glx9fsnajo23e	order-1782885976431074	2026-07-01 06:06:16.57	120.00	100.00	20.00	DUE	\N	2026-07-01 06:06:16.662	2026-07-05 03:43:43.627	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr33onsq00crw8fukjgzra0y	cmr0gdhu7005kw8g06c2lngfc	cmr1oi6kt001mw8xnqf2m6on0	order-1782972320673438	2026-07-02 06:05:21.097	40.00	10.00	20.00	DUE	\N	2026-07-02 06:05:21.147	2026-07-05 04:04:44.143	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	10.00	0.00
cmr5t74cc001hw8ohqnga9y5s	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782988352184264	2026-07-04 03:35:05.137	1400.00	1400.00	0.00	CASH	\N	2026-07-04 03:35:05.149	2026-07-04 03:35:05.149	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74eu0020w8oh96w6nn2e	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782988765786637	2026-07-04 03:35:05.214	450.00	450.00	0.00	CASH	\N	2026-07-04 03:35:05.238	2026-07-04 03:35:05.238	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74fv002hw8ohmtpbzdwn	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782989488117954	2026-07-04 03:35:05.265	1785.00	1785.00	0.00	CASH	\N	2026-07-04 03:35:05.276	2026-07-04 03:35:05.276	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74is002yw8oh5ewrx1d5	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782989561900135	2026-07-04 03:35:05.353	1050.00	1050.00	0.00	CASH	\N	2026-07-04 03:35:05.38	2026-07-04 03:35:05.38	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74k6003fw8ohd5stmjlo	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782989724275542	2026-07-04 03:35:05.425	600.00	600.00	0.00	CASH	\N	2026-07-04 03:35:05.43	2026-07-04 03:35:05.43	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5t74mz003uw8ohjykya0u0	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1782989874728370	2026-07-04 03:35:05.526	800.00	800.00	0.00	CASH	\N	2026-07-04 03:35:05.531	2026-07-04 03:35:05.531	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5tc8mc007jw8oh3hyy1y8z	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783136343914525	2026-07-04 03:39:03.947	1375.00	1375.00	0.00	CASH	\N	2026-07-04 03:39:03.973	2026-07-04 03:39:03.973	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5tdejb008cw8ohwq77sfih	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783136398210273	2026-07-04 03:39:58.264	2625.00	2625.00	0.00	CASH	\N	2026-07-04 03:39:58.295	2026-07-04 03:39:58.295	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5tg1qz009nw8oh4r4hxepw	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783136521456132	2026-07-04 03:42:01.548	1900.00	1900.00	0.00	CASH	\N	2026-07-04 03:42:01.692	2026-07-04 03:42:01.692	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5th1w400aew8oh4xqrw7bt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783136568435451	2026-07-04 03:42:48.482	4150.00	4150.00	0.00	CASH	\N	2026-07-04 03:42:48.532	2026-07-04 03:42:48.532	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5tjv6800bjw8ohaktljm9n	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783136699638405	2026-07-04 03:44:59.698	9250.00	9250.00	0.00	CASH	\N	2026-07-04 03:44:59.792	2026-07-04 03:44:59.792	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5tz38000cuw8oht64glxo3	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783137409956409	2026-07-04 03:56:50.011	1000.00	1000.00	0.00	CASH	\N	2026-07-04 03:56:50.064	2026-07-04 03:56:50.064	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5u7iom0009w83raonzgeai	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783137803231398	2026-07-04 04:03:23.305	275.00	275.00	0.00	CASH	\N	2026-07-04 04:03:23.35	2026-07-04 04:03:23.35	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5u8090001qw83rmylwgnpf	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783137826017241	2026-07-04 04:03:46.074	150.00	150.00	0.00	CASH	\N	2026-07-04 04:03:46.116	2026-07-04 04:03:46.116	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5u8p9j002nw83rfwcwsy3n	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783137858446586	2026-07-04 04:04:18.502	150.00	150.00	0.00	CASH	\N	2026-07-04 04:04:18.536	2026-07-04 04:04:18.536	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5ukn3c0003w8pld8eh0h18	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	\N	2026-07-04 04:13:35.572	100.00	100.00	0.00	CASH	\N	2026-07-04 04:13:35.593	2026-07-04 04:13:35.593	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5uov5a004ew83ravww52uk	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783138612599249	2026-07-04 04:16:52.637	125.00	125.00	0.00	CASH	\N	2026-07-04 04:16:52.654	2026-07-04 04:16:52.654	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5ur48x0063w83rqlvf99en	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783138717706159	2026-07-04 04:18:37.736	150.00	150.00	0.00	CASH	\N	2026-07-04 04:18:37.761	2026-07-04 04:18:37.761	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5uredd0070w83rxss2c5b6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783138730822851	2026-07-04 04:18:50.86	700.00	700.00	0.00	CASH	\N	2026-07-04 04:18:50.881	2026-07-04 04:18:50.881	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5wdqcq00djw83rwognoxcb	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783141452161662	2026-07-04 05:04:12.224	300.00	300.00	0.00	CASH	\N	2026-07-04 05:04:12.458	2026-07-04 05:04:12.458	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr5xsodq00gew83rab2b6ii1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783143828880819	2026-07-04 05:43:49.234	400.00	400.00	0.00	CASH	\N	2026-07-04 05:43:49.358	2026-07-04 05:43:49.358	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	0.00	0.00
cmr67ddof00fvw8jflwx020z3	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783159911673064	2026-07-04 10:11:51.727	100.00	195.00	0.00	CASH	\N	2026-07-04 10:11:51.806	2026-07-04 10:11:51.806	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	10.00	5.00
cmr67ex0v00guw8jfiu3vyot6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783159983431419	2026-07-04 10:13:03.498	100.00	200.00	0.00	CASH	\N	2026-07-04 10:13:03.535	2026-07-04 10:13:03.535	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	5.00	5.00
cmr67jrkp00ibw8jf2lzswu2s	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783160209649060	2026-07-04 10:16:49.718	300.00	400.00	0.00	CASH	\N	2026-07-04 10:16:49.754	2026-07-04 10:16:49.754	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	14.00	14.00
cmr69b1mb003pw8l334eerwnv	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783163161947181	2026-07-04 11:06:02.035	50.00	153.00	0.00	CASH	\N	2026-07-04 11:06:02.099	2026-07-04 11:06:02.099	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	3.00
cmr69bh21004kw8l3zha0nhrt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783163181977373	2026-07-04 11:06:22.066	100.00	205.00	0.00	CASH	\N	2026-07-04 11:06:22.105	2026-07-04 11:06:22.105	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr69bqeu005bw8l355nkc51n	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783163194138034	2026-07-04 11:06:34.179	100.00	205.00	0.00	CASH	\N	2026-07-04 11:06:34.23	2026-07-04 11:06:34.23	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr69deeh006yw8l3k4wtbkuc	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783163271902402	2026-07-04 11:07:51.945	50.00	153.00	0.00	CASH	\N	2026-07-04 11:07:51.977	2026-07-04 11:07:51.977	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	3.00
cmr33qohd00duw8fuf0fun1r2	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1782972415271005	2026-07-02 06:06:55.293	120.00	60.00	0.00	DUE	\N	2026-07-02 06:06:55.346	2026-07-05 03:42:17.556	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	0.00	60.00	0.00
cmr6801s800l0w8jfqh7ha07s	cmr0gdhu7005kw8g06c2lngfc	cmr1ok9xx001yw8xnlhiz9h3n	order-1783160969148133	2026-07-04 10:29:29.443	50.00	110.00	43.00	DUE	\N	2026-07-04 10:29:29.479	2026-07-05 04:05:37.39	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	3.00
cmr7a6mz401d3w8mpvi2m30t7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783225102228046	2026-07-05 04:18:22.272	200.00	310.00	0.00	CASH	\N	2026-07-05 04:18:22.288	2026-07-05 04:18:22.288	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	10.00
cmr7a7gpe01eiw8mpyvjz4us7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783225140757277	2026-07-05 04:19:00.805	50.00	153.00	0.00	CASH	\N	2026-07-05 04:19:00.818	2026-07-05 04:19:00.818	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	3.00
cmr7ahtjk01pmw8mp70bq37w9	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783225623805475	2026-07-05 04:27:03.895	100.00	205.00	0.00	CASH	\N	2026-07-05 04:27:04.014	2026-07-05 04:27:04.014	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr7ai9lp01qxw8mp32tyd6so	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783225644685231	2026-07-05 04:27:24.809	100.00	205.00	0.00	CASH	\N	2026-07-05 04:27:24.829	2026-07-05 04:27:24.829	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr7au59h01xtw8mpkv8sfjfy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783226198916591	2026-07-05 04:36:38.992	15.00	116.00	0.00	CASH	\N	2026-07-05 04:36:39.076	2026-07-05 04:36:39.076	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7b8voh023ow8mpabdnjxb7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783226886456747	2026-07-05 04:48:06.485	15.00	116.00	0.00	CASH	\N	2026-07-05 04:48:06.498	2026-07-05 04:48:06.498	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7b9jdr0259w8mp42oo1gfs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783226917151718	2026-07-05 04:48:37.192	15.00	116.00	0.00	CASH	\N	2026-07-05 04:48:37.215	2026-07-05 04:48:37.215	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7bqwrh027aw8mp3732z6z1	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783227727601180	2026-07-05 05:02:07.675	15.00	116.00	0.00	CASH	\N	2026-07-05 05:02:07.709	2026-07-05 05:02:07.709	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7brcyc028lw8mpptk47njy	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783227748584257	2026-07-05 05:02:28.669	15.00	116.00	0.00	CASH	\N	2026-07-05 05:02:28.692	2026-07-05 05:02:28.692	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7ch6l3001hw8rfp3ijhzp6	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783228953442400	2026-07-05 05:22:33.478	15.00	116.00	0.00	CASH	\N	2026-07-05 05:22:33.496	2026-07-05 05:22:33.496	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7cruy0003yw8rfr3ofdtd4	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783229451501504	2026-07-05 05:30:51.555	15.00	116.00	0.00	CASH	\N	2026-07-05 05:30:51.625	2026-07-05 05:30:51.625	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7cs7sx005bw8rf3vlwbvgz	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783229468239989	2026-07-05 05:31:08.275	15.00	116.00	0.00	CASH	\N	2026-07-05 05:31:08.289	2026-07-05 05:31:08.289	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7ct6in006mw8rfjc6mzr64	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783229513071520	2026-07-05 05:31:53.239	15.00	116.00	0.00	CASH	\N	2026-07-05 05:31:53.28	2026-07-05 05:31:53.28	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7da96g008zw8rfmdetx8bs	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783230309830192	2026-07-05 05:45:09.864	15.00	116.00	0.00	CASH	\N	2026-07-05 05:45:09.88	2026-07-05 05:45:09.88	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7dav9n00a8w8rfb2bm7rwa	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783230338460629	2026-07-05 05:45:38.496	15.00	116.00	0.00	CASH	\N	2026-07-05 05:45:38.508	2026-07-05 05:45:38.508	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7db7vj00bfw8rfyxfeitv7	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783230354809690	2026-07-05 05:45:54.834	100.00	205.00	0.00	CASH	\N	2026-07-05 05:45:54.847	2026-07-05 05:45:54.847	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr7dbm7d00cmw8rfj2unpzqh	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783230373374524	2026-07-05 05:46:13.404	15.00	116.00	0.00	CASH	\N	2026-07-05 05:46:13.417	2026-07-05 05:46:13.417	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7dbwxd00dxw8rfl1w5fsrt	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783230387173358	2026-07-05 05:46:27.266	15.00	116.00	0.00	CASH	\N	2026-07-05 05:46:27.313	2026-07-05 05:46:27.313	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7ds3ib00onw8rf32cafk45	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783231142268610	2026-07-05 05:59:02.317	15.00	116.00	0.00	CASH	\N	2026-07-05 05:59:02.338	2026-07-05 05:59:02.338	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7dsv9h00qqw8rfr5tro5zx	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783231178229393	2026-07-05 05:59:38.276	15.00	116.00	0.00	CASH	\N	2026-07-05 05:59:38.309	2026-07-05 05:59:38.309	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7duud100w6w8rfsdcn8e48	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783231270413070	2026-07-05 06:01:10.437	15.00	116.00	0.00	CASH	\N	2026-07-05 06:01:10.454	2026-07-05 06:01:10.454	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7e5p57001vw8w9zlmbqngc	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783231776848542	2026-07-05 06:09:36.883	150.00	258.00	0.00	CASH	\N	2026-07-05 06:09:36.907	2026-07-05 06:09:36.907	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	8.00
cmr7e6bjj003cw8w9g3eylzxe	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783231805878432	2026-07-05 06:10:05.919	150.00	258.00	0.00	CASH	\N	2026-07-05 06:10:05.935	2026-07-05 06:10:05.935	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	8.00
cmr7ephoi007xw8w9dleyqsui	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783232700285199	2026-07-05 06:25:00.328	15.00	116.00	0.00	CASH	\N	2026-07-05 06:25:00.354	2026-07-05 06:25:00.354	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	1.00
cmr7ewzw70021w8l6fqz6979e	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783233050042231	2026-07-05 06:30:50.494	105.00	210.00	0.00	CASH	\N	2026-07-05 06:30:50.55	2026-07-05 06:30:50.55	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr7f1umi005cw8l6ynkeks7b	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783233276914395	2026-07-05 06:34:36.976	100.00	205.00	0.00	CASH	\N	2026-07-05 06:34:37.002	2026-07-05 06:34:37.002	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
cmr7f28ab006jw8l65cchhz4n	cmr0gdhu7005kw8g06c2lngfc	cmqtf1e610024lxj6b04g862g	order-1783233294609736	2026-07-05 06:34:54.671	100.00	205.00	0.00	CASH	\N	2026-07-05 06:34:54.707	2026-07-05 06:34:54.707	\N	\N	\N	0.00	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	100.00	0.00	5.00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.customers (id, customer_code, name, mobile, email, address, notes, status, created_at, updated_at, deleted_at, store_credit) FROM stdin;
cmqtf1e610024lxj6b04g862g	GUESTC-917913	Guest Customer	\N	\N	\N	\N	ACTIVE	2026-06-25 11:25:29.209	2026-06-25 11:25:29.209	\N	0.00
cmqw8h8o9003glx9fsnajo23e	SAJIB-978811	Sajib	01537570379	\N	Lalmatia	\N	ACTIVE	2026-06-27 10:45:09.801	2026-06-27 10:45:09.801	\N	0.00
cmr0giodp005ww8g0flg381zs	DID-842526	did	01762161370	\N	a	\N	ACTIVE	2026-06-30 09:41:18.443	2026-06-30 09:41:18.443	\N	0.00
cmr0gjh5a005zw8g05zjs8d5m	RRR-572477	rrr	12341234124	\N	dfgs	\N	ACTIVE	2026-06-30 09:41:55.726	2026-06-30 09:41:55.726	\N	0.00
cmr0gmst3006aw8g0mj6044cw	EEE-080190	eee	23441241432	\N	did	\N	ACTIVE	2026-06-30 09:44:30.807	2026-06-30 09:44:30.807	\N	0.00
cmr0go0be006hw8g03bro81us	FFF-718961	fff	34235233434	\N	dfgsf	\N	ACTIVE	2026-06-30 09:45:27.194	2026-06-30 09:45:27.194	\N	0.00
cmr0go9zm006kw8g06xsi3i2b	TTT-972652	ttt	12341412412	\N	as	\N	ACTIVE	2026-06-30 09:45:39.731	2026-06-30 09:45:39.731	\N	0.00
cmr1oi6kt001mw8xnqf2m6on0	SAKIB-847203	sakib	01762161333	\N	s	\N	ACTIVE	2026-07-01 06:12:38.477	2026-07-01 06:12:38.477	\N	0.00
cmr1ok9xx001yw8xnlhiz9h3n	MONJUR-614867	monjurul	01921976941	\N	Dhaka	\N	ACTIVE	2026-07-01 06:14:16.149	2026-07-01 06:14:16.149	\N	0.00
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.expenses (id, shop_id, category, amount, expense_date, description, payment_method, money_box_id, bank_account_id, status, created_at, updated_at) FROM stdin;
cmr0kx89h001qw8s365soqf23	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	1000.00	2026-06-30 11:44:00.656	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 11:44:35.86	2026-06-30 11:44:35.86
cmr0l3y93001sw8s3givtyo45	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	2000.00	2026-06-30 11:49:30.954	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 11:49:49.478	2026-06-30 11:49:49.478
cmr0lbw070001w8dv5ab73m77	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	12222.00	2026-06-30 11:55:36.915	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 11:55:59.815	2026-06-30 11:55:59.815
cmr0ld71g0005w8dv90ysmx31	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	122222.00	2026-06-30 11:56:46.138	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 11:57:00.772	2026-06-30 11:57:00.772
cmr0ljxhr0007w8dvej0okay2	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	33333.00	2026-06-30 12:02:01.022	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 12:02:14.992	2026-06-30 12:02:14.992
cmr0ll1mq0009w8dvpk12uodp	cmr0gdhu7005kw8g06c2lngfc	পরিবহন	500.00	2026-06-30 12:02:50.605	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 12:03:07.009	2026-06-30 12:03:07.009
cmr0m0yxu0003w8z0p1i0h7ni	cmr0gdhu7005kw8g06c2lngfc	ভাড়া	23232.00	2026-06-30 12:15:06.694	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-06-30 12:15:30.018	2026-06-30 12:15:30.018
cmr1kym570003w8jo0krtphf1	cmr0gdhu7005kw8g06c2lngfc	ইন্টারনেট বিল	3000.00	2026-07-01 03:39:16.571	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-01 04:33:26.684	2026-07-01 04:33:26.684
cmr1kym680005w8jo4zrbxtwr	cmr0gdhu7005kw8g06c2lngfc	মেরামত	1000.00	2026-07-01 03:45:43.026	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-01 04:33:26.72	2026-07-01 04:33:26.72
cmr34sx3300i5w8furlc91whb	cmr0gdhu7005kw8g06c2lngfc	অন্যান্য	2000.00	2026-07-02 06:36:11.099	\N	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 06:36:39.423	2026-07-02 06:36:39.423
cmr35dfnj00jvw8fuvts94t9b	cmr0gdhu7005kw8g06c2lngfc	ভাড়া	5000.00	2026-07-02 06:51:28.038	bhai Kuhn bhalo lok	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 06:52:36.606	2026-07-02 06:52:36.606
cmr35niic0019w83utb0fa4g6	cmr0gdhu7005kw8g06c2lngfc	কর্মচারীর বেতন	3000.00	2026-07-02 06:59:44.314	Beton dissi	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 07:00:26.867	2026-07-02 07:00:26.867
cmr35oo83001jw83usqgfpur8	cmr0gdhu7005kw8g06c2lngfc	মেরামত	4000.00	2026-07-02 07:00:47.427	ict	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 07:01:20.932	2026-07-02 07:01:20.932
cmr35v0a20011w8yoec0ukml6	cmr0gdhu7005kw8g06c2lngfc	অন্যান্য	3000.00	2026-07-02 07:05:37.858	khaowa daowa	BANK	\N	cmr35v09p000zw8yo7in0fqxh	PAID	2026-07-02 07:06:16.49	2026-07-02 07:06:16.49
cmr35wb3p001bw8yoasalk0g2	cmr0gdhu7005kw8g06c2lngfc	ভাড়া	3000.00	2026-07-02 07:07:01.484	vara	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 07:07:17.173	2026-07-02 07:07:17.173
cmr378fc1002rw8yomx714c4m	cmr0gdhu7005kw8g06c2lngfc	বিদ্যুৎ বিল	4000.00	2026-07-02 07:44:23.748	mil	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-02 07:44:42.146	2026-07-02 07:44:42.146
cmr7a8ih301ftw8mpcq4iau1u	cmr0gdhu7005kw8g06c2lngfc	কর্মচারীর বেতন	2000.00	2026-07-05 04:19:29.105	salary	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-05 04:19:49.768	2026-07-05 04:19:49.768
cmr7dkjbk00gqw8rfi423jggz	cmr0gdhu7005kw8g06c2lngfc	পণ্য ক্রয়	1000.00	2026-07-04 18:00:00	fahad	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	PAID	2026-07-05 05:53:09.585	2026-07-05 05:53:09.585
\.


--
-- Data for Name: in_app_notifications; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.in_app_notifications (id, shop_id, type, title, message, "timestamp", created_at, is_read) FROM stdin;
cmr1v3jrs0001w8qdk036ilqg	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:১৭:১২ PM | ১/৭/২০২৬	2026-07-01 09:17:13.046	f
cmr1v3js80003w8qdvaiethrk	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:১৭:১৩ PM | ১/৭/২০২৬	2026-07-01 09:17:13.064	f
cmr1v3js90005w8qdbvq8k2tf	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:১৭:১৩ PM | ১/৭/২০২৬	2026-07-01 09:17:13.066	f
cmr1v3nl10007w8qdkj7u44c1	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:১৭:১৭ PM | ১/৭/২০২৬	2026-07-01 09:17:17.988	f
cmr1v3nla0009w8qdv9v2trbp	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:১৭:১৭ PM | ১/৭/২০২৬	2026-07-01 09:17:17.998	f
cmr1v3nlh000bw8qdfsxl0lls	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:১৭:১৮ PM | ১/৭/২০২৬	2026-07-01 09:17:18.005	f
cmr1v6yiy0017w8qd5q2hjcyv	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:১৯:৫২ PM | ১/৭/২০২৬	2026-07-01 09:19:52.135	f
cmr1v6yjp0019w8qdfqnysnzl	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:১৯:৫২ PM | ১/৭/২০২৬	2026-07-01 09:19:52.165	f
cmr1v6yjq001bw8qd7uiv5jvo	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:১৯:৫২ PM | ১/৭/২০২৬	2026-07-01 09:19:52.166	f
cmr1v8d39001xw8qd4s8tvu9r	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:২০:৫৭ PM | ১/৭/২০২৬	2026-07-01 09:20:57.668	f
cmr1v8d3y001zw8qdzvs1y2qc	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:২০:৫৭ PM | ১/৭/২০২৬	2026-07-01 09:20:57.694	f
cmr1v8d3z0021w8qdzqinsbh9	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:২০:৫৭ PM | ১/৭/২০২৬	2026-07-01 09:20:57.696	f
cmr1vclog003pw8qddvh9phfd	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:২৪:১৫ PM | ১/৭/২০২৬	2026-07-01 09:24:15.424	f
cmr1vclot003rw8qdm0wki0p6	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:২৪:১৫ PM | ১/৭/২০২৬	2026-07-01 09:24:15.437	f
cmr1vcloy003tw8qdlfrg1830	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:২৪:১৫ PM | ১/৭/২০২৬	2026-07-01 09:24:15.442	f
cmr1vfe65004rw8qdriqfu8v7	cmqtek0us0002lxj6zzrnqalp	SALE	টেস্ট বিক্রয় সম্পন্ন	রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন	৩:২৬:২৫ PM | ১/৭/২০২৬	2026-07-01 09:26:25.66	f
cmr1vfe6r004tw8qdik0hhzj6	cmqtek0us0002lxj6zzrnqalp	INVENTORY	টেস্ট স্টক সতর্কতা	পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।	৩:২৬:২৫ PM | ১/৭/২০২৬	2026-07-01 09:26:25.684	f
cmr1vfe6t004vw8qdk87lqkzp	cmqtek0us0002lxj6zzrnqalp	GENERAL	নতুন গ্রাহক যুক্ত হয়েছে	গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।	৩:২৬:২৫ PM | ১/৭/২০২৬	2026-07-01 09:26:25.685	f
cmr1vmrop0001w8bti1f983nc	cmqtek0us0002lxj6zzrnqalp	GENERAL	Antigravity AI	Hello Fahad! I am your AI Assistant. Real-time notifications are working perfectly!	৩:৩২:০৯ PM | ১/৭/২০২৬	2026-07-01 09:32:09.769	f
cmr1vwcej0001w8hhedg8p3t0	cmqtek0us0002lxj6zzrnqalp	GENERAL	Antigravity AI	Testing again after compatibility update!	৩:৩৯:৩৬ PM | ১/৭/২০২৬	2026-07-01 09:39:36.52	f
cmr1w09260003w8y3m9v0zg7e	cmqtek0us0002lxj6zzrnqalp	GENERAL	Antigravity AI	Hello! Notifications are working in realtime!	৩:৪২:৩৮ PM | ১/৭/২০২৬	2026-07-01 09:42:38.812	f
cmr1w2ikt0001w8fp7ggrm7oc	cmqtek0us0002lxj6zzrnqalp	GENERAL	Test Title	Hello Fahad	৩:৪৪:২৪ PM | ১/৭/২০২৬	2026-07-01 09:44:24.459	f
cmr1w38h60003w8fpz9vo0wc0	cmqtek0us0002lxj6zzrnqalp	GENERAL	My Custom Title	This is a test	৩:৪৪:৫৮ PM | ১/৭/২০২৬	2026-07-01 09:44:58.027	f
cmr1w6d9y0001w844yx8h97it	cmqtek0us0002lxj6zzrnqalp	GENERAL	Antigravity AI	Testing real-time alert!	৩:৪৭:২৪ PM | ১/৭/২০২৬	2026-07-01 09:47:24.212	f
cmr1w6dab0003w844bjhtonf3	cmr0gdhu7005kw8g06c2lngfc	GENERAL	Antigravity AI	Testing real-time alert!	৩:৪৭:২৪ PM | ১/৭/২০২৬	2026-07-01 09:47:24.227	f
cmr2zscuo00ccw82ppaep8abi	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782965775034919 | মোট বিক্রয় ৳80 | কাস্টমার: Guest Customer	১০:১৬:১৫ AM | ২/৭/২০২৬	2026-07-02 04:16:15.12	f
cmr2zrnwy00bbw82p6je4xdea	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782965742623287 | মোট বিক্রয় ৳80 | কাস্টমার: Guest Customer	১০:১৫:৪২ AM | ২/৭/২০২৬	2026-07-02 04:15:42.802	t
cmr31oai00026w8fuhixawcmd	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782968944530467 | মোট বিক্রয় ৳40 | কাস্টমার: Guest Customer	১১:০৯:০৪ AM | ২/৭/২০২৬	2026-07-02 05:09:04.681	f
cmr31qgyv003bw8fu7y0fr96b	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782969046286832 | মোট বিক্রয় ৳240 | কাস্টমার: Guest Customer	১১:১০:৪৬ AM | ২/৭/২০২৬	2026-07-02 05:10:46.376	f
cmr31s2ly0044w8fu5p8a7tll	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782969120955758 | মোট বিক্রয় ৳1240 | কাস্টমার: Guest Customer	১১:১২:০১ AM | ২/৭/২০২৬	2026-07-02 05:12:01.078	f
cmr3255j3005lw8fu0039invd	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782969730744493 | মোট বিক্রয় ৳200 | কাস্টমার: Guest Customer	১১:২২:১১ AM | ২/৭/২০২৬	2026-07-02 05:22:11.391	f
cmr328k9q007iw8fucj4qunzn	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782969890336516 | মোট বিক্রয় ৳120 | কাস্টমার: Guest Customer	১১:২৪:৫০ AM | ২/৭/২০২৬	2026-07-02 05:24:50.462	f
cmr32cebq0095w8fu8ooqvdvo	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782970069263492 | মোট বিক্রয় ৳40 | কাস্টমার: Guest Customer	১১:২৭:৪৯ AM | ২/৭/২০২৬	2026-07-02 05:27:49.382	f
cmr32e29l009qw8fufnz2b4ww	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782970146794165 | মোট বিক্রয় ৳80 | কাস্টমার: Guest Customer	১১:২৯:০৭ AM | ২/৭/২০২৬	2026-07-02 05:29:07.066	f
cmr32h9nv00b5w8fuj8pbnonu	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782970296388461 | মোট বিক্রয় ৳40 | কাস্টমার: Guest Customer	১১:৩১:৩৬ AM | ২/৭/২০২৬	2026-07-02 05:31:36.62	f
cmr33onwx00cyw8fuauvfmoqc	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782972320673438 | মোট বিক্রয় ৳40 | কাস্টমার: sakib	১২:০৫:২১ PM | ২/৭/২০২৬	2026-07-02 06:05:21.297	f
cmr33qom300e1w8fu70ntcs76	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782972415271005 | মোট বিক্রয় ৳120 | কাস্টমার: monjurul	১২:০৬:৫৫ PM | ২/৭/২০২৬	2026-07-02 06:06:55.516	f
cmr37ybw500biw8yojii2xwsv	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782979490408070 | মোট বিক্রয় ৳990 | কাস্টমার: Guest Customer	২:০৪:৫০ PM | ২/৭/২০২৬	2026-07-02 08:04:50.74	f
cmr37yvuk00cjw8yoe80h5uey	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782979516530188 | মোট বিক্রয় ৳880 | কাস্টমার: Guest Customer	২:০৫:১৬ PM | ২/৭/২০২৬	2026-07-02 08:05:16.605	f
cmr38lhug0076w896liy6gtf1	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782980571008090 | মোট বিক্রয় ৳500 | কাস্টমার: Guest Customer	২:২২:৫১ PM | ২/৭/২০২৬	2026-07-02 08:22:51.543	f
cmr38ur7800bqw8962gqaqwsx	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782981003161065 | মোট বিক্রয় ৳600 | কাস্টমার: Guest Customer	২:৩০:০৩ PM | ২/৭/২০২৬	2026-07-02 08:30:03.573	f
cmr394f1y00dtw8969ph0qja4	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782981454228054 | মোট বিক্রয় ৳1200 | কাস্টমার: Guest Customer	২:৩৭:৩৪ PM | ২/৭/২০২৬	2026-07-02 08:37:34.39	f
cmr398smm00euw8962ul2wem4	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782981658225179 | মোট বিক্রয় ৳1000 | কাস্টমার: Guest Customer	২:৪০:৫৮ PM | ২/৭/২০২৬	2026-07-02 08:40:58.607	f
cmr5t7464000sw8ohctdn1nkr	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782984223741471 | মোট বিক্রয় ৳2000 | কাস্টমার: Guest Customer	৯:৩৫:০৪ AM | ৪/৭/২০২৬	2026-07-04 03:35:04.924	f
cmr5t74bd0017w8ohbf4qad1v	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782984429516632 | মোট বিক্রয় ৳2000 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.114	f
cmr5t74ck001sw8ohosqb0yzh	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782988352184264 | মোট বিক্রয় ৳1400 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.157	f
cmr5t74f1002dw8ohh68eq3jx	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782988765786637 | মোট বিক্রয় ৳450 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.245	f
cmr5t74gx002uw8ohca5n0wlg	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782989488117954 | মোট বিক্রয় ৳1785 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.314	f
cmr5t74j2003bw8ohm1mdsyp0	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782989561900135 | মোট বিক্রয় ৳1050 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.39	f
cmr5t74m3003qw8ohtjq5w53r	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782989724275542 | মোট বিক্রয় ৳600 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.499	f
cmr5t74n30045w8ohbzigiyss	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1782989874728370 | মোট বিক্রয় ৳800 | কাস্টমার: Guest Customer	৯:৩৫:০৫ AM | ৪/৭/২০২৬	2026-07-04 03:35:05.535	f
cmr5tc8n1007uw8oh8kdzypzq	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783136343914525 | মোট বিক্রয় ৳1375 | কাস্টমার: Guest Customer	৯:৩৯:০৩ AM | ৪/৭/২০২৬	2026-07-04 03:39:03.997	f
cmr5tdek0008nw8ohhtct5cqo	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783136398210273 | মোট বিক্রয় ৳2625 | কাস্টমার: Guest Customer	৯:৩৯:৫৮ AM | ৪/৭/২০২৬	2026-07-04 03:39:58.321	f
cmr5tg1s4009yw8ohkbqu4u1k	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783136521456132 | মোট বিক্রয় ৳1900 | কাস্টমার: Guest Customer	৯:৪২:০১ AM | ৪/৭/২০২৬	2026-07-04 03:42:01.733	f
cmr5th1xp00apw8ohhtjg6ck8	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783136568435451 | মোট বিক্রয় ৳4150 | কাস্টমার: Guest Customer	৯:৪২:৪৮ AM | ৪/৭/২০২৬	2026-07-04 03:42:48.589	f
cmr5tjv7z00bww8ohaxbsa2hy	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783136699638405 | মোট বিক্রয় ৳9250 | কাস্টমার: Guest Customer	৯:৪৪:৫৯ AM | ৪/৭/২০২৬	2026-07-04 03:44:59.855	f
cmr5tz38r00d5w8ohyrwnkysd	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783137409956409 | মোট বিক্রয় ৳1000 | কাস্টমার: Guest Customer	৯:৫৬:৫০ AM | ৪/৭/২০২৬	2026-07-04 03:56:50.091	f
cmr5u7ir8000ow83rta2g4lc3	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783137803231398 | মোট বিক্রয় ৳275 | কাস্টমার: Guest Customer	১০:০৩:২৩ AM | ৪/৭/২০২৬	2026-07-04 04:03:23.444	f
cmr5u809k0023w83r15g4flyu	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783137826017241 | মোট বিক্রয় ৳150 | কাস্টমার: Guest Customer	১০:০৩:৪৬ AM | ৪/৭/২০২৬	2026-07-04 04:03:46.137	f
cmr5u8pab0030w83rlpkv0kz7	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783137858446586 | মোট বিক্রয় ৳150 | কাস্টমার: Guest Customer	১০:০৪:১৮ AM | ৪/৭/২০২৬	2026-07-04 04:04:18.564	f
cmr5ukn4w000ew8plqp67xsnz	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং cmr5ukn3c0003w8pld8eh0h18 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১০:১৩:৩৫ AM | ৪/৭/২০২৬	2026-07-04 04:13:35.649	f
cmr5uov5w004pw83rv291xe34	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783138612599249 | মোট বিক্রয় ৳125 | কাস্টমার: Guest Customer	১০:১৬:৫২ AM | ৪/৭/২০২৬	2026-07-04 04:16:52.677	f
cmr5ur49o006gw83r2tfajkdg	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783138717706159 | মোট বিক্রয় ৳150 | কাস্টমার: Guest Customer	১০:১৮:৩৭ AM | ৪/৭/২০২৬	2026-07-04 04:18:37.789	f
cmr5ureds007bw83r2st2r8m9	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783138730822851 | মোট বিক্রয় ৳700 | কাস্টমার: Guest Customer	১০:১৮:৫০ AM | ৪/৭/২০২৬	2026-07-04 04:18:50.896	f
cmr5wdqeq00duw83rf9swzsw5	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783141452161662 | মোট বিক্রয় ৳300 | কাস্টমার: Guest Customer	১১:০৪:১২ AM | ৪/৭/২০২৬	2026-07-04 05:04:12.53	f
cmr5xsoex00gpw83rbihy9zln	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783143828880819 | মোট বিক্রয় ৳400 | কাস্টমার: Guest Customer	১১:৪৩:৪৯ AM | ৪/৭/২০২৬	2026-07-04 05:43:49.401	f
cmr67ddrq00g6w8jfrky2ts9s	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783159911673064 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	৪:১১:৫১ PM | ৪/৭/২০২৬	2026-07-04 10:11:51.926	f
cmr67ex1o00h5w8jf1dp01fim	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783159983431419 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	৪:১৩:০৩ PM | ৪/৭/২০২৬	2026-07-04 10:13:03.564	f
cmr67jrmv00imw8jfv66hqldv	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783160209649060 | মোট বিক্রয় ৳300 | কাস্টমার: Guest Customer	৪:১৬:৪৯ PM | ৪/৭/২০২৬	2026-07-04 10:16:49.832	f
cmr6801tg00l7w8jfan0h9k3a	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783160969148133 | মোট বিক্রয় ৳50 | কাস্টমার: monjurul	৪:২৯:২৯ PM | ৪/৭/২০২৬	2026-07-04 10:29:29.525	f
cmr69b2hk0040w8l3pfochyk9	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783163161947181 | মোট বিক্রয় ৳50 | কাস্টমার: Guest Customer	৫:০৬:০২ PM | ৪/৭/২০২৬	2026-07-04 11:06:03.224	f
cmr69bh3n004vw8l3esnml4br	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783163181977373 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	৫:০৬:২২ PM | ৪/৭/২০২৬	2026-07-04 11:06:22.162	f
cmr69bqg0005mw8l3umvzq8u9	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783163194138034 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	৫:০৬:৩৪ PM | ৪/৭/২০২৬	2026-07-04 11:06:34.272	f
cmr69defx0079w8l36kt0l9ft	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783163271902402 | মোট বিক্রয় ৳50 | কাস্টমার: Guest Customer	৫:০৭:৫২ PM | ৪/৭/২০২৬	2026-07-04 11:07:52.029	f
cmr78w8pr00grw8mpj97hqxn1	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক monjurul এর কাছ থেকে সফলভাবে ৳100 আদায় করা হয়েছে।	৯:৪২:১৭ AM | ৫/৭/২০২৬	2026-07-05 03:42:17.631	f
cmr78wxts00jpw8mp1mt841ad	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক sakib এর কাছ থেকে সফলভাবে ৳100 আদায় করা হয়েছে।	৯:৪২:৫০ AM | ৫/৭/২০২৬	2026-07-05 03:42:50.176	f
cmr78y32y00m1w8mpc08fdfca	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক Sajib এর কাছ থেকে সফলভাবে ৳100 আদায় করা হয়েছে।	৯:৪৩:৪৩ AM | ৫/৭/২০২৬	2026-07-05 03:43:43.643	f
cmr78z1lt00ndw8mpgi0fwwme	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক monjurul এর কাছ থেকে সফলভাবে ৳50 আদায় করা হয়েছে।	৯:৪৪:২৮ AM | ৫/৭/২০২৬	2026-07-05 03:44:28.386	f
cmr797pcp00rxw8mpie6kikgz	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক ttt এর কাছ থেকে সফলভাবে ৳50 আদায় করা হয়েছে।	৯:৫১:১২ AM | ৫/৭/২০২৬	2026-07-05 03:51:12.41	f
cmr799ybj00ujw8mp5ay2mlhi	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক sakib এর কাছ থেকে সফলভাবে ৳10 আদায় করা হয়েছে।	৯:৫২:৫৭ AM | ৫/৭/২০২৬	2026-07-05 03:52:57.343	f
cmr79om2k00ybw8mpxmwarii1	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক sakib এর কাছ থেকে সফলভাবে ৳10 আদায় করা হয়েছে।	১০:০৪:২১ AM | ৫/৭/২০২৬	2026-07-05 04:04:21.308	f
cmr79p3p800zbw8mpypxq779n	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক sakib এর কাছ থেকে সফলভাবে ৳10 আদায় করা হয়েছে।	১০:০৪:৪৪ AM | ৫/৭/২০২৬	2026-07-05 04:04:44.156	f
cmr79q8sb0115w8mp80r58w2a	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক monjurul এর কাছ থেকে সফলভাবে ৳20 আদায় করা হয়েছে।	১০:০৫:৩৭ AM | ৫/৭/২০২৬	2026-07-05 04:05:37.404	f
cmr7a6n0n01dew8mp3b32t4uv	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783225102228046 | মোট বিক্রয় ৳200 | কাস্টমার: Guest Customer	১০:১৮:২২ AM | ৫/৭/২০২৬	2026-07-05 04:18:22.344	f
cmr7a7gqv01etw8mpibv7es80	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783225140757277 | মোট বিক্রয় ৳50 | কাস্টমার: Guest Customer	১০:১৯:০০ AM | ৫/৭/২০২৬	2026-07-05 04:19:00.871	f
cmr7ahtkn01pxw8mp83kw5z46	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783225623805475 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১০:২৭:০৪ AM | ৫/৭/২০২৬	2026-07-05 04:27:04.055	f
cmr7ai9mg01r8w8mpaebzzjg5	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783225644685231 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১০:২৭:২৪ AM | ৫/৭/২০২৬	2026-07-05 04:27:24.856	f
cmr7au5b601y4w8mp8riok5po	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783226198916591 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১০:৩৬:৩৯ AM | ৫/৭/২০২৬	2026-07-05 04:36:39.137	f
cmr7b8vpb023zw8mpygfurq0a	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783226886456747 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১০:৪৮:০৬ AM | ৫/৭/২০২৬	2026-07-05 04:48:06.528	f
cmr7b9jef025kw8mpjep1pmfr	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783226917151718 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১০:৪৮:৩৭ AM | ৫/৭/২০২৬	2026-07-05 04:48:37.239	f
cmr7bqwsf027lw8mpe81ps478	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783227727601180 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:০২:০৭ AM | ৫/৭/২০২৬	2026-07-05 05:02:07.743	f
cmr7brcyo028ww8mpq4f5ei25	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783227748584257 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:০২:২৮ AM | ৫/৭/২০২৬	2026-07-05 05:02:28.705	f
cmr7ch6oc001sw8rfs0hf5gaq	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783228953442400 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:২২:৩৩ AM | ৫/৭/২০২৬	2026-07-05 05:22:33.613	f
cmr7crv1d0049w8rfjns15cnd	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783229451501504 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৩০:৫১ AM | ৫/৭/২০২৬	2026-07-05 05:30:51.745	f
cmr7cs7tn005mw8rf7l00apfk	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783229468239989 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৩১:০৮ AM | ৫/৭/২০২৬	2026-07-05 05:31:08.316	f
cmr7ct6jm006xw8rfnd84aa14	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783229513071520 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৩১:৫৩ AM | ৫/৭/২০২৬	2026-07-05 05:31:53.314	f
cmr7da97f009aw8rfb6whj85k	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783230309830192 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৪৫:০৯ AM | ৫/৭/২০২৬	2026-07-05 05:45:09.915	f
cmr7dava100ajw8rfvsxysssm	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783230338460629 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৪৫:৩৮ AM | ৫/৭/২০২৬	2026-07-05 05:45:38.521	f
cmr7db7wb00bqw8rf8ogmx4qi	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783230354809690 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১১:৪৫:৫৪ AM | ৫/৭/২০২৬	2026-07-05 05:45:54.875	f
cmr7dbm7v00cxw8rfhf43h2no	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783230373374524 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৪৬:১৩ AM | ৫/৭/২০২৬	2026-07-05 05:46:13.436	f
cmr7dbwxr00e8w8rf47atvr8b	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783230387173358 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৪৬:২৭ AM | ৫/৭/২০২৬	2026-07-05 05:46:27.327	f
cmr7dq6kw00mnw8rf2bb5mvzz	cmr0gdhu7005kw8g06c2lngfc	SALE	পেমেন্ট গ্রহণ হয়েছে	গ্রাহক ttt এর কাছ থেকে সফলভাবে ৳50 আদায় করা হয়েছে।	১১:৫৭:৩৩ AM | ৫/৭/২০২৬	2026-07-05 05:57:33.009	f
cmr7ds3jl00oyw8rfbwf3kh7u	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783231142268610 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৫৯:০২ AM | ৫/৭/২০২৬	2026-07-05 05:59:02.385	f
cmr7dsvak00r1w8rfv8eitfdr	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783231178229393 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১১:৫৯:৩৮ AM | ৫/৭/২০২৬	2026-07-05 05:59:38.346	f
cmr7duuds00whw8rf8uje2u1s	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783231270413070 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১২:০১:১০ PM | ৫/৭/২০২৬	2026-07-05 06:01:10.48	f
cmr7e5p8o0026w8w96kdwg7jq	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783231776848542 | মোট বিক্রয় ৳150 | কাস্টমার: Guest Customer	১২:০৯:৩৬ PM | ৫/৭/২০২৬	2026-07-05 06:09:37.032	f
cmr7e6bkb003nw8w97li1bsgo	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783231805878432 | মোট বিক্রয় ৳150 | কাস্টমার: Guest Customer	১২:১০:০৫ PM | ৫/৭/২০২৬	2026-07-05 06:10:05.963	f
cmr7ephpq0088w8w93mck1qvz	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783232700285199 | মোট বিক্রয় ৳15 | কাস্টমার: Guest Customer	১২:২৫:০০ PM | ৫/৭/২০২৬	2026-07-05 06:25:00.399	f
cmr7ewzz4002cw8l6hwi1mdax	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783233050042231 | মোট বিক্রয় ৳105 | কাস্টমার: Guest Customer	১২:৩০:৫০ PM | ৫/৭/২০২৬	2026-07-05 06:30:50.656	f
cmr7f1uos005nw8l691ap3vyj	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783233276914395 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১২:৩৪:৩৭ PM | ৫/৭/২০২৬	2026-07-05 06:34:37.084	f
cmr7f28ed006uw8l6gyaqkaxo	cmr0gdhu7005kw8g06c2lngfc	SALE	নতুন বিক্রয় হয়েছে	রসিদ নং order-1783233294609736 | মোট বিক্রয় ৳100 | কাস্টমার: Guest Customer	১২:৩৪:৫৪ PM | ৫/৭/২০২৬	2026-07-05 06:34:54.853	f
\.


--
-- Data for Name: inventory_bin_items; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.inventory_bin_items (id, shop_id, bin_id, master_product_id, purchase_item_id, quantity, batch_no, expiry_date, notes, created_at, updated_at, purchase_price, sale_price) FROM stdin;
cmqteml250013lxj6fnhob5s4	cmqtek0us0002lxj6zzrnqalp	cmqteml1n0011lxj6wj4dvfa7	cmq3qiahw0005lxru9rwwztl9	\N	50.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.301	2026-06-25 11:13:58.301	125.00	130.00
cmqteml4t0019lxj65yl3yzcy	cmqtek0us0002lxj6zzrnqalp	cmqteml4i0017lxj6zcme0n8r	cmqnq97tc000zlx4up9ymaj58	\N	30.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.397	2026-06-25 11:13:58.397	15.00	15.00
cmqtemlcf001hlxj624wzsis2	cmqtek0us0002lxj6zzrnqalp	cmqteml78001flxj6mmjtmzzy	cmqnq97ut0013lx4ueqfkijq8	\N	25.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.671	2026-06-25 11:13:58.671	20.00	20.00
cmqtemldr001llxj6cw6ir0p0	cmqtek0us0002lxj6zzrnqalp	cmqtemldh001jlxj60ztn0b3s	cmqnq97vj0017lx4uc77sbdn6	\N	30.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.719	2026-06-25 11:13:58.719	30.00	30.00
cmqtemlf2001plxj6tiqwvlkw	cmqtek0us0002lxj6zzrnqalp	cmqtemles001nlxj66ku4s2a8	cmqnq97wg001blx4ueh3hh29z	\N	100.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.766	2026-06-25 11:13:58.766	55.00	60.00
cmqtemlg9001tlxj6xuv6lcw5	cmqtek0us0002lxj6zzrnqalp	cmqtemlg0001rlxj6vx69hqos	cmqnq97j1000flx4uexre8xhw	\N	60.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.809	2026-06-25 11:13:58.809	15.00	15.00
cmqtemlhg001xlxj6vigwey6l	cmqtek0us0002lxj6zzrnqalp	cmqtemlh7001vlxj6hmml8nkc	cmqnq97r6000vlx4usqsalrhi	\N	15.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.852	2026-06-25 11:13:58.852	105.00	115.00
cmqtemlin0021lxj6exo5vrca	cmqtek0us0002lxj6zzrnqalp	cmqtemlie001zlxj69l7vvgc0	cmqnq97kz000jlx4uxdu3s9ws	\N	20.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.895	2026-06-25 11:13:58.895	20.00	20.00
cmqteml68001dlxj61tdgjiya	cmqtek0us0002lxj6zzrnqalp	cmqteml5x001blxj60my4j0h4	cmqnq97x4001flx4upjb4nzcm	\N	20.000	1	\N	Quick setup batch 1	2026-06-25 11:13:58.448	2026-06-30 09:00:17.228	105.00	115.00
cmr0f4tmt004nw8g0pfcwuwn2	cmqtek0us0002lxj6zzrnqalp	cmqteml1n0011lxj6wj4dvfa7	cmq3qiahw0005lxru9rwwztl9	cmr0f4tlv004kw8g048u2de9j	1.000	2	\N	Assigned from purchase approval/receive flow.	2026-06-30 09:02:32.454	2026-06-30 09:02:32.454	126.00	130.00
cmr0j5bqn001ew8b5imfxmumv	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bjy000dw8b5e0kpvmqu	cmqnc6u0x000plxvskd56o9d9	cmr0j5bqc0016w8b5y6ezqewd	6.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.384	2026-06-30 10:54:54.384	120.00	120.00
cmr0j5bqs001hw8b5swews1zp	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bpl000uw8b5dv0xwrh7	cmqnq97tc000zlx4up9ymaj58	cmr0j5bqc0017w8b5wl2st6n5	700.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.388	2026-06-30 10:54:54.388	15.00	15.00
cmr0j5brt001yw8b52y15u0wy	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bjy000dw8b5e0kpvmqu	cmqnc6u0x000plxvskd56o9d9	cmr0j5brl001uw8b5e34qkh5d	400.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.425	2026-06-30 10:54:54.425	120.00	120.00
cmr0j5brv0021w8b5hlaisp0c	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr0j5brl001vw8b5jkofd620	900.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.428	2026-06-30 10:54:54.428	30.00	30.00
cmr0j6qu70031w8b5902ximah	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr0j6qts002rw8b5h98araqi	155.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.607	2026-06-30 10:56:00.607	30.00	\N
cmr0j6qub0034w8b5kjafg6tv	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bjy000dw8b5e0kpvmqu	cmqnc6u0x000plxvskd56o9d9	cmr0j6qts002sw8b5aqfr5enf	144444.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.611	2026-06-30 10:56:00.611	120.00	\N
cmr0j6qui0037w8b5va7jpd05	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bpl000uw8b5dv0xwrh7	cmqnq97tc000zlx4up9ymaj58	cmr0j6qts002tw8b5rhj2zss5	1333.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.619	2026-06-30 10:56:00.619	15.00	\N
cmr0j6qum003aw8b5zsgc2yk4	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bqv001jw8b5yqiwpt32	cmqnq97x4001flx4upjb4nzcm	cmr0j6qts002uw8b57ito6hpz	1222.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.622	2026-06-30 10:56:00.622	105.00	\N
cmr0jdqeq000aw8s3k2wb6p8i	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97n4000nlx4umqv6wqxb	cmr0jdqe90007w8s32brdeq06	30.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 11:01:26.642	2026-06-30 11:01:26.642	30.00	30.00
cmr0jg0oh000rw8s3sr8nqimn	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr0jg0lv000ow8s3vbntwydp	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 11:03:13.265	2026-06-30 11:03:13.265	125.00	125.00
cmr0j5bpg000sw8b55e5enx6u	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bjy000dw8b5e0kpvmqu	cmqnc6u0x000plxvskd56o9d9	cmr0j5bp7000ow8b5yquyrzm1	8.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.341	2026-07-01 06:41:00.524	120.00	120.00
cmr0j5bqi001bw8b5db2d8lcp	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr0j5bqc0015w8b50mcczq7j	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.379	2026-07-01 06:41:00.536	30.00	30.00
cmr0j5bqx001mw8b5enyynvxs	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bqv001jw8b5yqiwpt32	cmqnq97x4001flx4upjb4nzcm	cmr0j5bqc0018w8b5a50yul0b	897.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.394	2026-07-01 06:41:00.539	105.00	105.00
cmr0j6qva003uw8b5b8ns37ro	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qv8003rw8b5ujttgncg	cmqnq97n4000nlx4umqv6wqxb	cmr0j6qts002yw8b5187yl7dq	14440.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.646	2026-07-02 08:04:50.625	30.00	\N
cmr0j6qus003fw8b572mtjzrx	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qup003cw8b5r4tnpwgn	cmq3qiahw0005lxru9rwwztl9	cmr0j6qts002vw8b5zjgfgpqc	1328.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.628	2026-07-02 08:04:50.649	125.00	\N
cmr0j7mt30047w8b5lrleb2b8	cmr0gdhu7005kw8g06c2lngfc	cmr0j7msv0044w8b5vfhjlpnt	cmqnq97p4000rlx4updfrju1f	cmr0j7msc0042w8b5mkryfpzq	3983.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:42.039	2026-07-04 03:35:05.268	55.00	\N
cmr0j5bpr000xw8b5c4m23u68	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bpl000uw8b5dv0xwrh7	cmqnq97tc000zlx4up9ymaj58	cmr0j5bp7000pw8b5jsbkk54n	8.000	1	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:54:54.351	2026-07-01 06:41:00.56	15.00	15.00
cmr1l09nc001fw8joh7dnz3wp	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97tc000zlx4up9ymaj58	cmr1l09mt0019w8jo3wfds6v3	5.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-01 04:34:43.801	2026-07-01 04:34:43.801	15.00	15.00
cmr1l09nt001iw8jo66r75459	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr1l09mt001aw8jotv507yuz	6.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-01 04:34:43.817	2026-07-01 04:34:43.817	105.00	105.00
cmr1l09o0001lw8joifl936nh	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr1l09mt001bw8jo0zw18thc	5.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-01 04:34:43.824	2026-07-01 04:34:43.824	125.00	125.00
cmr1l09o6001ow8joywbueb9t	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97r6000vlx4usqsalrhi	cmr1l09mt001cw8joritk4ary	8.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-01 04:34:43.83	2026-07-01 04:34:43.83	105.00	105.00
cmr2zq3g1008bw82puaskjcnm	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr2zq3ew0081w82pw8afaqyk	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:14:29.617	2026-07-02 04:14:29.617	30.00	30.00
cmr2zq3g7008ew82px62h208w	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr2zq3ew0082w82p41ho93zw	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:14:29.624	2026-07-02 04:14:29.624	105.00	105.00
cmr2zr10t00a5w82p3byr4d2o	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97tc000zlx4up9ymaj58	cmr2zr10d009zw82p5mh02zk4	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:15:13.133	2026-07-02 04:15:13.133	15.00	15.00
cmr2zr11300a8w82pmnylm8pe	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnc6u0x000plxvskd56o9d9	cmr2zr10d00a0w82pzfo8ka8w	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:15:13.143	2026-07-02 04:15:13.143	120.00	120.00
cmr2zr11b00abw82p2e6bboze	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr2zr10d00a1w82pcirxuuxa	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:15:13.151	2026-07-02 04:15:13.151	30.00	30.00
cmr2zr11i00aew82po26v7bit	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr2zr10d00a2w82px2jrsow8	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:15:13.158	2026-07-02 04:15:13.158	125.00	125.00
cmr37uz2h007pw8yo3jsfudgo	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97r6000vlx4usqsalrhi	cmr37uz1z007mw8yoidlc3lpa	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:02:14.154	2026-07-02 08:02:14.154	105.00	105.00
cmr37w601009mw8yo9xnhn5jz	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr37w5ym009cw8yolka4xm3q	2.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.794	2026-07-02 08:03:09.794	30.00	30.00
cmr37w60g009pw8yoahhphn4j	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnc6u0x000plxvskd56o9d9	cmr37w5ym009dw8yoysp9msbx	100.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.809	2026-07-02 08:03:09.809	120.00	120.00
cmr2ye0qk0046w8zbodrli74v	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97r6000vlx4usqsalrhi	cmr2ye0py0041w8zbq9dp6p0h	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:37:06.62	2026-07-02 03:37:06.62	105.00	105.00
cmr2ye0qv0049w8zbi1p53mzk	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97kz000jlx4uxdu3s9ws	cmr2ye0py0042w8zbsjgk5csj	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:37:06.631	2026-07-02 03:37:06.631	20.00	20.00
cmr2ylva1006hw8zbzw6nt5cy	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97tc000zlx4up9ymaj58	cmr2ylv9n006ew8zb6k1kvo8i	2.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:43:12.793	2026-07-02 03:43:12.793	15.00	15.00
cmr2ynt77007ww8zbu2oqq1er	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97kz000jlx4uxdu3s9ws	cmr2ynt6n007sw8zbw8wwbqkn	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:44:43.412	2026-07-02 03:44:43.412	20.00	20.00
cmr2ynt7n007zw8zb8skbdw3p	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97n4000nlx4umqv6wqxb	cmr2ynt6n007tw8zbw35h26ik	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:44:43.427	2026-07-02 03:44:43.427	30.00	30.00
cmr2yuiwr00a0w8zbcg5wplo7	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97kz000jlx4uxdu3s9ws	cmr2yuiw3009xw8zbox23j7sk	7.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:49:56.667	2026-07-02 03:49:56.667	20.00	20.00
cmr2z123t001kw8hoeajicuu6	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr2z1238001gw8horjhpnzkb	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:55:01.482	2026-07-02 03:55:01.482	125.00	125.00
cmr2z1244001nw8how4d32tj6	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr2z1238001hw8hoaeraaf63	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 03:55:01.493	2026-07-02 03:55:01.493	105.00	105.00
cmr2z8dqb001ew82p938g9j15	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr2z8dpp001bw82p5qhw1rd0	5.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:00:43.14	2026-07-02 04:00:43.14	105.00	105.00
cmr2z90tg002jw82py1qw7yww	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr2z90t1002gw82p9jbfgc7e	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:01:13.061	2026-07-02 04:01:13.061	105.00	105.00
cmr2zq3fi0085w82pdn7put2y	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97tc000zlx4up9ymaj58	cmr2zq3ew007zw82p3bfu9ef2	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:14:29.598	2026-07-02 04:14:29.598	15.00	15.00
cmr2zq3fv0088w82p33r0kkdy	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnc6u0x000plxvskd56o9d9	cmr2zq3ew0080w82p8nsderea	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 04:14:29.611	2026-07-02 04:14:29.611	120.00	120.00
cmr37tp77006qw8yoqmfsspst	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr37tp6m006nw8yo0u93ijed	5.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:01:14.707	2026-07-02 08:01:14.707	30.00	30.00
cmr37w60o009sw8yoxi4jovlo	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97tc000zlx4up9ymaj58	cmr37w5ym009ew8yo4owgtlnw	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.817	2026-07-02 08:03:09.817	15.00	15.00
cmr37w60u009vw8yom2s4mutk	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr37w5ym009fw8yoa5akxm76	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.823	2026-07-02 08:03:09.823	105.00	105.00
cmr37w60z009yw8yonf99v5do	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr37w5ym009gw8yo7o8n9q6d	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.828	2026-07-02 08:03:09.828	125.00	125.00
cmr37w61d00a4w8yolg52m22u	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97n4000nlx4umqv6wqxb	cmr37w5ym009iw8yoff78gddm	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.841	2026-07-02 08:03:09.841	30.00	30.00
cmr37w61k00a7w8yog5n7v2is	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97p4000rlx4updfrju1f	cmr37w5ym009jw8yo3h04cmbo	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:03:09.848	2026-07-02 08:03:09.848	55.00	55.00
cmr0j6qv1003kw8b5fd9ccjfe	cmr0gdhu7005kw8g06c2lngfc	cmr0j6quz003hw8b5alyj12a5	cmqnq97r6000vlx4usqsalrhi	cmr0j6qts002ww8b5qh9mg8dz	18883.000	\N	\N	Assigned from purchase approval/receive flow.	2026-06-30 10:56:00.638	2026-07-02 08:04:50.64	105.00	\N
cmr38sali00abw896yu7s0mhr	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr38sag500a8w896zwi2wmfj	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:28:08.74	2026-07-02 08:28:08.74	105.00	105.00
cmr39a3jt00g1w896yy26iyc1	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr39a3jd00fxw8960vc4thjy	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 08:41:59.418	2026-07-02 08:41:59.418	105.00	105.00
cmr3drcjk00luw87piob3ndo5	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr3drciz00lrw87pit1pkp7u	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-02 10:47:22.688	2026-07-02 10:47:22.688	125.00	125.00
cmr5t74el001yw8oh2fc9ea9r	cmr0gdhu7005kw8g06c2lngfc	cmr5t74ek001ww8oh2celxi4t	cmr394f0b00dgw89676gha1f1	\N	1968.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:35:05.229	2026-07-04 10:16:49.731	150.00	150.00
cmr69bqe90059w8l3gwdtsnyq	cmr0gdhu7005kw8g06c2lngfc	cmr69bqe50057w8l3ernaqv1i	cmr38lhjj006tw896tmrl2wl3	\N	2994.000	1	\N	Auto-generated bin item for checkout	2026-07-04 11:06:34.21	2026-07-04 11:06:34.215	50.00	100.00
cmr7ahti901pkw8mp00eb00pf	cmr0gdhu7005kw8g06c2lngfc	cmr7ahti501piw8mpjm0xe6rn	cmr7ahth001pgw8mp81w4l2i8	\N	97.000	1	\N	Auto-generated bin item for checkout	2026-07-05 04:27:03.969	2026-07-05 05:45:54.839	50.00	100.00
cmr5t74c8001fw8ohjptywsyg	cmr0gdhu7005kw8g06c2lngfc	cmr5t74c8001dw8oh62i01x5i	cmr5t74c3001bw8oh2k59ek9v	\N	3976.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:35:05.145	2026-07-04 03:35:05.427	100.00	200.00
cmr5t743i000fw8ohgetxufjn	cmr0gdhu7005kw8g06c2lngfc	cmr5t743d000dw8ohczzhz52o	cmr5t7422000bw8oh1hhykio7	\N	266.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:35:04.831	2026-07-04 03:35:05.529	100.00	200.00
cmr5ta3pi006iw8ohe6q5nocu	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97x4001flx4upjb4nzcm	cmr5ta3oy006ew8oh8830k8fn	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-04 03:37:24.295	2026-07-04 03:37:24.295	105.00	105.00
cmr5ta3ps006lw8ohi794jodb	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmq3qiahw0005lxru9rwwztl9	cmr5ta3oy006fw8oh5uzq9t79	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-04 03:37:24.304	2026-07-04 03:37:24.304	125.00	125.00
cmr5tc8m3007hw8ohkexcazq1	cmr0gdhu7005kw8g06c2lngfc	cmr5tc8lz007fw8oh9fw4ml04	cmr5tc8lq007dw8ohq06pd1ho	\N	86.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:39:03.963	2026-07-04 04:16:52.645	120.00	125.00
cmr5wdqbz00dhw83rpjphsnqe	cmr0gdhu7005kw8g06c2lngfc	cmr5wdqbm00dfw83rctnwyo5n	cmr5wdq6p00ddw83rw50pbwz8	\N	373.000	1	\N	Auto-generated bin item for checkout	2026-07-04 05:04:12.431	2026-07-05 06:10:05.924	25.00	50.00
cmr7a2ogb019mw8mp0kaj55nm	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7a2ofp019jw8mp9iqeymfz	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 04:15:17.579	2026-07-05 04:15:17.579	30.00	30.00
cmr7a3s1p01btw8mpfblj3qjb	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7a3s0v01bqw8mpv4gdpik4	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 04:16:08.893	2026-07-05 04:16:08.893	30.00	30.00
cmr5tg1qh009lw8ohyml3gshx	cmr0gdhu7005kw8g06c2lngfc	cmr5tg1p1009jw8oh597gwcy1	cmr5tg1ne009hw8ohfuwwn9r4	\N	43.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:42:01.674	2026-07-05 04:19:00.811	10.00	50.00
cmr7aagkv01jow8mpxe5bqea2	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7aagkb01jlw8mplersrp7u	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 04:21:20.623	2026-07-05 04:21:20.623	30.00	30.00
cmr7dlicn00ihw8rfn7zlnywn	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7dlibn00iew8rfjfiogflj	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 05:53:54.983	2026-07-05 05:53:54.983	30.00	30.00
cmr7au59301xrw8mpgudwbr6e	cmr0gdhu7005kw8g06c2lngfc	cmr7au59101xpw8mptn9iwfzo	cmr7au57l01xnw8mp4h6bwy62	\N	176.000	1	\N	Auto-generated bin item for checkout	2026-07-05 04:36:39.064	2026-07-05 06:30:50.509	10.00	15.00
cmr7arayq01vfw8mpfguab8r1	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7aray801vcw8mpr8lkdhpy	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 04:34:26.498	2026-07-05 04:34:26.498	30.00	30.00
cmr7du2yz00uow8rf0c3tl9pf	cmr0gdhu7005kw8g06c2lngfc	cmr0j5bj60008w8b5j5xvmnuw	cmqnq97vj0017lx4uc77sbdn6	cmr7du2yd00ulw8rflnuherqk	1.000	1	\N	Assigned from purchase approval/receive flow.	2026-07-05 06:00:34.955	2026-07-05 06:00:34.955	30.00	30.00
cmr5tjv5t00bhw8ohdozwwus0	cmr0gdhu7005kw8g06c2lngfc	cmr5tjv5r00bfw8oh82kbvol6	cmr5tjv3u00bdw8oh5bm4rax4	\N	96.000	1	\N	Auto-generated bin item for checkout	2026-07-04 03:44:59.777	2026-07-05 06:34:54.684	10.00	100.00
\.


--
-- Data for Name: inventory_bins; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.inventory_bins (id, shop_id, zone_id, rack_id, shelf_id, code, product_name, status, quantity_label, days_label, sort_order, created_at, updated_at) FROM stdin;
cmqteml3b0015lxj6fskk9scr	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-KD56O9D9	Potato Chips Family Pack	EMPTY	খালি	খালি	0	2026-06-25 11:13:58.343	2026-06-25 11:13:58.357
cmqteml4i0017lxj6zcme0n8r	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-P9YMAJ58	PRAN Litchi Drink 125ml	FULL	30 পিস	Batch 1	0	2026-06-25 11:13:58.387	2026-06-25 11:13:58.407
cmqteml78001flxj6mmjtmzzy	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-EQFKIJQ8	PRAN Litchi Drink 200ml	FULL	25 পিস	Batch 1	0	2026-06-25 11:13:58.484	2026-06-25 11:13:58.681
cmqtemldh001jlxj60ztn0b3s	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-C77SBDN6	PRAN Litchi Drink 250ml	FULL	30 পিস	Batch 1	0	2026-06-25 11:13:58.709	2026-06-25 11:13:58.729
cmqtemles001nlxj66ku4s2a8	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-EH3HH29Z	PRAN Litchi Drink 500ml	FULL	100 পিস	Batch 1	0	2026-06-25 11:13:58.756	2026-06-25 11:13:58.775
cmqtemlg0001rlxj6vx69hqos	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-EXRE8XHW	PRAN Mango Fruit Drink 125ml	FULL	60 পিস	Batch 1	0	2026-06-25 11:13:58.8	2026-06-25 11:13:58.817
cmqtemlh7001vlxj6hmml8nkc	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-SQSALRHI	PRAN Mango Fruit Drink 1L	FULL	15 পিস	Batch 1	0	2026-06-25 11:13:58.843	2026-06-25 11:13:58.86
cmqtemlie001zlxj69l7vvgc0	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-XDU3S9WS	PRAN Mango Fruit Drink 200ml	FULL	20 পিস	Batch 1	0	2026-06-25 11:13:58.886	2026-06-25 11:13:58.903
cmqteml5x001blxj60my4j0h4	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-PJB4NZCM	PRAN Litchi Drink 1L	FULL	20 পিস	Batch 1	0	2026-06-25 11:13:58.438	2026-06-30 09:00:17.238
cmqteml1n0011lxj6wj4dvfa7	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	cmqteml1f000zlxj6n5lldpz3	BASIC-9RWWZTL9	Orange Juice 1L	FULL	51 পিস	নতুন স্টক	0	2026-06-25 11:13:58.283	2026-06-30 09:02:32.458
cmr0j8t2y004hw8b5pvu3fgw9	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-EH3HH29Z		EMPTY	খালি	খালি	0	2026-06-30 10:57:36.826	2026-07-02 08:04:50.565
cmr5tc8lz007fw8oh9fw4ml04	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-Q06PD1HO	Orange Juice 1L	FULL	86 পিস	নতুন স্টক	0	2026-07-04 03:39:03.959	2026-07-04 04:16:52.651
cmr0j5bjy000dw8b5e0kpvmqu	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-KD56O9D9	Potato Chips Family Pack	FULL	144858 পিস	নতুন স্টক	0	2026-06-30 10:54:54.142	2026-07-01 06:41:00.533
cmr5t74c8001dw8oh62i01x5i	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-2K59EK9V	boook	FULL	3976 পিস	নতুন স্টক	0	2026-07-04 03:35:05.144	2026-07-04 03:35:05.429
cmr5t743d000dw8ohczzhz52o	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-1HHYKIO7	sakib	FULL	266 পিস	নতুন স্টক	0	2026-07-04 03:35:04.826	2026-07-04 03:35:05.53
cmr0j5bqv001jw8b5yqiwpt32	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-PJB4NZCM	PRAN Litchi Drink 1L	FULL	2119 পিস	নতুন স্টক	0	2026-06-30 10:54:54.392	2026-07-01 06:41:00.541
cmr0j6qv8003rw8b5ujttgncg	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-MQV6WQXB	PRAN Mango Fruit Drink 250ml	FULL	14440 পিস	নতুন স্টক	0	2026-06-30 10:56:00.645	2026-07-02 08:04:50.626
cmr0j5bpl000uw8b5dv0xwrh7	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-P9YMAJ58	PRAN Litchi Drink 125ml	FULL	2041 পিস	নতুন স্টক	0	2026-06-30 10:54:54.346	2026-07-01 06:41:00.576
cmr0j6quz003hw8b5alyj12a5	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-SQSALRHI	PRAN Mango Fruit Drink 1L	FULL	18883 পিস	নতুন স্টক	0	2026-06-30 10:56:00.635	2026-07-02 08:04:50.642
cmr0j7msv0044w8b5vfhjlpnt	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-PDFRJU1F	PRAN Mango Fruit Drink 500ml	FULL	3983 পিস	নতুন স্টক	0	2026-06-30 10:56:42.032	2026-07-04 03:35:05.269
cmr0j6qup003cw8b5r4tnpwgn	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-9RWWZTL9	Orange Juice 1L	FULL	1328 পিস	নতুন স্টক	0	2026-06-30 10:56:00.625	2026-07-02 08:04:50.652
cmr0j6qv4003mw8b5hnhdktcm	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-XDU3S9WS		EMPTY	খালি	খালি	0	2026-06-30 10:56:00.641	2026-06-30 11:05:06.445
cmr5tjv5r00bfw8oh82kbvol6	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-5BM4RAX4	7up	FULL	96 পিস	নতুন স্টক	0	2026-07-04 03:44:59.776	2026-07-05 06:34:54.701
cmr5wdqbm00dfw83rctnwyo5n	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-W50PBWZ8	কিটক্যাট	FULL	373 পিস	নতুন স্টক	0	2026-07-04 05:04:12.418	2026-07-05 06:10:05.934
cmr5t74ek001ww8oh2celxi4t	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-76GHA1F1	add ponno	FULL	1968 পিস	নতুন স্টক	0	2026-07-04 03:35:05.228	2026-07-04 10:16:49.747
cmr69bqe50057w8l3ernaqv1i	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-TMRL2WL3	sajib bbbb	FULL	2994 পিস	নতুন স্টক	0	2026-07-04 11:06:34.206	2026-07-04 11:06:34.221
cmr5tg1p1009jw8oh597gwcy1	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-FUWWN9R4	chips	FULL	43 পিস	নতুন স্টক	0	2026-07-04 03:42:01.621	2026-07-05 04:19:00.815
cmr0j5bj60008w8b5j5xvmnuw	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-C77SBDN6	PRAN Litchi Drink 250ml	FULL	1264 পিস	নতুন স্টক	0	2026-06-30 10:54:54.115	2026-07-05 06:00:34.959
cmr7au59101xpw8mptn9iwfzo	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-4H6BWY62	Brazil	FULL	176 পিস	নতুন স্টক	0	2026-07-05 04:36:39.061	2026-07-05 06:30:50.543
cmr7ahti501piw8mpjm0xe6rn	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	cmr0hdgvg0081w8g0yexe4fdl	BASIC-81W4L2I8	chocolate	FULL	97 পিস	নতুন স্টক	0	2026-07-05 04:27:03.965	2026-07-05 05:45:54.845
\.


--
-- Data for Name: inventory_racks; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.inventory_racks (id, shop_id, zone_id, name, note, shelf_count, total_bins, used_bins, sort_order, created_at, updated_at) FROM stdin;
cmqteml0z000xlxj68mefx727	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	Main Rack	Auto-created for basic inventory stock	1	1	0	0	2026-06-25 11:13:58.259	2026-06-25 11:13:58.259
cmr0hd4x8007zw8g0fjxu8yeq	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	9	\N	1	0	0	0	2026-06-30 10:04:59.564	2026-06-30 10:05:15.057
\.


--
-- Data for Name: inventory_shelves; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.inventory_shelves (id, shop_id, zone_id, rack_id, name, total_bins, used_bins, sort_order, created_at, updated_at) FROM stdin;
cmqteml1f000zlxj6n5lldpz3	cmqtek0us0002lxj6zzrnqalp	cmqteml0f000vlxj6ro024kl9	cmqteml0z000xlxj68mefx727	Main Shelf	1	0	0	2026-06-25 11:13:58.275	2026-06-25 11:13:58.275
cmr0hdgvg0081w8g0yexe4fdl	cmr0gdhu7005kw8g06c2lngfc	cmr0hcpyx007xw8g05omsul1i	cmr0hd4x8007zw8g0fjxu8yeq	000:::উপরের সারি	0	0	0	2026-06-30 10:05:15.051	2026-06-30 10:05:15.051
\.


--
-- Data for Name: inventory_zones; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.inventory_zones (id, shop_id, name, subtitle, icon, sort_order, created_at, updated_at) FROM stdin;
cmqteml0f000vlxj6ro024kl9	cmqtek0us0002lxj6zzrnqalp	Main Store	Basic inventory stock area	store	0	2026-06-25 11:13:58.239	2026-06-25 11:13:58.239
cmr0hcpyx007xw8g05omsul1i	cmr0gdhu7005kw8g06c2lngfc	ss1	ss1 সম্পর্কিত র্যাক, শেলফ ও বিন ব্যবস্থাপনা	map	0	2026-06-30 10:04:40.183	2026-06-30 10:04:40.183
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.invoices (id, subscription_id, shop_id, billing_date, billable_accounts, rate_per_account, total_amount, paid_amount, status, created_at) FROM stdin;
cmqxac4jt0001lxf35rs9gkjp	cmqtek0wh0006lxj66clvebk0	cmqtek0us0002lxj6zzrnqalp	2026-06-27 18:00:00	1	10.00	10.00	10.00	PAID	2026-06-28 04:24:56.586
cmqvxdn3u0001lxww2q4t828a	cmqtek0wh0006lxj66clvebk0	cmqtek0us0002lxj6zzrnqalp	2026-06-26 18:00:00	1	10.00	10.00	10.00	PAID	2026-06-27 05:34:26.106
cmr0ew5s60001w8g0ycxuryf2	cmqtek0wh0006lxj66clvebk0	cmqtek0us0002lxj6zzrnqalp	2026-06-29 18:00:00	1	10.00	10.00	10.00	PAID	2026-06-30 08:55:48.293
cmr1u3dpk000dw8kn4w5it9jp	cmr0gdhv8005ow8g00ve5r4j5	cmr0gdhu7005kw8g06c2lngfc	2026-06-30 18:00:00	1	10.00	10.00	10.00	PAID	2026-07-01 08:49:05.573
cmr5t2dql0001w897swt9687r	cmr0gdhv8005ow8g00ve5r4j5	cmr0gdhu7005kw8g06c2lngfc	2026-07-03 18:00:00	1	10.00	10.00	10.00	PAID	2026-07-04 03:31:24.045
cmr385hku0001w896v7i5gwxo	cmqtek0wh0006lxj66clvebk0	cmqtek0us0002lxj6zzrnqalp	2026-07-01 18:00:00	1	10.00	10.00	0.00	UNPAID	2026-07-02 08:10:24.702
cmr780qef006fw8mp40hwg945	cmr0gdhv8005ow8g00ve5r4j5	cmr0gdhu7005kw8g06c2lngfc	2026-07-04 18:00:00	1	10.00	10.00	10.00	PAID	2026-07-05 03:17:47.558
cmr2xy7mq0001w8zb8rjdo9gt	cmr0gdhv8005ow8g00ve5r4j5	cmr0gdhu7005kw8g06c2lngfc	2026-07-01 18:00:00	1	10.00	10.00	10.00	PAID	2026-07-02 03:24:49.058
\.


--
-- Data for Name: master_product_barcodes; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.master_product_barcodes (id, master_product_id, barcode, pack_size, status, created_by, updated_by, created_at, updated_at) FROM stdin;
cmqnc6u1s000vlxvs783f8ttv	cmqnc6u0x000plxvskd56o9d9	8901234567002	12 pcs	MAPPED	cmq3dt6o00004lxopt6mh88b2	cmq3dt6o00004lxopt6mh88b2	2026-06-21 05:19:07.169	2026-06-21 05:19:07.169
cmqnc6u20000xlxvsl4v9tnqk	cmqnc6u15000rlxvs6653gawf	8901234567003	25 KG	MAPPED	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.176	2026-06-21 05:19:07.176
cmqnq97jn000hlx4ur99ivu84	cmqnq97j1000flx4uexre8xhw	8940000000001	125ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.595	2026-06-21 11:52:52.595
cmqnq97lu000llx4uhlholjde	cmqnq97kz000jlx4uxdu3s9ws	8940000000002	200ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.674	2026-06-21 11:52:52.674
cmqnq97o2000plx4u5u4771lx	cmqnq97n4000nlx4umqv6wqxb	8940000000003	250ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.754	2026-06-21 11:52:52.754
cmqnq97q1000tlx4uiv1dhukt	cmqnq97p4000rlx4updfrju1f	8940000000004	500ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.825	2026-06-21 11:52:52.825
cmqnq97s1000xlx4uolf7xlok	cmqnq97r6000vlx4usqsalrhi	8940000000005	1L	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.897	2026-06-21 11:52:52.897
cmqnq97u00011lx4u3qfjyoke	cmqnq97tc000zlx4up9ymaj58	8940000000006	125ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.968	2026-06-21 11:52:52.968
cmqnq97v00015lx4u6qcii9aw	cmqnq97ut0013lx4ueqfkijq8	8940000000007	200ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.005	2026-06-21 11:52:53.005
cmqnq97vr0019lx4uv8x34c7h	cmqnq97vj0017lx4uc77sbdn6	8940000000008	250ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.032	2026-06-21 11:52:53.032
cmqnq97wm001dlx4ul2miqf44	cmqnq97wg001blx4ueh3hh29z	8940000000009	500ml	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.063	2026-06-21 11:52:53.063
cmqnq97xc001hlx4u81yhjlok	cmqnq97x4001flx4upjb4nzcm	8940000000010	1L	MAPPED	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.089	2026-06-21 11:52:53.089
\.


--
-- Data for Name: master_product_requests; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.master_product_requests (id, shop_id, shop_product_id, created_by_user_id, reviewed_by_user_id, master_product_id, name, category, brand, unit, barcode, "pictureUrl", purchase_price, sale_price, opening_stock, low_stock_limit, status, rejection_reason, created_at, updated_at) FROM stdin;
cmr3037gb00dkw82pjqjkrtbx	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	test	পানীয়	local	পিস	000555	ছবি যোগ করা হয়নি	20.00	40.00	5000.000	5.000	PENDING	\N	2026-07-02 04:24:41.339	2026-07-02 04:24:41.357
cmr38l66a006lw896pnhxpsll	cmr0gdhu7005kw8g06c2lngfc	cmr38l6e0006nw896x2su8dy7	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	sajib bbbb	পানীয়	local	পিস	000222	\N	50.00	100.00	3000.000	5.000	PENDING	\N	2026-07-02 08:22:36.418	2026-07-02 08:22:36.701
cmr38u2xq00b1w896xnfryn6k	cmr0gdhu7005kw8g06c2lngfc	cmr38u30s00b3w896hn7pa13i	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	fahad	তেল-মসলা	local	কেজি	111111	\N	150.00	200.00	10.000	5.000	PENDING	\N	2026-07-02 08:29:32.126	2026-07-02 08:29:32.255
cmr392npw00cyw896k6i0vcn1	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	add ponno	চাল-ডাল	local	কেজি	111222	\N	150.00	200.00	2000.000	5.000	PENDING	\N	2026-07-02 08:36:12.309	2026-07-02 08:36:12.402
cmr3a9zbb00how896r72c8kor	cmr0gdhu7005kw8g06c2lngfc	cmr3a9zbe00hqw896zn9cids4	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	sakib	বিস্কুট	deshit	কেজি	1112222	\N	100.00	200.00	300.000	5.000	PENDING	\N	2026-07-02 09:09:53.543	2026-07-02 09:09:53.551
cmr3bbwdv003lw8ufnhb6xmgw	cmr0gdhu7005kw8g06c2lngfc	cmr3bbwe0003nw8uf9s6eckxu	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	boook	তেল-মসলা	local	পিস	111223	\N	100.00	200.00	4000.000	5.000	PENDING	\N	2026-07-02 09:39:22.675	2026-07-02 09:39:22.683
cmr5tbl5f0075w8ohpbg627uz	cmr0gdhu7005kw8g06c2lngfc	cmr5tbl5k0077w8ohq5rhclte	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	Orange Juice 1L	চাল-ডাল	PRAN	পিস	123321	\N	120.00	125.00	120.000	5.000	PENDING	\N	2026-07-04 03:38:33.556	2026-07-04 03:38:33.597
cmr5tfftz0099w8ohgjnvvmez	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	chips	বিস্কুট	PRAN	প্যাকেট	23423412	\N	10.00	50.00	200.000	5.000	PENDING	\N	2026-07-04 03:41:33.287	2026-07-04 03:41:33.295
cmr5tj0fd00b5w8ohkb2cskre	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	7up	পানীয়	7piece	পিস	123423432	\N	10.00	100.00	200.000	5.000	PENDING	\N	2026-07-04 03:44:19.946	2026-07-04 03:44:19.956
cmr5v7tnc008tw83rnxjd22kf	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	কিটক্যাট	বিস্কুট	deshit	প্যাকেট	4562456345	\N	25.00	50.00	400.000	5.000	PENDING	\N	2026-07-04 04:31:37.175	2026-07-04 04:31:37.21
cmr7adrcf01low8mp306gsly2	cmr0gdhu7005kw8g06c2lngfc	cmr7adrd801lqw8mp9ibm33op	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	chocolate	বিস্কুট	deshit	প্যাকেট	5342452	\N	50.00	100.00	100.000	5.000	PENDING	\N	2026-07-05 04:23:54.543	2026-07-05 04:23:54.579
cmr7at3an01wjw8mpvm0h04pj	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	Brazil	পানীয়	deshit	কেজি	12345432	\N	10.00	15.00	200.000	5.000	PENDING	\N	2026-07-05 04:35:49.871	2026-07-05 04:35:49.9
\.


--
-- Data for Name: master_products; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.master_products (id, sku, name, description, category_id, status, created_by, updated_by, created_at, updated_at, brand_id, package_size, picture_url, price, suggested_price, unit_id) FROM stdin;
cmq3qiahw0005lxru9rwwztl9	PRD-0001	Orange Juice 1L	Natural fruit drink for demo catalog data.	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-07 12:04:32.804	2026-06-21 05:19:07.124	cmqnc6tyr000flxvs82yi8mp2	1 L	http://localhost:4000/uploads/products/1780833872800-ccd8054d-0f4a-40bd-b677-b80bac788e9c.jpg	125.00	130.00	cmq3mu2in0002lxhm5wvta8ea
cmqnc6u0x000plxvskd56o9d9	PRD-0002	Potato Chips Family Pack	Demo snack product linked with the Snacks category.	cmq3f0jg8000blxtc6q6jlylb	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6o00004lxopt6mh88b2	2026-06-21 05:19:07.136	2026-06-21 05:19:07.136	cmqnc6tyz000hlxvsvyc2jrr9	12 pcs	\N	120.00	125.00	cmq3mskwq0000lxhmbmn95vjf
cmqnc6u15000rlxvs6653gawf	PRD-0003	Festival Gift Box	Demo archived-style catalog item for seasonal workflows.	cmqnc6tyl000dlxvs0zgdi5po	INACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.145	2026-06-21 05:19:07.145	cmqnc6tz5000jlxvs02kaifnp	25 KG	\N	1950.00	2050.00	cmq3mtdpk0001lxhmop3doo2e
cmqnq97j1000flx4uexre8xhw	PRN-00001	PRAN Mango Fruit Drink 125ml	Mango Fruit Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.573	2026-06-21 11:52:52.573	cmqnc6tyr000flxvs82yi8mp2	125ml	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTAYBvOcJnSbpwTRB-hZ7vJVtRcuDHhOHViGg&s	15.00	15.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97kz000jlx4uxdu3s9ws	PRN-00002	PRAN Mango Fruit Drink 200ml	Mango Fruit Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.643	2026-06-21 11:52:52.643	cmqnc6tyr000flxvs82yi8mp2	200ml	https://www.pranfoods.net/storage/products/26a39164-2d97-45b5-9926-a6eb070c63d3.png	20.00	20.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97n4000nlx4umqv6wqxb	PRN-00003	PRAN Mango Fruit Drink 250ml	Mango Fruit Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.72	2026-06-21 11:52:52.72	cmqnc6tyr000flxvs82yi8mp2	250ml	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTAYBvOcJnSbpwTRB-hZ7vJVtRcuDHhOHViGg&s	30.00	30.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97p4000rlx4updfrju1f	PRN-00004	PRAN Mango Fruit Drink 500ml	Mango Fruit Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.792	2026-06-21 11:52:52.792	cmqnc6tyr000flxvs82yi8mp2	500ml	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmyBIuJFOjLY-dldjqToLP1FF0JhZk6l2MUw&s	55.00	60.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97r6000vlx4usqsalrhi	PRN-00005	PRAN Mango Fruit Drink 1L	Mango Fruit Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.865	2026-06-21 11:52:52.865	cmqnc6tyr000flxvs82yi8mp2	1L	https://www.jamoona.com/cdn/shop/files/Pran-1l-Mango-Fruchtsaft-9017295.png?v=1753217711	105.00	115.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97tc000zlx4up9ymaj58	PRN-00006	PRAN Litchi Drink 125ml	Litchi Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.944	2026-06-21 11:52:52.944	cmqnc6tyr000flxvs82yi8mp2	125ml	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6T_zXPxIVJRANSV3tmDn2qDcBaWJ1dmj25Q&s	15.00	15.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97ut0013lx4ueqfkijq8	PRN-00007	PRAN Litchi Drink 200ml	Litchi Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:52.997	2026-06-21 11:52:52.997	cmqnc6tyr000flxvs82yi8mp2	200ml	https://www.pranfoods.net/storage/products/31ca535d-9b89-4f3a-8cd3-66cfab41db66.png	20.00	20.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97vj0017lx4uc77sbdn6	PRN-00008	PRAN Litchi Drink 250ml	Litchi Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.024	2026-06-21 11:52:53.024	cmqnc6tyr000flxvs82yi8mp2	250ml	https://www.pranfoods.net/storage/products/31ca535d-9b89-4f3a-8cd3-66cfab41db66.png	30.00	30.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97wg001blx4ueh3hh29z	PRN-00009	PRAN Litchi Drink 500ml	Litchi Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.056	2026-06-21 11:52:53.056	cmqnc6tyr000flxvs82yi8mp2	500ml	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQK7Uie8peE2pYV02zIHzaVJY0-sgPki7WFdA&s	55.00	60.00	cmq3mskwq0000lxhmbmn95vjf
cmqnq97x4001flx4upjb4nzcm	PRN-00010	PRAN Litchi Drink 1L	Litchi Drink ready to drink pack	cmq3f0jfy0009lxtchm4pq94r	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 11:52:53.08	2026-06-21 11:52:53.08	cmqnc6tyr000flxvs82yi8mp2	1L	https://www.mabrouksons.com/cdn/shop/files/BFD14235-8673-4815-ABC4-BFCBD7838FB2_300x.jpg?v=1686282046	105.00	115.00	cmq3mskwq0000lxhmbmn95vjf
cmr31oafe001tw8fube0vfpyq	LOCAL-cmr3037gn00dmw82p9tbvxa4v	test	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:09:04.586	2026-07-02 05:09:04.586	\N	\N	\N	40.00	40.00	\N
cmr38lhjj006tw896tmrl2wl3	LOCAL-cmr38l6e0006nw896x2su8dy7	sajib bbbb	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:22:51.151	2026-07-02 08:22:51.151	\N	\N	\N	100.00	100.00	\N
cmr38uqzi00bdw896uur2erb3	LOCAL-cmr38u30s00b3w896hn7pa13i	fahad	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:30:03.294	2026-07-02 08:30:03.294	\N	\N	\N	200.00	200.00	\N
cmr394f0b00dgw89676gha1f1	LOCAL-cmr392nse00d0w896nuguvfvg	add ponno	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:37:34.331	2026-07-02 08:37:34.331	\N	\N	\N	200.00	200.00	\N
cmr5t7422000bw8oh1hhykio7	LOCAL-cmr3a9zbe00hqw896zn9cids4	sakib	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:04.778	2026-07-04 03:35:04.778	\N	\N	\N	200.00	200.00	\N
cmr5t74c3001bw8oh2k59ek9v	LOCAL-cmr3bbwe0003nw8uf9s6eckxu	boook	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.139	2026-07-04 03:35:05.139	\N	\N	\N	200.00	200.00	\N
cmr5tc8lq007dw8ohq06pd1ho	LOCAL-cmr5tbl5k0077w8ohq5rhclte	Orange Juice 1L	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:39:03.951	2026-07-04 03:39:03.951	\N	\N	\N	125.00	125.00	\N
cmr5tg1ne009hw8ohfuwwn9r4	LOCAL-cmr5tffu4009bw8ohwvaqnaho	chips	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:42:01.562	2026-07-04 03:42:01.562	\N	\N	\N	50.00	50.00	\N
cmr5tjv3u00bdw8oh5bm4rax4	LOCAL-cmr5tj0fk00b7w8oh5ew29ywn	7up	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:44:59.706	2026-07-04 03:44:59.706	\N	\N	\N	100.00	100.00	\N
cmr5wdq6p00ddw83rw50pbwz8	LOCAL-cmr5v7to0008vw83racyeu238	কিটক্যাট	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 05:04:12.24	2026-07-04 05:04:12.24	\N	\N	\N	50.00	50.00	\N
cmr7ahth001pgw8mp81w4l2i8	LOCAL-cmr7adrd801lqw8mp9ibm33op	chocolate	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:27:03.922	2026-07-05 04:27:03.922	\N	\N	\N	100.00	100.00	\N
cmr7au57l01xnw8mp4h6bwy62	LOCAL-cmr7at3bc01wlw8mpe3gw17s5	Brazil	\N	\N	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:36:39.007	2026-07-05 04:36:39.007	\N	\N	\N	15.00	15.00	\N
\.


--
-- Data for Name: money_boxes; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.money_boxes (id, shop_id, box_name, code, type, opening_balance, current_balance, details, status, created_at, updated_at) FROM stdin;
cmr0j5bhv0003w8b5mjezmu9i	cmr0gdhu7005kw8g06c2lngfc	Cash Box	cash-cmr0gdhu-1782816894067	CASH	0.00	-389904.00	\N	ACTIVE	2026-06-30 10:54:54.068	2026-07-05 06:34:54.83
cmr2z1235001ew8hocgj716rm	cmr0gdhu7005kw8g06c2lngfc	bKash Wallet	bkash-cmr0gdhu-1782964501456	BKASH	0.00	920.00	\N	ACTIVE	2026-07-02 03:55:01.457	2026-07-02 05:22:11.381
\.


--
-- Data for Name: notification_settings; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.notification_settings (id, shop_id, low_stock, bin_low_stock, new_sale, due_reminder, new_customer, expiry_alert, daily_report, weekly_report, quiet_hours, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: otp_verifications; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.otp_verifications (id, user_id, shop_id, app_type, purpose, channel, recipient, country_code, code_hash, attempts, max_attempts, sent_at, expires_at, verified_at, consumed_at, status, request_ip, created_at) FROM stdin;
cmqtek12i0007lxj6z63nw6xe	\N	\N	MOBILE	REGISTRATION	SMS	1880561928	\N	931d2d38860931328dabaf84e10d271d4f804783af43ecd645012db21f10b251	1	5	2026-06-25 11:11:59.082	2026-06-25 11:13:59.08	2026-06-25 11:12:05.045	2026-06-25 11:12:05.045	VERIFIED	\N	2026-06-25 11:11:59.082
cmr0gdhxp005pw8g06e30dd8f	\N	\N	MOBILE	REGISTRATION	SMS	1762161370	\N	9a2d94742295a879f4da56d22e59f2b5edd3efad1ddb6ba3ae603eb8bd4d40df	3	5	2026-06-30 09:37:16.814	2026-06-30 09:39:16.813	2026-06-30 09:38:59.656	2026-06-30 09:38:59.656	VERIFIED	\N	2026-06-30 09:37:16.814
\.


--
-- Data for Name: owner_registration_drafts; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.owner_registration_drafts (id, name, mobile, email, password_hash, shop_id, shop_name, shop_address, shop_category, shop_location_label, latitude, longitude, otp_verification_id, pin_hash, otp_verified_at, pin_set_at, completed_at, status, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: password_reset_requests; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.password_reset_requests (id, user_id, shop_id, app_type, otp_verification_id, requested_for, status, expires_at, completed_at, created_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.payments (id, invoice_id, shop_id, amount, method, trx_id, status, paid_at, created_at) FROM stdin;
cmqvxfzxk000vlxwwd624f63k	cmqvxdn3u0001lxww2q4t828a	cmqtek0us0002lxj6zzrnqalp	10.00	bkash	tnx-12345678	SUCCESS	2026-06-27 05:36:16.038	2026-06-27 05:36:16.04
cmqxadk21000dlxf3geqzw2h2	cmqxac4jt0001lxf35rs9gkjp	cmqtek0us0002lxj6zzrnqalp	10.00	bkash	tnx-12345678	SUCCESS	2026-06-28 04:26:03.335	2026-06-28 04:26:03.337
cmr0exdgs000dw8g0uuqxn1xc	cmr0ew5s60001w8g0ycxuryf2	cmqtek0us0002lxj6zzrnqalp	10.00	bkash	tnx-12345678	SUCCESS	2026-06-30 08:56:44.908	2026-06-30 08:56:44.908
cmr1u3dpz000hw8kncgxirs4c	cmr1u3dpk000dw8kn4w5it9jp	cmr0gdhu7005kw8g06c2lngfc	10.00	bkash	erwrtwrtwwe	SUCCESS	2026-07-01 08:49:05.591	2026-07-01 08:49:05.592
cmr2y3t3j001dw8zb5d46s1da	cmr2xy7mq0001w8zb8rjdo9gt	cmr0gdhu7005kw8g06c2lngfc	10.00	bkash	aseqwe	SUCCESS	2026-07-02 03:29:10.159	2026-07-02 03:29:10.16
cmr5t3xpy001dw8970qfs4nye	cmr5t2dql0001w897swt9687r	cmr0gdhu7005kw8g06c2lngfc	10.00	bkash	asddsas	SUCCESS	2026-07-04 03:32:36.598	2026-07-04 03:32:36.598
cmr78it270075w8mpel0oum18	cmr780qef006fw8mp40hwg945	cmr0gdhu7005kw8g06c2lngfc	10.00	bkash	1ad2134ewrqw	SUCCESS	2026-07-05 03:31:50.815	2026-07-05 03:31:50.816
\.


--
-- Data for Name: platform_users; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.platform_users (id, user_id, role, created_at, updated_at) FROM stdin;
cmq3dt6nf0002lxoppcjjc9b3	cmq3dt6mv0000lxophsbhevt3	SUPER_ADMIN	2026-06-07 06:09:06.027	2026-06-21 05:19:06.949
cmq3dt6o90006lxopozpypbnl	cmq3dt6o00004lxopt6mh88b2	ADMIN	2026-06-07 06:09:06.057	2026-06-21 05:19:06.964
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.product_categories (id, name, description, status, created_by, updated_by, created_at, updated_at, is_approved, is_global, shop_id) FROM stdin;
cmq3f0jgf000dlxtc0wlct08q	Seasonal Item	Special campaigns, festive bundles, and time-based items.	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-07 06:42:48.831	2026-06-07 08:33:38.132	t	t	\N
cmq3j23sa0007lx48z2wnfj3i	Dairy Products	Milk, yogurt, butter, cheese, and dairy-based products.	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-07 08:36:00.298	2026-06-07 08:36:00.298	t	t	\N
cmq3j2x4p000blx48l7pfmoe5	Cooking Essentials	Edible oils, salt, sugar, spices, and seasonings.	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-07 08:36:38.329	2026-06-07 10:24:38.446	t	t	\N
cmq3f0jfy0009lxtchm4pq94r	Beverages	Soft drinks, juices, energy drinks, and bottled water.	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-07 06:42:48.814	2026-06-21 05:19:07.04	t	t	\N
cmq3f0jg8000blxtc6q6jlylb	Snacks	Biscuits, chips, noodles, and packaged snack items.	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6o00004lxopt6mh88b2	2026-06-07 06:42:48.824	2026-06-21 05:19:07.048	t	t	\N
cmqnh13hx0003lxbxx5wpq274	Staples & Grains	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13hy0007lxbx9tyxtxyk	Oil & Ghee	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13hz000blxbxuqyi91yd	Spices	মেইন ক্যাটেগরি — 9টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i1000flxbxmqgn8uuj	Sugar & Sweet	মেইন ক্যাটেগরি — 8টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i2000jlxbxm9mrupwh	Salt	মেইন ক্যাটেগরি — 6টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i3000nlxbxeh5zgns0	Eggs	মেইন ক্যাটেগরি — 4টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i4000rlxbxqkdzfohs	Tea & Coffee	মেইন ক্যাটেগরি — 10টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i5000vlxbxyybz27gm	Biscuit & Cake	মেইন ক্যাটেগরি — 13টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i6000zlxbx9660iufk	Chips & Snacks	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i70013lxbxokxu2hwu	Noodles & Pasta	মেইন ক্যাটেগরি — 8টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13i90017lxbx0eabkxor	Sauce & Ketchup	মেইন ক্যাটেগরি — 10টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ia001blxbx3h5w0hie	Pickle & Chutney	মেইন ক্যাটেগরি — 10টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ic001flxbxl1m7gpe5	Canned Food	মেইন ক্যাটেগরি — 8টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13id001jlxbxebgwddcz	Frozen Food	মেইন ক্যাটেগরি — 11টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13if001nlxbxe8x6gngi	Ice Cream	মেইন ক্যাটেগরি — 8টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ig001rlxbxju12jwbj	Dry Fruits & Nuts	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ih001vlxbxjliadch5	Soap	মেইন ক্যাটেগরি — 7টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ij001zlxbx11xh1k73	Detergent & Cleaner	মেইন ক্যাটেগরি — 11টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ik0023lxbxpp0gaena	Hair Care	মেইন ক্যাটেগরি — 10টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13il0027lxbx1sij95oo	Skincare	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13in002blxbxd0peefyl	Cosmetics & Makeup	মেইন ক্যাটেগরি — 11টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13io002flxbxb6md2erd	Oral Care	মেইন ক্যাটেগরি — 6টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ip002jlxbxmu2u1mjv	Sanitary & Hygiene	মেইন ক্যাটেগরি — 9টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13ir002nlxbxcpnhq0mn	Men's Grooming	মেইন ক্যাটেগরি — 9টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13is002rlxbxgt9cogx6	Women's Grooming	মেইন ক্যাটেগরি — 5টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13iu002vlxbxwyz06oq7	Baby Products	মেইন ক্যাটেগরি — 15টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13iv002zlxbxeb5yi7xl	Health & First Aid	মেইন ক্যাটেগরি — 16টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13iw0033lxbxvddjv2xl	Stationery	মেইন ক্যাটেগরি — 16টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13iy0037lxbxi4yhxbe6	Battery & Electric	মেইন ক্যাটেগরি — 17টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13iz003blxbxs27j2fhi	Plastic & Household	মেইন ক্যাটেগরি — 23টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13j0003flxbx327ikuig	Kitchen Tools	মেইন ক্যাটেগরি — 6টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13j1003jlxbx6dd1lsn1	Pan & Tobacco	মেইন ক্যাটেগরি — 11টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13j2003nlxbx5iin2xqr	Vegetables (Dry/Packaged)	মেইন ক্যাটেগরি — 9টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnh13j3003rlxbx8mtyrwjm	Organic & Special Diet	মেইন ক্যাটেগরি — 12টি সাব-ক্যাটেগরি	ACTIVE	cmq3dt6mv0000lxophsbhevt3	cmq3dt6mv0000lxophsbhevt3	2026-06-21 07:34:37.556	2026-06-21 07:34:37.556	t	t	\N
cmqnc6tyl000dlxvs0zgdi5po	Seasonal Items	Special campaigns, festive bundles, and time-based items.	ACTIVE	cmq3dt6o00004lxopt6mh88b2	cmq3dt6mv0000lxophsbhevt3	2026-06-21 05:19:07.054	2026-06-21 07:37:46.773	t	t	\N
cmr693jb2001xw8l3cqbj9ka3	sakib	sdfasfdsfaf	ACTIVE	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:00:11.775	2026-07-04 11:00:11.775	f	f	cmr0gdhu7005kw8g06c2lngfc
\.


--
-- Data for Name: product_template_items; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.product_template_items (id, template_id, master_product_id) FROM stdin;
cmq4srn3a0001lxhcwsh0s7hv	cmq4snira0000lxhcv8wx6he8	cmq3qiahw0005lxru9rwwztl9
\.


--
-- Data for Name: product_templates; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.product_templates (id, code, name, description, status, created_at, updated_at) FROM stdin;
cmq4snira0000lxhcv8wx6he8	TMP-GROCERY-001	Basic Grocery Starter Pack	Starter pack containing essential grocery products for new retail shops.	ACTIVE	2026-06-08 05:52:22.198	2026-06-08 05:52:22.198
\.


--
-- Data for Name: purchase_items; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.purchase_items (id, purchase_id, master_product_id, quantity, purchase_price, total_amount, batch_no, expiry_date) FROM stdin;
cmr0f4tlv004kw8g048u2de9j	cmr0f4037004aw8g06jezalcn	cmq3qiahw0005lxru9rwwztl9	1.000	126.00	126.00	2	\N
cmr0j5bi70005w8b5ospw5i5b	cmr0h6wzr007sw8g0tbj8zx72	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr0j5bi70006w8b5p3xeky37	cmr0h6wzr007sw8g0tbj8zx72	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	\N
cmr0j5bp7000ow8b5yquyrzm1	cmr0hl6u10089w8g0eawjuc78	cmqnc6u0x000plxvskd56o9d9	11.000	120.00	1320.00	1	\N
cmr0j5bp7000pw8b5jsbkk54n	cmr0hl6u10089w8g0eawjuc78	cmqnq97tc000zlx4up9ymaj58	11.000	15.00	165.00	1	\N
cmr0j5bqc0015w8b50mcczq7j	cmr0i27er008pw8g0shrocgbl	cmqnq97vj0017lx4uc77sbdn6	2.000	30.00	60.00	1	\N
cmr0j5bqc0016w8b5y6ezqewd	cmr0i27er008pw8g0shrocgbl	cmqnc6u0x000plxvskd56o9d9	6.000	120.00	720.00	1	\N
cmr0j5bqc0017w8b5wl2st6n5	cmr0i27er008pw8g0shrocgbl	cmqnq97tc000zlx4up9ymaj58	700.000	15.00	10500.00	1	\N
cmr0j5bqc0018w8b5a50yul0b	cmr0i27er008pw8g0shrocgbl	cmqnq97x4001flx4upjb4nzcm	900.000	105.00	94500.00	1	\N
cmr0j5brl001uw8b5e34qkh5d	cmr0ic37l0096w8g0aojmgem0	cmqnc6u0x000plxvskd56o9d9	400.000	120.00	48000.00	1	\N
cmr0j5brl001vw8b5jkofd620	cmr0ic37l0096w8g0aojmgem0	cmqnq97vj0017lx4uc77sbdn6	900.000	30.00	27000.00	1	\N
cmr0j6qts002rw8b5h98araqi	cmr0j6qts002pw8b5qtn78wqp	cmqnq97vj0017lx4uc77sbdn6	155.000	30.00	4650.00	\N	\N
cmr0j6qts002sw8b5aqfr5enf	cmr0j6qts002pw8b5qtn78wqp	cmqnc6u0x000plxvskd56o9d9	144444.000	120.00	17333280.00	\N	\N
cmr0j6qts002tw8b5rhj2zss5	cmr0j6qts002pw8b5qtn78wqp	cmqnq97tc000zlx4up9ymaj58	1333.000	15.00	19995.00	\N	\N
cmr0j6qts002uw8b57ito6hpz	cmr0j6qts002pw8b5qtn78wqp	cmqnq97x4001flx4upjb4nzcm	1222.000	105.00	128310.00	\N	\N
cmr0j6qts002vw8b5zjgfgpqc	cmr0j6qts002pw8b5qtn78wqp	cmq3qiahw0005lxru9rwwztl9	1333.000	125.00	166625.00	\N	\N
cmr0j6qts002ww8b5qh9mg8dz	cmr0j6qts002pw8b5qtn78wqp	cmqnq97r6000vlx4usqsalrhi	18888.000	105.00	1983240.00	\N	\N
cmr0j6qts002xw8b51qq9u0nf	cmr0j6qts002pw8b5qtn78wqp	cmqnq97kz000jlx4uxdu3s9ws	1.000	20.00	20.00	\N	\N
cmr0j6qts002yw8b5187yl7dq	cmr0j6qts002pw8b5qtn78wqp	cmqnq97n4000nlx4umqv6wqxb	14444.000	30.00	433320.00	\N	\N
cmr0j7msc0042w8b5mkryfpzq	cmr0j7msc0040w8b513bzlq5a	cmqnq97p4000rlx4updfrju1f	4000.000	55.00	220000.00	\N	\N
cmr0j8t2r004fw8b5djd2i3g7	cmr0j8t2r004dw8b5coiu617y	cmqnq97wg001blx4ueh3hh29z	14.000	55.00	770.00	\N	\N
cmr0jdqe90007w8s32brdeq06	cmr0jdhky0003w8s36i2kybhl	cmqnq97n4000nlx4umqv6wqxb	30.000	30.00	900.00	1	\N
cmr0jg0lv000ow8s3vbntwydp	cmr0jfpcu000kw8s3ksa9ty62	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr1l09mt0019w8jo3wfds6v3	cmr1kzx3o0012w8joeetozhlr	cmqnq97tc000zlx4up9ymaj58	5.000	15.00	75.00	1	\N
cmr1l09mt001aw8jotv507yuz	cmr1kzx3o0012w8joeetozhlr	cmqnq97x4001flx4upjb4nzcm	6.000	105.00	630.00	1	\N
cmr1l09mt001bw8jo0zw18thc	cmr1kzx3o0012w8joeetozhlr	cmq3qiahw0005lxru9rwwztl9	5.000	125.00	625.00	1	\N
cmr1l09mt001cw8joritk4ary	cmr1kzx3o0012w8joeetozhlr	cmqnq97r6000vlx4usqsalrhi	8.000	105.00	840.00	1	\N
cmr2ye0py0041w8zbq9dp6p0h	cmr2ydudi003nw8zbiqw0bnz2	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	1	\N
cmr2ye0py0042w8zbsjgk5csj	cmr2ydudi003nw8zbiqw0bnz2	cmqnq97kz000jlx4uxdu3s9ws	1.000	20.00	20.00	1	\N
cmr2ye0py0043w8zbls3j7qhc	cmr2ydudi003nw8zbiqw0bnz2	cmqnq97ut0013lx4ueqfkijq8	1.000	20.00	20.00	1	\N
cmr2ylv9n006ew8zb6k1kvo8i	cmr2ylpey0062w8zb04m8whed	cmqnq97tc000zlx4up9ymaj58	2.000	15.00	30.00	1	\N
cmr2ynt6n007sw8zbw8wwbqkn	cmr2ynen6007fw8zbiiw747h1	cmqnq97kz000jlx4uxdu3s9ws	1.000	20.00	20.00	1	\N
cmr2ynt6n007tw8zbw35h26ik	cmr2ynen6007fw8zbiiw747h1	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	1	\N
cmr2yuiw3009xw8zbox23j7sk	cmr2ytmrc009lw8zbvo7etzp3	cmqnq97kz000jlx4uxdu3s9ws	7.000	20.00	140.00	1	\N
cmr2z1238001gw8horjhpnzkb	cmr2z0rqj0011w8hobwhi38oy	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr2z1238001hw8hoaeraaf63	cmr2z0rqj0011w8hobwhi38oy	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr2z8dpp001bw82p5qhw1rd0	cmr2yvlri00aqw8zbn14lkdp3	cmqnq97x4001flx4upjb4nzcm	5.000	105.00	525.00	1	\N
cmr2z90t1002gw82p9jbfgc7e	cmr2z8uei0024w82pl4jprckc	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr2zikf60057w82ppn3dsdtr	cmr2zhv2j004rw82p25edpkp1	cmqnq97ut0013lx4ueqfkijq8	5.000	20.00	100.00	1	\N
cmr2zq3ew007zw82p3bfu9ef2	cmr2zpx9b007kw82ppc2ccbt9	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	\N
cmr2zq3ew0080w82p8nsderea	cmr2zpx9b007kw82ppc2ccbt9	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	\N
cmr2zq3ew0081w82pw8afaqyk	cmr2zpx9b007kw82ppc2ccbt9	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr2zq3ew0082w82p41ho93zw	cmr2zpx9b007kw82ppc2ccbt9	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr2zr10d009zw82p5mh02zk4	cmr2zqon5009kw82pefndzryz	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	\N
cmr2zr10d00a0w82pzfo8ka8w	cmr2zqon5009kw82pefndzryz	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	1	\N
cmr2zr10d00a1w82pcirxuuxa	cmr2zqon5009kw82pefndzryz	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr2zr10d00a2w82px2jrsow8	cmr2zqon5009kw82pefndzryz	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr37tp6m006nw8yo0u93ijed	cmr37t9hn0069w8yot9fpyn6z	cmqnq97vj0017lx4uc77sbdn6	5.000	30.00	150.00	1	\N
cmr37uz1z007mw8yoidlc3lpa	cmr2zjkgn0060w82pr4dweo2w	cmqnq97r6000vlx4usqsalrhi	1.000	105.00	105.00	1	\N
cmr37w5ym009cw8yolka4xm3q	cmr37w0nw008tw8yon306wqnl	cmqnq97vj0017lx4uc77sbdn6	2.000	30.00	60.00	1	\N
cmr37w5ym009dw8yoysp9msbx	cmr37w0nw008tw8yon306wqnl	cmqnc6u0x000plxvskd56o9d9	100.000	120.00	12000.00	1	\N
cmr37w5ym009ew8yo4owgtlnw	cmr37w0nw008tw8yon306wqnl	cmqnq97tc000zlx4up9ymaj58	1.000	15.00	15.00	1	\N
cmr37w5ym009fw8yoa5akxm76	cmr37w0nw008tw8yon306wqnl	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr37w5ym009gw8yo7o8n9q6d	cmr37w0nw008tw8yon306wqnl	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr37w5ym009hw8yox9teonr7	cmr37w0nw008tw8yon306wqnl	cmqnq97wg001blx4ueh3hh29z	1.000	55.00	55.00	1	\N
cmr37w5ym009iw8yoff78gddm	cmr37w0nw008tw8yon306wqnl	cmqnq97n4000nlx4umqv6wqxb	1.000	30.00	30.00	1	\N
cmr37w5ym009jw8yo3h04cmbo	cmr37w0nw008tw8yon306wqnl	cmqnq97p4000rlx4updfrju1f	1.000	55.00	55.00	1	\N
cmr38sag500a8w896zwi2wmfj	cmr2z9s4j0039w82ps3x24ynh	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr39a3jd00fxw8960vc4thjy	cmr399k4100fiw896gywrtm79	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr39a3jd00fyw896eglz4fq7	cmr399k4100fiw896gywrtm79	cmr394f0b00dgw89676gha1f1	1.000	150.00	150.00	1	\N
cmr3bte5600fnw8ufo51rece7	cmr3bte5600flw8ufvw7q3f7s	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	\N	\N
cmr3bte5600fow8ufagrz8mtf	cmr3bte5600flw8ufvw7q3f7s	cmqnc6u0x000plxvskd56o9d9	1.000	120.00	120.00	\N	\N
cmr3bte5600fpw8ufw7gcne6m	cmr3bte5600flw8ufvw7q3f7s	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	\N	\N
cmr3bte5600fqw8uf1gawg0ug	cmr3bte5600flw8ufvw7q3f7s	cmqnq97tc000zlx4up9ymaj58	120.000	15.00	1800.00	\N	\N
cmr3bte5600frw8ufksq671zm	cmr3bte5600flw8ufvw7q3f7s	cmqnq97x4001flx4upjb4nzcm	6.000	105.00	630.00	\N	\N
cmr3drciz00lrw87pit1pkp7u	cmr3dr0ep00j3w87pg8jklql6	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr5ta3oy006ew8oh8830k8fn	cmr5t9xe60061w8oh9gvahuo0	cmqnq97x4001flx4upjb4nzcm	1.000	105.00	105.00	1	\N
cmr5ta3oy006fw8oh5uzq9t79	cmr5t9xe60061w8oh9gvahuo0	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	1	\N
cmr7a2ofp019jw8mp9iqeymfz	cmr7a1mv50171w8mp91lvl4kr	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr7a3s0v01bqw8mpv4gdpik4	cmr7a3lvi01b6w8mp80duk4s2	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr7aagkb01jlw8mplersrp7u	cmr7aabwv01itw8mpyx0xbo7b	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr7aray801vcw8mpr8lkdhpy	cmr7ar6qr01uow8mp91cne35m	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr7dlibn00iew8rfjfiogflj	cmr7dlekj00hqw8rfkfmw86iv	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
cmr7du2yd00ulw8rflnuherqk	cmr7dty1400txw8rftx02hajp	cmqnq97vj0017lx4uc77sbdn6	1.000	30.00	30.00	1	\N
\.


--
-- Data for Name: purchase_return_items; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.purchase_return_items (id, purchase_return_id, purchase_item_id, master_product_id, quantity, unit_price, total_amount, reason) FROM stdin;
cmr1kym6z0009w8jo6egoxi62	cmr1kym6z0007w8jo2h7kfmi1	cmr0jg0lv000ow8s3vbntwydp	cmq3qiahw0005lxru9rwwztl9	1.000	125.00	125.00	raja
cmr1kymc9000gw8joxo4vgeq2	cmr1kymc9000ew8jouyyodbym	cmr0j7msc0042w8b5mkryfpzq	cmqnq97p4000rlx4updfrju1f	1.000	55.00	55.00	emni
cmr1kymf5000nw8jo3mle62kc	cmr1kymf4000lw8jozztv6lu3	cmr0j6qts002rw8b5h98araqi	cmqnq97vj0017lx4uc77sbdn6	4.000	30.00	120.00	emni
cmr1kymf5000ow8johkfu2hrz	cmr1kymf4000lw8jozztv6lu3	cmr0j6qts002sw8b5aqfr5enf	cmqnc6u0x000plxvskd56o9d9	2.000	120.00	240.00	emni
\.


--
-- Data for Name: purchase_returns; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.purchase_returns (id, shop_id, purchase_id, supplier_id, created_by_user_id, approved_by_user_id, return_date, status, refund_method, refund_amount, notes, created_at, updated_at) FROM stdin;
cmr1kym6z0007w8jo2h7kfmi1	cmr0gdhu7005kw8g06c2lngfc	cmr0jfpcu000kw8s3ksa9ty62	cmr0hw4la008dw8g0nh4tkk30	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:26.747	APPROVED	CASH	125.00	raja	2026-07-01 04:33:26.748	2026-07-01 04:33:26.748
cmr1kymc9000ew8jouyyodbym	cmr0gdhu7005kw8g06c2lngfc	cmr0j7msc0040w8b513bzlq5a	cmr0hw4la008dw8g0nh4tkk30	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:26.936	APPROVED	CASH	55.00	emni	2026-07-01 04:33:26.937	2026-07-01 04:33:26.937
cmr1kymf4000lw8jozztv6lu3	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qts002pw8b5qtn78wqp	cmr0hw4la008dw8g0nh4tkk30	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:27.04	APPROVED	CASH	360.00	emni	2026-07-01 04:33:27.041	2026-07-01 04:33:27.041
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.purchases (id, shop_id, supplier_id, invoice_no, purchase_date, total_amount, paid_amount, due_amount, payment_method, notes, created_at, updated_at, payment_meta, discount_amount, extra_charge_amount, invoice_file_name, subtotal_amount, approved_at, approved_by_user_id, created_by_user_id, rejected_at, rejection_reason, status) FROM stdin;
cmr0f4037004aw8g06jezalcn	cmqtek0us0002lxj6zzrnqalp	cmqxor2bl001slxtkt5felngw	\N	2026-06-30 09:01:54.142	126.00	0.00	126.00	DUE	\N	2026-06-30 09:01:54.163	2026-06-30 09:02:32.418	null	0.00	0.00	\N	126.00	2026-06-30 09:02:32.414	cmqtek0uk0000lxj659fzko6g	cmqtek0uk0000lxj659fzko6g	\N	\N	APPROVED
cmr0h6wzr007sw8g0tbj8zx72	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	\N	2026-06-30 10:00:09.312	150.00	150.00	0.00	CASH	\N	2026-06-30 10:00:09.35	2026-06-30 10:54:54.079	null	0.00	0.00	\N	150.00	2026-06-30 10:54:54.078	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0hl6u10089w8g0eawjuc78	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	\N	2026-06-30 10:11:15.257	1485.00	1485.00	0.00	CASH	\N	2026-06-30 10:11:15.288	2026-06-30 10:54:54.331	null	0.00	0.00	\N	1485.00	2026-06-30 10:54:54.33	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0i27er008pw8g0shrocgbl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 10:24:29.103	105780.00	105780.00	0.00	CASH	\N	2026-06-30 10:24:29.186	2026-06-30 10:54:54.373	null	0.00	0.00	\N	105780.00	2026-06-30 10:54:54.372	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0ic37l0096w8g0aojmgem0	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 10:32:10.262	75000.00	75000.00	0.00	CASH	\N	2026-06-30 10:32:10.304	2026-06-30 10:54:54.418	null	0.00	0.00	\N	75000.00	2026-06-30 10:54:54.417	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0j8t2r004dw8b5coiu617y	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 10:57:36.761	770.00	0.00	770.00	\N	\N	2026-06-30 10:57:36.819	2026-06-30 10:57:36.819	null	0.00	0.00	\N	770.00	2026-06-30 10:57:36.818	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0jdhky0003w8s36i2kybhl	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	\N	2026-06-30 11:01:15.138	900.00	900.00	0.00	CASH	\N	2026-06-30 11:01:15.202	2026-06-30 11:01:26.625	null	0.00	0.00	\N	900.00	2026-06-30 11:01:26.624	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0jfpcu000kw8s3ksa9ty62	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 11:02:58.56	125.00	125.00	0.00	CASH	\N	2026-06-30 11:02:58.591	2026-07-01 04:33:26.783	null	0.00	0.00	\N	125.00	2026-06-30 11:03:13.17	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0j7msc0040w8b513bzlq5a	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 10:56:41.991	220000.00	0.00	219945.00	\N	\N	2026-06-30 10:56:42.012	2026-07-01 04:33:27.019	null	0.00	0.00	\N	220000.00	2026-06-30 10:56:42.011	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr0j6qts002pw8b5qtn78wqp	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-06-30 10:56:00.5	20069440.00	0.00	20069080.00	\N	\N	2026-06-30 10:56:00.592	2026-07-01 04:33:27.049	null	0.00	0.00	\N	20069440.00	2026-06-30 10:56:00.591	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr1kzx3o0012w8joeetozhlr	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-01 04:34:27.507	2170.00	2170.00	0.00	CASH	\N	2026-07-01 04:34:27.54	2026-07-01 04:34:43.781	null	0.00	0.00	\N	2170.00	2026-07-01 04:34:43.78	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2ydudi003nw8zbiqw0bnz2	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 03:36:58.34	145.00	145.00	0.00	CASH	\N	2026-07-02 03:36:58.374	2026-07-02 03:37:06.598	null	0.00	0.00	\N	145.00	2026-07-02 03:37:06.597	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2ylpey0062w8zb04m8whed	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 03:43:05.099	30.00	30.00	0.00	CASH	\N	2026-07-02 03:43:05.194	2026-07-02 03:43:12.779	null	0.00	0.00	\N	30.00	2026-07-02 03:43:12.778	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2ynen6007fw8zbiiw747h1	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 03:44:24.528	50.00	0.00	50.00	DUE	\N	2026-07-02 03:44:24.546	2026-07-02 03:44:43.391	null	0.00	0.00	\N	50.00	2026-07-02 03:44:43.39	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2ytmrc009lw8zbvo7etzp3	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 03:49:14.987	140.00	140.00	0.00	CASH	\N	2026-07-02 03:49:15	2026-07-02 03:49:56.643	null	0.00	0.00	\N	140.00	2026-07-02 03:49:56.642	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2z0rqj0011w8hobwhi38oy	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 03:54:48.022	230.00	230.00	0.00	BKASH	\N	2026-07-02 03:54:48.043	2026-07-02 03:55:01.46	{"senderNumber": "", "transactionId": ""}	0.00	0.00	\N	230.00	2026-07-02 03:55:01.459	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2yvlri00aqw8zbn14lkdp3	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	\N	2026-07-02 03:50:47.004	525.00	525.00	0.00	CASH	\N	2026-07-02 03:50:47.022	2026-07-02 04:00:43.117	null	0.00	0.00	\N	525.00	2026-07-02 04:00:43.116	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2z8uei0024w82pl4jprckc	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 04:01:04.727	105.00	105.00	0.00	CASH	\N	2026-07-02 04:01:04.747	2026-07-02 04:01:13.045	null	0.00	0.00	\N	105.00	2026-07-02 04:01:13.044	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2zhv2j004rw82p25edpkp1	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 04:08:05.501	100.00	100.00	0.00	CASH	\N	2026-07-02 04:08:05.515	2026-07-02 04:08:38.37	null	0.00	0.00	\N	100.00	2026-07-02 04:08:38.368	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2zpx9b007kw82ppc2ccbt9	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	\N	2026-07-02 04:14:21.583	270.00	270.00	0.00	CASH	\N	2026-07-02 04:14:21.6	2026-07-02 04:14:29.576	null	0.00	0.00	\N	270.00	2026-07-02 04:14:29.574	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2zqon5009kw82pefndzryz	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	\N	2026-07-02 04:14:57.062	290.00	290.00	0.00	BKASH	\N	2026-07-02 04:14:57.089	2026-07-02 04:15:13.117	{"senderNumber": "", "transactionId": ""}	0.00	0.00	\N	290.00	2026-07-02 04:15:13.115	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr37t9hn0069w8yot9fpyn6z	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 08:00:54.307	150.00	150.00	0.00	CASH	\N	2026-07-02 08:00:54.347	2026-07-02 08:01:14.686	null	0.00	0.00	\N	150.00	2026-07-02 08:01:14.684	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2zjkgn0060w82pr4dweo2w	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 04:09:25.051	105.00	105.00	0.00	CASH	\N	2026-07-02 04:09:25.079	2026-07-02 08:02:14.135	null	0.00	0.00	\N	105.00	2026-07-02 08:02:14.134	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr37w0nw008tw8yon306wqnl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 08:03:02.842	12445.00	12445.00	0.00	CASH	\N	2026-07-02 08:03:02.876	2026-07-02 08:03:09.742	null	0.00	0.00	\N	12445.00	2026-07-02 08:03:09.741	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr2z9s4j0039w82ps3x24ynh	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 04:01:48.438	105.00	105.00	0.00	CASH	\N	2026-07-02 04:01:48.451	2026-07-02 08:28:08.549	null	0.00	0.00	\N	105.00	2026-07-02 08:28:08.547	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr399k4100fiw896gywrtm79	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 08:41:34.191	255.00	255.00	0.00	CASH	\N	2026-07-02 08:41:34.225	2026-07-02 08:41:59.402	null	0.00	0.00	\N	255.00	2026-07-02 08:41:59.401	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr3bte5600flw8ufvw7q3f7s	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 09:52:58.714	2705.00	0.00	2705.00	\N	\N	2026-07-02 09:52:58.841	2026-07-02 09:52:58.841	null	0.00	0.00	\N	2705.00	\N	\N	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	PENDING_APPROVAL
cmr3dr0ep00j3w87pg8jklql6	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-02 10:47:06.934	125.00	125.00	0.00	CASH	\N	2026-07-02 10:47:06.961	2026-07-02 10:47:22.668	null	0.00	0.00	\N	125.00	2026-07-02 10:47:22.667	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr5t9xe60061w8oh9gvahuo0	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-04 03:37:16.074	230.00	230.00	0.00	CASH	\N	2026-07-04 03:37:16.111	2026-07-04 03:37:24.274	null	0.00	0.00	\N	230.00	2026-07-04 03:37:24.273	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7a1mv50171w8mp91lvl4kr	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	\N	2026-07-05 04:14:28.755	30.00	30.00	0.00	CASH	\N	2026-07-05 04:14:28.864	2026-07-05 04:15:17.558	null	0.00	0.00	\N	30.00	2026-07-05 04:15:17.557	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7a3lvi01b6w8mp80duk4s2	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-05 04:16:00.876	30.00	30.00	0.00	CASH	\N	2026-07-05 04:16:00.894	2026-07-05 04:16:08.863	null	0.00	0.00	\N	30.00	2026-07-05 04:16:08.86	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7aabwv01itw8mpyx0xbo7b	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-05 04:21:14.558	30.00	30.00	0.00	CASH	\N	2026-07-05 04:21:14.576	2026-07-05 04:21:20.603	null	0.00	0.00	\N	30.00	2026-07-05 04:21:20.602	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7ar6qr01uow8mp91cne35m	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-05 04:34:21.009	30.00	30.00	0.00	CASH	\N	2026-07-05 04:34:21.026	2026-07-05 04:34:26.48	null	0.00	0.00	\N	30.00	2026-07-05 04:34:26.479	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7dlekj00hqw8rfkfmw86iv	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-05 05:53:50.004	30.00	30.00	0.00	CASH	\N	2026-07-05 05:53:50.083	2026-07-05 05:53:54.945	null	0.00	0.00	\N	30.00	2026-07-05 05:53:54.944	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
cmr7dty1400txw8rftx02hajp	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	\N	2026-07-05 06:00:28.509	30.00	30.00	0.00	CASH	\N	2026-07-05 06:00:28.552	2026-07-05 06:00:34.934	null	0.00	0.00	\N	30.00	2026-07-05 06:00:34.932	cmr0gdhs5005iw8g0cqf5tgmo	cmr0gdhs5005iw8g0cqf5tgmo	\N	\N	APPROVED
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.refresh_tokens (id, user_id, token_hash, family, app_type, expires_at, revoked_at, created_at) FROM stdin;
cmq3dwz820001lxdvgozllco8	cmq3dt6mv0000lxophsbhevt3	7ff15601447b7da5174dfab37df583afa24095dc6dafa880deace4645551707f	8d799744-ae75-4218-b75f-fce616c293b7	WEB	2026-06-14 06:12:03.025	2026-06-07 06:13:54.893	2026-06-07 06:12:03.027
cmq3dzhly0003lxdv1q9vxj3q	cmq3dt6mv0000lxophsbhevt3	e8d7740e0e88991f402cd4f39e30b9989c90f0bfff1d0b8439c0dc1937066160	42828e14-89c3-4d7a-8085-f3a08cfb4873	WEB	2026-06-14 06:14:00.164	\N	2026-06-07 06:14:00.167
cmq3f17wo0005lxdvr1aybel7	cmq3dt6mv0000lxophsbhevt3	2707127744944ba99c27fcbdbbf2eeb1fa6cb69038d4e87a1a5c6207755dbed7	6ddfec87-feac-43f1-8705-3446f8a917e9	WEB	2026-06-14 06:43:20.518	2026-06-07 06:56:34.081	2026-06-07 06:43:20.52
cmq3fibds0007lxdvtbdbvpka	cmq3dt6mv0000lxophsbhevt3	fd9f70a3b98c544a8d77eaf7d6e9600c86edd0d58c8daedc8602fdda30cf1a72	cb07f66f-147d-4dc8-82d6-4e94c84321ec	WEB	2026-06-14 06:56:38.174	\N	2026-06-07 06:56:38.176
cmq3hosdt0009lxdv1cawp918	cmq3dt6mv0000lxophsbhevt3	d0585666b4fcd8896590ea99d09f2b3130bced7622df034bcc70d4f01e141035	cf9d4c6b-2733-41c3-9ff9-f5627faca172	WEB	2026-06-14 07:57:39.376	\N	2026-06-07 07:57:39.377
cmq3i8fq9000blxdvngwz1cnb	cmq3dt6mv0000lxophsbhevt3	63685585fc2cb99cc32feba08d508692d9dd1c7d577851e24e07390c9a01034f	a725e7cb-cf5d-478c-9579-de0d61e173f7	WEB	2026-06-14 08:12:56.095	\N	2026-06-07 08:12:56.097
cmq3ivmx30001lx48gnkrzyfh	cmq3dt6mv0000lxophsbhevt3	3dd43c297f06f28c83e8e92dfb6ab9c8a31bb0896b8d03f5304b9f412eb000ee	21944c0a-dcc0-49fc-83f3-2ae0668dfbde	WEB	2026-06-14 08:30:58.501	\N	2026-06-07 08:30:58.503
cmq3ky8r30001lx09ene6wojx	cmq3dt6mv0000lxophsbhevt3	3604cf2cfd5363dfdb5ac49d0f95f158acfb778ec252cff126f1ec3e0b4a87c7	1af7e43a-0404-4a0f-add9-81064d3c191c	WEB	2026-06-14 09:28:59.338	\N	2026-06-07 09:28:59.343
cmq3lzso80001lx7m115irlg8	cmq3dt6mv0000lxophsbhevt3	98d18935356142f90cf7b4221f555c1214ca4fa8323120d9b2aaf5a01f034458	3b689467-7d9e-4ee7-93c5-0721a291798e	WEB	2026-06-14 09:58:11.429	\N	2026-06-07 09:58:11.432
cmq3mktua0001lx4cowrmv4qo	cmq3dt6mv0000lxophsbhevt3	a0fa03d3709683399ce65287aaa8d2323139d342ac6eb67c6aa5e5002970a610	e5263093-453d-402e-b4dc-8511118791a8	WEB	2026-06-14 10:14:32.72	\N	2026-06-07 10:14:32.722
cmq3nc7o2000glxhmpxjddq75	cmq3dt6mv0000lxophsbhevt3	d4765ee6d282c7eb38ec876f8de28782c3d3a57e43647035fea132cc8aa50e21	9cb568f9-a16b-4afd-aa24-b4c682346a8f	WEB	2026-06-14 10:35:50.352	2026-06-07 10:47:52.855	2026-06-07 10:35:50.354
cmq3nrp6h0001lx36v7a1lxc6	cmq3dt6mv0000lxophsbhevt3	bce115b2c335ac32b2cd4ce37136ff6864ce1feda33dd66613a92fd319a3c74a	9cb568f9-a16b-4afd-aa24-b4c682346a8f	WEB	2026-06-14 10:47:52.885	2026-06-07 11:01:36.944	2026-06-07 10:47:52.889
cmq3o9d920003lxzwphrs7tql	cmq3dt6mv0000lxophsbhevt3	68f63fc67d2fa973caf2dff978a59b31a75d0c981d38ede31441f236173af37d	9cb568f9-a16b-4afd-aa24-b4c682346a8f	WEB	2026-06-14 11:01:37.235	2026-06-07 11:13:37.19	2026-06-07 11:01:37.238
cmq3ooste0005lxzw4d892o4h	cmq3dt6mv0000lxophsbhevt3	01546599aa7d8d706dcc7ae0b960dc36ce6fff0917b6ef2e60fd5a9238f6b606	9cb568f9-a16b-4afd-aa24-b4c682346a8f	WEB	2026-06-14 11:13:37.249	2026-06-07 11:31:50.214	2026-06-07 11:13:37.25
cmq3pc85t0001lxulfwy2uvn6	cmq3dt6mv0000lxophsbhevt3	7c59b74f2f3ad07d4aa3b2e0a1f29aba459e8c471b624ec2d5e20c945ed69cf4	9cb568f9-a16b-4afd-aa24-b4c682346a8f	WEB	2026-06-14 11:31:50.224	\N	2026-06-07 11:31:50.225
cmq3q4etn0001lxru3r2b501b	cmq3dt6mv0000lxophsbhevt3	e67bb7cadacd7397b17ef953467fa52a4869582398639f8ba9f7e5aee57d2bbb	15d1d74a-9fdb-4fa4-bf79-755cea3674d3	WEB	2026-06-14 11:53:45.225	\N	2026-06-07 11:53:45.227
cmq4odiot0001lx7x1nyt3oda	cmq3dt6mv0000lxophsbhevt3	5ea24188939d2f0b8278081bd394a33928f96bdc2d1f82a19407f01e16e19d78	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 03:52:37.083	2026-06-08 04:04:42.933	2026-06-08 03:52:37.085
cmq4ot2sg0003lx7xw6dsdbiu	cmq3dt6mv0000lxophsbhevt3	ca11cfe866df5a6c3efb4ae4a8f9dc27a4e85086d351d6ca6fe7f3ffb2657088	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 04:04:42.975	2026-06-08 04:16:41.609	2026-06-08 04:04:42.977
cmq4p8haq0005lx7x1kccig4n	cmq3dt6mv0000lxophsbhevt3	c1c69ca24f38ce8da2102f621e50b53b1ef868fba5e66a39520fc172d0958113	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 04:16:41.617	2026-06-08 04:28:42.12	2026-06-08 04:16:41.618
cmq4pnxb70007lx7xeq1gq6bp	cmq3dt6mv0000lxophsbhevt3	f8d1845d3265522a2fbe0be7fa06921a27b25c54dc87e532a104393c75868a03	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 04:28:42.21	2026-06-08 04:40:41.805	2026-06-08 04:28:42.212
cmq4q3cpt0009lx7xmm0pcsia	cmq3dt6mv0000lxophsbhevt3	d04f71c3c8b62228ce9cb84d2be3f01de15f31c8d388338e14ea6fcb3980b2c3	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 04:40:42.016	2026-06-08 04:52:41.305	2026-06-08 04:40:42.017
cmq4qirq9000blx7x4c08husr	cmq3dt6mv0000lxophsbhevt3	3cfbfed53f9d941c5554abb0beb8dc3c9b002207502a4222e3b12c96d9c54ee7	53cbb49b-dcb2-4a06-a575-dafb193013a2	WEB	2026-06-15 04:52:41.312	\N	2026-06-08 04:52:41.313
cmq4r4s4g0001lx7il8xblgec	cmq3dt6mv0000lxophsbhevt3	3fb11f3e54452cb6893a64d8b538be5afcbab8459c935b63ee1956cb7c0f1573	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 05:09:48.254	2026-06-08 05:21:50.314	2026-06-08 05:09:48.256
cmq4rk99t0003lx7iujmzyp2j	cmq3dt6mv0000lxophsbhevt3	06aae0612bf460d068c5461c302aca93904c536c2b33f7b6873ebd83aea27555	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 05:21:50.32	2026-06-08 05:33:49.941	2026-06-08 05:21:50.322
cmq4rzojg0005lx7i4g4tyj5p	cmq3dt6mv0000lxophsbhevt3	0e7e7d01febf78864cb9a49c5f7e439cd3a2ff0d236b551c472833c9d781f38f	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 05:33:49.947	2026-06-08 05:45:49.764	2026-06-08 05:33:49.948
cmq4sf46j0001lxu5znd4ytun	cmq3dt6mv0000lxophsbhevt3	c980fda8aab304827a0d95c417bf240971f0d65a44ec351aaeff0edf3ad43452	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 05:45:50.058	2026-06-08 06:07:13.769	2026-06-08 05:45:50.06
cmq4t6mpo0003lxhcnw4cxvfc	cmq3dt6mv0000lxophsbhevt3	1dd84d571c0c2c82062ece0867cfb58fa6f72f089f997dc2bd13e8a795afdc27	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 06:07:13.786	2026-06-08 06:26:26.869	2026-06-08 06:07:13.788
cmq4tvcg50001lx18nlv30j71	cmq3dt6mv0000lxophsbhevt3	300fa0df11bbc668dab5d89e7b9f4ff010c3a649ec9f7bc82b979a206eab70a7	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 06:26:26.883	2026-06-08 06:47:42.341	2026-06-08 06:26:26.885
cmq4umolr0001lxdlroqtu0ch	cmq3dt6mv0000lxophsbhevt3	6692ab05cced3849dc71db85346e47b384bf1025f4b0383719d2565d216c07e5	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 06:47:42.35	2026-06-08 06:59:42.597	2026-06-08 06:47:42.351
cmq4v24de0001lxaxlcvc3i9e	cmq3dt6mv0000lxophsbhevt3	bc1bd73d2760c172fb00973ef10e0926b326b86c6bcc94b42b33be2d1a7f133d	0cd34047-e544-4a70-bf3d-8df62fa636bb	WEB	2026-06-15 06:59:42.625	\N	2026-06-08 06:59:42.626
cmq4vmad90001lx7relr1u663	cmq3dt6mv0000lxophsbhevt3	29fee2ee2905ab9b93f115cf3f1949182ecf23b28e4279745523aaa4b18f2c70	4a4556a4-49e5-4bca-958a-dd491daece01	WEB	2026-06-15 07:15:23.516	2026-06-08 07:27:28.478	2026-06-08 07:15:23.518
cmq4w1tr90001lxsial0rk1xj	cmq3dt6mv0000lxophsbhevt3	bff660d9d9579fac087ad5240c7d98eac05d9647e6a4cf11cd4b0185ee731c88	4a4556a4-49e5-4bca-958a-dd491daece01	WEB	2026-06-15 07:27:28.484	2026-06-08 07:39:27.171	2026-06-08 07:27:28.485
cmq4wh8b40003lxsiumj3k7fv	cmq3dt6mv0000lxophsbhevt3	1aec1b2f40d24e10dc5a0f3cc74a69b3c71a18eae850cb5301b4adf719c4a923	4a4556a4-49e5-4bca-958a-dd491daece01	WEB	2026-06-15 07:39:27.182	\N	2026-06-08 07:39:27.184
cmq4x10rs0001lxjhc7kff1dy	cmq3dt6mv0000lxophsbhevt3	4c69aa70c7a5eddb65b42662836ff663e8619d428af90ccbb199b73bd7ec5fee	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 07:54:50.534	2026-06-08 08:18:44.035	2026-06-08 07:54:50.536
cmq4xvqvi0001lxizkr0e90sb	cmq3dt6mv0000lxophsbhevt3	cb5c946263218c9407362dc1a062ce3429e456af60411b04efe54c72dee8c4ff	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 08:18:44.046	2026-06-08 08:30:43.649	2026-06-08 08:18:44.047
cmq4yb64r0003lxizwjj6ekt4	cmq3dt6mv0000lxophsbhevt3	48848719f49f073729c6975e42e87c01515d81eb206ba413567c4cd1a462b132	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 08:30:43.657	2026-06-08 08:42:43.342	2026-06-08 08:30:43.659
cmq4yqlgd0005lxizus658r36	cmq3dt6mv0000lxophsbhevt3	ef10da3751ae505ddb99f95750f20c55c1962c34738e64ee3796312cfa0181ad	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 08:42:43.354	2026-06-08 08:54:43.188	2026-06-08 08:42:43.358
cmq4z60vx0007lxiz3ug7hcmq	cmq3dt6mv0000lxophsbhevt3	2bc9e324c539ef20882d8d30867a16da5c1f1f2736e435d660cff2e28790d60d	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 08:54:43.195	2026-06-08 09:06:43.612	2026-06-08 08:54:43.197
cmq4zlgrq0009lxiz65z6xlys	cmq3dt6mv0000lxophsbhevt3	0eddf1cb28f4f1b1f8f205ef41bc203b189df58f0cebb36bc5af55719480d792	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 09:06:43.62	2026-06-08 09:18:44	2026-06-08 09:06:43.622
cmq500wqj000blxizxabq0i7z	cmq3dt6mv0000lxophsbhevt3	72418c549cf14d16feabe3dde143a31b931bb071acd4163413e68ef098fce8b7	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 09:18:44.153	2026-06-08 09:30:43.103	2026-06-08 09:18:44.155
cmq50gbhk0006lxyp5ay667z4	cmq3dt6mv0000lxophsbhevt3	22917690530719cb578ec05224d982afcda306623d97d391d14be45c2a6d16ad	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 09:30:43.11	2026-06-08 09:42:51.161	2026-06-08 09:30:43.112
cmq50vx9a0008lxypolhhq7ni	cmq3dt6mv0000lxophsbhevt3	5fb4064184c03b2586eea59c7452fd07041fd9401e736e3c05d3925fda9242a3	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 09:42:51.166	2026-06-08 09:54:43.609	2026-06-08 09:42:51.167
cmq51b6zl000alxyp0f6peo9h	cmq3dt6mv0000lxophsbhevt3	2b6e9a40f9f60c62b5d9f2965991a665eb74b8f4ca30b75bf09f5e79f3a8254c	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 09:54:43.616	2026-06-08 10:06:43.799	2026-06-08 09:54:43.617
cmq51qmox000clxyph5cnc4ab	cmq3dt6mv0000lxophsbhevt3	8be467b29db0a16f9004c2f92c3bc80d763a7ee180cfd89e3fc19cd61fd86d38	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 10:06:43.807	2026-06-08 10:18:43.072	2026-06-08 10:06:43.809
cmq5261oo000elxypfx13yjkn	cmq3dt6mv0000lxophsbhevt3	4162f1ddbedb5e8745262441585bdc7d28b1c67071fb6617f51c427ab373ca1d	c204fbd7-0488-44b9-a297-8779e343f0eb	WEB	2026-06-15 10:18:43.078	\N	2026-06-08 10:18:43.08
cmq52wixw0001lxs13vi7qe27	cmq3dt6mv0000lxophsbhevt3	4379a97f9ae2fea56be5a336d12708e3bbaaec1e9788faae365be185aa2a901e	9076d1f4-5d7b-420d-9a01-e076553b0e65	WEB	2026-06-15 10:39:18.498	2026-06-08 10:51:27.96	2026-06-08 10:39:18.5
cmq53c5vf0001lxc9ybcwd2tw	cmq3dt6mv0000lxophsbhevt3	eb166feeb821052ea0cc10dcc3879950817e2d3159e52633a30bd660bff16452	9076d1f4-5d7b-420d-9a01-e076553b0e65	WEB	2026-06-15 10:51:28.047	\N	2026-06-08 10:51:28.059
cmq547xjj0001lxuoofdoxmfd	cmq3dt6mv0000lxophsbhevt3	1ea335b27d01937031951cec2b601476be8baf7352f039b05161c4c7d8db7558	234a8142-a795-4baa-8fb1-583f5884c085	WEB	2026-06-15 11:16:10.254	2026-06-08 11:29:19.265	2026-06-08 11:16:10.256
cmq54ouco0003lxrsnto1okfj	cmq3dt6mv0000lxophsbhevt3	8e2d126155939aefa531feb473df7df27982a4c41ebe5aed5359cf7d3cc060ba	234a8142-a795-4baa-8fb1-583f5884c085	WEB	2026-06-15 11:29:19.272	2026-06-08 11:41:18.691	2026-06-08 11:29:19.273
cmq5549gp0005lxrsjh9sor3c	cmq3dt6mv0000lxophsbhevt3	3b53ab8df7acf3c1bd863607e2dfb9329ebb8e208c6a2208ea295a0aa17fbf8a	234a8142-a795-4baa-8fb1-583f5884c085	WEB	2026-06-15 11:41:18.696	2026-06-08 11:53:19.143	2026-06-08 11:41:18.697
cmq55jpd90007lxrsd8s206sg	cmq3dt6mv0000lxophsbhevt3	7e9e65fb78cae7b02f57982fb385e53d6c4421aa00616a038f4b9fc3a9d6af28	234a8142-a795-4baa-8fb1-583f5884c085	WEB	2026-06-15 11:53:19.149	2026-06-08 12:05:19.141	2026-06-08 11:53:19.15
cmq55z4xc0009lxrsx0kewkhf	cmq3dt6mv0000lxophsbhevt3	36483cfbe97c822f5e413988b7113b01cbb532012055d6f94dcf54a6a9de9d56	234a8142-a795-4baa-8fb1-583f5884c085	WEB	2026-06-15 12:05:19.152	\N	2026-06-08 12:05:19.153
cmqtek5pc0009lxj6l7997ux9	cmqtek0uk0000lxj659fzko6g	5f688e059eef1834fca8b288efa3e2de4168602724a91ae8ac6674ab71fb802e	c39c6b86-b4b0-44e7-b684-69342c341449	MOBILE	2026-06-26 11:12:05.086	2026-06-27 05:34:08.806	2026-06-25 11:12:05.088
cmqvxdn4n0003lxww4iqp944r	cmqtek0uk0000lxj659fzko6g	47e8611ca7849816c7b5d9242b2c753646c441c96b06b4c0e4069886d5390e5e	a4cd95b3-242a-4fe2-9619-ac5e1c0e4f1c	MOBILE	2026-06-30 05:34:26.133	\N	2026-06-27 05:34:26.135
cmq7jvtek0001lxh8d5mh7f0j	cmq3dt6mv0000lxophsbhevt3	d9895a69607f38f569515ab4e4be61f98a47beb5d5576adbed0f42dd743a548b	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 04:10:11.227	2026-06-10 04:22:17.58	2026-06-10 04:10:11.229
cmq7kbdvb0005lxhpbp8pqbe7	cmq3dt6mv0000lxophsbhevt3	d1e75ad2ca1b10efe9ad0b16db4d162b5c3e081ed895445dd407254598beaf49	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 04:22:17.589	2026-06-10 04:34:16.651	2026-06-10 04:22:17.591
cmq7kqspl0001lxp734dhouvj	cmq3dt6mv0000lxophsbhevt3	60589d43c7d6ed6dfd4b1dfac5fba6c1307deffb0c96753ac099c69f3c4538c5	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 04:34:16.664	2026-06-10 04:46:16.622	2026-06-10 04:34:16.665
cmq7l688m0001lxu02vbhwhqb	cmq3dt6mv0000lxophsbhevt3	24f45a079872c554c5761cfa09047edf2ab4b0f752829557a8f95dd3efba997a	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 04:46:16.628	2026-06-10 05:07:10.426	2026-06-10 04:46:16.63
cmq7lx3og0009lxkpgwmg4r4n	cmq3dt6mv0000lxophsbhevt3	6ca2e8d743c1207f7f6ff046231457eefcbd10e19eec905dd7470fe5ec5564a5	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:07:10.431	2026-06-10 05:10:15.974	2026-06-10 05:07:10.432
cmqw5lner0003lxwlo8q1xigk	cmqtek0uk0000lxj659fzko6g	3e67406ec3361341c58952125e14cdd9bd50ad8278f14d577d950dabfb54d654	6c61dd93-4b41-4f5d-bedb-28ebf0b9ef1f	MOBILE	2026-06-30 09:24:36.673	\N	2026-06-27 09:24:36.675
cmq7m12un000dlxkpgwkhuplh	cmq3dt6mv0000lxophsbhevt3	26c66bba11b556a14f2e498fdf89c7bb466f7d629502e1f4510d4845e834adf8	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:10:15.981	2026-06-10 05:22:16.631	2026-06-10 05:10:15.983
cmq7mgiwu000plxkpn70kklj8	cmq3dt6mv0000lxophsbhevt3	896d075b99d2c50089613b199d779c82ad9b33f35327bb9399cc2176b7de58d8	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:22:16.637	2026-06-10 05:34:15.991	2026-06-10 05:22:16.638
cmq7mvxz1000rlxkp6bd7os5c	cmq3dt6mv0000lxophsbhevt3	620e23ab6f609976cad61cab786b61d06ef5d91ad6f73981441a58aa440b1fe8	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:34:15.996	2026-06-10 05:46:15.955	2026-06-10 05:34:15.997
cmq7nbdi2000tlxkpv5v4mpes	cmq3dt6mv0000lxophsbhevt3	1451fc5b29377edc1b79c7227776f987f1f6f7223f2ebabf3175db40c9b514c2	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:46:15.961	2026-06-10 05:58:15.973	2026-06-10 05:46:15.962
cmq7nqt2o000vlxkpqn5x0793	cmq3dt6mv0000lxophsbhevt3	5ef684b1f77939733f75d9682623e042a4584d97650a15e8f4f4cdfc573dcff5	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 05:58:15.982	2026-06-10 06:10:15.943	2026-06-10 05:58:15.984
cmq7o68lp000xlxkplighpdou	cmq3dt6mv0000lxophsbhevt3	c602e5bac8f06fdc355bb21042dd9f203b982857dd5c47e0501c5872bede36fe	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 06:10:15.948	2026-06-10 06:22:15.954	2026-06-10 06:10:15.949
cmq7olo60000zlxkp9vlgelvb	cmq3dt6mv0000lxophsbhevt3	319c8522cf08216c62b4a637b43fd2e9f77255c707b66c79c577bf4e2f82cb2a	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 06:22:15.959	2026-06-10 06:34:15.987	2026-06-10 06:22:15.961
cmq7p13qy0011lxkp00xuzan0	cmq3dt6mv0000lxophsbhevt3	e6af214872f3805f43bc784e86d3ea17b6b16c64dfe5033a3d8b53afed5d9f7e	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 06:34:15.993	2026-06-10 06:46:53.728	2026-06-10 06:34:15.994
cmq7phcfa0013lxkpknwj5v6k	cmq3dt6mv0000lxophsbhevt3	99e557ab47febf8f45debf2cfd583a3f28ea1298de1be73a1ed8a8af15e18693	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 06:46:53.733	2026-06-10 06:58:16.473	2026-06-10 06:46:53.735
cmq7pvz8j0015lxkp6iselv7t	cmq3dt6mv0000lxophsbhevt3	c4b32176f7cf53f233ecc4f8874be9ce0dd536ff85175607a30cdf31822bcd5e	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 06:58:16.482	2026-06-10 07:10:53.676	2026-06-10 06:58:16.483
cmq7qc7hv0017lxkp9ieoqbyj	cmq3dt6mv0000lxophsbhevt3	449eafd3775e9973bc2860ddfac7f332608a6ef25c6fa1c3a7d93abddbfe88f1	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 07:10:53.682	2026-06-10 07:22:53.854	2026-06-10 07:10:53.684
cmq7qrn6y0019lxkp7f6fgx7v	cmq3dt6mv0000lxophsbhevt3	cf10550d8381f1d0b526bab75fb3f1f3a1ea6adccb7c28a4dc29c14d3da812b7	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 07:22:53.865	2026-06-10 07:34:53.661	2026-06-10 07:22:53.866
cmq7r72lf001blxkpyw88hs45	cmq3dt6mv0000lxophsbhevt3	16643ab0ddb4f04d1fed3da46ec7bc34660cce134a8f0ef4f4c2587471a615af	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 07:34:53.666	2026-06-10 07:46:53.745	2026-06-10 07:34:53.668
cmq7rmi7w001dlxkpmbhgsbww	cmq3dt6mv0000lxophsbhevt3	a2463d0473a8b79ec970f45eb64165a6250fe48a2b9c7efed0a1ca56416bbd31	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 07:46:53.752	2026-06-10 07:58:53.658	2026-06-10 07:46:53.753
cmqxdsitq000zlxpr1s5nsa2j	cmqtek0uk0000lxj659fzko6g	2c3a36d641c501736413a6de3e0329bb5bf1a36a8f7a03dd91c7a590e9dc71b1	b8245149-8702-4df0-8bff-05d4257bbea6	MOBILE	2026-07-01 06:01:40.429	\N	2026-06-28 06:01:40.43
cmq7s1xpg001flxkpgjnonse1	cmq3dt6mv0000lxophsbhevt3	5f7fd4bcf9e9ce5499cfc553c787dfcc34aedd0829fd0e71999282b7a29d1b52	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 07:58:53.667	2026-06-10 08:10:53.687	2026-06-10 07:58:53.668
cmq7shda7001hlxkp04q0xe45	cmq3dt6mv0000lxophsbhevt3	0cc049683c5e51afe7c73d2a6a2761824796b1776a6c7a628e3e26b4c84c282e	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 08:10:53.695	2026-06-10 08:22:53.692	2026-06-10 08:10:53.696
cmq7swsud001jlxkpi5w809cp	cmq3dt6mv0000lxophsbhevt3	bb54823439e95f68766a5c81dd1e65552a2a87dbc6597de8e544abf51638cd7a	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 08:22:53.7	2026-06-10 08:34:53.681	2026-06-10 08:22:53.701
cmq7tc8dz001llxkpaj9bd5i9	cmq3dt6mv0000lxophsbhevt3	26363c36cef3fae255822201d64f2fac6ea66ca1854cd7ea3d550c3720c6b4b0	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 08:34:53.686	2026-06-10 08:46:53.67	2026-06-10 08:34:53.687
cmq7trnxp0001lxn999gov365	cmq3dt6mv0000lxophsbhevt3	25228325867e78e8a7ba2c929b6a7cbca72efcc23cbf744ae2e872c0b6bbc9d0	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 08:46:53.676	2026-06-10 08:58:18.182	2026-06-10 08:46:53.678
cmqvxnw8w001jlxwwxjvzj3pn	cmqtek0uk0000lxj659fzko6g	44ffa259d17e60b0fa55ae21b1e4106f1dca29acf9062aafd20eabfac784529f	99277227-cbcf-4506-bd81-2c22d710c804	MOBILE	2026-06-30 05:42:24.511	\N	2026-06-27 05:42:24.512
cmq7u6c3w0003lxn943ky5fg9	cmq3dt6mv0000lxophsbhevt3	2ba383ceaea6e54b5caffce253a6acf869c8826a56540996b7f7152a25e5e091	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 08:58:18.188	2026-06-10 09:10:53.669	2026-06-10 08:58:18.189
cmq7umj1n0009lxn9fbs6f9c0	cmq3dt6mv0000lxophsbhevt3	10dc153fdc8ccfbe59f129ab5f0ee887e673fcf34c0d56a829a973683c1d3980	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 09:10:53.674	2026-06-10 09:22:54.165	2026-06-10 09:10:53.675
cmqw6rgba0003lxard8640nmy	cmqtek0uk0000lxj659fzko6g	5b89c1dc0d67961b6c567a5a61ea98f2ada4e058ce2c9fe28c396dc08b32eca0	61287479-0b7e-4874-a423-01046cbb4298	MOBILE	2026-06-30 09:57:07.029	\N	2026-06-27 09:57:07.031
cmq7v1yzm0001lxh81zjfj3t8	cmq3dt6mv0000lxophsbhevt3	c4d38e4f6d0f37b5c0734e9219cb96696f99b2695c5912578af2aa9ab331f81b	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 09:22:54.177	2026-06-10 09:34:53.683	2026-06-10 09:22:54.179
cmq7vhe630005lxngouzwksop	cmq3dt6mv0000lxophsbhevt3	d8e7b7b3fa434bd4ccd366eac96bb592cd0cd694d0302ba8a2c13d6e0a5df5a1	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 09:34:53.69	2026-06-10 09:46:16.984	2026-06-10 09:34:53.691
cmqxac4kd0003lxf3dwzgj7jo	cmqtek0uk0000lxj659fzko6g	c03b6bfa5a8f74b73ee2c3fe3b716086adfbdf83e934d1b2b45531852357b4d5	f991aa15-9d6f-4936-99fc-88f1139527bf	MOBILE	2026-07-01 04:24:56.603	2026-06-28 04:49:46.884	2026-06-28 04:24:56.605
cmq7vw1gz0004lx45v3jwzo7f	cmq3dt6mv0000lxophsbhevt3	c8cad4497da679cf7c71362fd3c5b091df392a57cd30697644e6d4d34c60f7d2	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 09:46:17.074	2026-06-10 10:05:01.316	2026-06-10 09:46:17.075
cmq7wk4y50009lxjraxirnmux	cmq3dt6mv0000lxophsbhevt3	4d9d208c27fa0a4027f198f64e2fbbe945e7c4dc3594f2a457d56a053dad713a	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 10:05:01.324	2026-06-10 10:17:00.679	2026-06-10 10:05:01.325
cmq7wzk0e000blxjrjfm1xw3y	cmq3dt6mv0000lxophsbhevt3	9bc63ff420f3213d6f36e4919cc46a64f28ee1901a3c36cdc2ddece5395a4ea4	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 10:17:00.685	2026-06-10 10:29:01.637	2026-06-10 10:17:00.686
cmq7xf0b0000dlxjrgznl6e3w	cmq3dt6mv0000lxophsbhevt3	320a54126a3b41a2b52ce6fd9f189ad113b4b05d94f73e4ce893e9299e5eadd6	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 10:29:01.642	2026-06-10 10:41:01.62	2026-06-10 10:29:01.644
cmq7xufui000flxjr3y13rw1i	cmq3dt6mv0000lxophsbhevt3	8888090b66b920acdcdce2f1528f1eda235973c240a8fae45771604454605532	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 10:41:01.625	2026-06-10 10:53:01.624	2026-06-10 10:41:01.626
cmq7y9vel000hlxjr1s3cmnbt	cmq3dt6mv0000lxophsbhevt3	d633ac32ad6e081903d948b1d61e205524b64451c5afe34e4666269a7b38e9c6	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 10:53:01.628	2026-06-10 11:05:01.625	2026-06-10 10:53:01.629
cmq7ypaz4000jlxjrucbep2it	cmq3dt6mv0000lxophsbhevt3	9faddb343de4abf6af30dbc6b08ba69e6cde66fc7a8903d9027cfabbca98c740	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 11:05:01.647	2026-06-10 11:17:53.65	2026-06-10 11:05:01.649
cmq7z5uny000llxjrodnp0gep	cmq3dt6mv0000lxophsbhevt3	165bf653c16af80681e207324ced723f6c17ac2e367e305c35acaa2b5905bafc	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 11:17:53.66	2026-06-10 11:29:53.649	2026-06-10 11:17:53.662
cmq7zla7y000nlxjr1kr1p93b	cmq3dt6mv0000lxophsbhevt3	3d96e411b68d5647ad726b1ebb78c2614dafcbd3b4c79270dbf6e8b43a286181	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 11:29:53.66	2026-06-10 11:41:53.907	2026-06-10 11:29:53.662
cmq800pz2000plxjry3frz3tc	cmq3dt6mv0000lxophsbhevt3	78dc0537ede4f974048a09a039f59f8b3943062a40b2a44a2055063a3f51c32a	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 11:41:53.917	2026-06-10 11:53:43.321	2026-06-10 11:41:53.918
cmq80fxd2000rlxjrj55zrh6m	cmq3dt6mv0000lxophsbhevt3	9710ce80be1dbd6b9ef63c7b5cdaaf813cf1982c6eaee168a36a56d93ffa6470	a0ba0776-9f95-41fc-ae91-00bba5e68a31	WEB	2026-06-17 11:53:43.333	\N	2026-06-10 11:53:43.334
cmqxe1vc2001vlxpre22n7rph	cmqtek0uk0000lxj659fzko6g	bb0b90f795cb2fd25db52774dbb4eb613013ae16071e34b286b124e54aeed1fb	44bb84f1-02db-48fa-bb55-76b1718be4ea	MOBILE	2026-07-01 06:08:56.545	\N	2026-06-28 06:08:56.546
cmqxjk3zv0003lxl2y8lgoqlv	cmqtek0uk0000lxj659fzko6g	f0a7b666163af3f4ff7df2d91252aed4acef27cbd8c594ea567b393bf516d814	7b007666-0327-424b-a24c-f326593ab9b6	MOBILE	2026-07-01 08:43:05.657	\N	2026-06-28 08:43:05.659
cmqxmxod5004zlxcfttn7yuuu	cmqtek0uk0000lxj659fzko6g	d0994f1c4a8b09c1ff3d34644fb481b72e0befcec9a0bf590af85b02a341d49e	a1a8c59d-9d0f-4dbb-9a5d-fea622b8f453	MOBILE	2026-07-01 10:17:37.429	\N	2026-06-28 10:17:37.432
cmqxr0qb8001xlxnlknr4r6p2	cmqtek0uk0000lxj659fzko6g	62dcf21bba2b35a1941515ca62628157ddfacc3168c193fabc964477ee00223c	f1081fc8-9332-480a-b72d-6b442dceab0f	MOBILE	2026-07-01 12:11:58.387	\N	2026-06-28 12:11:58.388
cmqvzutrm002plxww1jwvgaio	cmqtek0uk0000lxj659fzko6g	44b00e7ecf182f91a16d458c05219576bf7a3b0228e35ce921e5530ab504e770	c2c4ceb3-6cfa-4100-8542-2c3774d9a8ff	MOBILE	2026-06-30 06:43:47.119	\N	2026-06-27 06:43:47.122
cmq986fd60001lxglux5bhqdw	cmq3dt6mv0000lxophsbhevt3	7b69526493247c888e7ca19163a745083ed50715c378f24d704c21e7e642632a	68d46892-1afd-4ef3-859d-5acd9d8528c8	WEB	2026-06-18 08:18:03.208	\N	2026-06-11 08:18:03.21
cmqw78qah000plx9f0yb2awhz	cmqtek0uk0000lxj659fzko6g	7e057f2fee1b39d01774db4469d24d8927a1fb89e0580491984ac54515b65485	c3b0b846-b718-4f36-9dbe-1534e0803a5d	MOBILE	2026-06-30 10:10:33.112	2026-06-27 10:25:19.748	2026-06-27 10:10:33.114
cmq98pbu9000glxglszpops3h	cmq3dt6mv0000lxophsbhevt3	5d745e9d091f5ad6b91ed4c3b38e3a0423036ebcb79d5ea460b90fee76770778	815259c6-e951-4b56-afbc-7d1ecfb029fa	WEB	2026-06-18 08:32:45.104	2026-06-11 08:33:00.45	2026-06-11 08:32:45.105
cmq98ut90000ilxglf39qe3tu	cmq3dt6mv0000lxophsbhevt3	114385c4f83140b842989db77aa5576455a925ebdf04fa0d5c858db92ffefc8d	71660a2d-ab81-4da8-aacd-8cd2806e6a55	WEB	2026-06-18 08:37:00.947	\N	2026-06-11 08:37:00.949
cmqxb82h8001jlxf3b8erwqo0	cmqtek0uk0000lxj659fzko6g	916e5d52f80936d663e56c79e6728223db45b2de136215359eafbf897bf95a5d	f991aa15-9d6f-4936-99fc-88f1139527bf	MOBILE	2026-07-01 04:49:46.891	\N	2026-06-28 04:49:46.893
cmqxex9ty0003lxloond3qlfc	cmqtek0uk0000lxj659fzko6g	ad0b4e0efc9fcca8c9e7d4fd8181fefcbc2f74bcca62e0a0cc6a92178e1b0720	ea1e7c4c-3cb4-4747-a2b2-82204d27f4c1	MOBILE	2026-07-01 06:33:21.668	\N	2026-06-28 06:33:21.67
cmq99iqns000slxgl2ikttcr6	cmq3dt6mv0000lxophsbhevt3	41fce75fc4e131312e4a7fa3e7812d41523ad1769cec3c24eb53b047612783b3	f12f5895-8ca1-44f8-b5f7-1a695e1790b0	WEB	2026-06-18 08:55:37.336	2026-06-11 09:07:42.941	2026-06-11 08:55:37.337
cmq99yajo000ulxgluimti3ge	cmq3dt6mv0000lxophsbhevt3	bd07511b4af277ba16b3891835070595e4529c0ca1516454c5c018836019b970	f12f5895-8ca1-44f8-b5f7-1a695e1790b0	WEB	2026-06-18 09:07:42.947	2026-06-11 09:19:41.681	2026-06-11 09:07:42.949
cmq9adp4y000wlxglignonozt	cmq3dt6mv0000lxophsbhevt3	dfdf03cb7eb65accd4eec8e8617f97c5d1834a7654126fb9fc9f8de9917b6377	f12f5895-8ca1-44f8-b5f7-1a695e1790b0	WEB	2026-06-18 09:19:41.696	2026-06-11 09:31:41.737	2026-06-11 09:19:41.698
cmq9at4r9000ylxgl2gbm78pf	cmq3dt6mv0000lxophsbhevt3	40322244df4b9e5029f4ed14f8ed67ef3e285c35fd83cc7f5485b337b8da02b1	f12f5895-8ca1-44f8-b5f7-1a695e1790b0	WEB	2026-06-18 09:31:41.781	\N	2026-06-11 09:31:41.782
cmqxk9otp001flxl2a4lggxh1	cmqtek0uk0000lxj659fzko6g	4d4c12e47becea5c12e723853daf7bc68e2960ea66af87058d9a3064a9cfd590	8d48b849-62e3-497c-a282-069f34b833fc	MOBILE	2026-07-01 09:02:59.051	\N	2026-06-28 09:02:59.053
cmq9b429m0017lxglal3te2cy	cmq3dt6mv0000lxophsbhevt3	91f0c2bb91b1c9f244f6354295f22666d6ddfd0f61be2d3282803df75a85f050	6ebaabdf-f81d-473b-b45e-4e7c85239fd8	WEB	2026-06-18 09:40:11.769	2026-06-11 09:52:14.723	2026-06-11 09:40:11.77
cmq9bjk4b0019lxgluz3dtdh2	cmq3dt6mv0000lxophsbhevt3	22a5e8a89dc0ba6dfe8ae132aacb3c6db5c58132b95dc813eb23f1948fe7afb4	6ebaabdf-f81d-473b-b45e-4e7c85239fd8	WEB	2026-06-18 09:52:14.746	2026-06-11 10:04:12.695	2026-06-11 09:52:14.747
cmq9byy4e001blxglxmdnm9r0	cmq3dt6mv0000lxophsbhevt3	0cea6591eb5d700cac9adbba8955139cfe8c1eb5bd6f69dc551f26a014be1e91	6ebaabdf-f81d-473b-b45e-4e7c85239fd8	WEB	2026-06-18 10:04:12.732	\N	2026-06-11 10:04:12.734
cmqxna16n006blxcfc6zsus3q	cmqtek0uk0000lxj659fzko6g	d3189e18b3ec3fc766e49ddb34c8b926e7830693680f73cf47c401d4ee6231af	0cbad321-0523-4cc7-9f1b-5338e6dbfab2	MOBILE	2026-07-01 10:27:13.918	2026-06-28 11:02:38.628	2026-06-28 10:27:13.919
cmqxryxzj003rlxnl7n1ol9dk	cmqtek0uk0000lxj659fzko6g	2cdb001cd7601d307e68144244661ff6b5f808553ecc20f8612f3ac8d372223b	66e98d64-991b-439e-ae97-f62140a7fb6a	MOBILE	2026-07-01 12:38:34.638	\N	2026-06-28 12:38:34.639
cmqw01tzl003nlxwwojnph55y	cmqtek0uk0000lxj659fzko6g	9bb913d2f075ba5e00a1616cb4933d062ccd7bced8a3cc8d8dd199dfb48a9bd9	990e9d39-0c6f-40e7-a0cc-218acc403b40	MOBILE	2026-06-30 06:49:13.999	\N	2026-06-27 06:49:14.001
cmqw7rqg4001vlx9f5np81c3h	cmqtek0uk0000lxj659fzko6g	f239f8dcb661e66cd07fdea04f5ed9070e0467d3a2a13b4f899154e2a453978c	c3b0b846-b718-4f36-9dbe-1534e0803a5d	MOBILE	2026-06-30 10:25:19.777	2026-06-27 10:41:40.22	2026-06-27 10:25:19.78
cmqxbkme1002vlxf3bfom46nz	cmqtek0uk0000lxj659fzko6g	d6b68876fece5ae61c6b77278d9af20aebe28b463d5303b7e0373536f22d4277	90518ca8-0cfa-4df4-be6d-b2499e7c0162	MOBILE	2026-07-01 04:59:32.567	\N	2026-06-28 04:59:32.569
cmqxfkv9a002nlxgfswq0j2vs	cmqtek0uk0000lxj659fzko6g	37bf1ec721fa39c6cfa5bb39d5172f8ebcd558d834789547f81864380229335e	9363a9a7-8b64-48c1-85a6-ed3d24a2f254	MOBILE	2026-07-01 06:51:42.523	\N	2026-06-28 06:51:42.525
cmqxki993002nlxl2vj75hi1v	cmqtek0uk0000lxj659fzko6g	2670151bfd548e6abe22cdc23a922236963582f753e77ed3c685f02b7381031a	17d6a4b6-11ad-49bd-8340-68a17cb2c0d8	MOBILE	2026-07-01 09:09:38.774	\N	2026-06-28 09:09:38.776
cmqxojkmp0003lxtkf1f78llv	cmqtek0uk0000lxj659fzko6g	fb047cf7f612b4fa0e3e2d22aa238f0ff1c013e6c2834d10f922bffb6025d4cd	0cbad321-0523-4cc7-9f1b-5338e6dbfab2	MOBILE	2026-07-01 11:02:38.639	\N	2026-06-28 11:02:38.641
cmqda3zhx0001lx7bu7f9px4g	cmq3dt6mv0000lxophsbhevt3	1a40eeae9d36ac0634b8cc74aa0439d26a81eb65e28dec06b0a95cebc4ac7bc8	6f22dc93-c7ab-4260-8a36-0347b1d99f6b	WEB	2026-06-21 04:23:13.268	\N	2026-06-14 04:23:13.27
cmqw0xvnb0003lxx182q27yvu	cmqtek0uk0000lxj659fzko6g	5f265d4552016ea1b3e2a4c2a27c4c44f619d5773fcafe67fa0b3699ef105827	6fc004a1-5f8d-49aa-83f4-6edf1d8c5c7c	MOBILE	2026-06-30 07:14:09.142	\N	2026-06-27 07:14:09.144
cmqw8cqz3003blx9f0tkssj3u	cmqtek0uk0000lxj659fzko6g	db8105c4da76140d79335dbd6d1c18f32464e7d7fc788208fadb64d3daa1ffc4	c3b0b846-b718-4f36-9dbe-1534e0803a5d	MOBILE	2026-06-30 10:41:40.237	\N	2026-06-27 10:41:40.239
cmqxbzazq003zlxf34564toln	cmqtek0uk0000lxj659fzko6g	1425d60a9dde37221aff2678f78f156cb21dac080c4ff76471e35e0f4b0c471a	53af46b5-7b2e-4dd2-8d1f-e06af27d8ca7	MOBILE	2026-07-01 05:10:57.636	\N	2026-06-28 05:10:57.637
cmqxg7o2c004slxgf5vm4hndp	cmqtek0uk0000lxj659fzko6g	b2d6839a3becb175578f5a425448b25fdf35877cc1730131fd6c3769547f2ddb	96be6d8f-a7b8-4954-9546-5ca46bdb11ac	MOBILE	2026-07-01 07:09:26.291	2026-06-28 07:57:49.838	2026-06-28 07:09:26.292
cmqxkt1kc0003lxda41azi7vo	cmqtek0uk0000lxj659fzko6g	2219e3b2e25e7a0f605e4cf3b2bf1a9856169ad1a60f7b47014a8468f57c794b	7c7ffd29-e101-4bcb-884d-ce695b0c2d32	MOBILE	2026-07-01 09:18:02.027	2026-06-28 09:33:39.003	2026-06-28 09:18:02.029
cmqxoxx9d0020lxtkiwqwljin	cmqtek0uk0000lxj659fzko6g	0b20e248c538aac52b6506b63d351e4c134f8d847e62499da5ecd351abf19720	823fdf77-a735-4ecd-899a-7f427eafc7f7	MOBILE	2026-07-01 11:13:48.192	\N	2026-06-28 11:13:48.194
cmqdnjuo00001lx5j8rmwu22y	cmq3dt6mv0000lxophsbhevt3	7cb184c1b71e2b733e28c07ee086c57b2a3a0dabc61739a930f46ff14e47a3cc	aec9c2c6-5245-4b85-857c-3a531b8dc83d	WEB	2026-06-21 10:39:28.51	\N	2026-06-14 10:39:28.512
cmqdofrqg0001lx00m1xzkk1t	cmq3dt6mv0000lxophsbhevt3	1829f289a9d256eb5781faf990f56e767e9361d92f80a076b2c7a1b95c85906e	6378b804-f361-472d-8777-6cb94b45c3ca	WEB	2026-06-21 11:04:17.701	\N	2026-06-14 11:04:17.704
cmqdojhma0001lxxv04mq9eez	cmq3dt6mv0000lxophsbhevt3	db75caa4996c04f017103969e9b3b56665f0829f62503d48a8143bc6ebc34d63	ccf719af-63ea-44f4-ba4a-2c9f00a28698	WEB	2026-06-21 11:07:11.215	2026-06-14 11:29:51.389	2026-06-14 11:07:11.218
cmqdpcn53000flxl33hpefjgj	cmq3dt6mv0000lxophsbhevt3	5d919d63168b57e8cab30f62444da3751ff0b386737f6e6ff22f9d4f49603ac0	ccf719af-63ea-44f4-ba4a-2c9f00a28698	WEB	2026-06-21 11:29:51.398	2026-06-14 11:41:50.135	2026-06-14 11:29:51.4
cmqdps1q60001lxcnfdactlw3	cmq3dt6mv0000lxophsbhevt3	fbd5253e2e4976d6a4225d8b61ec3595470a0da3cd28599e58563eb97f0b04af	ccf719af-63ea-44f4-ba4a-2c9f00a28698	WEB	2026-06-21 11:41:50.141	2026-06-14 11:53:49.498	2026-06-14 11:41:50.142
cmqdq7gsu0001lxmpuc7arqh9	cmq3dt6mv0000lxophsbhevt3	23702a30e0d679b71004256a33efa9f992ac76e6a58ba47beb752737a780203e	ccf719af-63ea-44f4-ba4a-2c9f00a28698	WEB	2026-06-21 11:53:49.512	2026-06-14 12:05:49.358	2026-06-14 11:53:49.518
cmqdqmw8m0003lxmptoq6uplu	cmq3dt6mv0000lxophsbhevt3	25f24246a5dc991dfa77447cd006fcabf6734600663a335185dc08d938253718	ccf719af-63ea-44f4-ba4a-2c9f00a28698	WEB	2026-06-21 12:05:49.365	\N	2026-06-14 12:05:49.366
cmqw3ag8f0003lxugjmgax98j	cmqtek0uk0000lxj659fzko6g	1afacfd98896c3643a50948a0393078b943234130b5de408577b5041a15eae23	b9a990c5-6bf4-41a3-a952-ce155b814139	MOBILE	2026-06-30 08:19:54.924	\N	2026-06-27 08:19:54.927
cmqw9c7gh0003lxmqtjkt8jvl	cmqtek0uk0000lxj659fzko6g	fee79d7fa3044614676f5241b89ca7fe3fb50b7a5899a1919a6917d62dfc4fd8	f4968a2e-149c-4ac9-9526-0aed8ed7eb30	MOBILE	2026-06-30 11:09:14.558	2026-06-27 11:24:56.884	2026-06-27 11:09:14.561
cmqxcioks0003lxm8xwrjzdbj	cmqtek0uk0000lxj659fzko6g	53e6a5d19c05529b89349ff61f89f1fbf804ba6fee99dcd3ea18a37486a5bc0d	2a70b4f6-d0dc-49a2-8a0b-004085770090	MOBILE	2026-07-01 05:26:01.706	2026-06-28 05:41:01.714	2026-06-28 05:26:01.708
cmqxhxwh10003lx0bp4k4cprz	cmqtek0uk0000lxj659fzko6g	4de155f2fc35c5b31dc81f173e1442559cdc2fdd96f3251db9c3d52cf059ce5a	96be6d8f-a7b8-4954-9546-5ca46bdb11ac	MOBILE	2026-07-01 07:57:49.856	\N	2026-06-28 07:57:49.861
cmqxld4jz0003lxcf8p2stmvc	cmqtek0uk0000lxj659fzko6g	54d2eb598d9b77d0ea7beca1b6e3d286b538c126e71960f4bd8613f0fe9ff5e0	7c7ffd29-e101-4bcb-884d-ce695b0c2d32	MOBILE	2026-07-01 09:33:39.021	\N	2026-06-28 09:33:39.023
cmqxp8iir002ylxtk7m3xvtlv	cmqtek0uk0000lxj659fzko6g	34b398aa8e53928cd42b634dcfc82d5808f71cf697738a6c5e34b91ebcdfb82a	6c5051d7-271f-4ddf-b3a0-b93ccb05d6d5	MOBILE	2026-07-01 11:22:02.305	\N	2026-06-28 11:22:02.307
cmqeum7080011lx9qsddo718a	cmq3dt6mv0000lxophsbhevt3	21232d1daddf293360513971f74cb9b3472fce0e6973805b6f67cbdb1f5a68d9	33831932-99a8-48b6-93a5-8a176c167f6c	WEB	2026-06-22 06:45:01.303	2026-06-15 06:58:30.575	2026-06-15 06:45:01.304
cmqev3jg6001tlx9qngvrtrxr	cmq3dt6mv0000lxophsbhevt3	2e6ac69cd5a5726c7819615ea123eab7a1fa56072c19496d44585ebd864074fe	33831932-99a8-48b6-93a5-8a176c167f6c	WEB	2026-06-22 06:58:30.581	\N	2026-06-15 06:58:30.582
cmqw3lb7u001blxug1zkt7phl	cmqtek0uk0000lxj659fzko6g	789222a64da948b4158a0772f7a027e09fabc92bd50e4ef3a43f0161cfaf8e74	924d25c5-538d-4c92-b55a-6508fce235f4	MOBILE	2026-06-30 08:28:21.64	2026-06-27 08:51:32.019	2026-06-27 08:28:21.642
cmqw9weki0003lx3h3zxuqpnk	cmqtek0uk0000lxj659fzko6g	8ae4f098d87d12137ca6b33b4ba7044f41089c5cf87551c3148371fe3cbe80ed	f4968a2e-149c-4ac9-9526-0aed8ed7eb30	MOBILE	2026-06-30 11:24:56.895	\N	2026-06-27 11:24:56.898
cmqxd1z18002dlxm83rx2964k	cmqtek0uk0000lxj659fzko6g	81cc0ec8eb206b67ebf8103ab7e7c0cdd88a6f0873dbd1234150c143543ee095	2a70b4f6-d0dc-49a2-8a0b-004085770090	MOBILE	2026-07-01 05:41:01.722	\N	2026-06-28 05:41:01.724
cmqxi6fsu000tlx0bu1xqk8by	cmqtek0uk0000lxj659fzko6g	ad281bf1505ddda9c8b793ea758845df8a39bdcc6825345edf4b538f6b294b94	09593354-e4de-4b48-8f82-d15bc671541d	MOBILE	2026-07-01 08:04:28.156	2026-06-28 08:20:12.882	2026-06-28 08:04:28.158
cmqxlqzhf001jlxcf2x71jw4i	cmqtek0uk0000lxj659fzko6g	850762c2241a870664fe530cf9e2b05a6733eaa4754ec56b3ee5eda8a82edf42	2988a515-04fd-43ae-8e14-bc1f288cedd1	MOBILE	2026-07-01 09:44:25.632	\N	2026-06-28 09:44:25.635
cmqxq1p3j0003lxwcrm58nfxa	cmqtek0uk0000lxj659fzko6g	337c87f8cab1cfa21a911dfdd5318c9b09ec460651290fa15e2938b2634b4a12	ed30daa4-244a-461f-a1f6-5fe69be72077	MOBILE	2026-07-01 11:44:43.853	2026-06-28 12:02:44.361	2026-06-28 11:44:43.855
cmqngqbwq0001lxbx2ln65tnx	cmq3dt6mv0000lxophsbhevt3	ffcee9dfe45db700134a87f4956a438f8b69d237e649d3a6b22064cef8da4d8c	36ac8051-61d4-4fce-a36b-bf75bfb409de	WEB	2026-06-28 07:26:15.24	2026-06-21 07:38:20.043	2026-06-21 07:26:15.241
cmqnh5v6b003xlxbx4n8dfkeb	cmq3dt6mv0000lxophsbhevt3	49707d5792c4134ab83a5b93e0e2cc83224558545d786645697391d05d2d6d76	36ac8051-61d4-4fce-a36b-bf75bfb409de	WEB	2026-06-28 07:38:20.05	2026-06-21 07:50:19.56	2026-06-21 07:38:20.051
cmqnhlacw003zlxbxla56f9yf	cmq3dt6mv0000lxophsbhevt3	fb64ff69bed923bf028643ec5bed88bd86364cba000c67584707e0bed6f4ca0e	36ac8051-61d4-4fce-a36b-bf75bfb409de	WEB	2026-06-28 07:50:19.567	\N	2026-06-21 07:50:19.568
cmqni6ofs0041lxbx2k002ltv	cmq3dt6mv0000lxophsbhevt3	3c49ac82e584bfba217e77deab42740b557a6aea926a0c66ab54488448c91a6f	a3db992c-27b6-492d-a604-be49e078c51a	WEB	2026-06-28 08:06:57.591	2026-06-21 08:19:01.028	2026-06-21 08:06:57.592
cmqnim6ne0043lxbxpih7qm7e	cmq3dt6mv0000lxophsbhevt3	671222b4222580b33e5ae2ad22fd0fd21cd079b73c6d2271bcaf8529243409c0	a3db992c-27b6-492d-a604-be49e078c51a	WEB	2026-06-28 08:19:01.033	\N	2026-06-21 08:19:01.034
cmqnj7hg40067lxbx2f8pv5l2	cmq3dt6mv0000lxophsbhevt3	8fb2186022fb35da7431ca0a10b609bd4917b624382a89f314e99b5968be0297	fdc99098-eb79-45b9-9640-ce0b2c460927	WEB	2026-06-28 08:35:34.803	2026-06-21 08:47:36.987	2026-06-21 08:35:34.804
cmqnjmyul0069lxbxhkmifiyo	cmq3dt6mv0000lxophsbhevt3	45d84cfb66def03eb2df47b2a4afc9c287cc1d0d461fb19f1ecf27a7e44e01b5	fdc99098-eb79-45b9-9640-ce0b2c460927	WEB	2026-06-28 08:47:37.195	2026-06-21 08:59:38.22	2026-06-21 08:47:37.197
cmqnk2f83006nlxbxqvaft6c3	cmq3dt6mv0000lxophsbhevt3	6addb924601cc1d0319f78cc988e9a74b73dafb82613c160d8de3a3c187222cb	fdc99098-eb79-45b9-9640-ce0b2c460927	WEB	2026-06-28 08:59:38.258	2026-06-21 09:11:38.493	2026-06-21 08:59:38.26
cmqnkhuyu000nlx9atvps3ejf	cmq3dt6mv0000lxophsbhevt3	0f742bb4996f212125325ab85f232a3e725097e153c2e4bef6b9a9e4b8357757	fdc99098-eb79-45b9-9640-ce0b2c460927	WEB	2026-06-28 09:11:38.501	2026-06-21 09:23:38.751	2026-06-21 09:11:38.503
cmqnkxaq4000plx9acf3rdu06	cmq3dt6mv0000lxophsbhevt3	3b5effc9445b18ab340b141f74c5656a3b0be57969c3ce4a2f9645ddee58655e	fdc99098-eb79-45b9-9640-ce0b2c460927	WEB	2026-06-28 09:23:38.762	\N	2026-06-21 09:23:38.764
cmqnlgywo00rjlx9am61l7egb	cmq3dt6mv0000lxophsbhevt3	e5acc23f485f3850cc72ec33e0339db336a50f624b033dfaa7af4bb35259e378	cc84eaea-21ad-41b4-b447-bec21c427259	WEB	2026-06-28 09:38:56.545	\N	2026-06-21 09:38:56.546
cmqnm172r00rllx9aipr7xq3y	cmq3dt6mv0000lxophsbhevt3	ff54411d43eb5addf50fcd5709a085386b62d809fbabe12f0a88efc62127a95c	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 09:54:40.275	2026-06-21 10:06:43.02	2026-06-21 09:54:40.276
cmqnmgov400rnlx9amc8l9m49	cmq3dt6mv0000lxophsbhevt3	5f251cc74b68fd3e0e578ac5e17d680eb47bf58a7cbb291ea0438d33faefe23e	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 10:06:43.166	2026-06-21 10:18:42.123	2026-06-21 10:06:43.168
cmqnmw3s100rplx9auavhexzb	cmq3dt6mv0000lxophsbhevt3	4b6411d77c524e01f305ffe42df33f3663bc514cb1456eac3caaa8e20b97b7d3	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 10:18:42.336	2026-06-21 10:30:42.092	2026-06-21 10:18:42.337
cmqnnbj6h0001lx4ujfx3v6dt	cmq3dt6mv0000lxophsbhevt3	bb9498d46ce547ed1e2bc3aaa911ebfe0feebbe81f653c1c8f73e6ea71d123ce	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 10:30:42.136	2026-06-21 10:42:44.334	2026-06-21 10:30:42.137
cmqnnr0ll0003lx4ukjwcpo8b	cmq3dt6mv0000lxophsbhevt3	7f25e99b4f0a54cf2a30a8c329f1e04f00b2fb3795774c62b642c6026c6f91b6	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 10:42:44.551	2026-06-21 10:54:41.359	2026-06-21 10:42:44.554
cmqno6dp60005lx4u154zthtj	cmq3dt6mv0000lxophsbhevt3	c3a8f0d2503c293b1790b25b46c622a80c1db88120951d104d52fab4af11816b	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 10:54:41.369	2026-06-21 11:06:42.147	2026-06-21 10:54:41.37
cmqnoltux0007lx4u3p680gaz	cmq3dt6mv0000lxophsbhevt3	b7fcfc75b6871e2d36504a2107f334f57d3b34822a32e8ca05bf25e7b1e68d26	2c5adf10-c317-4052-8c93-25cdd7c2a312	WEB	2026-06-28 11:06:42.152	\N	2026-06-21 11:06:42.153
cmqnpc4pz0009lx4uxn71b8t8	cmq3dt6mv0000lxophsbhevt3	a3d0a7a14f338edf1cb86919da7bf029a7f3aa1a46dae2a7671e4e1b5b5580dd	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 11:27:09.286	2026-06-21 11:39:10.908	2026-06-21 11:27:09.287
cmqnprlj7000blx4u73jrmj57	cmq3dt6mv0000lxophsbhevt3	f075c437cf6dc824a3f5499c142c1a8f81cc1a5434e129881c5c902b5c75cb8f	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 11:39:10.915	2026-06-21 11:51:11.222	2026-06-21 11:39:10.916
cmqnq71k5000dlx4upblgds6i	cmq3dt6mv0000lxophsbhevt3	49adc4682b56deff03015e00e5a891ece4878983c49c5a510e5ff1425c34dafd	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 11:51:11.524	2026-06-21 12:03:11.808	2026-06-21 11:51:11.526
cmqnqmhck0001lxf5evsiizno	cmq3dt6mv0000lxophsbhevt3	1ecd608912fe33da9525129dce4e7f39475dfe1b46ad9f0c23528d67a00df5b6	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 12:03:11.827	2026-06-21 12:15:11.625	2026-06-21 12:03:11.828
cmqnr1wr30003lxf5icpcgaho	cmq3dt6mv0000lxophsbhevt3	2e6213c305906c186f16a9abf65be623645f74fc4b2a667982866a2da789ed15	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 12:15:11.63	2026-06-21 12:27:10.142	2026-06-21 12:15:11.631
cmqnrhb5w0005lxf5le7t2e4u	cmq3dt6mv0000lxophsbhevt3	2367b0d84e2ad55f96aecd4cf468013c7c94a5628045a7b0d44e7de4230903da	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 12:27:10.147	2026-06-21 12:39:10.545	2026-06-21 12:27:10.148
cmqnrwr1t0007lxf51go0d4mz	cmq3dt6mv0000lxophsbhevt3	4951b926db506bab4d6183e4b7e3672531a497a4c9965141bf1a1406301bb782	2a7391a5-94f6-4ecd-a1e0-61c5b4c74c10	WEB	2026-06-28 12:39:10.573	\N	2026-06-21 12:39:10.575
cmqw4f41q002ulxugckfc6lb9	cmqtek0uk0000lxj659fzko6g	555c87e24a8bb0c099aa23840e70de9450a0e2629356c30e23e5dd9b8413e65f	924d25c5-538d-4c92-b55a-6508fce235f4	MOBILE	2026-06-30 08:51:32.028	\N	2026-06-27 08:51:32.03
cmqxdhldf0003lxpreo8e72lh	cmqtek0uk0000lxj659fzko6g	4d863ac8cc091a14a8b1c1a3fadf4afd570feaa0eb6d8d42cbfbb9673298c9bd	87a48e94-b519-44dc-b281-160378a4f01d	MOBILE	2026-07-01 05:53:10.513	\N	2026-06-28 05:53:10.516
cmqxiqorf005ilx0bz3po7ng8	cmqtek0uk0000lxj659fzko6g	26e6dfb4b9da27e0d91355d1a22608d3e7c784dbfd4d1b35ebdd9543e57cf233	09593354-e4de-4b48-8f82-d15bc671541d	MOBILE	2026-07-01 08:20:12.89	\N	2026-06-28 08:20:12.891
cmqxmbstb002rlxcfdiatla7d	cmqtek0uk0000lxj659fzko6g	a2eb87c8e4a3fdd04fa92c5e12ab263061af7bdca29a9a7002d60390282d6a4e	ecd1dd76-ef74-4675-9121-5931a484c124	MOBILE	2026-07-01 10:00:36.766	\N	2026-06-28 10:00:36.767
cmqxqoutt0003lxnlwthf2f8c	cmqtek0uk0000lxj659fzko6g	0082c16acc9d82b911938f4df65fea2b47813b0ad4a39dab6662015a0b1a3738	ed30daa4-244a-461f-a1f6-5fe69be72077	MOBILE	2026-07-01 12:02:44.368	\N	2026-06-28 12:02:44.37
cmr0ew5ss0003w8g0oj127fgo	cmqtek0uk0000lxj659fzko6g	7b1d223c96cf07ab2575f42e6e246fd5dee62cf0053406fc1b6cdb56894e7825	de6b8be2-8e1d-4dc7-ab46-11adfba3f2f0	MOBILE	2026-07-03 08:55:48.316	2026-06-30 09:11:11.136	2026-06-30 08:55:48.316
cmr0gfpeg005rw8g0dauynwst	cmr0gdhs5005iw8g0cqf5tgmo	701d1a17723b60f1c2bd1d4e44b3eb95b812cac5831017e31546f07c8e995a20	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 09:38:59.799	2026-06-30 09:54:55.012	2026-06-30 09:38:59.8
cmr0ffxux005fw8g0m3wd9zab	cmqtek0uk0000lxj659fzko6g	362d6ff8f3d14e6f9fe9adf7448541959a2377f2658193ee050402ec253218c8	de6b8be2-8e1d-4dc7-ab46-11adfba3f2f0	MOBILE	2026-07-03 09:11:11.145	2026-06-30 09:57:39.407	2026-06-30 09:11:11.145
cmr0h06ge006sw8g045qvpk6x	cmr0gdhs5005iw8g0cqf5tgmo	ac4053e1d4b6631eb4e1c7616d8f3a95d00b02e176c57701898e368e16fc49e9	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 09:54:55.021	2026-06-30 10:10:16.51	2026-06-30 09:54:55.022
cmr0hjxl90083w8g03blhtkrf	cmr0gdhs5005iw8g0cqf5tgmo	6a9a3da45a0c6d691ad24b0219dd00c08991e3825b2f343c44d753467a6f223e	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 10:10:16.651	2026-06-30 10:24:52.675	2026-06-30 10:10:16.653
cmr0h3pap006ww8g0ds8g1el3	cmqtek0uk0000lxj659fzko6g	f95e03688710354894598beec316957a5e35a3f4ba5121e5482c8141c7cf300a	de6b8be2-8e1d-4dc7-ab46-11adfba3f2f0	MOBILE	2026-07-03 09:57:39.409	2026-06-30 10:30:55.729	2026-06-30 09:57:39.41
cmr0iaho80090w8g0e3j5swl2	cmqtek0uk0000lxj659fzko6g	f8e164da6bd0bd936b86f215ae3f5abb2aa771fed5c64b17d5aed338975328f7	de6b8be2-8e1d-4dc7-ab46-11adfba3f2f0	MOBILE	2026-07-03 10:30:55.735	\N	2026-06-30 10:30:55.736
cmr0i2pk2008ww8g0va7wan1k	cmr0gdhs5005iw8g0cqf5tgmo	82b2a62a4227b45f41906adb1f021d12e8b57cd4fe065a7bddea04da5f8848b4	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 10:24:52.704	2026-06-30 10:40:03.799	2026-06-30 10:24:52.706
cmr0im8kl009bw8g0yab2tpfa	cmr0gdhs5005iw8g0cqf5tgmo	a9aa0a54ad0c33fd9efc4b0b41e7e1c27a1c575097ca0b75bc2dc9f47772dbd5	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 10:40:03.81	2026-06-30 10:54:53.938	2026-06-30 10:40:03.812
cmr0j5bek0001w8b5v18wgi4y	cmr0gdhs5005iw8g0cqf5tgmo	4404943f66d8725736008bd9a6baa33de9f52b1f6e254107f7e871afbd2305df	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 10:54:53.947	2026-06-30 11:20:03.918	2026-06-30 10:54:53.948
cmr0k1oim001mw8s3aprvrcpi	cmr0gdhs5005iw8g0cqf5tgmo	170fc1b0af1632f2401ac121028561bc21bae9dfe81cc6c5d6019212012cf80e	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 11:20:03.932	2026-06-30 11:41:41.749	2026-06-30 11:20:03.933
cmr0kthxe001ow8s3lz8kq9x6	cmr0gdhs5005iw8g0cqf5tgmo	edf0e07dac7f5e1062d6236b143884746c0ed06a88880fc8c81904236348dd44	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 11:41:41.761	2026-06-30 11:56:15.228	2026-06-30 11:41:41.763
cmr0lc7wh0003w8dv9w35abb6	cmr0gdhs5005iw8g0cqf5tgmo	f76a178243bed2160ab68e62622ff037c09143b1fb37d69bc16dc0bbcd5eaf4c	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 11:56:15.232	2026-06-30 12:12:00.602	2026-06-30 11:56:15.233
cmr0lwhd80001w8z01sey7460	cmr0gdhs5005iw8g0cqf5tgmo	1bcbeee9a16eac3fc1fbea10a5e26c4319be4b1f37279e71a7c0006f61a51924	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 12:12:00.619	2026-06-30 12:28:38.293	2026-06-30 12:12:00.619
cmr0mhv6y0005w8z0xjxktup3	cmr0gdhs5005iw8g0cqf5tgmo	5e77ab1623c61dc1267ef0555c3d88d01672513b06dafbf5bccd17cb88ecbd9f	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-01 12:28:38.312	2026-07-01 04:33:26.314	2026-06-30 12:28:38.313
cmr1kylv70001w8jonrz2t56r	cmr0gdhs5005iw8g0cqf5tgmo	36d0dcfc7a9356ea8bed67a00193125e72e29d2b90d0a7aaaac5bf868e1b3a49	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 04:33:26.322	2026-07-01 04:50:48.207	2026-07-01 04:33:26.323
cmr1lkxsm001ww8jok9bgl99r	cmr0gdhs5005iw8g0cqf5tgmo	221e92f725cd18641b205cba85a422442b505713db315dd6f632bc0dc754d3b9	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 04:50:48.213	2026-07-01 05:06:08.893	2026-07-01 04:50:48.214
cmr1m4o7b0001w86cnpnif8de	cmr0gdhs5005iw8g0cqf5tgmo	68d1695c96c5a8831ac2d252d8159c1ae6c73087f2294f99c6988f69cbc92711	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 05:06:08.902	2026-07-01 05:31:14.028	2026-07-01 05:06:08.903
cmr1n0xkm0001w8djl6mruypw	cmr0gdhs5005iw8g0cqf5tgmo	18f7d75099a960ecf7ac8df7442ea5e02df71237d2a6b5da94b3c8627626a595	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 05:31:14.037	2026-07-01 05:46:13.64	2026-07-01 05:31:14.037
cmr1nk7pw0001w8xny0966xyy	cmr0gdhs5005iw8g0cqf5tgmo	a210e24c8fea168eef425f289e0f6c0b7fca919510841febf8c540c5206c6816	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 05:46:13.651	2026-07-01 06:00:44.715	2026-07-01 05:46:13.652
cmr1o2vuh000xw8xnzyu7cyrs	cmr0gdhs5005iw8g0cqf5tgmo	6fe3752cffbf3cb1aad12ca56994e279dd7fa74ac91dfd8ece3739896d3aea06	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 06:00:44.727	2026-07-01 06:17:49.908	2026-07-01 06:00:44.728
cmr1oouwc002bw8xnylnwlqbj	cmr0gdhs5005iw8g0cqf5tgmo	24f2fe2f8477b25d3c4a97a422be287b6cc12f78f810b711605d458b10d4ef05	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 06:17:49.93	2026-07-01 06:32:42.337	2026-07-01 06:17:49.932
cmr1p7zhn002lw8xnena96ydq	cmr0gdhs5005iw8g0cqf5tgmo	ee5268c07d8c20376ae68f3f85f49c59e58a20c87f801b850558b5111d4f7730	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 06:32:42.347	2026-07-01 06:47:19.149	2026-07-01 06:32:42.348
cmr1pqs1k004ow8xn1977f4jf	cmr0gdhs5005iw8g0cqf5tgmo	92d20f2c8369ae948589bce18e85b27d3eea37bb325fb8e30e6db60c4427db74	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 06:47:19.159	2026-07-01 07:17:59.505	2026-07-01 06:47:19.16
cmr1qu82s0005w8kn00tt40nf	cmr0gdhs5005iw8g0cqf5tgmo	f65f67b06296cd442124ef294a93ac58db66de389f91d95910ebd16dd57547c1	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 07:17:59.523	2026-07-01 08:10:17.758	2026-07-01 07:17:59.524
cmr1sphkd0007w8knsse3fw1y	cmr0gdhs5005iw8g0cqf5tgmo	68e293337fb6796ff9d4391c4ce6c8b29f92f0734760517ee5cb189091ebb855	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 08:10:17.77	2026-07-01 08:25:16	2026-07-01 08:10:17.771
cmr1t8qnf0009w8knjnza56zb	cmr0gdhs5005iw8g0cqf5tgmo	0b0734200a35f26aab0026a69cb95d0b3358555d0a808d99080cc71f42447146	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 08:25:16.009	2026-07-01 08:41:05.851	2026-07-01 08:25:16.01
cmr1tt3k5000bw8knoi7oijbt	cmr0gdhs5005iw8g0cqf5tgmo	c1f4802a25ddae093c38b98117e1288774afcd8ba74edb2c07954910e6aa1e52	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 08:41:05.859	2026-07-01 09:02:35.954	2026-07-01 08:41:05.86
cmr1ukr080003w8bsnhjmzrl5	cmr0gdhs5005iw8g0cqf5tgmo	cf82fe99925eaf97d6fe64c6eb8708f2f60c4bb6b359a7446b2d7e1074dccfe1	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 09:02:35.96	2026-07-01 09:17:37.607	2026-07-01 09:02:35.961
cmr1v42q7000fw8qdrqab5qa7	cmr0gdhs5005iw8g0cqf5tgmo	04b1d4dcb1a3e32c70d1e8e5f0eca34d7057095eebc7fbd595eb126ad66add6a	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 09:17:37.615	2026-07-01 09:32:43.548	2026-07-01 09:17:37.616
cmr1vnhr80005w8btj6r6pcn5	cmr0gdhs5005iw8g0cqf5tgmo	faf683324cb5e255ff4f7fac0b5c7ec8fdca9a5957def1fd09c60ccae417d647	cc9596c5-0222-479a-bc91-346362b0b3d6	MOBILE	2026-07-02 09:32:43.556	\N	2026-07-01 09:32:43.557
cmr1vy2q3000dw8hh3pqtp3ps	cmr0gdhs5005iw8g0cqf5tgmo	1c6fb644d6131ce11fad593115e6ee81a3340a1f7b02714ae08189d783eea15d	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 09:40:57.289	2026-07-01 09:58:21.247	2026-07-01 09:40:57.291
cmr1wkg93000xw844exru0tjh	cmr0gdhs5005iw8g0cqf5tgmo	0d4f91f607a580a3179b727644c7ef97f6c747826b3aed658f4af26774a7beee	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 09:58:21.255	2026-07-01 10:12:55.283	2026-07-01 09:58:21.256
cmr1x36ny0033w844929h4cw9	cmr0gdhs5005iw8g0cqf5tgmo	0e2086a070b7ecfc51ea91fb2be1b86fafb2c1c5eadb9c7f55775de6ad6b574a	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 10:12:55.293	2026-07-01 10:27:30.17	2026-07-01 10:12:55.294
cmr1xlxqh005hw844zpss1gqp	cmr0gdhs5005iw8g0cqf5tgmo	3c8aff6d49094915dd6f5de4ea9898e22b5a55cdacfb5d7d4449d96691a680cb	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 10:27:30.184	2026-07-01 10:42:12.07	2026-07-01 10:27:30.185
cmr1y4u7h008tw844n9m7hw73	cmr0gdhs5005iw8g0cqf5tgmo	f02ab89845885e58b1b8dac5d2ba84c54f450495dd00892a1332d88c76b46194	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 10:42:12.077	2026-07-01 10:58:09.735	2026-07-01 10:42:12.077
cmr1ypd5d00a3w84439j8fkvz	cmr0gdhs5005iw8g0cqf5tgmo	0343dbce1ce5420162c58c4c098625e3c9624bed15b950735e493505518f8aa8	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 10:58:09.745	2026-07-01 11:44:12.548	2026-07-01 10:58:09.745
cmr20ckzg00ezw844mpmcck50	cmr0gdhs5005iw8g0cqf5tgmo	3273910e2dc8d16d3b7205ffc4a4b32357bd51bf5ce5434266f09189b14c194a	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 11:44:12.602	2026-07-01 11:59:06.595	2026-07-01 11:44:12.604
cmr20vqtb00gjw844xeek8yox	cmr0gdhs5005iw8g0cqf5tgmo	20702fbeca7c202d383805a05fd6b1a994467f763042120a29265376e39ff3af	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 11:59:06.622	2026-07-01 12:48:46.169	2026-07-01 11:59:06.623
cmr22nlv100gtw8442loux8bn	cmr0gdhs5005iw8g0cqf5tgmo	018eb7d9e97ead8168403cf7befe4651202582f6daebf88aa7605067774be174	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-04 12:48:46.188	2026-07-02 03:24:49.069	2026-07-01 12:48:46.189
cmr2xy7n30003w8zb2h3sgl8g	cmr0gdhs5005iw8g0cqf5tgmo	cc7ba9c29080e2f7856e276cd20dcf0a432c8aab79b4010e5bcf00e5442e046e	2090f752-d36f-4a21-beab-f4c1d2a3856f	MOBILE	2026-07-05 03:24:49.071	\N	2026-07-02 03:24:49.072
cmr2xyvmo000nw8zbg1ec7yeu	cmr0gdhs5005iw8g0cqf5tgmo	f5fbe9e79ca3adf1ac37b4edb684c72ea553a69bec4365a9b6185c19dcbb7109	3d3f4a74-0265-4c7c-b362-c55427b13eee	MOBILE	2026-07-05 03:25:20.16	\N	2026-07-02 03:25:20.161
cmr2xzbrb000rw8zbb0uewb11	cmr0gdhs5005iw8g0cqf5tgmo	de569a1d1b1389229314665fb4e795ec033f80663cd01f8819d6f8c6aefb0d11	f5abb8e3-02fa-4bbd-af12-54eb05e8ce34	MOBILE	2026-07-05 03:25:41.063	\N	2026-07-02 03:25:41.064
cmr2xzvhz000vw8zb5sd5wp0w	cmr0gdhs5005iw8g0cqf5tgmo	874591038d4f9b1cbb4b4bf3521f539d9964af9b1c63534e8f97189af3bce996	ceea820e-8258-4919-89c8-a874543378d9	MOBILE	2026-07-05 03:26:06.646	\N	2026-07-02 03:26:06.648
cmr2y2nvu000zw8zbp0f7k6ci	cmr0gdhs5005iw8g0cqf5tgmo	6c5aafe1023ed4580318034d05b70655538e81ac61167db5785646eb513aa4de	4ed1ff80-0809-494a-9169-4b37db47c9b3	MOBILE	2026-07-05 03:28:16.746	\N	2026-07-02 03:28:16.746
cmr2y38tb0017w8zbd1a49c8t	cmr0gdhs5005iw8g0cqf5tgmo	4eafb67eafda74c1e008f5fe4f255271f4b2a4bdb764a660a1af2c9fddd756bc	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 03:28:43.871	2026-07-02 03:43:17.644	2026-07-02 03:28:43.872
cmr2ylz0w006tw8zb74l1kfj5	cmr0gdhs5005iw8g0cqf5tgmo	cc51908cb18804e08c234f0b3106f7665cb86b018842b549226caa2dcc3f096b	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 03:43:17.647	2026-07-02 04:00:00.709	2026-07-02 03:43:17.648
cmr2z7gzv0003w82pqlidscfb	cmr0gdhs5005iw8g0cqf5tgmo	375685fd96334e4d3e6cf5fa5ab5891d2c5b142132b79405d6071200932f2b0a	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 04:00:00.714	2026-07-02 04:14:46.348	2026-07-02 04:00:00.715
cmr2zqgd90092w82pt0lo8qm7	cmr0gdhs5005iw8g0cqf5tgmo	d810299fe7dbd6f118bb93d95244dfd2afe8cf2daba8e3b80e451cc85a615927	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 04:14:46.364	2026-07-02 04:29:35.432	2026-07-02 04:14:46.365
cmr309idp00emw82pz3ncnbwo	cmr0gdhs5005iw8g0cqf5tgmo	83358b59547d5a91dde970cad6b17814fa8c33d977730838ee206e92142cb2c7	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 04:29:35.437	2026-07-02 04:46:13.371	2026-07-02 04:29:35.438
cmr30uwed000nw8bdiy97pjcw	cmr0gdhs5005iw8g0cqf5tgmo	59c4cfdaf3fa398e10573071664f80d199203134c0632c4f6111d32a653281ee	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 04:46:13.38	2026-07-02 05:07:54.341	2026-07-02 04:46:13.381
cmr31ms870003w8fu4cncxpgu	cmr0gdhs5005iw8g0cqf5tgmo	f84a1a91214992419427b5af78fbddde04d1f22d443bbed9b0ea5f32c78a898d	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 05:07:54.343	2026-07-02 05:24:01.637	2026-07-02 05:07:54.344
cmr327iln005xw8fuhn0zwfh5	cmr0gdhs5005iw8g0cqf5tgmo	98a7520c68ac247f472cc19a083f01d8ad320c5c659aa7d3bb8784ac1fbd5494	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 05:24:01.642	2026-07-02 06:04:09.586	2026-07-02 05:24:01.643
cmr33n4l500bfw8fub5a7qn38	cmr0gdhs5005iw8g0cqf5tgmo	315fd00260be845331a036b6bb91fc2574615055e62cf0628a680dbc2a74d2b9	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 06:04:09.592	2026-07-02 06:28:43.758	2026-07-02 06:04:09.593
cmr34iq2e00g1w8funlmleibo	cmr0gdhs5005iw8g0cqf5tgmo	2da0600e6210a626463a86b46d4c60eb8acb4b1ee22de84ba48eb1a69bfb98d6	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 06:28:43.766	2026-07-02 06:47:18.515	2026-07-02 06:28:43.767
cmr356m7x00ifw8fuezpcq63n	cmr0gdhs5005iw8g0cqf5tgmo	6ffc58943b35452fb386abeeb3f4e7273636079f1e55705469553b1ea8a107cc	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 06:47:18.524	2026-07-02 07:05:08.053	2026-07-02 06:47:18.525
cmr35tjh40003w8yo9582lzn6	cmr0gdhs5005iw8g0cqf5tgmo	da8b54c7214149a3fb78f286d956a2db45442c06036e31dbb68686071ec835a6	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 07:05:08.056	2026-07-02 07:43:53.864	2026-07-02 07:05:08.057
cmr377e34001lw8yoli0xpk9s	cmr0gdhs5005iw8g0cqf5tgmo	9f25eee198cb4d4447738d24ce9280db562d5af7f54cfdd87a88cbfd004bc90b	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 07:43:53.872	2026-07-02 07:58:30.177	2026-07-02 07:43:53.873
cmr385hl70003w896fruph1xl	cmqtek0uk0000lxj659fzko6g	f3734916ec07d9b2c57e93a539eb45d8e1382c3a395596908dc86a97a9dee495	4d79929c-db04-4f8a-a057-8e872ae5fe08	MOBILE	2026-07-03 08:10:24.715	\N	2026-07-02 08:10:24.716
cmr385qpd0007w8960kwd4sf3	cmr0gdhs5005iw8g0cqf5tgmo	b5a70a51eba5c5856515ee820d47d554325fc8e21cd680b2bd82156b50506bd4	6ad107b9-fea0-4e70-ba79-4e2e7a93dacb	MOBILE	2026-07-03 08:10:36.529	\N	2026-07-02 08:10:36.53
cmr37q698004jw8yoc1pis211	cmr0gdhs5005iw8g0cqf5tgmo	7d8d934b81c2ed4321205968475fcba718f8155c86a090c958c8855a0612f6aa	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 07:58:30.187	2026-07-02 08:15:09.566	2026-07-02 07:58:30.188
cmr38bldy000zw896o3qt0c1t	cmr0gdhs5005iw8g0cqf5tgmo	9ea92b704dcca98c4895cd664fb80a91a3549cafa05b09db8706580ad48983db	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 08:15:09.574	2026-07-02 08:30:03.201	2026-07-02 08:15:09.575
cmr38uqx100b9w896umt014em	cmr0gdhs5005iw8g0cqf5tgmo	6cc2537937c49b9828323cd962aa892f4237cfb213b11d5298571d1bd7e3d0bc	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 08:30:03.204	2026-07-02 08:44:36.28	2026-07-02 08:30:03.205
cmr39dglz00gww896snfd7j15	cmr0gdhs5005iw8g0cqf5tgmo	c407fcf2fd51cafca85d75d57acc5447e79e8ffdd2abee9015f6118b644848a2	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 08:44:36.286	2026-07-02 09:09:53.359	2026-07-02 08:44:36.311
cmr3a9z6i00hiw896owhi5f58	cmr0gdhs5005iw8g0cqf5tgmo	48702350a7992455ae56deba82961324fae7577bd5e5cb37efc2ae3c99fc8bf6	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 09:09:53.369	2026-07-02 09:24:38.578	2026-07-02 09:09:53.37
cmr3asy7t002rw820fg2m1o7s	cmr0gdhs5005iw8g0cqf5tgmo	a6a5bf3ad41b2cb110da91f24355e3541bfdcf23ff7b748baedc854e1d4fee59	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 09:24:38.583	2026-07-02 09:39:22.571	2026-07-02 09:24:38.585
cmr3bbwbh003fw8ufrm7lbb7y	cmr0gdhs5005iw8g0cqf5tgmo	bbdf88e9527b7b16c418324f6d97a4b542bb0ad6e7722570fde801383434b5c6	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 09:39:22.589	2026-07-02 10:00:02.54	2026-07-02 09:39:22.59
cmr3c2h2z00hbw8ufvn7639m4	cmr0gdhs5005iw8g0cqf5tgmo	9c5da5a3a2df018bb0f72ecf3c247ee3fb1bb53041b22b959896dd8ad9e3843b	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 10:00:02.554	2026-07-02 10:16:14.017	2026-07-02 10:00:02.555
cmr3cnaod00qfw8ufs0ow5ajp	cmr0gdhs5005iw8g0cqf5tgmo	b4e1b139004e043babc4325ed51324a2188e00b1e953743a17289c69c3487fc8	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 10:16:14.029	2026-07-02 10:31:53.357	2026-07-02 10:16:14.03
cmr3d7fgy0003w8v3mbo4osfb	cmr0gdhs5005iw8g0cqf5tgmo	49ed8a23e4ef57abaf4d0af5aa9f65d8d67a9d37bd075bcc90ff78c6ab016d8a	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 10:31:53.361	2026-07-02 10:46:23.531	2026-07-02 10:31:53.362
cmr3dq2wd00f7w87pmv5qwzdd	cmr0gdhs5005iw8g0cqf5tgmo	77aa17ab1f8383eef6d1139337f05313b15b62f1a2ea72886194e38de635cd7a	b8f71bd4-b931-4f14-a725-a862f5bc5f04	MOBILE	2026-07-05 10:46:23.533	\N	2026-07-02 10:46:23.534
cmr5t2drb0003w897uua0uufe	cmr0gdhs5005iw8g0cqf5tgmo	34f0b5e9d7d90d4b5d7effe80d1a5f2106fdadc42c0021d518ce61d9db0f09d5	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 03:31:24.07	2026-07-04 03:46:32.593	2026-07-04 03:31:24.071
cmr5tlus500ccw8ohg6w78wrq	cmr0gdhs5005iw8g0cqf5tgmo	f92d0caa7df64c63c87291e3727fdcf7c7abf27fd4d03c39c945d8672435fcbb	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 03:46:32.596	2026-07-04 04:01:37.788	2026-07-04 03:46:32.597
cmr5u598j00dlw8oh3qy3ycvw	cmr0gdhs5005iw8g0cqf5tgmo	5cb589c1572e7982e2f00d8ac6bbd6f4382f7b93618c064f3e6a78ce82c5ba0f	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 04:01:37.795	2026-07-04 04:16:38.303	2026-07-04 04:01:37.795
cmr5uok2z003ow83rg0xkg3tv	cmr0gdhs5005iw8g0cqf5tgmo	5db5f5bfcaa4789dfcc7e11e1995ff02e424ab04e03247ea6552058a748dd15d	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 04:16:38.314	2026-07-04 04:31:37.035	2026-07-04 04:16:38.315
cmr5v7tk6008nw83rc5n96sgg	cmr0gdhs5005iw8g0cqf5tgmo	f49c509c6e99c9cfa26adc9ee7f0669bdf3ec7894ab4f16381305c5a9332d037	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 04:31:37.06	2026-07-04 04:46:43.815	2026-07-04 04:31:37.062
cmr5vr98300adw83rc615265a	cmr0gdhs5005iw8g0cqf5tgmo	27bb82c7c6da29bfe419d8e0f3741e0409d0279883bf847a2fe324bcbdef57f2	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 04:46:43.827	2026-07-04 05:03:19.63	2026-07-04 04:46:43.827
cmr5wclli00c9w83rmiw22bm8	cmr0gdhs5005iw8g0cqf5tgmo	8f4b5559776e543201e3f9e1ee0aaff73363a0f71263b91602d3276c210b2f36	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 05:03:19.637	2026-07-04 05:26:14.47	2026-07-04 05:03:19.638
cmr5x62ff00ecw83r4q5fl271	cmr0gdhs5005iw8g0cqf5tgmo	3202689708547e4b0b9072772804998e3f82b1d91ec1ca5be106b4656ad66b92	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 05:26:14.474	2026-07-04 05:41:39.291	2026-07-04 05:26:14.475
cmr5xpw1000f8w83rjewgdsf8	cmr0gdhs5005iw8g0cqf5tgmo	c5e520f1aa549dba921cbe67c274eec38be2a9bf150f8e99401a9f9277ae57da	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 05:41:39.299	2026-07-04 08:53:46.058	2026-07-04 05:41:39.3
cmr64ky4u0003w8b414mf336u	cmr0gdhs5005iw8g0cqf5tgmo	a37175e7d9d3479c96b8d8cea862cb0890582635d4fe903848494a22d1ecf441	dc0a6fb2-2c21-4b0a-8a7b-c24ac87ab7f4	MOBILE	2026-07-07 08:53:46.062	\N	2026-07-04 08:53:46.063
cmr64wrxq0003w8jf9f0eq9sa	cmr0gdhs5005iw8g0cqf5tgmo	3f3e0c90e259a5f53a37e63b19cd5b221290fe2dcc712ef6e0526c7a017435de	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 09:02:57.902	2026-07-04 09:24:54.06	2026-07-04 09:02:57.902
cmr65ozhv002rw8jf5yamt3yb	cmr0gdhs5005iw8g0cqf5tgmo	811a64488425f06444ab20de614a444f3a7cf3dd7b247f90c7cacf157decd8c4	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 09:24:54.066	2026-07-04 09:40:27.862	2026-07-04 09:24:54.067
cmr66900u006pw8jfrvtz3hxf	cmr0gdhs5005iw8g0cqf5tgmo	8d95a3bdbd4d5b0d7e0f6b1ccdbcd4e0a0c806e24c155c8fc8cb5834a0ced43d	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 09:40:27.869	2026-07-04 09:55:13.428	2026-07-04 09:40:27.87
cmr66rzbv00anw8jf6f8eqert	cmr0gdhs5005iw8g0cqf5tgmo	b589830b6c6cd1e318b19e89a2359bbccbfbfb6292e866bcd36ad44d164e449a	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 09:55:13.434	2026-07-04 10:11:04.206	2026-07-04 09:55:13.436
cmr67ccyw00evw8jft8dsx7mk	cmr0gdhs5005iw8g0cqf5tgmo	42dddd5d2278e1e90c8f688da1a1ffa63477b5b0296333c499a18322feb4e2c9	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 10:11:04.232	2026-07-04 10:28:13.716	2026-07-04 10:11:04.233
cmr67yfbv00juw8jfeh8seil0	cmr0gdhs5005iw8g0cqf5tgmo	c029b470a80c9e35f3753f4dfc6870cc481bc2bbe2a5f7910b3118538eadb28e	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 10:28:13.722	2026-07-04 10:43:38.299	2026-07-04 10:28:13.724
cmr68i8qz00lpw8jf7vyze5hb	cmr0gdhs5005iw8g0cqf5tgmo	99ebbd96ac685f747a87385ec9caf0e35f72b00934b01b09b56f7aeaa3a4c2d6	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 10:43:38.315	2026-07-04 10:58:18.852	2026-07-04 10:43:38.316
cmr691485000tw8l3clig39xb	cmr0gdhs5005iw8g0cqf5tgmo	0dd48b463909553ae7636ceab4b7bd4cce5d36b0f9da53b5653ab60372c673d9	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 10:58:18.915	2026-07-04 11:15:31.805	2026-07-04 10:58:18.917
cmr69n97q0003w86scawa6e44	cmr0gdhs5005iw8g0cqf5tgmo	0668c1ace4da8ede07dc2e492556f1bff080fa37ed39a7836bed75c7adad7e8f	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 11:15:31.813	2026-07-04 11:31:09.386	2026-07-04 11:15:31.814
cmr6a7cnm004vw86sem9g7wrz	cmr0gdhs5005iw8g0cqf5tgmo	c8b87ba97ec67f52a90b69e236476bfd7629938b8a8919db622bdae1efbf2a40	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 11:31:09.393	2026-07-04 11:45:43.552	2026-07-04 11:31:09.395
cmr6aq36200bnw86slp154fzj	cmr0gdhs5005iw8g0cqf5tgmo	a8f0b13a2ba4769ac8b0cd8f0def41cd9fcfa0a45d192fa20e925a30285c4b80	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 11:45:43.561	2026-07-04 12:09:45.734	2026-07-04 11:45:43.562
cmr6bkzyk002bw8mp4d8h3qpa	cmr0gdhs5005iw8g0cqf5tgmo	1703d5ede5999c7d1d4b8ad6371e1fbe8a5ec1ddb4b07acc5a823d02ac5a72c6	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-07 12:09:45.74	2026-07-05 03:17:47.589	2026-07-04 12:09:45.741
cmr780qfl006hw8mp5wdqnsr0	cmr0gdhs5005iw8g0cqf5tgmo	6132acc9c5b36eac8564e7a1bf1c37dccfdb12371fee02086fc69e8be11cbf73	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 03:17:47.6	2026-07-05 03:33:23.825	2026-07-05 03:17:47.601
cmr78kstx007rw8mpko4397l2	cmr0gdhs5005iw8g0cqf5tgmo	fd1abf4a55190dcfb3f5548e66f465285ff3bb32ebbde91c44e15e8fb01f0d3c	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 03:33:23.829	2026-07-05 03:49:31.943	2026-07-05 03:33:23.83
cmr795jue00odw8mp2pfpw4za	cmr0gdhs5005iw8g0cqf5tgmo	b59f7b7e598382799657b9e603cdf8dce74265b93b98b4149e03cb55d34bd0c5	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 03:49:31.958	2026-07-05 04:04:04.274	2026-07-05 03:49:31.959
cmr79o8xj00wzw8mpgw4p8s65	cmr0gdhs5005iw8g0cqf5tgmo	cdac9f4d0f6b1e058ea37eadc31bce63ae93bf18af8591d1abdaecb222e29c88	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 04:04:04.278	2026-07-05 04:18:35.465	2026-07-05 04:04:04.279
cmr7a6x5b01e2w8mpj4ssfu2q	cmr0gdhs5005iw8g0cqf5tgmo	c08014334c658a305350724cf575429efcc7341e282cd7e290add3d261c9a131	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 04:18:35.469	2026-07-05 04:33:25.947	2026-07-05 04:18:35.471
cmr7aq09001ssw8mpnrtbmuzl	cmr0gdhs5005iw8g0cqf5tgmo	49f1bf151669ada04c6b621a0b9e301d881549333e1acf79a02d5793d61171b9	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 04:33:25.955	2026-07-05 04:47:57.292	2026-07-05 04:33:25.956
cmr7b8okv0238w8mpx4z88sxn	cmr0gdhs5005iw8g0cqf5tgmo	3607df154d3813c72f7b9781847af8df9eb9306836c5acfb82dda5fba4e4be85	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 04:47:57.294	2026-07-05 05:02:28.613	2026-07-05 04:47:57.295
cmr7brcw8028hw8mp2qbt6x0n	cmr0gdhs5005iw8g0cqf5tgmo	8e711ca77fc82f5420a83a22b75f2cecfc7316c343a453b5d329a64bac299003	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 05:02:28.615	2026-07-05 05:17:10.079	2026-07-05 05:02:28.616
cmr7ca91i02acw8mpaoutbfwr	cmr0gdhs5005iw8g0cqf5tgmo	9822e7fbb2aa2381976b30330eba0be366cca6db809db9c9d5c0ae46692885f1	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 05:17:10.085	2026-07-05 05:31:53.102	2026-07-05 05:17:10.086
cmr7ct6dt006iw8rfshv4lczz	cmr0gdhs5005iw8g0cqf5tgmo	8b041092cd0d2378d191b4dda1d7f6dd965c07b7a1e93bc23bef715f2c673bbe	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 05:31:53.104	2026-07-05 05:46:27.196	2026-07-05 05:31:53.105
cmr7dbwu500dtw8rf7569gb2j	cmr0gdhs5005iw8g0cqf5tgmo	178def0058afd5c4be56b9809bf74b83d9d8fa794206bb3a4ef80a6d23572cf5	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 05:46:27.197	2026-07-05 06:01:03.629	2026-07-05 05:46:27.198
cmr7dup3l00vqw8rfk6lrp8kg	cmr0gdhs5005iw8g0cqf5tgmo	3a587c8a0065eb1f6b7a1956647df7a9d07c8375329b89097ec1691926fc43cd	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 06:01:03.633	2026-07-05 06:21:38.905	2026-07-05 06:01:03.634
cmr7el690004dw8w9p7wb39h1	cmr0gdhs5005iw8g0cqf5tgmo	df40070d3dc96bfe9418cf023a2aad6125369118cc9dfcb326b813d5a9c7741d	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 06:21:38.915	2026-07-05 06:40:45.463	2026-07-05 06:21:38.917
cmr7f9qxw007iw8l6h3vj89io	cmr0gdhs5005iw8g0cqf5tgmo	5f9fea98e3e2a119f531918d3f81831e4f987342074623dadcfe5819b4a623a5	2b4b7ed7-bc67-4420-addc-95c1469f35eb	MOBILE	2026-07-08 06:40:45.474	\N	2026-07-05 06:40:45.476
\.


--
-- Data for Name: salesman_permissions; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.salesman_permissions (id, shop_user_id, can_sell, can_view_stock, can_view_reports, can_change_price, can_collect_due, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: shop_charges; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_charges (id, shop_id, name, amount, type, is_active, created_at, updated_at) FROM stdin;
cmr675k7100drw8jf895zin91	cmr0gdhu7005kw8g06c2lngfc	ডেলিভারি চার্জ	100.00	FIXED	t	2026-07-04 10:05:47.005	2026-07-04 10:05:47.005
\.


--
-- Data for Name: shop_inventory_settings; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_inventory_settings (id, shop_id, mode, created_at, updated_at, allow_negative_stock, auto_low_stock_alert, demand_based_reorder, low_stock_default, low_stock_grocery, reduce_stock_on_sale, require_bin_assignment, show_bin_during_sale, stock_method, manual_stock_approval) FROM stdin;
cmqtemora0023lxj6ece6c60o	cmqtek0us0002lxj6zzrnqalp	GENERAL	2026-06-25 11:14:03.094	2026-06-27 05:44:15.243	f	t	f	10	5	t	f	t	FIFO	f
cmr0ggqrz005tw8g000sbmkh4	cmr0gdhu7005kw8g06c2lngfc	RACK	2026-06-30 09:39:48.237	2026-07-04 11:07:38.349	f	f	f	10	5	t	f	t	LIFO	f
\.


--
-- Data for Name: shop_products; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_products (id, shop_id, master_product_id, opening_stock, sale_price, created_at, updated_at, approval_request_id, local_barcode, local_brand, local_category, local_name, local_picture_url, local_unit, low_stock_limit, purchase_price, source) FROM stdin;
cmqtemkvi000dlxj6egibvrra	cmqtek0us0002lxj6zzrnqalp	cmqnc6u0x000plxvskd56o9d9	0.000	125.00	2026-06-25 11:13:58.062	2026-06-25 11:13:58.321	\N	\N	\N	\N	\N	\N	\N	10.000	120.00	MASTER
cmqtemkwj000llxj6u4ikxoib	cmqtek0us0002lxj6zzrnqalp	cmqnq97tc000zlx4up9ymaj58	30.000	15.00	2026-06-25 11:13:58.099	2026-06-25 11:13:58.364	\N	\N	\N	\N	\N	\N	\N	10.000	15.00	MASTER
cmqtemkwt000nlxj6x6m0z4ix	cmqtek0us0002lxj6zzrnqalp	cmqnq97ut0013lx4ueqfkijq8	25.000	20.00	2026-06-25 11:13:58.109	2026-06-25 11:13:58.463	\N	\N	\N	\N	\N	\N	\N	10.000	20.00	MASTER
cmqtemkx2000plxj6s0yphyc6	cmqtek0us0002lxj6zzrnqalp	cmqnq97vj0017lx4uc77sbdn6	30.000	30.00	2026-06-25 11:13:58.118	2026-06-25 11:13:58.687	\N	\N	\N	\N	\N	\N	\N	10.000	30.00	MASTER
cmqtemkxa000rlxj6p24mwzak	cmqtek0us0002lxj6zzrnqalp	cmqnq97wg001blx4ueh3hh29z	100.000	60.00	2026-06-25 11:13:58.126	2026-06-25 11:13:58.735	\N	\N	\N	\N	\N	\N	\N	10.000	55.00	MASTER
cmqtemkvs000flxj6q11pbbc9	cmqtek0us0002lxj6zzrnqalp	cmqnq97j1000flx4uexre8xhw	60.000	15.00	2026-06-25 11:13:58.072	2026-06-25 11:13:58.78	\N	\N	\N	\N	\N	\N	\N	10.000	15.00	MASTER
cmqtemkwa000jlxj63ei9ojlv	cmqtek0us0002lxj6zzrnqalp	cmqnq97r6000vlx4usqsalrhi	15.000	115.00	2026-06-25 11:13:58.09	2026-06-25 11:13:58.822	\N	\N	\N	\N	\N	\N	\N	10.000	105.00	MASTER
cmqtemkw1000hlxj6bdo0kkdu	cmqtek0us0002lxj6zzrnqalp	cmqnq97kz000jlx4uxdu3s9ws	20.000	20.00	2026-06-25 11:13:58.081	2026-06-25 11:13:58.865	\N	\N	\N	\N	\N	\N	\N	10.000	20.00	MASTER
cmqtemkxj000tlxj61hn6wxyw	cmqtek0us0002lxj6zzrnqalp	cmqnq97x4001flx4upjb4nzcm	20.000	115.00	2026-06-25 11:13:58.134	2026-06-30 09:00:18.051	\N	\N	\N	\N	\N	\N	\N	5.000	105.00	MASTER
cmqtemkue000blxj65belg6sa	cmqtek0us0002lxj6zzrnqalp	cmq3qiahw0005lxru9rwwztl9	51.000	130.00	2026-06-25 11:13:58.022	2026-06-30 09:02:32.45	\N	\N	\N	\N	\N	\N	\N	10.000	126.00	MASTER
cmr38u30s00b3w896hn7pa13i	cmr0gdhu7005kw8g06c2lngfc	cmr38uqzi00bdw896uur2erb3	7.000	200.00	2026-07-02 08:29:32.236	2026-07-02 08:30:03.758	cmr38u2xq00b1w896xnfryn6k	111111	local	তেল-মসলা	fahad	\N	কেজি	5.000	150.00	MASTER
cmr392nse00d0w896nuguvfvg	cmr0gdhu7005kw8g06c2lngfc	cmr394f0b00dgw89676gha1f1	1968.000	150.00	2026-07-02 08:36:12.399	2026-07-04 10:16:50.016	cmr392npw00cyw896k6i0vcn1	111222	local	চাল-ডাল	add ponno	\N	কেজি	5.000	150.00	MASTER
cmr0j8t2l004bw8b5d1st5xb2	cmr0gdhu7005kw8g06c2lngfc	cmqnq97wg001blx4ueh3hh29z	0.000	55.00	2026-06-30 10:57:36.813	2026-07-04 04:09:03.498	\N	\N	\N	\N	\N	\N	\N	9.000	55.00	MASTER
cmr0j6qtq002nw8b5th88ylt9	cmr0gdhu7005kw8g06c2lngfc	cmqnq97n4000nlx4umqv6wqxb	14472.000	30.00	2026-06-30 10:56:00.591	2026-07-02 08:04:51.03	\N	\N	\N	\N	\N	\N	\N	0.000	30.00	MASTER
cmr0j6qto002jw8b5ohwn880s	cmr0gdhu7005kw8g06c2lngfc	cmqnq97r6000vlx4usqsalrhi	18893.000	105.00	2026-06-30 10:56:00.588	2026-07-02 08:04:51.043	\N	\N	\N	\N	\N	\N	\N	0.000	105.00	MASTER
cmr0j6qtp002lw8b5ur6xf0pr	cmr0gdhu7005kw8g06c2lngfc	cmqnq97kz000jlx4uxdu3s9ws	9.000	20.00	2026-06-30 10:56:00.59	2026-07-02 03:49:56.661	\N	\N	\N	\N	\N	\N	\N	0.000	20.00	MASTER
cmr7at3bc01wlw8mpe3gw17s5	cmr0gdhu7005kw8g06c2lngfc	cmr7au57l01xnw8mp4h6bwy62	176.000	15.00	2026-07-05 04:35:49.897	2026-07-05 06:30:50.918	cmr7at3an01wjw8mpvm0h04pj	12345432	deshit	পানীয়	Brazil	\N	কেজি	5.000	10.00	MASTER
cmr0h6wzn007qw8g0mrmpeb93	cmr0gdhu7005kw8g06c2lngfc	cmqnc6u0x000plxvskd56o9d9	144958.000	120.00	2026-06-30 10:00:09.347	2026-07-02 08:03:09.807	\N	\N	\N	\N	\N	\N	\N	0.000	120.00	MASTER
cmr2ydud7003lw8zbjngnri11	cmr0gdhu7005kw8g06c2lngfc	cmqnq97ut0013lx4ueqfkijq8	0.000	20.00	2026-07-02 03:36:58.363	2026-07-02 05:22:11.636	\N	\N	\N	\N	\N	\N	\N	0.000	20.00	MASTER
cmr0hl6tt0087w8g00hfrr71n	cmr0gdhu7005kw8g06c2lngfc	cmqnq97tc000zlx4up9ymaj58	2051.000	15.00	2026-06-30 10:11:15.281	2026-07-02 08:03:09.814	\N	\N	\N	\N	\N	\N	\N	0.000	15.00	MASTER
cmr3037gn00dmw82p9tbvxa4v	cmr0gdhu7005kw8g06c2lngfc	cmr31oafe001tw8fube0vfpyq	4916.000	40.00	2026-07-02 04:24:41.351	2026-07-02 08:05:16.719	cmr3037gb00dkw82pjqjkrtbx	000555	local	পানীয়	test	ছবি যোগ করা হয়নি	পিস	5.000	20.00	MASTER
cmr5v7to0008vw83racyeu238	cmr0gdhu7005kw8g06c2lngfc	cmr5wdq6p00ddw83rw50pbwz8	373.000	50.00	2026-07-04 04:31:37.2	2026-07-05 06:10:06.146	cmr5v7tnc008tw83rnxjd22kf	4562456345	deshit	বিস্কুট	কিটক্যাট	\N	প্যাকেট	5.000	25.00	MASTER
cmr5tj0fk00b7w8oh5ew29ywn	cmr0gdhu7005kw8g06c2lngfc	cmr5tjv3u00bdw8oh5bm4rax4	96.000	100.00	2026-07-04 03:44:19.952	2026-07-05 06:34:55.119	cmr5tj0fd00b5w8ohkb2cskre	123423432	7piece	পানীয়	7up	\N	পিস	5.000	10.00	MASTER
cmr0j7ms4003yw8b5fzt1dvrs	cmr0gdhu7005kw8g06c2lngfc	cmqnq97p4000rlx4updfrju1f	3976.000	55.00	2026-06-30 10:56:42.005	2026-07-04 03:35:05.27	\N	\N	\N	\N	\N	\N	\N	0.000	55.00	MASTER
cmr5tbl5k0077w8ohq5rhclte	cmr0gdhu7005kw8g06c2lngfc	cmr5tc8lq007dw8ohq06pd1ho	86.000	125.00	2026-07-04 03:38:33.561	2026-07-04 04:16:52.791	cmr5tbl5f0075w8ohpbg627uz	123321	PRAN	চাল-ডাল	Orange Juice 1L	\N	পিস	5.000	120.00	MASTER
cmr38l6e0006nw896x2su8dy7	cmr0gdhu7005kw8g06c2lngfc	cmr38lhjj006tw896tmrl2wl3	2994.000	100.00	2026-07-02 08:22:36.696	2026-07-04 11:06:34.432	cmr38l66a006lw896pnhxpsll	000222	local	পানীয়	sajib bbbb	\N	পিস	5.000	50.00	MASTER
cmr5tffu4009bw8ohwvaqnaho	cmr0gdhu7005kw8g06c2lngfc	cmr5tg1ne009hw8ohfuwwn9r4	43.000	50.00	2026-07-04 03:41:33.292	2026-07-05 04:19:01.013	cmr5tfftz0099w8ohgjnvvmez	23423412	PRAN	বিস্কুট	chips	\N	প্যাকেট	5.000	10.00	MASTER
cmr3bbwe0003nw8uf9s6eckxu	cmr0gdhu7005kw8g06c2lngfc	cmr5t74c3001bw8oh2k59ek9v	3976.000	200.00	2026-07-02 09:39:22.68	2026-07-04 03:35:05.43	cmr3bbwdv003lw8ufnhb6xmgw	111223	local	তেল-মসলা	boook	\N	পিস	5.000	100.00	MASTER
cmr3a9zbe00hqw896zn9cids4	cmr0gdhu7005kw8g06c2lngfc	cmr5t7422000bw8oh1hhykio7	266.000	200.00	2026-07-02 09:09:53.547	2026-07-04 03:35:05.531	cmr3a9zbb00how896r72c8kor	1112222	deshit	বিস্কুট	sakib	\N	কেজি	5.000	100.00	MASTER
cmr0i27dr008nw8g0nizlcekx	cmr0gdhu7005kw8g06c2lngfc	cmqnq97x4001flx4upjb4nzcm	2137.000	105.00	2026-06-30 10:24:29.152	2026-07-04 03:37:24.291	\N	\N	\N	\N	\N	\N	\N	0.000	105.00	MASTER
cmr0j6qtb002hw8b549panick	cmr0gdhu7005kw8g06c2lngfc	cmq3qiahw0005lxru9rwwztl9	1339.000	125.00	2026-06-30 10:56:00.575	2026-07-04 03:37:24.303	\N	\N	\N	\N	\N	\N	\N	0.000	125.00	MASTER
cmr0h6wz9007ow8g0eeb1xr8f	cmr0gdhu7005kw8g06c2lngfc	cmqnq97vj0017lx4uc77sbdn6	1067.000	30.00	2026-06-30 10:00:09.332	2026-07-05 06:00:34.95	\N	\N	\N	\N	\N	\N	\N	0.000	30.00	MASTER
cmr7adrd801lqw8mp9ibm33op	cmr0gdhu7005kw8g06c2lngfc	cmr7ahth001pgw8mp81w4l2i8	97.000	100.00	2026-07-05 04:23:54.572	2026-07-05 05:45:55.125	cmr7adrcf01low8mp306gsly2	5342452	deshit	বিস্কুট	chocolate	\N	প্যাকেট	5.000	50.00	MASTER
\.


--
-- Data for Name: shop_receipt_settings; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_receipt_settings (id, shop_id, printer_type, paper_size, show_logo, show_address, show_phone, show_vat_info, header_text, footer_text, created_at, updated_at) FROM stdin;
cmr65rlc6003hw8jfiyfea3dt	cmr0gdhu7005kw8g06c2lngfc	\N	\N	f	t	t	t	\N	\N	2026-07-04 09:26:55.686	2026-07-04 11:37:41.809
\.


--
-- Data for Name: shop_taxes; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_taxes (id, shop_id, name, rate, type, is_active, created_at, updated_at) FROM stdin;
cmr675rct00dvw8jf5i2amiv2	cmr0gdhu7005kw8g06c2lngfc	ভ্যাট	5.00	PERCENTAGE	t	2026-07-04 10:05:56.286	2026-07-04 10:05:56.286
\.


--
-- Data for Name: shop_users; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shop_users (id, shop_id, user_id, role, is_billable, created_at) FROM stdin;
cmqtek0vu0004lxj6ir1h1l2j	cmqtek0us0002lxj6zzrnqalp	cmqtek0uk0000lxj659fzko6g	SHOP_OWNER	t	2026-06-25 11:11:58.842
cmr0gdhum005mw8g09edklejc	cmr0gdhu7005kw8g06c2lngfc	cmr0gdhs5005iw8g0cqf5tgmo	SHOP_OWNER	t	2026-06-30 09:37:16.703
\.


--
-- Data for Name: shops; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.shops (id, shop_name, owner_user_id, phone, email, address, district, status, created_at, updated_at, area, business_type, closing_time, logo_url, opening_time, postal_code, tin_no, trade_license_no, vat_reg_no, weekly_holiday, shop_code) FROM stdin;
cmqtek0us0002lxj6zzrnqalp	Fahad's Store	cmqtek0uk0000lxj659fzko6g	01880561928	\N	Banasree,Dhaka	\N	ACTIVE	2026-06-25 11:11:58.804	2026-06-28 08:46:19.285	Lat 23.757738, Lng 90.366828	অন্যান্য	\N	http://192.168.0.139:4000/uploads/shopprofilelogo/1782636379281-c299104b-d7a5-4531-b247-da1162b313c8.jpg	\N	\N	\N	\N	\N	\N	FAHADS918786
cmr0gdhu7005kw8g06c2lngfc	deshit-bd	cmr0gdhs5005iw8g0cqf5tgmo	01762161370	\N	dhaka bd	\N	ACTIVE	2026-06-30 09:37:16.686	2026-07-04 11:37:41.804	Lat 37.785834, Lng -122.406417	মুদি দোকান	\N	\N	\N	\N	\N	\N	\N	\N	DESHIT236606
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.stock_movements (id, shop_id, shop_product_id, master_product_id, movement_type, quantity_delta, stock_before, stock_after, purchase_price, sale_price, unit_price, reference_type, reference_id, reference_no, note, metadata, created_by_user_id, created_at) FROM stdin;
cmqw3owlc002alxugwfdzydit	cmqtek0us0002lxj6zzrnqalp	cmqtemkxj000tlxj61hn6wxyw	cmqnq97x4001flx4upjb4nzcm	SALE	-2.000	25.000	23.000	105.00	115.00	115.00	SALE	cmqw3owkm0027lxugwbjjro4j	order-1782549068656150	Stock reduced from sale. | Batch 1	null	cmqtek0uk0000lxj659fzko6g	2026-06-27 08:31:09.312
cmqw4fhlv003hlxugjdyp5foy	cmqtek0us0002lxj6zzrnqalp	cmqtemkue000blxj65belg6sa	cmq3qiahw0005lxru9rwwztl9	MANUAL_ADD	50.000	0.000	50.000	125.00	130.00	\N	INITIAL_STOCK	\N	\N	প্রারম্ভিক স্টক (Initial Stock)	\N	\N	2026-06-25 11:13:58.022
cmqw4fpl0003mlxugf5ju50vu	cmqtek0us0002lxj6zzrnqalp	cmqtemkxj000tlxj61hn6wxyw	cmqnq97x4001flx4upjb4nzcm	MANUAL_ADD	25.000	0.000	25.000	105.00	115.00	\N	INITIAL_STOCK	\N	\N	প্রারম্ভিক স্টক (Initial Stock)	\N	\N	2026-06-27 08:30:09.312
cmqxfmeo9004glxgfth6n2lao	cmqtek0us0002lxj6zzrnqalp	cmqtemkxj000tlxj61hn6wxyw	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	23.000	22.000	105.00	115.00	115.00	SALE	cmqxfmenl004dlxgfzegearqc	order-1782629573050284	Stock reduced from sale. | Batch 1	null	cmqtek0uk0000lxj659fzko6g	2026-06-28 06:52:54.346
cmqxiie6c0058lx0breraw5wk	cmqtek0us0002lxj6zzrnqalp	cmqtemkxj000tlxj61hn6wxyw	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	22.000	21.000	105.00	115.00	115.00	SALE	cmqxiie5p0055lx0b1ofzi029	order-1782634425172502	Stock reduced from sale. | Batch 1	null	cmqtek0uk0000lxj659fzko6g	2026-06-28 08:13:45.924
cmr0f1xb6002uw8g0tmnonghb	cmqtek0us0002lxj6zzrnqalp	cmqtemkxj000tlxj61hn6wxyw	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	21.000	20.000	105.00	115.00	115.00	SALE	cmr0f1xay002rw8g01c2ysu5o	order-1782810016873499	Stock reduced from sale. | Batch 1	null	cmqtek0uk0000lxj659fzko6g	2026-06-30 09:00:17.25
cmr0f4tmr004lw8g0bit7kv0k	cmqtek0us0002lxj6zzrnqalp	cmqtemkue000blxj65belg6sa	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	50.000	51.000	126.00	130.00	126.00	PURCHASE	cmr0f4037004aw8g06jezalcn	\N	Stock received from purchase flow.	null	cmqtek0uk0000lxj659fzko6g	2026-06-30 09:02:32.452
cmr0j5bjf0009w8b5h14u9lyy	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	0.000	1.000	30.00	30.00	30.00	PURCHASE	cmr0h6wzr007sw8g0tbj8zx72	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.123
cmr0j5bk0000ew8b55wcqet7m	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	1.000	0.000	1.000	120.00	120.00	120.00	PURCHASE	cmr0h6wzr007sw8g0tbj8zx72	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.144
cmr0j5bpg000qw8b53nbosh0p	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	11.000	1.000	12.000	120.00	120.00	120.00	PURCHASE	cmr0hl6u10089w8g0eawjuc78	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.34
cmr0j5bpp000vw8b5lfluh5um	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	11.000	0.000	11.000	15.00	15.00	15.00	PURCHASE	cmr0hl6u10089w8g0eawjuc78	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.349
cmr0j5bqi0019w8b59eraopn7	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	2.000	1.000	3.000	30.00	30.00	30.00	PURCHASE	cmr0i27er008pw8g0shrocgbl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.378
cmr0j5bqm001cw8b5pqa78i0t	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	6.000	12.000	18.000	120.00	120.00	120.00	PURCHASE	cmr0i27er008pw8g0shrocgbl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.383
cmr0j5bqr001fw8b5whlfv8pi	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	700.000	11.000	711.000	15.00	15.00	15.00	PURCHASE	cmr0i27er008pw8g0shrocgbl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.388
cmr0j5bqx001kw8b5ayu3eg37	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	900.000	0.000	900.000	105.00	105.00	105.00	PURCHASE	cmr0i27er008pw8g0shrocgbl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.393
cmr0j5brs001ww8b5y6cl2g7n	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	400.000	18.000	418.000	120.00	120.00	120.00	PURCHASE	cmr0ic37l0096w8g0aojmgem0	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.424
cmr0j5brv001zw8b505zf3wk2	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	900.000	3.000	903.000	30.00	30.00	30.00	PURCHASE	cmr0ic37l0096w8g0aojmgem0	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:54:54.427
cmr0j6qu6002zw8b59web9hc9	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	155.000	903.000	1058.000	30.00	30.00	30.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.606
cmr0j6qua0032w8b56i1sdlma	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	144444.000	418.000	144862.000	120.00	120.00	120.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.611
cmr0j6quh0035w8b5d61ek3an	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	1333.000	711.000	2044.000	15.00	15.00	15.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.618
cmr0j6qul0038w8b568l6vpdh	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1222.000	900.000	2122.000	105.00	105.00	105.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.622
cmr0j6qur003dw8b50aezlq7q	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1333.000	0.000	1333.000	125.00	\N	125.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.628
cmr0j6qv1003iw8b5yvxm919h	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	PURCHASE	18888.000	0.000	18888.000	105.00	\N	105.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.637
cmr0j6qv6003nw8b56rimd21p	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtp002lw8b5ur6xf0pr	cmqnq97kz000jlx4uxdu3s9ws	PURCHASE	1.000	0.000	1.000	20.00	\N	20.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.642
cmr0j6qv9003sw8b5emuuljyp	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	PURCHASE	14444.000	0.000	14444.000	30.00	\N	30.00	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:00.646
cmr0j7mt10045w8b5pt4cbam7	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	PURCHASE	4000.000	0.000	4000.000	55.00	\N	55.00	PURCHASE	cmr0j7msc0040w8b513bzlq5a	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:56:42.038
cmr0j8t31004iw8b5936w8vml	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	PURCHASE	14.000	0.000	14.000	55.00	\N	55.00	PURCHASE	cmr0j8t2r004dw8b5coiu617y	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 10:57:36.829
cmr0jdqeo0008w8s3bk71nnbm	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	PURCHASE	30.000	14444.000	14474.000	30.00	30.00	30.00	PURCHASE	cmr0jdhky0003w8s36i2kybhl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:01:26.64
cmr0jg0mp000pw8s324md06uz	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1333.000	1334.000	125.00	125.00	125.00	PURCHASE	cmr0jfpcu000kw8s3ksa9ty62	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:03:13.202
cmr0jig190019w8s39v2jdkyx	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-2.000	4000.000	3998.000	55.00	60.00	60.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.477
cmr0jig1c001aw8s31deex26p	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	SALE	-1.000	14474.000	14473.000	30.00	30.00	30.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.481
cmr0jig1e001bw8s3uze8p2vi	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtp002lw8b5ur6xf0pr	cmqnq97kz000jlx4uxdu3s9ws	SALE	-1.000	1.000	0.000	20.00	20.00	20.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.482
cmr0jig1e001cw8s37glo3o6l	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	SALE	-1.000	18888.000	18887.000	105.00	115.00	115.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.483
cmr0jig1f001dw8s3ejsa55t0	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	SALE	-1.000	144862.000	144861.000	120.00	120.00	120.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.484
cmr0jig1g001ew8s35dfu3ijc	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	14.000	13.000	55.00	60.00	60.00	SALE	cmr0jig0y0011w8s3kobfd8t8	order-1782817506202494	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-06-30 11:05:06.484
cmr1kym7o000aw8joob3u9fki	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE_RETURN	-1.000	1334.000	1333.000	125.00	125.00	125.00	PURCHASE_RETURN	cmr1kym6z0007w8jo2h7kfmi1	\N	raja	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:26.773
cmr1kymeg000hw8jofc8eb87y	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	PURCHASE_RETURN	-1.000	3998.000	3997.000	55.00	60.00	55.00	PURCHASE_RETURN	cmr1kymc9000ew8jouyyodbym	\N	emni	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:27.017
cmr1kymfa000pw8jo324zczqu	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE_RETURN	-4.000	1058.000	1054.000	30.00	30.00	30.00	PURCHASE_RETURN	cmr1kymf4000lw8jozztv6lu3	\N	emni	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:27.046
cmr1kymfb000qw8johnxm957y	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE_RETURN	-2.000	144861.000	144859.000	120.00	120.00	120.00	PURCHASE_RETURN	cmr1kymf4000lw8jozztv6lu3	\N	emni	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:33:27.048
cmr1l09n8001dw8jo8s7jcypj	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	5.000	2044.000	2049.000	15.00	15.00	15.00	PURCHASE	cmr1kzx3o0012w8joeetozhlr	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:34:43.797
cmr1l09ns001gw8jobfwgum3x	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	6.000	2122.000	2128.000	105.00	105.00	105.00	PURCHASE	cmr1kzx3o0012w8joeetozhlr	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:34:43.816
cmr1l09nz001jw8jog5pwt58o	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	5.000	1333.000	1338.000	125.00	125.00	125.00	PURCHASE	cmr1kzx3o0012w8joeetozhlr	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:34:43.823
cmr1l09o5001mw8jomiu7bkrf	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	PURCHASE	8.000	18887.000	18895.000	105.00	105.00	105.00	PURCHASE	cmr1kzx3o0012w8joeetozhlr	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 04:34:43.829
cmr1no4sz000aw8xnqnma2rf1	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	SALE	-1.000	14473.000	14472.000	30.00	30.00	30.00	SALE	cmr1no4sf0005w8xngt8jjzub	order-1782884956237169	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 05:49:16.499
cmr1no4u8000bw8xnqbpo92zk	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	SALE	-1.000	18895.000	18894.000	105.00	105.00	105.00	SALE	cmr1no4sf0005w8xngt8jjzub	order-1782884956237169	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 05:49:16.544
cmr1no4u9000cw8xn471vzywd	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	SALE	-1.000	1338.000	1337.000	125.00	125.00	125.00	SALE	cmr1no4sf0005w8xngt8jjzub	order-1782884956237169	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 05:49:16.546
cmr1nslh2000ow8xngd96zk73	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	13.000	12.000	55.00	60.00	60.00	SALE	cmr1nslf7000kw8xnal3umoza	order-1782885164491997	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 05:52:44.726
cmr1nslh6000pw8xnr1vff0sb	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3997.000	3996.000	55.00	60.00	60.00	SALE	cmr1nslf7000kw8xnal3umoza	order-1782885164491997	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 05:52:44.731
cmr1o9zz90013w8xne9ygm8be	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	12.000	11.000	55.00	60.00	60.00	SALE	cmr1o9zyu000zw8xncty4nm7k	order-1782885976431074	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:06:16.676
cmr1o9zzd0014w8xn3u1sijcc	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3996.000	3995.000	55.00	60.00	60.00	SALE	cmr1o9zyu000zw8xncty4nm7k	order-1782885976431074	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:06:16.681
cmr1oh70h001fw8xn3z5sfih9	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	11.000	10.000	55.00	60.00	60.00	SALE	cmr1oh6zz0018w8xnimfbggnk	order-1782886311925459	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:11:52.385
cmr1oh70m001gw8xnfm1vq8d8	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3995.000	3994.000	55.00	60.00	60.00	SALE	cmr1oh6zz0018w8xnimfbggnk	order-1782886311925459	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:11:52.391
cmr1oh70n001hw8xnxktdow96	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	2128.000	2127.000	105.00	105.00	105.00	SALE	cmr1oh6zz0018w8xnimfbggnk	order-1782886311925459	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:11:52.392
cmr1oh70o001iw8xnbqabemoc	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	SALE	-1.000	2049.000	2048.000	15.00	15.00	15.00	SALE	cmr1oh6zz0018w8xnimfbggnk	order-1782886311925459	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:11:52.392
cmr1oh70p001jw8xnovdmq0cf	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	SALE	-1.000	144859.000	144858.000	120.00	120.00	120.00	SALE	cmr1oh6zz0018w8xnimfbggnk	order-1782886311925459	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:11:52.393
cmr1oidmf001uw8xnlgvzng56	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	2127.000	2126.000	105.00	105.00	105.00	SALE	cmr1oidm6001qw8xngi8dedjm	order-1782886367340247	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:12:47.607
cmr1oidmk001vw8xnkrte0iw1	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	SALE	-1.000	2048.000	2047.000	15.00	15.00	15.00	SALE	cmr1oidm6001qw8xngi8dedjm	order-1782886367340247	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:12:47.612
cmr1okhan0026w8xnyvebolib	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	10.000	9.000	55.00	60.00	60.00	SALE	cmr1okhaa0022w8xn2jd7fnjv	order-1782886464811078	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:14:25.679
cmr1okhb60027w8xn0k65yxfw	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3994.000	3993.000	55.00	60.00	60.00	SALE	cmr1okhaa0022w8xn2jd7fnjv	order-1782886464811078	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:14:25.699
cmr1pebtw002vw8xn039dc2ro	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	9.000	8.000	55.00	60.00	60.00	SALE	cmr1pebtd002rw8xn1jj2kt77	order-1782887857899575	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:37:38.275
cmr1pebu2002ww8xniczs4jye	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3993.000	3992.000	55.00	60.00	60.00	SALE	cmr1pebtd002rw8xn1jj2kt77	order-1782887857899575	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:37:38.283
cmr1pfteq0039w8xn3v3bz815	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	8.000	7.000	55.00	60.00	60.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.714
cmr1pftgc003aw8xnjpm5ysas	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3992.000	3991.000	55.00	60.00	60.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.772
cmr1pftgc003bw8xnjqilk6yj	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	SALE	-1.000	14472.000	14471.000	30.00	30.00	30.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.773
cmr1pftge003cw8xniyf9cn3e	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	SALE	-1.000	18894.000	18893.000	105.00	105.00	105.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.775
cmr1pftgf003dw8xnr099tjrv	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	SALE	-1.000	1337.000	1336.000	125.00	125.00	125.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.775
cmr1pftgf003ew8xnaihjv3te	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	SALE	-1.000	1054.000	1053.000	30.00	30.00	30.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.776
cmr1pftgg003fw8xntm0di0mi	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	SALE	-1.000	144858.000	144857.000	120.00	120.00	120.00	SALE	cmr1pftau0030w8xnssm2a49w	order-1782887927325817	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:38:47.777
cmr1pio1c0041w8xnoresiv89	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	7.000	6.000	55.00	60.00	60.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.72
cmr1pio3e0042w8xnsdd7jkrw	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3991.000	3990.000	55.00	60.00	60.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.794
cmr1pio3f0043w8xnf7lonqjl	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	SALE	-1.000	144857.000	144856.000	120.00	120.00	120.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.795
cmr1pio3f0044w8xn5r37jh2i	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	SALE	-1.000	1053.000	1052.000	30.00	30.00	30.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.796
cmr1pio3g0045w8xnhdibghjm	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	SALE	-1.000	2126.000	2125.000	105.00	105.00	105.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.796
cmr1pio3g0046w8xnq92xkaud	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	SALE	-1.000	2047.000	2046.000	15.00	15.00	15.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.797
cmr1pio3h0047w8xn3ax9j9o9	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	SALE	-1.000	18893.000	18892.000	105.00	105.00	105.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.797
cmr1pio3h0048w8xni1zr3w39	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	SALE	-1.000	1336.000	1335.000	125.00	125.00	125.00	SALE	cmr1pinxr003rw8xn6rmhpkbk	order-1782888060390645	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-01 06:41:00.797
cmr2ye0qc0044w8zbnngyr56u	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	PURCHASE	1.000	18892.000	18893.000	105.00	105.00	105.00	PURCHASE	cmr2ydudi003nw8zbiqw0bnz2	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:37:06.612
cmr2ye0qu0047w8zbweetbpdl	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtp002lw8b5ur6xf0pr	cmqnq97kz000jlx4uxdu3s9ws	PURCHASE	1.000	0.000	1.000	20.00	20.00	20.00	PURCHASE	cmr2ydudi003nw8zbiqw0bnz2	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:37:06.631
cmr2ye0r0004aw8zbelx8coaw	cmr0gdhu7005kw8g06c2lngfc	cmr2ydud7003lw8zbjngnri11	cmqnq97ut0013lx4ueqfkijq8	PURCHASE	1.000	0.000	1.000	20.00	20.00	20.00	PURCHASE	cmr2ydudi003nw8zbiqw0bnz2	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:37:06.636
cmr2ylv9x006fw8zbll23abvw	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	2.000	2046.000	2048.000	15.00	15.00	15.00	PURCHASE	cmr2ylpey0062w8zb04m8whed	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:43:12.789
cmr2ynt74007uw8zbmugqaynp	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtp002lw8b5ur6xf0pr	cmqnq97kz000jlx4uxdu3s9ws	PURCHASE	1.000	1.000	2.000	20.00	20.00	20.00	PURCHASE	cmr2ynen6007fw8zbiiw747h1	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:44:43.409
cmr2ynt7m007xw8zbz9psh6gs	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	PURCHASE	1.000	14471.000	14472.000	30.00	30.00	30.00	PURCHASE	cmr2ynen6007fw8zbiiw747h1	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:44:43.427
cmr2yuiwn009yw8zbmazp7wbg	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtp002lw8b5ur6xf0pr	cmqnq97kz000jlx4uxdu3s9ws	PURCHASE	7.000	2.000	9.000	20.00	20.00	20.00	PURCHASE	cmr2ytmrc009lw8zbvo7etzp3	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:49:56.663
cmr2z123p001iw8ho8hlhmeos	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1335.000	1336.000	125.00	125.00	125.00	PURCHASE	cmr2z0rqj0011w8hobwhi38oy	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:55:01.477
cmr2z1243001lw8holy1dbuwc	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2125.000	2126.000	105.00	105.00	105.00	PURCHASE	cmr2z0rqj0011w8hobwhi38oy	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 03:55:01.492
cmr2z8dq8001cw82pnuxgw64y	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	5.000	2126.000	2131.000	105.00	105.00	105.00	PURCHASE	cmr2yvlri00aqw8zbn14lkdp3	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:00:43.137
cmr2z90te002hw82p7wnnvfry	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2131.000	2132.000	105.00	105.00	105.00	PURCHASE	cmr2z8uei0024w82pl4jprckc	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:01:13.059
cmr2zikfq0058w82pw2ktntfn	cmr0gdhu7005kw8g06c2lngfc	cmr2ydud7003lw8zbjngnri11	cmqnq97ut0013lx4ueqfkijq8	PURCHASE	5.000	1.000	6.000	20.00	20.00	20.00	PURCHASE	cmr2zhv2j004rw82p25edpkp1	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:08:38.39
cmr2zq3ff0083w82pv9ds9zb8	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	1.000	2048.000	2049.000	15.00	15.00	15.00	PURCHASE	cmr2zpx9b007kw82ppc2ccbt9	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:14:29.595
cmr2zq3fu0086w82phm05mv0p	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	1.000	144856.000	144857.000	120.00	120.00	120.00	PURCHASE	cmr2zpx9b007kw82ppc2ccbt9	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:14:29.611
cmr2zq3g00089w82pda0s90w2	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1052.000	1053.000	30.00	30.00	30.00	PURCHASE	cmr2zpx9b007kw82ppc2ccbt9	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:14:29.617
cmr2zq3g7008cw82p0zkxxi46	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2132.000	2133.000	105.00	105.00	105.00	PURCHASE	cmr2zpx9b007kw82ppc2ccbt9	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:14:29.623
cmr2zr10p00a3w82pqzs6ujw7	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	1.000	2049.000	2050.000	15.00	15.00	15.00	PURCHASE	cmr2zqon5009kw82pefndzryz	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:13.13
cmr2zr11200a6w82pmxifzelv	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	1.000	144857.000	144858.000	120.00	120.00	120.00	PURCHASE	cmr2zqon5009kw82pefndzryz	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:13.142
cmr2zr11a00a9w82p4xpcmbx4	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1053.000	1054.000	30.00	30.00	30.00	PURCHASE	cmr2zqon5009kw82pefndzryz	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:13.15
cmr2zr11h00acw82pcxy1miee	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1336.000	1337.000	125.00	125.00	125.00	PURCHASE	cmr2zqon5009kw82pefndzryz	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:13.157
cmr2zrnuu00b2w82p3hi1joe1	cmr0gdhu7005kw8g06c2lngfc	cmr2ydud7003lw8zbjngnri11	cmqnq97ut0013lx4ueqfkijq8	SALE	-1.000	6.000	5.000	20.00	20.00	20.00	SALE	cmr2zrnuj00ayw82p28oypxwf	order-1782965742623287	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:42.727
cmr2zrnuv00b3w82prwi2kilq	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	6.000	5.000	55.00	60.00	60.00	SALE	cmr2zrnuj00ayw82p28oypxwf	order-1782965742623287	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:15:42.728
cmr2zscua00c3w82pu7s9jf3v	cmr0gdhu7005kw8g06c2lngfc	cmr2ydud7003lw8zbjngnri11	cmqnq97ut0013lx4ueqfkijq8	SALE	-1.000	5.000	4.000	20.00	20.00	20.00	SALE	cmr2zscu400bzw82pv10yb4mg	order-1782965775034919	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:16:15.107
cmr2zscud00c4w82p3i6gdkyj	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	5.000	4.000	55.00	60.00	60.00	SALE	cmr2zscu400bzw82pv10yb4mg	order-1782965775034919	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 04:16:15.11
cmr31oag4001yw8fuhdm0l819	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-1.000	5000.000	4999.000	20.00	40.00	40.00	SALE	cmr31oafs001vw8fu7txff0d0	order-1782968944530467	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:09:04.613
cmr31qgy60033w8fu5lwmq0p2	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-6.000	4999.000	4993.000	20.00	40.00	40.00	SALE	cmr31qgxv0030w8fuijd3gq0m	order-1782969046286832	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:10:46.351
cmr31s2lf003ww8fuu0ootu1u	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-31.000	4993.000	4962.000	20.00	40.00	40.00	SALE	cmr31s2l5003tw8fux6usv7ok	order-1782969120955758	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:12:01.059
cmr3255ig005cw8fu3b05yuc5	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-3.000	4962.000	4959.000	20.00	40.00	40.00	SALE	cmr3255i30058w8fub48dq6ol	order-1782969730744493	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:22:11.369
cmr3255im005dw8fu61uj3qu5	cmr0gdhu7005kw8g06c2lngfc	cmr2ydud7003lw8zbjngnri11	cmqnq97ut0013lx4ueqfkijq8	SALE	-4.000	4.000	0.000	20.00	20.00	20.00	SALE	cmr3255i30058w8fub48dq6ol	order-1782969730744493	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:22:11.374
cmr328k92007aw8fuyj360pq7	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-3.000	4959.000	4956.000	20.00	40.00	40.00	SALE	cmr328k8o0077w8fupldcu09r	order-1782969890336516	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:24:50.438
cmr32ceb1008xw8fu6xff7a51	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-1.000	4956.000	4955.000	20.00	40.00	40.00	SALE	cmr32ceaj008uw8fux35w5uur	order-1782970069263492	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:27:49.358
cmr32e28i009iw8funylbk9b3	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-2.000	4955.000	4953.000	20.00	40.00	40.00	SALE	cmr32e26y009fw8fuun6fzbyj	order-1782970146794165	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:29:07.026
cmr32h9mb00axw8fus7j5wjnz	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-1.000	4953.000	4952.000	20.00	40.00	40.00	SALE	cmr32h9lm00auw8fu9ayyqcyz	order-1782970296388461	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 05:31:36.563
cmr33onwa00cuw8fugro9n7rt	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-1.000	4952.000	4951.000	20.00	40.00	40.00	SALE	cmr33onsq00crw8fukjgzra0y	order-1782972320673438	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 06:05:21.274
cmr33qoj400dxw8fumwhf734c	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-3.000	4951.000	4948.000	20.00	40.00	40.00	SALE	cmr33qohd00duw8fuf0fun1r2	order-1782972415271005	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 06:06:55.408
cmr37tp72006ow8yo8l6lt6c5	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	5.000	1054.000	1059.000	30.00	30.00	30.00	PURCHASE	cmr37t9hn0069w8yot9fpyn6z	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:01:14.701
cmr37uz2f007nw8yo7ska41nf	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	PURCHASE	1.000	18893.000	18894.000	105.00	105.00	105.00	PURCHASE	cmr2zjkgn0060w82pr4dweo2w	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:02:14.152
cmr37w5zd009kw8yolmtsjfqe	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	2.000	1059.000	1061.000	30.00	30.00	30.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.769
cmr37w60f009nw8yofcamd8xu	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wzn007qw8g0mrmpeb93	cmqnc6u0x000plxvskd56o9d9	PURCHASE	100.000	144858.000	144958.000	120.00	120.00	120.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.808
cmr37w60n009qw8yo3wy69tbv	cmr0gdhu7005kw8g06c2lngfc	cmr0hl6tt0087w8g00hfrr71n	cmqnq97tc000zlx4up9ymaj58	PURCHASE	1.000	2050.000	2051.000	15.00	15.00	15.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.815
cmr37w60u009tw8yo7zkg2s19	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2133.000	2134.000	105.00	105.00	105.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.822
cmr37w60z009ww8yo0fghixoc	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1337.000	1338.000	125.00	125.00	125.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.827
cmr37w616009zw8yohtd3e7xd	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	PURCHASE	1.000	4.000	5.000	55.00	55.00	55.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.834
cmr37w61c00a2w8yozh2mrkos	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	PURCHASE	1.000	14472.000	14473.000	30.00	30.00	30.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.84
cmr37w61j00a5w8yo0osp8sci	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	PURCHASE	1.000	3990.000	3991.000	55.00	55.00	55.00	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:03:09.848
cmr37ybua00b4w8yofvmrx273	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-10.000	4948.000	4938.000	20.00	40.00	40.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.674
cmr37ybud00b5w8yoj30pshth	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-4.000	5.000	1.000	55.00	55.00	55.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.677
cmr37ybui00b6w8yok7q4eg6m	cmr0gdhu7005kw8g06c2lngfc	cmr0j8t2l004bw8b5d1st5xb2	cmqnq97wg001blx4ueh3hh29z	SALE	-1.000	1.000	0.000	55.00	55.00	55.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.682
cmr37ybuj00b7w8yopwvv8igm	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-1.000	3991.000	3990.000	55.00	55.00	55.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.683
cmr37ybuj00b8w8yojdr980fx	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtq002nw8b5th88ylt9	cmqnq97n4000nlx4umqv6wqxb	SALE	-1.000	14473.000	14472.000	30.00	30.00	30.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.684
cmr37ybuk00b9w8yocdjise9z	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qto002jw8b5ohwn880s	cmqnq97r6000vlx4usqsalrhi	SALE	-1.000	18894.000	18893.000	105.00	105.00	105.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.684
cmr37ybuk00baw8yofp5555wg	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	SALE	-1.000	1338.000	1337.000	125.00	125.00	125.00	SALE	cmr37ybtt00avw8yo9ja0diki	order-1782979490408070	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:04:50.685
cmr37yvu800cbw8yoeeaz0667	cmr0gdhu7005kw8g06c2lngfc	cmr3037gn00dmw82p9tbvxa4v	cmr31oafe001tw8fube0vfpyq	SALE	-22.000	4938.000	4916.000	20.00	40.00	40.00	SALE	cmr37yvu100c8w8yoitpqhsgx	order-1782979516530188	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:05:16.592
cmr38lhnl006yw896a5gmeex9	cmr0gdhu7005kw8g06c2lngfc	cmr38l6e0006nw896x2su8dy7	cmr38lhjj006tw896tmrl2wl3	SALE	-5.000	3000.000	2995.000	50.00	100.00	100.00	SALE	cmr38lhk8006vw896c2xboxoc	order-1782980571008090	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:22:51.295
cmr38saio00a9w89629aaitfp	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2134.000	2135.000	105.00	105.00	105.00	PURCHASE	cmr2z9s4j0039w82ps3x24ynh	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:28:08.639
cmr38ur2n00biw89667dkjbkm	cmr0gdhu7005kw8g06c2lngfc	cmr38u30s00b3w896hn7pa13i	cmr38uqzi00bdw896uur2erb3	SALE	-3.000	10.000	7.000	150.00	200.00	200.00	SALE	cmr38ur0m00bfw896rwkp0xor	order-1782981003161065	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:30:03.407
cmr394f1c00dlw896opxfh09j	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-6.000	2000.000	1994.000	150.00	200.00	200.00	SALE	cmr394f0x00diw89684amqowy	order-1782981454228054	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:37:34.369
cmr398sgg00emw896057ha22c	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-5.000	1994.000	1989.000	150.00	200.00	200.00	SALE	cmr398sfz00ejw896c6pn0a2l	order-1782981658225179	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:40:58.384
cmr39a3jr00fzw896o9abekcf	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2135.000	2136.000	105.00	105.00	105.00	PURCHASE	cmr399k4100fiw896gywrtm79	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:41:59.416
cmr39a3k400g2w896eu2rep0v	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	PURCHASE	1.000	1989.000	1990.000	150.00	150.00	150.00	PURCHASE	cmr399k4100fiw896gywrtm79	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 08:41:59.429
cmr3drcjb00lsw87pukbr74ch	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1337.000	1338.000	125.00	125.00	125.00	PURCHASE	cmr3dr0ep00j3w87pg8jklql6	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-02 10:47:22.68
cmr5t744h000kw8ohtm632en0	cmr0gdhu7005kw8g06c2lngfc	cmr3a9zbe00hqw896zn9cids4	cmr5t7422000bw8oh1hhykio7	SALE	-10.000	290.000	280.000	100.00	200.00	200.00	SALE	cmr5t7440000hw8oh9jijldwg	order-1782984223741471	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:04.866
cmr5t74ba000zw8ohcvcrz1l1	cmr0gdhu7005kw8g06c2lngfc	cmr3a9zbe00hqw896zn9cids4	cmr5t7422000bw8oh1hhykio7	SALE	-10.000	280.000	270.000	100.00	200.00	200.00	SALE	cmr5t74b7000ww8ohlnovfe8c	order-1782984429516632	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.11
cmr5t74cf001kw8ohr5rqpj92	cmr0gdhu7005kw8g06c2lngfc	cmr3bbwe0003nw8uf9s6eckxu	cmr5t74c3001bw8oh2k59ek9v	SALE	-7.000	3993.000	3986.000	100.00	200.00	200.00	SALE	cmr5t74cc001hw8ohqnga9y5s	order-1782988352184264	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.152
cmr5t74ew0024w8ohp6ycoge7	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-1.000	1980.000	1979.000	150.00	150.00	150.00	SALE	cmr5t74eu0020w8oh96w6nn2e	order-1782988765786637	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.241
cmr5t74ex0025w8ohn7vbt843	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-2.000	1979.000	1977.000	150.00	150.00	150.00	SALE	cmr5t74eu0020w8oh96w6nn2e	order-1782988765786637	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.241
cmr5t74gg002lw8ohz1qlpeqa	cmr0gdhu7005kw8g06c2lngfc	cmr0j7ms4003yw8b5fzt1dvrs	cmqnq97p4000rlx4updfrju1f	SALE	-7.000	3983.000	3976.000	55.00	55.00	55.00	SALE	cmr5t74fv002hw8ohmtpbzdwn	order-1782989488117954	Stock reduced from sale.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.296
cmr5t74gk002mw8ohscvzg8t2	cmr0gdhu7005kw8g06c2lngfc	cmr3bbwe0003nw8uf9s6eckxu	cmr5t74c3001bw8oh2k59ek9v	SALE	-7.000	3986.000	3979.000	100.00	200.00	200.00	SALE	cmr5t74fv002hw8ohmtpbzdwn	order-1782989488117954	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.301
cmr5t74iv0032w8oh5jvdxz25	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-1.000	1977.000	1976.000	150.00	150.00	150.00	SALE	cmr5t74is002yw8oh5ewrx1d5	order-1782989561900135	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.384
cmr5t74iw0033w8ohkb7q7m5o	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-6.000	1976.000	1970.000	150.00	150.00	150.00	SALE	cmr5t74is002yw8oh5ewrx1d5	order-1782989561900135	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.385
cmr5t74k8003iw8ohijfhflgq	cmr0gdhu7005kw8g06c2lngfc	cmr3bbwe0003nw8uf9s6eckxu	cmr5t74c3001bw8oh2k59ek9v	SALE	-3.000	3979.000	3976.000	100.00	200.00	200.00	SALE	cmr5t74k6003fw8ohd5stmjlo	order-1782989724275542	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.433
cmr5t74n0003xw8ohkxgm64ee	cmr0gdhu7005kw8g06c2lngfc	cmr3a9zbe00hqw896zn9cids4	cmr5t7422000bw8oh1hhykio7	SALE	-4.000	270.000	266.000	100.00	200.00	200.00	SALE	cmr5t74mz003uw8ohjykya0u0	order-1782989874728370	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:35:05.533
cmr5ta3pg006gw8ohetib6rkw	cmr0gdhu7005kw8g06c2lngfc	cmr0i27dr008nw8g0nizlcekx	cmqnq97x4001flx4upjb4nzcm	PURCHASE	1.000	2136.000	2137.000	105.00	105.00	105.00	PURCHASE	cmr5t9xe60061w8oh9gvahuo0	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:37:24.292
cmr5ta3pr006jw8oh7caivtt8	cmr0gdhu7005kw8g06c2lngfc	cmr0j6qtb002hw8b549panick	cmq3qiahw0005lxru9rwwztl9	PURCHASE	1.000	1338.000	1339.000	125.00	125.00	125.00	PURCHASE	cmr5t9xe60061w8oh9gvahuo0	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:37:24.303
cmr5tc8mf007mw8ohw2hydi2c	cmr0gdhu7005kw8g06c2lngfc	cmr5tbl5k0077w8ohq5rhclte	cmr5tc8lq007dw8ohq06pd1ho	SALE	-11.000	120.000	109.000	120.00	125.00	125.00	SALE	cmr5tc8mc007jw8oh3hyy1y8z	order-1783136343914525	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:39:03.976
cmr5tdejl008fw8oh5977j4xn	cmr0gdhu7005kw8g06c2lngfc	cmr5tbl5k0077w8ohq5rhclte	cmr5tc8lq007dw8ohq06pd1ho	SALE	-21.000	109.000	88.000	120.00	125.00	125.00	SALE	cmr5tdejb008cw8ohwq77sfih	order-1783136398210273	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:39:58.306
cmr5tg1ra009qw8ohmr1qb65n	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-38.000	200.000	162.000	10.00	50.00	50.00	SALE	cmr5tg1qz009nw8oh4r4hxepw	order-1783136521456132	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:42:01.703
cmr5th1x900ahw8oh2fd1am9g	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-83.000	162.000	79.000	10.00	50.00	50.00	SALE	cmr5th1w400aew8oh4xqrw7bt	order-1783136568435451	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:42:48.573
cmr5tjv6g00bnw8oh02q30a5o	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-78.000	200.000	122.000	10.00	100.00	100.00	SALE	cmr5tjv6800bjw8ohaktljm9n	order-1783136699638405	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:44:59.8
cmr5tjv7a00bow8ohbnqttczm	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-29.000	79.000	50.000	10.00	50.00	50.00	SALE	cmr5tjv6800bjw8ohaktljm9n	order-1783136699638405	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:44:59.83
cmr5tz38c00cxw8ohhka2qh4r	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-10.000	122.000	112.000	10.00	100.00	100.00	SALE	cmr5tz38000cuw8oht64glxo3	order-1783137409956409	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 03:56:50.076
cmr5u7iov000ew83rlj87f81y	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	112.000	111.000	10.00	100.00	100.00	SALE	cmr5u7iom0009w83raonzgeai	order-1783137803231398	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:03:23.36
cmr5u7ip0000fw83r54gx0frv	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-1.000	50.000	49.000	10.00	50.00	50.00	SALE	cmr5u7iom0009w83raonzgeai	order-1783137803231398	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:03:23.365
cmr5u7ip1000gw83rcdu7c9r7	cmr0gdhu7005kw8g06c2lngfc	cmr5tbl5k0077w8ohq5rhclte	cmr5tc8lq007dw8ohq06pd1ho	SALE	-1.000	88.000	87.000	120.00	125.00	125.00	SALE	cmr5u7iom0009w83raonzgeai	order-1783137803231398	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:03:23.366
cmr5u8097001uw83r0ya06fpg	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	111.000	110.000	10.00	100.00	100.00	SALE	cmr5u8090001qw83rmylwgnpf	order-1783137826017241	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:03:46.124
cmr5u8098001vw83rsewvo294	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-1.000	49.000	48.000	10.00	50.00	50.00	SALE	cmr5u8090001qw83rmylwgnpf	order-1783137826017241	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:03:46.125
cmr5u8p9w002rw83rcwme8fni	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	110.000	109.000	10.00	100.00	100.00	SALE	cmr5u8p9j002nw83rfwcwsy3n	order-1783137858446586	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:04:18.548
cmr5u8p9y002sw83rhi2hvyxg	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-1.000	48.000	47.000	10.00	50.00	50.00	SALE	cmr5u8p9j002nw83rfwcwsy3n	order-1783137858446586	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:04:18.55
cmr5ukn3q0006w8plyr0eb46p	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	109.000	108.000	10.00	100.00	100.00	SALE	cmr5ukn3c0003w8pld8eh0h18	\N	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:13:35.607
cmr5uov5g004hw83r057m9apn	cmr0gdhu7005kw8g06c2lngfc	cmr5tbl5k0077w8ohq5rhclte	cmr5tc8lq007dw8ohq06pd1ho	SALE	-1.000	87.000	86.000	120.00	125.00	125.00	SALE	cmr5uov5a004ew83ravww52uk	order-1783138612599249	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:16:52.66
cmr5ur49a0067w83r6eu9p2xt	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	108.000	107.000	10.00	100.00	100.00	SALE	cmr5ur48x0063w83rqlvf99en	order-1783138717706159	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:18:37.775
cmr5ur49c0068w83rirl030q4	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-1.000	47.000	46.000	10.00	50.00	50.00	SALE	cmr5ur48x0063w83rqlvf99en	order-1783138717706159	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:18:37.777
cmr5uredi0073w83r8captr69	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-7.000	107.000	100.000	10.00	100.00	100.00	SALE	cmr5uredd0070w83rxss2c5b6	order-1783138730822851	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 04:18:50.886
cmr5wdqde00dmw83rn3bqifox	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-6.000	400.000	394.000	25.00	50.00	50.00	SALE	cmr5wdqcq00djw83rwognoxcb	order-1783141452161662	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 05:04:12.482
cmr5xsoe400ghw83rhq0df8tg	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-8.000	394.000	386.000	25.00	50.00	50.00	SALE	cmr5xsodq00gew83rab2b6ii1	order-1783143828880819	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 05:43:49.372
cmr67ddov00fyw8jfrnc2wtjj	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	100.000	99.000	10.00	100.00	100.00	SALE	cmr67ddof00fvw8jflwx020z3	order-1783159911673064	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 10:11:51.822
cmr67ex1400gxw8jfj0cnghej	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-2.000	46.000	44.000	10.00	50.00	50.00	SALE	cmr67ex0v00guw8jfiu3vyot6	order-1783159983431419	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 10:13:03.544
cmr67jrl900iew8jfbk2b8pzk	cmr0gdhu7005kw8g06c2lngfc	cmr392nse00d0w896nuguvfvg	cmr394f0b00dgw89676gha1f1	SALE	-2.000	1970.000	1968.000	150.00	150.00	150.00	SALE	cmr67jrkp00ibw8jf2lzswu2s	order-1783160209649060	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 10:16:49.772
cmr6801sp00l3w8jfacg5aot4	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-1.000	386.000	385.000	25.00	50.00	50.00	SALE	cmr6801s800l0w8jfqh7ha07s	order-1783160969148133	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 10:29:29.497
cmr69b1n4003sw8l3l37r22vq	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-1.000	385.000	384.000	25.00	50.00	50.00	SALE	cmr69b1mb003pw8l334eerwnv	order-1783163161947181	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:06:02.125
cmr69bh2c004nw8l3ge1bb6r7	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	99.000	98.000	10.00	100.00	100.00	SALE	cmr69bh21004kw8l3zha0nhrt	order-1783163181977373	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:06:22.116
cmr69bqf4005ew8l3e6z5pkdx	cmr0gdhu7005kw8g06c2lngfc	cmr38l6e0006nw896x2su8dy7	cmr38lhjj006tw896tmrl2wl3	SALE	-1.000	2995.000	2994.000	50.00	100.00	100.00	SALE	cmr69bqeu005bw8l355nkc51n	order-1783163194138034	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:06:34.24
cmr69def00071w8l3slzcnzw6	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-1.000	384.000	383.000	25.00	50.00	50.00	SALE	cmr69deeh006yw8l3k4wtbkuc	order-1783163271902402	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-04 11:07:51.997
cmr7a2og4019kw8mpf1ikjqmb	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1061.000	1062.000	30.00	30.00	30.00	PURCHASE	cmr7a1mv50171w8mp91lvl4kr	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:15:17.572
cmr7a3s1n01brw8mpfwnnghsi	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1062.000	1063.000	30.00	30.00	30.00	PURCHASE	cmr7a3lvi01b6w8mp80duk4s2	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:16:08.891
cmr7a6mzk01d6w8mp8xjhuj2b	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-4.000	383.000	379.000	25.00	50.00	50.00	SALE	cmr7a6mz401d3w8mpvi2m30t7	order-1783225102228046	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:18:22.305
cmr7a7gq601elw8mp66uwv91f	cmr0gdhu7005kw8g06c2lngfc	cmr5tffu4009bw8ohwvaqnaho	cmr5tg1ne009hw8ohfuwwn9r4	SALE	-1.000	44.000	43.000	10.00	50.00	50.00	SALE	cmr7a7gpe01eiw8mpyvjz4us7	order-1783225140757277	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:19:00.846
cmr7aagkt01jmw8mpe8iiz643	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1063.000	1064.000	30.00	30.00	30.00	PURCHASE	cmr7aabwv01itw8mpyx0xbo7b	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:21:20.621
cmr7ahtk001ppw8mpvvt0017p	cmr0gdhu7005kw8g06c2lngfc	cmr7adrd801lqw8mp9ibm33op	cmr7ahth001pgw8mp81w4l2i8	SALE	-1.000	100.000	99.000	50.00	100.00	100.00	SALE	cmr7ahtjk01pmw8mp70bq37w9	order-1783225623805475	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:27:04.032
cmr7ai9lw01r0w8mpsc5l1t06	cmr0gdhu7005kw8g06c2lngfc	cmr7adrd801lqw8mp9ibm33op	cmr7ahth001pgw8mp81w4l2i8	SALE	-1.000	99.000	98.000	50.00	100.00	100.00	SALE	cmr7ai9lp01qxw8mp32tyd6so	order-1783225644685231	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:27:24.837
cmr7arayn01vdw8mpqz6m0yu2	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1064.000	1065.000	30.00	30.00	30.00	PURCHASE	cmr7ar6qr01uow8mp91cne35m	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:34:26.495
cmr7au59r01xww8mp0w28ovx7	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	200.000	199.000	10.00	15.00	15.00	SALE	cmr7au59h01xtw8mpkv8sfjfy	order-1783226198916591	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:36:39.088
cmr7b8vop023rw8mpnr93u88d	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	199.000	198.000	10.00	15.00	15.00	SALE	cmr7b8voh023ow8mpabdnjxb7	order-1783226886456747	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:48:06.505
cmr7b9je0025cw8mpnbv5jgkl	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	198.000	197.000	10.00	15.00	15.00	SALE	cmr7b9jdr0259w8mp42oo1gfs	order-1783226917151718	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 04:48:37.224
cmr7bqwrv027dw8mpehbzq0dh	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	197.000	196.000	10.00	15.00	15.00	SALE	cmr7bqwrh027aw8mp3732z6z1	order-1783227727601180	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:02:07.723
cmr7brcyg028ow8mpmq2tlm2a	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	196.000	195.000	10.00	15.00	15.00	SALE	cmr7brcyc028lw8mpptk47njy	order-1783227748584257	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:02:28.697
cmr7ch6lj001kw8rfw58v4gww	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	195.000	194.000	10.00	15.00	15.00	SALE	cmr7ch6l3001hw8rfp3ijhzp6	order-1783228953442400	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:22:33.512
cmr7crv0j0041w8rfi3p3r0nv	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	194.000	193.000	10.00	15.00	15.00	SALE	cmr7cruy0003yw8rfr3ofdtd4	order-1783229451501504	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:30:51.716
cmr7cs7t3005ew8rfcqgndfk3	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	193.000	192.000	10.00	15.00	15.00	SALE	cmr7cs7sx005bw8rf3vlwbvgz	order-1783229468239989	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:31:08.296
cmr7ct6j1006pw8rfmyd2syrx	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	192.000	191.000	10.00	15.00	15.00	SALE	cmr7ct6in006mw8rfjc6mzr64	order-1783229513071520	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:31:53.293
cmr7da96q0092w8rfddqw9qoo	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	191.000	190.000	10.00	15.00	15.00	SALE	cmr7da96g008zw8rfmdetx8bs	order-1783230309830192	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:45:09.891
cmr7dav9u00abw8rfuzqcc2kh	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	190.000	189.000	10.00	15.00	15.00	SALE	cmr7dav9n00a8w8rfb2bm7rwa	order-1783230338460629	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:45:38.514
cmr7db7vz00biw8rf246630hd	cmr0gdhu7005kw8g06c2lngfc	cmr7adrd801lqw8mp9ibm33op	cmr7ahth001pgw8mp81w4l2i8	SALE	-1.000	98.000	97.000	50.00	100.00	100.00	SALE	cmr7db7vj00bfw8rfyxfeitv7	order-1783230354809690	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:45:54.864
cmr7dbm7k00cpw8rft5ioe9ef	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	189.000	188.000	10.00	15.00	15.00	SALE	cmr7dbm7d00cmw8rfj2unpzqh	order-1783230373374524	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:46:13.425
cmr7dbwxg00e0w8rflhhpd1ow	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	188.000	187.000	10.00	15.00	15.00	SALE	cmr7dbwxd00dxw8rfl1w5fsrt	order-1783230387173358	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:46:27.317
cmr7dlich00ifw8rfls8pz2wn	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1065.000	1066.000	30.00	30.00	30.00	PURCHASE	cmr7dlekj00hqw8rfkfmw86iv	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:53:54.978
cmr7ds3it00oqw8rfqdj9xbkf	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	187.000	186.000	10.00	15.00	15.00	SALE	cmr7ds3ib00onw8rf32cafk45	order-1783231142268610	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:59:02.357
cmr7dsva100qtw8rfiphf3azo	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	186.000	185.000	10.00	15.00	15.00	SALE	cmr7dsv9h00qqw8rfr5tro5zx	order-1783231178229393	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 05:59:38.329
cmr7du2yw00umw8rfujzltezc	cmr0gdhu7005kw8g06c2lngfc	cmr0h6wz9007ow8g0eeb1xr8f	cmqnq97vj0017lx4uc77sbdn6	PURCHASE	1.000	1066.000	1067.000	30.00	30.00	30.00	PURCHASE	cmr7dty1400txw8rftx02hajp	\N	Stock received from purchase flow.	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:00:34.952
cmr7duudb00w9w8rfbfu3zdz9	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	185.000	184.000	10.00	15.00	15.00	SALE	cmr7duud100w6w8rfsdcn8e48	order-1783231270413070	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:01:10.464
cmr7e5p5j001yw8w9r5je3tr5	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-3.000	379.000	376.000	25.00	50.00	50.00	SALE	cmr7e5p57001vw8w9zlmbqngc	order-1783231776848542	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:09:36.919
cmr7e6bju003fw8w9r9g5gwne	cmr0gdhu7005kw8g06c2lngfc	cmr5v7to0008vw83racyeu238	cmr5wdq6p00ddw83rw50pbwz8	SALE	-3.000	376.000	373.000	25.00	50.00	50.00	SALE	cmr7e6bjj003cw8w9g3eylzxe	order-1783231805878432	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:10:05.946
cmr7ephp00080w8w92vx9c83e	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-1.000	184.000	183.000	10.00	15.00	15.00	SALE	cmr7ephoi007xw8w9dleyqsui	order-1783232700285199	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:25:00.372
cmr7ewzwy0024w8l6xgvhm3mk	cmr0gdhu7005kw8g06c2lngfc	cmr7at3bc01wlw8mpe3gw17s5	cmr7au57l01xnw8mp4h6bwy62	SALE	-7.000	183.000	176.000	10.00	15.00	15.00	SALE	cmr7ewzw70021w8l6fqz6979e	order-1783233050042231	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:30:50.577
cmr7f1umz005fw8l6p1ainxlw	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	98.000	97.000	10.00	100.00	100.00	SALE	cmr7f1umi005cw8l6ynkeks7b	order-1783233276914395	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:34:37.02
cmr7f28bi006mw8l6vy3anyzx	cmr0gdhu7005kw8g06c2lngfc	cmr5tj0fk00b7w8oh5ew29ywn	cmr5tjv3u00bdw8oh5bm4rax4	SALE	-1.000	97.000	96.000	10.00	100.00	100.00	SALE	cmr7f28ab006jw8l65cchhz4n	order-1783233294609736	Stock reduced from sale. | Batch 1	null	cmr0gdhs5005iw8g0cqf5tgmo	2026-07-05 06:34:54.75
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.subscriptions (id, shop_id, status, trial_started_at, trial_ends_at, billing_started_at, daily_rate_per_account, grace_ends_at, created_at, updated_at) FROM stdin;
cmqtek0wh0006lxj66clvebk0	cmqtek0us0002lxj6zzrnqalp	GRACE	2026-06-25 11:11:58.848	2026-06-26 11:11:58.848	2026-06-30 08:56:44.921	10.00	2026-07-02 08:10:24.682	2026-06-25 11:11:58.865	2026-07-04 08:56:59.004
cmr0gdhv8005ow8g00ve5r4j5	cmr0gdhu7005kw8g06c2lngfc	ACTIVE	2026-06-30 09:37:16.713	2026-07-01 09:37:16.713	2026-07-05 03:31:50.835	10.00	\N	2026-06-30 09:37:16.723	2026-07-05 03:31:50.835
\.


--
-- Data for Name: supplier_ledgers; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.supplier_ledgers (id, shop_id, supplier_id, entry_type, purchase_id, supplier_payment_id, reference_no, debit, credit, notes, entry_date, created_at) FROM stdin;
cmqxor2br001ulxtk9i626wgz	cmqtek0us0002lxj6zzrnqalp	cmqxor2bl001slxtkt5felngw	OPENING_DUE	\N	\N	SHAKIB-815454	0.00	0.00	Supplier created for this shop.	2026-06-28 11:08:28.166	2026-06-28 11:08:28.167
cmr0f4tn2004pw8g04v8xkx55	cmqtek0us0002lxj6zzrnqalp	cmqxor2bl001slxtkt5felngw	PURCHASE	cmr0f4037004aw8g06jezalcn	\N	SHAKIB-815454	126.00	0.00	\N	2026-06-30 09:01:54.142	2026-06-30 09:02:32.462
cmr0h5buo007jw8g0u8ek9lbf	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	OPENING_DUE	\N	\N	SSS-527935	0.00	0.00	Supplier created for this shop.	2026-06-30 09:58:55.295	2026-06-30 09:58:55.296
cmr0h6b84007mw8g0o7phe9uu	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	OPENING_DUE	\N	\N	FFFF-112933	0.00	0.00	Supplier created for this shop.	2026-06-30 09:59:41.14	2026-06-30 09:59:41.141
cmr0hw4ln008fw8g0wjx6z4y2	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	OPENING_DUE	\N	\N	SAHIBB-558788	0.00	0.00	Supplier created for this shop.	2026-06-30 10:19:45.611	2026-06-30 10:19:45.611
cmr0j5bk7000iw8b589q2rrex	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PURCHASE	cmr0h6wzr007sw8g0tbj8zx72	\N	FFFF-112933	150.00	0.00	\N	2026-06-30 10:00:09.312	2026-06-30 10:54:54.152
cmr0j5bkl000mw8b5er6u1x5p	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PAYMENT	cmr0h6wzr007sw8g0tbj8zx72	cmr0j5bkb000kw8b5dm9punsu	FFFF-112933	0.00	150.00	\N	2026-06-30 10:00:09.312	2026-06-30 10:54:54.165
cmr0j5bpv000zw8b5cfrbg4nv	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PURCHASE	cmr0hl6u10089w8g0eawjuc78	\N	SSS-527935	1485.00	0.00	\N	2026-06-30 10:11:15.257	2026-06-30 10:54:54.356
cmr0j5bpx0013w8b5fc1pshgc	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PAYMENT	cmr0hl6u10089w8g0eawjuc78	cmr0j5bpw0011w8b53vb3z9qb	SSS-527935	0.00	1485.00	\N	2026-06-30 10:11:15.257	2026-06-30 10:54:54.358
cmr0j5bqz001ow8b5dee6tsd6	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0i27er008pw8g0shrocgbl	\N	SAHIBB-558788	105780.00	0.00	\N	2026-06-30 10:24:29.103	2026-06-30 10:54:54.395
cmr0j5br1001sw8b576112ifw	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr0i27er008pw8g0shrocgbl	cmr0j5br0001qw8b5bviud82q	SAHIBB-558788	0.00	105780.00	\N	2026-06-30 10:24:29.103	2026-06-30 10:54:54.398
cmr0j5brx0023w8b51yxejnym	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0ic37l0096w8g0aojmgem0	\N	SAHIBB-558788	75000.00	0.00	\N	2026-06-30 10:32:10.262	2026-06-30 10:54:54.429
cmr0j5brz0027w8b5vcf8tcju	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr0ic37l0096w8g0aojmgem0	cmr0j5brx0025w8b5typl2524	SAHIBB-558788	0.00	75000.00	\N	2026-06-30 10:32:10.262	2026-06-30 10:54:54.431
cmr0j6qvc003ww8b51cm447o6	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0j6qts002pw8b5qtn78wqp	\N	SAHIBB-558788	20069440.00	0.00	\N	2026-06-30 10:56:00.5	2026-06-30 10:56:00.649
cmr0j7mt80049w8b5s0pbva65	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0j7msc0040w8b513bzlq5a	\N	SAHIBB-558788	220000.00	0.00	\N	2026-06-30 10:56:41.991	2026-06-30 10:56:42.045
cmr0j8t3a004mw8b53l8stlmw	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0j8t2r004dw8b5coiu617y	\N	SAHIBB-558788	770.00	0.00	\N	2026-06-30 10:57:36.761	2026-06-30 10:57:36.838
cmr0jdqf0000cw8s312w3qlit	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PURCHASE	cmr0jdhky0003w8s36i2kybhl	\N	FFFF-112933	900.00	0.00	\N	2026-06-30 11:01:15.138	2026-06-30 11:01:26.652
cmr0jdqf4000gw8s305xqljj0	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PAYMENT	cmr0jdhky0003w8s36i2kybhl	cmr0jdqf2000ew8s3fbvf5jol	FFFF-112933	0.00	900.00	\N	2026-06-30 11:01:15.138	2026-06-30 11:01:26.657
cmr0jg0ol000tw8s3phmdb5cu	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr0jfpcu000kw8s3ksa9ty62	\N	SAHIBB-558788	125.00	0.00	\N	2026-06-30 11:02:58.56	2026-06-30 11:03:13.269
cmr0jg0oo000xw8s3gbluj759	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr0jfpcu000kw8s3ksa9ty62	cmr0jg0om000vw8s3cmyha3qf	SAHIBB-558788	0.00	125.00	\N	2026-06-30 11:02:58.56	2026-06-30 11:03:13.272
cmr1kym7v000cw8jo9e14pjck	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE_RETURN	cmr0jfpcu000kw8s3ksa9ty62	\N	SAHIBB-558788	0.00	125.00	raja	2026-07-01 04:33:26.778	2026-07-01 04:33:26.779
cmr1kymei000jw8joksqjhz88	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE_RETURN	cmr0j7msc0040w8b513bzlq5a	\N	SAHIBB-558788	0.00	55.00	emni	2026-07-01 04:33:27.017	2026-07-01 04:33:27.018
cmr1kymfc000sw8joiug0ac1u	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE_RETURN	cmr0j6qts002pw8b5qtn78wqp	\N	SAHIBB-558788	0.00	360.00	emni	2026-07-01 04:33:27.048	2026-07-01 04:33:27.048
cmr1l09ob001qw8jom33o8for	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr1kzx3o0012w8joeetozhlr	\N	SAHIBB-558788	2170.00	0.00	\N	2026-07-01 04:34:27.507	2026-07-01 04:34:43.835
cmr1l09og001uw8jodsci4m4q	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr1kzx3o0012w8joeetozhlr	cmr1l09od001sw8jo6knsomw4	SAHIBB-558788	0.00	2170.00	\N	2026-07-01 04:34:27.507	2026-07-01 04:34:43.84
cmr2ye0r5004ew8zbba2anpqx	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2ydudi003nw8zbiqw0bnz2	\N	SAHIBB-558788	145.00	0.00	\N	2026-07-02 03:36:58.34	2026-07-02 03:37:06.641
cmr2ye0rb004iw8zbhdexer43	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2ydudi003nw8zbiqw0bnz2	cmr2ye0r7004gw8zb4nu1shab	SAHIBB-558788	0.00	145.00	\N	2026-07-02 03:36:58.34	2026-07-02 03:37:06.648
cmr2ylva8006jw8zbtl3jfba2	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2ylpey0062w8zb04m8whed	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-02 03:43:05.099	2026-07-02 03:43:12.801
cmr2ylvag006nw8zb9n8y8npl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2ylpey0062w8zb04m8whed	cmr2ylvab006lw8zb3tm7lyg0	SAHIBB-558788	0.00	30.00	\N	2026-07-02 03:43:05.099	2026-07-02 03:43:12.809
cmr2ynt7v0081w8zbn3im1vzs	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2ynen6007fw8zbiiw747h1	\N	SAHIBB-558788	50.00	0.00	\N	2026-07-02 03:44:24.528	2026-07-02 03:44:43.435
cmr2yuiwx00a2w8zby2fpsedz	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2ytmrc009lw8zbvo7etzp3	\N	SAHIBB-558788	140.00	0.00	\N	2026-07-02 03:49:14.987	2026-07-02 03:49:56.674
cmr2yuix400a6w8zbc2trigh7	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2ytmrc009lw8zbvo7etzp3	cmr2yuix100a4w8zby0ccg7t5	SAHIBB-558788	0.00	140.00	\N	2026-07-02 03:49:14.987	2026-07-02 03:49:56.68
cmr2z124a001pw8horbvx89tu	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2z0rqj0011w8hobwhi38oy	\N	SAHIBB-558788	230.00	0.00	\N	2026-07-02 03:54:48.022	2026-07-02 03:55:01.498
cmr2z124g001tw8hozdzwkx5p	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2z0rqj0011w8hobwhi38oy	cmr2z124d001rw8hobpy0z98k	SAHIBB-558788	0.00	230.00	\N	2026-07-02 03:54:48.022	2026-07-02 03:55:01.505
cmr2z8dqk001gw82phkmamdm6	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PURCHASE	cmr2yvlri00aqw8zbn14lkdp3	\N	FFFF-112933	525.00	0.00	\N	2026-07-02 03:50:47.004	2026-07-02 04:00:43.148
cmr2z8dqs001kw82py3t0qa1m	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	PAYMENT	cmr2yvlri00aqw8zbn14lkdp3	cmr2z8dqp001iw82pyotdujs5	FFFF-112933	0.00	525.00	\N	2026-07-02 03:50:47.004	2026-07-02 04:00:43.156
cmr2z90tm002lw82pft5382mz	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2z8uei0024w82pl4jprckc	\N	SAHIBB-558788	105.00	0.00	\N	2026-07-02 04:01:04.727	2026-07-02 04:01:13.066
cmr2z90tt002pw82pnqu018r6	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2z8uei0024w82pl4jprckc	cmr2z90to002nw82pep4u9atl	SAHIBB-558788	0.00	105.00	\N	2026-07-02 04:01:04.727	2026-07-02 04:01:13.073
cmr2zikg3005cw82pqqmssiux	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2zhv2j004rw82p25edpkp1	\N	SAHIBB-558788	100.00	0.00	\N	2026-07-02 04:08:05.501	2026-07-02 04:08:38.404
cmr2zikga005gw82pcryku4li	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2zhv2j004rw82p25edpkp1	cmr2zikg6005ew82p9oayvf3p	SAHIBB-558788	0.00	100.00	\N	2026-07-02 04:08:05.501	2026-07-02 04:08:38.41
cmr2zq3gb008gw82pt85jl91p	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PURCHASE	cmr2zpx9b007kw82ppc2ccbt9	\N	SSS-527935	270.00	0.00	\N	2026-07-02 04:14:21.583	2026-07-02 04:14:29.627
cmr2zq3gj008kw82px3ugip5c	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PAYMENT	cmr2zpx9b007kw82ppc2ccbt9	cmr2zq3gf008iw82p3zneltdx	SSS-527935	0.00	270.00	\N	2026-07-02 04:14:21.583	2026-07-02 04:14:29.635
cmr2zr11m00agw82pyuru3hfp	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PURCHASE	cmr2zqon5009kw82pefndzryz	\N	SSS-527935	290.00	0.00	\N	2026-07-02 04:14:57.062	2026-07-02 04:15:13.162
cmr2zr11v00akw82p2z3r2lf3	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PAYMENT	cmr2zqon5009kw82pefndzryz	cmr2zr11p00aiw82pufxtvm3r	SSS-527935	0.00	290.00	\N	2026-07-02 04:14:57.062	2026-07-02 04:15:13.171
cmr37tp7h006sw8yo1s5fmecx	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr37t9hn0069w8yot9fpyn6z	\N	SAHIBB-558788	150.00	0.00	\N	2026-07-02 08:00:54.307	2026-07-02 08:01:14.716
cmr37tp7r006ww8yowxz8n2em	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr37t9hn0069w8yot9fpyn6z	cmr37tp7n006uw8yok1kb1fz4	SAHIBB-558788	0.00	150.00	\N	2026-07-02 08:00:54.307	2026-07-02 08:01:14.728
cmr37uz2u007rw8yo01l7dfey	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2zjkgn0060w82pr4dweo2w	\N	SAHIBB-558788	105.00	0.00	\N	2026-07-02 04:09:25.051	2026-07-02 08:02:14.166
cmr37uz30007vw8yodl10cghl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2zjkgn0060w82pr4dweo2w	cmr37uz2x007tw8yoo1skh6n8	SAHIBB-558788	0.00	105.00	\N	2026-07-02 04:09:25.051	2026-07-02 08:02:14.172
cmr37w61o00a9w8yoo0i4akj5	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr37w0nw008tw8yon306wqnl	\N	SAHIBB-558788	12445.00	0.00	\N	2026-07-02 08:03:02.842	2026-07-02 08:03:09.852
cmr37w61u00adw8yo3ejebmvz	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr37w0nw008tw8yon306wqnl	cmr37w61r00abw8yocqpr809q	SAHIBB-558788	0.00	12445.00	\N	2026-07-02 08:03:02.842	2026-07-02 08:03:09.858
cmr38mf4d008mw8960kpv4zx2	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	\N	cmr38mf44008kw896n3yz8exc	SAHIBB-558788	0.00	20290260.00	Cash payment	2026-07-02 08:23:34.657	2026-07-02 08:23:34.669
cmr38sapr00adw896041ww599	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr2z9s4j0039w82ps3x24ynh	\N	SAHIBB-558788	105.00	0.00	\N	2026-07-02 04:01:48.438	2026-07-02 08:28:08.896
cmr38saq300ahw896ny5p5t7r	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr2z9s4j0039w82ps3x24ynh	cmr38sapw00afw896vb6do4pp	SAHIBB-558788	0.00	105.00	\N	2026-07-02 04:01:48.438	2026-07-02 08:28:08.908
cmr39a3ka00g6w8969kicqawd	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr399k4100fiw896gywrtm79	\N	SAHIBB-558788	255.00	0.00	\N	2026-07-02 08:41:34.191	2026-07-02 08:41:59.434
cmr39a3kj00gaw896uc4t6g0o	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr399k4100fiw896gywrtm79	cmr39a3kd00g8w896v5fjqm1u	SAHIBB-558788	0.00	255.00	\N	2026-07-02 08:41:34.191	2026-07-02 08:41:59.444
cmr3drcjv00lww87ppkdwew1k	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr3dr0ep00j3w87pg8jklql6	\N	SAHIBB-558788	125.00	0.00	\N	2026-07-02 10:47:06.934	2026-07-02 10:47:22.699
cmr3drck300m0w87pczgbpwwt	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr3dr0ep00j3w87pg8jklql6	cmr3drck000lyw87py7atpnj7	SAHIBB-558788	0.00	125.00	\N	2026-07-02 10:47:06.934	2026-07-02 10:47:22.708
cmr5ta3pw006nw8ohf1coimht	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr5t9xe60061w8oh9gvahuo0	\N	SAHIBB-558788	230.00	0.00	\N	2026-07-04 03:37:16.074	2026-07-04 03:37:24.308
cmr5ta3q2006rw8ohun5airc6	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr5t9xe60061w8oh9gvahuo0	cmr5ta3pz006pw8ohmiwlyrf7	SAHIBB-558788	0.00	230.00	\N	2026-07-04 03:37:16.074	2026-07-04 03:37:24.314
cmr7a2ogn019ow8mpzcsn8xhz	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PURCHASE	cmr7a1mv50171w8mp91lvl4kr	\N	SSS-527935	30.00	0.00	\N	2026-07-05 04:14:28.755	2026-07-05 04:15:17.591
cmr7a2oh3019sw8mp0511oqvt	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	PAYMENT	cmr7a1mv50171w8mp91lvl4kr	cmr7a2ogy019qw8mp4zoqk70q	SSS-527935	0.00	30.00	\N	2026-07-05 04:14:28.755	2026-07-05 04:15:17.607
cmr7a3s1v01bvw8mpj1xgw5pl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr7a3lvi01b6w8mp80duk4s2	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-05 04:16:00.876	2026-07-05 04:16:08.9
cmr7a3s2001bzw8mpxjzw0ncs	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr7a3lvi01b6w8mp80duk4s2	cmr7a3s1y01bxw8mp2lopxvrd	SAHIBB-558788	0.00	30.00	\N	2026-07-05 04:16:00.876	2026-07-05 04:16:08.904
cmr7aagky01jqw8mprkdp28g5	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr7aabwv01itw8mpyx0xbo7b	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-05 04:21:14.558	2026-07-05 04:21:20.627
cmr7aagl501juw8mpyvf06xk7	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr7aabwv01itw8mpyx0xbo7b	cmr7aagl101jsw8mpqftbpzfl	SAHIBB-558788	0.00	30.00	\N	2026-07-05 04:21:14.558	2026-07-05 04:21:20.634
cmr7araz001vhw8mpawmldrpc	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr7ar6qr01uow8mp91cne35m	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-05 04:34:21.009	2026-07-05 04:34:26.508
cmr7araz701vlw8mp5pr3aus8	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr7ar6qr01uow8mp91cne35m	cmr7araz301vjw8mpywhqczvd	SAHIBB-558788	0.00	30.00	\N	2026-07-05 04:34:21.009	2026-07-05 04:34:26.516
cmr7dlid700ijw8rfms79990x	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr7dlekj00hqw8rfkfmw86iv	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-05 05:53:50.004	2026-07-05 05:53:55.003
cmr7dlidz00inw8rfj4hxqh1x	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr7dlekj00hqw8rfkfmw86iv	cmr7dlidm00ilw8rfv8jp6sqj	SAHIBB-558788	0.00	30.00	\N	2026-07-05 05:53:50.004	2026-07-05 05:53:55.032
cmr7du2z700uqw8rfaeh8hl92	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PURCHASE	cmr7dty1400txw8rftx02hajp	\N	SAHIBB-558788	30.00	0.00	\N	2026-07-05 06:00:28.509	2026-07-05 06:00:34.963
cmr7du2zi00uuw8rffjz993ek	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	PAYMENT	cmr7dty1400txw8rftx02hajp	cmr7du2zb00usw8rf1ynnwsr4	SAHIBB-558788	0.00	30.00	\N	2026-07-05 06:00:28.509	2026-07-05 06:00:34.974
\.


--
-- Data for Name: supplier_payments; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.supplier_payments (id, shop_id, supplier_id, amount, payment_method, money_box_id, notes, paid_at, created_at, payment_meta, bank_account_id) FROM stdin;
cmr0j5bkb000kw8b5dm9punsu	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 10:00:09.312	2026-06-30 10:54:54.156	null	\N
cmr0j5bpw0011w8b53vb3z9qb	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	1485.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 10:11:15.257	2026-06-30 10:54:54.357	null	\N
cmr0j5br0001qw8b5bviud82q	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	105780.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 10:24:29.103	2026-06-30 10:54:54.397	null	\N
cmr0j5brx0025w8b5typl2524	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	75000.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 10:32:10.262	2026-06-30 10:54:54.43	null	\N
cmr0jdqf2000ew8s3fbvf5jol	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	900.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 11:01:15.138	2026-06-30 11:01:26.654	null	\N
cmr0jg0om000vw8s3cmyha3qf	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	125.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-06-30 11:02:58.56	2026-06-30 11:03:13.271	null	\N
cmr1l09od001sw8jo6knsomw4	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	2170.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-01 04:34:27.507	2026-07-01 04:34:43.837	null	\N
cmr2ye0r7004gw8zb4nu1shab	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	145.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 03:36:58.34	2026-07-02 03:37:06.643	null	\N
cmr2ylvab006lw8zb3tm7lyg0	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 03:43:05.099	2026-07-02 03:43:12.804	null	\N
cmr2yuix100a4w8zby0ccg7t5	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	140.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 03:49:14.987	2026-07-02 03:49:56.677	null	\N
cmr2z124d001rw8hobpy0z98k	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	230.00	BKASH	cmr2z1235001ew8hocgj716rm	\N	2026-07-02 03:54:48.022	2026-07-02 03:55:01.501	{"senderNumber": "", "transactionId": ""}	\N
cmr2z8dqp001iw82pyotdujs5	cmr0gdhu7005kw8g06c2lngfc	cmr0h6b7x007kw8g0btebuoq1	525.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 03:50:47.004	2026-07-02 04:00:43.153	null	\N
cmr2z90to002nw82pep4u9atl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	105.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 04:01:04.727	2026-07-02 04:01:13.068	null	\N
cmr2zikg6005ew82p9oayvf3p	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	100.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 04:08:05.501	2026-07-02 04:08:38.406	null	\N
cmr2zq3gf008iw82p3zneltdx	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	270.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 04:14:21.583	2026-07-02 04:14:29.632	null	\N
cmr2zr11p00aiw82pufxtvm3r	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	290.00	BKASH	cmr2z1235001ew8hocgj716rm	\N	2026-07-02 04:14:57.062	2026-07-02 04:15:13.166	{"senderNumber": "", "transactionId": ""}	\N
cmr37tp7n006uw8yok1kb1fz4	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	150.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 08:00:54.307	2026-07-02 08:01:14.723	null	\N
cmr37uz2x007tw8yoo1skh6n8	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	105.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 04:09:25.051	2026-07-02 08:02:14.169	null	\N
cmr37w61r00abw8yocqpr809q	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	12445.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 08:03:02.842	2026-07-02 08:03:09.856	null	\N
cmr38mf44008kw896n3yz8exc	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	20290260.00	CASH	\N	Cash payment	2026-07-02 08:23:34.657	2026-07-02 08:23:34.66	null	\N
cmr38sapw00afw896vb6do4pp	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	105.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 04:01:48.438	2026-07-02 08:28:08.9	null	\N
cmr39a3kd00g8w896v5fjqm1u	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	255.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 08:41:34.191	2026-07-02 08:41:59.438	null	\N
cmr3drck000lyw87py7atpnj7	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	125.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-02 10:47:06.934	2026-07-02 10:47:22.705	null	\N
cmr5ta3pz006pw8ohmiwlyrf7	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	230.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-04 03:37:16.074	2026-07-04 03:37:24.312	null	\N
cmr7a2ogy019qw8mp4zoqk70q	cmr0gdhu7005kw8g06c2lngfc	cmr0h5bue007hw8g014mgncin	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 04:14:28.755	2026-07-05 04:15:17.602	null	\N
cmr7a3s1y01bxw8mp2lopxvrd	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 04:16:00.876	2026-07-05 04:16:08.902	null	\N
cmr7aagl101jsw8mpqftbpzfl	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 04:21:14.558	2026-07-05 04:21:20.63	null	\N
cmr7araz301vjw8mpywhqczvd	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 04:34:21.009	2026-07-05 04:34:26.511	null	\N
cmr7dlidm00ilw8rfv8jp6sqj	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 05:53:50.004	2026-07-05 05:53:55.019	null	\N
cmr7du2zb00usw8rf1ynnwsr4	cmr0gdhu7005kw8g06c2lngfc	cmr0hw4la008dw8g0nh4tkk30	30.00	CASH	cmr0j5bhv0003w8b5mjezmu9i	\N	2026-07-05 06:00:28.509	2026-07-05 06:00:34.968	null	\N
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.suppliers (id, supplier_code, name, mobile, email, address, contact_person, notes, status, created_at, updated_at, deleted_at, contact_person_mobile) FROM stdin;
cmqxor2bl001slxtkt5felngw	SHAKIB-815454	Shakib	01762161370	\N	Lalmatia	Grocery	\N	ACTIVE	2026-06-28 11:08:28.161	2026-06-28 11:08:28.161	\N	\N
cmr0h5bue007hw8g014mgncin	SSS-527935	sss	01767346592	\N	sfds	as	\N	ACTIVE	2026-06-30 09:58:55.286	2026-06-30 09:58:55.286	\N	\N
cmr0h6b7x007kw8g0btebuoq1	FFFF-112933	ffff	01734535345	\N	sdfds	sf	\N	ACTIVE	2026-06-30 09:59:41.133	2026-06-30 09:59:41.133	\N	\N
cmr0hw4la008dw8g0nh4tkk30	SAHIBB-558788	sahib bhai	01923487234	\N	sdfs	\N	\N	ACTIVE	2026-06-30 10:19:45.598	2026-06-30 10:19:45.598	\N	\N
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.units (id, name, short_name, type, description, status, created_at, updated_at, is_approved, is_global, shop_id) FROM stdin;
cmq3mskwq0000lxhmbmn95vjf	Piece	pcs	COUNTABLE	Count products individually as pieces.	ACTIVE	2026-06-07 10:20:34.394	2026-06-21 05:19:07.084	t	t	\N
cmq3mtdpk0001lxhmop3doo2e	Kilogram	kg	WEIGHT	Measure heavy goods by kilogram.	ACTIVE	2026-06-07 10:21:11.721	2026-06-21 05:19:07.092	t	t	\N
cmqnc6tzu000klxvsngzktou6	Gram	gm	WEIGHT	Measure smaller weight quantities.	ACTIVE	2026-06-21 05:19:07.098	2026-06-21 05:19:07.098	t	t	\N
cmq3mu2in0002lxhm5wvta8ea	Liter	ltr	VOLUME	Measure liquid products by liter.	ACTIVE	2026-06-07 10:21:43.871	2026-06-21 05:19:07.105	t	t	\N
cmqnc6u07000llxvs0446ainp	Box	box	PACKAGING	Bundle items in a single box.	INACTIVE	2026-06-21 05:19:07.112	2026-06-21 05:19:07.112	t	t	\N
cmqniohs20044lxbxq09orocg	Dozen	doz	COUNTABLE	12 pieces	ACTIVE	2026-06-21 08:20:48.771	2026-06-21 08:20:48.771	t	t	\N
cmqniohsl0045lxbx0my9b9hv	Pair	pair	COUNTABLE	2 pieces	ACTIVE	2026-06-21 08:20:48.79	2026-06-21 08:20:48.79	t	t	\N
cmqnioht30046lxbxwj3lztur	Pack	pack	COUNTABLE	Packaged items	ACTIVE	2026-06-21 08:20:48.807	2026-06-21 08:20:48.807	t	t	\N
cmqniohtm0047lxbxj89vbfz3	Carton	ctn	COUNTABLE	Carton packaging	ACTIVE	2026-06-21 08:20:48.827	2026-06-21 08:20:48.827	t	t	\N
cmqniohu70048lxbxmrklf01h	Bottle	btl	COUNTABLE	Bottle item	ACTIVE	2026-06-21 08:20:48.847	2026-06-21 08:20:48.847	t	t	\N
cmqniohur0049lxbxe5temwa1	Can	can	COUNTABLE	Can item	ACTIVE	2026-06-21 08:20:48.867	2026-06-21 08:20:48.867	t	t	\N
cmqniohv6004alxbxt2azfouu	Jar	jar	COUNTABLE	Jar item	ACTIVE	2026-06-21 08:20:48.882	2026-06-21 08:20:48.882	t	t	\N
cmqniohvo004blxbx9f4zwr54	Milligram	mg	COUNTABLE	Milligram	ACTIVE	2026-06-21 08:20:48.9	2026-06-21 08:20:48.9	t	t	\N
cmqniohw8004clxbx7isw9j6j	Ton	ton	COUNTABLE	1000 kilograms	ACTIVE	2026-06-21 08:20:48.92	2026-06-21 08:20:48.92	t	t	\N
cmqniohwt004dlxbx5vzy5qq8	Milliliter	ml	COUNTABLE	Milliliter	ACTIVE	2026-06-21 08:20:48.941	2026-06-21 08:20:48.941	t	t	\N
cmqniohxe004elxbxklgv50is	Gallon	gal	COUNTABLE	Gallon	ACTIVE	2026-06-21 08:20:48.962	2026-06-21 08:20:48.962	t	t	\N
cmqniohxv004flxbx98aymjyy	Meter	m	COUNTABLE	Meter	ACTIVE	2026-06-21 08:20:48.98	2026-06-21 08:20:48.98	t	t	\N
cmqniohyl004glxbxlmmqy991	Centimeter	cm	COUNTABLE	Centimeter	ACTIVE	2026-06-21 08:20:49.005	2026-06-21 08:20:49.005	t	t	\N
cmqniohz4004hlxbxl0zwdm8v	Foot	ft	COUNTABLE	Foot	ACTIVE	2026-06-21 08:20:49.024	2026-06-21 08:20:49.024	t	t	\N
cmqniohzi004ilxbxz42otm95	Inch	in	COUNTABLE	Inch	ACTIVE	2026-06-21 08:20:49.039	2026-06-21 08:20:49.039	t	t	\N
cmqnioi01004jlxbxw4a8dclj	Square Foot	sqft	COUNTABLE	Area measurement	ACTIVE	2026-06-21 08:20:49.058	2026-06-21 08:20:49.058	t	t	\N
cmqnioi0m004klxbxcyhawuvi	Square Meter	sqm	COUNTABLE	Area measurement	ACTIVE	2026-06-21 08:20:49.078	2026-06-21 08:20:49.078	t	t	\N
cmqnioi1c004llxbxguxw318q	Roll	roll	COUNTABLE	Roll item	ACTIVE	2026-06-21 08:20:49.105	2026-06-21 08:20:49.105	t	t	\N
cmqnioi1y004mlxbxy01aj564	Bundle	bundle	COUNTABLE	Bundle item	ACTIVE	2026-06-21 08:20:49.126	2026-06-21 08:20:49.126	t	t	\N
cmqnioi2n004nlxbx7viweo3y	Bag	bag	COUNTABLE	Bag item	ACTIVE	2026-06-21 08:20:49.152	2026-06-21 08:20:49.152	t	t	\N
cmqnioi3g004olxbxq8xtqddc	Sack	sack	COUNTABLE	Sack item	ACTIVE	2026-06-21 08:20:49.18	2026-06-21 08:20:49.18	t	t	\N
cmqnioi49004plxbxci2lfgq2	Tray	tray	COUNTABLE	Tray item	ACTIVE	2026-06-21 08:20:49.21	2026-06-21 08:20:49.21	t	t	\N
cmqnioi53004qlxbxlegc3jzo	Packet	pkt	COUNTABLE	Packet item	ACTIVE	2026-06-21 08:20:49.239	2026-06-21 08:20:49.239	t	t	\N
cmqnioi5y004rlxbxvmvrc7v0	Tube	tube	COUNTABLE	Tube item	ACTIVE	2026-06-21 08:20:49.27	2026-06-21 08:20:49.27	t	t	\N
cmqnioi6s004slxbx73lqrmi1	Unit	unit	COUNTABLE	Generic unit	ACTIVE	2026-06-21 08:20:49.301	2026-06-21 08:20:49.301	t	t	\N
cmqnioi7l004tlxbxzq7m4zpn	Set	set	COUNTABLE	Set of items	ACTIVE	2026-06-21 08:20:49.329	2026-06-21 08:20:49.329	t	t	\N
cmqniuglo004ulxbx8chhwpkj	Quintal	QTL	WEIGHT	100 kilograms	ACTIVE	2026-06-21 08:25:27.18	2026-06-21 08:25:27.18	t	t	\N
cmqniuh2n004vlxbxvctxxeda	Pound	LB	WEIGHT	Imperial weight measurement unit	ACTIVE	2026-06-21 08:25:27.792	2026-06-21 08:25:27.792	t	t	\N
cmqniuh3y004wlxbx9tuw8hgh	Ounce	OZ	WEIGHT	Imperial small weight unit	ACTIVE	2026-06-21 08:25:27.838	2026-06-21 08:25:27.838	t	t	\N
cmqniuh5p004xlxbxnguil7nn	Maund	MD	WEIGHT	Traditional bulk weight unit	ACTIVE	2026-06-21 08:25:27.901	2026-06-21 08:25:27.901	t	t	\N
cmqniuh73004ylxbx6spbtp1q	Seer	SEER	WEIGHT	Traditional weight unit	ACTIVE	2026-06-21 08:25:27.952	2026-06-21 08:25:27.952	t	t	\N
cmqniuh7r004zlxbxqm59aef4	Half Kilogram	500G	WEIGHT	500 gram weight pack	ACTIVE	2026-06-21 08:25:27.976	2026-06-21 08:25:27.976	t	t	\N
cmqniuh9g0050lxbxnbh6xh5w	Quarter Kilogram	250G	WEIGHT	250 gram weight pack	ACTIVE	2026-06-21 08:25:28.036	2026-06-21 08:25:28.036	t	t	\N
cmqniuhav0051lxbxidytf6et	One Hundred Gram	100G	WEIGHT	100 gram retail pack	ACTIVE	2026-06-21 08:25:28.087	2026-06-21 08:25:28.087	t	t	\N
cmqniuhcp0052lxbxxxi9pqg6	Fifty Gram	50G	WEIGHT	50 gram retail pack	ACTIVE	2026-06-21 08:25:28.154	2026-06-21 08:25:28.154	t	t	\N
cmqniuhe90053lxbxxlfz22lz	Twenty Five Gram	25G	WEIGHT	25 gram retail pack	ACTIVE	2026-06-21 08:25:28.208	2026-06-21 08:25:28.208	t	t	\N
cmqniuhfx0054lxbxon0gei8y	Fluid Ounce	FLOZ	VOLUME	Small liquid volume unit	ACTIVE	2026-06-21 08:25:28.268	2026-06-21 08:25:28.268	t	t	\N
cmqniuhh10055lxbxjy1d7jkp	Cubic Meter	CBM	VOLUME	Large volume measurement unit	ACTIVE	2026-06-21 08:25:28.31	2026-06-21 08:25:28.31	t	t	\N
cmqniuhiu0056lxbx9tsq4fpp	Cubic Centimeter	CC	VOLUME	Small volume measurement unit	ACTIVE	2026-06-21 08:25:28.375	2026-06-21 08:25:28.375	t	t	\N
cmqniuhk40057lxbx9wmwjwlr	Half Liter	500ML	VOLUME	500 milliliter liquid pack	ACTIVE	2026-06-21 08:25:28.421	2026-06-21 08:25:28.421	t	t	\N
cmqniuhle0058lxbx5mc2nhzo	Quarter Liter	250ML	VOLUME	250 milliliter liquid pack	ACTIVE	2026-06-21 08:25:28.463	2026-06-21 08:25:28.463	t	t	\N
cmqniuhms0059lxbxurc7jvsz	One Hundred Milliliter	100ML	VOLUME	100 milliliter retail pack	ACTIVE	2026-06-21 08:25:28.516	2026-06-21 08:25:28.516	t	t	\N
cmqniuhns005alxbxo7uqrgau	Fifty Milliliter	50ML	VOLUME	50 milliliter retail pack	ACTIVE	2026-06-21 08:25:28.552	2026-06-21 08:25:28.552	t	t	\N
cmqniuhpd005blxbxh4y49z98	Twenty Five Milliliter	25ML	VOLUME	25 milliliter retail pack	ACTIVE	2026-06-21 08:25:28.609	2026-06-21 08:25:28.609	t	t	\N
cmqniuhtt005clxbxmq9x9hil	Case	CASE	PACKAGING	Case packaging unit	ACTIVE	2026-06-21 08:25:28.769	2026-06-21 08:25:28.769	t	t	\N
cmqniuhuj005dlxbxxg6yhnm5	Tin	TIN	PACKAGING	Tin container unit	ACTIVE	2026-06-21 08:25:28.795	2026-06-21 08:25:28.795	t	t	\N
cmqniuhuv005elxbxn9fqk971	Drum	DRUM	PACKAGING	Large drum container unit	ACTIVE	2026-06-21 08:25:28.807	2026-06-21 08:25:28.807	t	t	\N
cmqniuhv7005flxbx598lyekm	Barrel	BBL	PACKAGING	Bulk barrel unit	ACTIVE	2026-06-21 08:25:28.82	2026-06-21 08:25:28.82	t	t	\N
cmqniuhvl005glxbx9jb559vq	Strip	STRIP	PACKAGING	Medicine strip or small strip pack	ACTIVE	2026-06-21 08:25:28.834	2026-06-21 08:25:28.834	t	t	\N
cmqniuhvz005hlxbxdlmk9rm7	Blister	BLSTR	PACKAGING	Blister packaging unit	ACTIVE	2026-06-21 08:25:28.847	2026-06-21 08:25:28.847	t	t	\N
cmqniuhwg005ilxbxldabwvuv	Pouch	POUCH	PACKAGING	Pouch packaging unit	ACTIVE	2026-06-21 08:25:28.864	2026-06-21 08:25:28.864	t	t	\N
cmqniuhwy005jlxbx8ctnghn9	Cart	CART	PACKAGING	Cart packaging unit	ACTIVE	2026-06-21 08:25:28.883	2026-06-21 08:25:28.883	t	t	\N
cmqniuhxc005klxbxrrc45lmy	Container	CONT	PACKAGING	Container packaging unit	ACTIVE	2026-06-21 08:25:28.896	2026-06-21 08:25:28.896	t	t	\N
cmqniuhy0005llxbxltddb65w	Pallet	PLT	PACKAGING	Pallet packaging unit	ACTIVE	2026-06-21 08:25:28.921	2026-06-21 08:25:28.921	t	t	\N
cmqniuhye005mlxbxk9uue8wc	Crate	CRATE	PACKAGING	Crate packaging unit	ACTIVE	2026-06-21 08:25:28.935	2026-06-21 08:25:28.935	t	t	\N
cmqniuhyt005nlxbxgs6gq02y	Wrapper	WRAP	PACKAGING	Wrapper packaging unit	ACTIVE	2026-06-21 08:25:28.95	2026-06-21 08:25:28.95	t	t	\N
cmqniuhz9005olxbxibdpml8o	Cone	CONE	PACKAGING	Cone packaging unit	ACTIVE	2026-06-21 08:25:28.966	2026-06-21 08:25:28.966	t	t	\N
cmqniuhzo005plxbxy2lftvav	Millimeter	MM	LENGTH	Very small length measurement unit	ACTIVE	2026-06-21 08:25:28.981	2026-06-21 08:25:28.981	t	t	\N
cmqniui06005qlxbx2k5i6gau	Kilometer	KM	LENGTH	Large distance measurement unit	ACTIVE	2026-06-21 08:25:28.998	2026-06-21 08:25:28.998	t	t	\N
cmqniui0s005rlxbxslcrtz7z	Yard	YD	LENGTH	Imperial length unit	ACTIVE	2026-06-21 08:25:29.02	2026-06-21 08:25:29.02	t	t	\N
cmqniui19005slxbxr0ga07un	Running Foot	RFT	LENGTH	Continuous length in feet	ACTIVE	2026-06-21 08:25:29.037	2026-06-21 08:25:29.037	t	t	\N
cmqniui1n005tlxbx8jk3akkd	Running Meter	RM	LENGTH	Continuous length in meters	ACTIVE	2026-06-21 08:25:29.052	2026-06-21 08:25:29.052	t	t	\N
cmqniui22005ulxbxdwku1sgv	Square Inch	SQIN	AREA	Area measurement in square inches	ACTIVE	2026-06-21 08:25:29.067	2026-06-21 08:25:29.067	t	t	\N
cmqniui2i005vlxbx3nfpe9op	Square Yard	SQYD	AREA	Area measurement in square yards	ACTIVE	2026-06-21 08:25:29.082	2026-06-21 08:25:29.082	t	t	\N
cmqniui2v005wlxbx791ka92u	Decimal	DEC	AREA	Land area measurement unit	ACTIVE	2026-06-21 08:25:29.095	2026-06-21 08:25:29.095	t	t	\N
cmqniui38005xlxbxo5b16l7b	Katha	KATHA	AREA	Land area measurement unit	ACTIVE	2026-06-21 08:25:29.108	2026-06-21 08:25:29.108	t	t	\N
cmqniui3l005ylxbxoleu0xrb	Bigha	BIGHA	AREA	Land area measurement unit	ACTIVE	2026-06-21 08:25:29.121	2026-06-21 08:25:29.121	t	t	\N
cmqniui3y005zlxbx9fn32y6b	Acre	ACRE	AREA	Land area measurement unit	ACTIVE	2026-06-21 08:25:29.135	2026-06-21 08:25:29.135	t	t	\N
cmqniui4x0060lxbximy14jz1	Cup	CUP	VOLUME	Food and beverage serving unit	ACTIVE	2026-06-21 08:25:29.17	2026-06-21 08:25:29.17	t	t	\N
cmqniui5a0061lxbxclrb11id	Glass	GLASS	VOLUME	Beverage serving unit	ACTIVE	2026-06-21 08:25:29.182	2026-06-21 08:25:29.182	t	t	\N
cmqniui6r0062lxbx4ikdkm52	Vial	VIAL	PACKAGING	Medicine vial packaging unit	ACTIVE	2026-06-21 08:25:29.236	2026-06-21 08:25:29.236	t	t	\N
cmqniui770063lxbxqzpnattr	Ampoule	AMP	PACKAGING	Injection ampoule unit	ACTIVE	2026-06-21 08:25:29.252	2026-06-21 08:25:29.252	t	t	\N
cmqniui7k0064lxbxjjpttzs7	Sachet	SAC	PACKAGING	Small sachet packaging unit	ACTIVE	2026-06-21 08:25:29.265	2026-06-21 08:25:29.265	t	t	\N
cmqniui7x0065lxbxn5h9bdto	Drop	DROP	VOLUME	Small medicine drop unit	ACTIVE	2026-06-21 08:25:29.277	2026-06-21 08:25:29.277	t	t	\N
\.


--
-- Data for Name: user_pins; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.user_pins (id, user_id, pin_hash, status, failed_attempts, locked_until, last_changed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: macbookair
--

COPY public.users (id, name, phone, email, password_hash, status, last_login_at, created_by_user_id, created_at, updated_at, profile_image_url, phone_verified_at) FROM stdin;
cmq3dt6o00004lxopt6mh88b2	Demo Admin	+8801000000009	admin@dokanerp.local	change-me-before-production	ACTIVE	\N	cmq3dt6mv0000lxophsbhevt3	2026-06-07 06:09:06.048	2026-06-21 05:19:06.957	\N	\N
cmq3dt6mv0000lxophsbhevt3	Demo Super Admin	+8801000000000	superadmin@dokanerp.local	12345678	ACTIVE	2026-06-21 11:27:09.298	\N	2026-06-07 06:09:06.007	2026-06-21 11:27:09.299	\N	\N
cmqtek0uk0000lxj659fzko6g	Syed Fahad Mahmud	01880561928	\N	12345678	ACTIVE	2026-07-02 08:10:24.721	\N	2026-06-25 11:11:58.796	2026-07-02 08:10:24.722	\N	\N
cmr0gdhs5005iw8g0cqf5tgmo	sakib bd	\N	\N	1234	ACTIVE	2026-07-04 09:02:57.909	\N	2026-06-30 09:37:16.613	2026-07-04 11:37:41.808	\N	\N
\.


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: category_logs category_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.category_logs
    ADD CONSTRAINT category_logs_pkey PRIMARY KEY (id);


--
-- Name: customer_ledgers customer_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_ledgers
    ADD CONSTRAINT customer_ledgers_pkey PRIMARY KEY (id);


--
-- Name: customer_payments customer_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_pkey PRIMARY KEY (id);


--
-- Name: customer_sale_items customer_sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sale_items
    ADD CONSTRAINT customer_sale_items_pkey PRIMARY KEY (id);


--
-- Name: customer_sales customer_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: in_app_notifications in_app_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.in_app_notifications
    ADD CONSTRAINT in_app_notifications_pkey PRIMARY KEY (id);


--
-- Name: inventory_bin_items inventory_bin_items_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bin_items
    ADD CONSTRAINT inventory_bin_items_pkey PRIMARY KEY (id);


--
-- Name: inventory_bins inventory_bins_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bins
    ADD CONSTRAINT inventory_bins_pkey PRIMARY KEY (id);


--
-- Name: inventory_racks inventory_racks_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_racks
    ADD CONSTRAINT inventory_racks_pkey PRIMARY KEY (id);


--
-- Name: inventory_shelves inventory_shelves_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_shelves
    ADD CONSTRAINT inventory_shelves_pkey PRIMARY KEY (id);


--
-- Name: inventory_zones inventory_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_zones
    ADD CONSTRAINT inventory_zones_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: master_product_barcodes master_product_barcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_barcodes
    ADD CONSTRAINT master_product_barcodes_pkey PRIMARY KEY (id);


--
-- Name: master_product_requests master_product_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_requests
    ADD CONSTRAINT master_product_requests_pkey PRIMARY KEY (id);


--
-- Name: master_products master_products_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_pkey PRIMARY KEY (id);


--
-- Name: money_boxes money_boxes_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.money_boxes
    ADD CONSTRAINT money_boxes_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: owner_registration_drafts owner_registration_drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.owner_registration_drafts
    ADD CONSTRAINT owner_registration_drafts_pkey PRIMARY KEY (id);


--
-- Name: password_reset_requests password_reset_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.password_reset_requests
    ADD CONSTRAINT password_reset_requests_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: platform_users platform_users_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.platform_users
    ADD CONSTRAINT platform_users_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_template_items product_template_items_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_template_items
    ADD CONSTRAINT product_template_items_pkey PRIMARY KEY (id);


--
-- Name: product_templates product_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_templates
    ADD CONSTRAINT product_templates_pkey PRIMARY KEY (id);


--
-- Name: purchase_items purchase_items_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_return_items purchase_return_items_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_returns purchase_returns_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_pkey PRIMARY KEY (id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: salesman_permissions salesman_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.salesman_permissions
    ADD CONSTRAINT salesman_permissions_pkey PRIMARY KEY (id);


--
-- Name: shop_charges shop_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_charges
    ADD CONSTRAINT shop_charges_pkey PRIMARY KEY (id);


--
-- Name: shop_inventory_settings shop_inventory_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_inventory_settings
    ADD CONSTRAINT shop_inventory_settings_pkey PRIMARY KEY (id);


--
-- Name: shop_products shop_products_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_products
    ADD CONSTRAINT shop_products_pkey PRIMARY KEY (id);


--
-- Name: shop_receipt_settings shop_receipt_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_receipt_settings
    ADD CONSTRAINT shop_receipt_settings_pkey PRIMARY KEY (id);


--
-- Name: shop_taxes shop_taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_taxes
    ADD CONSTRAINT shop_taxes_pkey PRIMARY KEY (id);


--
-- Name: shop_users shop_users_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_users
    ADD CONSTRAINT shop_users_pkey PRIMARY KEY (id);


--
-- Name: shops shops_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: supplier_ledgers supplier_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_ledgers
    ADD CONSTRAINT supplier_ledgers_pkey PRIMARY KEY (id);


--
-- Name: supplier_payments supplier_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: user_pins user_pins_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.user_pins
    ADD CONSTRAINT user_pins_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts_bank_name_account_number_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX bank_accounts_bank_name_account_number_key ON public.bank_accounts USING btree (bank_name, account_number);


--
-- Name: bank_accounts_bank_name_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX bank_accounts_bank_name_idx ON public.bank_accounts USING btree (bank_name);


--
-- Name: bank_accounts_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX bank_accounts_shop_id_idx ON public.bank_accounts USING btree (shop_id);


--
-- Name: bank_accounts_shop_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX bank_accounts_shop_id_status_idx ON public.bank_accounts USING btree (shop_id, status);


--
-- Name: brands_name_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX brands_name_key ON public.brands USING btree (name);


--
-- Name: brands_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX brands_status_idx ON public.brands USING btree (status);


--
-- Name: category_logs_category_id_created_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX category_logs_category_id_created_at_idx ON public.category_logs USING btree (category_id, created_at);


--
-- Name: customer_ledgers_customer_payment_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_ledgers_customer_payment_id_idx ON public.customer_ledgers USING btree (customer_payment_id);


--
-- Name: customer_ledgers_customer_sale_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_ledgers_customer_sale_id_idx ON public.customer_ledgers USING btree (customer_sale_id);


--
-- Name: customer_ledgers_shop_id_customer_id_entry_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_ledgers_shop_id_customer_id_entry_date_idx ON public.customer_ledgers USING btree (shop_id, customer_id, entry_date);


--
-- Name: customer_payments_customer_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_payments_customer_id_idx ON public.customer_payments USING btree (customer_id);


--
-- Name: customer_payments_paid_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_payments_paid_at_idx ON public.customer_payments USING btree (paid_at);


--
-- Name: customer_payments_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_payments_shop_id_idx ON public.customer_payments USING btree (shop_id);


--
-- Name: customer_sale_items_customer_sale_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sale_items_customer_sale_id_idx ON public.customer_sale_items USING btree (customer_sale_id);


--
-- Name: customer_sale_items_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sale_items_master_product_id_idx ON public.customer_sale_items USING btree (master_product_id);


--
-- Name: customer_sales_created_by_user_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sales_created_by_user_id_idx ON public.customer_sales USING btree (created_by_user_id);


--
-- Name: customer_sales_customer_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sales_customer_id_idx ON public.customer_sales USING btree (customer_id);


--
-- Name: customer_sales_sale_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sales_sale_date_idx ON public.customer_sales USING btree (sale_date);


--
-- Name: customer_sales_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customer_sales_shop_id_idx ON public.customer_sales USING btree (shop_id);


--
-- Name: customers_customer_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX customers_customer_code_key ON public.customers USING btree (customer_code);


--
-- Name: customers_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX customers_status_idx ON public.customers USING btree (status);


--
-- Name: expenses_bank_account_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX expenses_bank_account_id_idx ON public.expenses USING btree (bank_account_id);


--
-- Name: expenses_money_box_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX expenses_money_box_id_idx ON public.expenses USING btree (money_box_id);


--
-- Name: expenses_shop_id_expense_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX expenses_shop_id_expense_date_idx ON public.expenses USING btree (shop_id, expense_date);


--
-- Name: inventory_bin_items_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_bin_items_master_product_id_idx ON public.inventory_bin_items USING btree (master_product_id);


--
-- Name: inventory_bin_items_purchase_item_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_bin_items_purchase_item_id_idx ON public.inventory_bin_items USING btree (purchase_item_id);


--
-- Name: inventory_bin_items_shop_id_bin_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_bin_items_shop_id_bin_id_idx ON public.inventory_bin_items USING btree (shop_id, bin_id);


--
-- Name: inventory_bins_shop_id_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX inventory_bins_shop_id_code_key ON public.inventory_bins USING btree (shop_id, code);


--
-- Name: inventory_bins_shop_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_bins_shop_id_status_idx ON public.inventory_bins USING btree (shop_id, status);


--
-- Name: inventory_bins_shop_id_zone_id_rack_id_shelf_id_sort_order_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_bins_shop_id_zone_id_rack_id_shelf_id_sort_order_idx ON public.inventory_bins USING btree (shop_id, zone_id, rack_id, shelf_id, sort_order);


--
-- Name: inventory_racks_shop_id_zone_id_name_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX inventory_racks_shop_id_zone_id_name_key ON public.inventory_racks USING btree (shop_id, zone_id, name);


--
-- Name: inventory_racks_shop_id_zone_id_sort_order_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_racks_shop_id_zone_id_sort_order_idx ON public.inventory_racks USING btree (shop_id, zone_id, sort_order);


--
-- Name: inventory_shelves_shop_id_rack_id_name_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX inventory_shelves_shop_id_rack_id_name_key ON public.inventory_shelves USING btree (shop_id, rack_id, name);


--
-- Name: inventory_shelves_shop_id_zone_id_rack_id_sort_order_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_shelves_shop_id_zone_id_rack_id_sort_order_idx ON public.inventory_shelves USING btree (shop_id, zone_id, rack_id, sort_order);


--
-- Name: inventory_zones_shop_id_name_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX inventory_zones_shop_id_name_key ON public.inventory_zones USING btree (shop_id, name);


--
-- Name: inventory_zones_shop_id_sort_order_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX inventory_zones_shop_id_sort_order_idx ON public.inventory_zones USING btree (shop_id, sort_order);


--
-- Name: invoices_shop_id_billing_date_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX invoices_shop_id_billing_date_key ON public.invoices USING btree (shop_id, billing_date);


--
-- Name: invoices_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX invoices_status_idx ON public.invoices USING btree (status);


--
-- Name: master_product_barcodes_barcode_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX master_product_barcodes_barcode_key ON public.master_product_barcodes USING btree (barcode);


--
-- Name: master_product_barcodes_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_product_barcodes_master_product_id_idx ON public.master_product_barcodes USING btree (master_product_id);


--
-- Name: master_product_barcodes_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_product_barcodes_status_idx ON public.master_product_barcodes USING btree (status);


--
-- Name: master_product_requests_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_product_requests_master_product_id_idx ON public.master_product_requests USING btree (master_product_id);


--
-- Name: master_product_requests_shop_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_product_requests_shop_id_status_idx ON public.master_product_requests USING btree (shop_id, status);


--
-- Name: master_products_brand_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_products_brand_id_idx ON public.master_products USING btree (brand_id);


--
-- Name: master_products_category_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_products_category_id_idx ON public.master_products USING btree (category_id);


--
-- Name: master_products_sku_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX master_products_sku_key ON public.master_products USING btree (sku);


--
-- Name: master_products_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_products_status_idx ON public.master_products USING btree (status);


--
-- Name: master_products_unit_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX master_products_unit_id_idx ON public.master_products USING btree (unit_id);


--
-- Name: money_boxes_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX money_boxes_code_key ON public.money_boxes USING btree (code);


--
-- Name: money_boxes_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX money_boxes_shop_id_idx ON public.money_boxes USING btree (shop_id);


--
-- Name: money_boxes_shop_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX money_boxes_shop_id_status_idx ON public.money_boxes USING btree (shop_id, status);


--
-- Name: notification_settings_shop_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX notification_settings_shop_id_key ON public.notification_settings USING btree (shop_id);


--
-- Name: otp_verifications_expires_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX otp_verifications_expires_at_idx ON public.otp_verifications USING btree (expires_at);


--
-- Name: otp_verifications_recipient_purpose_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX otp_verifications_recipient_purpose_status_idx ON public.otp_verifications USING btree (recipient, purpose, status);


--
-- Name: otp_verifications_shop_id_purpose_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX otp_verifications_shop_id_purpose_status_idx ON public.otp_verifications USING btree (shop_id, purpose, status);


--
-- Name: otp_verifications_user_id_purpose_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX otp_verifications_user_id_purpose_status_idx ON public.otp_verifications USING btree (user_id, purpose, status);


--
-- Name: owner_registration_drafts_expires_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX owner_registration_drafts_expires_at_idx ON public.owner_registration_drafts USING btree (expires_at);


--
-- Name: owner_registration_drafts_mobile_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX owner_registration_drafts_mobile_status_idx ON public.owner_registration_drafts USING btree (mobile, status);


--
-- Name: owner_registration_drafts_otp_verification_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX owner_registration_drafts_otp_verification_id_key ON public.owner_registration_drafts USING btree (otp_verification_id);


--
-- Name: owner_registration_drafts_shop_name_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX owner_registration_drafts_shop_name_status_idx ON public.owner_registration_drafts USING btree (shop_name, status);


--
-- Name: password_reset_requests_expires_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX password_reset_requests_expires_at_idx ON public.password_reset_requests USING btree (expires_at);


--
-- Name: password_reset_requests_otp_verification_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX password_reset_requests_otp_verification_id_key ON public.password_reset_requests USING btree (otp_verification_id);


--
-- Name: password_reset_requests_shop_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX password_reset_requests_shop_id_status_idx ON public.password_reset_requests USING btree (shop_id, status);


--
-- Name: password_reset_requests_user_id_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX password_reset_requests_user_id_status_idx ON public.password_reset_requests USING btree (user_id, status);


--
-- Name: payments_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX payments_shop_id_idx ON public.payments USING btree (shop_id);


--
-- Name: payments_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX payments_status_idx ON public.payments USING btree (status);


--
-- Name: platform_users_user_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX platform_users_user_id_key ON public.platform_users USING btree (user_id);


--
-- Name: product_categories_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX product_categories_shop_id_idx ON public.product_categories USING btree (shop_id);


--
-- Name: product_categories_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX product_categories_status_idx ON public.product_categories USING btree (status);


--
-- Name: product_template_items_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX product_template_items_master_product_id_idx ON public.product_template_items USING btree (master_product_id);


--
-- Name: product_template_items_template_id_master_product_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX product_template_items_template_id_master_product_id_key ON public.product_template_items USING btree (template_id, master_product_id);


--
-- Name: product_templates_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX product_templates_code_key ON public.product_templates USING btree (code);


--
-- Name: product_templates_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX product_templates_status_idx ON public.product_templates USING btree (status);


--
-- Name: purchase_items_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_items_master_product_id_idx ON public.purchase_items USING btree (master_product_id);


--
-- Name: purchase_items_purchase_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_items_purchase_id_idx ON public.purchase_items USING btree (purchase_id);


--
-- Name: purchase_return_items_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_return_items_master_product_id_idx ON public.purchase_return_items USING btree (master_product_id);


--
-- Name: purchase_return_items_purchase_item_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_return_items_purchase_item_id_idx ON public.purchase_return_items USING btree (purchase_item_id);


--
-- Name: purchase_return_items_purchase_return_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_return_items_purchase_return_id_idx ON public.purchase_return_items USING btree (purchase_return_id);


--
-- Name: purchase_returns_shop_id_purchase_id_return_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_returns_shop_id_purchase_id_return_date_idx ON public.purchase_returns USING btree (shop_id, purchase_id, return_date);


--
-- Name: purchase_returns_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_returns_status_idx ON public.purchase_returns USING btree (status);


--
-- Name: purchase_returns_supplier_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchase_returns_supplier_id_idx ON public.purchase_returns USING btree (supplier_id);


--
-- Name: purchases_approved_by_user_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_approved_by_user_id_idx ON public.purchases USING btree (approved_by_user_id);


--
-- Name: purchases_created_by_user_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_created_by_user_id_idx ON public.purchases USING btree (created_by_user_id);


--
-- Name: purchases_purchase_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_purchase_date_idx ON public.purchases USING btree (purchase_date);


--
-- Name: purchases_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_shop_id_idx ON public.purchases USING btree (shop_id);


--
-- Name: purchases_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_status_idx ON public.purchases USING btree (status);


--
-- Name: purchases_supplier_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX purchases_supplier_id_idx ON public.purchases USING btree (supplier_id);


--
-- Name: refresh_tokens_family_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX refresh_tokens_family_idx ON public.refresh_tokens USING btree (family);


--
-- Name: refresh_tokens_token_hash_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX refresh_tokens_token_hash_key ON public.refresh_tokens USING btree (token_hash);


--
-- Name: refresh_tokens_user_id_family_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX refresh_tokens_user_id_family_idx ON public.refresh_tokens USING btree (user_id, family);


--
-- Name: salesman_permissions_shop_user_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX salesman_permissions_shop_user_id_key ON public.salesman_permissions USING btree (shop_user_id);


--
-- Name: shop_charges_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_charges_shop_id_idx ON public.shop_charges USING btree (shop_id);


--
-- Name: shop_inventory_settings_shop_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX shop_inventory_settings_shop_id_key ON public.shop_inventory_settings USING btree (shop_id);


--
-- Name: shop_products_approval_request_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_products_approval_request_id_idx ON public.shop_products USING btree (approval_request_id);


--
-- Name: shop_products_master_product_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_products_master_product_id_idx ON public.shop_products USING btree (master_product_id);


--
-- Name: shop_products_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_products_shop_id_idx ON public.shop_products USING btree (shop_id);


--
-- Name: shop_products_shop_id_master_product_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX shop_products_shop_id_master_product_id_key ON public.shop_products USING btree (shop_id, master_product_id);


--
-- Name: shop_receipt_settings_shop_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX shop_receipt_settings_shop_id_key ON public.shop_receipt_settings USING btree (shop_id);


--
-- Name: shop_taxes_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_taxes_shop_id_idx ON public.shop_taxes USING btree (shop_id);


--
-- Name: shop_users_shop_id_role_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shop_users_shop_id_role_idx ON public.shop_users USING btree (shop_id, role);


--
-- Name: shop_users_shop_id_user_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX shop_users_shop_id_user_id_key ON public.shop_users USING btree (shop_id, user_id);


--
-- Name: shops_shop_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX shops_shop_code_key ON public.shops USING btree (shop_code);


--
-- Name: shops_shop_name_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX shops_shop_name_idx ON public.shops USING btree (shop_name);


--
-- Name: stock_movements_shop_id_master_product_id_created_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX stock_movements_shop_id_master_product_id_created_at_idx ON public.stock_movements USING btree (shop_id, master_product_id, created_at);


--
-- Name: stock_movements_shop_id_shop_product_id_created_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX stock_movements_shop_id_shop_product_id_created_at_idx ON public.stock_movements USING btree (shop_id, shop_product_id, created_at);


--
-- Name: subscriptions_shop_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX subscriptions_shop_id_key ON public.subscriptions USING btree (shop_id);


--
-- Name: supplier_ledgers_purchase_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_ledgers_purchase_id_idx ON public.supplier_ledgers USING btree (purchase_id);


--
-- Name: supplier_ledgers_shop_id_supplier_id_entry_date_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_ledgers_shop_id_supplier_id_entry_date_idx ON public.supplier_ledgers USING btree (shop_id, supplier_id, entry_date);


--
-- Name: supplier_ledgers_supplier_payment_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_ledgers_supplier_payment_id_idx ON public.supplier_ledgers USING btree (supplier_payment_id);


--
-- Name: supplier_payments_bank_account_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_payments_bank_account_id_idx ON public.supplier_payments USING btree (bank_account_id);


--
-- Name: supplier_payments_paid_at_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_payments_paid_at_idx ON public.supplier_payments USING btree (paid_at);


--
-- Name: supplier_payments_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_payments_shop_id_idx ON public.supplier_payments USING btree (shop_id);


--
-- Name: supplier_payments_supplier_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX supplier_payments_supplier_id_idx ON public.supplier_payments USING btree (supplier_id);


--
-- Name: suppliers_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX suppliers_status_idx ON public.suppliers USING btree (status);


--
-- Name: suppliers_supplier_code_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX suppliers_supplier_code_key ON public.suppliers USING btree (supplier_code);


--
-- Name: units_shop_id_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX units_shop_id_idx ON public.units USING btree (shop_id);


--
-- Name: units_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX units_status_idx ON public.units USING btree (status);


--
-- Name: units_type_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX units_type_idx ON public.units USING btree (type);


--
-- Name: user_pins_status_idx; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE INDEX user_pins_status_idx ON public.user_pins USING btree (status);


--
-- Name: user_pins_user_id_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX user_pins_user_id_key ON public.user_pins USING btree (user_id);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_phone_key; Type: INDEX; Schema: public; Owner: macbookair
--

CREATE UNIQUE INDEX users_phone_key ON public.users USING btree (phone);


--
-- Name: bank_accounts bank_accounts_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: brands brands_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: brands brands_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: category_logs category_logs_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.category_logs
    ADD CONSTRAINT category_logs_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: category_logs category_logs_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.category_logs
    ADD CONSTRAINT category_logs_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_ledgers customer_ledgers_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_ledgers
    ADD CONSTRAINT customer_ledgers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_ledgers customer_ledgers_customer_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_ledgers
    ADD CONSTRAINT customer_ledgers_customer_payment_id_fkey FOREIGN KEY (customer_payment_id) REFERENCES public.customer_payments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_ledgers customer_ledgers_customer_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_ledgers
    ADD CONSTRAINT customer_ledgers_customer_sale_id_fkey FOREIGN KEY (customer_sale_id) REFERENCES public.customer_sales(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_ledgers customer_ledgers_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_ledgers
    ADD CONSTRAINT customer_ledgers_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_payments customer_payments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_payments customer_payments_money_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_money_box_id_fkey FOREIGN KEY (money_box_id) REFERENCES public.money_boxes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_payments customer_payments_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_sale_items customer_sale_items_customer_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sale_items
    ADD CONSTRAINT customer_sale_items_customer_sale_id_fkey FOREIGN KEY (customer_sale_id) REFERENCES public.customer_sales(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_sale_items customer_sale_items_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sale_items
    ADD CONSTRAINT customer_sale_items_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_sales customer_sales_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_sales customer_sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_sales customer_sales_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: expenses expenses_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: expenses expenses_money_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_money_box_id_fkey FOREIGN KEY (money_box_id) REFERENCES public.money_boxes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: expenses expenses_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: in_app_notifications in_app_notifications_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.in_app_notifications
    ADD CONSTRAINT in_app_notifications_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bin_items inventory_bin_items_bin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bin_items
    ADD CONSTRAINT inventory_bin_items_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES public.inventory_bins(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bin_items inventory_bin_items_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bin_items
    ADD CONSTRAINT inventory_bin_items_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bin_items inventory_bin_items_purchase_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bin_items
    ADD CONSTRAINT inventory_bin_items_purchase_item_id_fkey FOREIGN KEY (purchase_item_id) REFERENCES public.purchase_items(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: inventory_bin_items inventory_bin_items_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bin_items
    ADD CONSTRAINT inventory_bin_items_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bins inventory_bins_rack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bins
    ADD CONSTRAINT inventory_bins_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES public.inventory_racks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bins inventory_bins_shelf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bins
    ADD CONSTRAINT inventory_bins_shelf_id_fkey FOREIGN KEY (shelf_id) REFERENCES public.inventory_shelves(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bins inventory_bins_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bins
    ADD CONSTRAINT inventory_bins_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_bins inventory_bins_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_bins
    ADD CONSTRAINT inventory_bins_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.inventory_zones(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_racks inventory_racks_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_racks
    ADD CONSTRAINT inventory_racks_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_racks inventory_racks_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_racks
    ADD CONSTRAINT inventory_racks_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.inventory_zones(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_shelves inventory_shelves_rack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_shelves
    ADD CONSTRAINT inventory_shelves_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES public.inventory_racks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_shelves inventory_shelves_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_shelves
    ADD CONSTRAINT inventory_shelves_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_shelves inventory_shelves_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_shelves
    ADD CONSTRAINT inventory_shelves_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.inventory_zones(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_zones inventory_zones_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.inventory_zones
    ADD CONSTRAINT inventory_zones_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: master_product_barcodes master_product_barcodes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_barcodes
    ADD CONSTRAINT master_product_barcodes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_barcodes master_product_barcodes_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_barcodes
    ADD CONSTRAINT master_product_barcodes_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_barcodes master_product_barcodes_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_barcodes
    ADD CONSTRAINT master_product_barcodes_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_requests master_product_requests_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_requests
    ADD CONSTRAINT master_product_requests_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_requests master_product_requests_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_requests
    ADD CONSTRAINT master_product_requests_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_requests master_product_requests_reviewed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_requests
    ADD CONSTRAINT master_product_requests_reviewed_by_user_id_fkey FOREIGN KEY (reviewed_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_product_requests master_product_requests_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_product_requests
    ADD CONSTRAINT master_product_requests_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: master_products master_products_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_products master_products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_products master_products_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_products master_products_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: master_products master_products_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.master_products
    ADD CONSTRAINT master_products_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: money_boxes money_boxes_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.money_boxes
    ADD CONSTRAINT money_boxes_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification_settings notification_settings_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: otp_verifications otp_verifications_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: otp_verifications otp_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: owner_registration_drafts owner_registration_drafts_otp_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.owner_registration_drafts
    ADD CONSTRAINT owner_registration_drafts_otp_verification_id_fkey FOREIGN KEY (otp_verification_id) REFERENCES public.otp_verifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: owner_registration_drafts owner_registration_drafts_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.owner_registration_drafts
    ADD CONSTRAINT owner_registration_drafts_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: password_reset_requests password_reset_requests_otp_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.password_reset_requests
    ADD CONSTRAINT password_reset_requests_otp_verification_id_fkey FOREIGN KEY (otp_verification_id) REFERENCES public.otp_verifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: password_reset_requests password_reset_requests_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.password_reset_requests
    ADD CONSTRAINT password_reset_requests_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: password_reset_requests password_reset_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.password_reset_requests
    ADD CONSTRAINT password_reset_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payments payments_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: platform_users platform_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.platform_users
    ADD CONSTRAINT platform_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_categories product_categories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_categories product_categories_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_template_items product_template_items_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_template_items
    ADD CONSTRAINT product_template_items_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_template_items product_template_items_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.product_template_items
    ADD CONSTRAINT product_template_items_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.product_templates(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_items purchase_items_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: purchase_items purchase_items_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_return_items purchase_return_items_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: purchase_return_items purchase_return_items_purchase_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_purchase_item_id_fkey FOREIGN KEY (purchase_item_id) REFERENCES public.purchase_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_return_items purchase_return_items_purchase_return_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_purchase_return_id_fkey FOREIGN KEY (purchase_return_id) REFERENCES public.purchase_returns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_returns purchase_returns_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchase_returns purchase_returns_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchase_returns purchase_returns_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_returns purchase_returns_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchase_returns purchase_returns_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchases purchases_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchases purchases_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchases purchases_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: purchases purchases_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: salesman_permissions salesman_permissions_shop_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.salesman_permissions
    ADD CONSTRAINT salesman_permissions_shop_user_id_fkey FOREIGN KEY (shop_user_id) REFERENCES public.shop_users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_charges shop_charges_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_charges
    ADD CONSTRAINT shop_charges_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_inventory_settings shop_inventory_settings_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_inventory_settings
    ADD CONSTRAINT shop_inventory_settings_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_products shop_products_approval_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_products
    ADD CONSTRAINT shop_products_approval_request_id_fkey FOREIGN KEY (approval_request_id) REFERENCES public.master_product_requests(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shop_products shop_products_master_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_products
    ADD CONSTRAINT shop_products_master_product_id_fkey FOREIGN KEY (master_product_id) REFERENCES public.master_products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_products shop_products_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_products
    ADD CONSTRAINT shop_products_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_receipt_settings shop_receipt_settings_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_receipt_settings
    ADD CONSTRAINT shop_receipt_settings_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_taxes shop_taxes_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_taxes
    ADD CONSTRAINT shop_taxes_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_users shop_users_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_users
    ADD CONSTRAINT shop_users_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shop_users shop_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shop_users
    ADD CONSTRAINT shop_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shops shops_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: supplier_ledgers supplier_ledgers_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_ledgers
    ADD CONSTRAINT supplier_ledgers_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: supplier_ledgers supplier_ledgers_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_ledgers
    ADD CONSTRAINT supplier_ledgers_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: supplier_ledgers supplier_ledgers_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_ledgers
    ADD CONSTRAINT supplier_ledgers_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: supplier_ledgers supplier_ledgers_supplier_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_ledgers
    ADD CONSTRAINT supplier_ledgers_supplier_payment_id_fkey FOREIGN KEY (supplier_payment_id) REFERENCES public.supplier_payments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: supplier_payments supplier_payments_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: supplier_payments supplier_payments_money_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_money_box_id_fkey FOREIGN KEY (money_box_id) REFERENCES public.money_boxes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: supplier_payments supplier_payments_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: supplier_payments supplier_payments_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_pins user_pins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.user_pins
    ADD CONSTRAINT user_pins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macbookair
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict B8GZS2xgbHNr4g6CCuELT754gr7UEIpv0Y47sHx4mYiNFUaG2jQ6jazLHsIFGiE

