# frozen_string_literal: true

require 'bidify/html_string_bidifier'

# == Bidify module
#
# The namespace and helper methods for bidiying HTML contents
#
# == Example:
#
#    bidified_html = Bidify.bidify_html_string(regular_html)
module Bidify
  DEFAULT_BIDIFIABLE_TAGS = %w[div h1 h2 h3 h4 h5 h6 p ul ol blockquote].freeze
  TABLE_TAGS = %w[table thead tbody th tr td].freeze

  class << self
    ###
    # Applies dir="auto" to the given html string with default configuration
    #
    # @param [String] html_string a stringified HTML content
    # @return [String] Bidified version of the input string
    #
    def bidify_html_string(html_string)
      Bidify::HtmlStringBidifier.new.apply(html_string)
    end
  end
end
