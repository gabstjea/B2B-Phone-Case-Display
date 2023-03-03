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
        categoryLandingPage = '0ZGDn000000M345OAC';
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
           ConnectApi.ProductSearchResults searchResults = ProductPageController.getSearchResults(communityId,
                                                                                                  categoryLandingPage);
           List<ConnectApi.ProductSummary> productSummaries = searchResults.productsPage.products;
		   Set<String> productId = new Set<String>();
           if (searchResults != null) {
               for (ConnectApi.ProductSummary ps : productSummaries) {
                   productId.add(ps.id);
			   } // for
            
               List<Product2> productSOQL = [SELECT id FROM Product2 WHERE id =: productId];
               if (productSOQL.size() == productSummaries.size()) {
                   System.debug('SOQL query product: ' + productSOQL);
                   System.debug('getSearchResults method: ' + productSummaries);
                   System.assert(false,'Query mismatch: System didn\'t retrieve all queried products from the' +
                                   'ConnectApi search results');
               }
             
           } else {
               System.assert(false, 'Search results is null');
           } // if
        }       
    } // getSearchResultsTest
    
    @isTest static void createFacetDisplayTest() {
        Map<String, String> displayNameToApiMap = new Map<String, String>();
        Map<String, ConnectApi.SearchFacet> facetNameMap = new Map<String, ConnectApi.SearchFacet>();
        System.runAs(contextUser) {
            ConnectApi.ProductSearchResults searchRes = ProductPageController.getSearchResults(communityId, categoryLandingPage);
            List<FacetDisplay> fdList = new List<FacetDisplay>(ProductPageController.createFacetDisplay(communityId, categoryLandingPage));
            System.assert(searchRes != null, 'Search result failed');
            // Building maps
            for (ConnectApi.SearchFacet sf : searchRes.facets) {
                facetNameMap.put(sf.displayName, sf);
                displayNameToApiMap.put(sf.displayName, sf.nameOrId);
            }
            
          	List<ConnectApi.ProductSummary> productSummaries = searchRes.productsPage.products;
            // Testing facet names
            for (FacetDisplay fd : fdList) {
                String apiName = displayNameToApiMap.get(fd.facetName);
                // Check if the facet name exists for the FacetDisplay
                ConnectApi.SearchFacet connectSearchFacet = facetNameMap.get(fd.facetName);
                System.assert(connectSearchFacet != null, 
                              'The facet: ' + fd.facetName + 'is not on the product');
                String fdValuesJson = JSON.serialize(fd.facetValues);
                            
                // For each product search result, check if the facet display contains the field value for all facets on the product
                for (ConnectApi.ProductSummary ps : productSummaries) {
                    String connectFeildValue = ps.fields.get(apiName).value;
                    // if field is a multiselect picklist
                    if (connectFeildValue.contains(';')) {  
                        for (String val : connectFeildValue.split(';')) {
                            System.assert(fdValuesJson.contains(val),
                                  'The object ' + ps.name + ' (' + ps.id + ') ' + 'does not have the field value: ' +
                                   val + 'does not exist on the facet display ' +  fd);
                        } // for
                    } else {
                        System.debug(connectFeildValue);
                 	    System.assert(fdValuesJson.contains(connectFeildValue),
                                  'The object ' + ps.name + ' (' + ps.id + ') ' + 'does not have the field value: ' +
                                  connectFeildValue + 'does not exist on the facet display ' +  fd);
                    } // if	
                }// for
            } // for
        }        
    } // createFacetDisplayTest
    
    
       @isTest static void filterProductDisplaysTest() {
        String facetNameToTest = 'Color__c';
        String expectedFeildValue = 'Blue';
        List<FacetDisplay> dummyFacetDisplay = dummyFacetDisplayIphone();
        String facetDisplayJson = JSON.serialize(dummyFacetDisplayIphone());

        System.runAs(contextUser) {
           List<ConnectApi.ProductSummary> productSummary = ProductPageController.filterProductDisplay(communityId, categoryLandingPage, facetDisplayJson);
           if (productSummary != null) {
               // for each product result, check if the field value matches the facet criteria
               for (ConnectApi.ProductSummary ps : productSummary) { 
                   String connectFeildValue = ps.fields.get(facetNameToTest).value;
                   System.assert(connectFeildValue == expectedFeildValue, 
                       'The object ' + ps.name + ' (' + ps.id + ') ' + 'does not have the field value: ' + 
                       connectFeildValue + ' for the facet ' + facetNameToTest + ' in the Facet Display: ' +
                       dummyFacetDisplay);
               } 
           } else {
               System.assertEquals(true, false, 'filterProductDisplay Failed: Search results is null');
           } // if
        }       
    } // filterProductDisplaysTest
    
    
    // Creates hardcoded facet display values for testing
    public static List<FacetDisplay> dummyFacetDisplayIphone() {
        List<FacetDisplay> fdList = new List<FacetDisplay>();
        FacetDisplay brandFd = new FacetDisplay('Brand',
                                           new List<FacetValue> {
                                               new FacetValue('Apple')
                                           });
        FacetDisplay productLineFd = new FacetDisplay('Product Line',
                                           new List<FacetValue> {
                                               new FacetValue('Defender Series'),
                                               new FacetValue('Commuter Series'),  
                                               new FacetValue('Lumen Series')
                                           });
        FacetDisplay compatibilityFd = new FacetDisplay('Compatibility',
                                           new List<FacetValue> {
                                               new FacetValue('iPhone 13'),
                                               new FacetValue('iPhone 14')                                              
                                           });
        FacetDisplay featuresFd = new FacetDisplay('Features',
                                           new List<FacetValue> {
                                               new FacetValue('3X Tested To Military Standard'),
                                               new FacetValue('4X Tested To Military Standard'),                                          
                                               new FacetValue('Antimicrobial')     
                                           });
       FacetDisplay colorFd = new FacetDisplay('Color',
                                           new List<FacetValue> {
                                               new FacetValue('Blue'),
                                               new FacetValue('Black'), 
                                               new FacetValue('Grey'),
                                               new FacetValue('Pink')
                                           });
        FacetDisplay packagingFd = new FacetDisplay('Packaging',
                                           new List<FacetValue> {
                                               new FacetValue('Pro-Pack'),
                                               new FacetValue('Retail')                                              
                                           });
        
        // brandFd.selectedFacets =  new List<String> {};
    	// productLineFd.selectedFacets = new List<String> {};
    	// compatibilityFd.selectedFacets = new List<String> {};
    	// featuresFd.selectedFacets = new List<String> {};
        colorFd.selectedFacets = new List<String> {'Blue'};
        // packagingFd.selectedFacets =  new List<String> {};


        fdList.add(brandFd);
        fdList.add(productLineFd);
        fdList.add(compatibilityFd);
        fdList.add(featuresFd);
        fdList.add(colorFd);
        fdList.add(packagingFd);                                       
        return fdList;
    }
    
	
} // ProductPageControllerTest