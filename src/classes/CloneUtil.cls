public without sharing class CloneUtil {
    
    //clone a SEC_Forms_Form__c and its children
    public static Id cloneForm (Id formId) {
        //soql all related fields
        SEC_Forms_Form__c oldForm = [select 
                                        Id, 
                                        Active__c, 
                                        Form_Type__c, 
                                        Instructions__c, 
                                        Name, 
                                        OwnerId, 
                                        Page_Footer__c, 
                                        Page_Header__c, 
                                        Purpose__c, 
                                        SEC_Forms_Country__c, 
                                        Trial_Form__c 
                                    from SEC_Forms_Form__c where Id = :formId];
        //deepclone
        SEC_Forms_Form__c newForm = oldForm.clone(false, true);
        newForm.Name = getNewName(oldForm.Name);
        //insert
        insert newForm;
        //clone children
        cloneFormTemplates(oldForm.Id, newForm.Id);
        
        return newForm.Id;
    }
    
    //clone a SEC_Forms_Template__c and its children
    public static Id cloneTemplate (Id templateId) {
        SEC_Forms_Template__c oldTemplate = [select 
                                                Id, 
                                                Name,
                                                Active__c,
                                                Label__c,
                                                OwnerId,
                                                SEC_Forms_Country__c,
                                                Section_Header_Pre_Text__c,
                                                Template_Layout_Order__c,
                                                Template_Type__c
                                            from SEC_Forms_Template__c where Id = :templateId];
        
        SEC_Forms_Template__c newTemplate = oldTemplate.clone(false, true);
        newTemplate.Name = getNewName(oldTemplate.Name);
        
        insert newTemplate;
        
        cloneTemplateQuestions(oldTemplate.Id, newTemplate.Id);
        
        return newTemplate.Id;
    }
    
    public static Id cloneQuestion(Id questionId) {
    	SEC_Forms_Question__c oldQuestion = [select 
    											Id, 
    											OwnerId, 
    											Name, 
    											Active__c, 
    											Data_Type__c, 
    											Pre_population__c, 
    											Question_Text__c, 
    											Sandbox_ID__c, 
    											QID__c,
    											Question_Type__c
    										from SEC_Forms_Question__c
    										where Id = :questionId];
    										
    	SEC_Forms_Question__c newQuestion = oldQuestion.clone(false, true);
    	newQuestion.Name = getNewName(oldQuestion.Name);
    	
    	insert newQuestion;
    	
    	cloneQuestionOptions(oldQuestion.Id, newQuestion.Id);
    	
    	return newQuestion.Id;
    	
    }
    
    private static void cloneQuestionOptions(Id oldQuestionId, Id newQuestionId) {
    	List<SEC_Forms_Question_Option__c> newOptions = new List<SEC_Forms_Question_Option__c>{};
    	
    	for(SEC_Forms_Question_Option__c option : [select Id, Name, Question__c, Option_Values__c, Question_Type__c, Sandbox_ID__c from SEC_Forms_Question_Option__c where Question__c = :oldQuestionId]) {
    		SEC_Forms_Question_Option__c newOption = option.clone(false, true);
    		newOption.Question__c = newQuestionId; 
    		newOptions.add(newOption);
    	}
    	
    	if (!newOptions.isEmpty()) {
    		insert newOptions;
    	}
    }
    
    private static void cloneFormTemplates (Id oldFormId, Id newFormId) {
        List<SEC_Forms_Form_Template__c> newFormTemplates = new List<SEC_Forms_Form_Template__c>{};
        
        for(SEC_Forms_Form_Template__c formTemplate : [select Id, Form__c, Template__c, Template_Layout_Order__c from SEC_Forms_Form_Template__c where Form__c = :oldFormId]) {
            
            System.debug('old Form__c: ' + formTemplate.Form__c);
            
            SEC_Forms_Form_Template__c newFormTemplate = formTemplate.clone(false, true);
            newFormTemplate.Form__c = newFormId;
            
            
            System.debug('new Form__c: ' + newFormTemplate.Form__c);
            
            newFormTemplates.add(newFormTemplate);
        }
        
        if (newFormTemplates.size() != 0) {
            insert newFormTemplates;
            
            System.debug('####final Form__c: ' + newFormTemplates[0].Form__c);
        }
    }
    
    private static void cloneTemplateQuestions(Id oldTemplateId, Id newTemplateId) {
        List<SEC_Forms_Template_Question__c> newTemplateQuestions = new List<SEC_Forms_Template_Question__c>{};
        Map<Id,Id> childParent = new Map<Id,Id>{}; //id => parent_question
        
        for (SEC_Forms_Template_Question__c templateQuestion : [select 
                                                                    Id,
                                                                    Name,
                                                                    Parent_Question__c, //<--need to find cloned parent
                                                                    Parent_Trigger_Behavior__c,
                                                                    Parent_Trigger_Values__c,
                                                                    Question_Layout_Order__c,
                                                                    Question_Text__c,
                                                                    Question_Type__c,
                                                                    Required__c,
                                                                    SEC_Forms_Question__c,
                                                                    Template_Country__c,
                                                                    Template_Name__c,
                                                                    Template_Type__c
                                                                from SEC_Forms_Template_Question__c where SEC_Forms_Template__c = :oldTemplateId]) {
                                                                    
            SEC_Forms_Template_Question__c newTemplateQuestion = templateQuestion.clone(false, true);
            newTemplateQuestion.SEC_Forms_Template__c = newTemplateId;
            newTemplateQuestion.Cloned_From__c = templateQuestion.Id;
            
            if (newTemplateQuestion.Parent_Question__c != null) {
                
                childParent.put(templateQuestion.Id, newTemplateQuestion.Parent_Question__c);
                newTemplateQuestion.Parent_Question__c = null; //temporarily set to null to get around filter rule
            }
            
            newTemplateQuestions.add(newTemplateQuestion);
        }
        
        if (newTemplateQuestions.size() > 0) {
            insert newTemplateQuestions;
            
            if (childParent.size() > 0) {
            //now loop through, if clonedfrom is in map, then
            //find the new template that has the parent id for cloned
            
                for(SEC_Forms_Template_Question__c tq : newTemplateQuestions) {
                    if (childParent.containsKey(tq.Cloned_From__c)) {
                        Id pId = childParent.get(tq.Cloned_From__c);
                        
                        for(SEC_Forms_Template_Question__c pq : newTemplateQuestions) {
                            if (pq.Cloned_From__c == pId) {
                                tq.Parent_Question__c = pq.Id;
                                break;
                            }
                        }
                    }
                }
            }
            
            update newTemplateQuestions;
        }
    }
    
    public static void cloneOpportunity(List<Opportunity> oldOpptys, List<Opportunity> newOpptys) {
        /* Removed per Denise Cunningham 1/25/2012
        List<Opportunity> opptysToClone = new List<Opportunity>{};
        List<Opportunity> clonedOpptys = new List<Opportunity>{};
        
        //get list of opportunites that need to be cloned
        for(Integer i = 0; i < newOpptys.size(); i++) {
            Opportunity newOppty = newOpptys.get(i);
            
            if (oldOpptys.get(i).StageName != 'PI Changed' && newOppty.StageName == 'PI Changed') {
                opptysToClone.add(newOppty);
            }
        }
        
        if (opptysToClone.size() > 0) {
            //clone the oppty
            for(Opportunity oppty : opptysToClone) {
                Opportunity clonedOppty = oppty.clone(false, true);
                clonedOppty.Parent_Opportunity__c = oppty.Id;
                clonedOppty.StageName = 'Evaluation';
                clonedOppty.Name = getNewName(oppty.Name);
                
                clonedOpptys.add(clonedOppty);
            }
            
            insert clonedOpptys;
            
            Map<Id,Id> contactMap = new Map<Id,Id>{}; //parent opptyId => cloned opptyId
            
            for (Opportunity oppty : clonedOpptys) {
                contactMap.put(oppty.Parent_Opportunity__c, oppty.Id);  
            }
            
            List<OpportunityContactRole> clonedContactRoles = new List<OpportunityContactRole>{};
            
            for(OpportunityContactRole ocr : [select Id, OpportunityId, ContactId, Role, IsPrimary from OpportunityContactRole where OpportunityId in :contactMap.keySet()]) {
                OpportunityContactRole clonedOcr = ocr.clone(false, true);
                clonedOcr.OpportunityId = contactMap.get(ocr.OpportunityId);
                
                clonedContactRoles.add(clonedOcr);
            }
            
            if (clonedContactRoles.size() > 0) {
                insert clonedContactRoles;
            }
        }
        */
    }
    
    private static String getNewName (String name) {
        return 'Copy of ' + name + ' for ' + UserInfo.getName();
    }
}