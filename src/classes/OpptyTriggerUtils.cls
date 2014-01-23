public with sharing class OpptyTriggerUtils {
    
    public static void beforeTriggerProcessing(List<Opportunity> oldOpptys, List<Opportunity> newOpptys) {
        
        //List<Opportunity_Approval_Helper__c> oahs = new List<Opportunity_Approval_Helper__c>{};
        /*
        Set<Id> opptyIds = new Set<Id>{};
        
        for(Integer i = 0; i < newOpptys.size(); i++) {
            //Form_Submitted__c
            if (!oldOpptys[i].Form_Submitted__c && newOpptys[i].Form_Submitted__c) {
                
                opptyIds.add(newOpptys[i].Id);
            }
        }
        
        if (opptyIds.size() > 0) {
            ApprovalUtils.approveOpportunity(opptyIds);
        }
        */
        //if (oahs.size() > 0) {
        //  insert oahs;
        //}

    }

    public static void afterTriggerProcessing(List<Opportunity> oldOpptys, List<Opportunity> newOpptys) {
        //Send emails when the trial site is selected
        if (newOpptys.size() == 1) {
            
            Opportunity newOppty = newOpptys[0];
            Opportunity oldOppty = null;
            Campaign cap = null;

            try {
                oldOppty = oldOpptys[0];
                cap = [select Id, Name from Campaign where Id = :newOppty.CampaignId]; //opportunity campaign name
                
                system.debug('*** cName: ' + cap.Name);
	            system.debug('*** oldOppty.StageName: ' + oldOppty.StageName);
	            system.debug('*** newOppty.StageName: ' + newOppty.StageName);
            }
            catch(System.Exception ex) {
            	system.debug('*** Exception: ' + ex);
            }
            
            if (oldOppty != null && cap != null && (oldOppty.StageName != 'Selected' && newOppty.StageName == 'Selected')) {
                system.debug('*** SECTrialSiteHelper.sendOpptyEmail(newOppty.Id, newOppty.OwnerId);');
                
                //Send the email whenever the trial site is selected from other stage
                //Prevent the emails are sent out twice if the trigger is fired twice in a transaction
                if(!SECFormTriggerHelper.hasAlreadyfired()){
                	SECTrialSiteHelper.sendOpptyEmail(newOppty.Id, newOppty.OwnerId);
                	SECFormTriggerHelper.setAlreadyfired();
                }
            }
        }
        
        try {
            Set<Id> opptyIds = new Set<Id>{};
            Map<Id,String> opptyIdsForStages = new Map<Id,String>{};
            
            for(Integer i = 0; i < newOpptys.size(); i++) {
                //Form_Submitted__c
                if (!oldOpptys[i].Form_Submitted__c && newOpptys[i].Form_Submitted__c) {
                    
                    opptyIds.add(newOpptys[i].Id);
                }
                
                if (oldOpptys[i].StageName != newOpptys[i].StageName) {
                   
                    opptyIdsForStages.put(newOpptys[i].Id,newOpptys[i].StageName);
                }                
                
            }
            
            if (opptyIds.size() > 0) {
                ApprovalUtils.approveOpportunity(opptyIds);
            }
           
            if (opptyIdsForStages.size() > 0) {
                updateStages(opptyIdsForStages);
            }            

        }
        catch (System.NullPointerException npe) {}
        /*
        // contacts now copied during instantiation 
        List<Opportunity> selectedOpptys = new List<Opportunity>{};
        for(Integer i = 0; i < newOpptys.size(); i++) {
            Opportunity oldOppty = null;
            try {
                oldOppty = oldOpptys.get(i);
            } catch (System.Exception ex) {}
            Opportunity newOppty = newOpptys.get(i);
            
            if (oldOppty != null) {
                if (oldOppty.StageName != 'Selected' && newOppty.StageName == 'Selected') {
                    selectedOpptys.add(newOppty);
                }
            }
        }
        
        if (selectedOpptys.size() > 0) {
            contactsToOpptyFormTemplate(selectedOpptys);
        }
        */
        
        updateApprovalStatus(oldOpptys);
        
    }
    
    //Update the approval status on the SEC_Forms_Oppty_Form__c object
    public static void updateApprovalStatus(List<Opportunity> oldOpptys){
    	if(oldOpptys != null && oldOpptys.size() > 0){
	        List<Id> opptyIdList = new List<Id>();
	        for(Opportunity oppty : oldOpptys){
	            opptyIdList.add(oppty.Id);
	        }
	        List<Opportunity> opptyList = [SELECT Id,Form_Approval_Status__c,Form_Under_Approval__r.Approval_Status__c FROM Opportunity WHERE Id in :opptyIdList];
	        List<SEC_Forms_Oppty_Form__c> trailSiteFormList = new List<SEC_Forms_Oppty_Form__c>();
	        for(Opportunity oppty : opptyList){
	            if(oppty.Form_Under_Approval__r != null && oppty.Form_Under_Approval__r.Approval_Status__c != oppty.Form_Approval_Status__c){
	                oppty.Form_Under_Approval__r.Approval_Status__c = oppty.Form_Approval_Status__c;
	                trailSiteFormList.add(oppty.Form_Under_Approval__r);
	            }
	        }
	        system.debug('** trailSiteFormList: ' + trailSiteFormList);
	        update trailSiteFormList;
        }
    }

    public static void updateStages(map<id,String> opptyIds) 
    {
        List<SEC_Forms_Oppty_Form__c> opptyFormsToUpdate = new List<SEC_Forms_Oppty_Form__c>();
   
        for (SEC_Forms_Oppty_Form__c thisOpptyForm : [SELECT Id,Opportunity__c,Trial_Opportunity_Stage__c from SEC_Forms_Oppty_Form__c where Opportunity__c in : opptyIds.keyset()]) 
        {
          thisOpptyForm.Trial_Opportunity_Stage__c = opptyIds.get(thisOpptyForm.Opportunity__c);
          opptyFormsToUpdate.add(thisOpptyForm);
        }

        update opptyFormsToUpdate;
    }

    /*
    private static void contactsToOpptyFormTemplate(List<Opportunity> opptys) {
        
        Map<Id, List<Id>> contactToContactRoles = new Map<Id,List<Id>>{}; //C=>CR[]
        Map<Id,String> contactRoleRole = new Map<Id,String>{}; //CR=>Role
        Map<Id,Id> contactRoleToOppty = new Map<Id,Id>{}; //CR=>OP
        Map<Id,List<Id>> opptyToContacts = new Map<Id,List<Id>>{}; //OP=>C[]
        
        Map<Id,Id> formTemplateToOppty = new Map<Id,Id>{}; //FT=>OP
        Map<Id,Contact> contacts = new Map<Id,Contact>{}; //C.Id=>C
        
        Set<Id> opptyIds = new Set<Id>{};
        Set<Id> contactIds = new Set<Id>{};
        
        for(Opportunity o : opptys) {
            opptyIds.add(o.Id);
        }
            
        for(OpportunityContactRole ocr : [select Id, ContactId, OpportunityId, Role from OpportunityContactRole where OpportunityId in :opptyIds]) {
            contactRoleRole.put(ocr.Id, ocr.Role);
            contactIds.add(ocr.ContactId);
            contactRoleToOppty.put(ocr.Id, ocr.OpportunityId);
            if (contactToContactRoles.containsKey(ocr.ContactId)) {
                contactToContactRoles.get(ocr.ContactId).add(ocr.Id);
            }
            else {
                contactToContactRoles.put(ocr.ContactId, new List<Id> {ocr.Id});    
            }
        }
        
        System.debug('####contactIds:' + contactIds);
        if (contactIds.size() > 0) {
        
            for(Contact c : [select Id, Name, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where Id in :contactIds]) {
                contacts.put(c.Id, c);
                
                for(Id roleId : contactToContactRoles.get(c.Id)) {
                    Id oid = contactRoleToOppty.get(roleId);
                    
                    System.debug('####oid:' + oid);
                    
                    if (opptyToContacts.containsKey(oid)) {
                        opptyToContacts.get(oid).add(c.Id); 
                    }
                    else {
                        opptyToContacts.put(oid, new List<Id> {c.Id});
                    }
                }
            }
            
            List<SEC_Forms_Oppty_Form_Template__c> formTemplates = new List<SEC_Forms_Oppty_Form_Template__c>{};
            
            Map<Id,Id> formToOppty = new Map<Id,Id>{}; //OF=>OP
            for(SEC_Forms_Oppty_Form__c form : [select Id, Opportunity__c from SEC_Forms_Oppty_Form__c where Opportunity__c in :opptyIds]) {
                formToOppty.put(form.Id, form.Opportunity__c);
                formTemplates.add(new SEC_Forms_Oppty_Form_Template__c(
                    SEC_Forms_Oppty_Form__c = form.Id
                ));
            }
            
            insert formTemplates;
            
            List<SEC_Forms_Oppty_Forms_Question_Answer__c> qas = new List<SEC_Forms_Oppty_Forms_Question_Answer__c>{};
            
            for(SEC_Forms_Oppty_Form_Template__c oft : formTemplates) {
                formTemplateToOppty.put(oft.Id, formToOppty.get(oft.SEC_Forms_Oppty_Form__c));
                
                Id oid = formToOppty.get(oft.SEC_Forms_Oppty_Form__c);
                
                if (oid != null) {
                    for(Id contactId : opptyToContacts.get(oid)) {
                        
                        Contact c = contacts.get(contactId);
                        String role = null; 
                        
                        for (Id roleId : contactToContactRoles.get(contactId)) {
                            if (contactRoleToOppty.get(roleId) == oid) {
                                role = contactRoleRole.get(roleId);
                                break;
                            }
                        }
                        
                        String info = c.Name + '\n' +
                                      c.MailingStreet + '\n' +
                                      c.MailingCity + ', ' + c.MailingState + ' ' + c.MailingPostalCode + '\n' +
                                      c.MailingCountry + '\n' +
                                      'Phone: ' + c.Phone + '\n' +
                                      'Mobile: ' + c.MobilePhone + '\n' +
                                      'Email: ' + c.Email;
                                        
                        qas.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                            Question_Type__c = 'Comment',
                            Question_Text__c = role,
                            Answer__c = info,
                            SEC_Forms_Oppty_Form_Template__c = oft.Id
                        )); 
                    }
                }
            }
            
            if (qas.size() > 0) {
                insert qas;
            }
        
            System.debug('#####qas:' + qas);
        }
    }
    */
}