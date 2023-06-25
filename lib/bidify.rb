# frozen_string_literal: true

require 'nokogiri'

# Bidify applies `dir="auto"` to the given html string
#
# ### Example:
#
#    bidified_html = Bidify.bidify(regular_html)
module Bidify
  @bidifiable_tags = %w[div h1 h2 h3 h4 h5 h6 p ul ol blockquote]

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
      seen_the_first_bidifiable_element = false

      html_node.children.each do |child_node|
        bidify_recursively(child_node)

        if (options[:root] || seen_the_first_bidifiable_element) && @bidifiable_tags.include?(child_node.name)
          child_node.set_attribute('dir', 'auto')
        end

        seen_the_first_bidifiable_element = true if actual_content?(child_node)
      end
    end

    def actual_content?(node)
      node.element? || (node.text? && !node.blank?)
    end
  end
end
