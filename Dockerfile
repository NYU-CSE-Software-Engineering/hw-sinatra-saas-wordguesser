# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.8
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Set a standard absolute working directory
WORKDIR /app

# Set Rack/Sinatra to production environment
ENV RACK_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install standard packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Final stage for app image
FROM base

# Install runtime dependencies (add libsqlite3-0 here if using an SQLite database)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Run and own only the runtime files as a non-root user for security
RUN useradd sinatra --create-home --shell /bin/bash && \
    chown -R sinatra:sinatra /app
USER sinatra:sinatra

# Start the server by default, binding to 0.0.0.0 so Docker can map the port
EXPOSE 3000
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "3000"]
