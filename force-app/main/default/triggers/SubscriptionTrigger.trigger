/********************************************
 * Created by Jason Kurant
 * Test class: SubscriptionTrigger_Test
 * 
 * Revisions:
 * 
 * 06/22/2022 Jason Kurant    Created
 ********************************************/
trigger SubscriptionTrigger on Subscription__c (before insert, before update) {

  if (trigger.isBefore) {

    if (trigger.isInsert) {
      SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler(trigger.new);
      handler.beforeInsert();
    }

    if (trigger.isUpdate) {
      SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler(trigger.new);
      handler.beforeUpdate();
    }

  }

}