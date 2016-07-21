FactoryGirl.define do
  factory :user do
    trait :default do
      transient do
        suffix "1"
      end

      after(:create) do |user, evaluator|
        user.name = "User #{evaluator.suffix}"
        user.email = "user_#{evaluator.suffix}@gmail.com"
        user.intercom_id = "itercom_user_#{evaluator.suffix}"
      end
    end
  end
end
