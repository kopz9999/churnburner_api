class IntercomSegmentsWorker
  include Sidekiq::Worker

  def perform(name, count)
    self.sync_segments
  end

  def save_segments
    self.client.segments.all.each do |s|
      segment = Segment.retrieve_intercom s
      users_response = self.client.get("/users", segment_id: s.id)
      users_response['users'].each do |user_hash|
        user = User.retrieve_intercom_response user_hash
        segment.add_user user
      end
      self.segments << segment
    end
  end

  def sync_segments
    self.client.segments.all.each do |s|
      segment = Segment.retrieve_intercom s
      users_response = self.client.get("/users", segment_id: s.id)
      users_response['users'].each do |user_hash|
        segment.add_current_user User.retrieve_intercom_response(user_hash)
      end
      self.segments << segment
    end
    self.segments.each(&:sync_users)
    
  end

  protected

  def segments
    @segments||=[]
  end

  def client
    @client||= Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'],
                                    api_key: ENV['INTERCOM_API_KEY'])
  end
end
