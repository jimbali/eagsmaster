# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'View series stats', type: :system, js: true do
  let(:series) { create(:series) }
  let(:quizzes) { create_list(:quiz, 2, series: series) }
  let(:questions1) { create_list(:question, 3, quiz: quizzes.first) }
  let(:questions2) { create_list(:question, 3, quiz: quizzes.second) }

  let(:players) do
    create_list(:user, 5) do |user, i|
      user.nickname = "Player#{i}"
      user.save
    end
  end

  def populate_quiz(data, questions)
    data.each_with_index do |scores, p|
      scores.each_with_index do |score, q|
        create(
          :question_user,
          question: questions[q],
          user: players[p],
          points: score
        )
      end
    end
  end

  def populate_quiz1
    populate_quiz(
      [[1, 2, 4], [2, 3, 3.5], [1.5, 2, 5], [0, nil, 0.1], [10, 8, 0]],
      questions1
    )
  end

  def populate_quiz2
    populate_quiz(
      [[3, 2, 3], [1, 2, 3.5], [2.1, 2, 0], [0, 10, 0.1], [9, 5, nil]],
      questions2
    )
  end

  def data
    page.all('#leaderboard-root .ht_master table.htCore tr').map do |tr|
      tr.all('td').map { |td| td['innerHTML'] }
    end
  end

  before do
    populate_quiz1
    populate_quiz2
    sign_in players.first
    visit series_path(series.id)
  end

  it 'has the correct initial data' do
    expect(data).to eq(
      [
        ['1', players[4].nickname, '32', '5', '6.4', '1', '20.00%'],
        ['2', players[0].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['2', players[1].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['4', players[2].nickname, '12.6', '6', '2.1', '0', '0.00%'],
        ['5', players[3].nickname, '10.2', '5', '2.04', '1', '20.00%']
      ]
    )
  end

  it 'recauculates rank when sorting by other columns' do
    page.find('span', text: 'Questions Answered').click

    expect(data).to eq(
      [
        ['4', players[4].nickname, '32', '5', '6.4', '1', '20.00%'],
        ['4', players[3].nickname, '10.2', '5', '2.04', '1', '20.00%'],
        ['1', players[0].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['1', players[1].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['1', players[2].nickname, '12.6', '6', '2.1', '0', '0.00%']
      ]
    )
  end

  it 'returns to the original order when not explicitly sorted' do
    page.find('span', text: 'Questions Answered').click.click.click

    # Ordering of players with equal rank seems to be random
    expect(data).to eq(
      [
        ['1', players[4].nickname, '32', '5', '6.4', '1', '20.00%'],
        ['2', players[0].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['2', players[1].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['4', players[2].nickname, '12.6', '6', '2.1', '0', '0.00%'],
        ['5', players[3].nickname, '10.2', '5', '2.04', '1', '20.00%']
      ]
    ).or eq(
      [
        ['1', players[4].nickname, '32', '5', '6.4', '1', '20.00%'],
        ['2', players[1].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['2', players[0].nickname, '15', '6', '2.5', '0', '0.00%'],
        ['4', players[2].nickname, '12.6', '6', '2.1', '0', '0.00%'],
        ['5', players[3].nickname, '10.2', '5', '2.04', '1', '20.00%']
      ]
    )
  end
end
