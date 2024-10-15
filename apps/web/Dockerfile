# 1. Builder stage
FROM node:16-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Install turbo globally for workspace management
RUN npm install -g turbo

# Copy the entire monorepo into the container
COPY . .

# Prune the monorepo to only include what's needed for the web app
RUN turbo prune --scope="@repo/web" --docker

# 2. Install dependencies for web
FROM node:16-alpine AS installer

WORKDIR /app

# Copy the pruned app code
COPY --from=builder /app/out/full/apps/web/package.json ./apps/web/
COPY --from=builder /app/out/full/package-lock.json ./apps/web/

RUN npm install --prefix ./apps/web

# 3. Build the web app
FROM node:16-alpine AS builder-web

WORKDIR /app

COPY --from=installer /app/apps/web ./apps/web
RUN npm run build --prefix ./apps/web

# 4. Runner stage
FROM node:16-alpine AS runner

WORKDIR /app

COPY --from=builder-web /app/apps/web ./apps/web

EXPOSE 4000

CMD ["npm", "run", "start", "--prefix", "./apps/web"]
