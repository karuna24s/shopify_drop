require 'rails_helper'

RSpec.describe Claims::CreateClaimService do
  let(:vip_user) { create(:user, :vip) }
  let(:non_vip_user) { create(:user) }

  describe '#call' do
    context 'when product has high stock (> 5)' do
      let(:product) { create(:product, inventory_count: 10) }

      it 'allows VIP user to claim successfully' do
        result = described_class.new(product_id: product.id, user_id: vip_user.id).call

        expect(result).to eq({ success: true })
        expect(product.reload.inventory_count).to eq(9)
        expect(Claim.exists?(user_id: vip_user.id, product_id: product.id)).to be true
      end

      it 'allows non-VIP user to claim successfully' do
        result = described_class.new(product_id: product.id, user_id: non_vip_user.id).call

        expect(result).to eq({ success: true })
        expect(product.reload.inventory_count).to eq(9)
        expect(Claim.exists?(user_id: non_vip_user.id, product_id: product.id)).to be true
      end
    end

    context 'when product has low stock (<= 5)' do
      let(:product) { create(:product, inventory_count: 5) }

      it 'allows VIP user to claim successfully' do
        result = described_class.new(product_id: product.id, user_id: vip_user.id).call

        expect(result).to eq({ success: true })
        expect(product.reload.inventory_count).to eq(4)
        expect(Claim.exists?(user_id: vip_user.id, product_id: product.id)).to be true
      end

      it 'rejects non-VIP user with :vip_only error' do
        result = described_class.new(product_id: product.id, user_id: non_vip_user.id).call

        expect(result).to eq({ success: false, error: :vip_only })
      end

      it 'does NOT decrement inventory when non-VIP user is rejected' do
        described_class.new(product_id: product.id, user_id: non_vip_user.id).call

        expect(product.reload.inventory_count).to eq(5)
      end

      it 'does NOT create a claim when non-VIP user is rejected' do
        expect {
          described_class.new(product_id: product.id, user_id: non_vip_user.id).call
        }.not_to change(Claim, :count)
      end
    end

    context 'when product has very low stock (e.g., 3 items)' do
      let(:product) { create(:product, inventory_count: 3) }

      it 'still allows VIP user to claim' do
        result = described_class.new(product_id: product.id, user_id: vip_user.id).call

        expect(result).to eq({ success: true })
        expect(product.reload.inventory_count).to eq(2)
      end

      it 'still rejects non-VIP user' do
        result = described_class.new(product_id: product.id, user_id: non_vip_user.id).call

        expect(result).to eq({ success: false, error: :vip_only })
        expect(product.reload.inventory_count).to eq(3)
      end
    end

    context 'when product is out of stock (0)' do
      let(:product) { create(:product, inventory_count: 0) }

      it 'rejects non-VIP user with :out_of_stock error' do
        result = described_class.new(product_id: product.id, user_id: non_vip_user.id).call

        expect(result).to eq({ success: false, error: :out_of_stock })
      end

      it 'rejects VIP user with :out_of_stock error' do
        result = described_class.new(product_id: product.id, user_id: vip_user.id).call

        expect(result).to eq({ success: false, error: :out_of_stock })
      end

      it 'creates a RestockNotification for the user' do
        expect {
          described_class.new(product_id: product.id, user_id: vip_user.id).call
        }.to change(RestockNotification, :count).by(1)

        notification = RestockNotification.last
        expect(notification.user_id).to eq(vip_user.id)
        expect(notification.product_id).to eq(product.id)
      end

      it 'does not create duplicate RestockNotification for the same user' do
        # First call creates a notification
        described_class.new(product_id: product.id, user_id: vip_user.id).call

        # Second call should not create a duplicate
        expect {
          described_class.new(product_id: product.id, user_id: vip_user.id).call
        }.not_to change(RestockNotification, :count)
      end

      it 'does NOT create a claim' do
        expect {
          described_class.new(product_id: product.id, user_id: vip_user.id).call
        }.not_to change(Claim, :count)
      end

      it 'inventory remains at 0' do
        described_class.new(product_id: product.id, user_id: vip_user.id).call

        expect(product.reload.inventory_count).to eq(0)
      end
    end
  end
end
