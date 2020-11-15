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

    it 'redirects to the redirect_to param' do
      redirect_url = edit_quiz_url(id: 1)

      expect(
        post(
          :create,
          params: { series: { name: name }, redirect_to: redirect_url }
        )
      ).to redirect_to redirect_url
    end

    context 'when a series already exists with the same name' do
      before do
        create(:series, name: name)
        post :create, params: { series: { name: name } }
      end

      it { is_expected.to set_flash[:error].to('Name has already been taken') }

      it { is_expected.to redirect_to new_series_url }
    end
  end
end
