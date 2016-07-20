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
      expect(User.all.length).to eq 1
      active_segment = Segment.find_by(name: 'Active')
      expect(active_segment.users.length).to eq 1
      expected_user = active_segment.users.first
      expect(expected_user.email).to eq 'lashandra@yahoo.com'
      expect(expected_user.name).to eq 'Lashandra'
    end
  end

  describe '#sync_segments' do
    subject do
      instance.sync_segments
    end
    context 'with users added' do
      it 'notifies about the user' do
        subject
      end
    end
    context 'with users out' do
      it 'notifies about the user' do

      end
    end
    context 'without changes' do
      it 'notifies about the user' do

      end
    end
  end
end

