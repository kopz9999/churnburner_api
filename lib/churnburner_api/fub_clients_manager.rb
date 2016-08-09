module ChurnburnerApi
  class FubClientsManager
    include Singleton

    def sync(all = false)
      Rails.logger.info "Processing Follow Up Boss companies"
      users = Fub::User.default_active.joins(:default_user_companies)
      users.each { |user| FubClientsWorker.perform_async(user.id, all) }
      Rails.logger.info "Finished Processing Follow Up Boss companies"
    end
  end
end
