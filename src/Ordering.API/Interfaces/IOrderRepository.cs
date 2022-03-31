using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Ordering.API.Entities.OrderAggregate;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Ordering.API.Interfaces
{
    public interface IOrderRepository : IAsyncRepository<Order>
    {
        Task<Order> GetById(int id);

        Task<IReadOnlyList<Order>> GetByBuyerId(string buyerId);
    }
}
