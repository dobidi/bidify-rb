# frozen_string_literal: true

module Bidify
  # Super class for custom bidifiers
  class Bidifier
    def initialize
      configure
    end

    def apply
      raise NotImplementedError
    end

    private

    def configure
      @bidifiable_tags = DEFAULT_BIDIFIABLE_TAGS.dup
    end

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
