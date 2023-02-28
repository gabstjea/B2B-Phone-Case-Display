/** 
 * This class represents the picklist value that a Product2 instance has for a facet. A 
 * facet is picklist that defines filterable fields on a Product2 object. This class is
 * Used by {@link FacetDisplay}. 
 * 
 * The class also functions as a datastructure to be used in the 'options' parameter of the
 * lightning-checkbox-group class. Hence the member variables 'label' and 'value'.
 */
public class FacetValue {
	@auraEnabled
	public String label; 
    
    @auraEnabled
    public String value;
    
    /**
     * The label and value variables are guranteed to be unique elements in a collection because 
     * the facet values come directly from the Product2 object.  
     */
    public FacetValue(String value) {
    	this.label = value;
        this.value = value;
	}
        
    public Boolean equals(Object obj) {
        if (obj instanceof FacetValue) {
            FacetValue fvObj = (FacetValue) obj;
            return value == fvObj.value;
        }
        return false;
    }
    
    public Integer hashCode() {
        return value.hashCode();
    }
    
}