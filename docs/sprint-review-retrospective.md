# Sprint Review và Sprint Retrospective - BrewLite

Đây là bản tổng hợp dựa trên tiến độ repository và kết quả CI/CD. Nhóm cần bổ sung ngày họp, thành viên tham dự và phản hồi thật nếu giảng viên yêu cầu biên bản cuộc họp.

## Sprint 1 - Nền tảng và menu

Mục tiêu: có repository, tài liệu yêu cầu/sơ đồ/kiến trúc, NestJS API trả menu, Next.js hiển thị menu, cấu hình CI cơ bản.

Kết quả có trong source: Monorepo `apps/web`/`apps/api`, API `GET /products`, `GET /products/:id`, các sơ đồ Activity/Sequence/Class và workflow CI.

Điểm làm tốt: Chọn công nghệ thống nhất; chia tầng UI/API/Database; có kiểm thử sản phẩm và build tự động.

Điểm cần cải thiện: File tài liệu Task 1 và ADR còn thiếu/rỗng trong bản ZIP trước khi bổ sung; commit/PR/Issue Board chưa có minh chứng trên GitHub repository hiện tại.

Hành động: Lưu tài liệu trong `docs/`, mở PR để cập nhật, kèm link CI và ảnh kiểm chứng.

## Sprint 2 - Thanh toán và triển khai

Mục tiêu: hoàn thiện đặt đơn, thanh toán, quản lý trạng thái, test integration/E2E, Docker, CD và Render.

Kết quả trong source: Giỏ hàng, xác thực JWT, tạo đơn giữ kho, thanh toán demo và ZaloPay Sandbox, callback/QueryDR, lịch sử đơn, test Jest/HTTP E2E, Docker Compose.

Kết quả có minh chứng trên GitHub:

- CI success: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions/runs/43744261941
- CD success: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions/runs/43737678839
- Release v1.0.0: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/releases/tag/v1.0.0

Điểm làm tốt: Pipeline CD có quality gates, image GHCR, redeploy Render, health/products/homepage smoke. E2E HTTP đã kiểm tra tạo và thanh toán đơn trong DB test độc lập.

Điểm cần cải thiện: Chưa có browser E2E, chưa kiểm thử baseline Prisma để tái tạo database trống hoặc áp dụng trên Render Production, chưa đủ đo hiệu năng và minh chứng rollback thử nghiệm. Kết quả ZaloPay Sandbox không tương đương thanh toán/hoàn tiền thật.

Hành động: Bổ sung minh chứng kiểm thử UI, thử migration đã được kiểm tra trên staging, chụp trạng thái Production, kiểm tra PWA và diễn tập rollback. Nhóm đã đánh dấu baseline `0_init` trên Docker local nhưng chưa tự động hóa migration CD.

## Biên bản họp (nhóm điền)

- Ngày/giờ họp: Chưa cung cấp.
- Thành viên tham dự: Chưa cung cấp.
- Phản hồi của Product Owner/giảng viên: Chưa cung cấp.
- Quyết định và người chịu trách nhiệm: Nhóm cập nhật sau cuộc họp thật.
