@isTest
private class Test_QuestionOptionTrigger {

    static testMethod void test_QuestionOptionTrigger() {
       
        List<SEC_Forms_Question_Option__c> options = new List<SEC_Forms_Question_Option__c>{};
        for(SEC_Forms_Question_Option__c option : [select Id, Parent_QID__c, Option_Values__c, Question__c from SEC_Forms_Question_Option__c /*where Parent_QID__c = null*/ limit 200]) {
			        	        	        	
        	options.add(option);
        }
        
        update options;
        
    }
    
}