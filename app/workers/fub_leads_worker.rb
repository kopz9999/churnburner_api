class FubLeadsWorker
  include IntercomWorker
  include FubClientScope
  include Sidekiq::Worker

  sidekiq_options queue: 'fub_leads', retry: 5
  sidekiq_retry_in do
    (60 * rand(1..5))
  end

  def perform(user_id, app_task_id, page, page_size)
    self.fub_user = Fub::User.find_by(id: user_id)
    Thread.current[:fub_api_key] = self.fub_user.fub_client_datum.api_key
    persons = FubClient::Person.where(stage: FubClientsWorker::FubStages::LEAD)
                .by_page page, page_size
    unless app_task_id.nil?
      last_app_task = self.fub_user.app_tasks
                        .latest_success(:fub_clients).find app_task_id
      persons = persons.where(createdAfter: last_app_task.fub_ran_at)
    end
    # Sync leads
    Rails.logger.info "#{user_company_slug}: Processing page #{page}"
    persons.each do |person|
      next unless person.source.downcase.include? 'curaytor'
      fub_person = Fub::Person.retrieve_fub_lead person
      fub_person.set_default_company self.fub_user.validated_default_company
    end
    Rails.logger.info "#{user_company_slug}: Page #{page} processed"
  end
end
