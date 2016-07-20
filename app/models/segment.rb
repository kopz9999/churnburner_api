class Segment < ApplicationRecord
  module Factory
    def intercom(intercom_segment)
      self.new intercom_id: intercom_segment.id, name: intercom_segment.name
    end
  end

  extend Factory

  has_many :segment_users
  has_many :users, through: :segment_users
end
