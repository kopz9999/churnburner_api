require 'rails_helper'

RSpec.describe Segment, type: :model do
  let(:user_a) { create :user, :default, suffix: 'a' }
  let(:user_b) { create :user, :default, suffix: 'b' }
  let(:user_c) { create :user, :default, suffix: 'c' }
  let(:user_d) { create :user, :default, suffix: 'd' }
  let(:segment) { create :segment, :default }

  describe '#evaluate_users' do
    subject { segment.evaluate_users }

    before do
      SegmentUser.create(segment: segment, user: user_a)
      SegmentUser.create(segment: segment, user: user_b)
    end

    context 'with users added' do
      before do
        segment.add_current_user user_a
        segment.add_current_user user_b
        segment.add_current_user user_c
        segment.add_current_user user_d
      end

      it 'has new_users' do
        subject
        expect(segment.new_users.length).to eq 2
        expect(segment.new_users).to include(user_c, user_d)
      end
    end

    context 'with users out' do
      before do
        segment.add_current_user user_c
        segment.add_current_user user_d
      end

      it 'has removed_users and new_users' do
        subject
        expect(segment.new_users.length).to eq 2
        expect(segment.new_users).to include(user_c, user_d)
        expect(segment.removed_users.length).to eq 2
        expect(segment.removed_users).to include(user_a, user_b)
      end
    end

    context 'without changes' do
      before do
        segment.add_current_user user_a
        segment.add_current_user user_b
      end

      it 'has removed_users and new_users' do
        subject
        expect(segment.new_users.length).to eq 0
        expect(segment.removed_users.length).to eq 0
      end
    end
  end

  describe '#update_users' do
    subject { segment.update_users }
    before do
      SegmentUser.create(segment: segment, user: user_a)
      SegmentUser.create(segment: segment, user: user_b)
    end

    context 'with users added' do
      before do
        segment.new_users << user_c
      end

      it 'updates users' do
        subject
        segment.users.reload
        expect(segment.users.length).to eq 3
        expect(segment.users.to_a).to include(user_a, user_b, user_c)
      end
    end

    context 'with users added' do
      before do
        segment.removed_users << user_a
      end

      it 'updates users' do
        subject
        segment.users.reload
        expect(segment.users.length).to eq 1
        expect(segment.users.to_a).to include(user_b)
      end
    end
  end
end
