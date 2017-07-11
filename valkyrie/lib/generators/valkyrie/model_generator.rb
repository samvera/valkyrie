# frozen_string_literal: true
require 'rails/generators'
require 'rails/generators/model_helpers'

class Valkyrie::ModelGenerator < Rails::Generators::NamedBase
  # Include ModelHelpers to warn about pluralization when generating new models or scaffolds
  include Rails::Generators::ModelHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: 'field:type field:type'

  def create_model
    template('model.rb.erb', File.join('app/models', class_path, "#{file_name}.rb"))
  end

  def create_model_spec
    return unless rspec_installed?
    template('model_spec.rb.erb', File.join('spec/models', class_path, "#{file_name}_spec.rb"))
  end

  private

    def rspec_installed?
      defined?(RSpec) && defined?(RSpec::Rails)
    end
end
