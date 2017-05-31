# frozen_string_literal: true
module Catalog
  extend ActiveSupport::Concern
  module ClassMethods
    def search_config
      {
        'qf' => %w[title_ssim],
        'qt' => 'search',
        'rows' => 10
      }
    end
  end
  included do
    configure_blacklight do |config|
      ## Class for sending and receiving requests from a search index
      # config.repository_class = Blacklight::Solr::Repository
      #
      ## Class for converting Blacklight's url parameters to into request parameters for the search index
      # config.search_builder_class = ::SearchBuilder
      #
      ## Model that maps search index responses to the blacklight response model
      # config.response_model = Blacklight::Solr::Response

      ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
      config.default_solr_params = {
        qf: search_config['qf'],
        qt: search_config['qt'],
        rows: search_config['rows']
      }

      # solr path which will be added to solr base url before the other solr params.
      # config.solr_path = 'select'

      # items to show per page, each number in the array represent another option to choose from.
      # config.per_page = [10,20,50,100]

      ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
      ## parameters included in the Blacklight-jetty document requestHandler.
      #
      # config.default_document_solr_params = {
      #  qt: 'document',
      #  ## These are hard-coded in the blacklight 'document' requestHandler
      #  # fl: '*',
      #  # rows: 1,
      #  # q: '{!term f=id v=$id}'
      # }

      # solr field configuration for search results/index views
      config.index.title_field = 'title_ssim'

      # solr field configuration for document/show views
      # config.show.title_field = 'title_display'
      # config.show.display_type_field = 'format'

      # solr fields that will be treated as facets by the blacklight application
      #   The ordering of the field names is the order of the display
      #
      # Setting a limit will trigger Blacklight's 'more' facet values link.
      # * If left unset, then all facet values returned by solr will be displayed.
      # * If set to an integer, then "f.somefield.facet.limit" will be added to
      # solr request, with actual solr request being +1 your configured limit --
      # you configure the number of items you actually want _displayed_ in a page.
      # * If set to 'true', then no additional parameters will be sent to solr,
      # but any 'sniffed' request limit parameters will be used for paging, with
      # paging at requested limit -1. Can sniff from facet.limit or
      # f.specific_field.facet.limit solr request params. This 'true' config
      # can be used if you set limits in :default_solr_params, or as defaults
      # on the solr side in the request handler itself. Request handler defaults
      # sniffing requires solr requests to be made with "echoParams=all", for
      # app code to actually have it echo'd back to see it.
      #
      # :show may be set to false if you don't want the facet to be drawn in the
      # facet bar
      #
      # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
      #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
      # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

      # Have BL send all facet field names to Solr, which has been the default
      # previously. Simply remove these lines if you'd rather use Solr request
      # handler defaults, or have no facets.
      config.index.display_type_field = "internal_model_ssim"
      config.add_facet_field('internal_model_ssim', label: 'Type of Work')
      config.add_facet_fields_to_solr_request!
      config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false)
      config.add_show_field('author_tesim', label: 'Author')
      config.show.partials += [:members]
      config.add_show_field('member_ids_tesim', label: 'Member IDs')
      config.add_show_field('file_identifiers_tesim', label: 'File Identifiers')
      config.show.partials = config.show.partials.insert(1, :parent_breadcrumb)
      config.show.partials = config.show.partials.insert(2, :children)
      config.add_facet_field 'author_ssim', label: 'Author'
    end
  end
end
