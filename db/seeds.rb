# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data in development
if Rails.env.development?
  puts 'Clearing existing claims...'
  Claim.destroy_all
end

# Create test users
puts 'Creating users...'

vip_user = User.find_or_create_by!(email: 'vip@example.com') do |user|
  user.name = 'VIP Customer'
  user.vip = true
end
puts "  Created VIP user: #{vip_user.name} (ID: #{vip_user.id})"

regular_user = User.find_or_create_by!(email: 'regular@example.com') do |user|
  user.name = 'Regular Customer'
  user.vip = false
end
puts "  Created regular user: #{regular_user.name} (ID: #{regular_user.id})"

# Create a second regular user for testing global claim limit
regular_user_2 = User.find_or_create_by!(email: 'regular2@example.com') do |user|
  user.name = 'Another Regular Customer'
  user.vip = false
end
puts "  Created regular user: #{regular_user_2.name} (ID: #{regular_user_2.id})"

# Create test products
puts 'Creating products...'

standard_product = Product.find_or_create_by!(name: 'Standard Tee') do |product|
  product.inventory_count = 10
end
puts "  Created product: #{standard_product.name} (inventory: #{standard_product.inventory_count})"

limited_product = Product.find_or_create_by!(name: 'Limited Edition Hoodie') do |product|
  product.inventory_count = 3
end
puts "  Created product: #{limited_product.name} (inventory: #{limited_product.inventory_count}) - VIP ONLY"

sold_out_product = Product.find_or_create_by!(name: 'Sold Out Sneakers') do |product|
  product.inventory_count = 0
end
puts "  Created product: #{sold_out_product.name} (inventory: #{sold_out_product.inventory_count}) - SOLD OUT"

puts ''
puts '=== Seed Summary ==='
puts "Users: #{User.count} (VIP: #{User.vip.count}, Regular: #{User.non_vip.count})"
puts "Products: #{Product.count}"
puts ''
puts 'Test user IDs for API calls:'
puts "  VIP User ID: #{vip_user.id}"
puts "  Regular User ID: #{regular_user.id}"
puts "  Regular User 2 ID: #{regular_user_2.id}"
