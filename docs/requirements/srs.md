# Task 1.2 - SRS rút gọn BrewLite

## 1. Mục đích

Đặc tả yêu cầu BrewLite cho Assignment 2 theo các mã FR và NFR, ưu tiên MoSCoW và điều kiện nghiệm thu có thể kiểm tra. Các tiêu chí dưới đây là điều kiện mong muốn; không phải tất cả đã được đo hoặc tự động kiểm thử.

## 2. Yêu cầu chức năng

| Mã | Ưu tiên | Yêu cầu | Tiêu chí chấp nhận | Mã nguồn/API chính |
| --- | --- | --- | --- | --- |
| FR-01 | Must | Xem menu đồ uống | `GET /products` trả danh sách món đang bán, có tên, ảnh, giá theo size; UI có Loading/Empty/Error. Kiểm tra riêng tình trạng hết nguyên liệu vì API danh sách hiện không trả trực tiếp `stock` của từng món. | `products.controller.ts`, `products.service.ts`, `ThucDon.tsx` |
| FR-02 | Must | Chi tiết và tùy chọn món | `GET /products/:id` và `GET /products/:id/options` có giá size S/M/L và topping; tổng tiền thay đổi đúng theo tùy chọn. | `products.controller.ts`, `ChiTietMon.tsx` |
| FR-03 | Must | Giỏ hàng | Thêm, tăng/giảm số lượng, xóa món; tính lại tổng theo size/topping/số lượng; các cấu hình khác nhau không bị gộp sai. | `useGioHang.ts`, `GioHang.tsx` |
| FR-04 | Must | Đăng ký, đăng nhập và JWT | `POST /auth/register`, `POST /auth/login` hoạt động; mật khẩu băm; `POST /orders` thiếu JWT bị từ chối. | `auth/`, `DangNhap.tsx` |
| FR-05 | Must | Tạo đơn và chống âm kho | `POST /orders` kiểm tra JWT, DTO và `Idempotency-Key` (8-128 ký tự); tạo `PENDING`, giữ trước nguyên liệu/coupon/điểm. Gửi lại cùng key và nội dung không tạo đơn mới. Xung đột được báo lỗi. | `orders.controller.ts`, `orders.service.ts` |
| FR-06 | Must | Thanh toán | `POST /payments` dùng demo WALLET/CARD khi bật; `POST /payments/zalopay` tạo phiên thanh toán Sandbox, chưa coi là đã trả tiền. Có callback, kiểm tra chữ ký, đối soát QueryDR, khóa chống gửi trùng và xác nhận `PAID` sau kết quả thành công. | `payments/` |
| FR-07 | Must | Xác nhận và lịch sử đơn | `GET /orders/me` chỉ trả đơn của người đăng nhập; có mã, tổng tiền và trạng thái; giao diện thể hiện đang chờ/đã thanh toán/hủy. | `orders.controller.ts`, `LichSuDon.tsx`, `DatHangThanhCong.tsx` |
| FR-08 | Should | Chuyển trạng thái đơn | Quy tắc `PENDING -> PAID -> PREPARING -> READY -> COMPLETED`, thêm `PAYMENT_FAILED`, `CANCELLED`; `assertTransition()` chặn chuyển trái phép. Staff/Admin mới đổi trạng thái pha chế. | `order-state.ts`, `orders.service.ts` |
| FR-09 | Could | Mã giảm giá và điểm thưởng | Coupon hợp lệ được trừ đúng; giữ coupon/điểm khi đơn chờ, tiêu thụ khi `PAID`, giải phóng nếu hủy hợp lệ; điểm thưởng không cộng hai lần khi callback lặp. | `vouchers/`, `rewards/`, `orders.service.ts` |

Ghi chú nghiệp vụ quan trọng:

