namespace :events do
  desc "Sync events"
  task :sync, [:all, :resend] => :environment do |t, args|
    task_params = args.to_hash
    all = task_params.fetch(:all, false)
    resend = task_params.fetch(:resend, false)
    Rails.logger.info 'Syncing events ...'
    ChurnburnerApi::EventsManager.instance.sync all, resend
    Rails.logger.info 'Segments Synced !!'
  end

  desc "Loop for sync events"
  task :sync_worker => :environment do |t, args|
    Rails.logger.info "Starting events daemon..."
    loop do
      Rails.logger.info 'Syncing events ...'
      begin
        ChurnburnerApi::EventsManager.instance.sync false, false
      rescue => e
        Rails.logger.error e.backtrace
      end
      Rails.logger.info 'Segments Synced !!'
      sleep 30
    end
  end
end
