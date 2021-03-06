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

  def expire_question(title)
    tr = page.all('#questions-root .ht_master table.htCore tr').find do |row|
      row.first('td').text == title
    end
    tr.find('td input[type="checkbox"]').click
  end

  def row(selector)
    page.all(selector).find do |tr|
      tr.all('td')[1].text == player.nickname
    end
  end

  def leaderboard_cell(heading)
    column_index = column_with_heading(heading, 'thead td')
    cells = row('tbody tr').all('td')
    cells[column_index].text
  end

  it 'updates the points on the leaderboard' do
    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
    edit_cell(question.title, '10', 1)
    expire_question(question.title)
    page.has_text?('Autosaved (1 cell)')
    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    expect(leaderboard_cell('Points')).to eq '10'
  end

  it 'updates the answer on the leaderboard' do
    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
    edit_cell(question.title, 'Prince Charleston')
    expire_question(question.title)
    click_on 'OK'
    page.has_text?('Autosaved (1 cell)')
    sign_in player
    visit quiz_question_path(quiz_id: quiz.id, id: question.id)
    expect(leaderboard_cell('Answer')).to eq 'Prince Charleston'
  end

  it 'warns about expiring a question before all players have points' do
    sign_in quiz.user
    visit edit_quiz_path(id: quiz.id)
    fill_in 'question_title', with: 'Who is Keyzer Soze?'
    click_on 'Add question'
    expire_question('Who is Keyzer Soze?')
    expect(page).to have_selector(
      '.bootbox-body',
      text: 'Not all answers for this round have points assigned to them. ' \
            'Continue anyway?'
    )
  end

  context 'with two different sessions' do
    let(:admin) { Capybara::Session.new(:selenium) }

    it 'warns about expiring a question before all players have points' do
      Capybara.using_session(admin) do
        sign_in quiz.user
        visit edit_quiz_path(id: quiz.id)
      end

      visit quiz_question_path(quiz_id: quiz.id, id: question.id)
      click_on 'Undo'

      Capybara.using_session(admin) do
        expire_question(question.title)
        expect(page).to have_selector(
          '.bootbox-body',
          text: 'Not all answers for this round have points assigned to ' \
                'them. Continue anyway?'
        )
      end
    end
  end
end
