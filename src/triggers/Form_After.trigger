trigger Form_After on SEC_Forms_Form__c (after update) {
	if (trigger.size == 1) {
		FormTriggerUtils.afterTriggerProcessing(trigger.old[0], trigger.new[0]);
	}
}