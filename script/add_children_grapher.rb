# frozen_string_literal: true
require 'benchmark'
require 'gruff'

num_children = 1000

# Pop off the indexing_persister  so we don't test it
g = Gruff::Line.new
Valkyrie::Adapter.adapters.to_a.each do |adapter_name, adapter|
  i = Gruff::Line.new
  clean_name = adapter_name.to_s.tr(" ", "_")
  parent = adapter.persister.save(model: Book.new)
  create_page_times = []
  add_page_times = []
  num_children.times do |_child_number|
    page = nil
    create_page_times << Benchmark.measure do
      page = Page.new
      page = adapter.persister.save(model: page)
    end
    add_page_times << Benchmark.measure do
      parent = adapter.query_service.find_by(id: parent.id)
      parent.member_ids = parent.member_ids + [page.id]
      adapter.persister.save(model: parent)
    end
  end
  g.data("Create Page (#{clean_name})", create_page_times.map(&:real))
  g.data("Reload Parent & Add Page (#{clean_name})", add_page_times.map(&:real))
  i.data("Create Page", create_page_times.map(&:real))
  i.data("Reload Parent & Add Page", add_page_times.map(&:real))
  i.write("tmp/graph-#{clean_name}.png")
  puts "Wrote graph to tmp/graph-#{clean_name}.png"
  puts "Finished running benchmarks for #{clean_name}"
end
g.write("tmp/graph.png")
puts "Wrote graph to tmp/graph.png"
