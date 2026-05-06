FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./
RUN bundle lock && \
    bundle install --jobs 4 --retry 3

COPY . .

EXPOSE 3001

CMD ["bash", "-c", "bundle exec rails db:prepare && bundle exec rails db:seed && bundle exec puma -C config/puma.rb"]
