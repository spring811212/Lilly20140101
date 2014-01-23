public with sharing class FormViewController {

    public String oid {get; private set;} //opportunity form id
    public String mode {get;private set;}
    public String acctId {get; private set;}
    public String tid {get;private set;} //trial form id
    public String opptyId {get;private set;} //opportunity id
    public String cmpgnId {get;private set;} //trial campaign id
    public String sessionId {get;private set;}
    public Boolean showFlash {get;private set;}
    
    private String fnom; //form name

    public FormViewController() { 
        tid = Apexpages.currentPage().getParameters().get('tid');
        oid = Apexpages.currentPage().getParameters().get('oid');
        opptyId = Apexpages.currentPage().getParameters().get('opptyId');
        cmpgnId = ApexPages.currentPage().getParameters().get('cmpgnId');
        fnom = ApexPages.currentPage().getParameters().get('fnom');
        
        if (oid != null && oid != '') {
            setMode();
            
            if (mode != 'error') {
	            //override other vars
	            SEC_Forms_Oppty_Form__c opptyForm = [select Id, Opportunity__c, Opportunity__r.AccountId, Trial_Campaign__c from SEC_Forms_Oppty_Form__c where Id = :oid];
	            acctId = opptyForm.Opportunity__r.AccountId;
	            cmpgnId = opptyForm.Trial_Campaign__c;
	            opptyId = opptyForm.Opportunity__c;
            }
            
        }
        
        sessionId = UserInfo.getSessionId();
    }
    
    public PageReference init() {
        //return null;
        
        //if opptyid AND tid poped
        //double check created,
            //if IS, do nothing
        //if NOT>
            //instantiate form, then show as InProcess
        PageReference pr = null;    
            
        if (opptyId != null && tid != null && cmpgnId != null && oid == null) {
        	System.debug('####checking for form');
            if (!formAlreadyInstantiated()) {
                //instantiateForm();
                
                FormUtils fu = new FormUtils(opptyId, tid, cmpgnId, fnom);
                oid = fu.instantiateForm();
                //setMode();
                
                pr = Page.CopyAnswers;
                pr.getParameters().put('targetId', oid);
                //pr.setRedirect(true);
            }
        }
        
        return pr;
    }
    
    private Boolean formAlreadyInstantiated() {
        
        //check the form name that was passed in the url for an existing form of the same name
        //if it already exists, serve the eisting one rather than instantiating a new one
        
        
        
        //Set<String> existingFormNames = new Set<String>{};
        for(SEC_Forms_Oppty_Form__c opptyForm : [select Id, Form_Name__c from SEC_Forms_Oppty_Form__c where Trial_Campaign__c = :cmpgnId and Opportunity__c = :opptyId]) {
            if (opptyForm.Form_Name__c == fnom) {
                oid = opptyForm.Id;
                setMode();
                System.debug('####form exists');
                return true;
           
            }
        }
        
        System.debug('####form does not exist');
        return false;
    }
    
    private void setMode() {
        //oid
        
        //SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c
        
        if (oid != null) {
        	try {
            	SEC_Forms_Oppty_Form__c o = [select Opportunity__r.OwnerId, Opportunity__r.Form_Stage_Evaluator__c/*, SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c*/ from SEC_Forms_Oppty_Form__c where Id = :oid];
            	
            	Boolean owner = (UserInfo.getUserId() == o.Opportunity__r.OwnerId);
	            //Boolean locked = o.SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c;
	            Boolean stage = (o.Opportunity__r.Form_Stage_Evaluator__c == 1);
	            
	            //if (!owner || (owner && stage && locked)) {
	            //    mode = 'view';
	            //}
	            //else {
	            //    mode = 'edit';
	            //}
	            mode = 'view';
	            showFlash = true;
        	}
        	catch (System.Exception ex) {
        		mode = 'error';
        		showFlash = false;
        	}
            
        }
        else {
            mode = 'error';
            showFlash = false;
        }
        
        
    }
}