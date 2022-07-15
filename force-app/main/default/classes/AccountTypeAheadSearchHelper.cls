@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class AccountTypeAheadSearchHelper {

    /**
     * Given a searchString, returns an array of MatchingAccountsWrappers for the LWC to consume
     *
     * @param searchString a part of the name of the account to search for
     *
     * @return an array of MatchingAccountsWrappers
     */
    @AuraEnabled
    public static MatchingAccountsWrapper[] getMatchingAccounts(String searchString) {
        String searchSpec = '%' + searchString + '%';
        List<Account> accountsFound = [
            SELECT Id, Name,
                (SELECT Id, Name FROM Contacts ORDER BY Name) 
            FROM Account 
            WHERE Name LIKE :searchSpec 
            ORDER BY Name];

        List<MatchingAccountsWrapper> matchingAccounts = new List<MatchingAccountsWrapper>();
        for (Account ma : accountsFound) {
            //MatchingAccountsWrapper mar = new MatchingAccountsWrapper(ma);
            MatchingAccountsWrapper mar = new MatchingAccountsWrapper(ma.Id, ma.Name, ma.Contacts);
            matchingAccounts.add(mar);
            system.debug('#@# matching account.name = ' + ma.Name);
        }
        return matchingAccounts;
    }

    private class MatchingAccountsWrapper {

        public MatchingAccountsWrapper(String k, String n) {
            key = k;
            name = n;
        }

        public MatchingAccountsWrapper(String k, String n, List<Contact> c) {
            key = k;
            name = n;
            relatedContacts = c;
        }

        public MatchingAccountsWrapper(Account a) {
            key = a.Id;
            name = a.Name;
        }

        @AuraEnabled
        public string key {get; set;}

        @AuraEnabled
        public string name {get; set;}

        @AuraEnabled
        public string link {get {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.key;
        } set;}

        private List<Contact> relatedContacts {get; set;}

        @AuraEnabled
        public List<MatchingContactsWrapper> contacts {get {
            List<MatchingContactsWrapper> matchingContacts = new List<MatchingContactsWrapper>();
            for (Contact matchingContact : relatedContacts) {
                MatchingContactsWrapper mac = new MatchingContactsWrapper(matchingContact);
                matchingContacts.add(mac);
            }
            return matchingContacts;
        } set;}
    }

    private class MatchingContactsWrapper {

        public MatchingContactsWrapper(Contact c) {
            key = c.Id;
            name = c.Name;
        }

        @AuraEnabled
        public string key {get; set;}

        @AuraEnabled
        public string name {get; set;}

        @AuraEnabled
        public string link {get {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.key;
        } set;}
    }

}
