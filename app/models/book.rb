class Book
  include Virtus
  include Valkyrie::ActiveModel
  attribute :id, String
  attribute :title, NonBlankArray
end
