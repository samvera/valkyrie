# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Persister' do |*flags|
  before do
    raise 'persister must be set with `let(:persister)`' unless defined? persister
    class CustomResource < Valkyrie::Resource
      include Valkyrie::Resource::AccessControls
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
      attribute :author
      attribute :member_ids
      attribute :nested_resource
      attribute :single_value, Valkyrie::Types::String.optional
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  subject { persister }
  let(:resource_class) { CustomResource }
  let(:resource) { resource_class.new }

  it { is_expected.to respond_to(:save).with_keywords(:resource) }
  it { is_expected.to respond_to(:save_all).with_keywords(:resources) }
  it { is_expected.to respond_to(:delete).with_keywords(:resource) }

  it "can save a resource" do
    expect(resource).not_to be_persisted
    saved = persister.save(resource: resource)
    expect(saved).to be_persisted
    expect(saved.id).not_to be_blank
  end

  it "can save multiple resources at once" do
    resource2 = resource_class.new
    results = persister.save_all(resources: [resource, resource2])

    expect(results.map(&:id).uniq.length).to eq 2
  end

  it "can save nested resources" do
    book2 = resource_class.new(title: "Nested")
    book3 = persister.save(resource: resource_class.new(nested_resource: book2))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.first.title).to eq ["Nested"]
  end

  it "can persist single values" do
    resource.single_value = "A single value"

    output = persister.save(resource: resource)

    expect(output.single_value).to eq "A single value"
  end

  it "can mix properties with nested resources" do
    pending "No support for mixed nesting." if flags.include?(:no_mixed_nesting)
    book2 = resource_class.new(title: "Nested", id: SecureRandom.uuid)
    book3 = persister.save(resource: resource_class.new(nested_resource: [book2, "Alabama"]))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.map { |x| x.try(:title) }).to include ["Nested"]
    expect(reloaded.nested_resource).to include "Alabama"
  end

  it "can support deep nesting of resources" do
    pending "No support for deep nesting." if flags.include?(:no_deep_nesting)
    book = resource_class.new(title: "Sub-nested", author: [Valkyrie::ID.new("test"), RDF::Literal.new("Test", language: :fr), RDF::URI("http://test.com")])
    book2 = resource_class.new(title: "Nested", nested_resource: book)
    book3 = persister.save(resource: resource_class.new(nested_resource: book2))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.first.title).to eq ["Nested"]
    expect(reloaded.nested_resource.first.nested_resource.first.title).to eq ["Sub-nested"]
    expect(reloaded.nested_resource.first.nested_resource.first.author).to contain_exactly Valkyrie::ID.new("test"), RDF::Literal.new("Test", language: :fr), RDF::URI("http://test.com")
  end

  it "stores created_at/updated_at" do
    book = persister.save(resource: resource_class.new)
    book.title = "test"
    book = persister.save(resource: book)
    expect(book.created_at).not_to be_blank
    expect(book.updated_at).not_to be_blank
    expect(book.created_at).not_to be_kind_of Array
    expect(book.updated_at).not_to be_kind_of Array
  end

  it "can handle Boolean RDF properties" do
    boolean_rdf = RDF::Literal.new(false)
    book = persister.save(resource: resource_class.new(title: [boolean_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly boolean_rdf
  end

  it "can handle custom-typed RDF properties" do
    custom_rdf = RDF::Literal.new("Test", datatype: RDF::URI.parse("http://my_made_up_type"))
    book = persister.save(resource: resource_class.new(title: [custom_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly custom_rdf
  end

  it "can handle Date RDF properties" do
    date_rdf = RDF::Literal.new(Date.current)
    book = persister.save(resource: resource_class.new(title: [date_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly date_rdf
  end

  it "can handle DateTime RDF properties" do
    datetime_rdf = RDF::Literal.new(DateTime.current)
    book = persister.save(resource: resource_class.new(title: [datetime_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly datetime_rdf
  end

  it "can handle Decimal RDF properties" do
    decimal_rdf = RDF::Literal.new(BigDecimal(5.5, 10))
    book = persister.save(resource: resource_class.new(title: [decimal_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly decimal_rdf
  end

  it "can handle Double RDF properties" do
    double_rdf = RDF::Literal.new(5.5)
    book = persister.save(resource: resource_class.new(title: [double_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly double_rdf
  end

  it "can handle Integer RDF properties" do
    int_rdf = RDF::Literal.new(17)
    book = persister.save(resource: resource_class.new(title: [int_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly int_rdf
  end

  it "can handle language-typed RDF properties" do
    language_rdf = RDF::Literal.new("Test", language: :fr)
    book = persister.save(resource: resource_class.new(title: ["Test1", language_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly "Test1", language_rdf
  end

  it "can handle Time RDF properties" do
    time_rdf = RDF::Literal.new(Time.current)
    book = persister.save(resource: resource_class.new(title: [time_rdf]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly time_rdf
  end

  #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
  it "can store booleans" do
    boolean = [false, true]
    book = persister.save(resource: resource_class.new(title: boolean))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly(*boolean)
  end

  # Pending date support in Valkyrie
  #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
  xit "can store Dates" do
    date = Date.current
    book = persister.save(resource: resource_class.new(title: [date]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly date
  end

  it "can store DateTimes" do
    time1 = DateTime.current
    time2 = Time.current.in_time_zone
    book = persister.save(resource: resource_class.new(title: [time1], author: [time2]))

    reloaded = query_service.find_by(id: book.id)

    expect(reloaded.title.first.to_i).to eq(time1.to_i)
    expect(reloaded.title.first.zone).to eq('UTC')
    expect(reloaded.author.first.to_i).to eq(time2.to_i)
    expect(reloaded.author.first.zone).to eq('UTC')
  end

  # Pending decimals support in Valkyrie
  #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
  xit "can store Decimals" do
    decimal = BigDecimal(5.5, 10)
    book = persister.save(resource: resource_class.new(title: [decimal]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly decimal
  end

  # Pending doubles support in Valkyrie
  #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
  xit "can store doubles" do
    book = persister.save(resource: resource_class.new(title: [1.5]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly 1.5
  end

  it "can store integers" do
    book = persister.save(resource: resource_class.new(title: [1]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly 1
  end

  # Pending time support in Valkyrie
  #  currently millisecond precision is lost is postgres and solr
  #
  #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
  xit "can store Times" do
    time = Time.current
    book = persister.save(resource: resource_class.new(title: [time]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly time.utc
  end

  it "can store ::RDF::URIs" do
    book = persister.save(resource: resource_class.new(title: [::RDF::URI("http://example.com")]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly RDF::URI("http://example.com")
  end

  it "can store Valkyrie::IDs" do
    shared_title = persister.save(resource: resource_class.new(id: "test"))
    book = persister.save(resource: resource_class.new(title: [shared_title.id, Valkyrie::ID.new("adapter://1"), "test"]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly(shared_title.id, Valkyrie::ID.new("adapter://1"), "test")
    expect([shared_title.id, Valkyrie::ID.new("adapter://1"), "test"]).to contain_exactly(*reloaded.title)
  end

  it "can override default id generation with a provided id" do
    id = SecureRandom.uuid
    book = persister.save(resource: resource_class.new(id: id))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.id).to eq Valkyrie::ID.new(id)
    expect(reloaded).to be_persisted
    expect(reloaded.created_at).not_to be_blank
    expect(reloaded.updated_at).not_to be_blank
    expect(reloaded.created_at).not_to be_kind_of Array
    expect(reloaded.updated_at).not_to be_kind_of Array
  end

  context "parent tests" do
    let(:book) { persister.save(resource: resource_class.new) }
    let(:book2) { persister.save(resource: resource_class.new) }

    it "can order members" do
      book3 = persister.save(resource: resource_class.new)
      parent = persister.save(resource: resource_class.new(member_ids: [book2.id, book.id]))
      parent.member_ids = parent.member_ids + [book3.id]
      parent = persister.save(resource: parent)
      reloaded = query_service.find_by(id: parent.id)
      expect(reloaded.member_ids).to eq [book2.id, book.id, book3.id]
    end

    it "can remove members" do
      parent = persister.save(resource: resource_class.new(member_ids: [book2.id, book.id]))
      parent.member_ids = parent.member_ids - [book2.id]
      parent = persister.save(resource: parent)
      expect(parent.member_ids).to eq [book.id]
    end
  end

  it "doesn't override a resource that already has an ID" do
    book = persister.save(resource: resource_class.new)
    id = book.id
    output = persister.save(resource: book)
    expect(output.id).to eq id
  end

  it "can find that resource again" do
    id = persister.save(resource: resource).id
    expect(query_service.find_by(id: id)).to be_kind_of resource_class
  end

  it "can delete objects" do
    persisted = persister.save(resource: resource)
    persister.delete(resource: persisted)
    expect { query_service.find_by(id: persisted.id) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
  end

  it "can delete all objects" do
    resource2 = resource_class.new
    persister.save_all(resources: [resource, resource2])
    persister.wipe!
    expect(query_service.find_all.to_a.length).to eq 0
  end
end