- `Product.version` không phải kho bán trực tiếp. Tồn kho thực tế nằm trong `Ingredient.stockQty`, `Ingredient.reservedQty`, `Ingredient.version` và công thức nguyên liệu.
- `POST /orders` cũng yêu cầu `Idempotency-Key`, không chỉ `POST /payments`.
- `PAYMENT_FAILED` là trạng thái đơn; `PENDING`, `SUCCESS`, `FAILED` là trạng thái bản ghi Payment.
- Với ZaloPay Sandbox, tạo QR thành công không đồng nghĩa thanh toán thành công. Không ghi hoàn tiền thật nếu chỉ hoàn mô phỏng.

## 3. Yêu cầu phi chức năng

| Mã | Ưu tiên | Yêu cầu | Tiêu chí chấp nhận và cách kiểm chứng |
| --- | --- | --- | --- |
| NFR-01 | Must | Hiệu năng | `GET /products` và `POST /orders` đạt mục tiêu dưới 500 ms trong môi trường thử nghiệm được mô tả rõ; cần log đo thời gian và điều kiện đo. Chưa có bộ minh chứng định lượng được nghiệm thu đầy đủ cho ngưỡng dưới 500 ms. |
| NFR-02 | Must | Bảo mật | Production sử dụng HTTPS, JWT cho API cần đăng nhập, DTO validation, không lộ secrets trong repository/log. Cấu hình DB private cần xác minh trong Render Dashboard. |
| NFR-03 | Must | Khả dụng/mobile-first/PWA | Giao diện dùng được ở 375-430 px; có manifest và biểu tượng hợp lệ. Cần kiểm tra khả năng cài đặt PWA/Service Worker riêng, không khẳng định offline nếu chưa có. |
| NFR-04 | Must | Dễ triển khai | `docker compose up -d --build` khởi động web+api+db khi đã có `.env`; `GET /health` trả HTTP 200 khi kết nối DB sẵn sàng; GitHub CI/CD và smoke kiểm tra. |

## 4. Use-case tổng quát

Actor: Khách hàng, Nhân viên/Quản trị, Dịch vụ thanh toán ZaloPay.

- Khách hàng: Xem menu, xem chi tiết, tùy chỉnh, giỏ hàng, đăng nhập, tạo đơn, áp coupon/điểm, thanh toán, kiểm tra kết quả, lịch sử, hủy đơn hợp lệ.
- Nhân viên/Quản trị: Xem hàng đợi, cập nhật trạng thái, xem/nhập tồn kho.
- ZaloPay Sandbox: Tạo phiên thanh toán, gửi callback, trả QueryDR khi đối soát.

Sơ đồ tổng quát có hình `docs/diagrams/usecase/Usecase.png` và mã nguồn `Usecase.puml`; sơ đồ phạm vi UC-01 có `Usecase01.png` và `Usecase01.puml` trong cùng thư mục. Hai mã nguồn PlantUML bổ sung mô tả nội dung tương đương về nghiệp vụ nhưng chưa được xác nhận kết xuất giống hệt ảnh PNG hiện có; cần đồng bộ lại hình khi nghiệm thu.

## 5. Liên kết kiểm thử

- API unit: `apps/api/src/products/products.service.spec.ts`, `apps/api/src/order/orders.spec.ts`, `apps/api/src/payments/*.spec.ts`.
- Integration DB: `apps/api/src/order/stock.integration.spec.ts`, `reservation.integration.spec.ts`.
- HTTP E2E: `apps/api/scripts/e2e.mjs` (không phải Playwright).
- Web Jest: `apps/web/test/kiem-tra-ung-dung.spec.ts`.
- Bản đồ FR/NFR -> test: `docs/traceability-matrix.md`.

## 6. Những tiêu chí cần thêm minh chứng

Cần bổ sung kiểm thử trình duyệt end-to-end nếu giảng viên yêu cầu, đo hiệu năng dưới 500 ms, thử nghiệm PWA cài đặt/offline nếu mô tả offline và ảnh chạy local. CI chạy thành công chỉ chứng minh các job đã cấu hình được thực hiện, không chứng minh mọi NFR đều đã đạt.
