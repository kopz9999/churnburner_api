class UserCompany < ApplicationRecord
  scope :default, -> { where(default: true) }

  belongs_to :user
  belongs_to :company
  belongs_to :default_company, class_name: 'Company'

  validates :user_id, uniqueness: { scope: :company_id }
  validates :company_id, uniqueness: { scope: :user_id }
end
