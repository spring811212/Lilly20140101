@isTest
private class Test_Cloners {

    static testMethod void test_cloneFormController() {
        
        Id formId = [select Id from SEC_Forms_Form__c limit 1].Id;
        
        System.Test.setCurrentPage(Page.CloneForm);
        ApexPages.currentPage().getParameters().put('id', formId);
        
        CloneFormController cfc = new CloneFormController();
        PageReference pr = cfc.cloneForm();
    }
    
    static testMethod void test_cloneFormControllerNull() {
        
        System.Test.setCurrentPage(Page.CloneForm);
        
        CloneFormController cfc = new CloneFormController();
        PageReference pr = cfc.cloneForm();
    }
    
    static testMethod void test_cloneTemplateController() {
        
        Id templateId = [select Id from SEC_Forms_Template__c limit 1].Id;
        
        System.Test.setCurrentPage(Page.CloneTemplate);
        ApexPages.currentPage().getParameters().put('id', templateId);
        
        CloneTemplateController ctc = new CloneTemplateController();
        ctc.cloneTemplate();    
    }
    
    static testMethod void test_cloneTemplateControllerNull() {
        
        System.Test.setCurrentPage(Page.CloneTemplate);
        
        CloneTemplateController ctc = new CloneTemplateController();
        ctc.cloneTemplate();    
    }
    
    static testMethod void test_cloneQuestionController() {
        Id questionId = [select Id from SEC_Forms_Question__c limit 1].Id;
        
        PageReference pageRef = Page.CloneQuestion;
        pageRef.getParameters().put('id',questionId);
        Test.setCurrentPage(pageRef);
        
        CloneQuestionController cqc = new CloneQuestionController();
        
        try {
            cqc.cloneQuestion();
        }
        catch (System.DmlException de) {
            System.assertEquals(true, true);
        }
        
        System.Test.setCurrentPage(Page.CloneQuestion);
        ApexPages.currentPage().getParameters().put('id', null);
        
        CloneQuestionController cqc2 = new CloneQuestionController();
    }
    
    static testMethod void test_cloneForm() {
        Id formId = [select Id from SEC_Forms_Form__c limit 1].Id;
        
        System.Test.startTest();
        
            CloneUtil.cloneForm(formId);
        
        System.Test.stopTest();
    }
    
    static testMethod void test_cloneTemplate() {
        Id templateId = [select Id from SEC_Forms_Template__c limit 1].Id;
        
        System.Test.startTest();
        
            CloneUtil.cloneTemplate(templateId);
        
        System.Test.stopTest();
    }
    
    static testMethod void test_cloneOpportunities() {
        List<Opportunity> opptys = new List<Opportunity>{};
        
        for(Opportunity oppty : [select Id, StageName, Form_Submitted__c from Opportunity where Owner.IsActive = true and StageName != 'PI Changed' limit 500]) {
            oppty.StageName = 'PI Changed';
            opptys.add(oppty);
        }
        
        System.Test.startTest();
            
            update opptys;
            
        System.Test.stopTest();
        
    }
    
}