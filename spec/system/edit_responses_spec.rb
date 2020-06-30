# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit responses', type: :system, js: true do
  let!(:question) { create(:question) }
  let(:quiz) { question.quiz }
  let(:player) { create(:user) }

  before do
    quiz.update!(cursor: question.id)

    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    fill_in 'answer', with: 'Prince Charles'
    click_on 'Submit'
  end

  def edit_cell
    points_cell.double_click
    page.driver.browser.switch_to.active_element.send_keys('10')
    page.find('h2').click
  end

  def points_cell
    column_index = column_with_heading(question.title, '#quiz-root .colHeader')
    cells = row('#quiz-root .ht_master table.htCore tr').all('td')
    cells[column_index + 1]
  end

  def column_with_heading(text, selector)
    page.all(selector).find_index { |h| h.text == text }
  end

  def expire_question
    tr = page.all('#questions-root .ht_master table.htCore tr').find do |row|
      row.first('td').text == question.title
    end
    tr.find('td input[type="checkbox"]').click
  end

  def row(selector)
    page.all(selector).find do |tr|
      tr.all('td')[1].text == player.nickname
    end
  end

  def leaderboard_score
    column_index = column_with_heading('Points', 'thead td')
    cells = row('tbody tr').all('td')
    cells[column_index].text
  end

  it 'updates the leaderboard' do # rubocop:disable RSpec/MultipleExpectations
    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
    edit_cell
    expire_question
    expect(page).to have_text('Autosaved (1 cell)')
    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    expect(leaderboard_score).to eq '10'
  end
end
