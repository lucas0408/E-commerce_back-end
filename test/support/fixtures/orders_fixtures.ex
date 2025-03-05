defmodule BatchEcommerce.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BatchEcommerce.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(conn) do
    {:ok, order} = BatchEcommerce.Orders.complete_order(conn)

    order
  end

  # def line_item_fixture(attrs \\ %{}) do
  #   {:ok, line_item} =
  #     attrs
  #     |> Enum.into(%{
  #       price: "120.5",
  #       quantity: 42
  #     })
  #     |> BatchEcommerce.Orders.create_line_item()

  #   line_item
  # end
end
