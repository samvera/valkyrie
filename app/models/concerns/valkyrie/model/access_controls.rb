# frozen_string_literal: true
module Valkyrie
  class Model
    module AccessControls
      def self.included(klass)
        klass.attribute :read_groups, Valkyrie::Types::Set
        klass.attribute :read_users, Valkyrie::Types::Set
        klass.attribute :edit_users, Valkyrie::Types::Set
        klass.attribute :edit_groups, Valkyrie::Types::Set
      end
    end
  end
end
