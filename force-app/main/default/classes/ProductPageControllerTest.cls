// Test class for ProductPageController

@isTest(SeeAllData=true)
private class ProductPageControllerTest {
    
  
    
    @isTest static void testWebstoreId() {
        // Admin info
        // Digital Cases CommunityID - 0DBDn000000kEsROAU
        // Gmoney B2B store - 0DBDn000000kDqvOAE 
        // Gmoney B2B store webID '0ZEDn000000HehLOAS'
        
        getCommerceIds('engineerb2b@publicis.dev');
    } // testWebstoreId
    
    @isTest static void testConextUser() {
        String userName = 'phonecasecustomer@phonecase.org';
        User contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
        System.runAs(contextUser) {
           ProductPageController.createFacetPicklistMap();
        }       
    }
	
    /** 
     * Utility method used to retrieve the commerce and websoreId for a context User
    */ 
     private static void getCommerceIds(String username) {
        User contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
        System.runAs(contextUser) {
            ConnectApi.CommunityPage communityPage = ConnectApi.Communities.getCommunities();
      	    for (ConnectApi.Community cp : communityPage.communities) {
            	System.debug('name: ' + cp.name);
            	System.debug('communityId: ' + cp.id);
            	System.debug('Web ID : ' + B2BUtils.resolveCommunityIdToWebstoreId(cp.id));
                
       		 } 
        } 
	} // getCommericeIds

}