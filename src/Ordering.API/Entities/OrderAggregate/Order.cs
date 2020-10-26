using System;
using System.Collections.Generic;

namespace Ordering.API.Entities.OrderAggregate
{
    public class Order : BaseEntity
    {
        private Order()
        {
            // required by EF
        }

        public Order(string buyerId, Address shipToAddress, List<OrderItem> items)
        {
            BuyerId = buyerId;
            ShipToAddress = shipToAddress;
            OrderItems = items;
        }

        public string BuyerId { get; set; }
        public DateTimeOffset OrderDate { get; set; } = DateTimeOffset.Now;
        public Address ShipToAddress { get; set; }
        public List<OrderItem> OrderItems { get; set; }

        public decimal Total()
        {
            var total = 0m;
            foreach (var item in OrderItems)
            {
                total += item.UnitPrice * item.Units;
            }
            return total;
        }
    }
}
