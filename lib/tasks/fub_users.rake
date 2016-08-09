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

  desc "Import FUB users from CSV"
  task :import_csv_fub_clients, [:data_file] => :environment do |t, args|
    task_params = args.to_hash
    data_file = task_params.fetch(:data_file, 'fub_contacts.csv')
    path = File.join(Rails.root, 'data', data_file)
    Rails.logger.info "Processing #{data_file}"
    ChurnburnerApi::FubClientsETL.instance.import_csv path
    Rails.logger.info "#{data_file} processed!"
  end
end
