// List<User> usr = new List<User>([SELECT id, username, name, accountId FROM User WHERE id = '005Dn000006IdH1IAK']);
// List<Account> act = new List<Account>([SELECT id, type FROM Account WHERE id = '001Dn00000INKzOIAX']);
// System.debug(usr);
// System.debug(act);

// find user ID
// query contact id from user record
// query assoicated account on the contact record
// only works for portal users so pass null for not

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
    
  	@AuraEnabled(cacheable=true)
    public static List<String> userInfo() {
        //List<Account> acct = [SELECT id FROM Account WHERE id =: UserInfo.getUserID()];
        List<String> strList = new List<String> {
            'User Id: ' + UserInfo.getUserId(),
            'User Type: ' + UserInfo.getUserType(),
            'User Role Id: ' + UserInfo.getUserRoleId(),
            'User userName: ' + UserInfo.getUserName(),
            'User name: ' + UserInfo.getName(),
            'User email: ' + UserInfo.getUserEmail()
        };
       System.debug(strList);
       return strList;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<ConnectApi.ProductSummary> getProductList() {
        String webstoreId = '0ZEDn000000HehLOAS';
        ConnectApi.ProductSearchInput input = new ConnectApi.ProductSearchInput();
        input.searchTerm = 'samsung';
        ConnectApi.ProductSearchResults res = ConnectApi.CommerceSearch.searchProducts(webstoreId, null, input);
        for (ConnectApi.ProductSummary s : res.productsPage.products) {
            System.debug(s.id);
        } // for
        return res.productsPage.products;
    } // getProductList
    
} // ConnectToProductPage