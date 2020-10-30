using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using OrderingApi.Entities.OrderAggregate;
using OrderingApi.Interfaces;

namespace OrderingApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderController : ControllerBase
    {
        private readonly ILogger<OrderController> _logger;
        private readonly IOrderRepository _orderRepository;

        public OrderController(IOrderRepository orderRepository, ILogger<OrderController> logger)
        {
            _orderRepository = orderRepository;
            _logger = logger;
        }

        [HttpGet("GetByBuyerId/{buyerId}")]
        public async Task<ActionResult<IReadOnlyList<Order>>> GetByBuyerId(string buyerId)
        {
            if (string.IsNullOrEmpty(buyerId))
            {
                return new BadRequestResult();
            }

            return new OkObjectResult(await _orderRepository.GetByBuyerId(buyerId).ConfigureAwait(false));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Order>> GetById(int id)
        {
            if (id == 0)
            {
                return new BadRequestResult();
            }

            return new OkObjectResult(await _orderRepository.GetById(id).ConfigureAwait(false));
        }

        [HttpPost]
        public async Task<ActionResult> Add(Order order)
        {
            await _orderRepository.AddAsync(order).ConfigureAwait(false);
            return new OkResult();
        }
    }
}
