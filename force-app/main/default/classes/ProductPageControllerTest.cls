// Test class for ProductPageController
// Admin info:
//     Digital Cases communityID - 0DBDn000000kEsROAU
//     Gmoney B2B store communityID - 0DBDn000000kDqvOAE 
//     Gmoney B2B store webID '0ZEDn000000HehLOAS'

@isTest(SeeAllData=true)
private class ProductPageControllerTest {
    
    @isTest static void displayUserCommerceIds() {     
        String userName = 'engineerb2b@publicis.dev';
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
        String userName = 'phonecasecustomer@phonecase.org';
        String communityId = '0DBDn000000kDqvOAE';
        String categoryLandingPage = 'iPhone';
        User contextUser = [SELECT id FROM User WHERE Username =: userName LIMIT 1];
        System.runAs(contextUser) {
           ProductPageController.getSearchResults(communityId, categoryLandingPage);
        }       
    } // getProductListTest
	
} // ProductPageControllerTest