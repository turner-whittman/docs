FROM node:18-alpine AS runner
WORKDIR /app

RUN npm i -g mintlify

COPY . .

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

USER nextjs
EXPOSE 3000


CMD ["mintlify", "dev"]

