-- Demo data only. DO NOT run on a real production database.
-- The original data/recipes are maintained in dbBrewLite.sql.
BEGIN;
-- BREWLITE - POSTGRESQL 16 - OPTIONAL DEMO SEED ONLY
-- Runs AFTER seed_payment_methods.sql. Idempotent on conflicts: does not update existing records.
-- Do NOT run on production unless demo accounts, coupon fixtures and opening inventory are desired.
SET LOCAL TIME ZONE 'UTC';

INSERT INTO public.coupons (id, code, discount_type, discount_value, min_order_value, max_uses, used_count, is_active, valid_from, valid_to) VALUES
                                                                                                                                                 ('adbbacc5-1334-51f8-8f49-0804c79ef130', 'WELCOME10', 'PERCENT', '10.00', '30000.00', '100', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('653cb812-382c-5f3f-ab46-644a131aca3b', 'FREESHIP5', 'FIXED', '5000.00', '35000.00', '120', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('9db61425-bfe9-5a73-aff5-36afc90c654c', 'GIAM10K', 'FIXED', '10000.00', '70000.00', '80', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('b2819e57-731d-589f-9502-160dd1f685a7', 'CAFE20', 'PERCENT', '20.00', '90000.00', '50', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('05e690cc-5779-51ea-8363-0e9a810ea085', 'LOYA5K', 'FIXED', '5000.00', '45000.00', '100', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('352c856d-4fdf-501c-8770-41ab24a770a6', 'EXPIRED10', 'PERCENT', '10.00', '30000.00', '15', '0', 't', '2026-07-27 17:57:02.446613', '2026-10-20 17:57:02.446613'),
                                                                                                                                                 ('9121ba0a-9f7f-5381-a190-048874304192', 'INACTIVE5', 'FIXED', '5000.00', '40000.00', '20', '0', 'f', '2026-08-26 17:57:02.446613', '2027-12-31 16:59:59'),
                                                                                                                                                 ('804ee787-75a6-539c-9d39-83bb8853f413', 'BREWLITE15', 'PERCENT', '15.00', '60000.00', '80', '0', 't', '2026-07-27 17:57:02.446613', '2027-12-31 16:59:59')
ON CONFLICT DO NOTHING;


INSERT INTO public.toppings (id, code, name, price, is_active) VALUES
                                                                   ('3075f104-4b54-59d0-a5af-0d8fa3ab2828', 'TP001', 'Trân châu đen', '5000.00', 't'),
                                                                   ('4d4dca18-ae47-5485-ab6b-b5e74f089b74', 'TP002', 'Trân châu trắng', '6000.00', 't'),
                                                                   ('ca461442-fc58-596a-a78a-e4b938fbaab7', 'TP003', 'Thạch cà phê', '5000.00', 't'),
                                                                   ('be4d54f5-a987-5306-960f-632909bdac15', 'TP004', 'Kem cheese', '9000.00', 't'),
                                                                   ('3fa12143-595b-5f18-aabd-56a4882f0924', 'TP005', 'Kem tươi', '7000.00', 't'),
                                                                   ('7606cbbf-f31f-5dbd-b3cf-8f9b24036323', 'TP006', 'Trân châu hoàng kim', '7000.00', 't'),
                                                                   ('3655baaf-57e8-57d8-b0df-986345d8002c', 'TP007', 'Thạch đào', '6000.00', 't'),
                                                                   ('46ccd2db-66ca-5514-8ab3-7a0c76e4478e', 'TP008', 'Thạch vải', '6000.00', 't'),
                                                                   ('674c8ede-3830-5c10-963e-4d5fbe129ef4', 'TP009', 'Shot espresso', '10000.00', 't'),
                                                                   ('c5f1343d-f22c-5819-bd08-62a013bfa85e', 'TP010', 'Pudding trứng', '8000.00', 't')
ON CONFLICT DO NOTHING;


INSERT INTO public.users (id, email, password_hash, full_name, phone, role, loyalty_points, created_at, avatar_url, favorite_branch) VALUES
                                                                                                                                         ('5f15f651-55d0-54af-b402-204a5cdb438e', 'customer04@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Phạm Gia Huy', '0900000004', 'CUSTOMER', '0', '2026-10-13 15:57:02.446613', NULL, NULL),
                                                                                                                                         ('dd2a0246-fc58-59ea-9b22-3edd78488229', 'customer05@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Đỗ Khánh Linh', '0900000005', 'CUSTOMER', '0', '2026-10-13 18:27:02.446613', NULL, NULL),
                                                                                                                                         ('84276309-9cbe-52f3-ba77-c6441210a0b3', 'customer06@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Võ Ngọc Mai', '0900000006', 'CUSTOMER', '0', '2026-10-13 20:57:02.446613', NULL, NULL),
                                                                                                                                         ('56b6874f-e79a-5baa-82bf-742ae9204916', 'customer07@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Bùi Hoàng Nam', '0900000007', 'CUSTOMER', '0', '2026-10-13 23:27:02.446613', NULL, NULL),
                                                                                                                                         ('f6a3fc8e-3153-5f05-9339-b2ce98fdf72f', 'customer08@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Hoàng Thanh Trúc', '0900000008', 'CUSTOMER', '0', '2026-10-14 01:57:02.446613', NULL, NULL),
                                                                                                                                         ('2d9e6949-bbae-547f-b825-e52a448c5841', 'customer09@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Đặng Nhật Minh', '0900000009', 'CUSTOMER', '0', '2026-10-14 04:27:02.446613', NULL, NULL),
                                                                                                                                         ('c5d55341-3044-5b34-92b7-7fac9f607a8e', 'customer10@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Lý Thu Hà', '0900000010', 'CUSTOMER', '0', '2026-10-14 06:57:02.446613', NULL, NULL),
                                                                                                                                         ('42a057e6-3fac-59a9-95ef-578d09bdf43b', 'barista01@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Nhân viên Quầy 01', '0900000011', 'STAFF', '0', '2026-10-14 09:27:02.446613', NULL, NULL),
                                                                                                                                         ('305ebe46-9a84-5923-a736-df0a01191b58', 'admin01@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Quản trị BrewLite', '0900000012', 'ADMIN', '0', '2026-10-14 11:57:02.446613', NULL, NULL),
                                                                                                                                         ('0abd345f-7157-5376-bdf7-d23459d5c505', 'customer01@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Nguyễn Minh Anh', '0900000001', 'CUSTOMER', '0', '2026-10-08 17:57:02.446613', NULL, NULL),
                                                                                                                                         ('fd59e87d-6638-5681-9acd-cf19dd4fe755', 'customer03@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Lê Thảo Vy', '0900000003', 'CUSTOMER', '0', '2026-10-11 17:57:02.446613', NULL, NULL),
                                                                                                                                         ('89094c8e-81d2-582b-adcc-b81a331c6684', 'customer02@example.com', '$2b$12$.fMfd4/QFSJJelZpB2vyy.cfte0yXlU8PXx4zy./KMLDYztKSGtfe', 'Trần Quốc Bảo', '0900000002', 'CUSTOMER', '0', '2026-10-10 17:57:02.446613', NULL, NULL)
ON CONFLICT DO NOTHING;


-- image_key la ma anh local (duoc frontend map sang asset), KHONG PHAI URL.
-- image_url dang NULL; neu UI su dung URL thay vi image_key thi can cap nhat truoc demo.
INSERT INTO public.products (id, code, name, category, description, image_url, image_key, version, is_active) VALUES
                                                                                                                  ('c2109f91-894f-5836-872b-fc4c0f04ca5d', 'BL001', 'Cà phê sữa', 'Cà phê', 'Cà phê Robusta đậm đà pha sữa đặc thơm béo truyền thống', NULL, 'caPheSua', 0, TRUE),
                                                                                                                  ('80976789-a56b-5b36-88ba-04cd171910d6', 'BL002', 'Americano', 'Cà phê', 'Cà phê đen nguyên chất pha loãng với nước nóng thanh tao', NULL, 'americano', 0, TRUE),
                                                                                                                  ('0f5dda15-68ab-5ca9-aa9a-eb7dc73894d0', 'BL003', 'Cappuccino', 'Cà phê', 'Espresso đậm vị kết hợp sữa nóng và lớp bọt sữa bồng bềnh', NULL, 'cappuccino', 0, TRUE),
                                                                                                ('67a29cc6-e399-5f12-a564-faee3a7aa363', 'BL015', 'Cà phê đen', 'Cà phê', 'Cà phê phin nguyên chất đậm đà, thơm nồng, dùng cùng đá mát lạnh', NULL, 'caPheDen', 0, TRUE),
                                                                                                                  ('4c1c6d0a-0b99-5c97-b5ba-ac3a55b06479', 'BL005', 'Cà Phê Muối Huế', 'Cà phê', 'Cà phê phin đậm đà kết hợp lớp kem muối mặn ngọt béo ngậy chuẩn vị cố đô', NULL, 'caPheMuoi', 0, TRUE),
                                                                                                                  ('4f132288-30ec-529d-b40a-80d49fbdc751', 'BL006', 'Cà Phê Trứng Hà Nội', 'Cà phê', 'Lớp kem trứng gà đánh bông mịn màng, thơm lừng hòa quyện cùng cà phê nóng', NULL, 'caPheTrung', 0, TRUE),
                                                                                                                  ('f05fbd26-e12a-5870-83fe-01820d68bdba', 'BL007', 'Bạc Xỉu Đá Sài Gòn', 'Cà phê', 'Sữa đặc pha sữa tươi béo ngậy tạo tầng đẹp mắt cùng cà phê phin thơm nhẹ', NULL, 'bacXiu', 0, TRUE),
                                                                                                                  ('4e565d14-f3ab-5ad5-8577-6e657a55dcf4', 'BL008', 'Cà Phê Cốt Dừa', 'Cà phê', 'Cốt dừa xay đá tuyết mát lạnh, béo bùi quyện cùng vị đắng dịu của cà phê', NULL, 'caPheCotDua', 0, TRUE),
                                                                                                                  ('e602a5e6-bfba-57b4-b178-79be1eed5883', 'BL009', 'Cà Phê Sữa Tươi Sương Sáo', 'Cà phê', 'Cà phê sữa tươi thanh nhẹ kết hợp cùng thạch sương sáo đen giòn mát', NULL, 'caPheSuaTuoiSuongSao', 0, TRUE),
                                                                                                                  ('0d823f6e-1063-5281-bf54-b04d352249f2', 'BL010', 'Trà Sen Vàng Kem Cheese', 'Trà', 'Trà Ô long thanh mát kết hợp hạt sen bùi, củ năng giòn và lớp kem phô mai mặn béo', NULL, 'traSenVang', 0, TRUE),
                                                                                                                  ('60a3c525-a72d-5dea-bb8e-436d7ed1f7f0', 'BL011', 'Trà Đào Cam Sả', 'Trà', 'Hồng trà ủ lạnh thơm hương sả tươi, cam vàng mọng nước và đào miếng giòn ngọt', NULL, 'traDaoCamSa', 0, TRUE),
                                                                                                                  ('25204519-c2ee-5fb9-a3b0-cd1e4f20a4c8', 'BL012', 'Trà Vải Hoa Hồng', 'Trà', 'Trà lài thanh tao quyện vị ngọt thanh của trái vải ngâm và hương hoa hồng dịu nhẹ', NULL, 'traVaiHoaHong', 0, TRUE),
                                                                                                                  ('f6404914-0dbb-5b96-92f7-02e89db7cea7', 'BL013', 'Trà Mãng Cầu Tươi', 'Trà', 'Mãng cầu xiêm tươi dầm chua ngọt sảng khoái trên nền trà xanh lài đậm vị', NULL, 'traMangCau', 0, TRUE),
                                                                                                                  ('fc7d19ab-08ee-532c-a719-e7d34417bb98', 'BL014', 'Trà Ô Long Nhãn Nhục Hạt Chia', 'Trà', 'Vị ngọt thanh cổ truyền từ nhãn nhục sấy khô, hạt chia bổ dưỡng cùng trà Ô long', NULL, 'traOLongNhanNhuc', 0, TRUE)
ON CONFLICT DO NOTHING;


WITH base_price(product_code, price) AS (
    VALUES
        ('BL001', 35000.00),
        ('BL002', 40000.00),
        ('BL003', 45000.00),
        ('BL015', 30000.00),
        ('BL005', 39000.00),
        ('BL006', 45000.00),
        ('BL007', 35000.00),
        ('BL008', 45000.00),
        ('BL009', 39000.00),
        ('BL010', 49000.00),
        ('BL011', 45000.00),
        ('BL012', 45000.00),
        ('BL013', 49000.00),
        ('BL014', 45000.00)
)
INSERT INTO public.product_size_prices (product_id, size, price)
SELECT p.id, s.size,
       CASE s.size WHEN 'S' THEN bp.price - 5000
                   WHEN 'M' THEN bp.price
                   WHEN 'L' THEN bp.price + 5000 END
FROM base_price bp
         JOIN public.products p ON p.code = bp.product_code
         CROSS JOIN (VALUES ('S'::public.product_size), ('M'::public.product_size), ('L'::public.product_size)) AS s(size)
WHERE TRUE
ON CONFLICT DO NOTHING;


CREATE TEMP TABLE seed_initial_ingredients (
    code varchar(30) PRIMARY KEY,
    name varchar(255) NOT NULL,
    unit varchar(10) NOT NULL,
    opening_qty numeric(14,3) NOT NULL,
    min_stock_quantity numeric(14,3) NOT NULL
) ON COMMIT DROP;


INSERT INTO seed_initial_ingredients(code,name,unit,opening_qty,min_stock_quantity) VALUES
                                                                                        ('CF_BOT', 'Cà phê bột', 'g', 16000.000, 2000.000),
                                                                                        ('SUA_DAC', 'Sữa đặc', 'ml', 65000.000, 5000.000),
                                                                                        ('SUA_TUOI', 'Sữa tươi', 'ml', 110000.000, 10000.000),
                                                                                        ('DUONG', 'Đường', 'g', 60000.000, 5000.000),
                                                                                        ('DA_VIEN', 'Đá viên', 'g', 300000.000, 30000.000),
                                                                                        ('NUOC_LOC', 'Nước lọc', 'ml', 600000.000, 50000.000),
                                                                                        ('KEM_MUOI', 'Kem muối', 'ml', 16000.000, 2000.000),
                                                                                        ('NUOC_COT_DUA', 'Nước cốt dừa', 'ml', 24000.000, 3000.000),
                                                                                        ('LONG_DO_TRUNG', 'Lòng đỏ trứng', 'g', 10000.000, 1000.000),
                                                                                        ('TRA_LA', 'Trà khô', 'g', 16000.000, 1500.000),
                                                                                        ('SIRO_DAO', 'Siro đào', 'ml', 20000.000, 2000.000),
                                                                                        ('NUOC_CAM', 'Nước cam', 'ml', 25000.000, 3000.000),
                                                                                        ('SA_CAY', 'Sả', 'g', 10000.000, 1000.000),
                                                                                        ('TRAN_CHAU_DEN', 'Trân châu đen', 'g', 22000.000, 2500.000),
                                                                                        ('TRAN_CHAU_TRANG', 'Trân châu trắng', 'g', 15000.000, 1500.000),
                                                                                        ('THACH_CAFE', 'Thạch cà phê', 'g', 18000.000, 2000.000),
                                                                                        ('KEM_CHEESE', 'Kem cheese', 'ml', 16000.000, 1800.000),
                                                                                        ('KEM_TUOI', 'Kem tươi', 'ml', 19000.000, 2200.000),
                                                                                        ('TRAN_CHAU_HOANG_KIM', 'Trân châu hoàng kim', 'g', 15000.000, 1500.000),
                                                                                        ('THACH_DAO', 'Thạch đào', 'g', 15000.000, 1500.000),
                                                                                        ('THACH_VAI', 'Thạch vải', 'g', 15000.000, 1500.000),
                                                                                        ('PUDDING_TRUNG', 'Pudding trứng', 'g', 14000.000, 1500.000),
                                                                                        ('DAO_MIEN', 'Đào miếng', 'g', 18000.000, 2000.000),
                                                                                        ('THACH_SUONG_SAO', 'Thạch sương sáo', 'g', 18000.000, 2000.000),
                                                                                        ('TRA_O_LONG', 'Trà Ô long', 'g', 14000.000, 1500.000),
                                                                                        ('HAT_SEN', 'Hạt sen', 'g', 20000.000, 2000.000),
                                                                                        ('CU_NANG', 'Củ năng', 'g', 18000.000, 1800.000),
                                                                                        ('TRA_LAI', 'Trà lài', 'g', 15000.000, 1500.000),
                                                                                        ('VAI_NGAM', 'Vải ngâm', 'g', 18000.000, 1800.000),
                                                                                        ('SIRO_HOA_HONG', 'Siro hoa hồng', 'ml', 12000.000, 1200.000),
                                                                                        ('MANG_CAU', 'Mãng cầu xiêm', 'g', 22000.000, 2500.000),
                                                                                        ('NHAN_NHUC', 'Nhãn nhục sấy', 'g', 15000.000, 1500.000),
                                                                                        ('HAT_CHIA', 'Hạt chia', 'g', 10000.000, 1000.000);


-- Only record an OPENING movement for a newly inserted ingredient.
-- Re-seeding an existing stock item must NOT create another opening movement.
WITH just_inserted AS (
    INSERT INTO public.ingredients(code,name,unit,stock_quantity,min_stock_quantity,version)
    SELECT code,name,unit,opening_qty,min_stock_quantity,1
    FROM seed_initial_ingredients
    WHERE TRUE
    ON CONFLICT (code) DO NOTHING
    RETURNING id, code
)
INSERT INTO public.ingredient_movements
(ingredient_id, movement_type, expected_version, quantity_change, stock_before, stock_after, note)
SELECT i.id, 'OPENING', 0, s.opening_qty, 0, s.opening_qty, 'Ton dau ky (du lieu mau)'
FROM just_inserted i JOIN seed_initial_ingredients s ON s.code=i.code
WHERE s.opening_qty > 0
ON CONFLICT DO NOTHING;


-- Dinh luong tham khao cho size M; S 80%, L 125% (thay doi theo cong thuc nhom).
WITH recipe_base(product_code, ingredient_code, quantity_m) AS (
    VALUES
        ('BL001', 'CF_BOT', 20.000::numeric),
        ('BL001', 'SUA_DAC', 30.000::numeric),
        ('BL001', 'DA_VIEN', 150.000::numeric),
        ('BL002', 'CF_BOT', 18.000::numeric),
        ('BL002', 'NUOC_LOC', 160.000::numeric),
        ('BL003', 'CF_BOT', 18.000::numeric),
        ('BL003', 'SUA_TUOI', 140.000::numeric),
        ('BL015', 'CF_BOT', 20.000::numeric),
        ('BL015', 'NUOC_LOC', 150.000::numeric),
        ('BL015', 'DA_VIEN', 130.000::numeric),
        ('BL005', 'CF_BOT', 20.000::numeric),
        ('BL005', 'SUA_DAC', 20.000::numeric),
        ('BL005', 'KEM_MUOI', 40.000::numeric),
        ('BL005', 'DA_VIEN', 130.000::numeric),
        ('BL006', 'CF_BOT', 18.000::numeric),
        ('BL006', 'LONG_DO_TRUNG', 20.000::numeric),
        ('BL006', 'SUA_DAC', 20.000::numeric),
        ('BL006', 'DUONG', 8.000::numeric),
        ('BL007', 'CF_BOT', 10.000::numeric),
        ('BL007', 'SUA_DAC', 35.000::numeric),
        ('BL007', 'SUA_TUOI', 110.000::numeric),
        ('BL007', 'DA_VIEN', 150.000::numeric),
        ('BL008', 'CF_BOT', 18.000::numeric),
        ('BL008', 'NUOC_COT_DUA', 80.000::numeric),
        ('BL008', 'SUA_DAC', 15.000::numeric),
        ('BL008', 'DA_VIEN', 160.000::numeric),
        ('BL009', 'CF_BOT', 15.000::numeric),
        ('BL009', 'SUA_TUOI', 120.000::numeric),
        ('BL009', 'THACH_SUONG_SAO', 50.000::numeric),
        ('BL009', 'DA_VIEN', 130.000::numeric),
        ('BL010', 'TRA_O_LONG', 10.000::numeric),
        ('BL010', 'HAT_SEN', 40.000::numeric),
        ('BL010', 'CU_NANG', 35.000::numeric),
        ('BL010', 'KEM_CHEESE', 40.000::numeric),
        ('BL010', 'NUOC_LOC', 140.000::numeric),
        ('BL010', 'DA_VIEN', 130.000::numeric),
        ('BL011', 'TRA_LA', 10.000::numeric),
        ('BL011', 'SIRO_DAO', 25.000::numeric),
        ('BL011', 'DAO_MIEN', 55.000::numeric),
        ('BL011', 'NUOC_CAM', 50.000::numeric),
        ('BL011', 'SA_CAY', 10.000::numeric),
        ('BL011', 'NUOC_LOC', 140.000::numeric),
        ('BL011', 'DA_VIEN', 130.000::numeric),
        ('BL012', 'TRA_LAI', 10.000::numeric),
        ('BL012', 'VAI_NGAM', 60.000::numeric),
        ('BL012', 'SIRO_HOA_HONG', 15.000::numeric),
        ('BL012', 'NUOC_LOC', 140.000::numeric),
        ('BL012', 'DA_VIEN', 150.000::numeric),
        ('BL013', 'TRA_LAI', 10.000::numeric),
        ('BL013', 'MANG_CAU', 90.000::numeric),
        ('BL013', 'DUONG', 15.000::numeric),
        ('BL013', 'NUOC_LOC', 140.000::numeric),
        ('BL013', 'DA_VIEN', 130.000::numeric),
        ('BL014', 'TRA_O_LONG', 10.000::numeric),
        ('BL014', 'NHAN_NHUC', 40.000::numeric),
        ('BL014', 'HAT_CHIA', 8.000::numeric),
        ('BL014', 'DUONG', 12.000::numeric),
        ('BL014', 'NUOC_LOC', 150.000::numeric),
        ('BL014', 'DA_VIEN', 130.000::numeric)
), size_ratio(size, ratio) AS (
    VALUES ('S'::public.product_size, 0.80::numeric),
           ('M'::public.product_size, 1.00::numeric),
           ('L'::public.product_size, 1.25::numeric)
)
INSERT INTO public.product_ingredients (product_id, size, ingredient_id, quantity)
SELECT p.id, sr.size, i.id, round(rb.quantity_m * sr.ratio, 3)
FROM recipe_base rb
         JOIN public.products p ON p.code = rb.product_code
         JOIN public.ingredients i ON i.code = rb.ingredient_code
         CROSS JOIN size_ratio sr
         JOIN public.product_size_prices psp ON psp.product_id = p.id AND psp.size = sr.size
WHERE TRUE
ON CONFLICT DO NOTHING;


-- Topping quantity per ONE serving (nhan voi order_items.quantity va servings cua topping).
WITH topping_recipe(topping_code, ingredient_code, quantity) AS (
    VALUES
        ('TP001', 'TRAN_CHAU_DEN', 35.000::numeric),
        ('TP002', 'TRAN_CHAU_TRANG', 35.000::numeric),
        ('TP003', 'THACH_CAFE', 40.000::numeric),
        ('TP004', 'KEM_CHEESE', 40.000::numeric),
        ('TP005', 'KEM_TUOI', 35.000::numeric),
        ('TP006', 'TRAN_CHAU_HOANG_KIM', 35.000::numeric),
        ('TP007', 'THACH_DAO', 40.000::numeric),
        ('TP008', 'THACH_VAI', 40.000::numeric),
        ('TP009', 'CF_BOT', 18.000::numeric),
        ('TP009', 'NUOC_LOC', 35.000::numeric),
        ('TP010', 'PUDDING_TRUNG', 40.000::numeric)
)
INSERT INTO public.topping_ingredients (topping_id, ingredient_id, quantity)
SELECT t.id, i.id, r.quantity
FROM topping_recipe r
         JOIN public.toppings t ON t.code = r.topping_code
         JOIN public.ingredients i ON i.code = r.ingredient_code
WHERE TRUE
ON CONFLICT DO NOTHING;



COMMIT;
