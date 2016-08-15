FactoryGirl.define do
  factory :app_task do
    trait :running do
      name :running
      ran_at Time.now
      status_identity 2
    end

    trait :success do
      name :success
      ran_at Time.now
      status_identity 1
    end

    trait :fail do
      name :fail
      ran_at Time.now
      status_identity 0
    end
  end
end
