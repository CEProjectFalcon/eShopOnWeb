using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.Web.ViewModels;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Web.Controllers
{
    [ApiExplorerSettings(IgnoreApi = true)]
    [Authorize] // Controllers that mainly require Authorization still use Controller/View; other pages use Pages
    [Route("[controller]/[action]")]
    public class OrderController : Controller
    {
        private readonly IHttpClientFactory _clientFactory;

        public OrderController(IHttpClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        [HttpGet]
        public async Task<IActionResult> MyOrders()
        {
            var client = _clientFactory.CreateClient("order-api");
            var response = await client.GetAsync($"/Order/GetByBuyerId/{User.Identity.Name}").ConfigureAwait(false);
            var jsonString = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
            var orders = JsonConvert.DeserializeObject<IReadOnlyList<Order>>(jsonString);

            var viewModel = orders.Select(o => new OrderViewModel
            {
                OrderDate = o.OrderDate,
                OrderItems = o.OrderItems?.Select(oi => new OrderItemViewModel()
                {
                    PictureUrl = oi.ItemOrdered.PictureUri,
                    ProductId = oi.ItemOrdered.CatalogItemId,
                    ProductName = oi.ItemOrdered.ProductName,
                    UnitPrice = oi.UnitPrice,
                    Units = oi.Units
                }).ToList(),
                OrderNumber = o.Id,
                ShippingAddress = o.ShipToAddress,
                Total = o.Total()
            });

            return View(viewModel);
        }

        [HttpGet("{orderId}")]
        public async Task<IActionResult> Detail(int orderId)
        {
            var client = _clientFactory.CreateClient("order-api");
            var response = await client.GetAsync($"/Order/{orderId}").ConfigureAwait(false);
            var jsonString = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
            var order = JsonConvert.DeserializeObject<Order>(jsonString);

            if (!order.BuyerId.Equals(User.Identity.Name, System.StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest("No such order found for this user.");
            }

            var viewModel = new OrderViewModel
            {
                OrderDate = order.OrderDate,
                OrderItems = order.OrderItems.Select(oi => new OrderItemViewModel
                {
                    PictureUrl = oi.ItemOrdered.PictureUri,
                    ProductId = oi.ItemOrdered.CatalogItemId,
                    ProductName = oi.ItemOrdered.ProductName,
                    UnitPrice = oi.UnitPrice,
                    Units = oi.Units
                }).ToList(),
                OrderNumber = order.Id,
                ShippingAddress = order.ShipToAddress,
                Total = order.Total()
            };

            return View(viewModel);
        }
    }
}
