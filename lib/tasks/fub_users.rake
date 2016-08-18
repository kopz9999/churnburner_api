namespace :fub_users do
  desc "Sync Follow Up Leads"
  task :sync_clients, [:all] => :environment do |t, args|
    task_params = args.to_hash
    all = task_params.fetch(:all, false)
    Rails.logger.info 'Syncing follow up boss leads from clients ...'
    ChurnburnerApi::FubClientsManager.instance.sync all
    Rails.logger.info 'Leads Synced !!'
  end

  desc "Sync Follow Up Leads Worker"
  task :sync_clients_worker, [:minutes] => :environment do |t, args|
    task_params = args.to_hash
    minutes = task_params.fetch(:minutes, '60').to_i
    Rails.logger.info "Starting fub clients daemon..."
    loop do
      Rails.logger.info 'Syncing follow up boss leads from clients ...'
      begin
        ChurnburnerApi::FubClientsManager.instance.sync false
      rescue => e
        Rails.logger.error e.backtrace
      end
      Rails.logger.info 'Leads Synced !!'
      sleep (60*minutes)
    end
  end

  desc "Import FUB users from CSV"
  task :import_csv_fub_clients, [:data_file] => :environment do |t, args|
    task_params = args.to_hash
    data_file = task_params.fetch(:data_file, 'fub_users.csv')
    path = File.join(Rails.root, 'data', data_file)
    Rails.logger.info "Processing #{data_file}"
    ChurnburnerApi::ETL::FubClients.instance.import_csv path
    Rails.logger.info "#{data_file} processed!"
  end
end
