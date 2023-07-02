# frozen_string_literal: true

require 'nokogiri'
require_relative 'bidifier'

module Bidify
  ###
  # Bidifying html input as string
  #
  # == Example Usage
  #
  # Here's an example of how to use the class:
  #
  #   bidifier = HtmlStringBidifier.new
  #   bidifier.apply("<p>text</p>")
  #
  class HtmlStringBidifier < Bidifier
    ###
    # Applies dir="auto" to the given html string with default configuration
    #
    # @param [String] html_string a stringified HTML content
    # @return [String] Bidified version of the input string
    #
    def apply(html_input)
      html_node = Nokogiri::HTML.fragment(html_input)
      bidify_recursively(html_node, { root: true })

      html_node.to_s
    end
  end
end
