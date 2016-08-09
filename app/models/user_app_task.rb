class UserAppTask < ApplicationRecord
  belongs_to :user
  belongs_to :app_task
end
