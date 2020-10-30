using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using OrderingApi.Entities.OrderAggregate;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace OrderingApi.Interfaces
{
    public interface IOrderRepository : IAsyncRepository<Order>
    {
        Task<Order> GetById(int id);

        Task<IReadOnlyList<Order>> GetByBuyerId(string buyerId);
    }
}
