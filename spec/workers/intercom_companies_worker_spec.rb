require 'rails_helper'

RSpec.describe IntercomCompaniesWorker, :vcr do
  let(:instance) { IntercomCompaniesWorker.new }
  describe '#perform' do
    subject { instance.perform(1, 10) }

    it 'creates sync events' do
      instance.should_receive(:process_user).exactly(10).times
      subject
    end

    it 'does not creates a company' do
      instance.perform(1, 1)
      expect(Company.all.length).to eq 0
    end
  end

  describe '#process_user' do
    let(:company_name) {
      "Ursula and Associates | Keller Williams Realty Partners"
    }
    let(:custom_attributes) {
      {
        "domains"=>"callursula.com",
        "stripe_id"=>"cus_7MX5Y5gda135Eb",
        "stripe_account_balance"=>0.0,
        "stripe_delinquent"=>false,
        "stripe_plan_price"=>1275.0,
        "stripe_plan_interval"=>"month",
        "stripe_plan"=>"One Platform",
        "stripe_subscription_period_start_at"=>1468679704,
        "stripe_subscription_status"=>"active",
        "stripe_card_expires_at"=>1617148800,
        "stripe_card_brand"=>"American Express",
        "stripe_last_charge_at"=>1468683398,
        "stripe_last_charge_amount"=>1275.0,
        "company_name"=>"\"#{company_name}\"",
        "company_phone"=>"678-569-4044 | KW Office: 678-494-0644",
        "company_email"=>"ursula@callursula.com",
        "company_address"=>"\"220 Heritage Walk, Suite 101, Woodstock, GA 30188\"",
        "company_facebook"=>"\"https://www.facebook.com/TeamUrsulaRealEstate/?fref=ts\"",
        "company_twitter"=>"\"https://twitter.com/ursulakd\"",
        "company_linkedin"=>"\"https://www.linkedin.com/in/ursuladahle/\"",
        "company_google_plus"=>"\"https://plus.google.com/u/0/+UrsulaandAssociates/posts\"",
        "company_youtube"=>"\"https://www.youtube.com/channel/UCqQXx1ahN7nzOl4OLGsXnvA\"",
        "company_pinterest"=>"\"\"",
        "company_instagram"=>"\"\"",
        "company_snapchat"=>"\"\""
      }
    }
    let(:intercom_user) {
      instance.intercom_client
        .users.create(email: "bob@example.com", name: "Bob Smith",
                      custom_attributes: custom_attributes)
    }

    subject { instance.process_user(intercom_user) }

    context 'with intercom company' do
      before do
        instance.intercom_client
          .companies.create({:company_id => 6, :name => company_name,
                             :custom_attributes => {
                               :referral_source => "Google"
                             }})
      end

      it 'creates company based on intercom company' do
        subject
        company = Company.find_by company_identifier: '6'
        user = User.find_by(email: 'bob@example.com')
        expect(user).not_to be_nil
        expect(company).not_to be_nil
        expect(user.companies.first.id).to eq company.id
        expect(company.name).to eq company_name
        data = company.data.find_by(name: 'referral_source')
        expect(data).not_to be_nil
        expect(data.value).to eq 'Google'
      end
    end

    context 'without intercom company' do
      let(:company_name) {
        "Ursula and Associates"
      }

      it 'creates company based on intercom company' do
        subject
        company = Company.find_by name: company_name
        intercom_company = instance.intercom_client.companies
                             .find :name => company_name
        expect(company).not_to be_nil
        expect(company.name).to eq company_name
        expect(company.phone_data.value).to eq '678-569-4044 | KW Office: 678-494-0644'
        expect(company.email_data.value).to eq 'ursula@callursula.com'
        expect(company.address_data.value).to eq '220 Heritage Walk, Suite 101, Woodstock, GA 30188'
        expect(company.facebook_data.value).to eq 'https://www.facebook.com/TeamUrsulaRealEstate/?fref=ts'
        expect(company.twitter_data.value).to eq 'https://twitter.com/ursulakd'
        expect(company.linkedin_data.value).to eq 'https://www.linkedin.com/in/ursuladahle/'
        expect(company.google_plus_data.value).to eq 'https://plus.google.com/u/0/+UrsulaandAssociates/posts'
        expect(company.youtube_data.value).to eq 'https://www.youtube.com/channel/UCqQXx1ahN7nzOl4OLGsXnvA'
        expect(company.pinterest_data).to be_nil
        expect(company.instagram_data).to be_nil
        expect(company.snapchat_data).to be_nil
        expect(intercom_company.custom_attributes.keys)
          .to include('phone', 'email', 'address', 'facebook', 'twitter',
                      'linkedin', 'google_plus', 'youtube')
      end
    end
  end
end
