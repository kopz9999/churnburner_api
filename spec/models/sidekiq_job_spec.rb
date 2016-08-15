require 'rails_helper'

RSpec.describe SidekiqJob, type: :model do
  let(:app_task) { create :app_task, :running }

  describe '#parent' do
    it 'has a parent' do
      parent = described_class.create
      child = described_class.create parent: parent, app_task: app_task
      expect(child.parent.id).to eq parent.id
    end
  end

  describe '#children' do
    it 'has children' do
      parent = described_class.create
      described_class.create parent: parent, app_task: app_task
      described_class.create parent: parent, app_task: app_task
      described_class.create parent: parent, app_task: app_task
      expect(parent.children.length).to eq 3
    end
  end
end
