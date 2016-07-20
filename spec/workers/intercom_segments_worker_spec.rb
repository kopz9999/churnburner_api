require 'rails_helper'

RSpec.describe IntercomSegmentsWorker, :vcr do
  let(:instance) { IntercomSegmentsWorker.new }
  let(:segment_names) { ['Active', 'New', 'Slipping Away'] }

  describe '#save_segments' do
    subject do
      instance.save_segments
    end

    it 'stores users' do
      subject
      segment_names.each do |segment_name|
        s = Segment.find_by(name: segment_name)
        expect(s).not_to be_nil
      end
      active_segment = Segment.find_by(name: 'Active')
      expect(active_segment.users.first.email).to eq 'lashandra@yahoo.com'
    end
  end

  describe '#sync_segments' do
    subject do
      instance.sync_segments
    end
    context 'with users' do

    end
  end
end

