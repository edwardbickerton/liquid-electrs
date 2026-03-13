FROM node:16-buster-slim AS build

WORKDIR /app

COPY package.json /app/package.json
COPY apps/backend/package.json /app/apps/backend/package.json
COPY apps/frontend/package.json /app/apps/frontend/package.json

RUN npm install

COPY . /app

RUN npm run build:frontend

FROM node:16-buster-slim

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app /app

EXPOSE 3006

CMD ["npm", "run", "dev:backend"]
