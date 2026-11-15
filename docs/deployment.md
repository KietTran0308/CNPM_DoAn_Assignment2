# Task 3.2 và 5.4 - Triển khai BrewLite

## 1. Các môi trường

| Môi trường | Web | API | Database |
| --- | --- | --- | --- |
| Local Docker | `http://localhost:3200` | `http://localhost:4200` | PostgreSQL 16 cổng host `127.0.0.1:5434` |
| GitHub CI | Next.js test/build | NestJS test/build + HTTP E2E localhost | PostgreSQL 16 test trong GitHub Actions |
| Render production | `https://brewlite-a2-frontend.onrender.com` | `https://brewlite-a2-backend.onrender.com` | PostgreSQL được kết nối qua `DATABASE_URL` (cần xác minh private access trên Render) |

## 2. Luồng chạy thực tế

- Browser gọi Frontend trên Render qua HTTPS.
- Frontend gọi NestJS API qua HTTPS. CORS được khai báo bằng `FRONTEND_URL`.
- API truy cập PostgreSQL bằng Prisma.
- API gọi ZaloPay Sandbox để tạo giao dịch, nhận callback HTTPS và có thể dùng QueryDR để đối soát.
- GitHub Actions CI kiểm tra Web, API và HTTP E2E.
- GitHub Actions CD build và push image GHCR, sau đó gọi Render API để redeploy API rồi Web.
- Trong CD thành công ngày 15/11/2026, `RENDER_DEPLOY_MODE=git` nên Render triển khai theo commit SHA, KHÔNG lấy image vừa push ở GHCR.

## 3. Chạy local

Tạo `.env` từ `.env.example` tại thư mục gốc (KHÔNG commit `.env`):

```powershell
Copy-Item .env.example .env
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

Kiểm tra:

```powershell
Invoke-WebRequest http://localhost:4200/health
Invoke-WebRequest http://localhost:4200/products
```

DB local dùng volume `brewlite_assignment2_pg16_fresh`. File `apps/api/prisma/dbBrewLite.sql` chỉ được tự import vào database mới, khi volume chưa có dữ liệu. Không chạy `docker compose down -v` nếu muốn giữ dữ liệu.

## 4. Cấu hình quan trọng

- `DATABASE_URL`: chuỗi kết nối PostgreSQL.
- `JWT_SECRET`: khóa ký JWT dài, ngẫu nhiên.
- `FRONTEND_URL`: domain frontend được phép gọi API, ví dụ `https://brewlite-a2-frontend.onrender.com`.
- `NEXT_PUBLIC_API_URL`: origin API HTTPS, áp dụng tại thời điểm build frontend.
- `ZALOPAY_APP_ID`, `ZALOPAY_KEY1`, `ZALOPAY_KEY2`: khóa Sandbox, chỉ lưu trong env.
- `ZALOPAY_CALLBACK_URL`: callback trỏ tới `https://brewlite-a2-backend.onrender.com/payments/zalopay/callback` khi cấu hình callback production.
- `ENABLE_DEMO_PAYMENTS`: để `false` ở production.
- GitHub Actions secrets/vars: `RENDER_API_KEY`, `RENDER_API_SERVICE_ID`, `RENDER_WEB_SERVICE_ID`, `NEXT_PUBLIC_API_URL`, `PRODUCTION_WEB_URL`, `RENDER_DEPLOY_MODE`.

## 5. CI/CD và smoke test

- CI thành công (Web/API/E2E): https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions/runs/43744261941
- CD thành công: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions/runs/43737678839
- Log CD ngày 15/11/2026 xác nhận API `/health`, API `/products` và Web `/` vượt smoke test sau deploy. Đó là bằng chứng tại thời điểm chạy, không thay thế kiểm tra khả dụng tại thời điểm nghiệm thu.
- Release: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/releases/tag/v1.0.0

## 6. Database migration

ZIP đã có `apps/api/prisma/migrations/0_init/migration.sql` và `migration_lock.toml`. Nhóm đã thực hiện baseline `0_init` trên Docker local đang có dữ liệu; lệnh `prisma migrate resolve --applied 0_init` chỉ đánh dấu migration đã áp dụng, không thực thi lại SQL tạo bảng.

Kiểm tra trạng thái trên Docker local (không thay đổi dữ liệu):

```powershell
docker compose exec api ./node_modules/.bin/prisma migrate status
```

CI hiện vẫn tạo PostgreSQL thử nghiệm bằng `dbBrewLite.sql`. CD hiện chưa thực hiện `prisma migrate deploy` trên Render Production. Không được suy ra Production đã được baseline chỉ từ kết quả Docker local.

Lưu ý: baseline xuất bằng `pg_dump` có các dòng `\restrict`/`\unrestrict` dành riêng cho psql, cần xử lý và kiểm tra khả năng áp dụng SQL trước khi dùng migration tạo database trống. Nếu đã đánh dấu migration applied thì không tự ý sửa file baseline vì có thể sai checksum.

Khi triển khai migration Production: sao lưu, đối chiếu cấu trúc database Render với baseline, thử nghiệm trên staging, đánh giá thay đổi phá vỡ tương thích, rồi chạy migration mới có kiểm soát. Không chạy `migrate reset`/`db push` trên Production.

## 7. Rollback khi lỗi

1. Mở GitHub Actions, xác định job/CD deploy thất bại.
2. Mở Render, kiểm tra logs và phiên bản/commit đang chạy.
3. Chọn commit/deploy ổn định trước đó và redeploy API/Web phù hợp; với DB migration cần đánh giá riêng thay vì tự đảo schema.
4. Kiểm tra `/health`, `/products`, trang chủ và luồng đặt đơn không ảnh hưởng dữ liệu.
5. Ghi nguyên nhân, thời gian và phiên bản đã khôi phục vào biên bản.

Rollback hiện là quy trình thủ công. Không có bằng chứng rollback tự động hoặc zero-downtime trong ZIP.

## 8. Bảo mật

Không commit `.env`, mật khẩu DB, JWT secret hoặc khóa ZaloPay. Nếu khóa thật từng xuất hiện trong repo public, phải thu hồi và thay khóa. Khuyến nghị cấu hình database production không public trực tiếp và kiểm tra thực tế trên Render Dashboard trước nghiệm thu.
