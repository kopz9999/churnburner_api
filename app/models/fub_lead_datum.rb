class FubLeadDatum < ApplicationRecord
  module StatusIdentities
    PENDING = 0
    SYNCED = 1
  end

  belongs_to :fub_source, dependent: false

  def mark_pending
    self.sync_status_identity = StatusIdentities::PENDING
    self.save
  end

  def mark_synced
    self.sync_status_identity = StatusIdentities::SYNCED
    self.save
  end
end
