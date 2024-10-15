# 1. Base image for both fe and web
FROM node:18-alpine AS base
#twerka
# Install necessary packages
RUN apk add --no-cache libc6-compat
RUN apk update

# Set the working directory inside the container
WORKDIR /app

# Install yarn globally if it's not already installed
RUN if ! command -v yarn > /dev/null; then npm install -g yarn; fi

# Install turbo globally
RUN yarn global add turbo
# Install tailwindcss globally
RUN npm install -g tailwindcss
FROM base AS builder  
COPY . .
# 2. Builder stage for both fe and web

# Prune the monorepo to include what's needed for fe and web
RUN turbo prune --scope="@repo/fe" --scope="@repo/web" --docker
# Log the contents of the output directory
RUN ls -la /app/out/full

# 3. Installer stage for fe and web
FROM base AS installer
RUN apk add --no-cache libc6-compat
RUN apk update
WORKDIR /app

# Set the working directory
COPY ./packages ./packages

# Copy the pruned output from the builder stage
COPY .gitignore .gitignore
COPY --from=builder /app/out/json ./out/json
COPY --from=builder /app/out/full ./out/full
RUN yarn install
# Log the contents of the output directory again
RUN ls -la ./out/full
# Install dependencies for both apps
# RUN yarn install --frozen-lockfile --cwd ./out/full

# Verify contents of fe directory
RUN ls -la ./out/full/apps/fe
RUN ls -la ./out/full/apps/fe

COPY --from=builder /app/out/full/ .
COPY turbo.json turbo.json
RUN yarn turbo run build --filter=fe...
# Copy the UI package


RUN yarn turbo run build --filter=web...

# # RUN npm run build  
# WORKDIR /app/packages/ui
# # Build the UI package
# RUN npm run build  
# Build both fe and web apps
# RUN yarn --cwd ./out/full/apps/fe build
# RUN yarn --cwd ./out/full/apps/web build
# Copy the UI package and build it
# COPY ./packages/ui ./packages/ui
# WORKDIR ./packages/ui
# RUN npm run build  # Builds the UI package, make sure this command works


# RUN yarn --cwd ./out/full/apps/fe build
# RUN yarn --cwd ./out/full/apps/web build
# # Build both fe and web apps
# RUN yarn build --cwd ./out/full/apps/fe
# RUN yarn build --cwd ./out/full/apps/web

# 4. Runner stage for fe
FROM base AS fe_runner

# Set the working directory
WORKDIR /app

# Copy the built fe app from the installer stage
# COPY --from=installer /app/out/full/apps/fe/.next/standalone ./
# COPY --from=installer /app/out/full/apps/fe/.next/static ./apps/fe/.next/static
# COPY --from=installer /app/out/full/apps/fe/public ./apps/fe/public
COPY --from=installer /app/apps/fe/next.config.js .
COPY --from=installer /app/apps/fe/package.json ...
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
# COPY --from=installer /app/out/full/apps/web/.next/standalone ./
# COPY --from=installer /app/out/full/apps/web/.next/static ./apps/web/.next/static
# COPY --from=installer /app/out/full/apps/web/public ./apps/web/public
COPY --from=installer /app/apps/fe/next.config.js .
COPY --from=installer /app/apps/fe/package.json ...
# Expose the port for fe

# Expose the port for web
ENV PORT=4000
EXPOSE 4000

# Set the default command to run the web app
CMD ["npm", "run", "dev", "--prefix", "apps/web"]

