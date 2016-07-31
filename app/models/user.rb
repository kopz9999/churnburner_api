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

    def retrieve_fub(fub_person)
      user = self.find_by(fub_id: fub_person.id)
      if user.nil?
        user = self.fub(fub_person)
        user.save
      end
      user
    end

    def fub(fub_person)
      email = fub_person.emails.find{ |e| e[:is_primary] == 1 }
      email = fub_person.emails.first if email.nil?
      self.new email: email[:value], name: fub_person.name,
               fub_id: fub_person.id
    end
  end

  extend Factory
  has_many :segment_users
  has_many :segments, through: :segment_users
  has_many :sync_events
end
