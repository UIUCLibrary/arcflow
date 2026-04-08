# Dockerfile for ArcLight 1.6.2
# Based on https://github.com/projectblacklight/arclight/tree/v1.6.2
# Note: ArcLight v1.6.2 requires Ruby >= 3.0.0

# Stage 1: Get Node.js from official image (works on all platforms)
FROM node:18-slim AS node

# Stage 2: Build ArcLight application
FROM ruby:3.2-slim

LABEL maintainer="UIUC Library"
LABEL description="ArcLight v1.6.2 for local testing"

# Copy Node.js from the official image
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Verify Node.js installation
RUN node --version && npm --version

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        sqlite3 \
        libsqlite3-dev \
        libyaml-dev \
        pkg-config \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Install Rails 7.1
RUN gem install rails -v '~> 7.1.0'

# Create a new Rails app with ArcLight v1.6.2
RUN rails new . --skip-git --skip-bundle --database=sqlite3 && \
    echo "gem 'arclight', '~> 1.6.2'" >> Gemfile && \
    bundle install

# Generate ArcLight installation
RUN bundle exec rails generate blacklight:install --devise --skip-assets && \
    bundle exec rails generate arclight:install

# Install JavaScript dependencies  
RUN yarn install

# Setup database
RUN bundle exec rake db:migrate RAILS_ENV=development

# Note: Asset precompilation skipped in build - will happen at runtime
# This avoids needing sassc native extension compilation during build

# Expose port 3000
EXPOSE 3000

# Create tmp directory
RUN mkdir -p tmp/pids

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
