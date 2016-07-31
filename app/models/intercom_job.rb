class IntercomJob < ApplicationRecord
  RUNNING = 0
  FINISHED = 1
  FAILED = 1
  EVENTS=0

  module Factory
    def running_events(intercom_id)
      new(status_identity: RUNNING, type_identity: EVENTS,
          intercom_id: intercom_id)
    end
  end

  extend Factory

  scope :events, -> { where(type_identity: EVENTS) }
  scope :running, -> { where(status_identity: RUNNING) }

  has_many :intercom_job_sync_events
  has_many :sync_events, through: :intercom_job_sync_events

  def finish
    self.status_identity = FINISHED
    self.save
    self.sync_events.update_all(received_by_intercom: true)
  end

  def fail
    self.status_identity = FAILED
    self.save
    self.sync_events.update_all(received_by_intercom: false)
  end
end
