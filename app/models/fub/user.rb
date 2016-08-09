module Fub
  class User < ::User
    default_scope { where(fub_client: true) }
    scope :default_active, -> {
      joins(:fub_client_datum).where('fub_client_data.active = true')
    }

    has_one :fub_client_datum
    has_many :user_app_tasks
    has_many :app_tasks, through: :user_app_tasks

    delegate :api_key, :api_key=, :active?, :active=, to: :fub_client_datum

    after_create :create_fub_client_datum
  end
end
