//for QID validation
trigger SECForms_Question_Before on SEC_Forms_Question__c (before insert, before update) {

	if (trigger.isInsert) {
		QuestionUtils.validateOnInsert(trigger.new);
	}
	else if (trigger.isUpdate) {
		QuestionUtils.validateOnUpdate(trigger.old, trigger.new);
	}
	
}