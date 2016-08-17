class CompaniesStatsWorker
  include IntercomWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'companies_stats', retry: 5
  sidekiq_retry_in do
    (60 * rand(1..5))
  end

  def perform(user_id)
    fub_user = Fub::User.find_by(id: user_id)
    Thread.current[:fub_api_key] = fub_user.api_key
    company = fub_user.default_company
    intercom_company = self.intercom_client.companies
                         .find company_id: company.company_identifier
    intercom_company.custom_attributes.merge!( company.fub_metrics )
    self.intercom_client.companies.save(intercom_company)
  end

end
