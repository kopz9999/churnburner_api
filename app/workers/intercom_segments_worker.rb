class IntercomSegmentsWorker
  include Sidekiq::Worker

  def perform(name, count)
    self.sync_segments
    self.notify_segment_users
  end

  def save_segments
    self.intercom_client.segments.all.each do |s|
      segment = Segment.retrieve_intercom s
      users_response = self.intercom_client.get("/users", segment_id: s.id)
      users_response['users'].each do |user_hash|
        user = User.retrieve_intercom_response user_hash
        segment.add_user user
      end
      self.segments << segment
    end
  end

  def sync_segments
    self.intercom_client.segments.all.each do |s|
      segment = Segment.retrieve_intercom s
      users_response = self.intercom_client.get("/users", segment_id: s.id)
      users_response['users'].each do |user_hash|
        segment.add_current_user User.retrieve_intercom_response(user_hash)
      end
      self.segments << segment
    end
    self.segments.each(&:sync_users)
  end

  def notify_segment_users
    self.segments.each(&method(:process_segment))
  end

  def process_segment(segment)
    segments_channel = "##{Figleaf::Settings.slack[:segments_channel]}"
    default_opts = { channel: segments_channel, as_user: false }
    segment.new_users.each do |u|
      text = I18n.t('slack.added_user', user_name: u.name,
                    user_email: u.email, segment_name: segment.name)
      self.slack_client.chat_postMessage(default_opts.merge(text: text))
    end
    segment.removed_users.each do |u|
      text = I18n.t('slack.removed_user', user_name: u.name,
                    user_email: u.email, segment_name: segment.name)
      self.slack_client.chat_postMessage(default_opts.merge(text: text))
    end
  end

  def segments
    @segments||=[]
  end

  def intercom_client
    @intercom_client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                             api_key: ENV['INTERCOM_API_KEY'])
  end

  def slack_client
    @slack_client||= Slack::Web::Client.new
  end
end
