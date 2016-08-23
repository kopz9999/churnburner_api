namespace :intercom do
  desc "Initial load of users and segments"
  task :save_segments => :environment do |t, args|
    Rails.logger.info 'Saving segments ...'
    IntercomSegmentsWorker.instance.save_segments
    Rails.logger.info 'Segments Saved !!'
  end

  desc "Sync segments and send notifications"
  task :process_segments => :environment do |t, args|
    Rails.logger.info "Starting daemon..."
    loop do
      Rails.logger.info 'Syncing segments ...'
      begin
        IntercomSegmentsWorker.instance.perform
        IntercomSegmentsWorker.instance.segments.clear
      rescue => e
        Rails.logger.error e.backtrace
      end
      Rails.logger.info 'Segments Synced !!'
      sleep 30
    end
  end

  desc "Update jobs from Intercom"
  task :jobs_sync => :environment do |t, args|
    Rails.logger.info "Starting jobs daemon..."
    loop do
      Rails.logger.info 'Syncing jobs ...'
      begin
        ChurnburnerApi::IntercomJobsManager.instance.process
      rescue => e
        Rails.logger.error e.backtrace
      end
      Rails.logger.info 'Jobs Synced !!'
      sleep 30
    end
  end

  namespace :companies do
    desc "Set intercom companies from user custom_attributes"
    task :process_from_user => :environment do |t, args|
      Rails.logger.info 'Setting intercom companies ...'
      ChurnburnerApi::IntercomCompaniesManager.instance.process
      Rails.logger.info 'Companies synced!!'
    end

    desc "Pull down companies and set them into intercom"
    task :process_stats => :environment do |t, args|
      Rails.logger.info 'Sending company stats to intercom ...'
      ChurnburnerApi::IntercomCompaniesManager.instance.process_stats
      Rails.logger.info 'Company stats synced!!'
    end

    # TODO: Retry when tasks done
    desc "Pull down companies and set them into intercom worker"
    task :process_stats_worker, [:minutes] => :environment  do |t, args|
      task_params = args.to_hash
      group_size = task_params.fetch(:group_size, '5').to_i
      minutes = task_params.fetch(:minutes, '1').to_i
      Rails.logger.info "Params: #{task_params}"
      Rails.logger.info "Starting fub clients daemon..."
      loop do
        Rails.logger.info 'Sending company stats to intercom ...'
        begin
          ChurnburnerApi::IntercomCompaniesManager.instance
            .process_delayed_stats(group_size, minutes)
        rescue => e
          Rails.logger.error e.backtrace
        end
        Rails.logger.info 'Company stats synced!!'
      end
    end
  end

  desc "Import companies from FUB CSV"
  task :import_csv_fub_companies, [:data_file] => :environment do |t, args|
    task_params = args.to_hash
    data_file = task_params.fetch(:data_file, 'fub_companies.csv')
    path = File.join(Rails.root, 'data', data_file)
    Rails.logger.info "Processing #{data_file}"
    ChurnburnerApi::ETL::IntercomCompanies.instance.import_csv path
    Rails.logger.info "#{data_file} processed!"
  end
end
