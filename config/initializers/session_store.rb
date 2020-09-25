# Rails.application.config.api_only = false
if Rails.env.production?
  # # 本番環境ではredisをsessionの保持に使う
  # Rails.application.config.session_store :redis_store,{
  #   servers: [ENV['REDIS_URL'] + "/0/session"],
  #   expire_after: 1.week
  # }

  Rails.application.config.session_store :cookie_store, expire_after: 1.week, secure: Rails.env.production?, same_site: 'None'

else
  # それ以外の環境ではcookieを使う
  Rails.application.config.session_store :cookie_store, expire_after: 1.week
end
