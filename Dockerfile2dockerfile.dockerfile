//Dokerfileの作成 (nextjs/Dockerfile)

//ベースイメージの作成
FROM node:20.17.0-alpine3.20  AS builder

//作業ディレクトリを指定
WORKDIR /app

//依存関係をインストールするため、package.jsonとpackage-lock.jsonをコピー
COPY package.json package-lock.json ./

//依存関係をインストール
RUN npm install

//アプリケーションのソースコードをコピー
COPY . . 

//Prisma Clientを作成
RUN npx prisma generate

//Next.jsアプリケーションをビルド
RUN npm run build

-------------マイグレーション用のステージ---------------------
//ベースイメージの作成
FROM node:20.17.0-alpine3.20 AS migration

//作業ディレクトリを指定
WORKDIR /app

//必要なファイルをビルダーからコピー
COPY --from=builder /app/package.json    ./
COPY --from=builder /app/node_ modules ./node_modules
COPY --from=builder /app/prisma        ./prisma

//マイグレーション用の実行
CMD ["npx", "prisma", "migrate", "deploy"]

-------------プロダクション環境用の軽量イメージ------------------
//ベースイメージの作成
FROM node:20.17.0-alpine3.20 AS runner

//作業ディレクトリを指定
WORKDIR /app

//必要なファイルをビルダーからコピー
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next        ./.next

//Next.jsアプリケーションを実行
CMD ["npm", "start"]

