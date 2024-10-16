# Use a build argument for the Node.js version
ARG NODE_VERSION=18.18.0

# Stage 1: Base image setup with pnpm and turbo
FROM node:${NODE_VERSION}-alpine AS base
RUN apk add --no-cache libc6-compat
# Install pnpm and turbo globally
RUN npm install -g pnpm turbo
# Set up pnpm store for better caching during the build
RUN pnpm config set store-dir ~/.pnpm-store

# Stage 2: Prune workspace using pnpm
FROM base AS pruner
ARG PROJECT
WORKDIR /app

# Copy all files to the container
COPY . .

# Prune the workspace for the specific project (fe or web)
RUN turbo prune --scope=${PROJECT} --docker

# Stage 3: Install dependencies and build the project using pnpm
FROM base AS builder
ARG PROJECT
WORKDIR /app

# Copy the pruned lockfile and package.json from the pruned workspace
COPY --from=pruner /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=pruner /app/out/package.json ./package.json
COPY --from=pruner /app/out/pnpm-workspace.yaml ./pnpm-workspace.yaml

# Install dependencies with pnpm using the pruned lockfile
RUN --mount=type=cache,id=pnpm,target=~/.pnpm-store pnpm install --frozen-lockfile

# Copy the pruned source code
COPY --from=pruner /app/out/full/ .

# Build the project using turbo and pnpm
RUN turbo build --filter=${PROJECT}
# Prune dev dependencies to minimize the final image
RUN pnpm prune --prod --no-optional
RUN rm -rf ./**/*/src

# Stage 4: Create the final production image
FROM node:${NODE_VERSION}-alpine AS runner
ARG PROJECT
WORKDIR /app

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs
USER nodejs

# Copy the built files from the builder stage
COPY --from=builder /app .

# Change to the app directory of the project being built (fe or web)
WORKDIR /app/apps/${PROJECT}


# Set environment variables
ENV PORT=${PORT}
ENV NODE_ENV=production
EXPOSE ${PORT}

# Start the Next.js application
CMD ["npm", "run", "start"]
