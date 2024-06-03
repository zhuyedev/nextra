# 第一阶段：构建 Next.js 站点
FROM node:18 AS build-stage

# 设置工作目录
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm@8.15.8

# 复制整个项目文件
COPY . .

# 安装项目依赖
RUN pnpm install

# 构建 Next.js 站点
WORKDIR /app/docs

# 构建 Next.js 站点，假设构建命令已正确设置在项目的 package.json 中
RUN pnpm run build

# 第二阶段：部署使用 Nginx
FROM nginx:stable-alpine as production-stage

# 将 Next.js 构建的静态文件从构建阶段复制到 Nginx 服务目录
# 根据你的 next.js 配置，你可能需要调整这些路径
COPY --from=build-stage /app/.next/static /usr/share/nginx/html/_next/static
COPY --from=build-stage /app/.next/server/pages /usr/share/nginx/html/_next/server/pages
COPY --from=build-stage /app/public /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx，Nginx 默认会以前台方式运行
CMD ["nginx", "-g", "daemon off;"]
