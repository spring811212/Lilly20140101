public with sharing class CreateFormController {

    //public String oid {get; private set;} //opportunity form id
    //public String mode {get;private set;}
    //public String acctId {get; private set;}
    public String tid {get;private set;} //trial form id
    public String opptyId {get;private set;} //opportunity id
    public String cmpgnId {get;private set;} //trial campaign id
    public String fnom {get;private set;}
    
    public SEC_Forms_Oppty_Form__c opptyForm {get;set;}
    public String errMsg {get;private set;}
    public Boolean hideForm {get;private set;}
    public Boolean restrictForm {get;private set;}
    public Boolean missingSource {get;private set;}
    
    private Id oid;

    public CreateFormController() {
        oid = null;
        opptyForm = new SEC_Forms_Oppty_Form__c();
        tid = Apexpages.currentPage().getParameters().get('tid');
        opptyId = Apexpages.currentPage().getParameters().get('opptyId');
        cmpgnId = ApexPages.currentPage().getParameters().get('cmpgnId');
        fnom = ApexPages.currentPage().getParameters().get('fnom');
        
        errMsg = '';
        hideForm = false;
        restrictForm = false;
        missingSource = false;
        
        if (opptyId != null && tid != null && cmpgnId != null) {
            if (formAlreadyInstantiated()) {
                errMsg = 'Form already instantiated.';
                restrictForm = true;
            }
        }
        else {
            errMsg = 'Required parameters missing or invalid.';
            hideForm = true;
        }
    }
    
    public PageReference goToForm() {
        oid = createForm();
        
        //PwC updates: Change from FLEX to web page
        PageReference pr = Page.SECFormStartPage;
            //PageReference pr = Page.Form_View;
            //Update opportunity form status to 'Created' by oid
            SEC_Forms_Oppty_Form__c opptyForm = new SEC_Forms_Oppty_Form__c(id=oid, Approval_Status__c='Created');
            update opptyForm;
        //PwC updates end
        
        
        
        pr.getParameters().putAll(new Map<String,String>{
            'oid' => oid,
            'tid' => tid,
            'opptyId' => opptyId,
            'fnom' => fnom,
            'newEval' => '1'
        });
        
        return pr;
    }
    
    public PageReference goToCopyAnswers() {
        if (opptyForm.Source_Form__c == null) {
            errMsg = 'You must choose a Source Form to copy answers.';
            missingSource = true;
            return null;
        }
        oid = createForm();
        
        PageReference pr = Page.CopyAnswers;
        pr.getParameters().putAll(new Map<String,String> {
            'targetId' => oid,
            'sourceId' => opptyForm.Source_Form__c,
            'tid' => tid,
            'opptyId' => opptyId,
            'fnom' => fnom
        });
        
        return pr;
    }
    
    private Id createForm() {
        if (oid == null) {
            FormUtils fu = new FormUtils(opptyId, tid, cmpgnId, fnom);
            oid = fu.instantiateForm();
        }
        
        return oid;
    }

    private Boolean formAlreadyInstantiated() {
        
        //check the form name that was passed in the url for an existing form of the same name
        //if it already exists, serve the existing one rather than instantiating a new one
        for(SEC_Forms_Oppty_Form__c opptyForm : [select Id, Form_Name__c from SEC_Forms_Oppty_Form__c where Trial_Campaign__c = :cmpgnId and Opportunity__c = :opptyId]) {
            if (opptyForm.Form_Name__c == fnom) {
                System.debug('####form exists');
                oid = opptyForm.Id;
                return true;
            }
        }
        
        System.debug('####form does not exist');
        return false;
    }
}