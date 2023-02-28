// Test class for ProductPageController
// Admin info:
//     Digital Cases communityID - 0DBDn000000kEsROAU
//     Gmoney B2B store communityID - 0DBDn000000kDqvOAE 
//     Gmoney B2B store webID '0ZEDn000000HehLOAS'

@isTest(SeeAllData=true)
private class ProductPageControllerTest {
    
    static String userName; 
    static String communityId;
    static String categoryLandingPage;
    
    static {
        userName ='engineerb2b@publicis.dev';
        communityId = '0DBDn000000kDqvOAE';
        categoryLandingPage = 'iPhone';
    }
    
    @isTest static void displayUserCommerceIds() {     
        User contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
        System.runAs(contextUser) {
            ConnectApi.CommunityPage communityPage = ConnectApi.Communities.getCommunities();
      	    for (ConnectApi.Community cp : communityPage.communities) {
            	System.debug('name: ' + cp.name);
            	System.debug('communityId: ' + cp.id);
            	System.debug('Web ID : ' + B2BUtils.resolveCommunityIdToWebstoreId(cp.id));
       		 } 
        } 
    } // displayUserCommerceIds
    
    @isTest static void getSearchResultsTest() {
        User contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
        System.runAs(contextUser) {
           ConnectApi.ProductSearchResults searchResults = ProductPageController.getSearchResults(communityId, categoryLandingPage);
           if (searchResults != null) {
               String productId = searchResults.productsPage.products.get(0).id;
               List<Product2> productSOQL = [SELECT id FROM Product2 WHERE id =: productId LIMIT 1];
               System.assertEquals(productId, productSOQL[0].id, 'products are not equal');
           } else {
               System.assertEquals(true, false, 'Search results is null');
           } // if
        }       
    } // getProductListTest
	
} // ProductPageControllerTest