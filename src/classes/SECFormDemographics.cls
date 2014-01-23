/**
 * SECFormDemographics
 * The class is used to store all the common methods and web services supporting business logic on page 'SECFormDemographics'
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */

global class SECFormDemographics{
    
    public class DemographicsContact{
        public String name {get;set;}
        public String mailingCountry {get;set;}
        public String mailingState {get;set;}
        public String mailingCity {get;set;}
        public String mailingStreet {get;set;}
        public String mailingPostalCode {get;set;}
        public String otherCountry {get;set;}
        public String otherState {get;set;}
        public String otherCity {get;set;}
        public String otherStreet {get;set;}
        public String otherPostalCode {get;set;}
        public String trialSiteCountry {get;set;}
        public String trialSiteState {get;set;}
        public String trialSiteCity {get;set;}
        public String trialSiteStreet {get;set;}
        public String trialSitePostalCode {get;set;}
        public String phone {get;set;}
        public String fax {get;set;}
        public String email {get;set;}
        public String additionalEmail {get;set;}
        public String therapeuticArea {get;set;}
        public String trialSiteContactRoleId {get;set;} // Trial Site Contact Role ID
        public String Id {get;set;} // Contact ID
        public String role {get;set;}
    }
    
    public class TableOfContents{
        public String Id {get;set;}
        public String label {get;set;}
        public String status {get;set;}
    }
    
    public class RoleObject{
        public String Id {get;set;}
        public String label {get;set;}
        public List<DemographicsContact> initContacts {get;set;}
        RoleObject(String Id, String label, List<DemographicsContact> initContacts){
            this.Id = Id;
            this.label = label;
            this.initContacts = initContacts;
        }
    }
    
    public class SiteInfo{
        public String lillyRepresentative {get;set;}
        public String compound {get;set;}
        public String trialAlias {get;set;}
        public String siteName {get;set;}
    }
    
    public class AddressInfo{
        public String street {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String postalCode {get;set;}
        public String country {get;set;}
        public String phone {get;set;}
        public String fax {get;set;}
        public String email {get;set;}
        public String displayName {get;set;}
    }
    

    //Get trial site Id by SEC Form Opportunity ID
    webservice static String getTrialSiteId(ID SECFormOpptyFormId){
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        
        Map<String,String> m=new Map<String,String>();
        m.put('trialSitedId',trialSiteId);
        String result = JSON.serialize(m);
        return result;
    }
    //sv: get the id from Oppt contact role object with trialsiteid and contactid
    webservice static string getocrId(Id SECFormOpptyFormId, Id ContactId, string RoleId){
    //get the role name
     String role = SECFormCommonUtils.getRoleByRoleId(RoleId);
     ID ocrId = SECFormCommonUtils.getocrId(SECFormOpptyFormId,ContactId,role);
     system.debug('orcrid: ' + ocrId); 
        
    
    Map<String,String> m=new Map<String,String>();
        m.put('ocrid',ocrId);
        String result = JSON.serialize(m);
        return result;
        }
        
    //Get Site information - Lilly Representative, Compound, Trial Alias, Site Name
    webservice static String getSiteInfo(ID SECFormOpptyFormId){
        
        SiteInfo siteInfo = new SiteInfo();
        
        for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT CreatedBy.Name, Trial_Campaign__r.Compound_Name__c, Trial_Campaign_Text_Name__c, Site__c FROM SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId]){
            
            siteInfo.lillyRepresentative = opptyForm.CreatedBy.Name;
            siteInfo.compound = opptyForm.Trial_Campaign__r.Compound_Name__c;
            siteInfo.trialAlias = opptyForm.Trial_Campaign_Text_Name__c;
            siteInfo.siteName = opptyForm.Site__c;
        }
        String result = JSON.serialize(siteInfo);
        return result;
    }
    
    //Get 14 mandatory role objects listed in class 'SECFormCommonUtils'
    webservice static String getRoleObjectList(ID SECFormOpptyFormId){
       
        List<RoleObject> roleObjectList = new List<RoleObject>();
        RoleObject roleObject;
        Integer roleId = 0;
        
        List<DemographicsContact> demoContactList = getRoleContactObjectByForm(SECFormOpptyFormId);
         
        for(String roleName : SECFormCommonUtils.getMandatoryRoleList()){
            roleId++;
            roleObject = new RoleObject(String.valueOf(roleId), roleName, getRoleContactObjectByRole(roleName, demoContactList));
            roleObjectList.add(roleObject);
        }
        
        String result = JSON.serialize(roleObjectList);
        return result;
    }
    
    //Get 26 optional role objects listed in class 'SECFormCommonUtils'
    webservice static String getOptionalRoleObjectList(ID SECFormOpptyFormId){
        List<RoleObject> optionalRoleObjectList = new List<RoleObject>();
        RoleObject optionalRoleObject;
        Integer optionalRoleId = SECFormCommonUtils.getMandatoryRoleList().size();
        
        List<DemographicsContact> demoContactList = getRoleContactObjectByForm(SECFormOpptyFormId);
        for(String optionalRoleName : SECFormCommonUtils.getOptionalRoleList()){
            optionalRoleId++;
            optionalRoleObject = new RoleObject(String.valueOf(optionalRoleId), optionalRoleName, getRoleContactObjectByRole(optionalRoleName, demoContactList));
            optionalRoleObjectList.add(optionalRoleObject);
        }
        
        String result = JSON.serialize(optionalRoleObjectList);
        return result;
    }
    
   
    
     //Get Site Contacts, filtering assigned person
    webservice static String getCurrentTrialContacts(ID SECFormOpptyFormId, String roleId){    
        
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        
        String role = SECFormCommonUtils.getRoleByRoleId(roleId);
        
        //Get assigned Opportunity Contact Role IDs in a Trial Site by role
        Set<ID> opptyContactRoleIdSet = new Set<ID>();
        for(Opportunity_Contact_Role__c ocr : [SELECT Contact__c FROM Opportunity_Contact_Role__c WHERE TrialSite__c =: trialSiteId and Role__c =: role]){
            opptyContactRoleIdSet.add(ocr.Contact__c);
        }
        //Get Site Contact info
        List<DemographicsContact> contactList=new List<DemographicsContact>();
        
        //Get Site Id
        String siteId = null;
        for(Opportunity oppty : [SELECT AccountId FROM Opportunity WHERE Id =: trialSiteId LIMIT 1]){
            siteId = oppty.AccountId;
        }  
        
        //Get active Site contact info
        if(siteId != null){
            for(Contact c : [SELECT Id, Name, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Fax, Email, Phone, Therapeutic_Area__c, Additional_email_address__c 
                             FROM Contact 
                             WHERE AccountId =: siteId and Status__c = 'Active']){
                           
                DemographicsContact contact=new DemographicsContact();
                
                if(!opptyContactRoleIdSet.contains(c.Id)){
                    
                  contact.Id = c.Id;
                  contact.trialSiteContactRoleId = c.Id;
                  contact.name = c.Name;
                  contact.mailingStreet = (c.MailingStreet == null ? '' : c.MailingStreet);
                  contact.mailingCity = (c.MailingCity == null ? '' : c.MailingCity);
                  contact.mailingState = (c.MailingState == null ? '' : c.MailingState);
                  contact.mailingPostalCode = (c.MailingPostalCode == null ? '' : c.MailingPostalCode);
                  contact.mailingCountry = (c.MailingCountry == null ? '' : c.MailingCountry);
                  contact.phone = (c.Phone == null ? '' : c.Phone);
                  contact.fax = (c.Fax == null ? '' : c.Fax);
                  contact.email = (c.Email == null ? '' : c.Email);
                  contact.additionalEmail = (c.Additional_email_address__c == null ? '' : c.Additional_email_address__c);
                  contact.therapeuticArea = (c.Therapeutic_Area__c == null ? '' : c.Therapeutic_Area__c);
                  
                  contactList.add(contact);
                }
            }
        }
        
        String result = JSON.serialize(contactList);
        //String result = '';
        return result;
    } 
    
    //Get "Mailing address","Other address" in Contact, "Address" in Opportunity Contact Role
    webservice static String getContactAddress(ID contactId, ID SECFormOpptyFormId){
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        List<AddressInfo> addressList = new List<AddressInfo>();
        system.debug('contactid' + contactid + ' trialsite id' + trialsiteid);
        //Get Opportunity Contact Role info
        for(Opportunity_Contact_Role__c ocr : [SELECT Zip_PostalCode__c, Street__c, State_Province__c, Contact__c, City__c, Country__c, Phone__c, Fax__c, Email__c, Role__c
                                               FROM Opportunity_Contact_Role__c  
                                               WHERE Contact__c =: contactId and TrialSite__c =: trialSiteId]){
            AddressInfo address = new AddressInfo();
            
            address.street = (ocr.Street__c == null ? '' : ocr.Street__c);
            address.city = (ocr.City__c == null ? '' : ocr.City__c);
            address.state = (ocr.State_Province__c == null ? '' : ocr.State_Province__c);
            address.postalCode = (ocr.Zip_PostalCode__c == null ? '' : ocr.Zip_PostalCode__c);
            address.country = (ocr.Country__c == null ? '' : ocr.Country__c);
            address.phone = (ocr.Phone__c == null ? '' : ocr.Phone__c);
            address.fax = (ocr.Fax__c == null ? '' : ocr.Fax__c);
            address.email = (ocr.Email__c == null ? '' : ocr.Email__c);
            address.displayName = ocr.Role__c + ': Address';
            
            addressList.add(address);
        }
        
        //Get Contact mailing address / other address info
        for(Contact contact : [SELECT Phone, OtherStreet, OtherState, OtherPostalCode, OtherCountry, OtherCity, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Id, Fax, Email 
                               FROM Contact c 
                               WHERE Id =: contactId LIMIT 1]){
        
            AddressInfo address = new AddressInfo();
            address.street = (contact.MailingStreet == null ? '' : contact.MailingStreet);
            address.city = (contact.MailingCity == null ? '' : contact.MailingCity);
            address.state = (contact.MailingState == null ? '' : contact.MailingState);
            address.postalCode = (contact.MailingPostalCode == null ? '' : contact.MailingPostalCode);
            address.country = (contact.MailingCountry == null ? '' : contact.MailingCountry);
            address.phone = (contact.Phone == null ? '' : contact.Phone);
            address.fax = (contact.Fax == null ? '' : contact.Fax);
            address.email = (contact.Email == null ? '' : contact.Email);
            address.displayName = 'Contact: Mailing Address';
            
            addressList.add(address);
               
            address = new AddressInfo();
            address.street = (contact.OtherStreet == null ? '' : contact.OtherStreet);
            address.city = (contact.OtherCity == null ? '' : contact.OtherCity);
            address.state = (contact.OtherState == null ? '' : contact.OtherState);
            address.postalCode = (contact.OtherPostalCode == null ? '' : contact.OtherPostalCode);
            address.country = (contact.OtherCountry == null ? '' : contact.OtherCountry);
            address.phone = (contact.Phone == null ? '' : contact.Phone);
            address.fax = (contact.Fax == null ? '' : contact.Fax);
            address.email = (contact.Email == null ? '' : contact.Email);
            address.displayName = 'Contact: Other Address';
            
            addressList.add(address);
        }
        
        if(addressList.size() > 0)
        {       
            String result = JSON.serialize(addressList);
            return result;
        }else{
            String msg = 'No Address Found!';
            String result = JSON.serialize(msg);
            return result;
        }
    }
    
    //Secarch contacts information, including all the contacts in the system
    webservice static String searchContact(String searchText, ID SECFormOpptyFormId, String roleId){
        
        String txt = '%' + searchText + '%';
        List<DemographicsContact> resultList = new List<DemographicsContact>();
        
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        String role = SECFormCommonUtils.getRoleByRoleId(roleId);
        
        //Get assigned Opportunity Contact Role IDs in a Trial Site by role
        Set<ID> opptyContactRoleIdSet = new Set<ID>();
        for(Opportunity_Contact_Role__c ocr : [SELECT Contact__c FROM Opportunity_Contact_Role__c WHERE TrialSite__c =: trialSiteId and Role__c =: role]){
            opptyContactRoleIdSet.add(ocr.Contact__c);
        }
        
        for (Contact c : [SELECT Id, Name, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode, Therapeutic_Area__c, Phone, Email, Fax, Additional_email_address__c
                          FROM Contact 
                          WHERE Name LIKE: txt]){
                            
            DemographicsContact contact = new DemographicsContact();
            
            if(!opptyContactRoleIdSet.contains(c.Id)){
                contact.trialSiteContactRoleId = c.Id;
                contact.Id = c.Id;
                contact.name = c.Name;
                contact.mailingCountry = (c.MailingCountry == null ? '' : c.MailingCountry);
                contact.mailingState = (c.MailingState == null ? '' : c.MailingState);
                contact.mailingCity = (c.MailingCity == null ? '' : c.MailingCity);
                contact.mailingStreet = (c.MailingStreet == null ? '' : c.MailingStreet);
                contact.mailingPostalCode = (c.MailingPostalCode == null ? '' : c.MailingPostalCode);
                contact.therapeuticArea = (c.Therapeutic_Area__c == null ? '' : c.Therapeutic_Area__c);
                contact.phone = (c.Phone == null ? '' : c.Phone);
                contact.fax = (c.Fax == null ? '' : c.Fax);
                contact.email = (c.Email == null ? '' : c.Email);
                contact.additionalEmail = (c.Additional_email_address__c == null ? '' : c.Additional_email_address__c);
                
                resultList.add(contact);
            }
        }
        String result = JSON.serialize(resultList);
        return result;
    }
    
    
    //Save contact info to Opportunity Contact Role
    webservice static String insertExistingContacts(ID SECFormOpptyFormId, String addressOption, ID contactId, ID trialSiteId, String roleId, String country, String state, String city, String street, String postalCode, String phone, String fax, String email){ 
        
        Opportunity_Contact_Role__c ocr = new Opportunity_Contact_Role__c();
        
        Boolean updateContactAddress = true;
        
        //Set values for Opportunity Contact Role
        String role = SECFormCommonUtils.getRoleByRoleId(roleId);
                
        ocr.TrialSite__c = trialSiteId; 
        ocr.Contact__c = contactId;
        ocr.Role__c = role;
        ocr.Country__c = country;
        ocr.State_Province__c = state;
        ocr.City__c = city;
        ocr.Street__c = street;
        ocr.Zip_PostalCode__c = postalCode;
        ocr.Phone__c = phone;
        ocr.Email__c = email;
        ocr.Fax__c = fax;
        
        //Set values for Contact Mailing address / Other Address
        List<Contact> contactList = new List<Contact>();
        for(Contact contact : [SELECT Id, OtherStreet, OtherState, OtherPostalCode, OtherCountry, OtherCity, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Fax, Email, Phone, Additional_email_address__c, Therapeutic_Area__c
                               FROM Contact
                               WHERE Id =: contactId]){
            ocr.Therapeutic_Area__c = contact.Therapeutic_Area__c;
            ocr.Email_address_for_Safety_Mailings__c = contact.Additional_email_address__c;
            
            if(addressOption == 'MailingAddress'){
                contact.Id = contactId;
                contact.MailingStreet = street;
                contact.MailingCity = city;
                contact.MailingPostalCode = postalCode;
                contact.MailingState = state;
                contact.MailingCountry = country;
                contact.Phone = phone;
                contact.Fax = fax;
                contact.Email = email;
                contactList.add(contact);
            }
            else if (addressOption == 'OtherAddress'){
                contact.Id = contactId;
                contact.OtherStreet = street;
                contact.OtherCity = city;
                contact.OtherPostalCode = postalCode;
                contact.OtherState = state;
                contact.OtherCountry = country;
                contact.Phone = phone;
                contact.Fax = fax;
                contact.Email = email;
                contactList.add(contact);
            }else{
                updateContactAddress = false;
            }
        }
        
        
        Map<String,String> m=new Map<String,String>();
        
        //Form is editable until it is approved
        if (SECFormCommonUtils.getSECFormViewMode(SECFormOpptyFormId) == 'Editable'){
            try{
                insert ocr;
                //system.debug('----- Insert Successfully!');
                if(updateContactAddress == true)
                    update contactList;
                m.put('Msg','Insert Successfully!');
                m.put('Success','1'); // Insert successfully
                String result = JSON.serialize(m);
                return result;
            }catch(DMLException e){
                //system.debug('----- Insert Exception: ' + e);
                m.put('Msg', Label.Duplicate_PI_Role);
                m.put('Success','0'); // Insert failed
                String result = JSON.serialize(m);
                return result;
            }
        }
        else{
            m.put('Msg','Warning: Not Editable!');
            m.put('Success','0'); // Insert failed
            String result = JSON.serialize(m);
            return result;
        }
    }
 
    //Update Opportunity Contact Role info         
    webservice static String updateExistingContacts(ID SECFormOpptyFormId, String addressOption, ID trialSiteContactRoleId, ID contactId, ID trialSiteId, String roleId, String country, String state, String city, String street, String postalCode, String phone, String fax, String email){
        
        //Set values for Opportunity Contact Role
        String role = SECFormCommonUtils.getRoleByRoleId(roleId);
        Boolean updateContactAddress = true;
        
        List<Opportunity_Contact_Role__c> ocrList = new List<Opportunity_Contact_Role__c>();
        
        //Record to update
        //sv
        if(contactId == trialSiteContactRoleId){
         for(Opportunity_Contact_Role__c ocr : [SELECT id, TrialSite__c, Street__c, State_Province__c, Phone__c, Fax__c, Email__c, Country__c, Contact__c 
                                               FROM Opportunity_Contact_Role__c 
                                               WHERE TrialSite__c =: trialSiteId AND Contact__c =: contactId]){
                                               
            
            ocr.Id = ocr.Id;
            ocr.Country__c = country;
            ocr.State_Province__c = state;
            ocr.City__c = city;
            ocr.Street__c = street;
            ocr.Zip_PostalCode__c = postalCode;
            ocr.Phone__c = phone;
            ocr.Fax__c = fax;
            ocr.Email__c = email;  
            
            ocrList.add(ocr);
        }
        }
        Else {
        for(Opportunity_Contact_Role__c ocr : [SELECT  TrialSite__c, Street__c, State_Province__c, Phone__c, Fax__c, Email__c, Country__c, Contact__c 
                                               FROM Opportunity_Contact_Role__c 
                                               WHERE TrialSite__c =: trialSiteId AND Id =: trialSiteContactRoleId]){
                                               
            
            ocr.Id = trialSiteContactRoleId;
            ocr.Country__c = country;
            ocr.State_Province__c = state;
            ocr.City__c = city;
            ocr.Street__c = street;
            ocr.Zip_PostalCode__c = postalCode;
            ocr.Phone__c = phone;
            ocr.Fax__c = fax;
            ocr.Email__c = email;  
            
            ocrList.add(ocr);
        }
        }
          
        //Set values for Contact Mailing address / Other address
        List<Contact> contactList = new List<Contact>();
        for(Contact contact : [SELECT Id, OtherStreet, OtherState, OtherPostalCode, OtherCountry, OtherCity, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Fax, Email, Phone
                               FROM Contact
                               WHERE Id =: contactId]){
            if(addressOption == 'MailingAddress'){
                contact.Id = contactId;
                contact.MailingStreet = street;
                contact.MailingCity = city;
                contact.MailingPostalCode = postalCode;
                contact.MailingState = state;
                contact.MailingCountry = country;
                contact.Phone = phone;
                contact.Fax = fax;
                contact.Email = email;
                contactList.add(contact);
            }
            else if (addressOption == 'OtherAddress'){
                contact.Id = contactId;
                contact.OtherStreet = street;
                contact.OtherCity = city;
                contact.OtherPostalCode = postalCode;
                contact.OtherState = state;
                contact.OtherCountry = country;
                contact.Phone = phone;
                contact.Fax = fax;
                contact.Email = email;
                contactList.add(contact);
            }else{
                updateContactAddress = false;
            }
        }
        
        Map<String,String> m = new Map<String,String>();
        
        //Form is editable until it is approved    
        if (SECFormCommonUtils.getSECFormViewMode(SECFormOpptyFormId) == 'Editable'){    
            try{
                if(!ocrList.isEmpty())
                    update ocrList;
                if(updateContactAddress == true)
                    update contactList;
                m.put('Msg','Update Successfully!');
                m.put('Success','1'); // Update successfully
                String result = JSON.serialize(m);
                return result;
          }catch(DMLException e){
                //system.debug('----- Update Exception: ' + e);
                m.put('Msg','Update failed!');
                m.put('Success','0'); // Update failed
                String result = JSON.serialize(m);
                return result;
          }
        }
        else{
            m.put('Msg', 'Warning: Not Editable!');
            m.put('Success','0'); // Update failed, the form is in Read-Only mode
            String result = JSON.serialize(m);
            return result;
        }
    }
    
    
    //Delete Opportunity Contact Role info
    webservice static String deleteExistingContacts(ID SECFormOpptyFormId, ID contactId, String roleId, ID trialSiteId){
        
        String role = SECFormCommonUtils.getRoleByRoleId(roleId);
        
        List<Opportunity_Contact_Role__c> ocrList = new List<Opportunity_Contact_Role__c>();
        
        for(Opportunity_Contact_Role__c ocr : [SELECT Id FROM Opportunity_Contact_Role__c WHERE TrialSite__c =: trialSiteId and Contact__c =:contactId and Role__c =: role]){
            ocrList.add(ocr);
        }
        
        Map<String,String> m = new Map<String,String>();
        if (SECFormCommonUtils.getSECFormViewMode(SECFormOpptyFormId) == 'Editable'){
            
            try{
                if(!ocrList.isEmpty())
                    delete ocrList;
                m.put('Msg','Delete Successfully!');
                m.put('Success','1'); // Delete successfully
                String result = JSON.serialize(m);
                return result;
            }catch(DMLException e){
                //system.debug('----- Delete Exception: ' + e);
                m.put('Msg','Delete Failed!');
                m.put('Success','0'); // Delete failed
                String result = JSON.serialize(m);
                return result;
            }
        }
        else{
            m.put('Msg', 'Warning: Not Editable!');
            m.put('Success','0'); // Delete failed, it's in Read-Only mode
            String result = JSON.serialize(m);
            return result;
        }
    }
  
    //Get lists for Table of Contects
    webservice static String getTableOfContents(ID SECFormOpptyFormId){
        
        List<TableOfContents> resultList = new List<TableOfContents>();
        
        //Check if this form has the first 'Demographics' page which is only for form type - 'SEC_CRU'
        if(SECFormCommonUtils.addDemographicsPage(SECFormOpptyFormId)){
            TableOfContents demoPage = new TableOfContents();
            demoPage.Id = String.valueOf(1);
            demoPage.label = Label.SEC_Form_Demographics_Page_Name; //configrable Custom Labels
            demoPage.status = SECFormCommonUtils.PAGE_CURRENT;
            resultList.add(demoPage);
          }
          
        for(SEC_Forms_Oppty_Form_Template__c formTemplate : [SELECT Label__c, Id, Status__c, Template_Name__c, Template_Layout_Order__c 
                                                             FROM SEC_Forms_Oppty_Form_Template__c 
                                                             WHERE SEC_Forms_Oppty_Form__c =: SECFormOpptyFormId]){
            //filter Trailforce automatically added question template of contact info for form type - 'SEC_CRU'
            if(formTemplate.Label__c != null && formTemplate.Template_Name__c != null && formTemplate.Template_Layout_Order__c != 0.0){
                TableOfContents toc = new TableOfContents();
                
                toc.Id = formTemplate.Id;
                toc.label = (formTemplate.Label__c == null ? '' : formTemplate.Label__c);
                toc.status = formTemplate.Status__c;
                
                resultList.add(toc);
            }
        }
        String result = JSON.serialize(resultList);
        return result;
    }
    
    //Check if form type is 'Feasibility 1', add DemographicsPage to collect roles' information when return true;
    webservice static Boolean addDemographicsPage(ID SECFormOpptyFormId){
        return SECFormCommonUtils.addDemographicsPage(SECFormOpptyFormId);
    }
    
    //Fetch Trial Site Contact Role info by role
    static List<DemographicsContact> getRoleContactObjectByRole(String role, List<DemographicsContact> demoContactList){
        List<DemographicsContact> contactList = new List<DemographicsContact>();
        
        for(DemographicsContact demoContact : demoContactList){
            if(role.equals(demoContact.role)){
                contactList.add(demoContact);
            }
        }
        return contactList;
    }
    

    
    //Fetch Trial Site Contact Role info related to the Trial Site
    static List<DemographicsContact> getRoleContactObjectByForm(ID SECFormOpptyFormId){
        
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        List<DemographicsContact> contactList = new List<DemographicsContact>();
        
        for(Opportunity_Contact_Role__c ocr : [SELECT Id, Contact__c, Contact__r.Name, Street__c, State_Province__c, Zip_PostalCode__c,  Country__c, City__c, Fax__c, Phone__c, Email__c, Therapeutic_Area__c, Role__c, Email_address_for_Safety_Mailings__c 
                                               FROM Opportunity_Contact_Role__c 
                                               WHERE TrialSite__c =: trialSiteId]){
            DemographicsContact contact = new DemographicsContact();
            
            contact.trialSiteContactRoleId = ocr.Id;
            contact.Id = ocr.Contact__c;
            contact.name = ocr.Contact__r.Name;
            contact.mailingCountry = (ocr.Country__c == null ? '' : ocr.Country__c); 
            contact.mailingState = (ocr.State_Province__c == null ? '' : ocr.State_Province__c);
            contact.mailingCity = (ocr.City__c == null ? '' : ocr.City__c);
            contact.mailingStreet = (ocr.Street__c == null ? '' : ocr.Street__c);
            contact.mailingPostalCode = (ocr.Zip_PostalCode__c == null ? '' : ocr.Zip_PostalCode__c);
            contact.phone = (ocr.Phone__c == null ? '' :  ocr.Phone__c);
            contact.fax = (ocr.Fax__c == null ? '' : ocr.Fax__c);
            contact.email = (ocr.Email__c == null ? '' : ocr.Email__c);
            contact.additionalEmail = (ocr.Email_address_for_Safety_Mailings__c == null ? '' : ocr.Email_address_for_Safety_Mailings__c);
            contact.therapeuticArea = (ocr.Therapeutic_Area__c == null ? '' : ocr.Therapeutic_Area__c);
            contact.role = (ocr.Role__c == null ? '' : ocr.Role__c);
            
            contactList.add(contact);
        }
        return contactList;
    }
}