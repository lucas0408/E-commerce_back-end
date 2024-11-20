# Use uma imagem oficial do Elixir como base
FROM elixir:1.17-alpine AS build

# Instale dependências de build
RUN apk add --no-cache build-base npm git

# Configure o diretório de trabalho
WORKDIR /app

# Instale o hex e o rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copie os arquivos de configuração do projeto
COPY mix.exs mix.lock ./
COPY config config

# Instale as dependências do Mix
RUN mix deps.get --only dev
RUN mix deps.compile

# Copie o restante do código fonte
COPY priv priv
COPY lib lib

# Compile a aplicação
RUN mix compile
RUN mix release

# Estágio final para reduzir o tamanho da imagem
FROM elixir:1.17-alpine

# Instale dependências de runtime
RUN apk add --no-cache openssl ncurses-libs

# Configure o diretório de trabalho
WORKDIR /app

# Copie o build do estágio anterior
COPY --from=build /app/_build/dev/rel/batch_ecommerce ./

# Exponha a porta que sua aplicação usa
EXPOSE 4000

# Comando para iniciar a aplicação
CMD ["mix", "phx.server"]
