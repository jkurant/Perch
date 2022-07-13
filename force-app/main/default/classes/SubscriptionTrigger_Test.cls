/*************************************************************************
 * Created by Jason Kurant
 * 
 * Revisions:
 *
 * 06/29/2022 Jason kurant      Created test for SubscriptionTrigger 
 *                              and SubscriptionTriggerHandler
 * 07/01/2022 Jason Kurant      Added bulk testing code
 *************************************************************************/
@isTest
 public with sharing class SubscriptionTrigger_Test {

    @TestSetup
    static void makeData() {
        Account acc1 = new Account(Name = 'Account1');
        insert acc1;

        Account acc2 = new Account(Name = 'Account2');
        insert acc2;

        Account acc3 = new Account(Name = 'Account3');
        insert acc3;

        Shared_Solar_System__c s1 = new Shared_Solar_System__c(Name = 'Shared Solar System 1');
        insert s1;

        Shared_Solar_System__c s2 = new Shared_Solar_System__c(Name = 'Shared Solar System 2');
        insert s2;

        Shared_Solar_System__c s3 = new Shared_Solar_System__c(Name = 'Shared Solar System 3');
        insert s3;
    }
    
    @isTest
    static void testSubscriptionTooLong() {
        Integer failCount = 0;
        
        // get data
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = 'Account1' LIMIT 1];

        Shared_Solar_System__c s1 = [SELECT Id, Name FROM Shared_Solar_System__c WHERE name = 'Shared Solar System 1' LIMIT 1];

        // Verify we cannot create a subscription that is longer than 3 years
        final Subscription__c a1s1_too_long = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2018, 1, 1),
            End_Date__c = Date.newInstance(2022, 12, 31)
        );
        try {
            insert a1s1_too_long; // this should fail
        } catch (Exception e) {
            failCount++;
        }

        // check results
        system.assertEquals(1, failCount, 'The insert should have failed');

    }

    @isTest
    static void testOverlappingSubscriptions() {
        Integer failCount = 0;
        
        // get data
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = 'Account1' LIMIT 1];
        Account a2 = [SELECT Id, Name FROM Account WHERE Name = 'Account2' LIMIT 1];

        Shared_Solar_System__c s1 = [SELECT Id, Name FROM Shared_Solar_System__c WHERE name = 'Shared Solar System 1' LIMIT 1];
        Shared_Solar_System__c s2 = [SELECT Id, Name FROM Shared_Solar_System__c WHERE name = 'Shared Solar System 2' LIMIT 1];

        // Test creating a subscription
        final Subscription__c a1s1_1 = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 1, 1),
            End_Date__c = Date.newInstance(2022, 5, 31)
        );
        try {
            insert a1s1_1; // this should succeed
        } catch (Exception e) {
            failCount++;
        }

        // Test creating another subscription for the same customer and Shared Solar System
        final Subscription__c a1s1_2 = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 6, 1),
            End_Date__c = Date.newInstance(2022, 12, 31)
        );
        try {
            insert a1s1_2; // this should succeed
        } catch (Exception e) {
            failCount++;
        }

        system.assertEquals(0, failCount, 'Zero inserts should have failed at this point');

        // Verify that we cannot create an overlapping subscrition for the same customer and Shared Solar System
        final Subscription__c a1s1_overlap = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 3, 1),
            End_Date__c = Date.newInstance(2022, 9, 30)
        );
        try {
            insert a1s1_overlap; // this should fail
        } catch (Exception e) {
            failCount++;
        }

        // check results
        system.assertEquals(1, failCount, 'One insert should have failed');

        // Verify that we can create an "overlapping" subscription but for different customers
        final Subscription__c a2s1_overlap = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a2.Id,
            Start_Date__c = Date.newInstance(2022, 3, 1),
            End_Date__c = Date.newInstance(2022, 9, 30)
        );
        try {
            insert a2s1_overlap; // this should succeed
        } catch (Exception e) {
            failCount++;
        }

        // check results
        system.assertEquals(1, failCount, 'Only one insert should have failed');

        // Verify that we can create an "overlapping" subscription but for different Shared Solar System
        final Subscription__c a1s2_overlap = new Subscription__c(
            Shared_Solar_System__c = s2.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 3, 1),
            End_Date__c = Date.newInstance(2022, 9, 30)
        );
        try {
            insert a1s2_overlap; // this should succeed
        } catch (Exception e) {
            failCount++;
        }

        // check results
        system.assertEquals(1, failCount, 'Only one insert should have failed');

    }


    @isTest
    static void testUpdatingSubscriptions() {
        Integer failCount = 0;

        // get data
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = 'Account1' LIMIT 1];
        Account a2 = [SELECT Id, Name FROM Account WHERE Name = 'Account2' LIMIT 1];

        Shared_Solar_System__c s1 = [SELECT Id, Name FROM Shared_Solar_System__c WHERE name = 'Shared Solar System 1' LIMIT 1];
        Shared_Solar_System__c s2 = [SELECT Id, Name FROM Shared_Solar_System__c WHERE name = 'Shared Solar System 2' LIMIT 1];

        // Test creating a subscription
        final Subscription__c a1s1_1 = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 1, 1),
            End_Date__c = Date.newInstance(2022, 5, 31)
        );
        try {
            insert a1s1_1; // this should succeed
        } catch (Exception e) {
            failCount++;
        }

        // Test creating another subscription for the same customer and Shared Solar System
        final Subscription__c a1s1_2 = new Subscription__c(
            Shared_Solar_System__c = s1.Id,
            Subscriber__c = a1.Id,
            Start_Date__c = Date.newInstance(2022, 6, 1),
            End_Date__c = Date.newInstance(2022, 12, 31)
        );
        try {
            insert a1s1_2; // this should succeed
        } catch (Exception e) {
            failCount++;
        }
        system.assertEquals(0, failCount, 'Zero inserts should have failed at this point');

        // Verify we can update a subscription
        a1s1_2.End_Date__c = Date.newInstance(2023, 3, 31);
        try {
            update a1s1_2; // this should succeed
        } catch (Exception e) {
            failCount++;
        }
        system.assertEquals(0, failCount, 'Zero updates should have failed at this point');

        // Verify we cannot update a subscription so it overlaps an existing one 
        a1s1_2.Start_Date__c = Date.newInstance(2022, 1, 31);
        a1s1_2.End_Date__c = Date.newInstance(2023, 3, 31);
        try {
            update a1s1_2; // this should fail
        } catch (Exception e) {
            failCount++;
        }
        system.assertEquals(1, failCount, 'One update should have failed at this point');

    }

    @isTest
    static void testInBulk() {
        Integer failCount = 0;

        // get data
        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Shared_Solar_System__c> ssss = [SELECT Id, Name FROM Shared_Solar_System__c];

        List<Subscription__c> subsToInsert = new List<Subscription__c>();

        for (Account a : accounts) {
            for (Shared_Solar_System__c s : ssss) {
                subsToInsert.add(makeSubscription(s, a, 2022, 0, 90));
                subsToInsert.add(makeSubscription(s, a, 2022, 91, 180));
                subsToInsert.add(makeSubscription(s, a, 2022, 181, 270));
                subsToInsert.add(makeSubscription(s, a, 2022, 271, 365));
            }
        }
        // throw in one that should fail in two ways
        subsToInsert.add(makeSubscription(ssss[0], accounts[0], 2022, 181, 270));

        // Sub1 inside Sub2 - this should fail in two ways
        subsToInsert.add(makeSubscription(ssss[0], accounts[0], 2024, 30, 60));
        subsToInsert.add(makeSubscription(ssss[0], accounts[0], 2024, 0, 365));

        // Sub2 inside Sub1 - this should fail in two ways
        subsToInsert.add(makeSubscription(ssss[0], accounts[0], 2025, 0, 365));
        subsToInsert.add(makeSubscription(ssss[0], accounts[0], 2025, 30, 60));

        // DML statement
        Database.SaveResult[] srList = Database.insert(subsToInsert, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('#@# Successfully inserted subscription. Subscription ID = ' + sr.getId());
            } else {
                failCount++;
                // Operation failed, so get all errors 
                for(Database.Error err : sr.getErrors()) {
                    System.debug('#@# The following error has occurred.'); 
                    System.debug('#@#   ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#@#   fields that affected this error: ' + err.getFields());
                }
            }
        }
        system.assertEquals(6, failCount, '6 errors should have been detected (really the same one found two ways)');

    }

    static private Subscription__c makeSubscription(
        Shared_Solar_System__c s, Account a, 
        Integer year, Integer startDayOffset, Integer endDayOffset) 
    {

        final Subscription__c sub = new Subscription__c(
            Shared_Solar_System__c = s.Id,
            Subscriber__c = a.Id,
            Start_Date__c = Date.newInstance(year, 1, 1).addDays(startDayOffset),
            End_Date__c = Date.newInstance(year, 1, 1).addDays(endDayOffset)
        );
        
        return sub;
    }

}
