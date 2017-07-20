# frozen_string_literal: true
if Rails.env.development? || Rails.env.test?
  require "factory_girl"

  namespace :dev do
    desc "Sample data for local development environment"
    task prime: "db:setup" do
      include FactoryGirl::Syntax::Methods

      # create(:user, email: "user@example.com", password: "password")
    end
  end

  namespace :server do
    desc "Start solr and fedora servers for testing"
    task :test do
      fcrepo_opts = { managed: true, verbose: true, port: 8988, enable_jms: false, fcrepo_home_dir: "fcrepo4-test-data" }
      fcrepo_opts[:version] = ENV['FCREPO_VERSION'] if ENV['FCREPO_VERSION']
      shared_solr_opts = { managed: true, verbose: true, persist: false }
      shared_solr_opts[:version] = ENV['SOLR_VERSION'] if ENV['SOLR_VERSION']

      SolrWrapper.wrap(shared_solr_opts.merge(port: 8984, instance_dir: 'tmp/blacklight-core-test')) do |solr|
        solr.with_collection(name: "blacklight-core-test", dir: Rails.root.join("solr", "config").to_s) do
          SolrWrapper.wrap(shared_solr_opts.merge(port: 8985, instance_dir: 'tmp/hydra-test')) do |solr2|
            solr2.with_collection(name: "hydra-test", dir: Rails.root.join("solr", "config").to_s) do
              FcrepoWrapper.wrap(fcrepo_opts) do |_fcrepo|
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
      SolrWrapper.instance(managed: true, verbose: true, port: 8984, instance_dir: 'tmp/blacklight-core-test', persist: false).remove_instance_dir!
      SolrWrapper.instance(managed: true, verbose: true, port: 8985, instance_dir: 'tmp/hydra-test', persist: false).remove_instance_dir!
      FcrepoWrapper.default_instance(managed: true, verbose: true, port: 8988, enable_jms: false, fcrepo_home_dir: "fcrepo4-test-data").remove_instance_dir!
      puts "Cleaned up test solr & fedora servers."
    end
    desc "Start solr and fedora servers for development"
    task :development do
      SolrWrapper.wrap(managed: true, verbose: true, port: 8983, instance_dir: 'tmp/blacklight-core', persist: false) do |solr|
        solr.with_collection(name: "blacklight-core", dir: Rails.root.join("solr", "config").to_s) do
          SolrWrapper.wrap(managed: true, verbose: true, port: 8987, instance_dir: 'tmp/hydra-dev', persist: false) do |solr2|
            solr2.with_collection(name: "hydra-dev", dir: Rails.root.join("solr", "config").to_s) do
              FcrepoWrapper.wrap(managed: true, verbose: true, port: 8986, enable_jms: false, fcrepo_home_dir: "fcrepo4-dev-data") do |_fcrepo|
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
  end
end
