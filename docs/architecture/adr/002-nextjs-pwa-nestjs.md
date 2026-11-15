# ADR-002 - Tách Next.js và NestJS

- Trạng thái: Đang áp dụng; PWA cần kiểm chứng bổ sung.
- Bối cảnh: Website cần giao diện di động, quản lý giỏ hàng; nghiệp vụ đặt đơn và thanh toán cần kiểm soát trên server.
- Quyết định: Next.js xử lý UI trong `apps/web`; NestJS xử lý xác thực, sản phẩm, đơn, thanh toán, điểm và kho trong `apps/api`; giao tiếp HTTP/JSON.
- Lý do: Tách trách nhiệm; backend xác minh JWT/DTO và tính lại giá từ DB thay vì tin client.
- Ưu điểm: Có thể build, test và triển khai mỗi dịch vụ độc lập.
- Hạn chế: Phải khai báo `NEXT_PUBLIC_API_URL` lúc build Next.js và CORS (`FRONTEND_URL`) trên API.
- Ghi chú: Manifest đã có nhưng chưa thấy Service Worker trong ZIP; không mô tả là có chế độ offline nếu chưa làm.
- Minh chứng: `apps/web/src/app`, `apps/api/src/main.ts`, `apps/api/src/AppModule.ts`.
