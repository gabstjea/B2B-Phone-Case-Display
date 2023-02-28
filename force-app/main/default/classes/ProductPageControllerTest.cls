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
        String connectApiFacetResultsJson = '[{"attributeType":"Custom","displayName":"Brand","displayRank":2,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Brand__c","values":[{"displayName":"Apple","nameOrId":"Apple","productCount":5,"type":"DistinctValue"}]},{"attributeType":"Custom","displayName":"Product Line","displayRank":3,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Product_Line__c","values":[{"displayName":"Commuter Series","nameOrId":"Commuter Series","productCount":2,"type":"DistinctValue"},{"displayName":"Defender Series","nameOrId":"Defender Series","productCount":1,"type":"DistinctValue"},{"displayName":"Lumen Series","nameOrId":"Lumen Series","productCount":2,"type":"DistinctValue"}]},{"attributeType":"Custom","displayName":"Compatibility","displayRank":4,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Compatibility__c","values":[{"displayName":"iPhone 13","nameOrId":"iPhone 13","productCount":3,"type":"DistinctValue"},{"displayName":"iPhone 14","nameOrId":"iPhone 14","productCount":5,"type":"DistinctValue"}]},{"attributeType":"Custom","displayName":"Features","displayRank":5,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Features__c","values":[{"displayName":"3X Tested To Military Standard","nameOrId":"3X Tested To Military Standard","productCount":4,"type":"DistinctValue"},{"displayName":"4X Tested To Military Standard","nameOrId":"4X Tested To Military Standard","productCount":1,"type":"DistinctValue"},{"displayName":"Antimicrobial","nameOrId":"Antimicrobial","productCount":2,"type":"DistinctValue"}]},{"attributeType":"Custom","displayName":"Color","displayRank":6,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Color__c","values":[{"displayName":"Black","nameOrId":"Black","productCount":2,"type":"DistinctValue"},{"displayName":"Blue","nameOrId":"Blue","productCount":1,"type":"DistinctValue"},{"displayName":"Grey","nameOrId":"Grey","productCount":1,"type":"DistinctValue"},{"displayName":"Pink","nameOrId":"Pink","productCount":1,"type":"DistinctValue"}]},{"attributeType":"Custom","displayName":"Packaging","displayRank":7,"displayType":"MultiSelect","facetType":"DistinctValue","nameOrId":"Packaging__c","values":[{"displayName":"Pro-Pack","nameOrId":"Pro-Pack","productCount":2,"type":"DistinctValue"},{"displayName":"Retail","nameOrId":"Retail","productCount":3,"type":"DistinctValue"}]}]';
        String facetDisplayJson = '[{"facetName":"Brand","facetValues":[{"label":"Apple","value":"Apple"}],"selectedFacets":[]},{"facetName":"Product Line","facetValues":[{"label":"Defender","value":"Defender"},{"label":"Commuter","value":"Commuter"},{"label":"Lumen Series","value":"Lumen Series"}]';

        System.runAs(contextUser) {
           List<ConnectApi.ProductSummary>  productSummary = ProductPageController.filterProductDisplay(communityId, categoryLandingPage, connectApiFacetResultsJson, facetDisplayJson);
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