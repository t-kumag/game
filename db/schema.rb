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

ActiveRecord::Schema.define(version: 2019_02_04_082235) do

  create_table "at_banks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_emoney_services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fnc_cd"
    t.string "fnc_nm"
  end

  create_table "at_transaction_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "at_category_id", null: false
    t.string "category_name1"
    t.string "category_name2"
  end

  create_table "at_user_bank_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_bank_id"
    t.decimal "balance", precision: 18, scale: 2
    t.boolean "share"
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
    t.index ["at_bank_id"], name: "index_at_user_bank_accounts_on_at_bank_id"
    t.index ["at_user_id", "fnc_cd"], name: "at_user_bank_accounts_at_user_id_fnc_cd", unique: true
    t.index ["at_user_id"], name: "index_at_user_bank_accounts_on_at_user_id"
  end

  create_table "at_user_bank_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_bank_account_id", null: false
    t.datetime "trade_date", null: false
    t.string "description1", null: false
    t.string "description2"
    t.string "description3"
    t.string "description4"
    t.string "description5"
    t.decimal "amount_receipt", precision: 16, scale: 2
    t.decimal "amount_payment", precision: 16, scale: 2
    t.decimal "balance", precision: 16, scale: 2
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

  create_table "at_user_card_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_card_id"
    t.boolean "share"
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
    t.index ["at_card_id"], name: "index_at_user_card_accounts_on_at_card_id"
    t.index ["at_user_id", "fnc_cd"], name: "at_user_card_accounts_at_user_id_fnc_cd", unique: true
    t.index ["at_user_id"], name: "index_at_user_card_accounts_on_at_user_id"
  end

  create_table "at_user_card_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_card_account_id"
    t.datetime "used_date", null: false
    t.string "branch_desc", null: false
    t.decimal "amount", precision: 16, scale: 2, null: false
    t.decimal "payment_amount", precision: 16, scale: 2, null: false
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

  create_table "at_user_emoney_service_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.bigint "at_emoney_service_id"
    t.decimal "balance", precision: 18, scale: 2
    t.boolean "share"
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
    t.index ["at_emoney_service_id"], name: "index_at_user_emoney_service_accounts_on_at_emoney_service_id"
    t.index ["at_user_id", "fnc_cd"], name: "at_user_emoney_service_accounts_at_user_id_fnc_cd", unique: true
    t.index ["at_user_id"], name: "index_at_user_emoney_service_accounts_on_at_user_id"
  end

  create_table "at_user_emoney_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_emoney_service_account_id"
    t.date "used_date", null: false
    t.string "used_time"
    t.string "description"
    t.decimal "amount_receipt", precision: 16, scale: 2, null: false
    t.decimal "amount_payment", precision: 16, scale: 2, null: false
    t.decimal "balance", precision: 18, scale: 2
    t.integer "seq", null: false
    t.bigint "at_transaction_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_type"
    t.index ["at_transaction_category_id"], name: "index_at_user_emoney_transactions_on_at_transaction_category_id"
    t.index ["at_user_emoney_service_account_id", "seq"], name: "at_user_emoney_transactions_at_user_emoney_account_id_seq", unique: true
    t.index ["at_user_emoney_service_account_id"], name: "index_at_user_emoney_tran_on_at_user_emoney_service_account_id"
  end

  create_table "at_user_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "at_user_id"
    t.string "token"
    t.timestamp "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_user_id"], name: "index_at_user_tokens_on_at_user_id"
  end

  create_table "at_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id"
    t.string "at_user_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "at_user_id"
    t.index ["user_id"], name: "index_at_users_on_user_id"
  end

  create_table "families", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "participate_families", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "family_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_participate_families_on_family_id"
    t.index ["user_id"], name: "index_participate_families_on_user_id"
  end

  create_table "user_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "log_user_id"
    t.integer "group_id"
    t.string "owner"
    t.integer "at_user_bank_transaction_id"
    t.integer "at_user_card_transaction_id"
    t.integer "at_user_emoney_transaction_id"
    t.integer "user_manually_created_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "token"
    t.string "crypted_password"
  end

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
  add_foreign_key "at_user_tokens", "at_users"
  add_foreign_key "at_users", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "participate_families", "families"
  add_foreign_key "participate_families", "users"
end
