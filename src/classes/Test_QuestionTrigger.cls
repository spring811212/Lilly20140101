@isTest
private class Test_QuestionTrigger {

    static testMethod void test_QuestionUtils() {
    	
    	Map<Id,String> dataTypes = new Map<Id,String>{};
    	Map<Id,String> qids = new Map<Id,String>{};
    	
    	Integer i = 0;
    	
    	List<SEC_Forms_Question__c> questions = new List<SEC_Forms_Question__c>{};
    	for(SEC_Forms_Question__c question : [select Id, Data_Type__c, QID__c, Pre_Population__c from SEC_Forms_Question__c where QID__c != null limit 200]) {
    		
    		dataTypes.put(question.Id, question.Data_Type__c);
    		qids.put(question.Id, question.QID__c);
    		
    		question.QID__c = QuestionUtils.generateQID();
    		question.Data_Type__c = 'Comment';
    		
    		questions.add(question);
    	}
    	
    	try {
    		update questions;
    	}
    	catch (System.DmlException de) {
    		//do nothing, the trigger is supposed to error
    	}
    	
    	for(SEC_Forms_Question__c question : questions) {
    		question.Data_Type__c = dataTypes.get(question.Id);
    		question.QID__c = qids.get(question.Id);
    	}
    	
    	try {
    		update questions; //trigger should not error
    	}
    	catch (System.DmlException de) {
    		
    	}
    }
    
    static testMethod void testOnInsert() {
    	SEC_Forms_Question__c q = new SEC_Forms_Question__c();
    	q.Name = 'test';
    	insert q;
    	
    	SEC_Forms_Question__c q2 = new SEC_Forms_Question__c();
    	q2.Name = 'test';
    	q2.QID__c = 'test';
    	insert q2;
    	
    }
    
    static testMethod void test_2() {

    	SEC_Forms_Question__c qq = [select Id, QID__c, Data_Type__c, Pre_Population__c from SEC_Forms_Question__c limit 1];
    	String qid = QuestionUtils.generateQID();
    	qq.QID__c = qid;
    	update qq;
    	
    	List<SEC_Forms_Question__c> qsNew = new List<SEC_Forms_Question__c>{};
    	for(SEC_Forms_Question__c q : [select Id from SEC_Forms_Question__c where Data_Type__c = :qq.Data_Type__c and Pre_Population__c = :qq.Pre_Population__c limit 100]) {
    		
    		q.QID__c = qid;
    		qsNew.add(q);
    	}
    	
    	update qsNew;
    	//QuestionUtils.validateOnUpdate(qsOld, qsNew);
    }
    
}