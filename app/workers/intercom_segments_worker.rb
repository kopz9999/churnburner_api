class IntercomSegmentsWorker
  include Sidekiq::Worker

  def perform(name, count)
    self.sync_segments
  end

  def save_segments
    self.client.segments.all.each do |s|
      segment = Segment.find_by(intercom_id: s.id)
      if segment.nil?
        segment = Segment.intercom s
        segment.save
      end
      users_response = self.client.get("/users", segment_id: s.id)
      users_response['users'].each do |user_hash|
        
      end
    end
  end

  def sync_segments
    self.client.segments.all.each do |s|
      segment = Segment.find_by(intercom_id: s.id)
      if segment.nil?
        segment = Segment.intercom s
        segment.save
      end
    end
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
