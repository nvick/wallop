FROM ruby:2.7.2

LABEL maintainer="Nate Vick <nate@vick.codes>"

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# Base Software Install
###############################################################################

RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg \
    locales \
    git \
    netcat \
    vim \
    sudo

###############################################################################
# Non-root user
###############################################################################

# TODO remove UID GID defaults
ARG UID
ENV UID $UID
ARG GID
ENV GID $GID
ARG USER=ruby
ENV USER $USER

RUN groupadd -g $GID $USER && \
    useradd -u $UID -g $USER -m $USER && \
    usermod -p "*" $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/50-$USER

###############################################################################
# Ruby, Rubygems, and Bundler Defaults
###############################################################################

ENV LANG C.UTF-8

# Update Rubygems to latest
RUN gem update --system

# Increase how many threads Bundler uses when installing. Optional!
ENV BUNDLE_JOBS 20

# How many times Bundler will retry a gem download. Optional!
ENV BUNDLE_RETRY 5

# Where Rubygems will look for gems.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH ${GEM_HOME}/bin:${GEM_HOME}/gems/bin:$PATH

RUN unset BUNDLE_PATH && unset BUNDLE_BIN

###############################################################################
# Final Touches
###############################################################################

RUN mkdir -p "$GEM_HOME" && chown $USER:$USER "$GEM_HOME"
RUN mkdir -p /app && chown $USER:$USER /app

WORKDIR /app

USER $USER

# Install latest bundler
RUN gem install bundler