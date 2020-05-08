# frozen_string_literal: true

module ActiveRecord
  class QueryCounter
    attr_reader :query_count

    def initialize
      @query_count = 0
    end

    def to_proc
      lambda(&method(:callback))
    end

    def callback(_name, _start, _finish, _message_id, values)
      @query_count += 1 unless %w[CACHE SCHEMA].include?(values[:name])
    end
  end
end
