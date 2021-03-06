FROM ruby:2.5.3-slim
ENV PHANTOM_JS=2.1.1

# Add basic binaries
RUN apt-get update \
  && apt-get install -y bzip2 curl gnupg wget

# Add the apt repository for yarn
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Add the apt-repository for the latest node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get install build-essential chrpath libssl-dev libxft-dev -y && \
  apt-get install libfreetype6 libfreetype6-dev -y && \
  apt-get install libfontconfig1 libfontconfig1-dev -y && \
  cd ~ && \
  export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
  wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 && \
  tar xvjf $PHANTOM_JS.tar.bz2 && \
  mv $PHANTOM_JS /usr/local/share && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin && \
  apt-get install -y yarn

# Clean up the apt cache
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /refugerestrooms
WORKDIR /refugerestrooms

COPY Gemfile /refugerestrooms/Gemfile
COPY Gemfile.lock /refugerestrooms/Gemfile.lock
RUN bundle install

COPY package.json yarn.lock /refugerestrooms/
RUN yarn --pure-lockfile
