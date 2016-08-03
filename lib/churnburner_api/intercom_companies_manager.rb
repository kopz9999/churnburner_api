class IntercomCompaniesManager
  include IntercomWorker
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

end
