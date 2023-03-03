import { LightningElement, api, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import getSearchResults from '@salesforce/apex/ProductPageController.getSearchResults';
import createFacetDisplay from '@salesforce/apex/ProductPageController.createFacetDisplay';
import { CurrentPageReference } from 'lightning/navigation';

// This component serves as a testing ground for the product display and listing component

export default class RicardoProductDisplay extends LightningElement {
    @api productList;
    @api facetDisplay; // Stores a deep copy of the List<FacetDisplay> object from the createFacetDisplay Apex method 
    @api categoryLandingPage = '0ZGDn000000M345OAC';
    @api facetPillBox = [];
    isFacetAdded = false;
    isLoading = false;

    // Obtains the url of the current page
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
      
      
          //this.categoryLandingPage = currentPageReference.attributes.recordId;
          this.refreshProductDisplay();

    }

   async refreshProductDisplay() {
         await getSearchResults({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
              this.productList = r.productsPage.products;
              this.facetPillBox = [];
              this.isFacetAdded = false;
            })
            .catch(e => {
              console.log(e);
            });

         await createFacetDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
                // Create a deep copy of the server response 
                this.facetDisplay = JSON.parse(JSON.stringify(r));               
            })
            .catch(e => {
              console.log(e);
            });
        this.finishedLoading();
    } // refreshProductDisplay 

    finishedLoading() {
      this.isLoading = false;
    }


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
    } 
}