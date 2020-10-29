using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.eShopWeb.Web.Interfaces;
using Microsoft.eShopWeb.Web.Pages.Basket;
using Microsoft.eShopWeb.Web.ViewModels;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Web.Pages.Shared.Components.BasketComponent
{
    public class Basket : ViewComponent
    {
        private readonly IBasketViewModelService _basketService;
        //private readonly SignInManager<ApplicationUser> _signInManager;

        public Basket(IBasketViewModelService basketService)
        {
            _basketService = basketService;
            //_signInManager = signInManager;
        }

        public async Task<IViewComponentResult> InvokeAsync(string userName)
        {
            var vm = new BasketComponentViewModel();
            vm.ItemsCount = (await GetBasketViewModelAsync()).Items.Sum(i => i.Quantity);
            return View(vm);
        }

        private async Task<BasketViewModel> GetBasketViewModelAsync()
        {
            if (User.Identity.IsAuthenticated)
            {
                var user = User as ClaimsPrincipal;
                return await _basketService.GetOrCreateBasketForUser(user.Claims.Where(c => c.Type == ClaimTypes.NameIdentifier).Select(c => c.Value).SingleOrDefault());
            }
            string anonymousId = GetBasketIdFromCookie();
            if (anonymousId == null) return new BasketViewModel();
            return await _basketService.GetOrCreateBasketForUser(anonymousId);
        }

        private string GetBasketIdFromCookie()
        {
            if (Request.Cookies.ContainsKey(Constants.BASKET_COOKIENAME))
            {
                return Request.Cookies[Constants.BASKET_COOKIENAME];
            }
            return null;
        }
    }
}
