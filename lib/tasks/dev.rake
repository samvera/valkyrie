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
    desc "Start a development solr server"
    task :test do
      SolrWrapper.wrap(managed: true, verbose: true, port: 8984, instance_dir: 'tmp/blacklight-core-test', persist: false) do |solr|
        solr.with_collection(name: "blacklight-core-test", dir: Rails.root.join("solr", "config").to_s) do
          SolrWrapper.wrap(managed: true, verbose: true, port: 8985, instance_dir: 'tmp/hydra-test', persist: false) do |solr_2|
            solr_2.with_collection(name: "hydra-test", dir: Rails.root.join("solr", "config").to_s) do
              FcrepoWrapper.wrap(managed: true, verbose: true, port: 8988, enable_jms: false, fcrepo_home_dir: "fcrepo4-test-data") do |fcrepo|
                puts "Setup two solr servers & Fedora"
                while(true)
                  sleep(1)
                end
              end
            end
          end
        end
      end
    end
    task :development do
      SolrWrapper.wrap(managed: true, verbose: true, port: 8983, instance_dir: 'tmp/blacklight-core', persist: false) do |solr|
        solr.with_collection(name: "blacklight-core", dir: Rails.root.join("solr", "config").to_s) do
          SolrWrapper.wrap(managed: true, verbose: true, port: 8987, instance_dir: 'tmp/hydra-dev', persist: false) do |solr_2|
            solr_2.with_collection(name: "hydra-dev", dir: Rails.root.join("solr", "config").to_s) do
              FcrepoWrapper.wrap(managed: true, verbose: true, port: 8986, enable_jms: false, fcrepo_home_dir: "fcrepo4-dev-data") do |fcrepo|
                puts "Setup two solr servers & Fedora"
                while(true)
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
