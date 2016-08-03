class UserCompany < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :user_id, uniqueness: { scope: :company_id }
  validates :company_id, uniqueness: { scope: :user_id }
end
