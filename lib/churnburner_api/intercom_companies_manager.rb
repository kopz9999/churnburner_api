module ChurnburnerApi
  class IntercomCompaniesManager
    include IntercomWorker
    include Singleton
    PAGE_SIZE = 50

    def process
      # App-wide counts
      total = intercom_client.counts.for_app.user['count']
      page_size = PAGE_SIZE
      pages =  (total.to_f / page_size.to_f).ceil
      pages_arr = (1..pages).to_a
      Rails.logger.info "Processing #{total} users in #{pages} pages"
      ran_at_time = Time.now
      ran_at_desc = ran_at_time.strftime('%m/%d/%Y') + ' ' +
        ran_at_time.strftime('%I:%M%p') + ' ' + ran_at_time.zone
      pages_arr.each do |page|
        Rails.logger.info "Enqueueing page #{page}"
        IntercomCompaniesWorker.perform_async(page, page_size, ran_at_desc)
      end
    end

    def process_stats
      Rails.logger.info "Processing Follow Up Boss companies"
      companies = Company.fub_companies
      companies.each { |c| CompaniesStatsWorker.perform_async(c.id) }
      Rails.logger.info "Finished Processing Follow Up Boss companies"
    end
  end
end
