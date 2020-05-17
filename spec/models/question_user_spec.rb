# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionUser do
  describe 'autoformat' do
    let(:question_user) { create(:question_user, answer: 'lowercase') }

    it 'capitalises the answer' do
      expect(question_user.answer).to eq('Lowercase')
    end
  end
end
