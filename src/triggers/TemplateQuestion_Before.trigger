trigger TemplateQuestion_Before on SEC_Forms_Template_Question__c (before insert, before update) {
	TemplateQuestionUtils.checkParentForParent(trigger.new);
}