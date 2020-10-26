namespace Ordering.API.Entities.OrderAggregate
{
    /// <summary>
    /// Represents a snapshot of the item that was ordered. If catalog item details change, details of
    /// the item that was part of a completed order should not change.
    /// </summary>
    public class CatalogItemOrdered // ValueObject
    {
        public CatalogItemOrdered(int catalogItemId, string productName, string pictureUri)
        {
            CatalogItemId = catalogItemId;
            ProductName = productName;
            PictureUri = pictureUri;
        }

        private CatalogItemOrdered()
        {
            // required by EF
        }

        public int CatalogItemId { get; set; }
        public string ProductName { get; set; }
        public string PictureUri { get; set; }
    }
}
