class User < ApplicationRecord
  module Factory
    def retrieve_intercom_response(user_hash)
      user = self.find_by(intercom_id: user_hash['id'])
      if user.nil?
        user = self.intercom_response(user_hash)
        user.save
      end
      user
    end

    def intercom_response(user_hash)
      self.new email: user_hash['email'], intercom_id: user_hash['id'],
               name: user_hash['name']
    end
  end

  extend Factory
  has_many :segment_users
  has_many :segments, through: :segment_users
end
