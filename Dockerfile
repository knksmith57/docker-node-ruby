FROM buildpack-deps
MAINTAINER Kyle Smith <kbsmith@rmn.com>

RUN  apt-get update -y \
  && apt-get install --no-install-recommends -y -q curl python build-essential git ca-certificates procps autoconf bison ruby \
  && rm -rf /var/lib/apt/lists/*

################################# Node Install #################################
ENV NODE_VERSION 0.10.33
ENV NPM_VERSION 2.1.10

ENV PATH $PATH:/nodejs/bin

RUN  mkdir /nodejs \
  && curl "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    | tar xvzf - -C /nodejs --strip-components=1 \
  && npm install --global npm@"$NPM_VERSION" \
  && npm cache clear


################################# Ruby Install #################################
ENV RUBY_MAJOR 2.0
ENV RUBY_VERSION 2.0.0-p598

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN  mkdir -p /usr/src/ruby \
  && curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    | tar -xjC /usr/src/ruby --strip-components=1 \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
# && apt-get purge -y --auto-remove bison ruby \
  && make install \
  && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

RUN  gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD []
ENTRYPOINT ["/bin/bash"]
