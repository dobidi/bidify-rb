# frozen_string_literal: true

require 'bidify'
require 'bidify/html_string_bidifier'

describe 'Bidify' do
  it '#bidify_html_string calls HtmlStringBidifier#apply with the given input' do
    input = '<p>some text</p>'

    html_string_bidifier = instance_spy(Bidify::HtmlStringBidifier)
    allow(Bidify::HtmlStringBidifier).to receive(:new).and_return(html_string_bidifier)

    Bidify.bidify_html_string(input)

    expect(html_string_bidifier).to have_received(:apply).with(input)
  end
end
