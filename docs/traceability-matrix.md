# Ma trận truy vết BrewLite - Assignment 2

Bảng nối từng yêu cầu SRS với sơ đồ, mã nguồn và kiểm thử hiện có. Tên test dưới đây là đường dẫn thật trong ZIP; sự tồn tại của file không tự chứng minh mọi trường hợp đã được thử.

| Yêu cầu | Use-case | Sơ đồ | Mã nguồn/API | Test hoặc minh chứng |
| --- | --- | --- | --- | --- |
| FR-01 Menu | US-01 | `docs/diagrams/activity/UC02.png` | `apps/api/src/products/products.controller.ts`, `apps/web/src/man-hinh/ThucDon.tsx` | `products.service.spec.ts`, CI Web/API |
| FR-02 Chi tiết và tùy chọn | US-02 | `docs/diagrams/activity/UC03.png`, `docs/diagrams/activity/UC04.png` | `GET /products/:id`, `GET /products/:id/options`, `apps/web/src/man-hinh/ChiTietMon.tsx` | `products.service.spec.ts`, `orders.spec.ts` |
| FR-03 Giỏ hàng | US-03 | `docs/diagrams/activity/UC05.png` | `apps/web/src/store/useGioHang.ts`, `apps/web/src/man-hinh/GioHang.tsx` | `apps/web/test/kiem-tra-ung-dung.spec.ts` (kiểm thử cơ bản) |
| FR-04 JWT | US-04 | `docs/diagrams/activity/UC01.png`, `docs/diagrams/activity/UC07.png` | `apps/api/src/auth/`, `apps/web/src/man-hinh/DangNhap.tsx` | `apps/api/scripts/e2e.mjs` (đăng ký/token) |
| FR-05 Đặt đơn và giữ kho | UC-01 | `docs/diagrams/activity/UC06.png`, `docs/diagrams/sequence/UC01-DatVaThanhToan.puml` | `apps/api/src/order/orders.service.ts`, `POST /orders` | `reservation.integration.spec.ts`, `stock.integration.spec.ts`, HTTP E2E |
| FR-06 Thanh toán | UC-01 | `docs/diagrams/activity/UC09.png`, `docs/diagrams/sequence/UC01-DatVaThanhToan.puml` | `apps/api/src/payments/`, `POST /payments`, `POST /payments/zalopay` | `payments.service.spec.ts`, `payments.callback.spec.ts`, `payments.recheck.spec.ts`, `zalopay.service.spec.ts` |
| FR-07 Lịch sử đơn | US-07 | `docs/diagrams/activity/UC10.png`, `docs/diagrams/activity/UC12.png` | `GET /orders/me`, `apps/web/src/man-hinh/LichSuDon.tsx` | `apps/api/scripts/e2e.mjs` |
| FR-08 Trạng thái đơn | US-08 | `docs/diagrams/activity/UC13.png`, `docs/diagrams/activity/UC14.png` | `apps/api/src/order/order-state.ts`, `PATCH /orders/:id/status` | `orders.spec.ts` |
| FR-09 Coupon/điểm | US-09 | `docs/diagrams/activity/UC08.png`, `docs/diagrams/activity/UC11.png` | `apps/api/src/vouchers/`, `apps/api/src/rewards/`, `apps/api/src/order/orders.service.ts` | `reservation.integration.spec.ts`, `orders.spec.ts` (cần rà soát thêm các ca coupon/điểm) |
| NFR-01 Hiệu năng | Toàn hệ thống | `docs/diagrams/deployment/Deployment.png` | `GET /products`, `POST /orders` | Cần bổ sung đo đạc có điều kiện thử nghiệm rõ ràng để xác nhận mục tiêu dưới 500 ms |
| NFR-02 Bảo mật | Toàn hệ thống | `docs/diagrams/deployment/Deployment.png` | `apps/api/src/auth/jwt.guard.ts`, `apps/api/src/main.ts`, env của Render | CI + kiểm tra secrets/DB private trên Render; phần DB private cần xác minh |
| NFR-03 Mobile/PWA | Toàn hệ thống | `docs/diagrams/deployment/Deployment.png` | `apps/web/public/manifest.json`, `apps/web/src/app/` | Cần kiểm tra mobile/PWA cài đặt và icon trên production |
| NFR-04 Deploy | Toàn hệ thống | `docs/diagrams/deployment/deployment.puml` | `docker-compose.yml`, `.github/workflows/*`, `GET /health` | CI run `43744261941`; CD run `43737678839`; log smoke thành công |

## Đường dẫn kiểm thử được dùng

- `apps/api/src/products/products.service.spec.ts`
- `apps/api/src/order/orders.spec.ts`
- `apps/api/src/order/reservation.integration.spec.ts`
- `apps/api/src/order/stock.integration.spec.ts`
- `apps/api/src/payments/*.spec.ts`
- `apps/web/test/kiem-tra-ung-dung.spec.ts`
- `apps/api/scripts/e2e.mjs`
- `apps/api/scripts/smoke.mjs`

## Hạn chế cần ghi trong báo cáo

- HTTP E2E hiện dùng Node.js và API test localhost, không phải Playwright/browser UI E2E.
- SRS FR-01 muốn hiển thị stock theo món nhưng `GET /products` chưa trả `stock` trực tiếp.
- Mục tiêu NFR-01 dưới 500 ms chưa có số đo.
- Đã có Prisma baseline `apps/api/prisma/migrations/0_init/` và `migration_lock.toml` (Docker local); chưa xác nhận migration Production hoặc kiểm thử tái tạo schema từ baseline.
- `docs/diagrams/deployment/deployment.puml` là tệp nguồn Deployment; ảnh hiện có là `docs/diagrams/deployment/Deployment.png`. Cần đối chiếu hai phiên bản khi nghiệm thu.

**Lưu ý:** Các mục Activity phía trên trỏ tới **ảnh PNG đã có**. Nguồn `.puml` cùng tên trong `docs/diagrams/activity/` hiện dùng cú pháp Sequence và chưa khớp ảnh; cần thay bằng nguồn Activity thật trước khi xác nhận hoàn thành yêu cầu tệp nguồn. Các file PlantUML Usecase mới cũng cần kiểm tra lại ảnh kết xuất trước khi nộp.
