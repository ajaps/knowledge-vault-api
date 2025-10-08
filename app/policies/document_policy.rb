class DocumentPolicy < applicationPolicy
  def show?
    record.vault.accessible_by?(user)
  end

  def update?
    record.editable_by_by?(user)
  end

  def destroy?
    update?
  end

  def create?
    update?
  end
end