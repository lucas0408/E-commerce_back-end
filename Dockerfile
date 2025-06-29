FROM elixir:1.18-alpine

RUN apk add --no-cache build-base npm git curl bash postgresql-client

WORKDIR /app

ENV MIX_ENV=dev

# Instala ferramentas do Elixir
RUN mix local.hex --force && \
    mix local.rebar --force

# Copia arquivos que afetam deps primeiro (para cache mais eficiente)
COPY mix.exs mix.lock ./

# Copia o config pra conseguir compilar algumas deps que precisam
COPY config config

# ⚠️ Roda o deps.get ANTES de copiar todo o projeto
RUN mix deps.get

# Agora copia o resto da aplicação
COPY . .

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Instala deps de JS (assets)
RUN cd assets && npm install

# ⚠️ Pode compilar, agora que tudo foi copiado
RUN mix compile

ENTRYPOINT ["entrypoint.sh"]

