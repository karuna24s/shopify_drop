class ShippingCalculator
  # Currency constant - ready for i18n expansion
  DEFAULT_CURRENCY = "USD".freeze

  # Weight threshold for flat rate pricing (in kg)
  WEIGHT_BRACKET_THRESHOLD = 2.0

  # Zone configuration: base_rate, per_kg_rate (for weight over threshold), delivery window
  ZONE_RATES = {
    "domestic" => { base_rate: 5.00, per_kg_rate: 2.00, delivery_days: 3..5 },
    "north_america" => { base_rate: 15.00, per_kg_rate: 4.00, delivery_days: 5..10 },
    "europe" => { base_rate: 20.00, per_kg_rate: 5.00, delivery_days: 7..14 },
    "asia_pacific" => { base_rate: 25.00, per_kg_rate: 6.00, delivery_days: 10..21 },
    "rest_of_world" => { base_rate: 30.00, per_kg_rate: 8.00, delivery_days: 14..28 }
  }.freeze

  def initialize(weight:, destination_zone:)
    @weight = weight.to_f
    @destination_zone = destination_zone.to_s.downcase
  end

  def call
    return { success: false, error: :invalid_weight } if @weight <= 0
    return { success: false, error: :invalid_zone } unless valid_zone?

    {
      success: true,
      rate: calculate_rate,
      currency: DEFAULT_CURRENCY,
      estimated_delivery_days: format_delivery_days
    }
  end

  private

  def valid_zone?
    ZONE_RATES.key?(@destination_zone)
  end

  def zone_config
    ZONE_RATES[@destination_zone]
  end

  def calculate_rate
    base = zone_config[:base_rate]
    additional_weight = [ 0, @weight - WEIGHT_BRACKET_THRESHOLD ].max
    base + (additional_weight * zone_config[:per_kg_rate])
  end

  def format_delivery_days
    range = zone_config[:delivery_days]
    "#{range.first}-#{range.last} business days"
  end
end
