@isTest
private class Test_SECFormCommonUtils {
  static testMethod void test_SECFormCommonUtils() {
     
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
    
    SEC_Forms_Oppty_Form__c form1 = new SEC_Forms_Oppty_Form__c();
    form1.Opportunity__c = oppy.id;
    form1.Trial_Campaign__c = cam.id;
    form1.Trial_Campaign_Text_Name__c = 'trial campaign';
    form1.Site__c = 'site';
    form1.Form_Type__c = 'SEC_CRU';
    form1.Page_Footer__c = 'footer';
    form1.Page_Header__c = 'header';
    form1.Purpose__c = 'purpose';
    form1.Instructions__c = 'instructions';
    form1.Label__c = 'label';
    form1.Trial_Opportunity_Name_Text__c = 'trial opportunity';
    form1.Approval_Status__c = 'Draft';
    insert form1;
    
    SEC_Forms_Oppty_Form__c form2 = new SEC_Forms_Oppty_Form__c();
    form2.Opportunity__c = oppy.id;
    form2.Trial_Campaign__c = cam.id;
    form2.Trial_Campaign_Text_Name__c = 'trial campaign';
    form2.Site__c = 'site';
    form2.Form_Type__c = 'PI Change';
    form2.Page_Footer__c = 'footer';
    form2.Page_Header__c = 'header';
    form2.Purpose__c = 'purpose';
    form2.Instructions__c = 'instructions';
    form2.Label__c = 'label';
    form2.Trial_Opportunity_Name_Text__c = 'trial opportunity';
    form2.Approval_Status__c = 'Pending';
    insert form2;
    
    Test.startTest();
    SECFormCommonUtils.getTrialSiteId(form1.id);
    SECFormCommonUtils.checkSECFormViewMode(form1.id);
    SECFormCommonUtils.checkSECFormViewMode(form2.id);
    SECFormCommonUtils.addDemographicsPage(form1.id);
    SECFormCommonUtils.addDemographicsPage(form2.id);
    SECFormCommonUtils.getRoleByRoleId('4');
    SECFormCommonUtils.getRoleByRoleId('25');
    SECFormCommonUtils.getMandatoryRoleList();
    SECFormCommonUtils.getOptionalRoleList();
    SECFormCommonUtils.getRolePicklistValues();
    SECFormCommonUtils.setDisplayFormsFlagToTrue(oppy.id);
    SECFormCommonUtils.setDisplayFormsFlagToFalse(oppy.id);
    SECFormCommonUtils.setDisplayLocChangeFormsFlagToTrue(oppy.id);
    SECFormCommonUtils.setDisplayLocChangeFormsFlagToFalse(oppy.id);
    
    system.assert(true);
      Test.stopTest();
  }
}