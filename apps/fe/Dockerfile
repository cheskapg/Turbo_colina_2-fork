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

# 2. Builder stage for fe
FROM base AS builder

# Copy everything to the container
COPY . .

# Prune the monorepo to only include what's needed for the fe app
RUN turbo prune --scope="@repo/fe" --docker

# 3. Installer stage for fe
FROM base AS installer

# Set the working directory
WORKDIR /app

# Copy the pruned output from the builder stage
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full

# Install dependencies for fe app
RUN yarn install --frozen-lockfile

# Build the fe app
RUN yarn build --cwd ./out/full/apps/fe

# 4. Runner stage for fe
FROM base AS runner

# Set the working directory
WORKDIR /app

# Copy the built app from the installer stage
COPY --from=installer /app/out/full/apps/fe/.next/standalone ./
COPY --from=installer /app/out/full/apps/fe/.next/static ./apps/fe/.next/static
COPY --from=installer /app/out/full/apps/fe/public ./apps/fe/public

# Expose the port
ENV PORT=3000
EXPOSE 3000

# Set the default command to run the fe app
CMD ["node", "apps/fe/server.js"]
