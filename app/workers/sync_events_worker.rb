class SyncEventsWorker
  include Sidekiq::Worker

  def perform(page, page_size, resend = false)
    fub_events = FubClient::Event.by_page page, page_size
    clear_events
    fub_events.each do |fub_event|
      next unless fub_event.source.downcase.include? 'curaytor'
      user = User.retrieve_fub fub_event.person
      sync_intercom_user user
      sync_event = user.sync_events.find_by(fub_id: fub_event.id)
      if sync_event.nil?
        sync_event = SyncEvent.fub fub_event
        sync_event.user = user
        sync_event.save
        keep_event sync_event
      else
        if sync_event.sent_to_intercom
          keep_event sync_event if resend
        else
          keep_event sync_event
        end
      end
    end
    unless events.blank?
      job =
        intercom_client.events.submit_bulk_job create_items: bulk_events
      intercom_job = IntercomJob.running_events(job.id)
      intercom_job.save
      events.each do |e|
        e.mark_sent_to_intercom
        IntercomJobSyncEvent.create(sync_event: e, intercom_job: intercom_job)
      end
    end
  end

  def sync_intercom_user(user)
    if user.intercom_id.nil?
      begin
        intercom_user = intercom_client.users.find(email: user.email)
      rescue Intercom::ResourceNotFound
        intercom_user = nil
      end
      if intercom_user.nil?
        intercom_user = intercom_client.users.create(email: user.email,
                                                 name: user.name)
      end
      user.intercom_id = intercom_user.id
      user.save
    end
  end

  def intercom_client
    @intercom_client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                             api_key: ENV['INTERCOM_API_KEY'])
  end

  def keep_event(sync_event)
    self.events << sync_event
    self.bulk_events << sync_event.to_intercom_hash
  end

  def clear_events
    events.clear
    bulk_events.clear
  end

  def events
    @events ||= []
  end

  def bulk_events
    @bulk_events ||= []
  end
end
