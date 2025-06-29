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
        id: 1,  # Adicionei um ID para cada endereço para facilitar a manipulação
        cep: "01311-000",
        uf: "SP",
        city: "São Paulo",
        district: "Bela Vista",
        address: "Avenida Paulista",
        complement: "Próximo ao MASP",
        home_number: "1000"
      },
      %{
        id: 2,
        cep: "04538-132",
        uf: "SP",
        city: "São Paulo",
        district: "Itaim Bibi",
        address: "Rua Joaquim Floriano",
        complement: "Edifício Commercial",
        home_number: "100",
        apartment: "101"  # Adicionei campo extra como exemplo
      }
    ]
  },
  %{
    cpf: "12345674901",
    name: "Lucas da Silva",
    email: "lucas.silva@exemplo.com",
    phone_number: "11983654321",
    birth_date: ~D[1997-01-15],
    password: "Senha@123",
    addresses: [
      %{
        id: 1,  # Adicionei um ID para cada endereço para facilitar a manipulação
        cep: "01311-000",
        uf: "SP",
        city: "São Paulo",
        district: "Bela Vista",
        address: "Avenida Paulista",
        complement: "Próximo ao MASP",
        home_number: "1000"
      },
      %{
        id: 2,
        cep: "04538-132",
        uf: "SP",
        city: "São Paulo",
        district: "Itaim Bibi",
        address: "Rua Joaquim Floriano",
        complement: "Edifício Commercial",
        home_number: "100",
        apartment: "101"  # Adicionei campo extra como exemplo
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
categories = BatchEcommerce.Repo.all(BatchEcommerce.Catalog.Category)
category_ids = Enum.map(categories, & &1.id)

products = [
  %{
    name: "Smartphone Galaxy S21",
    price: Decimal.new("3499.99"),
    description: "Celular potente",
    stock_quantity: 50,
    sales_quantity: 15,
    company_id: company.id,
    filename: "https://example.com/images/galaxy-s21.jpg",
    discount: 12
  },
  %{
    name: "Camiseta Básica",
    price: Decimal.new("59.90"),
    stock_quantity: 200,
    description: "Camiseta grande",
    sales_quantity: 74,
    company_id: company.id,
    filename: "https://example.com/images/camiseta.jpg",
    discount: 0
  },
  %{
    name: "O Senhor dos Anéis",
    price: Decimal.new("89.90"),
    description: "Ótimo livro",
    stock_quantity: 30,
    sales_quantity: 5,
    company_id: company.id,
    filename: "https://example.com/images/lotr.jpg",
    discount: 8
  },
  %{
    name: "Luminária de Mesa",
    price: Decimal.new("129.90"),
    description: "Luminária fluorescente",
    stock_quantity: 45,
    sales_quantity: 12,
    company_id: company.id,
    filename: "https://example.com/images/luminaria.jpg",
    discount: 18
  },
  %{
    name: "Bola de Futebol",
    price: Decimal.new("149.90"),
    description: "Bola redonda",
    stock_quantity: 100,
    company_id: company.id,
    sales_quantity: 98,
    filename: "https://example.com/images/bola.jpg",
    discount: 35
  },
  %{
    name: "LEGO Star Wars",
    price: Decimal.new("499.90"),
    description: "Jogo bom",
    stock_quantity: 25,
    company_id: company.id,
    sales_quantity: 45,
    filename: "https://example.com/images/lego.jpg",
    discount: 22
  },
  %{
    name: "Notebook Dell Inspiron",
    price: Decimal.new("2799.99"),
    description: "Laptop para trabalho e estudos",
    stock_quantity: 35,
    sales_quantity: 28,
    company_id: company.id,
    filename: "https://example.com/images/notebook-dell.jpg",
    discount: 15
  },
  %{
    name: "Tênis Nike Air Max",
    price: Decimal.new("349.90"),
    description: "Tênis esportivo confortável",
    stock_quantity: 80,
    sales_quantity: 67,
    company_id: company.id,
    filename: "https://example.com/images/nike-air-max.jpg",
    discount: 25
  },
  %{
    name: "Cafeteira Elétrica",
    price: Decimal.new("199.90"),
    description: "Cafeteira automática 12 xícaras",
    stock_quantity: 40,
    sales_quantity: 31,
    company_id: company.id,
    filename: "https://example.com/images/cafeteira.jpg",
    discount: 10
  },
  %{
    name: "Fone de Ouvido Bluetooth",
    price: Decimal.new("179.90"),
    description: "Fone sem fio com cancelamento de ruído",
    stock_quantity: 65,
    sales_quantity: 52,
    company_id: company.id,
    filename: "https://example.com/images/fone-bluetooth.jpg",
    discount: 20
  },
  %{
    name: "Mochila Escolar",
    price: Decimal.new("89.90"),
    description: "Mochila resistente com vários compartimentos",
    stock_quantity: 120,
    sales_quantity: 85,
    company_id: company.id,
    filename: "https://example.com/images/mochila.jpg",
    discount: 5
  },
  %{
    name: "Panela de Pressão Elétrica",
    price: Decimal.new("249.90"),
    description: "Panela elétrica multifuncional 6L",
    stock_quantity: 30,
    sales_quantity: 22,
    company_id: company.id,
    filename: "https://example.com/images/panela-eletrica.jpg",
    discount: 30
  }
]

products_with_categories =
  Enum.map(products, fn product ->
    selected_categories = Enum.take_random(categories, Enum.random(1..3))

    Map.put(product, :categories, selected_categories)
  end)

Enum.each(products_with_categories, fn product ->
  %BatchEcommerce.Catalog.Product{}
  |> BatchEcommerce.Catalog.Product.changeset(%{
    name: product.name,
    price: product.price,
    stock_quantity: product.stock_quantity,
    description: product.description,
    company_id: product.company_id,
    discount: product.discount,
    sales_quantity: product.sales_quantity,
    filename: product.filename
  })
  |> Ecto.Changeset.put_assoc(:categories, product.categories)
  |> BatchEcommerce.Repo.insert!()
end)

products = BatchEcommerce.Repo.all(BatchEcommerce.Catalog.Product)

users = BatchEcommerce.Repo.all(BatchEcommerce.Accounts.User)

Enum.each(products, fn product ->

  number_of_reviews = Enum.random(5..20)

  Enum.each(users, fn user ->
    user_id = BatchEcommerce.Repo.get_by!(BatchEcommerce.Accounts.User, name: "João da Silva").id
    random_review = Enum.random(1..5)

    %BatchEcommerce.Catalog.ProductReview{}
    |> BatchEcommerce.Catalog.ProductReview.changeset(%{
      review: random_review,
      product_id: product.id,
      user_id: user.id
    })
    |> BatchEcommerce.Repo.insert!()
  end)
end)


# Buscar usuários e produtos existentes
users = BatchEcommerce.Repo.all(BatchEcommerce.Accounts.User)
products = BatchEcommerce.Repo.all(BatchEcommerce.Catalog.Product)

# Criar pedidos com diferentes status de pagamento
orders_data = [
  %{
    user_id: Enum.at(users, 0).id,  # João da Silva
    status_payment: "pendente",
    order_products: [
      %{product_id: Enum.at(products, 0).id, quantity: 1, status: "Preparando Pedido"},  # Smartphone Galaxy S21
      %{product_id: Enum.at(products, 6).id, quantity: 1, status: "Preparando Pedido"}   # Notebook Dell Inspiron
    ]
  },
  %{
    user_id: Enum.at(users, 1).id,  # Lucas da Silva
    status_payment: "confirmado",
    order_products: [
      %{product_id: Enum.at(products, 1).id, quantity: 3, status: "Enviado"},           # Camiseta Básica
      %{product_id: Enum.at(products, 7).id, quantity: 1, status: "Enviado"},           # Tênis Nike Air Max
      %{product_id: Enum.at(products, 10).id, quantity: 2, status: "Enviado"}           # Mochila Escolar
    ]
  },
  %{
    user_id: Enum.at(users, 0).id,  # João da Silva (segundo pedido)
    status_payment: "confirmado",
    order_products: [
      %{product_id: Enum.at(products, 2).id, quantity: 1, status: "Entregue"},          # O Senhor dos Anéis
      %{product_id: Enum.at(products, 8).id, quantity: 1, status: "Entregue"}           # Cafeteira Elétrica
    ]
  },
  %{
    user_id: Enum.at(users, 1).id,  # Lucas da Silva (segundo pedido)
    status_payment: "pendente",
    order_products: [
      %{product_id: Enum.at(products, 3).id, quantity: 2, status: "Preparando Pedido"}, # Luminária de Mesa
      %{product_id: Enum.at(products, 9).id, quantity: 1, status: "Preparando Pedido"}  # Fone de Ouvido Bluetooth
    ]
  },
  %{
    user_id: Enum.at(users, 0).id,  # João da Silva (terceiro pedido)
    status_payment: "confirmado",
    order_products: [
      %{product_id: Enum.at(products, 4).id, quantity: 1, status: "A Caminho"},         # Bola de Futebol
      %{product_id: Enum.at(products, 11).id, quantity: 1, status: "A Caminho"}         # Panela de Pressão Elétrica
    ]
  },
  %{
    user_id: Enum.at(users, 1).id,  # Lucas da Silva (terceiro pedido)
    status_payment: "confirmado",
    order_products: [
      %{product_id: Enum.at(products, 5).id, quantity: 1, status: "Enviado"}            # LEGO Star Wars
    ]
  }
]

# Criar os pedidos e produtos do pedido
Enum.each(orders_data, fn order_data ->
  # Calcular o preço total do pedido
  total_price =
    order_data.order_products
    |> Enum.reduce(Decimal.new("0"), fn order_product, acc ->
      product = Enum.find(products, &(&1.id == order_product.product_id))
      product_total = Decimal.mult(product.price, Decimal.new(order_product.quantity))
      Decimal.add(acc, product_total)
    end)

  # Criar o pedido
  {:ok, order} = BatchEcommerce.Repo.insert(%BatchEcommerce.Order.Order{
    user_id: order_data.user_id,
    total_price: total_price,
    status_payment: order_data.status_payment
  })

  # Criar os produtos do pedido
  Enum.each(order_data.order_products, fn order_product_data ->
    product = Enum.find(products, &(&1.id == order_product_data.product_id))

    BatchEcommerce.Repo.insert!(%BatchEcommerce.Order.OrderProduct{
      order_id: order.id,
      product_id: order_product_data.product_id,
      price: product.price,
      quantity: order_product_data.quantity,
      status: order_product_data.status
    })
  end)
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
