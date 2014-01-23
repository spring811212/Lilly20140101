@isTest
private class Test_TemplateUtils {

    static testMethod void test_templateQuestionTrigger() {
        
        SEC_Forms_Template__c ft = [select Id from SEC_Forms_Template__c limit 1];
        SEC_Forms_Question__c fq = [select Id from SEC_Forms_Question__c Where Data_Type__c != 'Checkbox' limit 1];
        
        SEC_Forms_Template_Question__c tq1 = new SEC_Forms_Template_Question__c(
        	SEC_Forms_Template__c = ft.Id,
        	SEC_Forms_Question__c = fq.Id
        );
        
        insert tq1; //will pass
        
        SEC_Forms_Template_Question__c tq2 = new SEC_Forms_Template_Question__c(
        	SEC_Forms_Template__c = ft.Id,
        	SEC_Forms_Question__c = fq.Id,
        	Parent_Question__c = tq1.Id
        );
        
        insert tq2; //will pass
        
        SEC_Forms_Template_Question__c tq3 = new SEC_Forms_Template_Question__c(
        	SEC_Forms_Template__c = ft.Id,
        	SEC_Forms_Question__c = fq.Id,
        	Parent_Question__c = tq2.Id
        );
        
        try {
        	insert tq3; //will not pass
        	System.assertEquals(false, true);
        }
        catch (System.DMLException dex) { 
        	System.assertEquals(false, false);
        }
        
    }
}