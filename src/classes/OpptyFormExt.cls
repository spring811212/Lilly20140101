public class OpptyFormExt {
	public SEC_Forms_Oppty_Form__c opptyForm{get;set;}
	public String message{get;set;}
	public OpptyFormExt(ApexPages.StandardController stdController) {
        this.opptyForm = (SEC_Forms_Oppty_Form__c)stdController.getRecord();
        
    }
    public PageReference cloneForm(){
    	Id opptyFormId = deepCloneOpptyForm();
    	return new PageReference('/' + opptyFormId);
    }
    private Id deepCloneOpptyForm(){
    	SEC_Forms_Oppty_Form__c newOpptyForm = cloneOpptyForm(this.opptyForm);
    	insert newOpptyForm;
    	if(newOpptyForm == null){
    		return null;
    	}
    	
    	List<SEC_Forms_Oppty_Form_Template__c> opptyTemplateList = [Select s.Template_Name__c, s.Template_Layout_Order__c, 
																		s.Section_Header_Pre_Text__c, s.SEC_Forms_Template__c, s.SEC_Forms_Oppty_Form__c, 
																		s.Name, s.Label__c, s.Form_Template__c, 
																		(Select Name, SEC_Forms_Oppty_Form_Template__c, Answer__c, Date_Answered__c, 
																			Parent_Question_Trigger_Behavior__c, Parent_Question_Trigger_Value__c, 
																			Parent_Question__c, Pre_population__c, Question_Layout_Order__c, Question_Options__c, 
																			Question_Text__c, Question_Type__c, Required__c, SEC_Forms_Oppty_Form__c, 
																			SEC_Forms_Template_Question__c, Is_Contact_Name__c, QID__c, Question_Type_2__c 
																		From SEC_Forms_Oppty_Forms_Question_Answers__r) 
																	From SEC_Forms_Oppty_Form_Template__c s
																	Where s.SEC_Forms_Oppty_Form__c = :this.opptyForm.Id];
		SEC_Forms_Oppty_Form_Template__c toAddOpptyTemplate;
		
		List<SEC_Forms_Oppty_Form_Template__c> newOpptyTemplateList = new List<SEC_Forms_Oppty_Form_Template__c>();
    	for(SEC_Forms_Oppty_Form_Template__c opptyTemplate:opptyTemplateList){
    		toAddOpptyTemplate = cloneOpptyFormTemplate(opptyTemplate, newOpptyForm.Id);
    		newOpptyTemplateList.add(toAddOpptyTemplate);
    	}    	
    	insert newOpptyTemplateList;
    	
    	SEC_Forms_Oppty_Forms_Question_Answer__c toAddOpptyQA;
    	List<SEC_Forms_Oppty_Forms_Question_Answer__c> newOpptyQAList = new List<SEC_Forms_Oppty_Forms_Question_Answer__c>();
    	for(SEC_Forms_Oppty_Form_Template__c newOpptyTemplate : newOpptyTemplateList){
    		for(SEC_Forms_Oppty_Forms_Question_Answer__c newOpptyQA:newOpptyTemplate.SEC_Forms_Oppty_Forms_Question_Answers__r){
    			toAddOpptyQA = cloneOpptyFormQA(newOpptyQA, newOpptyForm.Id, newOpptyTemplate.Id);
    			newOpptyQAList.add(toAddOpptyQA);
    		}
    	}
    	insert newOpptyQAList;    	
    	
    	return newOpptyForm.Id;
    }
    public static SEC_Forms_Oppty_Form__c cloneOpptyForm(SEC_Forms_Oppty_Form__c fromOpptyForm){
    	if(fromOpptyForm == null){
    		return null;
    	}
    	
    	fromOpptyForm = [Select s.Trial_Opportunity_Stage__c, s.Trial_Opportunity_Name_Text__c, 
    						s.Trial_Campaign__c, s.Trial_Campaign_Text_Name__c, 
    						s.Theraputic_Area__c, s.Source_Form__c, s.Site__c, s.SEC_Forms_Form__c, 
    						s.Purpose__c, s.Primary_Investigator__c, s.Page_Header__c, 
    						s.Page_Footer__c, s.Opportunity__c, s.Name, 
    						s.Label__c, s.Instructions__c, s.Form_Type__c, s.Form_Name__c, s.Country__c 
    						From SEC_Forms_Oppty_Form__c s Where s.Id=:fromOpptyForm.Id Limit 1];
    	
    	SEC_Forms_Oppty_Form__c newOpptyForm = fromOpptyForm.clone(false, true);
    	newOpptyForm.Label__c = 'Copy of ' + fromOpptyForm.Label__c;

    	return newOpptyForm;
    }
    
    public static  SEC_Forms_Oppty_Form_Template__c cloneOpptyFormTemplate(SEC_Forms_Oppty_Form_Template__c fromTemplate, Id opptyFormId){
    	SEC_Forms_Oppty_Form_Template__c newTemplate = fromTemplate.clone(false, true);
    	newTemplate.SEC_Forms_Oppty_Form__c = opptyFormId;
    	
    	return newTemplate;
    }
    
    public static SEC_Forms_Oppty_Forms_Question_Answer__c cloneOpptyFormQA(SEC_Forms_Oppty_Forms_Question_Answer__c fromQA, Id opptyFormId, Id opptyTemplateId){
    	SEC_Forms_Oppty_Forms_Question_Answer__c newQA = fromQA.clone(false, true);
    	newQA.SEC_Forms_Oppty_Form_Template__c = opptyTemplateId;
    	newQA.SEC_Forms_Oppty_Form__c = opptyFormId;
    	
    	return newQA;
    }
}