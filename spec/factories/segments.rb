FactoryGirl.define do
  factory :segment do
    trait :default do
      transient do
        suffix "1"
      end

      after(:create) do |segment, evaluator|
        segment.name = "Segment #{evaluator.suffix}"
        segment.intercom_id = "itercom_segment_#{evaluator.suffix}"
      end
    end
  end
end
