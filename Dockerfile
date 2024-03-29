FROM ruby:2.7.2-alpine

RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                mysql-dev \
                                nodejs \
                                tzdata \
                                ruby-dev \
                                yarn \
                                python2 \
                                g++ \
                                make

RUN gem install bundler

WORKDIR /app

COPY .ruby-version ./
COPY Gemfile* ./

RUN bundle config set force_ruby_platform true
RUN bundle install

COPY . .

RUN bundle exec rails webpacker:install
RUN rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "bin/rails", "server", "-b", "0.0.0.0"]
