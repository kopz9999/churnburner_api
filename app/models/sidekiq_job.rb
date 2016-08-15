class SidekiqJob < ApplicationRecord
  belongs_to :parent, class_name: 'SidekiqJob', foreign_key: :job_id,
             optional: true
  has_many :children, class_name: 'SidekiqJob', foreign_key: :job_id
  belongs_to :app_task, optional: true
end
