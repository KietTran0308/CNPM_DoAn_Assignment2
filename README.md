# \# BrewLite - Assignment 2

# 

# BrewLite là ứng dụng đặt đồ uống, tạo đơn, thanh toán và theo dõi đơn hàng.

# Dự án dùng Next.js (frontend), NestJS (backend), PostgreSQL 16, Prisma ORM và Docker.

# 

# \## 1. Cấu trúc dự án

# 

# \- `apps/web`: giao diện Next.js.

# \- `apps/api`: NestJS API và Prisma.

# \- `apps/api/prisma/dbBrewLite.sql`: tạo cấu trúc và dữ liệu mẫu khi PostgreSQL Docker có volume trống.

# \- `apps/api/prisma/migrations`: lịch sử Prisma Migrate.

# \- `docs/requirements`: bối cảnh, SRS và use-case.

# \- `docs/diagrams`: các sơ đồ UML và ảnh.

# \- `docs/architecture`: mô tả kiến trúc và các ADR.

# \- `docs/traceability-matrix.md`: ma trận truy vết yêu cầu.

# \- `docs/deployment.md`: môi trường và quy trình triển khai.

# \- `.github/workflows`: CI và CD.

# 

# \## 2. Chạy bằng Docker (Windows PowerShell)

# 

# Yêu cầu: đã cài Docker Desktop, Docker Compose và Git.

# 

# Tại thư mục gốc dự án, chạy:

# 

# \*\*Nếu đã có `.env` và Docker chạy tốt, bỏ qua bước tạo file. \*\*Không ghi đè `.env` đang dùng\*\*. File `.env.example` chỉ chứa giá trị mẫu, không phải mật khẩu thật.\*\*

# 

# ```powershell

# Copy-Item .env.example .env

# ```

# 

# Mở `.env`, thay ít nhất `POSTGRES\_PASSWORD` và `JWT\_SECRET` bằng giá trị riêng đủ mạnh.

# Nếu cần thanh toán ZaloPay Sandbox, nhập thêm `ZALOPAY\_APP\_ID`, `ZALOPAY\_KEY1`, `ZALOPAY\_KEY2` hợp lệ.

# Không dùng khóa Production để thử nghiệm hoặc đẩy `.env` lên GitHub. Nếu PostgreSQL volume đã có dữ liệu, không tự đổi `POSTGRES\_PASSWORD` trong `.env` vì tài khoản database cũ không tự đổi mật khẩu.

# 

# ```powershell

# docker compose config --quiet

# docker compose up -d --build

# docker compose ps

# ```

# 

# Đường dẫn local:

# 

# \- Website: http://localhost:3200

# \- API: http://localhost:4200

# \- Kiểm tra API: http://localhost:4200/health

# \- Menu JSON: http://localhost:4200/products

# \- PostgreSQL: `127.0.0.1:5434` (nội bộ Docker là `db:5432`).

# 

# Nếu muốn xem log:

# 

# ```powershell

# docker compose logs --tail=100 api

# docker compose logs --tail=100 web

# ```

# 

# Dừng container nhưng vẫn giữ dữ liệu:

# 

# ```powershell

# docker compose down

# ```

# 

# \*\*Không chạy `docker compose down -v`\*\* nếu muốn giữ PostgreSQL hiện có.

# SQL trong `dbBrewLite.sql` chỉ tự chạy khi volume database hoàn toàn trống.

# Không dùng SQL khởi tạo để ghi đè database đang có dữ liệu.

# 

# \## 3. Chức năng chính

# 

# \- Xem menu, chi tiết đồ uống, chọn kích cỡ và topping.

# \- Thêm/xóa món trong giỏ hàng và tính tổng tiền.

# \- Đăng ký, đăng nhập bằng JWT.

# \- Tạo đơn, kiểm tra và giữ trước nguyên liệu; ngăn đơn trùng bằng Idempotency-Key.

# \- Thanh toán qua ZaloPay Sandbox, hiển thị QR và đối soát callback/QueryDR.

# \- Có phương thức thanh toán mô phỏng dành cho môi trường kiểm thử khi được bật.

# \- Theo dõi trạng thái, lịch sử đơn hàng, hủy đơn theo điều kiện.

# \- Hỗ trợ mã giảm giá và điểm thưởng; Backend có API hàng đợi và cập nhật trạng thái cho nhân viên (chưa có giao diện nhân viên riêng trong ZIP).

# 

# ZaloPay Sandbox không phải thanh toán tiền thật. Chỉ xem đơn là đã thanh toán sau khi Backend xác minh kết quả.

# Docker local không gửi callback sang Backend Render vì hai môi trường có thể dùng database khác nhau.

# 

# \## 4. Kiểm thử

# 

# Cài Node.js 22 nếu muốn chạy lệnh npm ngoài Docker.

# 

# Backend:

# 

# ```powershell

# cd apps/api

# npm ci

# npm run prisma:generate

# npm run lint

# npm test

# npm run build

# ```

# 

# Frontend (mở PowerShell tại thư mục gốc rồi chạy):

# 

# ```powershell

# cd apps/web

# npm ci

# npm run lint

# npm test

# npm run build

# ```

# 

