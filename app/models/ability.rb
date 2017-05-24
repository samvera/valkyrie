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
    group_readable?(obj) || user_readable?(obj)
  end

  def group_readable?(obj)
    (user_groups & obj.read_groups).any?
  end

  def user_readable?(obj)
    obj.read_users.include?(current_user.user_key)
  end

  def valkyrie_test_edit(obj)
    group_editable?(obj) || user_editable?(obj)
  end

  def group_editable?(obj)
    (user_groups & obj.edit_groups).any?
  end

  def user_editable?(obj)
    obj.edit_users.include?(current_user.user_key)
  end
end
