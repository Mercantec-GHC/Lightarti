FROM ruby:3.3.2

WORKDIR /rails

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  pkg-config \
  git \
  curl \
  libxml2-dev \
  libxslt1-dev

COPY Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform true
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]