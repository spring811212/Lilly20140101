trigger SECForms_QuestionOption_Before on SEC_Forms_Question_Option__c (before insert, before update) {

	QuestionOptionUtils.validateQuestionOption(trigger.new);

}