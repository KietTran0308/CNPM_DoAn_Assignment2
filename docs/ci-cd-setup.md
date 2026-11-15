# Thiết lập GitHub Actions CI/CD – BrewLite Assignment 2

Repository: `KietTran0308/CNPM_DoAn_Assignment2`

## 1. Đã cấu hình những gì

- `.github/workflows/ci.yml`: khi mở PR vào `main`/`develop`, khi push lên 2 nhánh và khi chạy thủ công: kiểm tra TypeScript, chạy unit/integration trên PostgreSQL 16 riêng, build backend/frontend, và E2E HTTP trên máy runner.
- `.github/workflows/cd.yml`: khi push tag `v*`, gọi CI lại, build hai Docker image, push GHCR theo **commit SHA** và **tag phiên bản**, deploy lên Render API trước → Web sau, chờ trạng thái `live` của từng deploy, smoke-test `/health`, `/products` và homepage, rồi tạo GitHub Release Notes.
- `scripts/render-release.mjs`: gọi Render API, chờ deploy thực sự `live`, dừng pipeline nếu lỗi; **không** dùng cơ sở dữ liệu production trong CI.

Các thay đổi **chưa được push lên GitHub** trong gói này. Cần thêm file vào repo theo đúng đường dẫn và cấu hình Render/Actions bên dưới.

## 2. Cấu hình GitHub repository

Vào `https://github.com/KietTran0308/CNPM_DoAn_Assignment2/settings/secrets/actions`:

**Repository secret**:

- `RENDER_API_KEY`: API key từ Render Account Settings → API Keys, không công khai.

**Repository variables** (`Settings` → `Secrets and variables` → `Actions` → `Variables`):

- `RENDER_API_SERVICE_ID`: ID service backend `srv-...`.
- `RENDER_WEB_SERVICE_ID`: ID service frontend `srv-...`.
- `NEXT_PUBLIC_API_URL`: **HTTPS origin của API** (ví dụ `https://<backend>.onrender.com`, **không kèm `/api`** nếu route code là `/health` và `/products`).
- `PRODUCTION_WEB_URL`: HTTPS origin của web (ví dụ `https://<frontend>.onrender.com`).
- `RENDER_DEPLOY_MODE`: `git` hoặc `image`; mặc định `git` nếu chưa đặt.

**Không điền placeholder URL** vào Variables. Cần URL thực tế đúng dịch vụ Assignment 2.

Vào `Settings → Environments` tạo environment `production` và thiết lập **Required reviewers** nếu gói GitHub cho phép; cần duyệt thay đổi CSDL trước khi phát hành.

Vào `Settings → Rules → Rulesets` hoặc `Branches → Branch protection`:

- Target branch `main`.
- Require a pull request before merging.
- Require status checks: các jobs `API / lint - unit - integration - build`, `Web / lint - test - build`, `API / localhost E2E - isolated database` sau khi đã có lần CI chạy thực tế.
- Block merge khi checks không đạt (có thể tùy gói GitHub/repo visibility).

## 3. Cấu hình Render – CHỌN MỘT chế độ

### A. Mode `git` (dễ nhất khi Render đã kết nối source GitHub)

- Chỉ đặt `RENDER_DEPLOY_MODE=git` hoặc để trống.
- Trên Render, mỗi service chọn nguồn `Git repository` tới cùng repo, đặt Root Directory `apps/api` (backend) hoặc `apps/web` (frontend). Docker runtime có thể dùng Dockerfile trong từng thư mục.
- Tại Render > service > Settings > Auto-Deploy chọn **Off** để GitHub Actions điều phối; tránh deploy trước khi CI pass.
- Backend Environment: `DATABASE_URL`, `JWT_SECRET`, `FRONTEND_URL`, ZaloPay sandbox credentials/callback đúng môi trường và `ENABLE_DEMO_PAYMENTS=false`; `PORT` do Render cung cấp.
- Frontend cần build-time `NEXT_PUBLIC_API_URL` trùng biến GitHub, dùng HTTPS.
- CD vẫn publish hai Docker image lên GHCR để lưu vết, nhưng **Render mode git tự build lại từ commit SHA**, không chạy trực tiếp image GHCR.

### B. Mode `image` (đúng pipeline Build → Push GHCR → Render dùng image)

- Đặt `RENDER_DEPLOY_MODE=image`.
- Tạo **hai Render Web Services dạng prebuilt image** với lần lượt:
  - `ghcr.io/kiettran0308/cnpm_doan_assignment2-api:<tag ban đầu>`
  - `ghcr.io/kiettran0308/cnpm_doan_assignment2-web:<tag ban đầu>`
