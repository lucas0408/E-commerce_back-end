#!/bin/sh
set -e

# Função para testar conexão com o Postgres
wait_for_postgres() {
  echo "Waiting for PostgreSQL to start..."
  while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
  do
    echo "Waiting for PostgreSQL..."
    sleep 2
  done
  echo "PostgreSQL is ready!"
}

if [ "${1}" = "mix" ]; then
  wait_for_postgres
  
  # Cria e migra o banco de dados
  mix ecto.create
  mix ecto.migrate
fi

exec "$@"
