defmodule BatchEcommerceWeb.Live.AboutLive do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = if user_id, do: Accounts.get_user(user_id), else: nil

    {:ok,
      socket
      |> assign(
        page_title: "Sobre",
        user: user
      )
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault}
      user={@user}
      id="HeaderDefault"
    />

    <div class="max-w-4xl mx-auto px-6 py-12 text-gray-200">
      <h1 class="text-3xl font-bold text-indigo-400 mb-6">Sobre o Warejeira</h1>

      <p class="mb-4 text-justify leading-relaxed">
        O comércio eletrônico tem se tornado cada vez mais presente na vida dos consumidores, impulsionado pela conveniência, variedade de produtos e facilidade de acesso. Shopee, Mercado Livre e Amazon são as três maiores plataformas de E-commerce do país (<span class="italic">Conversion, 2025</span>), obtendo milhões de acessos diariamente. Cada uma dessas plataformas oferece recursos e diferenciais que atendem a diferentes perfis de usuários.
      </p>

      <p class="mb-4 text-justify leading-relaxed">
        Diante desse cenário, é essencial compreender quais aspectos tornam essas plataformas bem-sucedidas. Este trabalho teve como objetivo o desenvolvimento de uma plataforma de E-commerce que reúna os melhores aspectos das principais empresas do setor, proporcionando uma experiência de compra e venda otimizada.
      </p>

      <p class="mb-4 text-justify leading-relaxed">
        Em vez de buscar inovação radical, o foco do projeto foi na integração de funcionalidades já consolidadas, garantindo um sistema escalável, confiável e intuitivo para os consumidores.
      </p>

      <p class="mb-4 text-justify leading-relaxed">
        Para isso, foram analisados os principais elementos que tornam essas plataformas bem-sucedidas — desde sistemas de busca avançada até ampla personalização de anúncios dos produtos. Além disso, serão descritos os diferentes métodos e tecnologias utilizadas na produção do projeto.
      </p>

      <p class="text-justify leading-relaxed">
        Com base nessas análises, o projeto visa construir um E-commerce que combine essas características em um só lugar, oferecendo ao usuário uma experiência prática e satisfatória.
      </p>
    </div>
    """
  end
end
