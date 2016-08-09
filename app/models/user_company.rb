class UserCompany < ApplicationRecord
  scope :default, -> { where(default: true) }

  belongs_to :user
  belongs_to :company
  # alias_attribute :default_company, :company

  validates :user_id, uniqueness: { scope: :company_id }
  validates :company_id, uniqueness: { scope: :user_id }
end
