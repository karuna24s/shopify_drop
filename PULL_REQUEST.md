# Pull Request: High-Heat Drop System & Order Tracking

## Overview

This PR implements a production-ready inventory claim system designed for Shopify-style high-traffic product drops, plus a robust order tracking system with full audit trail capabilities.

---

## 🔥 Feature 1: Atomic Claim System for High-Heat Drops

### Impact

**Prevents overselling during flash sales and limited drops.** When thousands of users hit "Buy" simultaneously, traditional read-then-write patterns cause race conditions that oversell inventory. This implementation uses atomic database operations to guarantee inventory integrity.

### Technical Implementation

#### Atomic Inventory Decrement
```ruby
affected_rows = Product.where(id: @product_id)
                       .where('inventory_count > 0')
                       .update_all('inventory_count = inventory_count - 1')
```
- Single SQL statement — no gap between check and decrement
- Database handles concurrency via row-level locking
- Returns `0` if inventory depleted, preventing oversell

#### Pessimistic Locking for VIP Check
```ruby
product = Product.lock.find_by(id: @product_id)
```
- `FOR UPDATE` lock prevents TOCTOU race conditions
- Ensures VIP threshold check uses latest inventory value

#### Global Claim Limit
- Unique index on `user_id` enforces one claim per user across all products
- Database constraint is the ultimate safeguard — application check is fail-fast optimization

### VIP-Only Access
- Products with ≤5 items are reserved for VIP users
- Configurable threshold via `VIP_THRESHOLD` constant
- Non-VIP users receive clear `:vip_only` error

### Restock Notifications
- Out-of-stock attempts automatically register users for notifications
- `find_or_create_by!` ensures idempotency (no duplicate signups)
- Unique index on `(user_id, product_id)` as database-level safeguard

### Verification (TDD)

All features developed test-first with RSpec:

```
Claims::CreateClaimService
  #call
    when product has high stock (> 5)
      ✓ allows VIP user to claim successfully
      ✓ allows non-VIP user to claim successfully
    when product has low stock (<= 5)
      ✓ allows VIP user to claim successfully
      ✓ rejects non-VIP user with :vip_only error
      ✓ does NOT decrement inventory when non-VIP user is rejected
      ✓ does NOT create a claim when non-VIP user is rejected
    when product is out of stock (0)
      ✓ rejects non-VIP user with :out_of_stock error
      ✓ rejects VIP user with :out_of_stock error
      ✓ creates a RestockNotification for the user
      ✓ does not create duplicate RestockNotification

14 examples, 0 failures
```

### Error Handling

Graceful error responses (no exceptions for user input errors):

| Error | Scenario |
|-------|----------|
| `:global_limit_reached` | User already claimed a product |
| `:product_not_found` | Invalid product ID |
| `:user_not_found` | Invalid user ID |
| `:out_of_stock` | Inventory is 0 |
| `:vip_only` | Non-VIP attempting low-stock claim |
| `:sold_out` | Race condition edge case |

---

## 📦 Feature 2: Order Status Tracking with Audit Trail

### Impact

**Complete audit trail for customer service and compliance.** Every status change is recorded with timestamps, enabling support teams to answer "When did my order ship?" instantly.

### Technical Implementation

#### Transaction-Safe Event Creation
```ruby
after_update :create_status_change_event, if: :saved_change_to_status?
```
- `after_update` callback runs **inside** the save transaction
- If event creation fails, the entire status update rolls back
- Data integrity guaranteed — no orphaned status changes

#### Efficient Change Tracking
```ruby
saved_change_to_status?    # Only fires when status actually changed
status_before_last_save    # Access previous value without extra query
```
- Modern Rails dirty-tracking (not deprecated `*_changed?` / `*_was`)
- No event created when saving with same status or updating other fields

