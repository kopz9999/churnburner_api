require 'rails_helper'

RSpec.describe ChurnburnerApi::IntercomCompaniesManager, :vcr do
  let(:instance) { described_class.instance }

  describe '#process' do
    subject { instance.process }

    it 'paginates' do
      IntercomCompaniesWorker.should_receive(:perform_async).exactly(13).times
      subject
    end
  end
end
