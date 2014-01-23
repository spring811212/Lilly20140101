trigger SECForms_TrialForm on SEC_Forms_Trial_Form__c (before insert, before update) {
	TrialFormUtils.checkForDuplication(trigger.new);
}