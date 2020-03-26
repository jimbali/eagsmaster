FROM ruby:2.7.0-alpine

RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                mysql-dev \
                                nodejs \
                                tzdata \
                                ruby-dev \
                                yarn

RUN gem install bundler

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

RUN yarn install --check-files

EXPOSE 3000

CMD ["bundle", "exec", "bin/rails", "server", "-b", "0.0.0.0"]
