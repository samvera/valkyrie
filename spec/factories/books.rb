# frozen_string_literal: true
FactoryGirl.define do
  factory :book do
    read_groups ['public']
    to_create do |instance|
      Valkyrie.config.metadata_adapter.persister.save(model: instance)
    end
  end
end
