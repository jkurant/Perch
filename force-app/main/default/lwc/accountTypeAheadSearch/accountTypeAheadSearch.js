import { LightningElement, api } from 'lwc';
import getMatchingAccounts from '@salesforce/apex/AccountTypeAheadSearchHelper.getMatchingAccounts';

export default class AccountTypeAheadSearch extends LightningElement {

  searchString = '';
  @api searchResults = [];
  @api showResults = false;
  showContacts = false;
  showContactsValue = ['showContactsYes'];

  connectedCallback() {
    console.log('connectedCallback BEGIN');
    this.showResults = false;
    this.showContacts = true;
    console.log('connectedCallback END');
  }

  get contactsOptions() {
    return [
      { label: 'Show Contacts', value: 'showContactsYes' }
    ];
  }

  handleShowContactChange(event) {
    const val = event.target.value;
    if (val == 'showContactsYes') {
      this.showContacts = true;
    } else {
      this.showContacts = false;
    }
    this.refreshSearchResults();
  }

  handleKeyUp(event) {
    const val = event.target.value;
    this.searchString = val;
    this.refreshSearchResults();
  }

  refreshSearchResults() {
    if (this.searchString) { 
      getMatchingAccounts({ searchString: this.searchString, showContacts: this.showContacts })
        .then(result => {
          this.showResults = true;
          this.searchResults = result;
        })
        .catch(error => {
          this.showResults = false;
          console.log('Error in handleKeyUp');
          console.log(error);
        });
    } else {
      this.showResults = false;
    }
  }


} 