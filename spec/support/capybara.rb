# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before :each, type: :system, js: true do
    driven_by :selenium, using: :chrome, options: {
      browser: :remote,
      url: 'http://chrome:4444/wd/hub',
      desired_capabilities: :chrome
    }

    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = 3000
    session_server = Capybara.current_session.server
    Capybara.app_host = "http://#{session_server.host}:#{session_server.port}"
  end

  config.after :each, type: :system, js: true do
    page.driver.browser.manage.logs.get(:browser).each do |log|
      case log.message
      when /This page includes a password or credit card input in a non-secure
           context/x
        next
      when /Cannot read property 'ownerDocument' of undefined/
        next
      else
        message = "[#{log.level}] #{log.message}"
        raise message
      end
    end
  end
end
