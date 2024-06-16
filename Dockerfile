# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /app

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libvips node-gyp pkg-config python-is-python3

# Install JavaScript dependencies
ARG NODE_VERSION=22.2.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install dev gems
RUN gem install solargraph

# Install application gems
COPY ./app/Gemfile ./app/Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY ./app/package.json ./app/yarn.lock ./
RUN yarn install --frozen-lockfile


FROM ubuntu:22.04 as installer
ARG DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get upgrade -y && \
    apt-get --no-install-recommends install -y \
        perl-modules \
        liburi-encode-perl \
        gnupg \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /install

COPY lualatex/texlive.profile .

RUN wget --no-check-certificate http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar -xzf install-tl-unx.tar.gz --strip-components=1 && \
    ./install-tl -profile texlive.profile

# Final stage for app image
FROM base
ARG DEBIAN_FRONTEND=noninteractive

COPY --from=installer /usr/local/texlive /usr/local/texlive

RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

RUN apt-get update && apt-get upgrade -y && \
    apt-get --no-install-recommends install -y \
        perl-modules \
        liburi-encode-perl \
        gnupg \
        wget \
        lmodern\
        # ttf-mscorefonts-installer 
        fontconfig \
        fonts-liberation \
        curl zip\
        libsqlite3-0 \
        libvips \
        sqlite3\
        build-essential &&\
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG NODE_VERSION=22.2.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

COPY lualatex/fonts/* /usr/share/fonts/

ENV HOME=/tmp PATH="/usr/local/texlive/bin/x86_64-linux:$PATH"

RUN mkdir /tex_test
COPY lualatex/main.tex /tex_test/

RUN tlmgr install \
        collection-latex \
        collection-luatex \
        collection-fontsrecommended fontspec polyglossia && \
    rm -rf /usr/local/texlive/texmf-var/*

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

ENTRYPOINT ["/app/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
