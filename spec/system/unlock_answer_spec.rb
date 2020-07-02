# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Unlock answer', type: :system, js: true do
  let!(:question) { create(:question) }
  let(:quiz) { question.quiz }
  let(:player) { create(:user) }

  before do
    quiz.update!(cursor: question.id)

    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    fill_in 'answer', with: 'Prince Charles'
    click_on 'Submit'

    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
    edit_cell(question.title, '8', 1)
    page.has_text?('Autosaved (1 cell)')

    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    click_on 'Unlock'

    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
  end

  def edit_cell(heading, replacement, offset = 0)
    cell = cell(heading, offset).double_click
    page.driver.browser.switch_to.active_element.send_keys(
      [:backspace] * cell.text.size, replacement
    )
    page.find('h2').click
  end

  def cell(heading, offset = 0)
    column_index = column_with_heading(heading, '#quiz-root .colHeader')
    cells = row('#quiz-root .ht_master table.htCore tr').all('td')
    cells[column_index + offset]
  end

  def column_with_heading(text, selector)
    page.all(selector).find_index { |h| h.text == text }
  end

  def row(selector)
    page.all(selector).find do |tr|
      tr.all('td')[1].text == player.nickname
    end
  end

  it 'clears the answer on the leaderboard' do
    expect(cell(question.title).text).to be_blank
  end

  it 'clears the points on the leaderboard' do
    expect(cell(question.title, 1).text).to be_blank
  end
end
