# typeをid 17はincome、それ以外はexpenceで更新する
UPDATE at_grouped_categories SET category_type = 'expence';
UPDATE at_grouped_categories SET category_type = 'income' WHERE id = 17;