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
end
