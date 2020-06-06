# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthController do
  before { get :index }

  it 'has ok status' do
    expect(response).to have_http_status :ok
  end

  it 'returns some JSON' do
    expect(response.parsed_body).to eq([{ 'health' => 'ok' }])
  end
end
