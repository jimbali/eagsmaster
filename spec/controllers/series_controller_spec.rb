# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeriesController do
  before { sign_in create(:user) }

  describe '#new' do
    it 'initializes a series' do
      get :new
      expect(assigns(:series)).to be_a Series
    end
  end

  describe '#create' do
    let(:name) { 'Friday Forehead-wrinkler' }

    it 'creates a series' do
      expect { post :create, params: { series: { name: name } } }
        .to change(Series, :count).by 1
    end

    it 'redirects to the root URL' do
      expect(post(:create, params: { series: { name: name } }))
        .to redirect_to root_url
    end
  end
end
