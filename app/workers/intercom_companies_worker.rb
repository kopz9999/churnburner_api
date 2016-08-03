class IntercomCompaniesWorker
  include IntercomWorker
  include Sidekiq::Worker

  def perform(page, page_size)
    intercom_users = self.intercom_client.users.find_all page: page,
                                                         per_page: page_size
    intercom_users.each(&method(:process_user))
  end

  # @param [Intercom::User] intercom_user
  def process_user(intercom_user)
    if !intercom_user.custom_attributes.blank? && \
        (raw_company_name = intercom_user.custom_attributes['company_name'])
      company = find_company intercom_user, raw_company_name.gsub('"', '')
      intercom_user.companies = [company.to_intercom_hash]
      self.intercom_client.users.save(intercom_user)
    end
  end

  # @return [Company]
  def find_company(intercom_user, company_name)
    company = Company.find_by name: company_name
    if company.nil?
      begin
        intercom_company =
          self.intercom_client.companies.find(name: company_name)
      rescue Intercom::ResourceNotFound
        intercom_company = nil
      end
      company = intercom_company.nil? ?
        Company.intercom_user(intercom_user) :
          Company.intercom_company(intercom_company)
    end
    company
  end
end
