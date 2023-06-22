# frozen_string_literal: true

require 'bidify'

describe 'Bidify' do
  describe '.bidify' do
    it 'bidifies a simple html' do
      input = '<p>some text</p>'
      expected_output = '<p dir="auto">some text</p>'

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies a html with multiple tags' do
      input = '<h1>some text</h1><p>A paragraph</p>'
      expected_output = %(<h1 dir="auto">some text</h1><p dir="auto">A paragraph</p>)

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies nested elements and ignore the first inner element' do
      input = <<~HTML
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
        </ul>
      HTML

      expected_output = <<~HTML
        <ul dir="auto">
          <li>Item 1</li>
          <li dir="auto">Item 2</li>
        </ul>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies nested elements with plain text as the first content' do
      input = <<~HTML
        <ul>
          blah
          <li>Item 1</li>
          <li>Item 2</li>
        </ul>
      HTML

      expected_output = <<~HTML
        <ul dir="auto">
          blah
          <li dir="auto">Item 1</li>
          <li dir="auto">Item 2</li>
        </ul>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies nested elements and ignores html comments' do
      input = <<~HTML
        <ul>
          <!-- comment -->
          <li>Item 1</li>
          <li>Item 2</li>
        </ul>
      HTML

      expected_output = <<~HTML
        <ul dir="auto">
          <!-- comment -->
          <li>Item 1</li>
          <li dir="auto">Item 2</li>
        </ul>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'skips span elements' do
      input = '<span>Not getting affected</span>'
      expected_output = '<span>Not getting affected</span>'

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'skips img elements' do
      input = '<img src="image.png">'
      expected_output = '<img src="image.png">'

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end
  end
end
