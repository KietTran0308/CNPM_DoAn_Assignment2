# Task 3.1 - Kiến trúc BrewLite

## 1. Kiến trúc tổng quát

BrewLite tách thành ba phần:

1. Web: Next.js trong `apps/web`, giao diện mobile-first và trạng thái giỏ hàng với Zustand.
2. API: NestJS trong `apps/api`, chia module Auth, Products, Orders, Payments, Vouchers, Rewards và Health.
3. Database: PostgreSQL, truy xuất qua Prisma ORM.

Bên ngoài hệ thống có ZaloPay Sandbox để tạo giao dịch, nhận callback và đối soát thanh toán. Không có một microservice thanh toán riêng biệt trong ZIP; mã tích hợp nằm trong module Payments của NestJS.

## 2. Tổ chức mã nguồn

- Controller: nhận request, xác thực, validate DTO, gọi service.
- Service: tính giá, kiểm tra quyền, xử lý đơn, giao dịch, kho và trạng thái.
- Prisma: ánh xạ model với PostgreSQL, thực hiện transaction.
- Frontend: hiển thị trang và gọi API. Không được tin vào đơn giá/tổng tiền do frontend gửi lên.

Đường đi: Browser -> HTTPS Next.js -> HTTPS NestJS -> Prisma -> PostgreSQL. Với thanh toán ZaloPay: NestJS -> ZaloPay Sandbox; callback/QueryDR -> NestJS -> PostgreSQL.

## 3. Dữ liệu

- Các nhóm bảng: users, products, product_size_prices, toppings, orders, order_items, payments, payment_gateway_transactions, coupons, loyalty_transactions, ingredients, order_ingredient_reservations và các bảng hỗ trợ.
- `Ingredient.stockQty` là kho thực, `reservedQty` là lượng đã giữ cho đơn đang chờ. `version` hỗ trợ khóa lạc quan.
- Tạo đơn dùng transaction Serializable để giữ kho/coupon/điểm. Khi thanh toán xác nhận thành công, hệ thống mới tiêu thụ.
- Idempotency-Key có unique constraint ở Orders và Payments.

## 4. Logging, health và cấu hình

- `GET /health` truy vấn `SELECT 1` tới PostgreSQL; trả HTTP 200 khi DB dùng được.
- Mã dùng logger/console và log GitHub Actions/Render để theo dõi. Chưa có Prometheus/Grafana/Sentry.
- JWT, DATABASE_URL, ZaloPay keys, CORS và PORT lấy từ biến môi trường.

## 5. Ưu điểm và đánh đổi

| Quyết định | Ưu điểm | Hạn chế |
| --- | --- | --- |
| Monorepo | Đồng bộ Web, API, Docs và CI | Build độc lập phải cấu hình đường dẫn |
| NestJS modules | Tách trách nhiệm và dễ test | Tăng số lớp/DTO |
| PostgreSQL + Prisma | Transaction và kiểm tra schema | Cần quy trình migration cẩn thận |
| Transaction + idempotency | Hạn chế âm kho/đặt trùng | Có tranh chấp 409, cần cho người dùng thử lại đúng cách |
| Render + GH Actions | Có HTTPS, logs, CI/CD và smoke | Phụ thuộc dịch vụ ngoài; rollback hiện cần thao tác thủ công |

## 6. Các điểm chưa hoàn tất theo đề bài

- Docker Compose và CI khởi tạo DB test/local lần đầu bằng `prisma/dbBrewLite.sql`. Thư mục `apps/api/prisma/migrations/0_init/` và `migration_lock.toml` đã có; theo kết quả thực hiện của nhóm, baseline `0_init` đã được đánh dấu áp dụng trên database Docker local đang tồn tại. Điều này chưa chứng minh có thể tái tạo database mới từ migration hoặc đã chạy migration an toàn trên Render Production.
- `public/manifest.json` đã có nội dung và icon, nhưng cần kiểm tra liên kết icon/metadata và Service Worker để xác minh khả năng cài đặt PWA.
- CI hiện chạy Jest và HTTP E2E. ZIP không có test hoặc cấu hình Playwright đang dùng. Đã gỡ `@playwright/test` khỏi `devDependencies` trực tiếp của API và Web; lockfile Web có thể vẫn chứa Playwright do Next.js khai báo peer dependency tùy chọn. HTTP E2E chưa phải kiểm thử UI bằng trình duyệt.

Tham khảo: `docs/architecture/adr/` và `docs/deployment.md`.
