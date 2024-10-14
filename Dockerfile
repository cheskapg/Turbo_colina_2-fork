version: '3.8'

services:
  fe:
    build:
      context: .
      args:
        APP: fe  # Specify which app to build
    ports:
      - "3000:3000"  # Map host port 3000 to container port 3000

  web:
    build:
      context: .
      args:
        APP: web  # Specify which app to build
    ports:
      - "4000:4000"  # Map host port 4000 to container port 4000
