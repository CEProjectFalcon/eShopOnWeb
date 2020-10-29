using System;
using Xunit;
using Microsoft.eShopWeb.ApplicationCore.Services;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.ApplicationCore.Entities.BasketAggregate;
using Microsoft.eShopWeb.ApplicationCore.Specifications;
using Microsoft.Extensions.Logging;
using Moq;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;
using Microsoft.eShopWeb.Web.Pages.Basket;

namespace UnitTests
{
    public class BasketServiceTests
    {
        [Fact]
        public async Task Add_An_Item_To_BasketAsync()
        {
            //Arrange
            var mockRepository = new Mock<IAsyncRepository<Basket>>();
            var mockLoger = new Mock<IAppLogger<BasketService>>();

            var basketid = 1;
            var catalogitemid = 1;
            var buyerid = "1";

            var basket = new Basket(buyerid);
            
            mockRepository.Setup(x => x.FirstOrDefaultAsync(It.IsAny<BasketWithItemsSpecification>())).Returns(Task.FromResult(basket));

            var basketService = new BasketService(mockRepository.Object, mockLoger.Object);

            //Act
            await basketService.AddItemToBasket(basketid, catalogitemid, 22);

            //Assert
            Assert.Equal(1, basket.Items.Count);
            Assert.Equal(catalogitemid, basket.Items.First().CatalogItemId);
        }

        [Fact]
        public async Task Delete_Basket()
        {
            //Arrange
            var mockRepository = new Mock<IAsyncRepository<Basket>>();
            var mockLoger = new Mock<IAppLogger<BasketService>>();

            var basketid = 1;
            var catalogitemid = 1;
            var buyerid = "1";

            var basket = new Basket(buyerid);
            basket.AddItem(catalogitemid, 22);

            mockRepository.Setup(x => x.GetByIdAsync(basketid)).Returns(Task.FromResult(basket));
            mockRepository.Setup(x => x.DeleteAsync(basket)).Callback(() => { basket = null; });

            var basketService = new BasketService(mockRepository.Object, mockLoger.Object);

            //Act
            await basketService.DeleteBasketAsync(basketid);

            //Assert
            Assert.Null(basket);
        }

        [Fact]
        public async void Add_An_Item_And_Set_Quantities_To_Basket()
        {
            //Arrange
            var mockRepository = new Mock<IAsyncRepository<Basket>>();
            var mockLoger = new Mock<IAppLogger<BasketService>>();

            var basketid = 1;
            var catalogitemid = 1;
            var buyerid = "1";

            var basket = new Basket(buyerid);
            basket.AddItem(catalogitemid, 22);

            var quantities = new Dictionary<string, int>() { { "0", 2 } };

            mockRepository.Setup(x => x.FirstOrDefaultAsync(It.IsAny<BasketWithItemsSpecification>())).Returns(Task.FromResult(basket));

            var basketService = new BasketService(mockRepository.Object, mockLoger.Object);

            //Act
            await basketService.SetQuantities(basketid, quantities);

            //Assert
            Assert.Equal(1, basket.Items.Count);
            Assert.Equal(2, basket.Items.First().Quantity);
            Assert.Equal(catalogitemid, basket.Items.First().CatalogItemId);
            Assert.Equal(22, basket.Items.First().UnitPrice);
        }

        public async void Calculate_Total_Basket()
        {
            //Arrange
            var basketviewmodel = new BasketViewModel();

            //var basketid = 1;
            //var catalogitemid = 1;
            //var buyerid = "1";

            //var basket = new Basket(buyerid);
            //basket.AddItem(catalogitemid, 22);

            //var quantities = new Dictionary<string, int>() { { "0", 2 } };

            //mockRepository.Setup(x => x.FirstOrDefaultAsync(It.IsAny<BasketWithItemsSpecification>())).Returns(Task.FromResult(basket));

            //var basketService = new BasketService(mockRepository.Object, mockLoger.Object);

            //Act
            //await basketService.SetQuantities(basketid, quantities);

            ////Assert
            //Assert.Equal(1, basket.Items.Count);
            //Assert.Equal(2, basket.Items.First().Quantity);
            //Assert.Equal(catalogitemid, basket.Items.First().CatalogItemId);
        }

    }
}
