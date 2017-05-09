# frozen_string_literal: true
# Benchmarks how many data migrations can be done per second, per adapter.
require 'benchmark/ips'

# Pop off the indexing_persister  so we don't test it
Benchmark.ips do |x|
  Valkyrie::Adapter.adapters.to_a.each do |adapter_name, adapter|
    object = adapter.persister.save(model: Book.new)
    x.report("Load/Change Title Value/Save (#{adapter_name})") do |times|
      object = adapter.query_service.find_by(id: object.id)
      object.title = times.to_s
      object = adapter.persister.save(model: object)
    end
  end
  x.compare!
end
