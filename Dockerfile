FROM ruby:2.5

WORKDIR /usr/local/src/
ADD . /usr/local/src/
RUN gem install bundler
RUN bundle install

CMD bundle exec rspec -cfd spec/*
