class FubLeadDatum < ApplicationRecord
  module StatusIdentities
    PENDING = 0
    SYNCED = 1
  end

  def mark_pending
    self.sync_status_identity = StatusIdentities::PENDING
    self.save
  end

  def mark_synced
    self.sync_status_identity = StatusIdentities::SYNCED
    self.synced_at = Time.now
    self.save
  end
end
