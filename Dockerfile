# Dockerfile
FROM elixir:1.17-alpine

ARG PHOENIX_VERSION=1.7.14
ARG MIX_ENV=dev

ENV MIX_ENV=${MIX_ENV}
ENV ERL_AFLAGS="-kernel shell_history enabled"
ENV LANG=C.UTF-8

# Instalação de dependências do sistema
RUN apk add --no-cache \
    git \
    postgresql-client \
    build-base \
    inotify-tools \
    && rm -rf /var/cache/apk/*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new ${PHOENIX_VERSION} --force

# Copia os arquivos de dependências
COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get && \
    mix deps.compile

# Copia o restante do código fonte
COPY lib lib
COPY priv priv

# Script para aguardar o Postgres e iniciar o Phoenix
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 4000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mix", "phx.server"]
