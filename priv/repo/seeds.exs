# Inserindo categorias
categories = [
  %{type: "Eletrônicos"},
  %{type: "Vestuário"},
  %{type: "Livros"},
  %{type: "Casa e Decoração"},
  %{type: "Esportes"},
  %{type: "Brinquedos"}
]

Enum.each(categories, fn category ->
  BatchEcommerce.Repo.insert!(%BatchEcommerce.Catalog.Category{
    type: category.type
  })
end)

# Inserindo produtos
products = [
  %{
    name: "Smartphone Galaxy S21",
    price: Decimal.new("3499.99"),
    description: "Celular potente",
    stock_quantity: 50,
    image_url: "https://example.com/images/galaxy-s21.jpg"
  },
  %{
    name: "Camiseta Básica",
    price: Decimal.new("59.90"),
    stock_quantity: 200,
    description: "Camiseta grande",
    image_url: "https://example.com/images/camiseta.jpg"
  },
  %{
    name: "O Senhor dos Anéis",
    price: Decimal.new("89.90"),
    description: "Ótimo livro",
    stock_quantity: 30,
    image_url: "https://example.com/images/lotr.jpg"
  },
  %{
    name: "Luminária de Mesa",
    price: Decimal.new("129.90"),
    description: "Luminária fluorescente",
    stock_quantity: 45,
    image_url: "https://example.com/images/luminaria.jpg"
  },
  %{
    name: "Bola de Futebol",
    price: Decimal.new("149.90"),
    description: "Bola redonda",
    stock_quantity: 100,
    image_url: "https://example.com/images/bola.jpg"
  },
  %{
    name: "LEGO Star Wars",
    price: Decimal.new("499.90"),
    description: "Jogo bom",
    stock_quantity: 25,
    image_url: "https://example.com/images/lego.jpg"
  }
]

Enum.each(products, fn product ->
  BatchEcommerce.Repo.insert!(%BatchEcommerce.Catalog.Product{
    name: product.name,
    price: product.price,
    stock_quantity: product.stock_quantity,
    description: product.description,
    image_url: product.image_url
  })
end)

# Relacionando produtos com categorias
# Aqui vamos pegar as categorias e produtos já inseridos
electronics = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Eletrônicos")
clothing = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Vestuário")
books = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Livros")
home = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Casa e Decoração")
sports = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Esportes")
toys = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Brinquedos")

smartphone =
  BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Smartphone Galaxy S21")

shirt = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Camiseta Básica")
book = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "O Senhor dos Anéis")
lamp = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Luminária de Mesa")
ball = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Bola de Futebol")
lego = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "LEGO Star Wars")

# Associando produtos às suas categorias
BatchEcommerce.Repo.preload(smartphone, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [electronics])
|> BatchEcommerce.Repo.update!()

BatchEcommerce.Repo.preload(shirt, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [clothing])
|> BatchEcommerce.Repo.update!()

BatchEcommerce.Repo.preload(book, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [books])
|> BatchEcommerce.Repo.update!()

BatchEcommerce.Repo.preload(lamp, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [home])
|> BatchEcommerce.Repo.update!()

BatchEcommerce.Repo.preload(ball, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [sports])
|> BatchEcommerce.Repo.update!()

BatchEcommerce.Repo.preload(lego, :categories)
|> BatchEcommerce.Catalog.Product.changeset(%{})
|> Ecto.Changeset.put_assoc(:categories, [toys])
|> BatchEcommerce.Repo.update!()
