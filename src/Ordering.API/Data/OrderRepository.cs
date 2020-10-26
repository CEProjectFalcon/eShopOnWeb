using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using Ordering.API.Interfaces;
using Ordering.API.Entities.OrderAggregate;
using System.Linq;
using System.Collections.Generic;

namespace Ordering.API.Data
{
    public class OrderRepository : EfRepository<Order>, IOrderRepository
    {
        public OrderRepository(OrderContext dbContext) : base(dbContext)
        {
        }

        public async Task<Order> GetById(int id)
        {
            return await _dbContext.Orders
                .Include(o => o.OrderItems)
                .Include($"{nameof(Order.OrderItems)}.{nameof(OrderItem.ItemOrdered)}")
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<IReadOnlyList<Order>> GetByBuyerId(string buyerId)
        {
            return await _dbContext.Orders
                .Where(o => o.BuyerId == buyerId)
                .Include(o => o.OrderItems)
                .ThenInclude(i => i.ItemOrdered)
                .ToListAsync();
        }
    }
}
