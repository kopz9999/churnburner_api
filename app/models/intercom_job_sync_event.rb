class IntercomJobSyncEvent < ApplicationRecord
  belongs_to :sync_event
  belongs_to :intercom_job
end
