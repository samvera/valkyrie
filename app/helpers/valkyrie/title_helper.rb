# frozen_string_literal: true
module Penguin::TitleHelper
  def application_title
    t('penguin.product_name', default: application_name)
  end

  def construct_page_title(*elements)
    (elements.flatten.compact + [application_name]).join(' // ')
  end

  def default_page_title
    text = controller_name.singularize.titleize
    text = "#{action_name.titleize} " + text if action_name
    construct_page_title(text)
  end
end
