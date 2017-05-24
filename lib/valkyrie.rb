# frozen_string_literal: true
module Valkyrie
  def config
    Config.new(
      YAML.safe_load(ERB.new(File.read(Rails.root.join("config", "valkyrie.yml"))).result)[Rails.env]
    )
  end

  class Config < OpenStruct
    def adapter
      Valkyrie::Adapter.find(super.to_sym)
    end

    def storage_adapter
      Valkyrie::FileRepository.find(super.to_sym)
    end
  end

  module_function :config
end
