# ================= STAGE 1: Build =================
# Giai đoạn này dùng để build ứng dụng TypeScript ra JavaScript
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Sao chép file dependencies và cài đặt tất cả (bao gồm cả devDependencies để build)
COPY package*.json ./
RUN npm install

# Sao chép toàn bộ mã nguồn
COPY . .

# Xóa thư mục node_modules cũ và cài lại chỉ production dependencies
# Điều này đảm bảo node_modules trong thư mục build sẽ gọn nhẹ
RUN rm -rf node_modules
RUN npm install --omit=dev --ignore-scripts

# Chạy lệnh build
RUN npm run build

# ================= STAGE 2: Production =================
# Giai đoạn này tạo ra image cuối cùng, siêu nhẹ để chạy ứng dụng
FROM node:20-alpine

WORKDIR /usr/src/app

# Sao chép chỉ các production dependencies từ giai đoạn 'builder'
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Sao chép thư mục dist (chứa code JS đã biên dịch) từ giai đoạn 'builder'
COPY --from=builder /usr/src/app/dist ./dist

# Sao chép package.json để có thông tin về ứng dụng (tùy chọn nhưng nên có)
COPY package.json .

# Lệnh khởi động ứng dụng trực tiếp bằng node, hiệu quả hơn
CMD ["node", "dist/main.js"]