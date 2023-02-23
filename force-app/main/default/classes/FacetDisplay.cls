/** 
 * The purpose of the this class is to create a manegable data structure for a LWC to acess
 * metadata pertaining to the facets on a Product2 object. Facets on a Product2 object 
 * are picklist values which are represented by the {@link FacetValue} class. A facet defines the field
 * values that an instance of a Product2 object can be filtered by. So, this class is used to store 
 * filterable fields for a collection of Product2 objects.
 * 
 * Since aura enabled fields do not support Sets, ensure that their are no duplicate facet values in
 * {@code facetValues}. 
 */
public class FacetDisplay {
    @auraEnabled
	public String facetName; // Stores the name of the facet (picklist name)
    @auraEnabled
    public List<FacetValue> facetValues; // Stores the facet values that can be filtered
    @auraEnabled
    public List<String> selectedFacets; // Stores the selected facets in the LWC (Used in a checkbox component)

    public FacetDisplay(String facetName, List<FacetValue> facetValues) {
        this.facetName = facetName;
        this.facetValues = facetValues;
        selectedFacets = new List<String>();
    }
    

    public static List<FacetDisplay> parseJson(String json) {
		return (List<FacetDisplay>) System.JSON.deserialize(json, List<FacetDisplay>.class);
	}
}