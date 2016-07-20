class User < ApplicationRecord
  module Factory
    def intercom_response(user_hash)
      self.new email: user_hash['email'], intercom_id: user_hash['id']
    end
  end

  extend Factory
  has_many :segment_users
  has_many :segments, through: :segment_users
end
