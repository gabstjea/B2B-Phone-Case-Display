import { LightningElement, api } from 'lwc';
import communityId from '@salesforce/community/Id';
import filterProductDisplay from '@salesforce/apex/ProductPageController.filterProductDisplay';

export default class filterCheckboxDisplay extends LightningElement {
    @api facetDisplay;
    @api activeAccordionSections;
    @api categoryLandingPage;
    @api facetPillBox;

    handleCheckBoxGroup(event) {
      let facetPillBox = JSON.parse(JSON.stringify(this.facetPillBox));
      let facetDisplay = JSON.parse(JSON.stringify(this.facetDisplay))
      let selectedFacetDisplay = facetDisplay.filter(item => item.facetName === event.target.label)[0];

      if (event.detail.value.length < selectedFacetDisplay.selectedFacets.length ) { 
          let uncheckedItem = selectedFacetDisplay.selectedFacets.filter(e => event.detail.value.includes(e) !== true)[0];      
          facetPillBox = facetPillBox.filter( e => e.label.substring(e.label.indexOf(":") + 1).trim() !== uncheckedItem);
      } else { // add item to pillbox
          // Since elements are automatically sorted when added into the array, the newly added element can't be retireved from the last index
         let newlyAddedItem = event.detail.value.filter(e => selectedFacetDisplay.selectedFacets.includes(e) !== true)[0];  
         if (newlyAddedItem !== undefined)  { // may result in undefined if the user clicks the box too fast
             facetPillBox.push({label: event.target.label + ": " + newlyAddedItem, name: event.target.label});
         } 
      }

      selectedFacetDisplay.selectedFacets = event.detail.value;
      filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage,  
                            facetDisplayJson: JSON.stringify(facetDisplay)})
              .then(r => {
                const checkBoxSelectEvent = new CustomEvent("checkboxselect", {
                    detail:{facetDisplay: facetDisplay, facetPillBox: facetPillBox, filterResults: r}
                });  
                this.dispatchEvent(checkBoxSelectEvent);   
            })
              .catch(e => {
               console.log(e);
              });
    } // handleCheckBoxGroup

}