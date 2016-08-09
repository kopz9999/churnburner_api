class FubClientsWorker
  PAGE_SIZE = 100
  module FubStages
    LEAD = 'Lead'
  end

  include IntercomWorker
  include FubClientScope
  include Sidekiq::Worker
  sidekiq_options queue: 'fub_clients'

  # @return [AppTask]
  attr_accessor :current_task
  # @return [AppTask]
  attr_accessor :last_app_task

  def perform(user_id, all)
    self.fub_user = Fub::User.find_by(id: user_id)
    Thread.current[:fub_api_key] = self.fub_user.fub_client_datum.api_key
    setup_app_tasks
    # App Task variables
    app_task_id = last_app_task &. last_app_task.id
    total = total_fub_clients all
    # Paginate
    page_size = PAGE_SIZE
    pages =  (total.to_f / page_size.to_f).ceil
    pages_arr = (1..pages).to_a
    # Process pages
    Rails.logger.info("#{user_company_slug}: Processing"+
                        " #{total} users in #{pages} pages")
    pages_arr.each do |page|
      Rails.logger.info "#{user_company_slug}: Enqueueing page #{page}"
      FubLeadsWorker.perform_async(user_id, app_task_id, page, page_size)
    end
    Rails.logger.info "#{user_company_slug}: All Pages enqueued"
    self.current_task.finish
  end

  def total_fub_clients(all)
    persons = FubClient::Person.where(stage: FubStages::Lead).by_page(1, 1)
    if !all && !last_app_task.nil?
      persons = persons.where(createdAfter: last_app_task.fub_ran_at)
    end
    persons.metadata[:total]
  end

  def setup_app_tasks
    self.last_app_task =
      self.fub_user.app_tasks.latest_success(:fub_clients).first
    self.current_task = AppTask.running :fub_clients
    UserAppTask.create app_task: self.current_task, user: self.fub_user
  end
end
