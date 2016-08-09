namespace :fub_users do
  desc "Sync Follow Up Leads"
  task :sync_clients, [:all] => :environment do |t, args|
    task_params = args.to_hash
    all = task_params.fetch(:all, false)
    Rails.logger.info 'Syncing events ...'
    ChurnburnerApi::FubClientsManager.instance.sync all
    Rails.logger.info 'Segments Synced !!'
  end

  desc "Loop for Sync Follow Up Leads"
  task :sync_clients_worker => :environment do |t, args|
    Rails.logger.info "Pending ...."
  end
end
