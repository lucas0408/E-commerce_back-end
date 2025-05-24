#!/bin/sh
set -e

mix ecto.setup

if [ "$MIX_SEEDS" = "true" ]; then
  mix run priv/repo/seeds.exs
fi

exec mix phx.server