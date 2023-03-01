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
    static User contextUser;
    
    static {
        userName ='engineerb2b@publicis.dev';
        communityId = '0DBDn000000kDqvOAE';
        categoryLandingPage = 'iPhone';
        contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
    }
    
    @isTest static void displayUserCommerceIds() {     
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
        System.runAs(contextUser) {
           ConnectApi.ProductSearchResults searchResults = ProductPageController.getSearchResults(communityId, categoryLandingPage);
           if (searchResults != null) {
               String productId = searchResults.productsPage.products.get(0).id;
               List<Product2> productSOQL = [SELECT id FROM Product2 WHERE id =: productId LIMIT 1];
               System.assertEquals(productId, productSOQL[0].id, 'products do not match');
           } else {
               System.assertEquals(true, false, 'Search results is null');
           } // if
        }       
    } // getSearchResultsTest
    
    @isTest static void createFacetDisplayTest() {
        Map<String, List<FacetValue>> faceNameToFacetValues = new Map<String, List<FacetValue>>();
        System.runAs(contextUser) {
           List<FacetDisplay> fdList = new List<FacetDisplay>(ProductPageController.createFacetDisplay(communityId, categoryLandingPage));
           if (fdList != null) {
               for (FacetDisplay facet: fdList) {
                   faceNameToFacetValues.put(facet.facetName, facet.facetValues);
               }
               String feildValue = faceNameToFacetValues.get('Color')[0].label;
               List<Product2> productSOQL = [SELECT id FROM Product2 WHERE Color__c =: feildValue];
			   System.assertNotEquals(null, productSOQL, 'Assert failed: Query did not return any values');
           } else {
               System.assertEquals(true, false, 'Facet display is null');
           } // if
        }       
    } // createFacetDisplayTest
    
    
       @isTest static void filterProductDisplaysTest() {
        String facetDisplayJson = '[{"facetName":"Brand","facetValues":[{"label":"Apple","value":"Apple"}],"selectedFacets":[]},{"facetName":"Product Line","facetValues":[{"label":"Defender","value":"Defender"},{"label":"Commuter","value":"Commuter"},{"label":"Lumen Series","value":"Lumen Series"}]';

        System.runAs(contextUser) {
           List<ConnectApi.ProductSummary>  productSummary = ProductPageController.filterProductDisplay(communityId, categoryLandingPage, facetDisplayJson);
           if (productSummary != null) {
               for (ConnectApi.ProductSummary ps : productSummary) {
                   System.debug(ps);
               }
           } else {
               System.assertEquals(true, false, 'Search results is null');
           } // if
        }       
    } // filterProductDisplaysTest
    
	
} // ProductPageControllerTest