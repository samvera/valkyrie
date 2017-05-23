# frozen_string_literal: true
class Ability
  include Hydra::Ability

  def custom_permissions
    can :manage, Valkyrie::Model if current_user.admin?
    alias_action :file_manager, to: :update
  end

  def read_permissions
    super
    can :read, Valkyrie::Model do |obj|
      valkyrie_test_read(obj) || valkyrie_test_edit(obj)
    end
  end

  def edit_permissions
    super
    can [:edit, :update, :destroy], Valkyrie::Model do |obj|
      valkyrie_test_edit(obj)
    end
  end

  def valkyrie_test_read(obj)
    !(user_groups & obj.read_groups).empty? || obj.read_users.include?(current_user.user_key)
  end

  def valkyrie_test_edit(obj)
    !(user_groups & obj.edit_groups).empty? || obj.edit_users.include?(current_user.user_key)
  end
end
