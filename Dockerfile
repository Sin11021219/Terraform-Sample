//ベースイメージを指定
FROM node:20.17.0-alpine3.20 AS builder

//作業ディレクトリを指定
WORKDIR /app

//依存関係をインストール
COPY package.json package-lock.json ./

//依存関係をインストール
RUN npm install

//アプリケーションのソースコードをコピー
COPY . .

//Prisma Client を作成
RUN npx prisma generate

//Next.jsアプリケーションをビルド
RUN npm run builder

//======マイグレーション用のステージ=======
FROM node:20.17.0-alpine3.20 AS migration
//作業ディレクトリを指定
WORKDIR /app

//必要なファイルをビルダーからコピー
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --form=builder /app/prisma       ./prisma

//マイグレーションの実行
CMD ["npx", "prisma", "migrate", "deploy"]

//========プロダクション環境用の軽量イメージ====
FROM node:20.17.0-alpine3.20 AS runner

//作業ディレクトリを指定
WORKDIR /app

//必要なファイルをビルダーからコピー
COPY --from=builder /app/package      ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next        ./.next

//Next.jsアプリケーションを実行
CMD ["npm", "start"]




