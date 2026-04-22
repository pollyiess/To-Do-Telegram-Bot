# frozen_string_literal: true

require 'webmock/rspec'
require 'telegram/bot'
require 'telegram/bot/types'
require_relative '../lib/database'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../lib/states', __dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each) do
    db = Database.new
    db.db[:tasks].delete

    stub_request(:any, /api.telegram.org/).to_return(status: 200, body: '{"ok":true}', headers: {})
  end
end
