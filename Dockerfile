# 1. Base image for both fe and web
FROM node:18-alpine AS base

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory inside the container
WORKDIR /app

# Install yarn globally if it's not already installed
RUN if ! command -v yarn > /dev/null; then npm install -g yarn; fi


# Install turbo globally
# Install turbo and tailwind globally
RUN npm install -g turbo tailwindcss
# 2. Builder stage for both fe and web
FROM base AS builder

# Copy everything to the container
COPY . .

# Prune the monorepo to include what's needed for fe and web
RUN turbo prune --scope="@repo/fe" --scope="@repo/web" --docker
RUN ls -la 

# COPY yarn.lock ./out/full/yarn.lock

# Log the contents of the output directory
RUN ls -la /app/out/full

# Install dependencies based on pruned output
# COPY yarn.lock ./out/full/yarn.lock
COPY package-lock.json ./out/full/package-lock.json
RUN npm install --production --prefix ./out/full


# 3. Installer stage for fe and web
FROM base AS installer

# Set the working directory
WORKDIR /app

# Copy the pruned output from the builder stage
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full

# Log the contents of the output directory again
RUN ls -la ./out/full

# Build the UI package
WORKDIR /app/packages/ui
RUN npm run build

# Build both fe and web apps
# RUN yarn --cwd ./out/full/apps/fe build
# RUN yarn --cwd ./out/full/apps/web build
RUN npm run --prefix ./out/full/apps/fe build
RUN npm run --prefix ./out/full/apps/web build

# 4. Runner stage for fe
FROM base AS fe_runner

# Set the working directory
WORKDIR /app

# Copy the built fe app from the installer stage
COPY --from=installer /app/out/full/apps/fe ./apps/fe

# Verify contents of fe directory
RUN ls -la ./apps/fe

# Expose the port for fe
ENV PORT=3000
EXPOSE 3000
WORKDIR /app/apps/fe

# Production start (change if running in dev)
CMD npm run start 

# 5. Runner stage for web
FROM base AS web_runner

# Set the working directory
WORKDIR /app

# Copy the built web app from the installer stage
COPY --from=installer /app/out/full/apps/web ./apps/web

# Verify contents of web directory
RUN ls -la ./apps/web

# Expose the port for web
ENV PORT=4000
EXPOSE 4000
WORKDIR /app/apps/web

# Production start (change if running in dev)
CMD npm run start
