# syntax=docker/dockerfile:1.5.2
FROM node:20.2-alpine3.17 AS base

# Install necessary packages and Turborepo
RUN apk add -f --update --no-cache --virtual .gyp nano bash libc6-compat python3 make g++ \
      && yarn global add turbo \
      && apk del .gyp

# Common build stage for both services
FROM base AS builder
WORKDIR /app

COPY . .

# Prune the workspaces to only include the necessary packages
ARG APP
RUN turbo prune --scope=$APP --docker

# Installer stage for dependencies
FROM base AS installer
WORKDIR /app
ARG APP

COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/yarn.lock /app/yarn.lock
COPY apps/${APP}/package.json /app/apps/${APP}/package.json

# Install dependencies for the specific app
RUN \
      --mount=type=cache,target=/usr/local/share/.cache/yarn/v6,sharing=locked \
      yarn --prefer-offline --frozen-lockfile

COPY --from=builder /app/out/full/ .
COPY turbo.json turbo.json

# Build the necessary dependencies for the specified app
RUN turbo run build --no-cache --filter=${APP}^...

# Final runner stage
FROM base AS runner
WORKDIR /app
ARG APP
ARG START_COMMAND=dev

COPY --from=installer /app .

CMD yarn workspace ${APP} ${START_COMMAND}
