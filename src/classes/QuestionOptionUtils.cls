public with sharing class QuestionOptionUtils {

	public static void validateQuestionOption(List<SEC_Forms_Question_Option__c> options) {
		
		Map<String, List<SEC_Forms_Question_Option__c>> optionsMap = new Map<String,List<SEC_Forms_Question_Option__c>>{};
		
		for(SEC_Forms_Question_Option__c option : options) {
			if (option.Parent_QID__c != null) {
				if (optionsMap.containsKey(option.Parent_QID__c)) {
					optionsMap.get(option.Parent_QID__c).add(option);
				}
				else {
					optionsMap.put(option.Parent_QID__c, new List<SEC_Forms_Question_Option__c> { option });
				}
			}
		}
		
		Map<String,Set<Id>> hasMultQIDs = new Map<String,Set<Id>>{};
		Map<String,List<String>> existingOptions = new Map<String,List<String>>{};
		for(SEC_Forms_Question_Option__c option : [select Id, Parent_QID__c, Option_Values__c, Question__c from SEC_Forms_Question_Option__c where Parent_QID__c in :optionsMap.keySet()]) {
			if (existingOptions.containsKey(option.Parent_QID__c)) {
				existingOptions.get(option.Parent_QID__c).add(option.Option_Values__c);
			}
			else {
				existingOptions.put(option.Parent_QID__c, new List<String> { option.Option_Values__c });
			}
			
			if (hasMultQIDs.containsKey(option.Parent_QID__c)) {
				hasMultQIDs.get(option.Parent_QID__c).add(option.Question__c);	
			}
			else {
				hasMultQIDs.put(option.Parent_QID__c, new Set<Id> { option.Question__c });
			}
		}
		
		for(String key : optionsMap.keySet()) {
			for(SEC_Forms_Question_Option__c option : optionsMap.get(key)) {
				
				System.debug('###option:' + option);
				
				Boolean valid = false;
				if (existingOptions.containsKey(option.Parent_QID__c)) {
					for(String optionValue : existingOptions.get(option.Parent_QID__c)) {
						if (option.Option_Values__c == optionValue) {
							valid = true;
							break;
						}
					}
				}
				else {
					valid = true;
				}
				
				if (!valid && hasMultQIDs.get(option.Parent_QID__c).size() > 1) {
					option.Option_Values__c.addError('Value does not exist on any Question Options with a parent of the same QID.');
				}
			}
		}
	}
}