require 'rails_helper'

RSpec.describe FubLeadsWorker, :vcr do
  let(:instance) { described_class.new }
  let(:fub_user) {
    create :fub_user, :default,
           api_key: ENV['FUB_API_KEY']
  }
  let(:company) {
    create :company, :default, intercom_id: '32132'
  }
  let(:intercom_client) {
    instance.intercom_client
  }
  before do
    fub_user.user_companies.create(default: true, company: company)
  end

  describe '#perform' do
    subject { instance.perform fub_user.id, nil, 1, 10 }

    it 'creates fub leads correctly' do
      subject
      users = Fub::Person.joins(:user_companies)
                .where('user_companies.company_id = ?', company.id)
      expect(users.length).to eq 10
      users.each do |user|
        expect(user.default_company.id).to eq company.id
      end
    end

    it 'creates fub leads correctly in intercom' do
      subject
      intercom_company = instance.intercom_client.companies
                           .find(:company_id => company.company_identifier)
      intercom_users = intercom_client.companies.users(intercom_company.id)
      intercom_users.each do |u|
        person = Fub::Person.all.select{ |p| p.email == u.email }.first
        expect(person).not_to be_nil
      end
    end

    context 'with app task' do
      let(:last_task) do
        AppTask.create(name: 'fub_clients',
                       ran_at: Time.parse('2016-07-09T10:54:21Z'),
                       status_identity: AppTask::SUCCESS)
      end

      subject { instance.perform fub_user.id, last_task.id, 1, 10 }

      before do
        fub_user.user_app_tasks.create app_task: last_task
      end

      it 'creates fub leads correctly' do
        subject
        users = Fub::Person.joins(:user_companies)
                  .where('user_companies.company_id = ?', company.id)
        expect(users.length).to eq 10
      end
    end
  end
end
