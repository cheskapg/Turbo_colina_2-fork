# 1. Base image for both fe and web
FROM node:18-alpine AS base

# Install necessary packages
RUN apk add --no-cache libc6-compat && \
    npm install -g yarn --force && \
    yarn global add turbo && \
    npm install -g tailwindcss

# 2. Builder stage for both fe and web
FROM base AS builder  

# Copy everything to the container
COPY . .

# Prune the monorepo to include what's needed for fe and web
RUN turbo prune --scope="@repo/fe" --scope="@repo/web" --docker

# Log the contents of the output directory


# 3. Installer stage for fe and web
FROM base AS installer

# Set the working directory
WORKDIR /app

# Copy the pruned output from the builder stage
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full

# Install dependencies
RUN yarn install

# Log the contents of the output directory again


# 4. Runner stage for fe
FROM base AS fe_runner

# Set the working directory
WORKDIR /app

# Copy the built fe app from the installer stage
COPY --from=installer /app/out/full/apps/fe/.next/standalone ./
COPY --from=installer /app/out/full/apps/fe/.next/static ./apps/fe/.next/static  
COPY --from=installer /app/out/full/apps/fe/public ./apps/fe/public
COPY --from=installer /app/out/full/apps/fe/next.config.js .
COPY --from=installer /app/out/full/apps/fe/package.json .  

# Expose the port for fe
ENV PORT=3000
EXPOSE 3000

# Set the default command to run the fe app
CMD ["npm", "run", "dev", "--prefix", "apps/fe"]

# 5. Runner stage for web
FROM base AS web_runner

# Set the working directory
WORKDIR /app

# Copy the built web app from the installer stage
COPY --from=installer /app/out/full/apps/web/.next/standalone ./
COPY --from=installer /app/out/full/apps/web/.next/static ./apps/web/.next/
COPY --from=installer /app/out/full/apps/web/public ./apps/web/public 
COPY --from=installer /app/out/full/apps/web/next.config.js . 
COPY --from=installer /app/out/full/apps/web/package.json . 

# Expose the port for web
ENV PORT=4000
EXPOSE 4000

# Set the default command to run the web app
CMD ["npm", "run", "dev", "--prefix", "apps/web"]
    