#### Future-Proof Metadata
```ruby
t.jsonb :metadata, default: {}
```
- Flexible schema for audit data (changed_at, changed_by, reason, etc.)
- No migrations needed to add new metadata fields
- Customer service can see full context of each change

### Verification (TDD)

```
Order
  status change event tracking
    when status changes
      ✓ creates an OrderEvent with correct from_status and to_status
      ✓ includes metadata with changed_at timestamp
    when status does NOT change
      ✓ does NOT create an OrderEvent when updating other attributes
      ✓ does NOT create an OrderEvent when saving with same status
    multiple status transitions
      ✓ creates an event for each status change

5 examples, 0 failures
```

---

## 🚚 Feature 3: Shipping Calculator

### Impact

**Standalone, reusable shipping rate calculator** for product pages (estimates) and checkout (final totals).

### Technical Implementation

- O(1) zone lookup via hash constant
- Weight bracket pricing: flat rate up to 2kg, per-kg rate above
- Idiomatic Ruby: `[0, weight - threshold].max` eliminates conditionals
- Error hashes (not exceptions) for invalid input — CPU-friendly at scale

### Verification

```
ShippingCalculator
  #call
    ✓ domestic under 2kg returns exactly $5 flat rate
    ✓ domestic at 5kg returns $11 ($5 base + 3kg extra at $2/kg)
    ✓ asia_pacific at 1kg returns $25 base rate
    ✓ invalid zone returns an error hash

4 examples, 0 failures
```

---

## Database Changes

### New Tables
- `users` — with `vip` boolean for tiered access
- `orders` — with `status` and index for filtering
- `order_events` — audit trail with `from_status`, `to_status`, `metadata` (jsonb)
- `restock_notifications` — with unique index on `(user_id, product_id)`

### Index Changes
- Replaced `(user_id, product_id)` composite index on `claims` with stricter `user_id` unique index (global limit enforcement)

---

## Files Changed

### Models
- `app/models/user.rb` — VIP scopes, associations
- `app/models/claim.rb` — belongs_to user
- `app/models/product.rb` — associations
- `app/models/order.rb` — status tracking with callback
- `app/models/order_event.rb` — audit record
- `app/models/restock_notification.rb` — notification signup

### Services
- `app/services/claims/create_claim_service.rb` — atomic claim logic
- `app/services/shipping_calculator.rb` — rate calculation

### Specs
- `spec/services/claims/create_claim_service_spec.rb`
- `spec/services/shipping_calculator_spec.rb`
- `spec/models/order_spec.rb`
- `spec/factories/*.rb`

---

## 🔮 Future Improvements

### Configuration
- [ ] Move `VIP_THRESHOLD` and `ZONE_RATES` to YAML config files
- [ ] Environment-specific thresholds (staging vs production)
- [ ] Admin UI for adjusting rates without deploy

### Observability
- [ ] Add structured logging for claim attempts (success/failure/reason)
- [ ] Metrics for claim latency and failure rates
- [ ] Alerting on unusual oversell patterns

### Features
- [ ] Waitlist position tracking for out-of-stock products
- [ ] Email notifications when restocked
- [ ] Per-product VIP thresholds (some items more exclusive than others)

### Order Tracking
- [ ] Add `changed_by` to metadata when CurrentAttributes is set up
- [ ] Webhook notifications on status changes
- [ ] Customer-facing order timeline UI

---

## How to Test

```bash
# Run all specs
bundle exec rspec --format documentation

# Run specific feature specs
bundle exec rspec spec/services/claims/create_claim_service_spec.rb
bundle exec rspec spec/models/order_spec.rb
bundle exec rspec spec/services/shipping_calculator_spec.rb
```

---

## Checklist

- [x] All tests passing (23 examples, 0 failures)
- [x] Database migrations reversible
- [x] No N+1 queries introduced
- [x] Error handling returns hashes (no exceptions for user input)
- [x] Race conditions handled at database level
- [x] Code follows Rails conventions and style guide

