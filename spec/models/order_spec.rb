require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'status change event tracking' do
    let(:order) { create(:order, status: 'pending') }

    context 'when status changes' do
      it 'creates an OrderEvent with correct from_status and to_status' do
        expect {
          order.update!(status: 'shipped')
        }.to change(OrderEvent, :count).by(1)

        event = order.order_events.last
        expect(event.from_status).to eq('pending')
        expect(event.to_status).to eq('shipped')
      end

      it 'includes metadata with changed_at timestamp' do
        order.update!(status: 'confirmed')

        event = order.order_events.last
        expect(event.metadata['changed_at']).to be_present
      end
    end

    context 'when status does NOT change' do
      it 'does NOT create an OrderEvent when updating other attributes' do
        # Update something other than status (e.g., updated_at via touch)
        expect {
          order.touch
        }.not_to change(OrderEvent, :count)
      end

      it 'does NOT create an OrderEvent when saving with same status' do
        expect {
          order.update!(status: 'pending') # same as current
        }.not_to change(OrderEvent, :count)
      end
    end

    context 'multiple status transitions' do
      it 'creates an event for each status change' do
        order.update!(status: 'confirmed')
        order.update!(status: 'processing')
        order.update!(status: 'shipped')

        expect(order.order_events.count).to eq(3)

        events = order.order_events.order(:created_at)
        expect(events[0].from_status).to eq('pending')
        expect(events[0].to_status).to eq('confirmed')
        expect(events[1].from_status).to eq('confirmed')
        expect(events[1].to_status).to eq('processing')
        expect(events[2].from_status).to eq('processing')
        expect(events[2].to_status).to eq('shipped')
      end
    end
  end
end
