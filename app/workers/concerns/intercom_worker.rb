module IntercomWorker
  def intercom_client
    @intercom_client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                             api_key: ENV['INTERCOM_API_KEY'])
  end
end
