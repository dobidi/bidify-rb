# frozen_string_literal: true

require 'bidify'

describe 'Bidify' do
  describe '::StringHtmlBidifier.apply with defaults' do
    let(:bidifier) { Bidify::HtmlStringBidifier.new }

    it 'bidifies a single paragraph' do
      input = '<p>some text</p>'
      expected_output = '<p dir="auto">some text</p>'

      actual_output = bidifier.apply(input)

      expect(actual_output).to eq expected_output
    end

    it 'bidifies all non-list tags in bidifiable tags list' do
      input = <<~HTML
        <div>Content</div>
        <h1>Content</h1>
        <h2>Content</h2>
        <h3>Content</h3>
        <h4>Content</h4>
        <h5>Content</h5>
        <h6>Content</h6>
        <p>Content</p>
        <blockquote>Content</blockquote>
      HTML

      expected_output = <<~HTML
        <div dir="auto">Content</div>
        <h1 dir="auto">Content</h1>
        <h2 dir="auto">Content</h2>
        <h3 dir="auto">Content</h3>
        <h4 dir="auto">Content</h4>
        <h5 dir="auto">Content</h5>
        <h6 dir="auto">Content</h6>
        <p dir="auto">Content</p>
        <blockquote dir="auto">Content</blockquote>
      HTML

      actual_output = bidifier.apply(input)

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

      actual_output = bidifier.apply(input)

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

      actual_output = bidifier.apply(input)

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

      actual_output = bidifier.apply(input)

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

      actual_output = bidifier.apply(input)

      expect(actual_output).to eq expected_output
    end

    it 'skips tags not included in bidifiable tags by default' do
      input = <<~HTML
        <span>Not getting affected</span>
        <img src="image.png">
        <main>content</main>
        <section>content</section>
        <aside>content</aside>
        <a>content</a>
      HTML

      expected_output = input

      actual_output = bidifier.apply(input)

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

      actual_output = bidifier.apply(input)

      expect(actual_output).to eq expected_output
    end

    it 'stops recursive bidification on an element with explicit dir attribute' do
      input = <<~HTML
        <div>
          <p>Item 1</p>
          <div dir="ltr">
            <p>Item 2</p>
            <p>Item 3</p>
          </div>
        </div>
      HTML

      expected_output = <<~HTML
        <div dir="auto">
          <p>Item 1</p>
          <div dir="ltr">
            <p>Item 2</p>
            <p>Item 3</p>
          </div>
        </div>
      HTML

      actual_output = bidifier.apply(input)

      expect(actual_output).to eq expected_output
    end
  end

  it 'bidifies a table with :with_table_support option' do
    input = <<~HTML
      <table>
        <tr>
          <td>راست left</td>
          <td>left راست</td>
        </tr>
      </table>
    HTML

    expected_output = <<~HTML
      <table dir="auto">
        <tr>
          <td>راست left</td>
          <td dir="auto">left راست</td>
        </tr>
      </table>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(with_table_support: true)
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end

  it 'with `greedy: true` option, it disregard any exisitng dir attribute' do
    input = <<~HTML
      <div>
        <p>Item 1</p>
        <div dir="ltr">
          <p>Item 2</p>
          <p>Item 3</p>
        </div>
      </div>
    HTML

    expected_output = <<~HTML
      <div dir="auto">
        <p>Item 1</p>
        <div dir="auto">
          <p>Item 2</p>
          <p dir="auto">Item 3</p>
        </div>
      </div>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(greedy: true)
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end

  it 'only bidifies specified tags using `only_tags` option' do
    input = <<~HTML
      <p>راست left</p>
      <div>left راست</div>
    HTML

    expected_output = <<~HTML
      <p dir="auto">راست left</p>
      <div>left راست</div>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(only_tags: ['p'])
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end

  it 'bidies specified additional tags using `including_tags` option' do
    input = <<~HTML
      <p>راست left</p>
      <xyz>left راست</xyz>
    HTML

    expected_output = <<~HTML
      <p dir="auto">راست left</p>
      <xyz dir="auto">left راست</xyz>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(including_tags: ['xyz'])
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end

  it "doesn't bidify specified excluded tags using `excluding_tags` option" do
    input = <<~HTML
      <p>راست left</p>
      <div>left راست</div>
    HTML

    expected_output = <<~HTML
      <p dir="auto">راست left</p>
      <div>left راست</div>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(excluding_tags: ['div'])
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end

  it '`excluding_tags` option overrides `including_tags`' do
    input = <<~HTML
      <p>راست left</p>
      <xyz>left راست</xyz>
    HTML

    expected_output = <<~HTML
      <p dir="auto">راست left</p>
      <xyz>left راست</xyz>
    HTML

    bidifier = Bidify::HtmlStringBidifier.new(including_tags: ['xyz'], excluding_tags: ['xyz'])
    actual_output = bidifier.apply(input)

    expect(actual_output).to eq expected_output
  end
end
