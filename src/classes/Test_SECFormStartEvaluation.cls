@isTest
private class Test_SECFormStartEvaluation{
  static testMethod void test_getSECFormInfo() {
    SEC_Forms_Oppty_Form__c form = new SEC_Forms_Oppty_Form__c();
    form.Trial_Opportunity_Name_Text__c = 'opportunity name';
    form.Purpose__c = 'purpose';
    form.Page_Header__c = 'header';
    form.Page_Footer__c = 'footer';
    form.Label__c = 'label';
    form.Instructions__c = 'instructions';
    insert form;
    
    SEC_Forms_Oppty_Form__c form1 = new SEC_Forms_Oppty_Form__c();
    form1.Trial_Opportunity_Name_Text__c = 'opportunity name';
    form1.Purpose__c = 'purpose';
    form1.Page_Header__c = 'header';
    form1.Page_Footer__c = 'footer';
    form1.Label__c = 'label';
    form1.Instructions__c = 'instructions';
    insert form1;
    
    SEC_Forms_Oppty_Form_Template__c formTemp = new SEC_Forms_Oppty_Form_Template__c();
    formTemp.Label__c = 'label';
    formTemp.Status__c = 'status';
    formTemp.Template_Name__c = 'template';
    formTemp.Template_Layout_Order__c = 1.0;
    formTemp.SEC_Forms_Oppty_Form__c = form.id;
    insert formTemp;  
    
    Test.startTest();
        SECFormStartEvaluation.getSECFormInfo(form.id);
        SECFormStartEvaluation.checkFormValid(form.id);
        SECFormStartEvaluation.checkFormValid(form1.id);
        system.assert(true);
      Test.stopTest();
  }
}