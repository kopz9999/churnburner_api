module ChurnburnerApi
  class EventsManager
    include Singleton
    PAGE_SIZE = 100

    attr_accessor :current_task

    def sync(all = false, resend = false)
      total = total_events all
      page_size = PAGE_SIZE
      pages =  (total.to_f / page_size.to_f).ceil
      pages_arr = (1..pages).to_a
      Rails.logger.info "Processing #{total} events in #{pages} pages"
      pages_arr.each do |page|
        Rails.logger.info "Enqueueing page #{page}"
        SyncEventsWorker.perform_async(page, page_size, resend)
      end
      self.current_task.finish
    end

    def total_events(all)
      app_task = AppTask.latest_success(:sync_events).first
      if app_task.nil? || all
        total = FubClient::Event.total
      else
        ran_at = app_task.runned_at.utc.iso8601.to_s
        events = FubClient::Event.where(createdAfter: ran_at).by_page(1, 1)
        total = events.metadata[:total]
      end
      self.current_task = AppTask.running :sync_events
      total
    end
  end
end
