# ADR-005 - GitHub Actions, GHCR và Render

- Trạng thái: Đang áp dụng theo chế độ Render Git deploy.
- Bối cảnh: Cần CI/CD và đường dẫn HTTPS truy cập từ ngoài localhost.
- Quyết định: Dùng GitHub Actions để lint/test/build, tạo và push Docker images lên GHCR; dùng Render cho Web, API và PostgreSQL.
- Triển khai được xác nhận: CD ngày 15/11/2026 chạy `RENDER_DEPLOY_MODE=git`. Script gọi Render API theo commit SHA; GHCR image được build/push nhưng Render không sử dụng image đó trong lần deploy này.
- Ưu điểm: Có quality gates, phát hành theo tag, theo dõi logs và chạy smoke `/health`, `/products`, trang web.
- Hạn chế: Phụ thuộc Render; rollback chưa tự động; các bước migration production an toàn cần xác minh riêng.
- Rollback hiện tại: Chọn phiên bản/commit ổn định trước đó trên Render, redeploy, kiểm tra health và dữ liệu. Không giả định rollback code có thể tự rollback schema.
- Minh chứng: `.github/workflows/ci.yml`, `.github/workflows/cd.yml`, `scripts/render-release.mjs`.
- CD: https://github.com/KietTran0308/CNPM_DoAn_Assignment2/actions/runs/43737678839
