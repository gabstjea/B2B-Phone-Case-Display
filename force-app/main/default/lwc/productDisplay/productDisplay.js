import { LightningElement, api, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import getSearchResults from '@salesforce/apex/ProductPageController.getSearchResults';
import createFacetDisplay from '@salesforce/apex/ProductPageController.createFacetDisplay';
import { CurrentPageReference } from 'lightning/navigation';

// This component serves as a testing ground for the product display and listing component

export default class FilterPrompt extends LightningElement {
   
    @api productList;
    @api facetDisplay; // Stores a deep copy of the List<FacetDisplay> object from the createFacetDisplay Apex method 
    @api activeAccordionSections = [];
    @api categoryLandingPage = '0ZGDn000000M345OAC';
    @api facetPillBox = [];
    isFacetAdded = false;



    // Obtains the url of the current page
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       console.log('current page');
       if (currentPageReference.attributes.recordId !== undefined) {
          this.categoryLandingPage = currentPageReference.attributes.recordId;
          this.refreshProductDisplay();
        } // if
    }

   refreshProductDisplay() {
         getSearchResults({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
              this.productList = r.productsPage.products;
              console.log(JSON.parse(JSON.stringify(this.productList)));
              this.facetPillBox = [];
              this.isFacetAdded = false;
            })
            .catch(e => {
              console.log(e);
            });

         createFacetDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
                .then(r => {
                    // Create a deep copy of the server response 
                    this.facetDisplay = JSON.parse(JSON.stringify(r));
                    console.log(JSON.parse(JSON.stringify(this.facetDisplay)));
                    // Expand the accordian section whose names appear in the array
                    this.activeAccordionSections = [];
                    for (let i = 0; i < this.facetDisplay.length; i++) {
                      this.activeAccordionSections[i] = this.facetDisplay[i].facetName;
                    }
                })
    } // refreshProductDisplay 



    handleFilterCheckboxDisplay(event) {
      console.log(event.detail.facetDisplay);
      console.log(JSON.parse(JSON.stringify(event.detail.facetPillBox)));
      console.log(event.detail.filterResults);
      this.facetDisplay = event.detail.facetDisplay;
      this.facetPillBox = event.detail.facetPillBox;
      this.productList = event.detail.filterResults;
      if (this.facetPillBox.length === 0) {
        this.isFacetAdded = false;
      } else {
        this.isFacetAdded = true;
      }
    }

    handlePillboxItemRemove(event) {
      console.log('Pillbox Item remove');
      this.template.querySelector('c-filter-checkbox-display').removePillBoxItem(event);
    }

    connectedCallback() {
        console.log('Product Display Initialized');
    } // connectedCallback
}