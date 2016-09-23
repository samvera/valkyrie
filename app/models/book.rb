class Book
  include Virtus.model
  include Valkyrie::ActiveModel
  attribute :id, String
  attribute :title, NonBlankArray
end
