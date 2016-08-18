class Company < ApplicationRecord
  # @!attribute name
  #   @return [String] the name of the user
  # @!attribute company_identifier
  #   @return [String] the name of the user
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
      company
    end

    # @param [Intercom::Company] intercom_comp
    # @return [Company]
    def intercom_company(intercom_comp)
      company = self.create name: HTMLEntities.new.decode(intercom_comp.name)
      unless intercom_comp.custom_attributes.blank?
        intercom_comp.custom_attributes.each do |k, v|
          company.data.create(name: k, value: v) unless v.blank?
        end
      end
      company.company_identifier = intercom_comp.company_id.to_s
      company.save
      company
    end

    # @param [Intercom::Company] intercom_comp
    # @return [Company]
    def retrieve_intercom_company(intercom_comp)
      company = self.find_by name: HTMLEntities.new.decode(intercom_comp.name)
      company = self.intercom_company(intercom_comp) if company.nil?
      company
    end

    def fub_user(f_usr)
      company = self.create name: "#{f_usr.name} Company"
      company.create_email_data(value: f_usr.email)
      company
    end
  end

  extend Factory

  scope :fub_companies, ->  {
    joins(:users).where(users: { fub_client: true })
  }

  has_many :data, class_name: 'CompanyDatum'
  has_many :user_companies
  has_many :users, through: :user_companies

  after_create :set_company_identifier

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

  def fub_users
    @fub_users ||= Fub::User.by_company self.id
  end

  def fub_persons
    @fub_persons ||= Fub::Person.by_company self.id
  end

  def fub_metrics
    sources = FubSource.all
    time_queries = {
      'FUB Leads in last 7 days' => {
        days_before: 7
      },
      'FUB Leads in last 30 days' => {
        days_before: 29
      },
      'All FUB Leads' => {}
    }
    result_hash = {}
    time_queries.each do |k, v|
      result_hash[k] = 0
      sources.each do |s|
        persons = FubClient::Person.by_page(1, 1)
                    .where(stage: FubClientsWorker::FubStages::LEAD,
                           source: s.name)
        if (days_before = v[:days_before])
          time_at_formatted =
            Time.now.advance(days: (days_before*-1))
              .middle_of_day.utc.iso8601.to_s
          persons = persons.where({
            createdAfter: time_at_formatted
          })
        end
        total = persons.metadata[:total]
        Rails.logger.info "#{self.name}\t#{k}\t#{s.name}\t#{total}"
        result_hash[k] += total
      end
    end
    result_hash
  end

  protected

  def set_company_identifier
    self.update(company_identifier: self.id.to_s)
  end
end
