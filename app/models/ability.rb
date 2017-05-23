# frozen_string_literal: true
class Ability
  include Hydra::Ability

  def custom_permissions; end

  def read_permissions
    super
    can :read, Valkyrie::Model do |obj|
      !(user_groups & obj.read_groups).empty? || obj.read_users.include?(current_user.user_key)
    end
  end
end
