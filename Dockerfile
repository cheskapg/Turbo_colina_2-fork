# 1. Builder stage
FROM node:16-alpine AS builder

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory inside the container
WORKDIR /app

# Install turbo globally for workspace management
RUN npm install -g turbo

# Copy everything to the container
COPY . .

# Prune the monorepo to only include what's needed for the fe and api apps
RUN turbo prune --scope="@repo/fe" --docker
RUN turbo prune --scope="@repo/api" --docker

# 2. Install dependencies for fe and api (installer stage)
FROM node:16-alpine AS installer

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory
WORKDIR /app

# Copy the pruned output to the installer stage
COPY --from=builder /app/out/full ./out/full
COPY --from=builder /app/out/json ./out/json

# Copy the internal packages
COPY packages ./packages

# Install dependencies for fe app (including internal packages)
RUN npm install --prefix ./out/full/apps/fe || true

# Install dependencies for api app (including internal packages)
RUN npm install --prefix ./out/full/apps/api || true

# 3. Build the fe and api apps
FROM node:16-alpine AS builder-fe-api

# Set the working directory
WORKDIR /app

# Copy the source code for fe app
COPY --from=installer /app/out/full/apps/fe ./apps/fe

# Copy the source code for api app
COPY --from=installer /app/out/full/apps/api ./apps/api

# Build fe app
RUN npm run build --prefix ./apps/fe

# Build api app
RUN npm run build --prefix ./apps/api

# 4. Final stage - Create a lightweight production image for both apps
FROM node:16-alpine AS runner

# Build argument to specify the app to run
ARG APP

# Set the working directory
WORKDIR /app

# Copy the built app from the previous stages
COPY --from=builder-fe-api /app/apps/${APP} ./apps/${APP}

# Set environment variable for the port based on the app
# Assuming fe runs on 3000 and api runs on 3001
ENV PORT=3000
RUN if [ "${APP}" = "api" ]; then export PORT=3001; fi

# Expose the port
EXPOSE ${PORT}

# Set the default command to run the specific app
CMD ["sh", "-c", "npm run start --prefix ./apps/${APP} -- --port $PORT"]
