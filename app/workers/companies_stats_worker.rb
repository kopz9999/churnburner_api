class CompaniesStatsWorker
  include IntercomWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'companies_stats', retry: 5
  sidekiq_retry_in do
    (60 * rand(1..5))
  end

  def perform(user_id)
    company = Company.find user_id
    intercom_company = self.intercom_client.companies
                         .find company_id: company.company_identifier
    intercom_company.custom_attributes.merge!( company.fub_metrics )
    self.intercom_client.companies.save(intercom_company)
  end

end
