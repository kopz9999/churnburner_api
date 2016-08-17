class FubSource < ApplicationRecord
  # @!attribute name
  #   @return [String]

  validates :name, uniqueness: true
end
