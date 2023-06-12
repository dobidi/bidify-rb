require 'nokogiri'

module Bidify
  class << self
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

        seen_the_first_bidifiable_element = true if child_node.element?
      end
    end
  end
end
