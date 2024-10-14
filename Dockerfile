
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

# Prune the monorepo to only include what's needed for the fe app
RUN turbo prune --scope="fe" --docker

# Prune the monorepo to only include what's needed for the web app
RUN turbo prune --scope="web" --docker

# 2. Install dependencies for fe and web (installer stage)
FROM node:16-alpine AS installer

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory
WORKDIR /app

# Install dependencies for fe app
COPY --from=builder /app/out/json/fe/package.json ./apps/fe/package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
RUN npm install --prefix ./apps/fe

# Install dependencies for web app
COPY --from=builder /app/out/json/web/package.json ./apps/web/package.json
RUN npm install --prefix ./apps/web

# 3. Build the fe and web apps
FROM node:16-alpine AS builder-fe-web

# Set the working directory
WORKDIR /app

# Copy the source code for fe app
COPY --from=builder /app/out/full/fe ./apps/fe

# Copy the source code for web app
COPY --from=builder /app/out/full/web ./apps/web

# Build fe app
RUN npm run build --prefix ./apps/fe

# Build web app
RUN npm run build --prefix ./apps/web

# 4. Final stage - Create a lightweight production image for both apps
FROM node:16-alpine AS runner

# Build arguments to specify the app to run
ARG APP

# Set the working directory
WORKDIR /app

# Copy the built app from the previous stages
COPY --from=builder-fe-web /app/apps/${APP} ./apps/${APP}

# Expose the port based on the app
EXPOSE 3000  # You can set this dynamically if needed, but typically you'll expose one port per service.

# Set the default command to run the specific app
CMD ["npm", "run", "start", "--prefix", "./apps/${APP}"]
