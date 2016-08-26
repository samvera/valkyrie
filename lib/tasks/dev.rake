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
    task :development do
      SolrWrapper.wrap(port: 8983, instance_dir: 'tmp/blacklight-core') do |solr|
        solr.with_collection(name: "blacklight-core", dir: Rails.root.join("solr", "config").to_s) do
          while(true)
            sleep(1)
          end
        end
      end
    end
  end
end
