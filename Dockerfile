# Extend from the official Elixir image.
# TODO: Set an Alpine version to reduce the image size
FROM elixir:latest

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
WORKDIR /app


# Download app dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force
RUN mix deps.get

# Copy the rest of the files
COPY . .

# Compile the project.
RUN mix compile

# Compile assets.
RUN mix assets.deploy

