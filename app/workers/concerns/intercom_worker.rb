module IntercomWorker
  # @return [Intercom::Client]
  def intercom_client
    @intercom_client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                             api_key: ENV['INTERCOM_API_KEY'])
  end

  # @param [String] tag_name
  # @param [Company] company
  def tag_company(tag_name, company)
    intercom_client.tags.tag(name: tag_name,
                             companies: [
                               {company_id: company.company_identifier }
                             ])
  end

  # @param [String] tag_name
  # @param [User] user
  def tag_user(tag_name, user)
    intercom_client.tags.tag(name: tag_name,
                             users: [
                               {id: user.intercom_id }
                             ])
  end

  def ran_at_time
    @ran_at_time ||= Time.now
  end

  def ran_at
    "#{ran_at_time.strftime('%m/%d/%Y')} #{ran_at_time.strftime('%I:%M%p')} " +
      ran_at_time.zone
  end
end
