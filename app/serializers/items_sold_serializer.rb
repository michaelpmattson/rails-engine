# class ItemsSoldSerializer
#   include JSONAPI::Serializer
#
#   attributes :name, :count
# end


class ItemsSoldSerializer
  def self.format_items_sold(merchants)
    {
      data: merchants.map do |merchant|
              {
                id: merchant.id.to_s,
                type: "items_sold",
                attributes: {
                  name: merchant.name,
                  count: merchant.items_sold
                }
              }
            end
    }
  end
end
