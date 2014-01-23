@isTest
private class Test_SECFormDemographics{
  static testMethod void test_SECFormDemographics() { 
    
    Account account = new Account(); 
    account.Name = 'Hospital';
    account.Type = 'Clinic';
    account.Therapeutic_Area__c = 'All';
    insert account;
    
    Contact c = new Contact();
    c.lastName = 'Jack';
    c.Phone = '12423489';
    c.Email = 'jack@lilly.com';
    c.Fax = '123463';
    c.MailingCountry = 'country';
    c.MailingState = 'state';
    c.MailingCity= 'city';
    c.MailingPostalCode = '200134';
    c.MailingStreet = 'street';
    c.OtherStreet = 'other street';
    c.OtherState = 'other state';
    c.OtherPostalCode = '432122';
    c.OtherCountry = 'other country';
    c.OtherCity = 'other city';
    c.AccountId = account.Id;
    insert c;
    
    Contact c1 = new Contact();
    c1.lastName = 'Peter';
    c1.Phone = '12216634';
    c1.Email = 'peter@lilly.com';
    c1.Fax = '123458';
    c1.MailingCountry = 'country';
    c1.MailingState = 'state';
    c1.MailingCity= 'city';
    c1.MailingPostalCode = '200133';
    c1.MailingStreet = 'street';
    c1.OtherStreet = 'other street';
    c1.OtherState = 'other state';
    c1.OtherPostalCode = '432112';
    c1.OtherCountry = 'other country';
    c1.OtherCity = 'other city';
    c1.AccountId = account.Id;
    insert c1;
    
    Campaign cam = new Campaign();
    cam.Name = 'campaign';
    cam.Compound_Name__c = 'compound name';
    cam.Therapeutic_Area__c = 'area';
    cam.LPET_Date__c = system.today();
    insert cam;
    
    CampaignMember cm = new CampaignMember();
    cm.CampaignId = cam.id;
    cm.ContactId = c.id;
    insert cm;
    
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
    form.Approval_Status__c = 'Draft';
    insert form;
    
    SEC_Forms_Oppty_Form__c form1 = new SEC_Forms_Oppty_Form__c();
    form1.Opportunity__c = oppy.id;
    form1.Trial_Campaign__c = cam.id;
    form1.Trial_Campaign_Text_Name__c = 'trial campaign';
    form1.Site__c = 'site';
    form1.Form_Type__c = 'SEC_CRU';
    form1.Approval_Status__c = 'Pending';
    insert form1;
    
    SEC_Forms_Oppty_Form_Template__c formTemp = new SEC_Forms_Oppty_Form_Template__c();
    formTemp.Label__c = 'label';
    formTemp.Status__c = 'status';
    formTemp.Template_Name__c = 'template';
    formTemp.Template_Layout_Order__c = 1.0;
    formTemp.SEC_Forms_Oppty_Form__c = form.id;
    insert formTemp;  
    
    Opportunity_Contact_Role__c ocr = new Opportunity_Contact_Role__c();
    ocr.Contact__c = c.id;
    ocr.Street__c = 'No.99 Avenue';
    ocr.State_Province__c = 'Shanghai';
    ocr.Zip_PostalCode__c = '12345';
    ocr.Country__c = 'China';
    ocr.City__c = 'Shanghai';
    ocr.Fax__c = '73224';
    ocr.Phone__c = '63513193';
    ocr.Email__c = 'aa@bb.com';
    ocr.Role__c = 'Principal Investigator';
    ocr.TrialSite__c = oppy.id;
    insert ocr;
    
    Opportunity_Contact_Role__c ocr1 = new Opportunity_Contact_Role__c();
    ocr1.Contact__c = c1.id;
    ocr1.Street__c = 'No.1 Building';
    ocr1.State_Province__c = 'Beijing';
    ocr1.Zip_PostalCode__c = '56789';
    ocr1.Country__c = 'China';
    ocr1.City__c = 'Beijing';
    ocr1.Fax__c = '32155';
    ocr1.Phone__c = '98763111';
    ocr1.Email__c = 'aa@bb.com';
    ocr1.Role__c = 'Data Manager';
    ocr1.TrialSite__c = oppy.id;
    insert ocr1;
    
    Test.startTest();
        SECFormDemographics.getTrialSiteId(form.id);
        SECFormDemographics.getSiteInfo(form.id);
        //SECFormDemographics.getSiteInfo(form1.id);
        SECFormDemographics.getRoleObjectList(form.id);
        SECFormDemographics.getOptionalRoleObjectList(form.id);
        //SECFormDemographics.getRoleContactObject('Principal Investigator', form.id);
        SECFormDemographics.getCurrentTrialContacts(form.id, '1');
        SECFormDemographics.getCurrentTrialContacts(form.id, '2');
        SECFormDemographics.getContactAddress(c.id, form.id);
        SECFormDemographics.searchContact('Jack', form.id, '2');
        SECFormDemographics.insertExistingContacts(form.id, 'MailingAddress', c.id, oppy.id, '1', 'country', 'state', 'city', 'street', '4321', '1234', '1234', 'aa@bb.com');
        SECFormDemographics.insertExistingContacts(form1.id, 'OtherAddress', c.id, oppy.id, '1', 'country', 'state', 'city', 'street', '4321', '1234', '1234', 'aa@bb.com');
        SECFormDemographics.updateExistingContacts(form.id, 'MailingAddress', ocr.Id, c.id, oppy.id, '1', 'country', 'state', 'city', 'street', '4321', '1234', '1234', 'aa@bb.com');
        SECFormDemographics.updateExistingContacts(form1.id,'OtherAddress', ocr1.Id, c.id, oppy.id, '1', 'country', 'state', 'city', 'street', '4321', '1234', '1234', 'aa@bb.com');
        SECFormDemographics.deleteExistingContacts(form.id, c.id, '1', oppy.id);
        SECFormDemographics.deleteExistingContacts(form.id, c1.id, '22', oppy.id);
        SECFormDemographics.getTableOfContents(form.id);
        SECFormDemographics.addDemographicsPage(form.id);
        
        system.assert(true);
      Test.stopTest();
  }
}