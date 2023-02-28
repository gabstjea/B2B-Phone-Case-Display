import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getSearchResults from '@salesforce/apex/ProductPageController.getSearchResults';
// import createFacetDisplay from '@salesforce/apex/ProductPageController.createFacetDisplay';
import dummyFacetDisplay from '@salesforce/apex/ProductPageController.dummyFacetDisplay';
import  filterProductDisplay from '@salesforce/apex/ProductPageController.filterProductDisplay';

// This component serves as a testing ground for the product display and listing component

export default class FilterPrompt extends LightningElement {
   
    @track productList;
    @track facetDisplay; // Stores a deep copy of the List<FacetDisplay> object from the createFacetDisplay Apex method 
    connectApiFacetResultsJson
    @track activeAccordionSections = [];
    categoryLandingPage = 'iPhone';
    clpComboboxOptions =  [
        {label: "iPhone", value: "iPhone"},
        {label: "Samsung", value: "Samsung"},
      ];
    
    selectedFacetDisplay;
    uncheckedItem;
    newlyAddedItem;
    @track facetPillBox = [];

    comboBoxValue = "proPack";
    compatibility;
    productLine;



   imperativeApex() {
         getSearchResults({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
              this.productList = r.productsPage.products;
              console.log(JSON.parse(JSON.stringify(this.productList)));
              this.connectApiFacetResultsJson = r.facets; 
              console.log( JSON.parse(JSON.stringify(this.facetPillBox.filter( e => e.name === 'Sam' &&  e.label !== 'hey: '))));

              this.facetPillBox = [];
              this.selectedFacetDisplay = '';
              this.uncheckedItem = '';
              this.newlyAddedItem = '';
              dummyFacetDisplay({connectApiFacetResultsJson: JSON.stringify(r.facets), categoryLandingPage: 'hi'})
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
            })
            .catch(e => {
              console.log(e);
            });
    } // imperativeApex 

    handleCheckBoxGroup(event) {
      this.selectedFacetDisplay = this.facetDisplay.filter(item => item.facetName === event.target.label)[0];
      // If the new list of values from the facet display is less than before it was changed, remove the item from the pillbox
      if (event.detail.value.length < this.selectedFacetDisplay.selectedFacets.length ) { 
          this.uncheckedItem = this.selectedFacetDisplay.selectedFacets.filter(e => event.detail.value.includes(e) !== true)[0];      
          this.facetPillBox = this.facetPillBox.filter( e => e.label.substring(e.label.indexOf(":") + 1).trim() !== this.uncheckedItem);
      } else { // add item to pillbox
          // Since elements are automatically sorted when added into the array, the newly added element can't be retireved from the last index
          this.newlyAddedItem = event.detail.value.filter(e => this.selectedFacetDisplay.selectedFacets.includes(e) !== true)[0];     
          this.facetPillBox.push({label: event.target.label + ": " +  this.newlyAddedItem, name: event.target.label});
      }
      console.log(event.detail.value);
      this.selectedFacetDisplay.selectedFacets = event.detail.value;
      filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage, 
                            connectApiFacetResultsJson: JSON.stringify(this.connectApiFacetResultsJson), 
                            facetDisplayJson: JSON.stringify(this.facetDisplay)})
              .then(r => {
                console.log(r);
                this.productList = r;      
              })
              .catch(e => {
              console.log(e);
              });
    }

    get comboBoxOptions() {
      return [
        {label: "Pro-pack", value: "proPack"},
        {label: "retail", value: "retail"},
      ];
    }

    onChangeHandler(event) {
      const tagName = event.target.name;
      if (tagName === "categoryLandingPage") {
        this.categoryLandingPage = event.detail.value;
      } else if (tagName === "compatibility") {
        this.compatibility = event.target.value;
      } else if (tagName === "productLine") {
        this.productLine = event.target.value;
      } else if (tagName === "packaging") {
        this.comboBoxValue = event.detail.value;
      }
    } // onChangeHandler

    connectedCallback() {
        console.log(this.productList);
        console.log(this.productList);
    } // connectedCallback
 

}