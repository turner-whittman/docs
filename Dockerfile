FROM node:22-alpine AS runner
WORKDIR /app

RUN npm i -g mint

COPY . .

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

USER nextjs
EXPOSE 3000


CMD ["mint", "dev"]

