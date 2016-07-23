require 'rails_helper'

RSpec.describe IntercomSegmentsWorker, :vcr do
  let(:instance) { IntercomSegmentsWorker.send(:new) }
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
    let(:user_a) { create :user, :default, suffix: 'a' }
    let(:user_b) { create :user, :default, suffix: 'b' }
    let(:user_intercom) do
      create :user, :intercom, suffix: 'intercom',
             intercom_id: '578e6f8f6f121013c400005d'
    end
    let(:segment) { create :segment, :intercom, suffix: 'intercom',
                           intercom_id: '578d08799b659c1d84000023' }

    subject do
      instance.sync_segments
    end

    before do
      segment
    end

    context 'with users added' do
      before do
        user_intercom
        SegmentUser.create segment: segment, user: user_a
      end

      it 'notifies about the user' do
        subject
        s = instance.segments.first
        expect(s.new_users.length).to eq 1
        expect(s.new_users).to include(user_intercom)
      end
    end
    context 'with users out' do
      before do
        SegmentUser.create segment: segment, user: user_b
      end

      it 'notifies about the user' do
        subject
        s = instance.segments.first
        expect(s.removed_users.length).to eq 1
        expect(s.removed_users).to include(user_b)
      end
    end
    context 'without changes' do
      before do
        user_intercom
        SegmentUser.create segment: segment, user: user_intercom
      end

      it 'notifies about the user' do
        subject
        s = instance.segments.first
        expect(s.new_users.length).to eq 0
        expect(s.removed_users.length).to eq 0
        expect(s.users.to_a).to include(user_intercom)
      end
    end
  end

  describe '#notify_segment_users' do
    let(:segment) { create :segment, :default }
    let(:user) { create :user, :default }
    let(:instance) do
      iw = IntercomSegmentsWorker.send(:new)
      iw.segments << segment
      iw
    end

    subject do
      instance.notify_segment_users
    end

    context 'with new users' do
      before do
        segment.new_users << user
      end

      it 'receives correct arguments' do
        text = "User User 1 (user_1@gmail.com) was added to "+
          "segment Segment 1"
        expected_arguments = {channel: '#churnburner-box',
                              as_user: false,
                              text: text}
        expect(instance.slack_client)
          .to receive(:chat_postMessage).with(expected_arguments)
        subject
      end

      it 'calls slack' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with removed_users' do
      before do
        segment.removed_users << user
      end

      it 'receives correct arguments' do
        text = "User User 1 (user_1@gmail.com) was removed from "+
          "segment Segment 1"
        expected_arguments = {channel: '#churnburner-box',
                              as_user: false,
                              text: text}
        expect(instance.slack_client)
          .to receive(:chat_postMessage).with(expected_arguments)
        subject
      end

      it 'calls slack' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'without changes' do
      it 'does not calls slack' do
        expect(instance).not_to receive(:slack_client)
        subject
      end
    end
  end
end

