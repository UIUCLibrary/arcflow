# Dockerfile for ArcLight 1.6.2
# Based on https://github.com/projectblacklight/arclight/tree/v1.6.2
# Note: ArcLight v1.6.2 requires Ruby >= 3.0.0

FROM ruby:3.0-slim

LABEL maintainer="UIUC Library"
LABEL description="ArcLight v1.6.2 for local testing"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        xz-utils \
        sqlite3 \
        libsqlite3-dev \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x LTS directly from nodejs.org
RUN curl -fsSL https://nodejs.org/dist/v18.20.2/node-v18.20.2-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz && \
    node --version && \
    npm --version

# Install yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Install Rails 7.1
RUN gem install rails -v '~> 7.1.0'

# Create a new Rails app with ArcLight v1.6.2
RUN rails new . --skip-git --skip-bundle --database=sqlite3 && \
    echo "gem 'arclight', '~> 1.6.2'" >> Gemfile && \
    echo "gem 'rsolr', '~> 2.0'" >> Gemfile && \
    bundle install

# Generate ArcLight installation
RUN bundle exec rails generate blacklight:install --devise --skip-assets && \
    bundle exec rails generate arclight:install

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
