/*************************************************************************
 * Created by Jason Kurant
 * Test class: SubscriptionTrigger_Test
 * 
 * Revisions:
 * 
 * 06/22/2022 Jason Kurant      Created
 * 06/29/2022 Jason kurant      improved formatting for error message
 * 07/01/2022 Jason Kurant      Fixed bugs found in bulk testing
 *************************************************************************/
public with sharing class SubscriptionTriggerHandler {

    private List<Subscription__c> newSubs;

    public SubscriptionTriggerHandler( List<Subscription__c> newList ) {
        newSubs = newList;
        system.debug('#@# SubscriptionTriggerHandler.constructor: There are ' + newList.size() + ' subscriptions being inserted or updated');
    }

    /* before inserting a new subscription, make sure there are no existing subscriptions
       with overlapping effective dates for the same Shared Solar System and the same
       customer.   */
    public void beforeInsert() {
        checkForOverlappingSubscriptions();
    }

    /* before updating an existing subscription, make sure there are no existing subscriptions
       with overlapping effective dates for the same Shared Solar System and the same
       customer.   */
    public void beforeUpdate() {
        checkForOverlappingSubscriptions();
    }

    // find all the Shared Solar System and customer combinations received in the records
    // processed by this bulkified trigger 
    public void checkForOverlappingSubscriptions() {

        Set<String> subLookups = new Set<String>();
        for (Subscription__c sub : newSubs) {
            String key = sub.Shared_Solar_System__c.to15() + '|' + sub.Subscriber__c.to15();
            system.debug('#@# SubscriptionTriggerHandler.checkForOverlappingSubscriptions: key for subscription being inserted/updated: ' + key);
            subLookups.add(key);
        }
        system.debug('#@# SubscriptionTriggerHandler.checkForOverlappingSubscriptions: found ' + subLookups.size() + ' unique keys');

        // get all the existing subscriptions for the set of Shared Solar System & Subscriber 
        // combinations received in the records processed by this bulkified trigger 
        List<Subscription__c> existingSubs = [
            SELECT Id, Name, Start_Date__c, End_Date__c, SubscriptionLookup__c
            FROM Subscription__c
            WHERE SubscriptionLookup__c IN :subLookups];
        system.debug('#@# SubscriptionTriggerHandler.checkForOverlappingSubscriptions: found ' + existingSubs.size() + ' existing subs for the same Shared Solar System and Subscriber');

        // check if any new subscriptions conflict with any existing ones
        for (Subscription__c newSub : newSubs) {
            // check if this new subscription conflicts with any existing ones
            for (Subscription__c existSub : existingSubs) {
                system.debug('#@## newSub.SubscriptionLookup__c   == ' + newSub.SubscriptionLookup__c);
                system.debug('#@## existSub.SubscriptionLookup__c == ' + existSub.SubscriptionLookup__c);
                system.debug('#@## newSub.Id   = ' + newSub.Id);
                system.debug('#@## existSub.Id = ' + existSub.Id);
                if (newSub.Id != existSub.Id && 
                    newSub.SubscriptionLookup__c == existSub.SubscriptionLookup__c &&
                    datesOverlap(newSub.Start_Date__c, newsub.End_Date__c, existSub.Start_Date__c, existSub.End_Date__c)) {
                    // prevent this update
                    newSub.addError('This subscription cannot be saved because it overlaps existing subscription ' + existSub.Name + ' which runs from ' + formatDate(existSub.Start_Date__c) + ' through ' + formatDate(existSub.End_Date__c));
                    // exit the loop
                    break;
                }
            }
        }
        
        // check if any new subscriptions conflict with any other new ones to be added
        for (Integer i = 0; i < newSubs.size(); i++) {
            Subscription__c newSub = newSubs[i];
            // check if this new subscription conflicts with any other new ones
            for (Integer j = 0; j < newSubs.size(); j++) {
                Subscription__c otherNewSub = newSubs[j];
                if (i != j) {
                    system.debug('##@## newSub != otherNewSub');
                    system.debug('##@## newSub.SubscriptionLookup__c      == ' + newSub.SubscriptionLookup__c);
                    system.debug('##@## otherNewSub.SubscriptionLookup__c == ' + otherNewSub.SubscriptionLookup__c);
                } else {
                    system.debug('##@## newSub == otherNewSub');
                }
                
                if (i != j &&
                    newSub.SubscriptionLookup__c == otherNewSub.SubscriptionLookup__c &&
                    datesOverlap(newSub.Start_Date__c, newsub.End_Date__c, otherNewSub.Start_Date__c, otherNewSub.End_Date__c)) {
                    // prevent this update
                    String msg = 'This subscription ' + i + ' cannot be saved because it overlaps existing subscription ' + j + ' which runs from ' + formatDate(otherNewSub.Start_Date__c) + ' through ' + formatDate(otherNewSub.End_Date__c);
                    system.debug('#@#$ Raised error: ' + msg);
                    newSub.addError(msg);
                    // exit the loop
                    break;
                }
            }
        }

    }

    private Boolean datesOverlap(Date startNew, Date endNew, Date startExist, Date endExist) {
        // if the start date of the first one is within the dates of the second one, OR
        // if the end date of the first one is within the dates of the second one
        Boolean retVal = (endNew >= startExist && endNew <= endExist) || (startNew >= startExist && startNew <= endExist)
                      || (endExist >= startNew && endExist <= endNew) || (startExist >= startNew && startExist <= endNew);
        system.debug('#@# SubscriptionTriggerHandler.datesOverlap: startNew = ' + startNew);
        system.debug('#@# SubscriptionTriggerHandler.datesOverlap: endNew = ' + endNew);
        system.debug('#@# SubscriptionTriggerHandler.datesOverlap: startExist = ' + startExist);
        system.debug('#@# SubscriptionTriggerHandler.datesOverlap: endExist = ' + endExist);
        system.debug('#@# SubscriptionTriggerHandler.datesOverlap: Overlap = ' + retVal);
        return retVal;
    }

    private String formatDate(Date d) {
        if (d == null) {
            return '';
        } else {
            return d.month() + '/' + d.day() + '/' + d.year();
        }
    }

}
