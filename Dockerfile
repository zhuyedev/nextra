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

# 第二阶段：运行 Next.js 服务器
FROM node:18 as production-stage


# 设置工作目录
WORKDIR /app

# 复制构建输出和必要的文件
COPY --from=build-stage /app/docs /app

# 暴露 80 端口
EXPOSE 3000

# 启动 Next.js 服务器
CMD ["node", "/app/.next/server/pages/_app.js"]
