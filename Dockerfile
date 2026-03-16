FROM node:20-bookworm-slim AS build

WORKDIR /app

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
COPY apps/backend/package.json /app/apps/backend/package.json
COPY apps/frontend/package.json /app/apps/frontend/package.json
COPY icon.svg /app/icon.svg

RUN npm ci

COPY apps/backend /app/apps/backend
COPY apps/frontend /app/apps/frontend

RUN npm run build:frontend

FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
COPY apps/backend/package.json /app/apps/backend/package.json
COPY apps/frontend/package.json /app/apps/frontend/package.json

RUN npm ci --omit=dev --workspace liquid-electrs-backend --include-workspace-root=false

COPY apps/backend /app/apps/backend
COPY --from=build /app/apps/frontend/dist /app/apps/frontend/dist

EXPOSE 3006

CMD ["npm", "run", "dev:backend"]
