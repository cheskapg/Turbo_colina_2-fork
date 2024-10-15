# 1. Base image
FROM node:18-alpine AS base

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory inside the container
WORKDIR /app

# Install yarn globally
RUN npm install -g yarn

# Install turbo globally
RUN yarn global add turbo

# 2. Builder stage for web
FROM base AS builder

# Copy everything to the container
COPY . .

# Prune the monorepo to only include what's needed for the web app
RUN turbo prune --scope="@repo/web" --docker

# 3. Installer stage for web
FROM base AS installer

# Set the working directory
WORKDIR /app

# Copy the pruned output from the builder stage
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full

# Install dependencies for web app
RUN yarn install --frozen-lockfile

# Build the web app
RUN yarn build --cwd ./out/full/apps/web

# 4. Runner stage for web
FROM base AS runner

# Set the working directory
WORKDIR /app

# Copy the built app from the installer stage
COPY --from=installer /app/out/full/apps/web/.next/standalone ./
COPY --from=installer /app/out/full/apps/web/.next/static ./apps/web/.next/static
COPY --from=installer /app/out/full/apps/web/public ./apps/web/public

# Expose the port
ENV PORT=4000
EXPOSE 4000

# Set the default command to run the web app
CMD ["node", "apps/web/server.js"]
