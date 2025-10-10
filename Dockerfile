# ================= STAGE 1: Build =================
FROM node:20-alpine AS builder
WORKDIR /usr/src/app

COPY package*.json ./
# Cài đặt tất cả các gói để có công cụ build
RUN npm install

COPY . .
# Build ứng dụng NGAY BÂY GIỜ khi @nestjs/cli vẫn còn
RUN npm run build

# Dọn dẹp node_modules để chuẩn bị cho Stage 2
RUN npm prune --production

# ================= STAGE 2: Production =================
FROM node:20-alpine
WORKDIR /usr/src/app

# Chỉ sao chép những gì cần thiết để chạy ứng dụng
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package*.json ./

CMD ["node", "dist/main.js"]