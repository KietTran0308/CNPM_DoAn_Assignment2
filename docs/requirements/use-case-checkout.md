# Task 1.3 - Use-case UC-01: Đặt và thanh toán đơn hàng

## 1. Thông tin chung

- Mã: UC-01.
- Tên: Đặt và thanh toán đồ uống.
- Actor chính: Khách hàng.
- Actor phụ: NestJS API, PostgreSQL, cổng ZaloPay Sandbox hoặc phương thức demo.
- Mã yêu cầu: FR-02, FR-03, FR-04, FR-05, FR-06, FR-07, FR-08, FR-09; NFR-02, NFR-04.
- Sơ đồ: `docs/diagrams/sequence/UC01-DatVaThanhToan.puml`, `docs/diagrams/sequence/DatVaThanhToan.png`.

## 2. Điều kiện bắt đầu

1. Khách đã chọn ít nhất một món và có giỏ hàng hợp lệ.
2. Khách đăng nhập, có JWT hợp lệ.
3. Sản phẩm, size, topping còn được bán và còn đủ nguyên liệu khả dụng.
4. Môi trường thanh toán được cấu hình. Demo ví/thẻ chỉ dùng trong môi trường được cho phép; ZaloPay Sandbox cần khóa hợp lệ.

## 3. Kết quả

- Khi tạo đơn: trạng thái Order là `PENDING`, `reservationStatus=HELD`; nguyên liệu/coupon/điểm được giữ trước, chưa coi như đã thanh toán.
- Khi xác nhận thanh toán thành công: Order chuyển `PAID`, Payment thành `SUCCESS`, nguồn lực được tiêu thụ, điểm được cộng một lần.
- Nếu khách hủy hợp lệ hoặc giao dịch được xác nhận thất bại/hết hạn: hệ thống cập nhật trạng thái và giải phóng tài nguyên theo quy tắc.
- Nếu trạng thái cổng chưa rõ: hệ thống tiếp tục đối soát, không tự kết luận là đã trả hoặc đã thất bại.

## 4. Luồng chính - thanh toán ZaloPay Sandbox

1. Khách vào menu, chọn size/topping/số lượng và đưa món vào giỏ.
2. Khách vào thanh toán; nếu chưa đăng nhập, chuyển sang đăng nhập.
3. Frontend gửi `POST /orders` kèm JWT, `Idempotency-Key` và danh sách món.
4. Backend xác thực JWT và DTO; đọc giá thật từ DB, kiểm tra tồn kho nguyên liệu, coupon và điểm.
5. Backend chạy transaction để tạo đơn `PENDING`, giữ trước nguyên liệu/coupon/điểm và trả mã đơn cùng tổng tiền.
6. Khách chọn ZaloPay. Frontend gửi `POST /payments/zalopay` với `orderId`, JWT và `Idempotency-Key`.
7. Backend lưu Payment `PENDING` và gọi ZaloPay Sandbox tạo phiên thanh toán; trả về URL hoặc nội dung QR hợp lệ.
8. Giao diện hiển thị QR/đường dẫn thanh toán và trạng thái đang chờ.
9. Khách hoàn tất thao tác trong ZaloPay Sandbox. ZaloPay có thể gọi `POST /payments/zalopay/callback`.
10. Backend kiểm tra chữ ký callback và dữ liệu giao dịch. Nếu callback chậm/mất, có thể gọi QueryDR qua cơ chế đối soát.
11. Chỉ sau khi kết quả thành công đã được xác minh, backend ghi Payment `SUCCESS`, chuyển đơn `PAID`, tiêu thụ tài nguyên đã giữ và xử lý tích điểm.
12. Khách xem kết quả và lịch sử ở `GET /orders/me` hoặc API trạng thái ZaloPay.

## 5. Luồng thay thế

- A1 - Áp coupon/điểm: khách nhập mã hoặc chọn điểm. Backend kiểm tra và tính lại tổng; chỉ giữ coupon/điểm trong lúc chờ, tiêu thụ khi thanh toán thành công.
- A2 - Gửi trùng: nếu khách gửi lại cùng `Idempotency-Key` và cùng payload, API trả kết quả đã tồn tại. Khóa dùng lại cho payload khác bị từ chối.
- A3 - Demo WALLET/CARD: chỉ khi `ENABLE_DEMO_PAYMENTS=true`, dùng `POST /payments` để mô phỏng thành công/thất bại.
- A4 - Đơn giá trị 0: sử dụng `POST /payments/zero`, không yêu cầu ZaloPay.
- A5 - Callback không đến: dùng `POST /payments/zalopay/verify/:orderId` hoặc cơ chế QueryDR để xác minh, có giới hạn tần suất.

## 6. Luồng ngoại lệ

- E1 - Chưa đăng nhập: không thể đặt đơn, điều hướng đăng nhập; yêu cầu không có JWT bị từ chối.
- E2 - Dữ liệu không hợp lệ: size/topping/số lượng không đúng, trả lỗi validation hoặc nghiệp vụ.
- E3 - Hết nguyên liệu hoặc tranh chấp kho: transaction thất bại, không tạo đơn mới, thông báo đặt lại.
- E4 - Thanh toán demo thất bại: Payment `FAILED`, Order `PAYMENT_FAILED`, giữ lại khả năng thử lại nếu còn hợp lệ.
- E5 - ZaloPay đang xử lý: Payment tiếp tục `PENDING`, không tạo giao dịch khác và không hủy khi chưa đối soát.
- E6 - Đơn hết hạn: hệ thống chỉ tự hủy khi không còn giao dịch cổng cần đối soát; hoàn lại tài nguyên đã giữ theo quy tắc.
- E7 - Callback sai chữ ký/số tiền: backend từ chối xác nhận, không chuyển `PAID`.
- E8 - Hủy đơn đã trả ZaloPay Sandbox: nếu được phép trước pha chế, hệ thống ghi hoàn mô phỏng nội bộ, KHÔNG gọi API refund thật.

## 7. API dùng trong use-case

| API | Mục đích |
| --- | --- |
| `GET /products` | Xem menu |
| `GET /products/:id/options` | Lấy tùy chọn size và topping |
| `POST /auth/login` | Đăng nhập |
| `POST /orders` | Tạo đơn và giữ trước tài nguyên |
| `POST /payments/zalopay` | Khởi tạo thanh toán ZaloPay Sandbox |
| `POST /payments` | Thanh toán mô phỏng (chỉ khi bật) |
| `POST /payments/zero` | Xác nhận đơn 0 đồng |
| `POST /payments/zalopay/callback` | Callback công khai, có xác thực chữ ký |
| `GET /payments/zalopay/status?orderId=...` | Khách đọc trạng thái giao dịch |
| `POST /payments/zalopay/verify/:orderId` | Khách yêu cầu xác minh thanh toán |
| `GET /orders/me` | Xem lịch sử đơn |
| `POST /orders/:id/cancel` | Hủy theo điều kiện cho phép |

## 8. Kiểm chứng

- Đặt đơn/idempotency, thanh toán demo/lịch sử/hủy: `apps/api/scripts/e2e.mjs`.
- Chống vượt kho: `apps/api/src/order/stock.integration.spec.ts`.
- Giữ và giải phóng tài nguyên: `apps/api/src/order/reservation.integration.spec.ts`.
- Callback, QueryDR, chữ ký: các test trong `apps/api/src/payments/`.

HTTP E2E không phải kiểm thử thao tác màn hình bằng Playwright. Để nghiệm thu UI thực tế, nhóm cần thêm video hoặc test trình duyệt riêng.
