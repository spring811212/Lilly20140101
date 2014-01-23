trigger OpportunityTrigger on Opportunity (before insert, before update) {
    SEC_Forms_Service.opptySetTrialOwner(trigger.new);
    if (trigger.isUpdate) {
    	OpptyTriggerUtils.beforeTriggerProcessing(trigger.old, trigger.new);
    }
}