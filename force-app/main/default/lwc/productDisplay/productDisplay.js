import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getSearchResults from '@salesforce/apex/ProductPageController.getSearchResults';
import createFacetDisplay from '@salesforce/apex/ProductPageController.createFacetDisplay';
// import dummyFacetDisplay from '@salesforce/apex/ProductPageController.dummyFacetDisplay';
import  filterProductDisplay from '@salesforce/apex/ProductPageController.filterProductDisplay';

// This component serves as a testing ground for the product display and listing component

export default class FilterPrompt extends LightningElement {
   
    @api productList;
    @api facetDisplay; // Stores a deep copy of the List<FacetDisplay> object from the createFacetDisplay Apex method 
    @api activeAccordionSections = [];
    @api categoryLandingPage = 'iPhone';
    clpComboboxOptions =  [
        {label: "iPhone", value: "iPhone"},
        {label: "Samsung", value: "Samsung"},
      ];
    
   @api facetPillBox = [];

   imperativeApex() {
         getSearchResults({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
              this.productList = r.productsPage.products;
              console.log(JSON.parse(JSON.stringify(this.productList)));
              this.facetPillBox = [];
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
    } // imperativeApex 

    // Updates the facet display when a pill box is x'ed out
    handleItemRemove(event) {
        const index = event.detail.index;
        let pillBoxLabel = event.detail.item.label
        let facetToUncheck =  pillBoxLabel.substring(pillBoxLabel.indexOf(":") + 1).trim();    
        // Retrieve the Facet Display item to update
        let selectedFacetDisplay = this.facetDisplay.filter(item => item.facetName === event.detail.item.name)[0];
        
        selectedFacetDisplay.selectedFacets =  selectedFacetDisplay.selectedFacets.filter(e => e !== facetToUncheck );
        this.facetPillBox.splice(index, 1); // Remove the pillbox  
        filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage, 
                            facetDisplayJson: JSON.stringify(this.facetDisplay)})
              .then(r => {
                console.log(r);
                this.productList = r;      
              })
              .catch(e => {
                console.log(e);
              });
    } // handleItemRemove

    handleCheckboxSelect(event) {
      //this.productList = event.detail;
      console.log('child to parent');
      console.log(event.detail.facetPillBox);
       console.log('child ended');
      this.facetDisplay = event.detail.facetDisplay;
      this.facetPillBox = event.detail.facetPillBox;
      this.productList = event.detail.filterResults;
    }

    handleChange(event) {
      this.categoryLandingPage = event.target.value;
    }

    connectedCallback() {
        console.log('Product Display Initialized');
    } // connectedCallback
}