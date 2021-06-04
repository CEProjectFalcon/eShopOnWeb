using BlazorAdmin.Pages.CatalogItemPage;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.eShopWeb.Web.Services;
using Microsoft.eShopWeb.Web.ViewModels;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Web.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ICatalogViewModelService _catalogViewModelService;
        private readonly TelemetryClient _telemetryClient;

        public IndexModel(ICatalogViewModelService catalogViewModelService, TelemetryClient telemetryClient)
        {
            _catalogViewModelService = catalogViewModelService;
            _telemetryClient = telemetryClient;
        }

        public CatalogIndexViewModel CatalogModel { get; set; } = new CatalogIndexViewModel();

        public async Task OnGet(CatalogIndexViewModel catalogModel, int? pageId)
        {
            CatalogModel = await _catalogViewModelService.GetCatalogItems(pageId ?? 0, Constants.ITEMS_PER_PAGE, catalogModel.BrandFilterApplied, catalogModel.TypesFilterApplied);

            if(catalogModel.BrandFilterApplied != null)
            {
                SelectListItem itemBrand = CatalogModel.Brands.Where(brand => brand.Value == catalogModel.BrandFilterApplied.ToString()).FirstOrDefault();

                _telemetryClient.TrackPageView(itemBrand.Text);
            }

            if (catalogModel.TypesFilterApplied != null)
            {
                SelectListItem itemType = CatalogModel.Types.Where(type => type.Value == catalogModel.TypesFilterApplied.ToString()).FirstOrDefault();

                _telemetryClient.TrackPageView(itemType.Text);
            }
        }
    }
}