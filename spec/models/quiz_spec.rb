require 'rails_helper'

RSpec.describe Quiz do
  describe '.unique_code' do
    it 'is composed of capital letters' do
      expect(described_class.unique_code).to match /[A-Z]*/
    end

    it 'is five characters long' do
      expect(described_class.unique_code.length).to eq 5
    end

    context 'when the code already exists' do
      let(:code) { 'VEGAS' }
      let(:new_code) { 'TOKYO' }

      before do
        allow(described_class)
          .to receive(:random_code)
          .and_return(code, new_code)
        allow(described_class).to receive(:find_by).and_call_original
        allow(described_class)
          .to receive(:find_by)
          .with(code: code)
          .and_return(instance_double(described_class))
      end

      it 'returns a new unique code' do
        expect(described_class.unique_code).to eq new_code
      end
    end
  end
end