# `npm test` Backend chạy Jest unit tests; những integration tests có sử dụng PostgreSQL được bỏ qua nếu không đặt `TEST\_DATABASE\_URL`.

# Chỉ chạy integration/HTTP E2E trên database thử nghiệm \*\*tên `brewlite\_test`\*\*, không dùng database local đang có đơn hoặc database Production.

# GitHub Actions tự khởi tạo PostgreSQL `brewlite\_test` độc lập và chạy các bài kiểm thử này.

# 

# Kiểm tra API đang chạy với Docker local:

# 

# ```powershell

# curl.exe http://localhost:4200/health

# curl.exe http://localhost:4200/products

# ```

# 

# \## 5. Prisma Migrate

# 

# Docker local dùng SQL để khởi tạo dữ liệu ban đầu. Với database \*\*đã có dữ liệu\*\*, nhóm sử dụng baseline `0\_init` để đánh dấu cấu trúc hiện tại đã được áp dụng.

# Kiểm tra lịch sử migration trong Docker:

# 

# ```powershell

# docker compose exec api ./node\_modules/.bin/prisma migrate status

# ```

# 

# Không dùng `prisma migrate reset` hoặc `prisma db push` trên database đang có dữ liệu thực tế.

# Không tự động chạy `migrate deploy` vào Render khi database Production chưa được sao lưu, đối chiếu schema và baseline riêng.

# Lưu ý: migration `0\_init` được xuất bằng `pg\_dump` còn cú pháp `\\restrict` và `\\unrestrict` của psql; cần xử lý/kiểm thử bản SQL trước khi dùng nó tái tạo database trống. Không sửa migration đã được đánh dấu áp dụng mà chưa đánh giá checksum/lịch sử.

# 

# Các file seed bổ sung trong `apps/api/prisma/` được dùng cho \*\*database demo/test đã có schema\*\*, không tự chạy trên Production:

# 

# ```powershell

# cd apps/api

# npm run db:seed

# ```

# 

# `db:seed` đã bao gồm danh mục phương thức thanh toán. Bạn cũng có thể chạy `npm run db:seed:catalog` riêng nếu chỉ cần danh mục. Hai lệnh cần `DATABASE\_URL` trỏ đúng database demo/test đã có schema (có thể tạo `apps/api/.env` từ file mẫu của API nếu chạy CLI trên Windows). Không chạy chúng trên Production.

# 

# \## 6. CI/CD và triển khai Render

# 

# Repository: https://github.com/KietTran0308/CNPM\_DoAn\_Assignment2

# 

# \- CI: `.github/workflows/ci.yml` kiểm tra API, Web và HTTP E2E bằng PostgreSQL test.

# \- CD: `.github/workflows/cd.yml` chạy quality gate, build/push Docker images lên GHCR, triển khai hai dịch vụ Render và smoke test.

# \- CD phát hành bằng tag dạng `v1.0.0`, hoặc chạy thủ công với ref là release tag.

# \- Render hiện có thể được cấu hình ở chế độ Git deploy (`RENDER\_DEPLOY\_MODE=git`), tức image GHCR được đẩy lên nhưng không phải nguồn triển khai của Render.

# \- Migration PostgreSQL Production \*\*chưa tự động hóa\*\* trong pipeline CD.

# 

# Các thông số CD cấu hình trong GitHub Actions Secrets/Variables: `RENDER\_API\_KEY`, `RENDER\_API\_SERVICE\_ID`, `RENDER\_WEB\_SERVICE\_ID`, `NEXT\_PUBLIC\_API\_URL`, `PRODUCTION\_WEB\_URL`, `RENDER\_DEPLOY\_MODE`.

# 

# Production tham khảo:

# 

# \- Web: https://brewlite-a2-frontend.onrender.com

# \- API: https://brewlite-a2-backend.onrender.com

# \- Health: https://brewlite-a2-backend.onrender.com/health

# 

# Cần kiểm tra các URL đang hoạt động tại thời điểm nghiệm thu; liên kết không tự chứng minh deployment mới nhất đã thành công.

# 

# \## 7. Rollback khi triển khai thất bại

# 

# 1\. Kiểm tra job thất bại trong GitHub Actions và logs của Render.

# 2\. Trên Render, triển khai lại commit/deploy ổn định gần nhất cho API và Web.

# 3\. Kiểm tra `/health`, `/products`, trang chủ và nghiệp vụ đặt đơn.

# 4\. Nếu lỗi liên quan database, sao lưu và đánh giá thay đổi schema riêng; rollback mã nguồn không tự đảo database.

# 5\. Ghi lại nguyên nhân và phiên bản đã khôi phục.

# 

# \## 8. Tài liệu và minh chứng

# 

# \- `docs/requirements/context-and-scope.md`, `srs.md`, `use-case-checkout.md`.

# \- `docs/diagrams/`: Use-case, Activity, Sequence, Class, Deployment.

# \- `docs/architecture/overview.md` và `docs/architecture/adr/`.

# \- `docs/deployment.md`, `docs/traceability-matrix.md`.

# \- `docs/sprint-review-retrospective.md`.

# \- API HTTP E2E: `apps/api/scripts/e2e.mjs`.

# \- GitHub Actions: https://github.com/KietTran0308/CNPM\_DoAn\_Assignment2/actions

#


