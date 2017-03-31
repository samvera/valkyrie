require 'benchmark'

num_children = 100

# Pop off the indexing_persister  so we don't test it
Valkyrie::Adapter.adapters.to_a[0..-2].each do |adapter_name, adapter|
  Benchmark.bm do |bench|
    parent = Book.new
    children = nil
    bench.report("#{adapter_name} create #{num_children} children") do
      children = num_children.times.map do |page_num|
        p = Page.new
        adapter.persister.save(p)
      end
    end
    parent.member_ids = children.map(&:id)
    bench.report("#{adapter_name} save parent with #{num_children} children") do
      parent = adapter.persister.save(parent)
    end
    bench.report("#{adapter_name} reload parent with #{num_children} children") do
      parent = adapter.query_service.find_by_id(parent.id)
    end
    last_page = Page.new
    adapter.persister.save(last_page)
    bench.report("#{adapter_name} add one more page to a parent with #{num_children} existing children") do
      parent.member_ids += [last_page.id]
      parent = adapter.persister.save(parent)
    end
  end
end
