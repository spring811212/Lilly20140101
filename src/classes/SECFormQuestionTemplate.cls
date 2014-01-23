/**
 * SECFormQuestionTemplate
 * The class is used to store all the common methods and web services supporting business logic on page 'SECFormTemplate'
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */

global class SECFormQuestionTemplate{
    
    public class SECForm{
        public String formId {get;set;}
        public List<QuestionTemplate> templateList {get;set;}
        public String lillyRepresentative{get;set;}
        public String compound{get;set;}
        public String trialAlias{get;set;}
        public String siteName{get;set;}
        public String status{get;set;}
        public String instructions {get;set;}
        public String purpose {get;set;}
        public String pageFooter {get;set;}
        public String pageHeader {get;set;}
        public String trialSiteName {get;set;}
        public String label {get;set;}
        public List<Opportunity_Contact_Role__c> opptyContactRoleList {get;set;}
        public SECForm(String formId){
            this.formId = formId;
            templateList = new List<QuestionTemplate>();
        }
    }
  
    public class QuestionTemplate{
        public String templateId {get;set;}
        public List<QuestionGroup> groupList {get;set;}
        public String pageStatus {get;set;}
        public String sectionHeaderPreText {get;set;}
        public String label {get;set;}
        QuestionTemplate(String templateId, List<QuestionGroup> groupList){
            this.templateId = templateId;
            this.groupList = groupList;
        }
    }
    
    public class QuestionGroup{
        public String groupId {get;set;}
        public String groupName {get;set;}
        public List<Question> questionList {get;set;}
        QuestionGroup(){}
        QuestionGroup(String groupId, String groupName, List<Question> questionList){
            this.groupId = groupId;
            this.groupName = groupName;
            this.questionList = questionList;
        }
    }
    public class Question{
        public String questionId {get;set;}
        public String QID {get;set;}
        public String questionText {get;set;}
        public String questionType {get;set;}
        public Boolean questionRequired {get;set;}
        public String answer {get;set;}
        public String questionGroup {get;set;}
        public String questionLayoutOrder {get;set;}
        public List<QuestionOption> optionList {get;set;}
        Question(){}
        Question(String questionId, String QID, String questionText, String questionType, Boolean questionRequired, String questionGroup, String questionLayoutOrder, List<QuestionOption> optionList){
            this.questionId = questionId;
            this.QID = QID;
            this.questionText = questionText;
            this.questionType = questionType;
            this.questionRequired = questionRequired;
            this.questionGroup = questionGroup;
            this.questionLayoutOrder = questionLayoutOrder;
            this.optionList = optionList;
        }
    }
    
    public class QuestionOption{
        public String optionId {get;set;}
        public String optionText {get;set;}
        List<String> disableRule;
        QuestionOption(){}
        QuestionOption(String optionId, String optionText, List<ID> disableRule){
            this.optionId = optionId;
            this.optionText = optionText;
            this.disableRule = disableRule;
        }
    }
  
    public class TableOfContents{
        public String Id {get;set;}
        public String Label {get;set;}
        public String Status {get;set;} 
    }
    
    public class SECCompleteFormForPreview{
        public String completeFormId {get;set;}
        public List<SECForm> formList {get;set;}
        public SECCompleteFormForPreview(String completeFormId){
            this.completeFormId = completeFormId;
            formList = new List<SECForm>();
        }
      
    }
    
    //Get SEC Subform contents for PDF preview and print
    public static SECForm getSECForm(ID formId){
    string AllPageFooter;
     //sv: get the form header and footer of the SEC form
    for(SEC_Forms_Oppty_Form__c OpptyParentForm : [Select s.SEC_Forms_Form__r.Page_Header__c, s.SEC_Forms_Form__r.Page_Footer__c From SEC_Forms_Oppty_Form__c s where s.id=: formId LIMIT 1]){
    AllPageFooter = OpptyParentForm.SEC_Forms_Form__r.Page_Footer__c;
    system.debug('Formid' + formid);
    system.debug('PageFooter:' + AllPageFooter);}
             
        SECForm form = new SECForm(formId);
        
    
        for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT CreatedBy.Name, Trial_Campaign__r.Compound_Name__c, Trial_Campaign_Text_Name__c, Site__c, Opportunity__c, Page_Footer__c, Page_Header__c, Purpose__c, Instructions__c, Label__c, Trial_Opportunity_Name_Text__c, Form_Type__c, Approval_Status__c 
                                                 FROM SEC_Forms_Oppty_Form__c 
                                                 WHERE Id =: formId LIMIT 1]){
            form.lillyRepresentative = opptyForm.CreatedBy.Name;
            form.compound = opptyForm.Trial_Campaign__r.Compound_Name__c;
            form.trialAlias= opptyForm.Trial_Campaign_Text_Name__c;
            form.siteName = opptyForm.Site__c;
            form.instructions = opptyForm.Instructions__c;
            form.purpose = opptyForm.Purpose__c;
    //sv:12/9: if the oppty form header and footer are empty, populate them from the SEC parentform
                
            form.pagefooter =AllPageFooter;
            
            form.pageHeader = opptyForm.Page_Header__c;
            form.label = opptyForm.Label__c;
            form.status = opptyForm.Approval_Status__c;
            form.trialSiteName = opptyForm.Trial_Opportunity_Name_Text__c;
            
            //Get role info only for form type 'Feasibility 1'
            //sv:12/4/2013. change to accomodate demographics 
            //if(opptyForm.Form_Type__c == 'Feasibility 1'){ 
              if(opptyForm.Form_Type__c == 'Demographics'){ 
            
              form.opptyContactRoleList = [SELECT Contact__c, Contact__r.Name, Full_Name__c, Street__c, State_Province__c, Zip_PostalCode__c,  Country__c, City__c, Role__c, Email__c, Fax__c, Phone__c, Therapeutic_Area__c 
                                             FROM Opportunity_Contact_Role__c 
                                             WHERE TrialSite__c =: opptyForm.Opportunity__c];
            }
            
        }
    
        QuestionTemplate questionTemplate;
        
        for(SEC_Forms_Oppty_Form_Template__c formTemplate : [SELECT Label__c, Id, Template_Name__c, Template_Layout_Order__c 
                                                             FROM SEC_Forms_Oppty_Form_Template__c 
                                                             WHERE SEC_Forms_Oppty_Form__c =: formId]){
            //filter Trailforce automatically added contact role info page for SEC_CRU form
            if(formTemplate.Label__c != null && formTemplate.Template_Name__c != null && formTemplate.Template_Layout_Order__c != 0.0){
                questionTemplate = getTemplate(formTemplate.Id);
                form.templateList.add(questionTemplate);
          }
        }
        return form;
    }
    
    //Get complete SEC Form to preview and print
    public static SECCompleteFormForPreview getCompleteSECFormForPreview(ID trialId, ID trialSiteId){
        
        List<SEC_Forms_Oppty_Form__c> opptyFormList = [SELECT Id, Name, Form_Type__c, Approval_Status__c FROM SEC_Forms_Oppty_Form__c WHERE Opportunity__c =: trialSiteId AND Trial_Campaign__c =: trialId ORDER BY Name];

        SECCompleteFormForPreview completeForm = new SECCompleteFormForPreview(trialSiteId);
        
        for(SEC_Forms_Oppty_Form__c opptyForm : opptyFormList){
            SECForm form = new SECForm(opptyForm.Id);
            form = getSECForm(opptyForm.Id);
            
           if((opptyForm.Form_Type__c == 'Demographics' || opptyForm.Form_Type__c == 'Feasibility 1' || opptyForm.Form_Type__c == 'Feasibility 2' ||
              opptyForm.Form_Type__c == 'Feasibility 3'  || opptyForm.Form_Type__c == 'Site Evaluation') && opptyForm.Approval_Status__c == 'Approved'){
                completeForm.formList.add(form);
           }
        }
        
        return completeForm;
    }
    
    //Get Question Template contents 
    public static QuestionTemplate getTemplate(ID questionTemplateId){
        
        List<SEC_Forms_Oppty_Forms_Question_Answer__c> opptyFormsQestionAnswerList = new List<SEC_Forms_Oppty_Forms_Question_Answer__c>();
        
        for(SEC_Forms_Oppty_Forms_Question_Answer__c questionAnswer : [SELECT Id, SEC_Forms_Template_Question__c, QID__c, Answer__c, Question_Text__c, Question_Type__c, Required__c, Question_Layout_Order__c, Question_Options__c, Parent_Question_Trigger_Behavior__c, Parent_Question_Trigger_Value__c, Parent_Question__c  
                                                                       FROM SEC_Forms_Oppty_Forms_Question_Answer__c 
                                                                       WHERE SEC_Forms_Oppty_Form_Template__c =: questionTemplateId ORDER BY Question_Layout_Order__c]){
            opptyFormsQestionAnswerList.add(questionAnswer);                                                                                
        }
    
        Integer questionGroupSize = 0;
        Integer questionTotalNum = opptyFormsQestionAnswerList.size();
        String groupName = '';
        
        for(SEC_Forms_Oppty_Form_Template__c temp : [SELECT Label__c FROM SEC_Forms_Oppty_Form_Template__c WHERE Id =: questionTemplateId LIMIT 1]){
            groupName = temp.Label__c; //Question Group Title
        }
        
        List<List<Question>> questionGroupList = new List<List<Question>>();
        
        //get the number of question groups in one question template and add instances of question list
        for(SEC_Forms_Oppty_Forms_Question_Answer__c questionAnswer : opptyFormsQestionAnswerList){
            if(questionGroupSize == 0){
                List<Question> questionList = new List<Question>();
                questionGroupList.add(questionList);
                questionGroupSize++;
            }
        
            if(questionAnswer.Question_Type__c != 'Sub-Section Break')
                continue;
            
            List<Question> questionList = new List<Question>();
            questionGroupList.add(questionList);
            questionGroupSize++;
        }
    
        //Build disableRule for question option
        Set<String> parentQuestionSet = new Set<String>();  
        Map<String, String> parentChildMap = new Map<String, String>();      
        Set<String> triggerValueSet = new Set<String>();
    
        for(SEC_Forms_Oppty_Forms_Question_Answer__c questionAnswer : opptyFormsQestionAnswerList){
            if(questionAnswer.Parent_Question__c != null && questionAnswer.Parent_Question_Trigger_Behavior__c == 'Required' && questionAnswer.Parent_Question_Trigger_Value__c != null){
                parentQuestionSet.add(questionAnswer.Parent_Question__c);
                parentChildMap.put(questionAnswer.Parent_Question__c, questionAnswer.Id);
                List<String> triggerValueList = questionAnswer.Parent_Question_Trigger_Value__c.split(';');
                for(String value : triggerValueList){
                    triggerValueSet.add(value);
                }
            }
        }
    
        Integer optionNum = 1;
        Integer groupNum = 1;
        List<String> disableRule = new List<String>();
        List<QuestionGroup> qgroupList = new List<QuestionGroup>();
    
        //Fetch data for question template
        for(SEC_Forms_Oppty_Forms_Question_Answer__c questionAnswer : opptyFormsQestionAnswerList){
      
            //Question number flag
            questionTotalNum--;
      
            //Add disable rule to related question option, only support 'Picklist'
            if(questionAnswer.Question_Type__c == 'Picklist' && parentQuestionSet.contains(questionAnswer.Id)){
                if(parentChildMap.size()>0){
                    String childQuestion = parentChildMap.get(questionAnswer.Id);
                    disableRule.add(childQuestion);
                }
            }
      
            Question question = new Question();
            question.questionGroup = 'G' + String.ValueOf(groupNum);
            
            //'Sub-Section Break' is used for identifing question group
            if(questionAnswer.Question_Type__c != 'Sub-Section Break'){
                question.questionId = questionAnswer.Id;
                question.QID = questionAnswer.QID__c;
                question.questionText = questionAnswer.Question_Text__c;
                question.questionType = questionAnswer.Question_Type__c;
                question.questionRequired = questionAnswer.Required__c;
                
                if(questionAnswer.Answer__c != null){
                    question.answer = questionAnswer.Answer__c;
                }else{
                    question.answer = '';
                }
                
                question.questionLayoutOrder = String.ValueOf(questionAnswer.Question_Layout_Order__c.intValue());
                
                //Split question options string to generate option objects including disableRole for branching logic
                if(questionAnswer.Question_Options__c != null){
                    List<QuestionOption> questionOptionList = new List<QuestionOption>();
                    List<String> strList = questionAnswer.Question_Options__c.split(';');
                    
                    for(String str : strList){
                        QuestionOption questionOption = new QuestionOption();
                        questionOption.optionId = 'Op' + String.ValueOf(optionNum);
                        questionOption.optionText = str;
                            if(!triggerValueSet.contains(questionOption.optionText)){
                                questionOption.disableRule = disableRule; // Rule for branching logic
                            }
                    questionOptionList.add(questionOption);
                    optionNum++;
                    }
                    question.optionList = questionOptionList;
                }
        
                questionGroupList.get(groupNum-1).add(question);
                if(questionTotalNum == 0){
                    QuestionGroup questionGroup = new QuestionGroup(question.questionGroup, groupName, questionGroupList.get(groupNum-1));
                    qgroupList.add(questionGroup); //Add question group to question template
                }
            }else{
                QuestionGroup questionGroup = new QuestionGroup(question.questionGroup, groupName, questionGroupList.get(groupNum-1));
                qgroupList.add(questionGroup); //Add question group to question template
                groupName = questionAnswer.Question_Text__c;
                groupNum++;
            }
        }
        
        QuestionTemplate questionTemplate = new QuestionTemplate(questionTemplateId, qgroupList);
        
        for(SEC_Forms_Oppty_Form_Template__c temp : [SELECT Label__c FROM SEC_Forms_Oppty_Form_Template__c WHERE Id =: questionTemplateId LIMIT 1]){
            questionTemplate.label = temp.Label__c; //Question Group Title
        }
        
        return questionTemplate;
    }
    
    webservice static String getQuestionsOfTemplate(ID questionTemplateId){
        String result = JSON.serialize(getTemplate(questionTemplateId));
        return result;
    }
     
    //Get trial site Id by SEC Form Opportunity ID
    webservice static String getTrialSiteId(ID SECFormOpptyFormId){
        ID trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        
        Map<String,String> m=new Map<String,String>();
        m.put('trialSitedId',trialSiteId);
        String result = JSON.serialize(m);
        return result;
    }
    
    //Save answers to the form
    webservice static String saveAnswers(ID SECFormOpptyFormId, ID questionTemplateId, String questionAnswer){
    
        Boolean notAnswered = false;
    
        List<SEC_Forms_Oppty_Forms_Question_Answer__c> answerList = (List<SEC_Forms_Oppty_Forms_Question_Answer__c>)JSON.deserialize(questionAnswer, List<SEC_Forms_Oppty_Forms_Question_Answer__c>.class);
        for(SEC_Forms_Oppty_Forms_Question_Answer__c answer : answerList){
            if(answer.Required__c == true && (answer.Answer__c == null || answer.Answer__c == '' )){
                notAnswered = true;
            }
        }
    
        SEC_Forms_Oppty_Form_Template__c form = new SEC_Forms_Oppty_Form_Template__c();
        
        for(SEC_Forms_Oppty_Form_Template__c formTemp : [SELECT Id, Label__c, Status__c FROM SEC_Forms_Oppty_Form_Template__c WHERE Id =: questionTemplateId LIMIT 1]){
            form.Id = formTemp.Id;
        }
        
        //Get status for each question template
        if(notAnswered == false){
            form.Status__c = SECFormCommonUtils.PAGE_STATUS_COMPLETED;
        }else{
            form.Status__c = SECFormCommonUtils.PAGE_STATUS_DRAFTSAVED;
        }
        
        //Set SEC Form approval status to 'Draft Saved' once answers saved 
        List<SEC_Forms_Oppty_Form__c> formList = [SELECT Opportunity__c FROM SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId];
        
        if(formList.size() > 0){
            formList[0].Approval_Status__c= 'Draft Saved';
        }
        
        try{
            update form; //Save answers
            update formList; //Set SEC Form status to 'Draft Saved'
        }catch(DMLException e){
            system.debug(e.getDmlMessage(0));
        }
       
        Map<String,String> msg = new Map<String,String>();
        
        try{
            update answerList;
            msg.put('Msg','Save Successfully!');
            msg.put('Success','1');
            String result = JSON.serialize(msg);
            return result;
        }catch(DMLException e){
            msg.put('Msg','Save failed!');
            msg.put('Success','0');
            String result = JSON.serialize(msg);
            return result;
        }
    }
    
    //Submit form once all the required questions are answered, each time there is one and only form under approval process
    webservice static String submitForm(ID SECFormOpptyFormId){
            
        Boolean readyForSubmit = true;
        List<TableOfContents> formTemplateList = new List<TableOfContents>();
        
        Boolean demoPage = true;
        
        //Get current form's form type
        String currentFormType = 'unknown form type';
        String trialId = 'unknown trial';
        
        for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT Form_Type__c FROM SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId]){
            currentFormType = opptyForm.Form_Type__c;
        }
        
        //Check if any form has been submitted
        String trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        String stage = 'unknown stage';
        
        Map<String, String> msg = new Map<String, String>();
        
        for(Opportunity oppty : [SELECT StageName, CampaignId FROM Opportunity WHERE Id =: trialSiteId]){
            stage = oppty.StageName;
            trialId = oppty.CampaignId;
        }
        
        if(stage == 'SEC Subform Submitted' || stage == 'Site Loc Change Submitted' || stage =='PI Change Submitted' || stage == 'PIQ Submitted'){
            readyForSubmit = false;
            msg.put('Success', '2'); // Submit failed, already one form under approval process
            msg.put('Msg', 'Submit Failed!'); 
            String result = JSON.serialize(msg);
            return result;
        }
        
        //Check if all the feasibility form are approved before submitting 'Site Evaluation' form
        if(currentFormType == 'Site Evaluation'){
            
            List<SEC_Forms_Oppty_Form__c> trialOpptyFormList = new List<SEC_Forms_Oppty_Form__c>();
            
            
            List<SEC_Forms_Trial_Form__c> trialFormList = [SELECT Id, SEC_Forms_Form__c, Form_Type__c FROM SEC_Forms_Trial_Form__c WHERE Trial_Campaign__c =: trialId];
            List<SEC_Forms_Oppty_Form__c> trialSiteFormList = [SELECT Id, SEC_Forms_Form__c, Approval_Status__c, Form_Type__c FROM SEC_Forms_Oppty_Form__c WHERE Trial_Campaign__c =: trialId AND Opportunity__c =: trialSiteId];
            
            for(Integer i=0; i<trialFormList.size(); i++){
                
                Boolean formNotCreated = true;
                SEC_Forms_Oppty_Form__c opptyFormToAdd = new SEC_Forms_Oppty_Form__c();
                
                for(Integer j=0; j<trialSiteFormList.size(); j++){
                    if(trialFormList[i].SEC_Forms_Form__c == trialSiteFormList[j].SEC_Forms_Form__c){
                        opptyFormToAdd.Form_Type__c = trialSiteFormList[j].Form_Type__c;
                        opptyFormToAdd.Approval_Status__c = trialSiteFormList[j].Approval_Status__c;
                        trialOpptyFormList.add(opptyFormToAdd);
                        formNotCreated = false;
                        break;
                    }
                }
                
                if(formNotCreated == true){
                    opptyFormToAdd.Form_Type__c = trialFormList[i].Form_Type__c;
                    opptyFormToAdd.Approval_Status__c = 'Not Created';
                    trialOpptyFormList.add(opptyFormToAdd);
                }
            }
            
            for(SEC_Forms_Oppty_Form__c opptyForm : trialOpptyFormList){
                if(opptyForm.Form_Type__c.contains('Feasibility') && !opptyForm.Approval_Status__c.equals('Approved')){
                    readyForSubmit = false;
                    msg.put('Success', '3'); // Submit failed, all the SEC subforms must be approved before submitting 'Site Evaluation' form
                    msg.put('Msg', 'Submit Failed!'); 
                    String result = JSON.serialize(msg);
                    return result;
                }
            }
        }
        
        //Check if the site is Selected, only PI Change and Location Change forms can be submitted
        if(stage == 'Selected' || stage == 'PI Change Rejected' || stage == 'Site Loc Change Rejected' ){
            if (currentFormType != 'PI Change' && currentFormType != 'Location Change'){
                readyForSubmit = false;
                msg.put('Success', '4'); // Submit failed, if the site is Selected, only PI Change and Location Change forms can be submitted
                msg.put('Msg', 'Submit Failed!'); 
                String result = JSON.serialize(msg);
                return result;
            }
        }
        
        //Check each question template status, if not completed, set readyForSubmit to false
        for(SEC_Forms_Oppty_Form_Template__c formTemplate : [SELECT Label__c, Id, Status__c 
                                                             FROM SEC_Forms_Oppty_Form_Template__c 
                                                             WHERE SEC_Forms_Oppty_Form__c =: SECFormOpptyFormId]){
        
            TableOfContents templateStatus = new TableOfContents();
            if(demoPage == true && SECFormCommonUtils.addDemographicsPage(SECFormOpptyFormId)){
                templateStatus.Id = '1';
                templateStatus.Label = Label.SEC_Form_Demographics_Page_Name; // Configrable Custom Labels
                
                if(checkMandatoryContactRoles(SECFormOpptyFormId)){
                    templateStatus.Status = SECFormCommonUtils.PAGE_STATUS_COMPLETED;
                }else{
                    templateStatus.Status = SECFormCommonUtils.PAGE_STATUS_DRAFTSAVED;
                    readyForSubmit = false;
                }
            
                formTemplateList.add(templateStatus);
                demoPage = false;
            }else{
                if(formTemplate.Status__c != SECFormCommonUtils.PAGE_STATUS_COMPLETED ){
                    readyForSubmit = false;
                }
    
                templateStatus.Id = formTemplate.Id;
                templateStatus.Label = formTemplate.Label__c;
                templateStatus.Status = formTemplate.Status__c;
                formTemplateList.add(templateStatus);
            }
        }
        
        List<SEC_Forms_Oppty_Form__c> opptyFormList = new List<SEC_Forms_Oppty_Form__c>();
        
        //Set Trial Site stage       
        for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT Form_Type__c, Opportunity__r.Form_Submitted__c, Opportunity__r.StageName, Opportunity__c 
                                                 FROM SEC_Forms_Oppty_Form__c 
                                                 WHERE Id =: SECFormOpptyFormId LIMIT 1]){
            opptyForm.Opportunity__r.Form_Submitted__c = true;
            
            //Edit for multiple form, set state to 'SEC Subform Submitted' 
            //sv:12/4/2013 accomodate demographics
            if(opptyForm.Form_Type__c == 'Demographics' || opptyForm.Form_Type__c == 'Feasibility 1' || opptyForm.Form_Type__c == 'Feasibility 2' ||
               opptyForm.Form_Type__c == 'Feasibility 3' || opptyForm.Form_Type__c == 'Site Evaluation'){ 
                opptyForm.Opportunity__r.StageName = 'SEC Subform Submitted';
            }
            else if(opptyForm.Form_Type__c == 'Revision Requested'){
                opptyForm.Opportunity__r.StageName = 'Revision Request Completed';
            }
            else if(opptyForm.Form_Type__c == 'PI Change'){
                opptyForm.Opportunity__r.StageName = 'PI Change Submitted';
            }
            else if(opptyForm.Form_Type__c == 'PIQ'){
                opptyForm.Opportunity__r.StageName = 'PIQ Submitted';
            }
            else if(opptyForm.Form_Type__c == 'Location Change'){
                opptyForm.Opportunity__r.StageName = 'Site Loc Change Submitted';
            }
            else{}
            
            opptyForm.Opportunity__r.Form_Approval_Status__c = SECFormCommonUtils.TRIALSITEFORM_STATUS_PENDING;
            opptyForm.Opportunity__r.Form_Under_Approval__c = SECFormOpptyFormId;
            opptyForm.Submitted_Date__c = Datetime.now();
            
            opptyFormList.add(opptyForm);
        }
        
        if(readyForSubmit == true && SECFormCommonUtils.getSECFormViewMode(SECFormOpptyFormId) == 'Editable'){
            try{
                if(!opptyFormList.isEmpty()){
                    update opptyFormList;
                    update opptyFormList[0].Opportunity__r;
                }
            }catch(DMLException e){
                system.debug(e.getDmlMessage(0));
            }
            String tempList = JSON.serialize(formTemplateList);
            msg.put('Success', '1'); //Submit successfully
            msg.put('Msg', tempList); 
            String result = JSON.serialize(msg);
            return result;
         }else{
            String tempList = JSON.serialize(formTemplateList);
            msg.put('Success', '0');
            msg.put('Msg', tempList);
            String result = JSON.serialize(msg);
            return result;
         }
    }
  
    //Get lists for Table of Contects
    webservice static String getTableOfContents(ID SECFormOpptyFormId, ID questionTemplateId){
        
        List<TableOfContents> resultList = new List<TableOfContents>();
        if(SECFormCommonUtils.addDemographicsPage(SECFormOpptyFormId)){
            TableOfContents demoPage = new TableOfContents();
            demoPage.Id = String.valueOf(1);
            demoPage.Label = Label.SEC_Form_Demographics_Page_Name; //Custom Label to display
            if(checkMandatoryContactRoles(SECFormOpptyFormId)){
                demoPage.Status = SECFormCommonUtils.PAGE_STATUS_COMPLETED;
            }else{
                demoPage.Status = SECFormCommonUtils.PAGE_STATUS_DRAFTSAVED;
            }
            resultList.add(demoPage);
        }
        
        for(SEC_Forms_Oppty_Form_Template__c formTemplate : [SELECT Label__c, Id, Status__c, Template_Name__c, Template_Layout_Order__c 
                                                             FROM SEC_Forms_Oppty_Form_Template__c 
                                                             WHERE SEC_Forms_Oppty_Form__c =: SECFormOpptyFormId]){
            //Filter Trailforce automatically added contact role info page for SEC_CRU form
            if(formTemplate.Label__c != null  && formTemplate.Template_Name__c != null && formTemplate.Template_Layout_Order__c != 0.0){
                TableOfContents toc = new TableOfContents();
                toc.Id = formTemplate.Id;
                toc.Label = formTemplate.Label__c == null ? '' : formTemplate.Label__c;
                
                if(toc.Id == questionTemplateId){
                    toc.Status = SECFormCommonUtils.PAGE_CURRENT;
                }else{
                    toc.Status = formTemplate.Status__c;
                }
                resultList.add(toc);
            }
        }
        String result = JSON.serialize(resultList);
        return result;
    }
    
    //Check if all the mandatory contact role is assigned before submit
    public static Boolean checkMandatoryContactRoles(ID SECFormOpptyFormId){
        String trialSiteId = SECFormCommonUtils.getTrialSiteId(SECFormOpptyFormId);
        
        Set<String> mandatoryRoleSet = new Set<String>();
        Set<String> assignedRoleSet = new Set<String>();
        for(String role : SECFormCommonUtils.getMandatoryRoleList()){
            mandatoryRoleSet.add(role);
        }
        
        for(Opportunity_Contact_Role__c contactRole : [SELECT Id, Role__c FROM Opportunity_Contact_Role__c WHERE TrialSite__c =: trialSiteId]){
            assignedRoleSet.add(contactRole.Role__c);
        }
         
        if(assignedRoleSet.containsAll(mandatoryRoleSet)){
            return true;
        }else{
            return false;
        }
    }  
}