# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_21_050538) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id"
    t.integer "count", default: 0, null: false
    t.string "activity_type", null: false
    t.string "url"
    t.string "message"
    t.datetime "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "at_banks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_emoney_services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_grouped_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_name"
    t.string "category_type"
  end

  create_table "at_scraping_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_bank_account_id"
    t.bigint "at_user_card_account_id"
    t.bigint "at_user_emoney_service_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_user_bank_account_id"], name: "index_at_scraping_logs_on_at_user_bank_account_id"
    t.index ["at_user_card_account_id"], name: "index_at_scraping_logs_on_at_user_card_account_id"
    t.index ["at_user_emoney_service_account_id"], name: "index_at_scraping_logs_on_at_user_emoney_service_account_id"
  end

  create_table "at_sync_transaction_latest_date_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "at_user_bank_account_id"
    t.integer "at_user_card_account_id"
    t.integer "at_user_emoney_service_account_id"
    t.datetime "latest_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "at_sync_transaction_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_bank_account_id"
    t.bigint "at_user_card_account_id"
    t.bigint "at_user_emoney_service_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_user_bank_account_id"], name: "index_at_sync_transaction_logs_on_at_user_bank_account_id"
    t.index ["at_user_card_account_id"], name: "index_at_sync_transaction_logs_on_at_user_card_account_id"
    t.index ["at_user_emoney_service_account_id"], name: "index_a_s_t_l_on_at_user_emoney_service_account_id"
  end

  create_table "at_sync_transaction_monthly_date_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "monthly_date", null: false
    t.bigint "at_user_bank_account_id"
    t.bigint "at_user_card_account_id"
    t.bigint "at_user_emoney_service_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_user_bank_account_id"], name: "index_a_s_t_l_on_at_user_bank_account_id"
    t.index ["at_user_card_account_id"], name: "index_a_s_t_l_on_at_user_card_account_id"
    t.index ["at_user_emoney_service_account_id"], name: "index_a_s_t_l_on_at_user_emoney_service_account_id"
  end

  create_table "at_transaction_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "at_category_id", null: false
    t.string "category_name1"
    t.string "category_name2"
    t.bigint "at_grouped_category_id"
    t.index ["at_grouped_category_id"], name: "index_at_transaction_categories_on_at_grouped_category_id"
  end

  create_table "at_user_asset_products", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "at_user_asset_id"
    t.string "assets_product_type"
    t.bigint "assets_product_balance"
    t.bigint "assets_product_profit_loss_amount"
    t.string "product_rec"
    t.string "product_name"
    t.bigint "product_balance"
    t.integer "product_profit_loss_amount"
    t.integer "product_profit_loss_rate"
    t.float "product_bond_rate"
  end

  create_table "at_user_assets", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "at_user_stock_account_id"
    t.bigint "total_balance"
    t.bigint "total_profit_loss_amount"
    t.bigint "total_deposit_balance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "at_user_bank_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_bank_id"
    t.bigint "balance", default: 0, null: false, unsigned: true
    t.boolean "share", default: false, null: false
    t.string "fnc_id", null: false
    t.string "fnc_cd", null: false
    t.string "fnc_nm", null: false
    t.string "corp_yn", null: false
    t.string "brn_cd"
    t.string "brn_nm"
    t.string "acct_no"
    t.string "acct_kind"
    t.string "memo"
    t.string "use_yn", null: false
    t.string "cert_type", null: false
    t.datetime "scrap_dtm", null: false
    t.string "last_rslt_cd"
    t.string "last_rslt_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_id"
    t.datetime "error_date"
    t.integer "error_count", default: 0
    t.index ["at_bank_id"], name: "index_at_user_bank_accounts_on_at_bank_id"
    t.index ["at_user_id", "fnc_id"], name: "at_user_bank_accounts_at_user_id_fnc_id", unique: true
    t.index ["at_user_id"], name: "index_at_user_bank_accounts_on_at_user_id"
    t.index ["deleted_at"], name: "index_at_user_bank_accounts_on_deleted_at"
    t.index ["group_id"], name: "index_at_user_bank_accounts_on_group_id"
  end

  create_table "at_user_bank_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_bank_account_id", null: false
    t.datetime "trade_date", null: false
    t.string "description1", null: false
    t.string "description2"
    t.string "description3"
    t.string "description4"
    t.string "description5"
    t.bigint "amount_receipt", default: 0, null: false
    t.bigint "amount_payment", default: 0, null: false
    t.bigint "balance", default: 0, null: false
    t.string "currency", null: false
    t.integer "seq", null: false
    t.bigint "at_transaction_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_type"
    t.index ["at_transaction_category_id"], name: "index_at_user_bank_transactions_on_at_transaction_category_id"
    t.index ["at_user_bank_account_id", "seq"], name: "at_user_bank_transactions_at_user_bank_account_id_seq", unique: true
    t.index ["at_user_bank_account_id"], name: "index_at_user_bank_transactions_on_at_user_bank_account_id"
  end

  create_table "at_user_card_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_card_id"
    t.boolean "share", default: false, null: false
    t.string "fnc_id", null: false
    t.string "fnc_cd", null: false
    t.string "fnc_nm", null: false
    t.string "corp_yn", null: false
    t.string "brn_cd"
    t.string "brn_nm"
    t.string "acct_no"
    t.string "memo"
    t.string "use_yn", null: false
    t.string "cert_type", null: false
    t.datetime "scrap_dtm", null: false
    t.string "last_rslt_cd"
    t.string "last_rslt_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_id"
    t.datetime "error_date"
    t.integer "error_count", default: 0
    t.index ["at_card_id"], name: "index_at_user_card_accounts_on_at_card_id"
    t.index ["at_user_id", "fnc_id"], name: "at_user_card_accounts_at_user_id_fnc_id", unique: true
    t.index ["at_user_id"], name: "index_at_user_card_accounts_on_at_user_id"
    t.index ["deleted_at"], name: "index_at_user_card_accounts_on_deleted_at"
    t.index ["group_id"], name: "index_at_user_card_accounts_on_group_id"
  end

  create_table "at_user_card_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_card_account_id"
    t.datetime "used_date", null: false
    t.string "branch_desc", null: false
    t.bigint "amount", default: 0, null: false
    t.bigint "payment_amount", default: 0, null: false
    t.string "trade_gubun", null: false
    t.string "etc_desc"
    t.string "clm_ym", null: false
    t.string "crdt_setl_dt"
    t.integer "seq", null: false
    t.string "card_no"
    t.bigint "at_transaction_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_type"
    t.index ["at_transaction_category_id"], name: "index_at_user_card_transactions_on_at_transaction_category_id"
    t.index ["at_user_card_account_id", "seq"], name: "at_user_card_transactions_at_user_card_account_id_seq", unique: true
    t.index ["at_user_card_account_id"], name: "index_at_user_card_transactions_on_at_user_card_account_id"
  end

  create_table "at_user_emoney_service_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_emoney_service_id"
    t.bigint "balance", default: 0, null: false
    t.boolean "share", default: false, null: false
    t.string "fnc_id", null: false
    t.string "fnc_cd", null: false
    t.string "fnc_nm", null: false
    t.string "corp_yn", null: false
    t.string "acct_no"
    t.string "memo"
    t.string "use_yn", null: false
    t.string "cert_type", null: false
    t.datetime "scrap_dtm", null: false
    t.string "last_rslt_cd"
    t.string "last_rslt_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_id"
    t.datetime "error_date"
    t.integer "error_count", default: 0
    t.index ["at_emoney_service_id"], name: "index_at_user_emoney_service_accounts_on_at_emoney_service_id"
    t.index ["at_user_id", "fnc_id"], name: "at_user_emoney_service_accounts_at_user_id_fnc_id", unique: true
    t.index ["at_user_id"], name: "index_at_user_emoney_service_accounts_on_at_user_id"
    t.index ["deleted_at"], name: "index_at_user_emoney_service_accounts_on_deleted_at"
    t.index ["group_id"], name: "index_at_user_emoney_service_accounts_on_group_id"
  end

  create_table "at_user_emoney_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_emoney_service_account_id"
    t.datetime "used_date", null: false
    t.string "used_time"
    t.string "description"
    t.bigint "amount_receipt", default: 0, null: false
    t.bigint "amount_payment", default: 0, null: false
    t.bigint "balance", default: 0, null: false
    t.integer "seq", null: false
    t.bigint "at_transaction_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_type"
    t.index ["at_transaction_category_id"], name: "index_at_user_emoney_transactions_on_at_transaction_category_id"
    t.index ["at_user_emoney_service_account_id", "seq"], name: "at_user_emoney_transactions_at_user_emoney_account_id_seq", unique: true
    t.index ["at_user_emoney_service_account_id"], name: "index_at_user_emoney_tran_on_at_user_emoney_service_account_id"
  end

  create_table "at_user_products", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "at_user_asset_product_id"
    t.bigint "product_balance"
    t.bigint "product_bond_rate"
    t.bigint "product_name"
    t.bigint "product_profit_loss_rate"
    t.bigint "product_profit_loss_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "at_user_stock_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.boolean "share", default: false, null: false
    t.string "fnc_id", null: false
    t.string "fnc_cd", null: false
    t.string "fnc_nm", null: false
    t.string "corp_yn", null: false
    t.string "brn_cd"
    t.string "brn_nm"
    t.string "memo"
    t.string "use_yn", default: ""
    t.string "cert_type", default: ""
    t.string "sv_type", default: "", null: false
    t.datetime "scrap_dtm", null: false
    t.string "last_rslt_cd"
    t.string "last_rslt_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_id"
    t.datetime "error_date"
    t.integer "error_count", limit: 1, default: 0
    t.string "bank_cd"
    t.string "bank_nm"
    t.index ["at_user_id", "fnc_id"], name: "at_user_bank_accounts_at_user_id_fnc_id", unique: true
    t.index ["at_user_id"], name: "index_at_user_bank_accounts_on_at_user_id"
    t.index ["deleted_at"], name: "index_at_user_bank_accounts_on_deleted_at"
    t.index ["group_id"], name: "index_at_user_bank_accounts_on_group_id"
  end

  create_table "at_user_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.string "token"
    t.timestamp "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["at_user_id"], name: "index_at_user_tokens_on_at_user_id"
    t.index ["deleted_at"], name: "index_at_user_tokens_on_deleted_at"
  end

  create_table "at_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "at_user_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_at_users_on_deleted_at"
    t.index ["user_id"], name: "index_at_users_on_user_id"
  end

  create_table "balance_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_bank_account_id"
    t.bigint "at_user_emoney_service_account_id"
    t.integer "amount", default: 0, null: false
    t.datetime "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_user_bank_account_id"], name: "index_b_l_on_at_user_bank_account_id"
    t.index ["at_user_emoney_service_account_id"], name: "index_b_l_on_at_user_emoney_service_account_id"
  end

  create_table "budget_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_authentication_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "token", null: false
    t.date "expires_at", null: false
    t.bigint "users_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["users_id"], name: "index_email_authentication_tokens_on_users_id"
  end

  create_table "goal_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id"
    t.bigint "goal_id"
    t.bigint "at_user_bank_account_id"
    t.bigint "add_amount", default: 0, null: false
    t.bigint "monthly_amount", default: 0, null: false
    t.bigint "first_amount", default: 0, null: false
    t.bigint "before_current_amount", default: 0, null: false
    t.bigint "after_current_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "goal_amount", default: 0, null: false
    t.datetime "add_date"
    t.index ["at_user_bank_account_id"], name: "index_goal_logs_on_at_user_bank_account_id"
    t.index ["goal_id"], name: "index_goal_logs_on_goal_id"
  end

  create_table "goal_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "goal_id"
    t.bigint "at_user_bank_account_id"
    t.bigint "monthly_amount", default: 0, null: false
    t.bigint "first_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["at_user_bank_account_id"], name: "index_goal_settings_on_at_user_bank_account_id"
    t.index ["goal_id"], name: "index_goal_settings_on_goal_id"
  end

  create_table "goal_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "img_url"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.bigint "goal_type_id"
    t.string "name"
    t.string "img_url"
    t.date "start_date"
    t.date "end_date"
    t.bigint "goal_amount", default: 0, null: false
    t.bigint "current_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_goals_on_deleted_at"
    t.index ["goal_type_id"], name: "index_goals_on_goal_type_id"
    t.index ["group_id"], name: "index_goals_on_group_id"
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title", null: false
    t.date "date", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "pairing_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "from_user_id"
    t.bigint "to_user_id"
    t.bigint "group_id"
    t.string "token"
    t.datetime "token_expires_at"
    t.bigint "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id"], name: "index_pairing_requests_on_from_user_id"
    t.index ["group_id"], name: "index_pairing_requests_on_group_id"
    t.index ["to_user_id"], name: "index_pairing_requests_on_to_user_id"
  end

  create_table "participate_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_participate_groups_on_deleted_at"
    t.index ["group_id"], name: "index_participate_groups_on_group_id"
    t.index ["user_id"], name: "index_participate_groups_on_user_id"
  end

  create_table "user_budget_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "budget_question_id"
    t.integer "step", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_question_id"], name: "index_user_budget_questions_on_budget_question_id"
    t.index ["user_id"], name: "index_user_budget_questions_on_user_id"
  end

  create_table "user_cancel_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "user_cancel_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_cancel_question_id"], name: "index_user_cancel_answers_on_user_cancel_question_id"
    t.index ["user_id"], name: "index_user_cancel_answers_on_user_id"
  end

  create_table "user_cancel_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "cancel_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_cancel_reasons", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.text "cancel_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_cancel_reasons_on_user_id"
  end

  create_table "user_distributed_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.boolean "share", default: false, null: false
    t.datetime "used_date", null: false
    t.bigint "at_user_bank_transaction_id"
    t.bigint "at_user_card_transaction_id"
    t.bigint "at_user_emoney_transaction_id"
    t.bigint "user_manually_created_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "used_location"
    t.text "memo"
    t.bigint "amount", default: 0, null: false
    t.bigint "at_transaction_category_id"
    t.boolean "ignore", default: false, null: false
    t.index ["at_transaction_category_id"], name: "index_u_d_t_on_at_transaction_category_id"
    t.index ["at_user_bank_transaction_id"], name: "index_u_d_t_on_at_user_bank_transaction_id"
    t.index ["at_user_card_transaction_id"], name: "index_u_d_t_on_at_user_card_transaction_id"
    t.index ["at_user_emoney_transaction_id"], name: "index_u_d_t_on_at_user_emoney_transaction_id"
    t.index ["group_id"], name: "index_user_distributed_transactions_on_group_id"
    t.index ["user_id", "at_user_bank_transaction_id"], name: "index_u_d_t_on_user_id_and_at_user_bank_transaction_id", unique: true
    t.index ["user_id", "at_user_card_transaction_id"], name: "index_u_d_t_on_user_id_and_at_user_card_transaction_id", unique: true
    t.index ["user_id", "at_user_emoney_transaction_id"], name: "index_u_d_t_on_user_id_and_at_user_emoney_transaction_id", unique: true
    t.index ["user_id", "user_manually_created_transaction_id"], name: "index_u_d_t_on_user_id_and_user_manually_created_transaction_id", unique: true
    t.index ["user_id"], name: "index_user_distributed_transactions_on_user_id"
    t.index ["user_manually_created_transaction_id"], name: "index_u_d_t_on_user_manually_created_transaction_id"
  end

  create_table "user_icons", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.string "img_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_icons_on_user_id"
  end

  create_table "user_manually_created_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "at_transaction_category_id"
    t.date "used_date", null: false
    t.string "title"
    t.bigint "amount", default: 0, null: false
    t.string "used_location"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method_type"
    t.integer "payment_method_id"
    t.index ["at_transaction_category_id"], name: "index_u_m_c_t_on_at_transaction_category_id"
    t.index ["user_id"], name: "index_user_manually_created_transactions_on_user_id"
  end

  create_table "user_notices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "notice_id"
    t.bigint "user_id", null: false
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notice_id"], name: "index_user_notices_on_notice_id"
    t.index ["user_id"], name: "index_user_notices_on_user_id"
  end

  create_table "user_pl_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "pl_period_date"
    t.string "pl_type"
    t.integer "group_pl_period_date"
    t.string "group_pl_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_pl_settings_on_user_id"
  end

  create_table "user_profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.date "birthday"
    t.integer "gender"
    t.integer "has_child", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "push", default: false, null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "user_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "log_user_id"
    t.integer "group_id"
    t.integer "at_user_bank_transaction_id"
    t.integer "at_user_card_transaction_id"
    t.integer "at_user_emoney_transaction_id"
    t.integer "user_manually_created_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_share"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "token"
    t.string "password_digest"
    t.boolean "email_authenticated", default: false
    t.datetime "token_expires_at"
    t.integer "rank", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
  end

  create_table "wallets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "initial_balance", default: 0, null: false
    t.integer "balance", default: 0, null: false
    t.integer "group_id"
    t.boolean "share", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "at_scraping_logs", "at_user_bank_accounts"
  add_foreign_key "at_scraping_logs", "at_user_card_accounts"
  add_foreign_key "at_scraping_logs", "at_user_emoney_service_accounts"
  add_foreign_key "at_sync_transaction_logs", "at_user_bank_accounts"
  add_foreign_key "at_sync_transaction_logs", "at_user_card_accounts"
  add_foreign_key "at_sync_transaction_logs", "at_user_emoney_service_accounts"
  add_foreign_key "at_sync_transaction_monthly_date_logs", "at_user_bank_accounts"
  add_foreign_key "at_sync_transaction_monthly_date_logs", "at_user_card_accounts"
  add_foreign_key "at_sync_transaction_monthly_date_logs", "at_user_emoney_service_accounts"
  add_foreign_key "at_user_bank_accounts", "at_banks"
  add_foreign_key "at_user_bank_accounts", "at_users"
  add_foreign_key "at_user_bank_transactions", "at_transaction_categories"
  add_foreign_key "at_user_bank_transactions", "at_user_bank_accounts"
  add_foreign_key "at_user_card_accounts", "at_cards"
  add_foreign_key "at_user_card_accounts", "at_users"
  add_foreign_key "at_user_card_transactions", "at_transaction_categories"
  add_foreign_key "at_user_card_transactions", "at_user_card_accounts"
  add_foreign_key "at_user_emoney_service_accounts", "at_emoney_services"
  add_foreign_key "at_user_emoney_service_accounts", "at_users"
  add_foreign_key "at_user_emoney_transactions", "at_transaction_categories"
  add_foreign_key "at_user_emoney_transactions", "at_user_emoney_service_accounts"
  add_foreign_key "at_user_stock_accounts", "at_users", name: "at_user_stock_accounts_ibfk_1"
  add_foreign_key "at_user_tokens", "at_users"
  add_foreign_key "at_users", "users"
  add_foreign_key "balance_logs", "at_user_bank_accounts"
  add_foreign_key "balance_logs", "at_user_emoney_service_accounts"
  add_foreign_key "email_authentication_tokens", "users", column: "users_id"
  add_foreign_key "goal_logs", "at_user_bank_accounts"
  add_foreign_key "goal_logs", "goals"
  add_foreign_key "goal_settings", "at_user_bank_accounts"
  add_foreign_key "goal_settings", "goals"
  add_foreign_key "goals", "goal_types"
  add_foreign_key "goals", "groups"
  add_foreign_key "goals", "users"
  add_foreign_key "pairing_requests", "groups"
  add_foreign_key "pairing_requests", "users", column: "from_user_id"
  add_foreign_key "pairing_requests", "users", column: "to_user_id"
  add_foreign_key "participate_groups", "groups"
  add_foreign_key "participate_groups", "users"
  add_foreign_key "user_budget_questions", "budget_questions"
  add_foreign_key "user_budget_questions", "users"
  add_foreign_key "user_cancel_answers", "user_cancel_questions"
  add_foreign_key "user_cancel_answers", "users"
  add_foreign_key "user_cancel_reasons", "users"
  add_foreign_key "user_distributed_transactions", "at_transaction_categories"
  add_foreign_key "user_distributed_transactions", "at_user_bank_transactions"
  add_foreign_key "user_distributed_transactions", "at_user_card_transactions"
  add_foreign_key "user_distributed_transactions", "at_user_emoney_transactions"
  add_foreign_key "user_distributed_transactions", "groups"
  add_foreign_key "user_distributed_transactions", "user_manually_created_transactions"
  add_foreign_key "user_distributed_transactions", "users"
  add_foreign_key "user_icons", "users"
  add_foreign_key "user_manually_created_transactions", "at_transaction_categories"
  add_foreign_key "user_manually_created_transactions", "users"
  add_foreign_key "user_notices", "notices"
  add_foreign_key "user_notices", "users"
  add_foreign_key "user_pl_settings", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "wallets", "users"
end
