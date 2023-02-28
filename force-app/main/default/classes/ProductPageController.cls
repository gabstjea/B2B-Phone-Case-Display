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
        
    /**
     * Returns the search results from the ConnectApi Commerce Search class.
     * 
     * @param communityId - the ID of the experience cloud site that the context user is accessing
     * @param categoryLandingPage - the literals used to generate a search result
     */
    @AuraEnabled(cacheable=false)
    public static ConnectApi.ProductSearchResults getSearchResults(String communityId, String categoryLandingPage) {
        // String webstoreId = '0ZEDn000000HehLOAS';
        // CommunityID = '0DBDn000000kDqvOAE';
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.ProductSearchInput input = new ConnectApi.ProductSearchInput();
        input.searchTerm = categoryLandingPage;
        input.includePrices = True;
        input.includeQuantityRule = True;
        ConnectApi.ProductSearchResults searchResults = ConnectApi.CommerceSearch.searchProducts(webstoreId, null, input);
        return searchResults;
	} // getSearchResults
        
    
    // Maps facet names (keys) to their Api names 
    private static Map<String, JSON2ApexSearchFacet> createFacetResultsMap(String connectApiFacetResultsJson) {
        // Recieved JSON parser errors when trying to cast directly into List<ConnectApi.SearchFacet>, so a custom class is used
        List<JSON2ApexSearchFacet> facetResults = JSON2ApexSearchFacet.parse(connectApiFacetResultsJson);
        Map<String, JSON2ApexSearchFacet> facetResultsMap = new Map<String, JSON2ApexSearchFacet>();
        for (JSON2ApexSearchFacet facet : facetResults) {
            facetResultsMap.put(facet.displayName, facet);
		}
        return facetResultsMap;
	}
    
    /**
     * Returns a map of the Api names used in the facet (IDs) and their associated picklist
     * values as a concatenated string. 
     * 
     * Method may be deprecarted if there is a method to retrieve the ConnectApi.ProductSearchResults as
     * a parameter from the LWC.
     */
    @AuraEnabled(cacheable=false)
    public static List<FacetDisplay> createFacetDisplay(String communityId, String categoryLandingPage) {
      	ConnectApi.ProductSearchResults searchResults = getSearchResults(communityId, categoryLandingPage);
        Set<FacetValue> fvSet = new Set<FacetValue>();
        List<FacetDisplay> fdList = new List<FacetDisplay>();
	    
        // maps facet api names (keys) to their display name
        Map<String, String> facetApiMap = new Map<String, String>(); 
        
        // maps facet display names (keys) to their facet info
        Map<String, ConnectApi.SearchFacet> facetResultsMap = new Map<String, ConnectApi.SearchFacet>();
        for (ConnectApi.SearchFacet facet : searchResults.facets) {
            facetApiMap.put(facet.nameOrId, facet.displayName); 
            facetResultsMap.put(facet.displayName, facet); 
        } // for
		
        // for each field in the ConnectApi.ProductSummary (the product), create a FacetDisplay item
        for (String facetApiName : facetApiMap.keySet()) {
            String displayName =  facetApiMap.get(facetApiName);
            fvSet.clear();
            for (ConnectApi.ProductSummary ps : searchResults.productsPage.products) {
                String fieldValue = ps.fields.get(facetApiName).value;
                // If the field is a multiselect, parse multiselect values into a collection
                if (facetResultsMap.get(displayName).displayType == ConnectApi.CommerceSearchFacetDisplayType.MultiSelect) {
                    for (String fieldVal : fieldValue.split(';')) {
                    	fvSet.add(new FacetValue(fieldVal));
                    } 
                } else {
            		fvSet.add(new FacetValue(fieldValue));
                }   
			} // for
            List<FacetValue> fvList = new List<FacetValue>(fvSet);
            fdList.add(new FacetDisplay(displayName, fvList));
        }
        for (FacetDisplay fd : fdList) {
        	System.debug(fd);
        }
        return fdList;
	} // createFacetPicklistMap
    
    @AuraEnabled(cacheable=false)
    public static List<FacetDisplay> dummyFacetDisplay(String connectApiFacetResultsJson, String categoryLandingPage) {
  		Map<String, JSON2ApexSearchFacet> facetResultsMap = createFacetResultsMap(connectApiFacetResultsJson);
        System.debug(facetResultsMap);
        List<FacetDisplay> fdList = new List<FacetDisplay>();
    
        FacetDisplay brandFd = new FacetDisplay('Brand',
                                           new List<FacetValue> {
                                               new FacetValue('Apple')
                                           });
        FacetDisplay productLineFd = new FacetDisplay('Product Line',
                                           new List<FacetValue> {
                                               new FacetValue('Defender'),
                                               new FacetValue('Commuter'),  
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
                                               new FacetValue('Pink')
                                           });
        FacetDisplay packagingFd = new FacetDisplay('Packaging',
                                           new List<FacetValue> {
                                               new FacetValue('Pro-Pack'),
                                               new FacetValue('Retail')                                              
                                           });
        fdList.add(brandFd);
        fdList.add(productLineFd);
        fdList.add(compatibilityFd);
        fdList.add(featuresFd);
        fdList.add(colorFd);
        fdList.add(packagingFd);                                       
        return fdList;
    }
    
   /**
     * Adds refinements to a search key so that it can return a filtered list of results. 
     */
    @AuraEnabled(cacheable=false)
    public static List<ConnectApi.ProductSummary> filterProductDisplay(String communityId, String categoryLandingPage, 
                                                                       String connectApiFacetResultsJson, 
                                                                       String facetDisplayJson) {
        List<FacetDisplay> facetDisplay = FacetDisplay.parseJson(facetDisplayJson);
                                            
     	Map<String, JSON2ApexSearchFacet> facetResultsMap = createFacetResultsMap(connectApiFacetResultsJson);
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);        
        ConnectApi.ProductSearchInput sInput = new ConnectApi.ProductSearchInput();
        ConnectApi.DistinctValueRefinementInput rInput;
		List<ConnectApi.RefinementInput> rInputList = new List<ConnectApi.RefinementInput>();
		List<String> filterList;
       
		sInput.searchTerm = categoryLandingPage; 
        
        // Refine the search input
        for (FacetDisplay fd : facetDisplay) {
            System.debug(fd);
            rInput = new ConnectApi.DistinctValueRefinementInput();
            JSON2ApexSearchFacet facetInfo = facetResultsMap.get(fd.facetName);
            String apiName = facetInfo.nameOrId;
            String attributeType = facetInfo.attributeType;
         
            if (facetInfo.attributeType == 'Custom') {
            	rInput.attributeType = ConnectApi.CommerceSearchAttributeType.Custom;
            } else if (facetInfo.attributeType == 'Standard') {
                rInput.attributeType = ConnectApi.CommerceSearchAttributeType.Standard;
            } else if (facetInfo.attributeType == 'ProductAttribute') {
                rInput.attributeType = ConnectApi.CommerceSearchAttributeType.ProductAttribute;
            } else {
                rInput.attributeType = ConnectApi.CommerceSearchAttributeType.ProductCategory;
            }
         
			rInput.nameOrId = apiName;
       	    filterList = new List<String>(fd.selectedFacets);
			rInput.values = filterList;
			rInputList.add(rInput);
        }
               
		sInput.refinements = rInputList;
		ConnectApi.ProductSearchResults rSearchResults = ConnectApi.CommerceSearch.searchProducts(webstoreId, null, sInput);

        return rSearchResults.productsPage.products;
    } // filterSearch

   
   
} // ConnectToProductPage