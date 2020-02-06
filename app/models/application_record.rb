class ApplicationRecord < ActiveRecord::Base
  attr_reader :relation_keyse
  self.abstract_class = true
end
