# ADR-003 - PostgreSQL và Prisma Migrate

- Trạng thái: Đang áp dụng Prisma ORM; baseline `0_init` đã được nhóm thực hiện trên Docker local, chưa được xác nhận trên Render Production.
- Bối cảnh: Hệ thống có bảng đơn hàng, thanh toán, nguyên liệu, coupon và điểm thưởng, cần khóa, transaction và kiểm soát lịch sử schema.
- Quyết định: Sử dụng PostgreSQL 16 và Prisma ORM (`apps/api/prisma/schema.prisma`). Database Docker local trống được tạo từ `dbBrewLite.sql`; database hiện có được ghi nhận baseline tại `apps/api/prisma/migrations/0_init/migration.sql` bằng `migrate resolve --applied 0_init`.
- Lý do: Giữ nguyên dữ liệu đang có, bổ sung lịch sử schema mà không thực thi lại các lệnh tạo bảng trên local.
- Ưu điểm: Cơ sở để quản lý các thay đổi schema tiếp theo, có thể kiểm tra bằng `prisma migrate status`.
- Hạn chế: `migrate resolve` chỉ ghi lịch sử, không kiểm tra hoặc thực thi SQL baseline. `0_init/migration.sql` lấy từ pg_dump còn hai dòng psql `\restrict` và `\unrestrict`; không nên dùng trực tiếp để tái tạo database trống trước khi xử lý và kiểm thử.
- Vận hành: Không dùng `migrate reset`, `db push` hoặc SQL khởi tạo để ghi đè database có dữ liệu. Trước migration Production phải backup, đối chiếu schema, thử nghiệm staging và ghi nhận baseline riêng cho môi trường Render.
- CI/CD hiện tại: CI tạo DB test bằng SQL; CD chưa gọi `prisma migrate deploy` lên Render.
- Minh chứng: `schema.prisma`, `dbBrewLite.sql`, `migrations/0_init/migration.sql`, `migration_lock.toml`, `docker-compose.yml`, `.github/workflows/ci.yml`.
