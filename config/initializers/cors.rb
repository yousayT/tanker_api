# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 許可するドメイン
    origins 'https://vigorous-lamport-f0e2a6.netlify.app', 'localhost:8080'
    # 許可するヘッダーとメソッドの種類
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[Per-Page Total Link],
             credentials: true
  end
end
