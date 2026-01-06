require 'rails_helper'

RSpec.describe ShippingCalculator do
  describe '#call' do
    context 'domestic under 2kg' do
      it 'returns exactly $5 flat rate' do
        result = described_class.new(weight: 1.5, destination_zone: 'domestic').call

        expect(result[:success]).to be true
        expect(result[:rate]).to eq(5.00)
        expect(result[:currency]).to eq('USD')
        expect(result[:estimated_delivery_days]).to be_present
      end
    end

    context 'domestic at 5kg' do
      it 'returns $11 ($5 base + 3kg extra at $2/kg)' do
        result = described_class.new(weight: 5.0, destination_zone: 'domestic').call

        expect(result[:success]).to be true
        expect(result[:rate]).to eq(11.00)
      end
    end

    context 'asia_pacific at 1kg' do
      it 'returns $25 base rate' do
        result = described_class.new(weight: 1.0, destination_zone: 'asia_pacific').call

        expect(result[:success]).to be true
        expect(result[:rate]).to eq(25.00)
      end
    end

    context 'invalid zone' do
      it 'returns an error hash' do
        result = described_class.new(weight: 1.0, destination_zone: 'mars').call

        expect(result[:success]).to be false
        expect(result[:error]).to eq(:invalid_zone)
      end
    end
  end
end
