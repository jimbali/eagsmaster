# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a quiz', type: :system do
  let(:user) { create(:user) }
  let!(:quiz) { create(:quiz, user: user) }
  let(:new_name) { 'Thursday Thinkfest' }
  let(:new_code) { 'THURS' }
  let(:player) { create(:user) }

  before do
    sign_in user

    visit edit_quiz_path(id: quiz.id)
  end

  describe 'update the details' do
    before do
      fill_in 'Name', with: new_name
      fill_in 'quiz_code', with: new_code
      click_on 'Update Quiz'
    end

    it 'updates the title' do
      expect(page).to have_field 'Name', with: new_name
    end

    it 'updates the code' do
      expect(page).to have_field 'quiz_code', with: new_code
    end

    it 'directs users to the waiting page' do
      sign_in player
      visit quiz_path(id: quiz.id)

      expect(page).to have_text 'Waiting for the quiz to start...'
    end
  end

  describe 'create questions', js: true do
    let(:question1_title) { 'Question 1' }

    it 'adds the question' do
      fill_in 'question_title', with: question1_title
      click_on 'Add question'

      expect(page).to have_css('#questions-root td', text: question1_title)
    end
  end

  context 'with a question' do
    let!(:question) { create(:question, quiz: quiz) }

    before do
      visit edit_quiz_path(id: quiz.id)
      select question.title, from: 'Current question'
      click_on 'Update Quiz'
    end

    it 'selects the question' do
      expect(page).to have_select('Current question', selected: question.title)
    end

    it 'directs users to the enter answer page' do
      sign_in player
      visit quiz_path(id: quiz.id)

      expect(page).to have_field 'answer'
    end
  end
end
