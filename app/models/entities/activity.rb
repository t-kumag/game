class Entities::Activity < ApplicationRecord

  def activities(
      bank_account_id, card_account_id, emoney_account_id,
          partner_bank_account_id, partner_card_account_id, partner_emoney_account_id
  )
    #・個人収入支出（デイリーでまとめて）
    #　　　　→　銀行出金、クレカ利用明細、電マネ利用明細等をまとめて、＠件で表示
    #　　　　　　※「振分け」も取引の増加になるため、この中に含む
    #　　　　→　クリックで個人明細画面に遷移
    #・夫婦収入支出（デイリーでまとめて）
    #　　　　→　銀行出金、クレカ利用明細、電マネ利用明細等をまとめて、＠件で表示
    #　　　　　　※「振分け」も取引の増加になるため、この中に含む
    #　　　　→　クリックで夫婦明細画面に遷移
    # TODO: ・夫婦明細のコメント入力（都度）
    # TODO:　　→　明細詳細画面遷移
    #・目標の設定

    daysMap = {}
    p_daysMap = {}
    transactions = []
    p_transactions = []

    if bank_account_id
      @b_transactions = Services::AtBankTransactionService.new.list(bank_account_id)
      transactions.push(@b_transactions)
    end
    if card_account_id
      @c_transactions = Services::AtCardTransactionService.new.list(card_account_id)
      transactions.push(@c_transactions)
    end
    if emoney_account_id
      @e_transactions = Services::AtEmoneyTransactionService.new.list(emoney_account_id)
      transactions.push(@e_transactions)
    end

    if partner_bank_account_id
      @p_b_transactions = Services::AtBankTransactionService.new.list(partner_bank_account_id)
      p_transactions.push(@p_e_transactions)
    end
    if partner_card_account_id
      @p_c_transactions = Services::AtCardTransactionService.new.list(partner_card_account_id)
      p_transactions.push(@p_c_transactions)
    end
    if partner_emoney_account_id
      @p_e_transactions = Services::AtEmoneyTransactionService.new.list(partner_emoney_account_id)
      p_transactions.push(@p_e_transactions)
    end

    transactions.each {|transactions|
      transactions.map {|t|
        if t.kind_of?(Entities::AtUserBankTransaction)
          dayStr = t.trade_date.strftime('%Y-%m-%d')
        else
          dayStr = t.used_date.strftime('%Y-%m-%d')
        end
        unless daysMap[dayStr]
          daysMap[dayStr] = [t]
        else
          daysMap[dayStr].push(t)
        end
      }
    }
    p_transactions.each {|transactions|
      transactions.map {|t|
        if t.kind_of?(Entities::AtUserBankTransaction)
          dayStr = t.trade_date.strftime('%Y-%m-%d')
        else
          dayStr = t.used_date.strftime('%Y-%m-%d')
        end
        unless daysMap[dayStr]
          p_daysMap[dayStr] = [t]
        else
          p_daysMap[dayStr].push(t)
        end
      }
    }

    @result = []

    daysMap.each {|key, value|
      type = ""
      b_count = 0
      c_count = 0
      e_count = 0
      value.each {|t|
        if t.kind_of?(Entities::AtUserBankTransaction)
          b_count += 1
        elsif t.kind_of?(Entities::AtUserCardTransaction)
          c_count += 1
        elsif t.kind_of?(Entities::AtUserEmoneyTransaction)
          e_count += 1
        end
      }
      if b_count > 0
        @result.push({
                        "day": key,
                        "type": "bank",
                        "count": b_count,
                    })
      end
      if c_count > 0
        @result.push({
                        "day": key,
                        "type": "card",
                        "count": c_count,
                    })
      end
      if e_count > 0
        @result.push({
                        "day": key,
                        "type": "emoney",
                        "count": e_count,
                    })
      end
    }
    p_daysMap.each {|key, value|
      type = ""
      b_count = 0
      c_count = 0
      e_count = 0
      value.each {|t|
        if t.kind_of?(Entities::AtUserBankTransaction)
          b_count += 1
        elsif t.kind_of?(Entities::AtUserCardTransaction)
          c_count += 1
        elsif t.kind_of?(Entities::AtUserEmoneyTransaction)
          e_count += 1
        end
      }
      if b_count > 0
        @result.push({
                         "day": key,
                         "type": "partner_bank",
                         "count": b_count,
                     })
      end
      if c_count > 0
        @result.push({
                         "day": key,
                         "type": "partner_card",
                         "count": c_count,
                     })
      end
      if e_count > 0
        @result.push({
                         "day": key,
                         "type": "partner_emoney",
                         "count": e_count,
                     })
      end
    }

    pp @result

  end

end
