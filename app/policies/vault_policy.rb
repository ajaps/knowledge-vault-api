class VaultPolicy < applicationPolicy
  def show?
    record.accessible_by?(user)
  end

  def update?
    record.editable_by?(user)
  end

  def destroy?
    record.user_id = user.id
  end

  def create?
    true
  end

  class Scope < Scope
    def resolve
      @scope.where("user_id = ? OR id IN (?)", @user.id, Membership.where(user_id: @user.id).select(:vault_id))
    end
  end
end