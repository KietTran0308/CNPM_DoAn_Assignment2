# CNPM – BrewLite Assignment 2

Monorepo: Next.js trong `apps/web`, NestJS trong `apps/api`; PostgreSQL 16 chạy độc lập trên Docker local. Source nghiệp vụ được giữ nguyên.

## Docker local (không trùng BrewLite gốc)

Tại thư mục gốc có `docker-compose.yml`:

```powershell
Copy-Item .env.example .env
# Sửa POSTGRES_PASSWORD / JWT_SECRET / ZALOPAY_APP_ID, KEY1, KEY2 trong .env

docker compose config --quiet
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 db
docker compose logs --tail=100 api
```

- Website Assignment 2: <http://localhost:3200>
- API health Assignment 2: <http://localhost:4200/health>
- API products Assignment 2: <http://localhost:4200/products>
- PostgreSQL Assignment 2: host `127.0.0.1`, port `5434`, database theo `POSTGRES_DB` (mặc định `brewlite`).
- Frontend/backend bên trong container vẫn lắng nghe cổng 3000/4000, PostgreSQL vẫn 5432; chỉ host port khác.

Container DB dùng volume **`brewlite_assignment2_pg16_fresh`** (giữ nguyên tên từ file đã nhận), hoàn toàn khác volume BrewLite 1. File `apps/api/prisma/dbBrewLite.sql` chỉ được tự import một lần trên volume hoàn toàn trống. Nếu volume Assignment 2 đã có dữ liệu, không tự chạy lại SQL. **Không dùng `docker compose down -v` nếu muốn giữ DB.**

Nếu muốn chạy lại riêng Frontend/Backend sau khi sửa code:

```powershell
docker compose up -d --build web
docker compose up -d --build api
```

Nếu thấy cổng vẫn dùng bản cũ, kiểm tra `docker compose config`, `.env`, biến môi trường và khởi động lại container với `docker compose up -d --force-recreate web api`.

## ZaloPay Sandbox trong Docker local

- `ZALOPAY_LOCAL_MODE=true` (container API); callback URL local mặc định để trống.
- Backend tự đối soát QueryDR; **không** trỏ callback của Docker local sang Render vì database local khác.
- Nếu cần callback có HTTPS tunnel, đặt `ZALOPAY_LOCAL_CALLBACK_URL=https://<tunnel-domain>/payments/zalopay/callback`, trỏ về chính API local `localhost:4200`.
- `NEXT_PUBLIC_API_URL=http://localhost:4200` được đưa vào Next.js tại thời điểm Docker build; đổi biến này phải build lại `web`.
- Không đưa khóa ZaloPay, JWT secret, DB password lên Git.

## Render (không dùng Compose local để cấu hình Render)

Trên Render, Root Directory cho hai Web Services: `apps/web` và `apps/api`. Node service phía API sử dụng `PORT` do Render cấp; frontend cần `NEXT_PUBLIC_API_URL` là HTTPS của API Assignment 2 ở thời điểm build. Route nhận callback có thật trong code là `POST /payments/zalopay/callback`.

Nếu cả BrewLite 1 và Assignment 2 **dùng cùng một database PostgreSQL**, dữ liệu đơn/giao dịch và scheduler đối soát cùng tồn tại. Cần tránh deploy migration xung đột và kiểm thử race-condition; không tạo lại schema SQL trên DB có dữ liệu. Việc đổi cổng Docker local không thay đổi kết nối database trên Render.

## Kiểm tra mã và chạy test

```powershell
cd apps/api
npm ci
npm run lint
npm test
npm run build

cd ../web
npm ci
npm run lint
npm test
npm run build
```

Integration tests thật cần DB thử nghiệm tách biệt. Script `apps/api/scripts/e2e.mjs` là E2E HTTP Node, không phải Playwright; không chạy E2E trên Production. `package.json` và `package-lock.json` ở **cả hai ứng dụng đều phải giữ** để Docker chạy `npm ci`.

## Tài liệu/Minh chứng

Xem `docs/report-completion-checklist.md`. Báo cáo PDF đang có nhiều ảnh UML nhưng chưa có file `.puml` / `.svg` tương ứng trong ZIP. Không đánh dấu CI/CD, test hay triển khai là `PASSED` khi chưa có log/URL thực tế.
