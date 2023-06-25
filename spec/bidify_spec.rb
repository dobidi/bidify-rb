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

    it 'bidifies non list nested elements and ignore the first inner element' do
      input = <<~HTML
        <blockquote>
          <p>Item 1</p>
          <p>Item 2</p>
        </blockquote>
      HTML

      expected_output = <<~HTML
        <blockquote dir="auto">
          <p>Item 1</p>
          <p dir="auto">Item 2</p>
        </blockquote>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it "doesn't bidify li elements by default" do
      input = <<~HTML
        <ul>
          <li>
            Item 1
            <p>with paragraph</p>
          </li>
          <li>
            <p>Paragram at the begining of</p>
            Item 2
          </li>
        </ul>
      HTML

      expected_output = <<~HTML
        <ul dir="auto">
          <li>
            Item 1
            <p dir="auto">with paragraph</p>
          </li>
          <li>
            <p>Paragram at the begining of</p>
            Item 2
          </li>
        </ul>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies non-list nested elements with plain text as the first content' do
      input = <<~HTML
        <blockquote>
          blah
          <p>Item 1</p>
          <p>Item 2</p>
        </blockquote>
      HTML

      expected_output = <<~HTML
        <blockquote dir="auto">
          blah
          <p dir="auto">Item 1</p>
          <p dir="auto">Item 2</p>
        </blockquote>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies non-list nested elements and ignores html comments' do
      input = <<~HTML
        <blockquote>
          <!-- comment -->
          <p>Item 1</p>
          <p>Item 2</p>
        </blockquote>
      HTML

      expected_output = <<~HTML
        <blockquote dir="auto">
          <!-- comment -->
          <p>Item 1</p>
          <p dir="auto">Item 2</p>
        </blockquote>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'skips tags not included in bidifiable tags by default' do
      input = <<~HTML
        <span>Not getting affected</span>
        <img src="image.png">
        <main>content</main>
        <section>content</section>
        <aside>content</aside>
      HTML

      expected_output = input

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end

    it 'skips blank lines' do
      input = <<~HTML
        <blockquote>

          <p>Item 1</p>
          <p>Item 2</p>
        </blockquote>
      HTML

      expected_output = <<~HTML
        <blockquote dir="auto">

          <p>Item 1</p>
          <p dir="auto">Item 2</p>
        </blockquote>
      HTML

      actual_output = Bidify.bidify(input)

      expect(actual_output).to eq expected_output
    end
  end
end
