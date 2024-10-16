# Use a build argument for the Node.js version
ARG NODE_VERSION=18.18.0

# Stage 1: Base image setup with pnpm and turbo
FROM node:${NODE_VERSION}-alpine AS base
RUN apk add --no-cache libc6-compat
# Install pnpm and turbo globally
RUN npm install -g turbo
# Set up pnpm store for better caching during the build

# Stage 2: Prune workspace using pnpm
FROM base AS pruner
ARG PROJECT
WORKDIR /app

# Copy all files to the container
COPY . .

# Prune the workspace for the specific project (fe or web)
RUN turbo prune --scope=${PROJECT} --docker
RUN ls -la /app/out/full
# Stage 3: Install dependencies and build the project using pnpm
FROM base AS builder
ARG PROJECT
WORKDIR /app

# Copy the pruned lockfile and package.json from the pruned workspace
# Ensure npm lockfile is copied (replace pnpm-specific ones)
COPY --from=pruner /app/out/package-lock.json ./package-lock.json
COPY --from=pruner /app/out/package.json ./package.json

# Install dependencies with pnpm using the pruned lockfile
# Install dependencies using npm
RUN npm install
# Copy the pruned source code
COPY --from=pruner /app/out/full/ .

# Build the project using turbo and pnpm
RUN turbo build --filter=${PROJECT}
# Prune dev dependencies to minimize the final image
# RUN pnpm prune --prod --no-optional
# RUN rm -rf ./**/*/src

# Stage 4: Create the# Install dependencies using npm
RUN npm install final production image
FROM node:${NODE_VERSION}-alpine AS runner
WORKDIR /app
ARG PROJECTPATH

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs
USER nodejs

# Copy the built files from the builder stage
COPY --from=builder /app .

# Change to the app directory of the project being built (fe or web)
WORKDIR /app/apps/${PROJECTPATH}


# Set environment variables
ENV PORT=${PORT}
ENV NODE_ENV=production
EXPOSE ${PORT}

# Start the Next.js application
CMD ["npm", "run", "start"]
