namespace :intercom do
  desc "Daily sync"
  task :save_segments => :environment do |t, args|
    Rails.logger.info 'Saving segments ...'
    IntercomSegmentsWorker.new.save_segments
    Rails.logger.info 'Segments Saved !!'
  end
end
