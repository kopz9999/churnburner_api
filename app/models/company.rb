class Company < ApplicationRecord
  DATA_ATTRIBUTES = [:phone, :email, :address, :facebook, :twitter, :linkedin,
                     :google_plus, :youtube, :pinterest, :instagram, :snapchat]

  module Factory
    # @param [Intercom::User] intercom_usr
    # @return [Company]
    def intercom_user(intercom_usr)
      company_name =
        intercom_usr.custom_attributes['company_name'].gsub('"', '')
      company = self.create name: company_name
      intercom_usr.custom_attributes.each do |k, v|
        if k.start_with?('company_') && k != 'company_name'
          value = v.to_s.gsub('"', '')
          unless value.blank?
            company.data.create(name: k.gsub('company_', ''), value: value)
          end
        end
      end
      company.company_identifier = company.id.to_s
      company.save
      company
    end

    # @param [Intercom::Company] intercom_comp
    # @return [Company]
    def intercom_company(intercom_comp)
      company = self.create name: intercom_comp.name
      unless intercom_comp.custom_attributes.blank?
        intercom_comp.custom_attributes.each do |k, v|
          company.data.create(name: k, value: v) unless v.blank?
        end
      end
      company.company_identifier = intercom_comp.company_id.to_s
      company.save
      company
    end
  end

  extend Factory

  has_many :data, class_name: 'CompanyDatum'
  has_many :user_companies
  has_many :users, through: :user_companies

  DATA_ATTRIBUTES.each do |a|
    has_one :"#{a}_data", -> { where(name: a) }, class_name: 'CompanyDatum'
  end

  def to_intercom_hash
    custom_attributes = {}
    self.data.map do |c_data|
      custom_attributes[c_data.name] = c_data.value
    end
    {
      company_id: self.company_identifier,
      name: self.name,
      custom_attributes: custom_attributes
    }
  end
end
