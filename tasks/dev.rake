# frozen_string_literal: true

namespace :server do
  desc "Start solr and fedora servers for testing"
  task :test do
    require 'solr_wrapper'
    require 'fcrepo_wrapper'
    SolrWrapper.wrap(shared_solr_opts.merge(port: 8984, instance_dir: 'tmp/blacklight-core-test')) do |solr|
      solr.with_collection(name: "blacklight-core-test", dir: Pathname.new(__dir__).join("..", "solr", "config").to_s) do
        FcrepoWrapper.wrap(shared_fedora_opts.merge(port: 8988, fcrepo_home_dir: "tmp/fcrepo4-test-data", version: "4.7.5", instance_directory: "tmp/fcrepo4")) do |_fcrepo|
          FcrepoWrapper::Instance.new(shared_fedora_opts.merge(port: 8998, fcrepo_home_dir: "tmp/fcrepo5-test-data", version: "5.0.0-RC-1", instance_directory: "tmp/fcrepo5")).wrap do |_other_repo|
            puts "Setup solr & Fedora"
            loop do
              sleep(1)
            end
          end
        end
      end
    end
  end

  desc "Cleanup test servers"
  task :clean_test do
    require 'solr_wrapper'
    require 'fcrepo_wrapper'
    SolrWrapper.instance(shared_solr_opts.merge(port: 8984, instance_dir: 'tmp/blacklight-core-test')).remove_instance_dir!
    FcrepoWrapper.default_instance(shared_fedora_opts.merge(port: 8988, fcrepo_home_dir: "tmp/fcrepo4-test-data", instance_directory: "tmp/fcrepo4")).remove_instance_dir!
    FcrepoWrapper::Instance.new(shared_fedora_opts.merge(port: 8998, fcrepo_home_dir: "tmp/fcrepo5-test-data", instance_directory: "tmp/fcrepo5")).remove_instance_dir!
    puts "Cleaned up test solr & fedora servers."
  end

  desc "Start solr and fedora servers for development"
  task :development do
    require 'solr_wrapper'
    require 'fcrepo_wrapper'

    SolrWrapper.wrap(shared_solr_opts.merge(port: 8983, instance_dir: 'tmp/blacklight-core')) do |solr|
      solr.with_collection(name: "blacklight-core", dir: Pathname.new(__dir__).join("..", "solr", "config").to_s) do
        FcrepoWrapper.wrap(shared_fedora_opts.merge(port: 8986, fcrepo_home_dir: "tmp/fcrepo4-dev-data", version: "4.7.5")) do |_fcrepo|
          FcrepoWrapper::Instance.new(shared_fedora_opts.merge(port: 8996, fcrepo_home_dir: "tmp/fcrepo5-dev-data", version: "5.0.0-RC-1")).wrap do |_fcrepo|
            puts "Setup solr & Fedora"
            loop do
              sleep(1)
            end
          end
        end
      end
    end
  end

  def shared_solr_opts
    opts = { managed: true, verbose: true, persist: false, download_dir: "tmp" }
    opts[:version] = ENV['SOLR_VERSION'] if ENV['SOLR_VERSION']
    opts
  end

  def shared_fedora_opts
    opts = { managed: true, verbose: true, enable_jms: false, download_dir: "tmp" }
    opts
  end
end
