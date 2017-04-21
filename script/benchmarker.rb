# frozen_string_literal: true
require 'benchmark'

num_children = 1000

# Pop off the indexing_persister  so we don't test it
Valkyrie::Adapter.adapters.to_a.each do |adapter_name, adapter|
  Benchmark.bm do |bench|
    parent = Book.new
    children = nil
    bench.report("#{adapter_name} create #{num_children} children") do
      children = Array.new(num_children) do |_page_num|
        Page.new
      end
      children = adapter.persister.save_all(models: children)
    end
    parent.member_ids = children.map(&:id)
    bench.report("#{adapter_name} save parent with #{num_children} children") do
      parent = adapter.persister.save(model: parent)
    end
    bench.report("#{adapter_name} reload parent with #{num_children} children") do
      parent = adapter.query_service.find_by(id: parent.id)
    end
    last_page = Page.new
    adapter.persister.save(model: last_page)
    bench.report("#{adapter_name} add one more page to a parent with #{num_children} existing children") do
      parent.member_ids += [last_page.id]
      parent = adapter.persister.save(model: parent)
    end
  end
end
