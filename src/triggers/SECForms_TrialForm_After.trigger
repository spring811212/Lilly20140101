trigger SECForms_TrialForm_After on SEC_Forms_Trial_Form__c (after insert) {
	if (trigger.size == 1) {
		/*
		Id oldCmpgnId = null;
		if (trigger.isUpdate) {
			oldCmpgnId = trigger.old[0].Trial_Campaign__c;
		}
		*/
		TrialFormUtils.afterTriggerProcessing(trigger.new[0]/*, oldCmpgnId*/);
		
	}
}