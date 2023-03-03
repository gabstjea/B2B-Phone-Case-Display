import { LightningElement, api } from 'lwc';
import communityId from '@salesforce/community/Id';
import filterProductDisplay from '@salesforce/apex/ProductPageController.filterProductDisplay';

export default class filterCheckboxDisplay extends LightningElement {
    @api facetDisplay;
    @api categoryLandingPage;
    @api facetPillBox;
    isLoading = false;


    async handleCheckboxGroup(event) {
      this.isLoading = true;
      let facetPillBox = JSON.parse(JSON.stringify(this.facetPillBox));
      let facetDisplay = JSON.parse(JSON.stringify(this.facetDisplay));
      let selectedFacetDisplay = facetDisplay.filter(item => item.facetName === event.target.label)[0];
      if (event.detail.value.length < selectedFacetDisplay.selectedFacets.length ) { 
          let uncheckedItem = selectedFacetDisplay.selectedFacets.filter(e => event.detail.value.includes(e) !== true)[0];      
          facetPillBox = facetPillBox.filter( e => e.label.substring(e.label.indexOf(":") + 1).trim() !== uncheckedItem);
      } else { // add item to pillbox
          // Since elements are automatically sorted when added into the array, the newly added element can't be retireved from the last index
         let newlyAddedItem = event.detail.value.filter(e => selectedFacetDisplay.selectedFacets.includes(e) !== true)[0];  
         facetPillBox.push({label: event.target.label + ": " + newlyAddedItem, name: event.target.label});
      }

      selectedFacetDisplay.selectedFacets = event.detail.value;
      await filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage,  
                            facetDisplayJson: JSON.stringify(facetDisplay)})
              .then(r => {
                const checkboxSelectEvent = new CustomEvent("checkboxselect", {
                    detail:{facetDisplay: facetDisplay, facetPillBox: facetPillBox, filterResults: r}
                });  
                this.dispatchEvent(checkboxSelectEvent);   
            })
              .catch(e => {
               console.log(e);
              });
      this.finishedLoading();
    } // handleCheckBoxGroup

    /** 
     * Updates the facet display when a pill box is x'ed out
     * 
     * This method is invoked by productDisplay.js
     */
    @api
    async removePillBoxItem(event) {
        this.isLoading = true;
        let facetDisplay = JSON.parse(JSON.stringify(this.facetDisplay));
        let facetPillBox = JSON.parse(JSON.stringify(this.facetPillBox));

        const index = event.detail.index;
        let pillBoxLabel = event.detail.item.label
        let facetToUncheck =  pillBoxLabel.substring(pillBoxLabel.indexOf(":") + 1).trim();    
        // Retrieve the Facet Display item to update
        let selectedFacetDisplay = facetDisplay.filter(item => item.facetName === event.detail.item.name)[0];
        
        selectedFacetDisplay.selectedFacets =  selectedFacetDisplay.selectedFacets.filter(e => e !== facetToUncheck );
        facetPillBox.splice(index, 1); // Remove the pillbox  
        await filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage, 
                            facetDisplayJson: JSON.stringify(facetDisplay)})
              .then(r => {
                console.log(r);
                 const removePillEvent = new CustomEvent("removepillevent", {
                    detail:{facetDisplay: facetDisplay, facetPillBox: facetPillBox, filterResults: r}
                });  
                this.dispatchEvent(removePillEvent);         
              })
              .catch(e => {
                console.log(e);
              });
         this.finishedLoading();
    } // handlePIllBoxItemRemove

    async updateFacetDisplay() {
      
    }

    finishedLoading() {
      this.isLoading = false;
    }


}