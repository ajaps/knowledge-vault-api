class applicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def update?
    false
  end

  def new?
    create?
  end

  def create?
    false
  end

  def edit?
    update?
  end

  class Scope
    def initialize(user, scope)
      @user, @scope = user, scope
    end

    def resolve
      @scope.none
    end
  end
end