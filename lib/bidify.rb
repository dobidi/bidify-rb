# frozen_string_literal: true

require 'nokogiri'

# Bidify applies `dir="auto"` to the given html string
#
# ### Example:
#
#    bidified_html = Bidify.bidify(regular_html)
module Bidify
  class << self
    ###
    # bidify applies dir="auto" to the given html string
    def bidify(input_html)
      html_node = Nokogiri::HTML.fragment(input_html)
      bidify_recursively(html_node, { root: true })
      html_node.to_s
    end

    private

    def bidify_recursively(html_node, options = {})
      return unless html_node.children.count.positive?

      seen_the_first_bidifiable_element = false

      html_node.children.each do |child_node|
        next if child_node.blank?

        bidify_recursively(child_node)

        child_node.set_attribute('dir', 'auto') if options[:root] || seen_the_first_bidifiable_element

        seen_the_first_bidifiable_element = true if bidifiable_node?
      end
    end

    def bidifiable_node?(node)
      child_node.element? || (child_node.text? && !child_node.blank?)
    end
  end
end
