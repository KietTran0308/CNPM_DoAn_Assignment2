-- Catalog seed: safe to run against an existing BrewLite schema.
-- Does not update existing payment method settings.
INSERT INTO public.payment_methods (code, name, type, is_active) VALUES
    ('ZALOPAY', 'ZaloPay', 'GATEWAY', true),
    ('WALLET', 'Ví nội bộ', 'INTERNAL', false),
    ('CARD', 'Thẻ ngân hàng', 'GATEWAY', false)
ON CONFLICT (code) DO NOTHING;
