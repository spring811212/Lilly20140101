trigger SECTrialSiteContactRoleCheck on Opportunity_Contact_Role__c (before insert, before update) {
    
    if(trigger.isBefore){
        if(trigger.isUpdate || trigger.isInsert){
          SECTrialSiteContactRoleHelper.checkPIExists(Trigger.new);
        }
    }
       
    if(trigger.isBefore){
        if(trigger.isUpdate || trigger.isInsert){
            SECTrialSiteContactRoleHelper.checkDuplicateRoleForTheSameContact(Trigger.new);
        }
    }
     
}