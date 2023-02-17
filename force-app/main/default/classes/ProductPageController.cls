// This class utilizes Connect Apex to integrate search results from a B2B Commerce store
// 
// Important parameters:
// communityId - the ID of the experience cloud site that the context user is accessing
// webstoreId - the ID of the webstore being accessed by the User
//     * To obtain manually:
//         - Go to the store's workspace on the Lightning platform
//         - Copy the ID in the URL
// effectiveAccountId - the ID of the account for which the request is made. If null, defaults to the account ID
//                      of the context user.
//     * To get effective AccountId:
//         - Get the ID of User with UserInfo.getUserId()
//         - Query the account with matching user ID
//                        

public without sharing class ProductPageController {
    
    public static void refinement() {
        ConnectApi.ProductSearchInput sInput = new ConnectApi.ProductSearchInput();
		sInput.searchTerm = 'coffee';
		ConnectApi.DistinctValueRefinementInput rInput = new ConnectApi.DistinctValueRefinementInput();
		rInput.attributeType = ConnectApi.CommerceSearchAttributeType.Custom;
		rInput.nameOrId = 'Size__c';
		List<String> values = new List<String>();
		values.add('L');
		rInput.values = values;
		List<ConnectApi.RefinementInput> refinementInputs = new List<ConnectApi.RefinementInput>();
		refinementInputs.add(rInput);
		sInput.refinements = refinementInputs;
		ConnectApi.ProductSearchResults results = ConnectApi.CommerceSearch.searchProducts(
  		  '0ZEDn000000HehLOAS', null, sInput);
		System.debug('ProductSearchResults = ' + results.toString());
    }
    
 
    
    /**
     * Returns a list of products from a B2B store's search index.
     * 
     * @param communityId - the ID of the experience cloud site that the context user is accessing
     * @param searchKey - the literals used to generate a search result
     */
    @AuraEnabled(cacheable=false)
    public static List<ConnectApi.ProductSummary> getProductList(String communityId, String searchKey) {
        // String webstoreId = '0ZEDn000000HehLOAS';
         String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(
            communityId
        );
        ConnectApi.ProductSearchInput input = new ConnectApi.ProductSearchInput();
        input.searchTerm = searchKey;
        ConnectApi.ProductSearchResults res = ConnectApi.CommerceSearch.searchProducts(webstoreId, null, input);
        for (ConnectApi.ProductSummary s : res.productsPage.products) {
            System.debug(s.id);
        } // for
        return res.productsPage.products;
    } // getProductList
    
} // ConnectToProductPage