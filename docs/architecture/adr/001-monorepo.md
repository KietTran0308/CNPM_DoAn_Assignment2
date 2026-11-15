# ADR-001 - Dùng Monorepo

- Trạng thái: Đang áp dụng.
- Bối cảnh: BrewLite có Frontend, Backend, tài liệu UML và CI/CD cần đồng bộ.
- Quyết định: Đặt ứng dụng trong `apps/web` và `apps/api`, sơ đồ và yêu cầu trong `docs`, workflow trong `.github/workflows` cùng một repository GitHub.
- Lý do: Dễ truy vết từ yêu cầu sang code/test và quản lý chung lịch sử commit.
- Ưu điểm: Một PR có thể xem tác động đến cả hai ứng dụng; tránh trôi phiên bản API giữa Web và Backend.
- Hạn chế: CI phải cấu hình đúng thư mục làm việc và cache riêng; có thể tốn thời gian build.
- Minh chứng: `apps/web`, `apps/api`, `docs`, `.github/workflows/ci.yml`.
