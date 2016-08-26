class Mapper
  ## Find a mapper for a given object
  def self.find(obj)
    self.new(obj)
  end

  attr_reader :object
  def initialize(object)
    @object = object
  end

  def to_h
    {
      "id": object.id,
      "title_ssim": object.title
    }
  end
end
