class LocalizeString < ActiveRecord::Base
  belongs_to :language
  belongs_to :localize_model
end
