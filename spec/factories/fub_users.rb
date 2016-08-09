FactoryGirl.define do
  factory :fub_user, :class => Fub::User do
    fub_client true
    trait :intercom do
      transient do
        suffix "1"
        api_key "key"
      end

      after(:create) do |fub_user, evaluator|
        fub_user.name = "FUB User #{evaluator.suffix}"
        fub_user.email = "fub_user_#{evaluator.suffix}@gmail.com"
        fub_user.api_key = evaluator.api_key
        fub_user.save
        fub_user.fub_client_datum.save
      end
    end

    trait :default do
      transient do
        suffix "1"
        api_key "key"
      end

      after(:create) do |fub_user, evaluator|
        fub_user.name = "FUB User #{evaluator.suffix}"
        fub_user.email = "fub_user_#{evaluator.suffix}@gmail.com"
        fub_user.intercom_id = "fub_intercom_user_#{evaluator.suffix}"
        fub_user.api_key = evaluator.api_key
        fub_user.save
        fub_user.fub_client_datum.save
      end
    end
  end
end
