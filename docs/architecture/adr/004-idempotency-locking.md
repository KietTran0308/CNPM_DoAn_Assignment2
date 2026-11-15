# ADR-004 - Chống đơn trùng và bán vượt kho

- Trạng thái: Đang áp dụng.
- Bối cảnh: Mạng chậm, người dùng bấm nhiều lần; hai khách có thể đặt cùng nguyên liệu tồn kho.
- Quyết định: Dùng `Idempotency-Key` (unique trong Orders/Payments), transaction Serializable, giữ trước nguyên liệu và so khớp `version` của Ingredient.
- Lý do: Ngăn tạo đơn và thanh toán lặp; hạn chế bán vượt kho trước khi thanh toán được xác nhận.
- Cơ chế: Khi tạo Order `PENDING`, giữ trước lượng nguyên liệu, coupon và điểm. Khi `PAID`, tiêu thụ nguồn lực; khi hủy hợp lệ, hoàn giữ. Giao dịch ZaloPay chưa rõ kết quả vẫn phải được đối soát.
- Ưu điểm: Có thể chạy với PostgreSQL, không cần Redis cho bài tập hiện tại.
- Hạn chế: Tranh chấp có thể trả 409, cần client hiển thị thông báo rõ. Có thể phải xử lý retry transaction.
- Minh chứng: `orders.service.ts`, `payments.service.ts`, `order-state.ts`, `reservation.integration.spec.ts`, `stock.integration.spec.ts`.
