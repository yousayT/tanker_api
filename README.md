# TANKER

## アプリ概要
短歌共有webアプリです。
自分の作った短歌を投稿して皆に評価してもらったり、他人の短歌を閲覧したりできます

## 使用言語・開発環境
### サーバーサイド
ruby 2.6.3 

ruby on rails 6.0.3

### フロントエンド
vue.js  

url: https://github.com/Linpyj/tanker-front

## 機能一覧
### ユーザに関する機能
- ユーザ新規登録機能

  ユーザidとユーザ名、パスワードを登録してユーザの新規登録ができます。
- ログイン機能

  ユーザidとパスワードを用いてログインができます。
  
  （Google、Twitterでのログインは現在実装中です）
- プロフィール変更機能

  ユーザ名、プロフィール画像、自己紹介文、パスワードの変更ができます。
 
- フォロー機能

  ユーザのフォロー、フォロー解除ができます。
  
  またフォロワーや自分をフォローしている人の一覧を見ることもできます。

### 投稿に関する機能
- 短歌投稿機能

  「タイムライン」画面で短歌を投稿できます。
- 短歌のタグ付け機能

  短歌の投稿時にタグをプルダウンメニューから追加できます。
  
  （タグの表示は現在実装中です）
- 短歌削除機能

  自分の投稿した短歌を削除することができます。
- 「タイムライン」機能

  フォロワーとログインユーザ自身の投稿を一覧で見ることができます。
- 短歌の「like」機能

  好きな投稿に対して「like」をすることができます。

## 注力した点
### 画像アップロード
最も注力したのはユーザのプロフィール画像のアップロード機能です。base64形式で送られた画像ファイルをActionDispatchへと変換し、それをaws S3へと送信してフロントエンドへと反映するという一連の動作を作りあげました。

関連ファイル
- app/uploaders/user_image_uploader.rb
- app/controllers/concerns/carrierwave_base64_uploader.rb
- app/controllers/application_controller.rb
- app/controllers/api/users_controller.rbのupdateアクション
### サーバーサイドとフロントエンドの分離
サーバーサイドとフロントエンドを別々の言語で構築して接続するのにも注力しました。特にログイン時にセッションを保持する仕組みを作るのには長い時間を割きました。

関連ファイル
- config/initializers/cors.rb
- config/initializers/session_store.rb
- 各種コントローラファイルのアクション内のjsonによるレンダリング処理
### カウントデータの整合性の保持
各ユーザが持っているフォロー数とフォロワー数のカウントデータや、各投稿データが持つ「like」数のカウントデータが実際のデータと食い違うことのないように注意しました。

具体的には、createアクションやdestroyアクションにて、saveメソッドの成功を確認してからカウントの加減を行ったり、users_controller内のdestroyアクションにて、フォロー数や「like」数を再集計するようにしました。

関連ファイル
- app/controllers/api/follows_controller.rbのcreate、destroyアクション
- app/controllers/api/posts_controller.rbのlike、unlikeアクション
- app/controllers/api/users_controller.rbのdestroyアクション
## 環境構築手順
### Homebrewのインストール
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
### rbenvのインストール
      brew install rbenv ruby-build
### rubyのインストール
      rbenv install 2.6.3
      rbenv global 2.6.3
### リポジトリのクローン
      git clone https://github.com/yousayT/tanker_api.git
### bundle install
      bundle install
### マイグレーションを行う
      rails db:migrate
### テストデータをいれる
      rails db:seed
## デモ画面

## 注意点
### 動作環境について
chromeであれば問題なく動作します。safariの場合は環境設定から「プライバシー」の「サイト越えトラッキングを防ぐ」のチェックを外す必要があります。
### ログイン方法について
ログイン画面に「Googleログイン」や「Twitterログイン」のボタンがありますが、現在は動作しません。


