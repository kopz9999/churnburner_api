class Segment < ApplicationRecord
  module Factory
    def retrieve_intercom(intercom_segment)
      segment = self.find_by(intercom_id: intercom_segment.id)
      if segment.nil?
        segment = self.intercom intercom_segment
        segment.save
      end
      segment
    end

    def intercom(intercom_segment)
      self.new intercom_id: intercom_segment.id, name: intercom_segment.name
    end
  end

  extend Factory

  has_many :segment_users
  has_many :users, through: :segment_users

  def add_user(user)
    u = self.users.find_by(id: user.id)
    if u.nil?
      SegmentUser.create(segment: self, user: user)
    end
    user
  end

  def add_current_user(user)
    self.current_users[user.id] = user
  end

  def current_users
    @current_users||= {}
  end

  def new_users
    @new_users||= []
  end

  def removed_users
    @removed_users||= []
  end

  def evaluate_users
    self.users.reload
    self.users.each do |user|
      u = self.current_users.delete user.id
      self.removed_users << user if u.nil?
    end
    self.current_users.each do |_k, v|
      self.new_users << v
    end
  end

  # NOTE: Consider a transaction if too many users
  def update_users
    self.new_users.each do |u|
      SegmentUser.create(segment: self, user: u)
    end
    SegmentUser.where(user_id: self.removed_users.map(&:id),
                      segment_id: self.id).destroy_all
  end

  def sync_users
    evaluate_users
    update_users
  end
end
