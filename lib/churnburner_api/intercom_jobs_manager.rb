class IntercomJobsManager
  include Singleton

  def process
    IntercomJob.events.running.each do |intercom_job|
      begin
        job = intercom_client.jobs.find(id: intercom_job.intercom_id)
      rescue Intercom::ResourceNotFound
        job = nil
      end
      case job.state
        when 'completed'
          intercom_job.finish
        when 'failed'
          intercom_job.fail
      end
    end
  end

  def intercom_client
    @intercom_client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                             api_key: ENV['INTERCOM_API_KEY'])
  end
end
