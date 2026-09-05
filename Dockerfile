FROM ruby:3.3.8

RUN gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock* ./

RUN bundle install

COPY . .

CMD ["bundle", "exec", "rackup", "-p", "3000", "-o", "0.0.0.0"]
