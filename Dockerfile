# 第一阶段：构建 Next.js 站点
FROM node:18 AS build-stage

# 设置工作目录
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm@8.15.8

# 复制 package.json 和 pnpm-lock.yaml（如果存在）
COPY package*.json pnpm-lock.yaml* pnpm-workspace.yaml* ./
COPY patches/ ./patches/

# 安装项目依赖
RUN pnpm install

# 只复制 docs 目录下的项目文件
COPY docs/ ./docs

# 设置 docs 为工作目录
WORKDIR /app/docs

# 构建 Next.js 站点
RUN pnpm run build

# 第二阶段：部署使用 Nginx
FROM nginx:stable-alpine as production-stage

# 将 Next.js 构建的静态文件从构建阶段复制到 Nginx 服务目录
COPY --from=build-stage /app/docs/.next/static /usr/share/nginx/html/_next/static
COPY --from=build-stage /app/docs/.next/server/pages /usr/share/nginx/html/_next/server/pages
COPY --from=build-stage /app/docs/public /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx，Nginx 默认会以前台方式运行
CMD ["nginx", "-g", "daemon off;"]
