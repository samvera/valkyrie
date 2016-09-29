module ORM
  class Book
    include NoBrainer::Document
    (::Book.attribute_set.map(&:name) - [:id]).each do |attribute|
      field attribute, type: Array
    end
  end
end