- Render phải đọc được GHCR images: chuyển package sang Public hoặc thiết lập registry credentials có quyền read package (không public secret).
- Service API/Web có cùng image repository/name như trên; CD chỉ thay tag theo SHA (`imageUrl`).
- Nếu trước đó đã tạo Git-backed services, bạn cần tạo/chuyển sang image-backed services trước khi bật mode này. Không thể gửi `imageUrl` cho dịch vụ Git-backed.
- Đặt các environment variables giống mode git. Trong Web image, `NEXT_PUBLIC_API_URL` được đóng vào lúc build bởi workflow.

## 4. Migration production – kiểm soát rủi ro

Source trong ZIP hiện chỉ chứa `prisma/dbBrewLite.sql` khởi tạo **database mới** và `schema.prisma`; chưa có `prisma/migrations/*/migration.sql` chính thức. Do vậy workflow này **không tự động chạy** `prisma db push`, nạp lại SQL hay `migrate deploy` trên production.

Trước khi phát hành bất kỳ thay đổi cấu trúc DB nào, cần tạo/baseline migrations chính thức; với database Render đang chứa dữ liệu phải xử lý baseline đúng chuẩn, sao lưu, thử trên staging, review thay đổi. Khi đã có migrations hợp lệ và tương thích ngược, cấu hình **Pre-Deploy Command** của Render API để chạy `npx prisma migrate deploy` (nếu môi trường Render/plan hỗ trợ) hoặc một bước migration riêng có quyền truy cập DB private. Đây là bước còn thiếu để đáp ứng trọn vẹn yêu cầu 'safe migration' của Assignment 2. Không tự chạy SQL khởi tạo database trên Render.

## 5. Bật CD bằng tag phiên bản

Sau khi CI xanh và Render config đã xong:

```bash
git switch main
git pull origin main
git tag -a v1.0.0 -m "BrewLite Assignment 2 release v1.0.0"
git push origin v1.0.0
```

Nếu đã có tag `v1.0.0`, hãy chọn số tag mới, ví dụ `v1.0.1`. Workflow sẽ chạy từ tag, kiểm tra chất lượng, đẩy image GHCR, triển khai Render rồi tạo GitHub Release Notes. Theo dõi tại `https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions`.

Lưu ý: nếu chạy `workflow_dispatch` trên branch thay vì tag `v*`, workflow sẽ từ chối phát hành; đây là chủ ý để không tạo release từ commit chưa gắn version.

## 6. Kiểm thử và minh chứng Assignment 2

1. Tạo PR thử nghiệm thay đổi nhỏ. Giữ ảnh GitHub Actions CI thành công.
2. Tạo PR cố ý gây lỗi compile trên nhánh test. Giữ ảnh CI thất bại, xác minh không thể merge khi branch protection đang có hiệu lực, sau đó sửa/revert.
3. Gắn tag release. Ghi lại GitHub Actions `quality → images → deploy → release`, 2 image GHCR theo SHA, Render deploy status `live`, 3 smoke checks, và link release notes.
4. Bổ sung vào báo cáo thật **chỉ khi** đã có log thực tế.

## 7. Rollback nếu production lỗi

- Chặn tiếp tục phát hành (GitHub Actions sẽ dừng khi `deploy` thất bại).
- Trên Render từng service: Deploys → chọn bản ổn định trước đó → Rollback, hoặc sử dụng Render API rollback với deploy ID đã xác định. Rollback **Web trước**, sau đó **API** nếu cần, chú ý tương thích API/UI và DB. Xác minh `/health`, `/products` và trang chủ.
- **Không** tự động rollback schema database; migration destructive có thể không đảo ngược an toàn. Sao lưu/staging/expand-contract là bắt buộc khi thay đổi dữ liệu.
- Nếu chỉ frontend lỗi, rollback web mà không đổi database/API.

## 8. Cần xử lý nếu CI thất bại

- `npm ci`: kiểm tra package-lock đúng theo package.json ở mỗi app.
- API integration test: xem postgres service và log khởi tạo `apps/api/prisma/dbBrewLite.sql`.
- E2E: chỉ dùng PostgreSQL test; W​ALLET được bật bằng UPDATE trong job E2E **mà không thay đổi production**.
- Nếu `/products` trống ở smoke: cần kiểm tra seed/catalog production đã được quản lý đúng, **không tự nạp demo fixtures** lên production.
- Bảo vệ `.env`: không đẩy key production. `.env.example` ZIP có giá trị sandbox mẫu và callback URL typo `hhttps://` – kiểm tra/sửa cấu hình thật trong Render.

## 9. Hạn chế đã xác định

- Chưa có Prisma migration thực tế; không thể chứng nhận đã deploy an toàn schema mới.
- Không thể tự tạo GitHub Secrets/Render services từ file cấu hình; cần cài đặt quyền và thông tin thực tế.
- Chưa có bằng chứng pipeline đã chạy thành công trên repo của bạn cho đến khi tạo PR/tag và kiểm tra Actions.
