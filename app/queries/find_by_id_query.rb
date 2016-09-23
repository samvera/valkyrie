class FindByIdQuery
  attr_reader :klass, :id
  def initialize(klass, id)
    @klass = klass
    @id = id
  end

  def run
    Persister.cache[id] || raise(::Persister::ObjectNotFoundError)
  end
end
