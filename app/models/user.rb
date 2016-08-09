class User < ApplicationRecord
  module Factory
    def retrieve_intercom_response(user_hash)
      user = self.find_by(intercom_id: user_hash['id'])
      if user.nil?
        user = self.intercom_response(user_hash)
        user.save
      end
      user
    end

    def intercom_response(user_hash)
      self.new email: user_hash['email'], intercom_id: user_hash['id'],
               name: user_hash['name']
    end

    def retrieve_fub(fub_person)
      user = self.find_by(fub_id: fub_person.id)
      if user.nil?
        user = self.fub(fub_person)
        user.save
      end
      user
    end

    def fub(fub_person)
      email = fub_person.emails.find{ |e| e[:is_primary] == 1 }
      email = fub_person.emails.first if email.nil?
      email_value = email.nil? ?
        "unknown_#{fub_person.id}@gmail.com" : email[:value]
      self.new email: email_value.downcase, name: fub_person.name,
               fub_id: fub_person.id
    end
  end

  extend Factory
  has_many :segment_users
  has_many :segments, through: :segment_users
  has_many :user_companies
  has_many :companies, through: :user_companies
  has_one :default_user_companies, -> { default }, class_name: 'UserCompany'
  has_one :default_company, through: :default_user_companies, source: :company
  has_many :sync_events

  def reset_default_company
    self.user_companies.where(default: true).update_all(default: false)
  end

  # @param [Company] company
  def set_default_company(company)
    reset_default_company
    self.user_companies.create(default: true, company: company)
    self.default_company = company
  end

  def validated_default_company
    self.default_company || self.companies.first
  end
end
