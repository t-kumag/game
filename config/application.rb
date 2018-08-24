require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Osdr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # 追加
    config.i18n.default_locale = :ja
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local #DBのタイムゾーンを変更
    config.paths.add "lib", eager_load: true

    # config.after_initialize
    # Railsによるアプリの初期化が完了した 直後 に実行されます。
    # アプリの初期化作業には、フレームワーク自体の初期化、エンジンの初期化、そしてconfig/initializersに記述されたすべてのアプリイニシャライザの実行が含まれます。他のイニシャライザによって設定される値を設定するのに便利です。
    # config.after_initialize do
    #   ActionView::Base.sanitized_allowed_tags.delete "div"
    # end

    # config.asset_host
    # アセットを置くホストを設定します。この設定は、アセットの置き場所がCDN (Contents Delivery Network) の場合や、別のドメインエイリアスを使用するとブラウザの同時実行制限にひっかかるのを避けたい場合に便利です。

    # config.cache_classes
    # アプリのクラスやモジュールをリクエストごとに再読み込みするか(=キャッシュしないかどうか)どうかを指定します。config.cache_classesのデフォルト値は、developmentモードではfalseなのでコードの更新がすぐ反映され、testモードとproductionモードではtrueなので動作が高速になります。同時にthreadsafe!をオンにすることもできます。

    # config.action_view.cache_template_loading
    # リクエストのたびにビューテンプレートを再読み込みするか(=キャッシュしないか)を指定します。config.action_view.cache_template_loadingのデフォルト値はconfig.cache_classesがtrueならtrue、falseならfalseとして設定されます。

    # config.beginning_of_weekは、アプリにおける週の初日を設定します。引数には、曜日を表す正しいシンボルを渡します(:mondayなど)。

    # config.cache_store
    # Railsでのキャッシュ処理に使用されるキャッシュストアを設定します。指定できるオプションは次のシンボル:memory_store、:file_store、:mem_cache_store、:null_storeのいずれか、またはキャッシュAPIを実装するオブジェクトです。tmp/cacheディレクトリが存在する場合のデフォルトは:file_storeに設定され、それ以外の場合のデフォルトは:memory_storeに設定されます。

    # config.colorize_loggingは、出力するログ情報にANSI色情報を与えるかどうかを指定します。デフォルトはtrueです。

    # config.consider_all_requests_localはフラグです。このフラグがtrueの場合、どのような種類のエラーが発生した場合にも詳細なデバッグ情報がHTTPレスポンスに出力され、アプリの実行時コンテキストがRails::Infoコントローラによって/rails/info/propertiesに出力されます。このフラグはdevelopmentモードとtestモードではtrue、productionモードではfalseに設定されます。もっと細かく制御したい場合は、このフラグをfalseに設定してから、コントローラでlocal_request?メソッドを実装し、エラー時にどのデバッグ情報を出力するかをそこで指定してください。

    # config.eager_loadをtrueにすると、config.eager_load_namespacesに登録された事前一括読み込み(eager loading)用の名前空間をすべて読み込みます。ここにはアプリ、エンジン、Railsフレームワークを含むあらゆる登録済み名前空間が含まれます。

    # config.encodingはアプリ全体のエンコーディングを指定します。デフォルトはUTF-8です。

    # config.debug_exception_response_formatは、developmentモードで発生したエラーのレスポンスで用いられるフォーマットを設定します。通常のアプリの場合は:defaultが、APIのみの場合は:apiがデフォルトで設定されます。

    # config.file_watcherは、config.reload_classes_only_on_changeがtrueの場合にファイルシステム上のファイル更新検出に使用されるクラスを指定します。デフォルトのRailsではActiveSupport::FileUpdateChecker、およびActiveSupport::EventedFileUpdateChecker（これはlistenに依存します）が指定されます。カスタムクラスはこのActiveSupport::FileUpdateChecker APIに従わなければなりません。

    # config.filter_parametersは、パスワードやクレジットカード番号など、ログに出力したくないパラメータをフィルタで除外するのに用います。デフォルトのRailsではconfig/initializers/filter_parameter_logging.rbにRails.application.config.filter_parameters += [:password]を追加することでパスワードをフィルタで除外します。パラメータのフィルタは正規表現の部分一致によって行われます。

    # config.force_sslは、ActionDispatch::SSLミドルウェアを使用して、すべてのリクエストをHTTPSプロトコル下で実行するよう強制し、かつconfig.action_mailer.default_url_optionsを{ protocol: 'https' }に設定します。詳しくはActionDispatch::SSL documentationを参照してください。

    # config.log_formatterはRailsロガーのフォーマットを定義します。このオプションは、デフォルトではすべてのモードでActiveSupport::Logger::SimpleFormatterのインスタンスを使用します。config.loggerを設定する場合は、この設定がActiveSupport::TaggedLoggingインスタンスでラップされるより前に、フォーマッターの値を手動で渡さなければなりません。Railsはこの処理を自動では行いません。

    # config.log_levelは、Railsのログ出力をどのぐらい詳細にするかを指定します。デフォルトではすべての環境で:debugが指定されます。指定可能な出力レベルは:debug、:info、:warn、:error、:fatal、:unknownです。

    # config.loggerは、Rails.loggerで使われるロガーやRails関連のあらゆるログ出力（ActiveRecord::Base.loggerなど）を指定します。デフォルトでは、ActiveSupport::LoggerのインスタンスをラップするActiveSupport::TaggedLoggingのインスタンスが指定されます。なおActiveSupport::Loggerはログをlog/ディレクトリに出力します。ここにカスタムロガーを指定できますが、互換性を完全にするには以下のガイドラインに従わなければなりません。

    # フォーマッターをサポートするため、config.log_formatterの値を手動でロガーに代入しなければなりません。

    # config.generators do |g|
    #   g.assets false
    #   g.helper false
    #   g.test_framework false
    # end
  end
end
