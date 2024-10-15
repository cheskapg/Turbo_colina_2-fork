# 1. Builder stage
FROM node:16-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Install turbo globally for workspace management
RUN npm install -g turbo

# Copy the entire monorepo into the container
COPY . .

# Prune the monorepo to only include what's needed for the fe app
RUN turbo prune --scope="@repo/fe" --docker

# 2. Install dependencies for fe
FROM node:16-alpine AS installer

WORKDIR /app

# Copy the pruned app code
COPY --from=builder /app/out/full/apps/fe/package.json ./apps/fe/
COPY --from=builder /app/out/full/package-lock.json ./apps/fe/

RUN npm install --prefix ./apps/fe

# 3. Build the fe app
FROM node:16-alpine AS builder-fe

WORKDIR /app

COPY --from=installer /app/apps/fe ./apps/fe
RUN npm run build --prefix ./apps/fe

# 4. Runner stage
FROM node:16-alpine AS runner

WORKDIR /app

COPY --from=builder-fe /app/apps/fe ./apps/fe

EXPOSE 3000

CMD ["npm", "run", "start", "--prefix", "./apps/fe"]
