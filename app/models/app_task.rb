class AppTask < ApplicationRecord
  FAIL = 0
  SUCCESS = 1
  RUNNING = 2

  module ClassMethods
    def running(name)
      create(name: name, ran_at: Time.now, status_identity: RUNNING)
    end
  end

  extend ClassMethods

  scope :latest_success, -> (name) {
    where(name: name, status_identity: SUCCESS).order(ran_at: :desc)
  }
  has_many :sidekiq_jobs

  def finish
    self.status_identity = SUCCESS
    self.save
  end

  def fub_ran_at
    self.ran_at.utc.iso8601.to_s
  end
end
