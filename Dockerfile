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

# Prune the monorepo to only include what's needed for the fe and web apps
RUN turbo prune --scope="@repo/fe" --docker
RUN turbo prune --scope="@repo/web" --docker

# 2. Install dependencies for fe and web (installer stage)
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
RUN npm install --global npm@9.8.1


# Install dependencies for fe app (including internal packages)
RUN npm install --prefix ./out/full/apps/fe || true

# Install dependencies for web app (including internal packages)
RUN npm install --prefix ./out/full/apps/web || true

# 3. Build the fe and web apps
FROM node:16-alpine AS builder-fe-web

# Set the working directory
WORKDIR /app

# Copy the source code for fe app
COPY --from=installer /app/out/full/apps/fe ./apps/fe

# Copy the source code for web app
COPY --from=installer /app/out/full/apps/web ./apps/web

# Build fe app
RUN npm run build --prefix ./apps/fe

# Build web app
RUN npm run build --prefix ./apps/web

# 4. Final stage - Create a lightweight production image for both apps
FROM node:16-alpine AS runner

# Build argument to specify the app to run
ARG APP

# Set the working directory
WORKDIR /app

# Copy the built app from the previous stages
COPY --from=builder-fe-web /app/apps/${APP} ./apps/${APP}

# Set environment variable for the port based on the app
# Assuming fe runs on 3000 and web runs on 4000
ENV PORT=3000
RUN if [ "${APP}" = "web" ]; then export PORT=4000; fi

# Expose the port
EXPOSE ${PORT}

# Set the default command to run the specific app
CMD ["sh", "-c", "npm run start --prefix ./apps/${APP} -- --port $PORT"]
