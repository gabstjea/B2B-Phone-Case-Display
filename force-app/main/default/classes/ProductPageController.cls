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
    
    public static ConnectApi.ProductSearchResults res;
    
    /**
     * Returns a list of products from a B2B store's search index.
     * 
     * @param communityId - the ID of the experience cloud site that the context user is accessing
     * @param searchKey - the literals used to generate a search result
     */
    @AuraEnabled(cacheable=false)
    public static List<ConnectApi.ProductSummary> getProductList(String communityId, String searchKey) {
        // String webstoreId = '0ZEDn000000HehLOAS';
        // CommunityID = '0DBDn000000kDqvOAE';
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.ProductSearchInput input = new ConnectApi.ProductSearchInput();
        input.searchTerm = searchKey;
        res = ConnectApi.CommerceSearch.searchProducts(webstoreId, null, input);
        return res.productsPage.products;
    } // getProductList
    
    /**
     * Adds refinements to a search key so that it can return a filtered list of results. 
     */
    private static void filterSearch() {
        ConnectApi.ProductSearchInput searchKey = new ConnectApi.ProductSearchInput();
		searchKey.searchTerm = 'iPhone';
		ConnectApi.DistinctValueRefinementInput rInput = new ConnectApi.DistinctValueRefinementInput();
		rInput.attributeType = ConnectApi.CommerceSearchAttributeType.Custom;
		rInput.nameOrId = 'Color__c';
        List<String> values = new List<String> {'Black'};
		rInput.values = values;
		List<ConnectApi.RefinementInput> rInputList = new List<ConnectApi.RefinementInput>();
		rInputList.add(rInput);
		searchKey.refinements = rInputList;
		res = ConnectApi.CommerceSearch.searchProducts('0ZEDn000000HehLOAS', null, searchKey);
		System.debug('ProductSearchResults = ' + res.toString());
         for (ConnectApi.ProductSummary s : res.productsPage.products) {
            System.debug('name: ' + s.name);
            System.debug('fields: ' + s.fields);
        } // for
    } // filterSearch
    
} // ConnectToProductPage