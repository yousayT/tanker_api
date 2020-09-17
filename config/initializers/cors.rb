Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      # 許可するドメイン
      origins "http://localhost:8080", "https://vigorous-lamport-f0e2a6.netlify.app/"
      # 許可するヘッダーとメソッドの種類
      resource "*",
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['Per-Page', 'Total', 'Link'],
        credentials: true
    end
  end
