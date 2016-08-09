FactoryGirl.define do
  factory :company do
    trait :default do
      transient do
        intercom_id "1"
      end

      after(:create) do |company, evaluator|
        company.name = "Company #{evaluator.intercom_id}"
        company.company_identifier = evaluator.intercom_id
        company.create_phone_data value: '971-321-3242'
        company.save
      end
    end
  end
end
