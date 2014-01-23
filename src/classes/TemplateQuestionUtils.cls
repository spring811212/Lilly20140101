public with sharing class TemplateQuestionUtils {

	//if a template question's parent question is populated, ensure that the parent does not also have a parent
	//to prevent possible cyclicle parent lookups
	public static void checkParentForParent(List<SEC_Forms_Template_Question__c> quests) {
		
		Map<Id,List<SEC_Forms_Template_Question__c>> parents = new Map<Id,List<SEC_Forms_Template_Question__c>>{}; //id => parentId
		
		for(SEC_Forms_Template_Question__c q : quests) {
			if (q.Parent_Question__c != null) {
				if (parents.containsKey(q.Parent_Question__c)) {
					parents.get(q.Parent_Question__c).add(q);
				}
				else {
					parents.put(q.Parent_Question__c, new List<SEC_Forms_Template_Question__c> {q});
				}
			}
		}
		
		//check each parent(1), if it has a parent(2), throw an error on the parent(1)'s child
		if (parents.size() > 0) {
			for(SEC_Forms_Template_Question__c p : [select Id, Parent_Question__c from SEC_Forms_Template_Question__c where Id in :parents.keySet()]) {
				if (p.Parent_Question__c != null) {
					for(SEC_Forms_Template_Question__c t : parents.get(p.Id)) {
						t.Parent_Question__c.addError('Cannot reference a Template Question that has a parent.');
					}
				}
			}
		}
	}
}