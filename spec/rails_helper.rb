# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'app/channels/application_cable/channel.rb'
  add_filter 'app/channels/application_cable/connection.rb'
  add_filter %r{^/app/controllers/users/}
  add_filter 'app/jobs/application_job.rb'
  add_filter 'app/mailers/application_mailer.rb'
end

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  %i[controller view].each do |type|
    config.include Devise::Test::ControllerHelpers, type: type
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.shared_context 'with existing quiz' do
  let!(:quiz) { create(:quiz) }
  let!(:questions) { create_list(:question, 3, quiz: quiz) }
  let!(:players) { create_list(:user, 3) }
  let!(:answers) { Array.new(9) { |_i| Faker::Books::Dune.character } }

  let(:progress_data) do
    [
      {
        'playerId' => players.third.id,
        "question#{questions.first.id}Answer" => answers[6],
        "question#{questions.first.id}Points" => '6',
        "question#{questions.second.id}Answer" => answers[7],
        "question#{questions.second.id}Points" => '7',
        "question#{questions.third.id}Answer" => answers[8],
        "question#{questions.third.id}Points" => '8',
        'rank' => 1,
        'team' => players.third.nickname,
        'totalPoints' => '21'
      },
      {
        'playerId' => players.second.id,
        "question#{questions.first.id}Answer" => answers[3],
        "question#{questions.first.id}Points" => '3',
        "question#{questions.second.id}Answer" => answers[4],
        "question#{questions.second.id}Points" => '4',
        "question#{questions.third.id}Answer" => answers[5],
        "question#{questions.third.id}Points" => '5',
        'rank' => 2,
        'team' => players.second.nickname,
        'totalPoints' => '12'
      },
      {
        'playerId' => players.first.id,
        "question#{questions.first.id}Answer" => answers[0],
        "question#{questions.first.id}Points" => '0',
        "question#{questions.second.id}Answer" => answers[1],
        "question#{questions.second.id}Points" => '1',
        "question#{questions.third.id}Answer" => answers[2],
        "question#{questions.third.id}Points" => '2',
        'rank' => 3,
        'team' => players.first.nickname,
        'totalPoints' => '3'
      }
    ]
  end

  before do
    i = 0
    players.each do |player|
      questions.each do |question|
        create(:question_user, question: question, user: player, points: i,
                               answer: answers[i])
        i += 1
      end
    end
  end
end
