FROM docker/compose:latest

WORKDIR /app

COPY . /app

RUN docker-compose up
