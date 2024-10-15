# Base image
ARG NODE_VERSION=18.18.0
FROM node:${NODE_VERSION}-alpine AS base

# Install necessary packages
RUN apk update && apk add --no-cache libc6-compat

# Set the working directory inside the container
WORKDIR /app

# Install dependencies globally (only if needed)
RUN npm install -g yarn tailwindcss turbo

# Builder stage for both fe and web
FROM base AS builder
COPY . .

# Install dependencies locally
RUN yarn install --frozen-lockfile

# Prune the monorepo to include what's needed for fe and web
RUN turbo prune --scope="@repo/fe" --scope="@repo/web" --docker

# Installer stage for both fe and web
FROM base AS installer
WORKDIR /app
COPY ./packages ./packages
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full

# Install dependencies for both apps
RUN yarn install --frozen-lockfile --cwd ./out/full

# Build both fe and web apps
RUN yarn build --cwd ./out/full/apps/fe
RUN yarn build --cwd ./out/full/apps/web

# Runner stage for fe
FROM base AS fe_runner
WORKDIR /app/out/full/apps/fe
COPY --from=installer /app/out/full/apps/fe ./
ENV PORT=3000
EXPOSE ${PORT}
CMD ["yarn", "next", "start"]

# Runner stage for web
FROM base AS web_runner
WORKDIR /app/out/full/apps/web
COPY --from=installer /app/out/full/apps/web ./
ENV PORT=4000
EXPOSE ${PORT}
CMD ["yarn", "next", "start"]
