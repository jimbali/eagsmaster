# frozen_string_literal: true

require_relative '../query_counter'

RSpec::Matchers.define :exceed_query_limit do |expected|
  supports_block_expectations

  match do |block|
    query_count(&block) > expected
  end

  failure_message do |_actual|
    "Expected to run minimum #{expected} queries, got #{@counter.query_count}"
  end

  failure_message_when_negated do |_actual|
    "Expected to run maximum #{expected} queries, got #{@counter.query_count}"
  end

  def query_count(&block)
    @counter = ActiveRecord::QueryCounter.new
    ActiveSupport::Notifications.subscribed(
      @counter.to_proc, 'sql.active_record', &block
    )
    @counter.query_count
  end
end
