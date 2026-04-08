# Dockerfile for ArcLight 1.6.2
# Based on https://github.com/projectblacklight/arclight/tree/v1.6.2

FROM ruby:2.7-slim

LABEL maintainer="UIUC Library"
LABEL description="ArcLight v1.6.2 for local testing"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        nodejs \
        npm \
        sqlite3 \
        libsqlite3-dev \
        curl \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Clone ArcLight v1.6.2
RUN git clone --branch v1.6.2 --depth 1 https://github.com/projectblacklight/arclight.git . && \
    rm -rf .git

# Install Ruby dependencies
RUN bundle install

# Install JavaScript dependencies  
RUN yarn install

# Setup database
RUN bundle exec rake db:migrate RAILS_ENV=development

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=development

# Expose port 3000
EXPOSE 3000

# Create tmp directory
RUN mkdir -p tmp/pids

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
