$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'test/unit'
require 'coveralls'
Coveralls.wear!
require 'pry'
require 'geocoder/olleh'

require 'vcr'

class URIWithoutOllehTimestampMatcher
  def uri_without_timestamp(request)
    request.parsed_uri.tap do |uri|
      return uri unless uri.query # ignore uris without params, e.g. "http://example.com/"

      uri.query = uri.query.split('timestamp').first
    end
  end

  def call(request_1, request_2)
    uri_without_timestamp(request_1) == uri_without_timestamp(request_2)
  end

  def to_proc
    lambda { |r1, r2| call(r1, r2) }
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.register_request_matcher(:uri_without_olleh_timestamp, &URIWithoutOllehTimestampMatcher.new)
  config.default_cassette_options = {
    match_requests_on: [
      :method,
      :uri_without_olleh_timestamp]
  }
end

class GeocoderTestCase < Test::Unit::TestCase
end