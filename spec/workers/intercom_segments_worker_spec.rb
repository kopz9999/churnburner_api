require 'rails_helper'

RSpec.describe IntercomSegmentsWorker, :vcr do
  let(:instance) { IntercomSegmentsWorker.new }
  describe '#save_segments' do
    subject do
      instance.save_segments
    end

    it 'stores users' do
      subject
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

