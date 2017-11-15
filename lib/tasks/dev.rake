# frozen_string_literal: true

namespace :server do
  desc "Start solr and fedora servers for testing"
  task :test do
    require 'solr_wrapper'
    require 'fcrepo_wrapper'
    SolrWrapper.wrap(shared_solr_opts.merge(port: 8984, instance_dir: 'tmp/blacklight-core-test')) do |solr|
      solr.with_collection(name: "blacklight-core-test", dir: Rails.root.join("solr", "config").to_s) do
        SolrWrapper.wrap(shared_solr_opts.merge(port: 8985, instance_dir: 'tmp/hydra-test')) do |solr2|
          solr2.with_collection(name: "hydra-test", dir: Rails.root.join("solr", "config").to_s) do
            FcrepoWrapper.wrap(shared_fedora_opts.merge(port: 8988, fcrepo_home_dir: "tmp/fcrepo4-test-data")) do |_fcrepo|
              puts "Setup two solr servers & Fedora"
              loop do
                sleep(1)
              end
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
    SolrWrapper.instance(shared_solr_opts.merge(port: 8985, instance_dir: 'tmp/hydra-test')).remove_instance_dir!
    FcrepoWrapper.default_instance(shared_fedora_opts.merge(port: 8988, fcrepo_home_dir: "tmp/fcrepo4-test-data")).remove_instance_dir!
    puts "Cleaned up test solr & fedora servers."
  end

  desc "Start solr and fedora servers for development"
  task :development do
    require 'solr_wrapper'
    require 'fcrepo_wrapper'

    SolrWrapper.wrap(shared_solr_opts.merge(port: 8983, instance_dir: 'tmp/blacklight-core')) do |solr|
      solr.with_collection(name: "blacklight-core", dir: Rails.root.join("solr", "config").to_s) do
        SolrWrapper.wrap(shared_solr_opts.merge(port: 8987, instance_dir: 'tmp/hydra-dev')) do |solr2|
          solr2.with_collection(name: "hydra-dev", dir: Rails.root.join("solr", "config").to_s) do
            FcrepoWrapper.wrap(shared_fedora_opts.merge(port: 8986, fcrepo_home_dir: "fcrepo4-dev-data")) do |_fcrepo|
              puts "Setup two solr servers & Fedora"
              loop do
                sleep(1)
              end
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
    opts[:version] = ENV['FCREPO_VERSION'] if ENV['FCREPO_VERSION']
    opts
  end
end
