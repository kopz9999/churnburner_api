class SegmentUser < ApplicationRecord
  belongs_to :segment
  belongs_to :user
end
