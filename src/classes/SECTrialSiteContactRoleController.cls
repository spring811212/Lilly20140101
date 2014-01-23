/**
 * SECTrialSiteContactRoleController
 * Controller class for manipulating the Opportunity_Contact_Role__c custom object
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang, Shon Gao)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */

public with sharing class SECTrialSiteContactRoleController {
    public List<contactRoleStruc> trialSiteContactRoles {get; set;}
    public String oppyName {get; set;}
    public Integer delIndex {get; set;}
    
    private Id trialSiteId;
    private Integer cIndex;
    private Id accountId;
    private Id ocrId;
    public SECTrialSiteContactRoleController(ApexPages.StandardController stdController){
        trialSiteContactRoles = new List<contactRoleStruc>();
        cIndex = -1; 
        Opportunity_Contact_Role__c ocr = (Opportunity_Contact_Role__c)stdController.getRecord();
        ocrId = ocr.Id;
        if(ocr.id != null) trialSiteId = [select id, TrialSite__c from Opportunity_Contact_Role__c where id = :ocr.id].TrialSite__c;
        else{
        	trialSiteId = ocr.TrialSite__c;
        }
        Opportunity trialSite = [select name, AccountId from Opportunity where id = :trialSiteId limit 1];
        oppyName = trialSite.Name;       
        accountId = trialSite.AccountId;
		retrieveContactRoles();
		system.debug('Contructor .... End');
    }
    
    //Merge Contact role and contacts together so that all the contacts under the same site will be displayed
    public void retrieveContactRoles(){
    	List<Opportunity_Contact_Role__c> currentTrialSiteContactRoles = SECTrialSiteContactRoleHelper.findAllTSCRforTrialSite(trialSiteId);
        for(Opportunity_Contact_Role__c ocr : currentTrialSiteContactRoles) {
        	ocr.ContactFake__c = ocr.Contact__c; 
        }
        
        List<Contact> trialSiteContacts = SECTrialSiteContactRoleHelper.findAllContactforSite(accountId);
        
    	trialSiteContactRoles = new List<contactRoleStruc>();
    	Integer existingOCRCount = currentTrialSiteContactRoles.size();
    	Integer OCRIndex = 0;
    	
    	for(Opportunity_Contact_Role__c ocr : currentTrialSiteContactRoles){
    		contactRoleStruc crs = new contactRoleStruc(ocr);
    		cIndex++;
    		crs.index = cIndex;
			trialSiteContactRoles.add(crs);
		}
    	
		for(Contact con: trialSiteContacts){
			OCRIndex = 0;
			
			if(currentTrialSiteContactRoles.isEmpty()){
				contactRoleStruc crs = new contactRoleStruc(creatOCRfromContact(con));
				cIndex++;
    			crs.index = cIndex;
				trialSiteContactRoles.add(crs);
			}
			
			for(Opportunity_Contact_Role__c ocr : currentTrialSiteContactRoles){
				OCRIndex++;
				if(ocr.Contact__c == con.Id){
					break;
				}
				//If this contact does not exist in the contact role, add to it
				if(OCRIndex == existingOCRCount){
					contactRoleStruc crs = new contactRoleStruc(creatOCRfromContact(con));
					cIndex++;
	    			crs.index = cIndex;
					trialSiteContactRoles.add(crs);
				}
			}
		}
    }
    
    //Copy the address info from contact and create the trial site contact role
    private Opportunity_Contact_Role__c creatOCRfromContact(Contact con){
    	return new Opportunity_Contact_Role__c(
						ContactFake__c = con.Id,
						Contact__c = con.Id,
						Role__c = '',
						TrialSite__c = trialSiteId,
						Street__c = con.MailingStreet,
						City__c = con.MailingCity,
						State_Province__c = con.MailingState,
						Zip_PostalCode__c = con.MailingPostalCode,
						Email__c = con.Email,
						Email_address_for_Safety_Mailings__c =con.Additional_email_address__c,
						Country__c = con.MailingCountry);
    }
    
    public void addTrialContactRoles(){
    	contactRoleStruc crs = new contactRoleStruc(new Opportunity_Contact_Role__c(TrialSite__c=trialSiteId ));
		cIndex++;
		crs.index = cIndex;
		trialSiteContactRoles.add(crs);
    }   
    
    //Save the trial site contact role into SFDC
    public PageReference saveTrialContactRoles(){
    	boolean noError = true;
    	list<Opportunity_Contact_Role__c> upsertPIlist = new List<Opportunity_Contact_Role__c> ();
    	try{
    	    if(!trialSiteContactRoles.isEmpty()) {    	    	
    	    	List<Opportunity_Contact_Role__c> validTrialSiteContactRoles = new List<Opportunity_Contact_Role__c>();
    	    	for(contactRoleStruc crs : trialSiteContactRoles){
    	    		if(crs.ocr.Role__c != null && crs.ocr.Role__c != ''){
    	    			crs.ocr.Contact__c = crs.ocr.ContactFake__c;
    	    			
    	    			if (crs.ocr.Role__c == 'Principal Investigator') {
    	    				upsertPIlist.add(crs.ocr);
    	    			} else {
							validTrialSiteContactRoles.add(crs.ocr);
    	    			}	
    	    		}
    	    		
    	    		/*if(crs.ocr.ContactFake__c == '' ||crs.ocr.ContactFake__c == null) {
    	    			noError = false;
    	    			ApexPages.Message noContactError = new ApexPages.Message(ApexPages.severity.ERROR, 'Related contact can\'t be empty!');
    	    			ApexPages.addMessage(noContactError);
    	    		}*/
				}
				
					upsert validTrialSiteContactRoles;
	    	    	upsert upsertPIlist;
	    	    	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved Successfully.'));
	    	    	//cIndex = -1;
	    	    	//retrieveContactRoles();
	    	
    	    }
    	}
    	catch(Exception ex){
    		ApexPages.addMessages(ex);
    		noError = false;
    	}
    	
    	
    	if (noError) {
    		return new pageReference('/'+trialSiteId);
    	} else {
    		return null;
    	}
        
    }
    
    public PageReference cancelTrialContactRoles(){
        PageReference pf = new PageReference('/' + trialSiteId);
        pf.setRedirect(true);
        return pf;
    }
    
    public PageReference gotoSelectContactAddress(){
        PageReference pf = new PageReference('/apex/SECTrialSiteSelectContact');
        //pf.setRedirect(true);
        return pf;
    }
    
    public void DeleteTrialContactRoles(){
    	Integer i = -1;
    	Boolean isFind = false;
        for(contactRoleStruc crs :trialSiteContactRoles){
        	i++;
        	if(delIndex == crs.index){
        		if(crs.ocr.id != null){
        			delete crs.ocr;      			
        		}
        		isFind = true;
        		break;
        	}
        }
        if(isFind) {
        	trialSiteContactRoles.remove(i);
        }
    }
    
    //*******************Select New Contact Role***********************
    public String searchCriteria{get;set;}
    public list<ContactAddress> contactAddrList{get;set;}
    
    //Search out all the contact addresses
    public void initContactAddress(){
    	contactAddrList = findContactAddr('');
    	warnToManyRows();
    }
    
    private void warnToManyRows(){
    	if(contactAddrList.size() == 1000){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, 'System returned more than 1000 contacts and their addresses. Please use criteria to filter');
    		ApexPages.addMessage(msg);
    	}
    }
    //Find all the contact and their addresses
    private list<contactAddress> findContactAddr(String nameCriteria){
    	map<String, contactAddress> tmpContactAddrMap = new map<String, contactAddress>();
    	ContactAddress ca;
    	
    	list<Contact> contactList = SECTrialSiteContactRoleHelper.findContactAddr(nameCriteria);
    	String Key;
    	
    	for(Contact con : contactList){
    		ca = new ContactAddress(con.Id);
    		ca.contactName = con.Name;
	    	ca.street = con.MailingStreet;
	    	ca.city = con.MailingCity;
	    	ca.state = con.MailingState;
	    	ca.zipCode = con.MailingPostalCode;
	    	ca.country = con.MailingCountry;
	    	
	    	ca.email = con.Email;
	    	ca.additionalEmail = con.Additional_email_address__c;
	    	
	    	if(!tmpContactAddrMap.containsKey(ca.key) && tmpContactAddrMap.size() < 1000){
	    		tmpContactAddrMap.put(ca.key, ca);
	    	}
    	}
    	
    	list<Opportunity_Contact_Role__c> ocrList = SECTrialSiteContactRoleHelper.findContactRoleAddr(nameCriteria);
    	for(Opportunity_Contact_Role__c ocr : ocrList){
    		ca = new ContactAddress(ocr.Contact__c);
    		ca.contactName = ocr.Contact__r.Name;
	    	ca.street = ocr.Street__c;
	    	ca.city = ocr.City__c;
	    	ca.state = ocr.State_Province__c;
	    	ca.zipCode = ocr.Zip_PostalCode__c;
	    	ca.country = ocr.Country__c;
	    	
	    	ca.email = ocr.Email__c;
	    	ca.additionalEmail = ocr.Email_address_for_Safety_Mailings__c;
	    	
	    	if(!tmpContactAddrMap.containsKey(ca.key) && tmpContactAddrMap.size() < 1000){
	    		tmpContactAddrMap.put(ca.key, ca);
	    	}
    	}

    	list<contactAddress> tmpContactAddrList = tmpContactAddrMap.values();
    	tmpContactAddrList.sort();
    	return tmpContactAddrList;
    }
    //Find all contact addresses with search criteria
    public void searchContactAddress(){
    	contactAddrList = findContactAddr(searchCriteria);
    	warnToManyRows();
    }
    //Add selected contact address into new contact role list
    public PageReference selectContactAddress(){
    	if(trialSiteContactRoles==null){
    		trialSiteContactRoles = new List<contactRoleStruc>();
    	}
    	
    	Integer cIndex = contactAddrList.size() - 1;
    	
    	system.debug('contactAddrList: ' + contactAddrList);
    	Boolean isSelected = false;
    	for(ContactAddress ca : contactAddrList){
    		if(ca.isSelect){
	    		contactRoleStruc crs = new contactRoleStruc(creatOCRfromContactAddr(ca));
				cIndex++;
				crs.index = cIndex;
				isSelected = true;
				trialSiteContactRoles.add(crs);
    		}
    	}
    	
    	if(!isSelected){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, 'Please select at least one contact');
    		ApexPages.addMessage(msg);
    		return null;
    	}
    	
    	return new PageReference('/apex/SECTrialSiteContactRoleNewEdit');
    }
    
    public PageReference cancelSelectContactAddress(){
    	return new PageReference('/apex/SECTrialSiteContactRoleNewEdit');
    }
    
    //Copy the address info from contact and create the trial site contact role
    private Opportunity_Contact_Role__c creatOCRfromContactAddr(ContactAddress ca){
    	return new Opportunity_Contact_Role__c(
						ContactFake__c = ca.contactId,
						Contact__c = ca.contactId,
						Role__c = '',
						TrialSite__c = trialSiteId,
						Street__c = ca.street,
						City__c = ca.city,
						State_Province__c = ca.state,
						Zip_PostalCode__c = ca.zipCode,
						Email__c = ca.Email,
						Email_address_for_Safety_Mailings__c =ca.additionalEmail,
						Country__c = ca.country);
    }
    
    public class ContactAddress implements Comparable {
    	public Boolean isSelect{get;set;}
    	public String contactId{get;set;}
    	public String contactName{get;set;}
    	public String street{get;set;}
    	public String city{get;set;}
    	public String state{get;set;}
    	public String zipCode{get;set;}
    	public String country{get;set;}
    	public String email{get;set;}
    	public String additionalEmail{get;set;}
    	public String key{
    		get{
    			return contactId + street + city + state + zipCode + country;
    		}
    	}
    	
    	public contactAddress(String conId){
    		contactId = conId;
			isSelect = false;
    	}
    	
    	public Integer compareTo(Object compareTo) {
		    if(compareTo == null){
		    	return 1;
		    }
		    
		    ContactAddress compareToObj = (ContactAddress) compareTo;
		    
		    if(this.contactName > compareToObj.contactName){
		    	return 1;
		    }
		    else if(this.contactName == compareToObj.contactName){
		    	return 0;
		    }
		    else{
		    	return -1;
		    }
		}
    }
    //*****************************************************************
    
    public class contactRoleStruc{
    	public Integer index {get;set;}
    	public Opportunity_Contact_Role__c ocr {get; set;}
    	
    	public contactRoleStruc(Opportunity_Contact_Role__c ocr){
    		this.ocr = ocr;
    		
    	}
    }
    
    
}