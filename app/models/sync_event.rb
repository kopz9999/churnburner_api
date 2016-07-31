class SyncEvent < ApplicationRecord
  module Factory
    def fub(fub_event)
      self.new name: fub_event.type, description: fub_event.description,
               fub_id: fub_event.id,
               fub_created: Time.parse(fub_event.created).to_i
    end
  end

  extend Factory

  belongs_to :user
  has_many :intercom_job_sync_events
  has_many :intercom_jobs, through: :intercom_job_sync_events

  def to_intercom_hash
    {
      event_name: self.name,
      created_at: self.fub_created, email: self.user.email,
      metadata: { description: self.description }
    }
  end

  def mark_sent_to_intercom
    self.sent_to_intercom = true
    self.save
  end
end
