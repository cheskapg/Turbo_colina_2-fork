# # 1. Builder stage
# FROM node:16-alpine AS builder

# # Install necessary packages
# RUN apk add --no-cache libc6-compat
# RUN apk update

# # Set the working directory inside the container
# WORKDIR /app

# # Install turbo globally for workspace management
# RUN npm install -g turbo

# # Copy everything to the container
# COPY . .

# # Prune the monorepo to only include what's needed for the fe app
# RUN turbo prune --scope="@repo/fe" --docker && ls -R /app/out
# # Prune the monorepo to only include what's needed for the web app
# RUN turbo prune --scope="@repo/web" --docker && ls -R /app/out


# # RUN turbo prune --scope="@repo/fe,@repo/web" --docker && ls -R /app/out

# # 2. Install dependencies for fe and web (installer stage)
# FROM node:16-alpine AS installer

# # Install necessary packages
# RUN apk add --no-cache libc6-compat
# RUN apk update

# # Set the working directory
# WORKDIR /app

# # Install dependencies for fe app
# # Copy package.json and package-lock.json to the correct location
# # COPY --from=builder /app/out/json/apps/fe/package.json /app/out/json/apps/fe/
# # COPY --from=builder /app/package-lock.json /app/out/json/

# # RUN npm install --prefix /app/out/json/apps/fe

# # # Install dependencies for web app
# # COPY --from=builder /app/out/json/apps/web/package.json /app/out/json/apps/web/
# # RUN npm install --prefix /app/out/json/apps/web


# # Install dependencies for fe app
# # Copy package.json and package-lock.json to the correct location
# COPY --from=builder /app/out/full/apps/fe/package.json /app/out/full/apps/fe/
# COPY --from=builder /app/out/package-lock.json /app/out/full/

# RUN npm install --prefix /app/out/full/apps/fe || true
# # Install internal packages (using npm install with workspace support)
# # RUN npm install --workspace @repo/fe || true
# # Install dependencies for web app
# COPY --from=builder /app/out/full/apps/web/package.json /app/out/full/apps/web/
# RUN npm install --prefix /app/out/full/apps/web || true
# # RUN npm install --workspace @repo/web || true
# # 3. Build the fe and web apps
# FROM node:16-alpine AS builder-fe-web

# # Set the working directory
# WORKDIR /app

# # Copy the source code for fe app
# COPY --from=installer /app/apps/fe ./apps/fe

# # Copy the source code for web app
# COPY --from=installer /app/apps/web ./apps/web

# # Build fe app
# RUN npm run build --prefix ./apps/fe

# # Build web app
# RUN npm run build --prefix ./apps/web

# # 4. Final stage - Create a lightweight production image for both apps
# FROM node:16-alpine AS runner

# # Build argument to specify the app to run
# ARG APP

# # Set the working directory
# WORKDIR /app

# # Copy the built app from the previous stages
# COPY --from=builder-fe-web /app/apps/${APP} ./apps/${APP}

# # Set environment variable for the port based on the app
# # Assuming fe runs on 3000 and web runs on 4000
# ENV PORT=3000
# RUN if [ "${APP}" = "web" ]; then export PORT=4000; fi

# # Expose the port
# EXPOSE ${PORT}

# # Set the default command to run the specific app
# CMD ["sh", "-c", "npm run start --prefix ./apps/${APP} -- --port $PORT"]


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

# Install dependencies for fe app
RUN npm ci --prefix ./out/full/apps/fe || true

# Install dependencies for web app
RUN npm ci --prefix ./out/full/apps/web || true


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
