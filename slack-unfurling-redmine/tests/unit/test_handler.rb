# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'webmock/minitest'

require_relative '../../app.rb'

class AppTest < Minitest::Test
  def setup
    WebMock.disable_net_connect!
  end

  def test_url_verification_404
    e = event({
      type: 'url_verification'
    }.to_json)

    expected_result = { statusCode: 404, body: JSON.generate(ok: false) }

    assert_equal(expected_result, lambda_handler(event: e, context: ''))
  end

  def test_url_verification_200
    e = event({
      type: 'url_verification',
      challenge: 'example'
    }.to_json)

    expected_result = { statusCode: 200, body: JSON.generate(challenge: 'example') }

    RedmineClient.stub_any_instance(:'enabled?', true) do
      assert_equal(expected_result, lambda_handler(event: e, context: ''))
    end
  end

  def test_event_callback_page
    e = event({
      type: 'event_callback',
      event: {
        channel: 'channel_name',
        message_ts: '1234567890.123456',
        links: [
          { url: 'https://example.com/issues/367' }
        ]
      }
    }.to_json)

    stub_request(:get, 'https://example.com/issues/367.json?key=').
      to_return(status: 200, body: {
        issue: {
          project: {
            name: 'Some Project'
          },
          subject: 'Some Issue',
          description: (1..100).map { |i| i.to_s }.join("\n")
        }
      }.to_json, headers: {})

    stub_request(:post, 'https://slack.com/api/chat.unfurl').
    with(
      body: {
        channel: 'channel_name',
        ts: '1234567890.123456',
        unfurls: {
          'https://example.com/issues/367': {
            title: 'Some Project | Some Issue',
            title_link: 'https://example.com/issues/367',
            text: (1..10).map { |i| i.to_s }.join("\n"),
            color: '#A00F1B',
            fields: []
          }
        }
      }.to_json).
      to_return(status: 200, body: "", headers: {})

    expected_result = { statusCode: 200, body: JSON.generate(ok: true) }

    RedmineClient.stub_any_instance(:'enabled?', true) do
      assert_equal(expected_result, lambda_handler(event: e, context: ''))
    end
  end

  private

  def event(body)
    {
      'body' => body,
    }
  end
end
