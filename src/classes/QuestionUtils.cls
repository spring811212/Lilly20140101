public with sharing class QuestionUtils {

	public static void validateOnInsert(List<SEC_Forms_Question__c> questions) {
		Map<String,List<SEC_Forms_Question__c>> qMap = new Map<String,List<SEC_Forms_Question__c>>{};
		Map<String,SEC_Forms_Question__c> newQIDs = new Map<String,SEC_Forms_Question__c>{};
		//Map<String,Boolean> newQIDUnique = new Map<String,Boolean>{};
		
		//either send to validate, or create unique qid
		for(SEC_Forms_Question__c question : questions) {
			if (question.QID__c != null) {
				if (qMap.containsKey(question.QID__c)) {
					qMap.get(question.QID__c).add(question);
				}
				else {
					qMap.put(question.QID__c, new List<SEC_Forms_Question__c> { question });
				}
			}
			else {
				String QID = generateQID();
				newQIDs.put(QID, question);
				//newQIDUnique.put(QID, false);
			}
		}
		
		if (!newQIDs.isEmpty()) {
			//ValidateQIDUniqueness(newQIDs, newQIDUnique);
			for(String key : newQIDs.keySet()) {
				SEC_Forms_Question__c question = newQIDs.get(key);
				question.QID__c = key;
			}
		}
		
		if (!qMap.isEmpty()) {
			ValidateQIDs(qMap);
		}
	}
 
	public static void validateOnUpdate(List<SEC_Forms_Question__c> oldQuestions, List<SEC_Forms_Question__c> newQuestions) {
		//if any of the check fields are modified, send to validate
		//if QID is null, re-generate
		Map<String,List<SEC_Forms_Question__c>> qids = new Map<String,List<SEC_Forms_Question__c>>{};
		Map<String,SEC_Forms_Question__c> newQIDs = new Map<String,SEC_Forms_Question__c>{};
		
		for(Integer i = 0; i < newQuestions.size(); i++) {
			SEC_Forms_Question__c oldQuestion = oldQuestions[i];
			SEC_Forms_Question__c newQuestion = newQuestions[i];
			
			if (oldQuestion.Data_Type__c != newQuestion.Data_Type__c || oldQuestion.Pre_population__c != newQuestion.Pre_population__c || oldQuestion.QID__c != newQuestion.QID__c) {
				if (newQuestion.QID__c != null) {
					if (qids.containsKey(newQuestion.QID__c)) {
						qids.get(newQuestion.QID__c).add(newQuestion);
					}
					else {
						qids.put(newQuestion.QID__c, new List<SEC_Forms_Question__c> { newQuestion });	
					}
				}
			}
			
			if (newQuestion.QID__c == null) {
				String QID = generateQID();
				newQIDs.put(QID, newQuestion);
			}
		}
		
		if (!newQIDs.isEmpty()) {
			//ValidateQIDUniqueness(newQIDs, newQIDUnique);
			for(String key : newQIDs.keySet()) {
				SEC_Forms_Question__c question = newQIDs.get(key);
				question.QID__c = key;
			}
		}
		
		if (!qids.isEmpty()) {
			ValidateQIDs(qids);
		}
	}
	
	//OIL: what to do if user blanks out qid of existing question:
	// 1) allow the operation, or ***this one
	// 2) auto-create new qid?

	private static void ValidateQIDs (Map<String,List<SEC_Forms_Question__c>> qids) {
		
		//check each, if it fails, add error to object
		//since we can assume that the qid was valid the last time this ran, it should match ALL
		//questions with the same QID
		Map<Id,Id> qq = new Map<Id,Id>{}; //matches a question against its matching question
		Map<Id,SEC_Forms_Question__c> qOptions = new Map<Id,SEC_Forms_Question__c>{};
		
		System.debug(qids);
		
		for(SEC_Forms_Question__c question : [select Id, Data_Type__c, Pre_population__c, QID__c from SEC_Forms_Question__c where QID__c in :qids.keySet()]) {
			
			for(SEC_Forms_Question__c q : qids.get(question.QID__c)) {
				if (q.Id != question.Id) {
					if (q.Data_Type__c != question.Data_Type__c) {
						q.Data_Type__c.addError('Data Type does not match matching QID question.'); //needs re-wording
					}
					if (q.Pre_Population__c != question.Pre_population__c) {
						q.Pre_Population__c.addError('Pre-population does not match matching QID question.'); //needs re-wording
					}
					
					if (q.Data_Type__c == 'Picklist') {
						if (q.Id != null) {
							qq.put(q.Id, question.Id);
						}
						else {
							q.Data_Type__c.addError('To create a picklist question with a matching QID, you must clone the existing quetion.');
						}
						
						qOptions.put(q.Id, q);
					}
				}
			}
			
		}
		
		if (!qq.isEmpty()) {
			Map<Id, List<String>> options = new Map<Id,List<String>>{};
			
			//picklist options must match exactly
			for(SEC_Forms_Question_Option__c option : [select Id, Option_Values__c, Question__c from SEC_Forms_Question_Option__c where Id in :qq.keySet() or Id in :qq.values()]) {
				if (options.containsKey(option.Question__c)) {
					options.get(option.Question__c).add(option.Option_Values__c);
				}
				else {
					options.put(option.Question__c, new List<String> { option.Option_Values__c });	
				}
			}
			
			for(Id key : options.keySet()) {
				if (qOptions.containsKey(key)) {
					
					Boolean mismatch = false;
					
					List<String> updatingOptions = options.get(key);
					List<String> checkOptions = options.get(qq.get(key));
					
					updatingOptions.sort();
					checkOptions.sort();
					
					//check size
					if (updatingOptions.size() != checkOptions.size()) {
						mismatch = true;
					}
					
					if (!mismatch) {
						for(Integer i = 0; i < updatingOptions.size(); i++) {
							if (updatingOptions[i] != checkOptions[i]) {
								mismatch = true;
								break;
							}
						}
					}
					
					if (mismatch) {
						SEC_Forms_Question__c badQuestion = qOptions.get(key);
						badQuestion.Data_Type__c.addError('Mismatching Options found.');
					}
				}
			}
		}
	}
	
	//statistically impossible to get a duplicate
	//1 in 2.610121787199411e124 (25^89) chance of duplication
	public static String generateQID() {
	
		List<String> chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*()-_=+{[}];:,<.>/?'.split('');
		chars.remove(0);
		
		String QID = '';
		
		for(Integer i = 0; i < 25; i ++) {
			QID += chars[Math.round(Math.random() * (chars.size() - 1))];
		}
		
		return QID;
	}
}