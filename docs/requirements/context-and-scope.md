# Task 1.1 - Bối cảnh, bên liên quan và phạm vi

## 1. Bối cảnh

BrewLite là hệ thống web đặt đồ uống cho khách hàng. Khách xem thực đơn, chọn size và topping, quản lý giỏ hàng, đặt đơn, thanh toán và theo dõi lịch sử đơn. Hệ thống giúp giảm thao tác thủ công tại quầy và hạn chế bán vượt kho nguyên liệu.

Luồng chính: Xem menu -> Chọn món -> Giỏ hàng -> Đăng nhập -> Đặt đơn -> Thanh toán -> Xem trạng thái.

Công nghệ: Next.js (web), NestJS (API), PostgreSQL (dữ liệu), Prisma, Docker. Render được dùng để triển khai web và API. ZaloPay là cổng thanh toán Sandbox đang tích hợp.

## 2. Các bên liên quan

| Bên liên quan | Vai trò | Mong đợi |
| --- | --- | --- |
| Khách hàng | Người xem và mua đồ uống | Xem món, chọn tùy chọn, thanh toán an toàn, xem trạng thái, lịch sử và điểm |
| Nhân viên quầy | Nhận và pha chế đơn | Xem hàng đợi, đổi trạng thái từ đã thanh toán sang pha chế, sẵn sàng và hoàn tất |
| Quản lý cửa hàng | Quản lý vận hành | Kiểm soát tồn kho, các đơn và khuyến mãi |
| Giảng viên nghiệm thu | Người kiểm tra bài tập | Đối chiếu yêu cầu, sơ đồ, mã nguồn, test và triển khai |
| Nhóm phát triển | Xây dựng và bảo trì | Dễ kiểm thử, bảo trì, triển khai và truy vết thay đổi |
| Đơn vị thanh toán | ZaloPay Sandbox hoặc phương thức mô phỏng | Phản hồi thanh toán, đối soát khi callback chậm hoặc lỗi |

## 3. Phạm vi làm trong Assignment 2 (in-scope)

- Hiển thị menu, xem chi tiết món và các giá size S/M/L, tùy chọn topping, đường/đá.
- Quản lý giỏ hàng, tính tổng tiền theo số lượng, size và topping.
- Đăng ký, đăng nhập và xác thực JWT.
- Đặt đơn, lưu đơn trạng thái `PENDING`, chống gửi trùng bằng `Idempotency-Key`.
- Giữ trước nguyên liệu, coupon và điểm trong khi chờ thanh toán; tránh đặt vượt số lượng khả dụng.
- Thanh toán thử nghiệm: demo WALLET/CARD khi có cấu hình; ZaloPay Sandbox có QR/URL, callback và đối soát.
- Xem lịch sử đơn, trạng thái đơn, hủy đơn theo quy định.
- Áp coupon, sử dụng/đổi điểm, ghi lịch sử điểm thưởng.
- API cho nhân viên/quản trị xem hàng đợi, cập nhật pha chế và nhập kho.
- Docker local và CI/CD lên Render.

## 4. Phạm vi không làm (out-of-scope)

- Giao hàng qua bên thứ ba, điều phối shipper.
- Hệ thống kế toán hoặc quản trị chuỗi cửa hàng đầy đủ.
- Thu tiền thẻ thật thông qua mô-đun demo WALLET/CARD.
- Hoàn tiền thật qua ZaloPay Refund API. Việc hủy đơn ZaloPay Sandbox đã thanh toán chỉ ghi hoàn mô phỏng trong dữ liệu nội bộ, không có nghĩa đã hoàn tiền vào ví.
- Cam kết chạy offline toàn bộ nếu chưa có Service Worker và kiểm thử offline.

## 5. Giả định và ràng buộc

- Người dùng có thiết bị kết nối internet và trình duyệt hiện đại.
- Đơn phải gắn với tài khoản được xác thực khi đặt hoặc thanh toán.
- Backend tính lại giá từ database, không tin tổng tiền gửi từ trình duyệt.
- `Idempotency-Key` dài 8-128 ký tự cho thao tác tạo đơn; thanh toán cũng phải có khóa chống gửi trùng.
- Môi trường production mặc định không bật thanh toán demo bằng `ENABLE_DEMO_PAYMENTS`.
- Dùng Next.js, NestJS, PostgreSQL và Docker theo yêu cầu môn học.
- Không đưa `JWT_SECRET`, mật khẩu DB hoặc khóa ZaloPay vào GitHub public.

## 6. Rủi ro và hướng xử lý

| Rủi ro | Cách xử lý hoặc kiểm chứng |
| --- | --- |
| Gửi yêu cầu đặt đơn/thanh toán nhiều lần | `Idempotency-Key` và ràng buộc unique trong PostgreSQL |
| Nhiều khách đặt cùng một lúc gây âm kho | Transaction Serializable, giữ trước nguyên liệu và kiểm tra `version` |
| ZaloPay timeout, callback đến chậm | Lưu giao dịch `PENDING`, QueryDR/đối soát; không tự suy luận thất bại |
| Hủy đơn khi thanh toán chưa rõ kết quả | Chặn hủy cho đến khi đối soát giao dịch cổng |
| Lộ thông tin bí mật | Đọc biến môi trường trên Render/CI, không commit `.env` |
| Cloud triển khai lỗi | CI/CD dừng khi lỗi, health check; rollback bằng redeploy phiên bản ổn định trước |

## 7. Ghi chú về trạng thái hiện tại

Bản ZIP có mã cho các chức năng chính. Tuy nhiên một số tiêu chí như hiệu năng dưới 500 ms, khả năng offline và migration production cần minh chứng riêng, không tự coi là đã đạt chỉ từ việc có code.
