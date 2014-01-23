trigger Opportunity_After on Opportunity (after insert, after update) {
	//if (trigger.size == 1) {
		//OpptyTriggerUtils.afterTriggerProcessing(trigger.isUpdate ? trigger.old[0] : null, trigger.new[0]);
	//}
	OpptyTriggerUtils.afterTriggerProcessing(trigger.old, trigger.new);
	
	if (trigger.isUpdate) {
		CloneUtil.cloneOpportunity(trigger.old, trigger.new);
	}
}