# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
