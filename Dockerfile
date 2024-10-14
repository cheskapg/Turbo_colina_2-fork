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
RUN turbo prune --scope="@repo/fe" --docker

# 2. Install dependencies for fe (installer stage)
FROM node:16-alpine AS installer

# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory
WORKDIR /app

# Install dependencies for fe app
COPY --from=builder /app/out/json/@repo/fe/package.json ./apps/@repo/fe/package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
RUN npm install --prefix ./apps/@repo/fe

# 3. Build the fe app
FROM node:16-alpine AS builder-fe
WORKDIR /app

# Copy the source code for fe app
COPY --from=builder /app/out/full/@repo/fe ./apps/@repo/fe

# Build fe app
RUN npm run build --prefix ./apps/@repo/fe

# 4. Final stage - Create a lightweight production image for the app
FROM node:16-alpine AS runner

# Build arguments to specify the app to run
ARG APP
# Set the working directory
WORKDIR /app

# Copy the built app from the previous stages
COPY --from=builder-fe /app/apps/@repo/${APP} ./apps/@repo/${APP}

# Expose the port based on the app
EXPOSE 3000  # You can set this dynamically if needed, expose one port per service.

# Set the default command to run the specific app
CMD ["npm", "run", "start", "--prefix", "./apps/@repo/${APP}"]
