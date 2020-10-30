using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using OrderApi.Entities.OrderAggregate;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace OrderApi.Interfaces
{
    public interface IOrderRepository : IAsyncRepository<Order>
    {
        Task<Order> GetById(int id);

        Task<IReadOnlyList<Order>> GetByBuyerId(string buyerId);
    }
}
