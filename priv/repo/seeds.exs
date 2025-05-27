# Limpar dados existentes
BatchEcommerce.Repo.delete_all(BatchEcommerce.Catalog.Product)
BatchEcommerce.Repo.delete_all(BatchEcommerce.Catalog.Category)
BatchEcommerce.Repo.delete_all(BatchEcommerce.Accounts.Company)
BatchEcommerce.Repo.delete_all(BatchEcommerce.Accounts.User)
# Insere User
users = [
  %{
    cpf: "12345678901",
    name: "João da Silva",
    email: "joao.silva@exemplo.com",
    phone_number: "11987654321",
    birth_date: ~D[1990-01-15],
    password: "Senha@123",
    addresses: [
      %{
        cep: "01311-000",
        uf: "SP",
        city: "São Paulo",
        district: "Bela Vista",
        address: "Avenida Paulista",
        complement: "Próximo ao MASP",
        home_number: "1000"
      }
    ]
  }
]

Enum.each(users, fn user ->
  %BatchEcommerce.Accounts.User{}
  |> BatchEcommerce.Accounts.User.insert_changeset(%{
    cpf: user.cpf,
    name: user.name,
    email: user.email,
    phone_number: user.phone_number,
    birth_date: user.birth_date,
    password: user.password,
    addresses: user.addresses
  })
  |> BatchEcommerce.Repo.insert!()
end)

# inserindo empresa

companies = [
  %{
    name: "Tech Solutions LTDA",
    cnpj: "98765432000121",
    email: "contato@techsolutions.com.br",
    phone_number: "11987654322",
    user_id: BatchEcommerce.Repo.get_by!(BatchEcommerce.Accounts.User, name: "João da Silva").id,
    addresses: [
      %{
        cep: "01311-000",
        uf: "SP",
        city: "São Paulo",
        district: "Bela Vista",
        address: "Avenida Paulista",
        complement: "Próximo ao MASP",
        home_number: "1000"
      }
    ]
  }
]

Enum.each(companies, fn company ->
  BatchEcommerce.Repo.insert!(%BatchEcommerce.Accounts.Company{
      name: company.name,
      cnpj: company.cnpj,
      email: company.email,
      phone_number: company.phone_number,
      user_id: company.user_id,
      addresses: company.addresses
    })
  end)

company = BatchEcommerce.Repo.get_by!(BatchEcommerce.Accounts.Company, name: "Tech Solutions LTDA")

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
# products = [
#   %{
#     name: "Smartphone Galaxy S21",
#     price: Decimal.new("3499.99"),
#     description: "Celular potente",
#     stock_quantity: 50,
#     company_id: company.id,
#     filename: "https://example.com/images/galaxy-s21.jpg"
#   },
#   %{
#     name: "Camiseta Básica",
#     price: Decimal.new("59.90"),
#     stock_quantity: 200,
#     description: "Camiseta grande",
#     company_id: company.id,
#     filename: "https://example.com/images/camiseta.jpg"
#   },
#   %{
#     name: "O Senhor dos Anéis",
#     price: Decimal.new("89.90"),
#     description: "Ótimo livro",
#     stock_quantity: 30,
#     company_id: company.id,
#     filename: "https://example.com/images/lotr.jpg"
#   },
#   %{
#     name: "Luminária de Mesa",
#     price: Decimal.new("129.90"),
#     description: "Luminária fluorescente",
#     stock_quantity: 45,
#     company_id: company.id,
#     filename: "https://example.com/images/luminaria.jpg"
#   },
#   %{
#     name: "Bola de Futebol",
#     price: Decimal.new("149.90"),
#     description: "Bola redonda",
#     stock_quantity: 100,
#     company_id: company.id,
#     filename: "https://example.com/images/bola.jpg"
#   },
#   %{
#     name: "LEGO Star Wars",
#     price: Decimal.new("499.90"),
#     description: "Jogo bom",
#     stock_quantity: 25,
#     company_id: company.id,
#     filename: "https://example.com/images/lego.jpg"
#   }
# ]

# Enum.each(products, fn product ->
#   BatchEcommerce.Repo.insert!(%BatchEcommerce.Catalog.Product{
#     name: product.name,
#     price: product.price,
#     stock_quantity: product.stock_quantity,
#     description: product.description,
#     company_id: product.company_id,
#     filename: product.filename
#   })
# end)

# # Relacionando produtos com categorias
# # Aqui vamos pegar as categorias e produtos já inseridos
# electronics = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Eletrônicos")
# clothing = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Vestuário")
# books = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Livros")
# home = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Casa e Decoração")
# sports = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Esportes")
# toys = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Category, type: "Brinquedos")

# smartphone =
#   BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Smartphone Galaxy S21")

# shirt = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Camiseta Básica")
# book = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "O Senhor dos Anéis")
# lamp = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Luminária de Mesa")
# ball = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "Bola de Futebol")
# lego = BatchEcommerce.Repo.get_by!(BatchEcommerce.Catalog.Product, name: "LEGO Star Wars")


# # Associando produtos às suas categorias
# BatchEcommerce.Repo.preload(smartphone, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [electronics])
# |> BatchEcommerce.Repo.update!()

# BatchEcommerce.Repo.preload(shirt, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [clothing])
# |> BatchEcommerce.Repo.update!()

# BatchEcommerce.Repo.preload(book, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [books])
# |> BatchEcommerce.Repo.update!()

# BatchEcommerce.Repo.preload(lamp, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [home])
# |> BatchEcommerce.Repo.update!()

# BatchEcommerce.Repo.preload(ball, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [sports])
# |> BatchEcommerce.Repo.update!()

# BatchEcommerce.Repo.preload(lego, :categories)
# |> BatchEcommerce.Catalog.Product.changeset(%{})
# |> Ecto.Changeset.put_assoc(:categories, [toys])
# |> BatchEcommerce.Repo.update!()
