# frozen_string_literal: true

class Quiz
  class AnswerFormatter
    def initialize(operation)
      raise ArgumentError if operation != :upcase_first

      @operation = operation
    end

    def format(answer)
      answer&.public_send(@operation)
    end
  end
end
