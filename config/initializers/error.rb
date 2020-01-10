
module ERROR_TYPE
  NUMBER = {
      "001001":  { code: '001001', message: 'こちらのアドレスは本登録されておりません。再度認証URLを送付しますか？', info: 'Account status is temporary registration.'},
      "001002":  { code: '001002', message: 'こちらのメールアドレはOsidOriに登録されていません。ご確認をお願いいたします。', info: 'Email not found.'},
      "001003":  { code: '001003', message: 'こちらのメールアドレはOsidOriに登録されていません。ご確認をお願いいたします。', info: 'User not found or invalid token.'},
      "002001":  { code: '002001', message: '写真の登録に失敗しました。もう一度お試しください。', info: 'Icon is registered.'},
      "002002":  { code: '002002', message: '写真の登録に失敗しました。もう一度お試しください。', info: 'Icon not found.'},
      "003001":  { code: '003001', message: 'その金融機関にはアクセスできません。', info: 'Disallowed financier id.'},
      "003002":  { code: '003002', message: '金融機関の削除は登録者のみ行えます。', info: 'Disallowed partner account id.	'},
      "004001":  { code: '004001', message: 'その利用明細にはアクセスできません。', info: 'Disallowed transaction id.	'},
      "005001":  { code: '005001', message: 'その目標貯金にはアクセスできません。', info: 'Record not found.'},
      "005002":  { code: '005002', message: 'その目標貯金にはアクセスできません。', info: 'Disallowed goal id.'},
      "005003":  { code: '005003', message: 'その目標貯金にはアクセスできません。', info: 'Disallowed goal setting id.'},
      "005004":  { code: '005004', message: 'その目標貯金にはアクセスできません。', info: 'Goal not found.'},
      "005005":  { code: '005005', message: 'その目標貯金にはアクセスできません。', info: 'Goal settings not found.	'},
      "005006":  { code: '005006', message: 'その目標貯金にはアクセスできません。', info: 'User not found or goal not found.'},
      "006001":  { code: '006001', message: '家族画面をご利用頂くにはペアリングが必要となります。まずは設定画面からペアリングを設定してください。', info: 'Require group.'},
      "006002":  { code: '006002', message: '招待したいパートナーにURLを送り、URLをタップしていただいてください。', info: 'Same user.'},
      "006003":  { code: '006003', message: 'お客様はすでにペアリング済みです。', info: 'Paring user already exists.'},
      "006004":  { code: '006004', message: '招待をしたお客様は、すでにペアリング済みです。', info: 'From user group taken.'},
      "006005":  { code: '006005', message: 'お客様はすでにペアリング済みです。', info: 'To user group taken.'},
      "006006":  { code: '006006', message: '招待をしたお客様は、OsidOriには存在しません。', info: 'Pairing token not found.'},
      "006007":  { code: '006007', message: 'こちらのURLは有効期限が過ぎています。再度招待していただいてください。', info: 'Paring user not found or invalid token.'},
      "007001":  { code: '007001', message: '登録数が上限のため追加できません(5個)', info: 'Five goal limit of free users.'},
      "007002":  { code: '007002', message: '登録数が上限のため追加できません(5個)', info: 'Five account limit of free users.'},
      "007003":  { code: '007003', message: 'この機能はプレミアムプランへの登録が必要です。ぜひお試しください。', info: 'Not premium user.'},
      "008001":  { code: '008001', message: 'ネットワークエラー', info: 'Message sample fobidden.'}
  }.freeze
end
