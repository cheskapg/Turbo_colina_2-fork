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
RUN yarn global add turbo

# 2. Builder stage for both fe and web
FROM base AS builder

# Copy everything to the container
COPY . .

# Prune the monorepo to include what's needed for fe and web
RUN turbo prune --scope="@repo/fe" --scope="@repo/web" --docker
# Log the contents of the output directory
RUN ls -la /app/out/full
# 3. Installer stage for fe and web
FROM base AS installer

# Set the working directory
WORKDIR /app

# Copy the pruned output from the builder stage
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full
# Log the contents of the output directory again
RUN ls -la ./out/full
# Install dependencies for both apps
RUN yarn install --frozen-lockfile --cwd ./out/full

# Verify contents of fe directory
RUN ls -la ./out/full/apps/fe
RUN ls -la ./out/full/apps/fe


# Build both fe and web apps
RUN yarn install --frozen-lockfile --cwd ./out/full
# Copy the UI package and build it
COPY ./packages/ui ./packages/ui
WORKDIR ./packages/ui
RUN npm run build  # Builds the UI package, make sure this command works

# Add this in your Dockerfile for debugging purposes
RUN ls -la /app/out/full/packages/ui/dist

RUN yarn --cwd ./out/full/apps/fe build
RUN yarn --cwd ./out/full/apps/web build
# # Build both fe and web apps
# RUN yarn build --cwd ./out/full/apps/fe
# RUN yarn build --cwd ./out/full/apps/web

# 4. Runner stage for fe
FROM base AS fe_runner

# Set the working directory
WORKDIR /app

# Copy the built fe app from the installer stage
COPY --from=installer /app/out/full/apps/fe/.next/standalone ./
COPY --from=installer /app/out/full/apps/fe/.next/static ./apps/fe/.next/static
COPY --from=installer /app/out/full/apps/fe/public ./apps/fe/public

# Expose the port for fe
ENV PORT=3000
EXPOSE 3000

# Set the default command to run the fe app
CMD ["node", "apps/fe/server.js"]

# 5. Runner stage for web
FROM base AS web_runner

# Set the working directory
WORKDIR /app

# Copy the built web app from the installer stage
COPY --from=installer /app/out/full/apps/web/.next/standalone ./
COPY --from=installer /app/out/full/apps/web/.next/static ./apps/web/.next/static
COPY --from=installer /app/out/full/apps/web/public ./apps/web/public

# Expose the port for web
ENV PORT=4000
EXPOSE 4000

# Set the default command to run the web app
CMD ["node", "apps/web/server.js"]
