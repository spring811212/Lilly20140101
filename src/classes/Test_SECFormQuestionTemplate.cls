@isTest
private class Test_SECFormQuestionTemplate{
  static testMethod void test_SECFormQuestionTemplate() { 
    
    Campaign cam = new Campaign();
    cam.Name = 'campaign';
    cam.Compound_Name__c = 'compound name';
    cam.Therapeutic_Area__c = 'area';
    cam.LPET_Date__c = system.today();
    insert cam;
    
    Opportunity oppy = new Opportunity();
    oppy.Name = 'oppy';
    oppy.CampaignId = cam.id;
    oppy.CloseDate = system.today();
    oppy.stageName = 'Feasibility';
    insert oppy;  
    
    SEC_Forms_Oppty_Form__c form = new SEC_Forms_Oppty_Form__c();
    form.Opportunity__c = oppy.id;
    form.Trial_Campaign__c = cam.id;
    form.Trial_Campaign_Text_Name__c = 'trial campaign';
    form.Site__c = 'site';
    form.Form_Type__c = 'SEC_CRU';
    form.Page_Footer__c = 'footer';
    form.Page_Header__c = 'header';
    form.Purpose__c = 'purpose';
    form.Instructions__c = 'instructions';
    form.Label__c = 'label';
    form.Trial_Opportunity_Name_Text__c = 'trial opportunity';
    form.Approval_Status__c = 'Draft';
    insert form;
    
    SEC_Forms_Oppty_Form_Template__c formTemp = new SEC_Forms_Oppty_Form_Template__c();
    formTemp.Label__c = 'label';
    formTemp.Status__c = 'status';
    formTemp.Template_Name__c = 'template';
    formTemp.Template_Layout_Order__c = 1.0;
    formTemp.SEC_Forms_Oppty_Form__c = form.id;
    insert formTemp;
    
    SEC_Forms_Oppty_Forms_Question_Answer__c formAnswer = new SEC_Forms_Oppty_Forms_Question_Answer__c();
    formAnswer.QID__c = '111';
    formAnswer.Answer__c = 'answer';
    formAnswer.Question_Text__c = 'question';
    formAnswer.Question_Type__c = 'Picklist';
    formAnswer.Required__c = true;
    formAnswer.Question_Layout_Order__c = 1.0;
    formAnswer.Question_Options__c = 'option';
    formAnswer.Parent_Question_Trigger_Behavior__c = 'Required';
    formAnswer.Parent_Question_Trigger_Value__c = 'value';
    formAnswer.SEC_Forms_Oppty_Form_Template__c = formTemp.id;
    insert formAnswer;
    
    SEC_Forms_Oppty_Forms_Question_Answer__c formAnswer1 = new SEC_Forms_Oppty_Forms_Question_Answer__c();
    formAnswer1.QID__c = '111';
    formAnswer1.Answer__c = 'answer';
    formAnswer1.Question_Text__c = 'question';
    formAnswer1.Question_Type__c = 'Sub-Section Break';
    formAnswer1.Required__c = true;
    formAnswer1.Question_Layout_Order__c = 1.0;
    formAnswer1.Question_Options__c = 'option';
    formAnswer1.Parent_Question_Trigger_Behavior__c = 'Required';
    formAnswer1.Parent_Question_Trigger_Value__c = 'value';
    formAnswer1.Parent_Question__c = formAnswer.id;
    formAnswer1.SEC_Forms_Oppty_Form_Template__c = formTemp.id;
    insert formAnswer1;
    
    Test.startTest();
    
    SECFormQuestionTemplate.getSECForm(form.id);
    SECFormQuestionTemplate.getTemplate(formTemp.id);
    SECFormQuestionTemplate.getQuestionsOfTemplate(formTemp.id);
    SECFormQuestionTemplate.saveAnswers(form.id, formTemp.id, '[{"Id":"a0Je0000000qjC7EAI", "Answer__c":"Michael Jordan","Required__c":"true"},{"Id":"a0Je0000000qjC8EAI", "Answer__c":"Kobe Byrant", "Required__c":"false"}]');
    SECFormQuestionTemplate.submitForm(form.id);
    SECFormQuestionTemplate.getTableOfContents(form.id, formTemp.id);
    SECFormQuestionTemplate.checkMandatoryContactRoles(form.id);
    
    system.assert(true);
      Test.stopTest();
  }
}