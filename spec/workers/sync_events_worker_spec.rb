require 'rails_helper'

RSpec.describe SyncEventsWorker, :vcr do
  let(:instance) { SyncEventsWorker.new }
  describe '#perform' do
    subject { instance.perform 1, 10 }

    it 'creates sync events' do
      subject
      sync_events = SyncEvent.all
      expect(sync_events.length).to eq 10
    end

    it 'creates users' do
      subject
      users = User.all
      expect(users.length).to eq 10
    end

    it 'creates job' do
      subject
      intercom_jobs = IntercomJob.all
      expect(intercom_jobs.length).to eq 1
    end
  end
end
