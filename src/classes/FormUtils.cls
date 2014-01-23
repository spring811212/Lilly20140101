public with sharing class FormUtils {

    Id opptyId;
    Id tid; 
    Id cmpgnId;
    Id fid;
    DateTime now;

    public FormUtils(Id opptyId, Id tid, Id cmpgnId, Id fid) {
        this.opptyId = opptyId;
        this.cmpgnId = cmpgnId;
        this.tid = tid;
        this.fid = fid;
        
        now = DateTime.now();
    }
    
    public Id instantiateForm() {
        
        Id retId = null;
        //DateTime now = DateTime.now(); 
        
        if (opptyId != null && tid != null && cmpgnId != null) {
            //if i could do it all over again...

            Campaign cmpgn = [select Id, Therapeutic_Area__c from Campaign where Id = :cmpgnId limit 1];
            //sv list of template questions
            List<SEC_Forms_Template_Question__c> templateQuestions = new List<SEC_Forms_Template_Question__c>{};
            
            String primaryInvestigator = '';
            String acctName = '';
            
            //PwC Update: Replace OpportunityContactRole with Opportunity_Contact_Role__c
            //sv get the pr inv name
            try {
                primaryInvestigator = [select Contact__r.Name from Opportunity_Contact_Role__c where TrialSite__c = :opptyId limit 1].Contact__r.Name;
            }
            catch (System.QueryException qe) {}
            catch (System.NullPointerException ne) {}
            //PwC Update End
            
            //try {
            //  acctName = [select Account.Name from Opportunity where Id = :opptyId limit 1].Account.Name;
            //}
            //catch (System.QueryException qe) {}
            //sv get opportunity details
            Opportunity oppty = [select Id, Owner.Name, Account.Name, Campaign.Compound_Name__c, Campaign.Name from Opportunity where Id = :opptyId];
            
            
            SEC_Forms_Trial_Form__c trialForm = new SEC_Forms_Trial_Form__c();
            try {
                System.debug('#####cmpgnId:' + cmpgnId);
                System.debug('#####fId:' + fid);
                //using the fnom and campaign id, get the trial form and sec form associated
                trialForm = [select Id, SEC_Forms_Form__c, SEC_Forms_Form__r.SEC_Forms_Country__r.Name, SEC_Forms_Form__r.Label__c, SEC_Forms_Form__r.Purpose__c, SEC_Forms_Form__r.Page_Footer__c, SEC_Forms_Form__r.Page_Header__c, SEC_Forms_Form__r.Instructions__c, SEC_Forms_Form__r.Form_Type__c, SEC_Forms_Form__r.Name from SEC_Forms_Trial_Form__c where Trial_Campaign__c = :cmpgnId and SEC_Forms_Form__c = :fid limit 1];
            }
            catch (System.QueryException ex) { return null; }
            
            System.Savepoint sp = Database.setSavepoint();
            
            try {
            
                SEC_Forms_Oppty_Form__c opptyForm = new SEC_Forms_Oppty_Form__c(
                    Opportunity__c = opptyId,
                    Country__c = trialForm.SEC_Forms_Form__r.SEC_Forms_Country__r.Name, //second call below
                    Site__c = oppty.Account.Name, //cmpgn.Account.Name
                    Theraputic_Area__c = cmpgn.Therapeutic_Area__c,
                    Trial_Campaign__c = cmpgn.Id,
                    SEC_Forms_Form__c = fid,
                    Primary_Investigator__c = primaryInvestigator,
                    Form_Type__c = trialForm.SEC_Forms_Form__r.Form_Type__c,
                    Form_Name__c = trialForm.SEC_Forms_Form__r.Name,
                    Instructions__c = trialForm.SEC_Forms_Form__r.Instructions__c,
                    Page_Footer__c = trialForm.SEC_Forms_Form__r.Page_Footer__c,
                    Page_Header__c = trialForm.SEC_Forms_Form__r.Page_Header__c,
                    Purpose__c = trialForm.SEC_Forms_Form__r.Purpose__c,
                    Label__c = trialForm.SEC_Forms_Form__r.Label__c
                );
                
                List<SEC_Forms_Oppty_Form_Template__c> opptyFormTemplates = new List<SEC_Forms_Oppty_Form_Template__c>{}; 
                List<SEC_Forms_Oppty_Forms_Question_Answer__c> opptyFormQAs = new List<SEC_Forms_Oppty_Forms_Question_Answer__c>{};
                
                insert opptyForm;
                
                
                //System.debug('#####opptyForm: ' + opptyForm);
                
                retId = opptyForm.Id;
                /*
                try {
                    opptyForm.Country__c = [select SEC_Forms_Country__r.Name from SEC_Forms_Form__c where Id = :trialForm.SEC_Forms_Form__c].SEC_Forms_Country__r.Name;
                    //opptyForm.Country__c = [select Name from Country__c where Id = :cntryId limit 1].Name;
                    System.debug('##cntry:' + opptyForm.Country__c);
                    
                }
                catch(System.QueryException qe) {
                    System.debug('@@cntry lookup failed');
                }
                finally {
                    update opptyForm;
                }
                */
                //oppty contact roles
                //add all oppty contact roles as fisrt oppty_form_template/oppty_qa[]
                /*if (trialForm.SEC_Forms_Form__r.Form_Type__c == 'Feasibility 1') { //Edit 'SEC_CRU' to 'Feasibility 1' for Multiple form
                    opptyFormTemplates.add(new SEC_Forms_Oppty_Form_Template__c(
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Template_Layout_Order__c = 0
                    ));*/
                    //SV dec4 2013. to accomodate demographics form
                     if (trialForm.SEC_Forms_Form__r.Form_Type__c == 'Demographics') { //Edit 'SEC_CRU' to 'Demographics' for Multiple form
                    opptyFormTemplates.add(new SEC_Forms_Oppty_Form_Template__c(
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Template_Layout_Order__c = 0
                    ));  
                    
                }
                                
                //now get all the templates assoc, just a list, we know the id
                //List<SEC_Forms_Form_Template__c> formTemplates = [select Id, Template__c from SEC_Forms_Form_Template__c where Form__c = :trialForm.SEC_Forms_Form__c];
                Set<Id> templateIds = new Set<Id>{};
                Map<Id,Id> templateMap = new Map<Id,Id>{};
                
                for(SEC_Forms_Form_Template__c formTemplate : [select Id, Name, Form__c, Template__c, Form_Name__c, Template_Name__c, Form_Type__c, Template_Type__c, Template_Layout_Order__c from SEC_Forms_Form_Template__c where Form__c = :trialForm.SEC_Forms_Form__c]) {
                    SEC_Forms_Oppty_Form_Template__c opptyFormTemplate = new SEC_Forms_Oppty_Form_Template__c(
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        //Section_Header_Pre_Text__c = template.Section_Header_Pre_Text__c,
                        Template_Layout_Order__c = formTemplate.Template_Layout_Order__c,
                        Form_Template__c = formTemplate.Id,
                        Template_Name__c = formTemplate.Name
                    );
                    
                    templateMap.put(formTemplate.Template__c, formTemplate.Id);
                    
                    opptyFormTemplates.add(opptyFormTemplate);
                    templateIds.add(formTemplate.Template__c);
                }
                
                insert opptyFormTemplates;
                
                //change by SV to accomodate demographics form -Dec4 2013
                /*if (trialForm.SEC_Forms_Form__r.Form_Type__c == 'Feasibility 1') { //Edit 'SEC_CRU' to 'Feasibility 1' for Multiple form */
                if (trialForm.SEC_Forms_Form__r.Form_Type__c == 'Demographics') { //Edit 'SEC_CRU' to 'Demographics' for Multiple form
              
                
                
                
                    Id contactTemplate = opptyFormTemplates[0].Id;
                    Integer c = 0;
                    
                    //roles
                    List<String> roles = new List<String> {
                        'Principal Investigator',
                        'Sub-Investigator',
                        'Primary Study Coordinator',
                        'Regulatory',
                        'Pharmacist',
                        'Budgets',
                        'Contracts',
                        'Other Key Staff',
                        'Ship Lab Supplies to',
                        'Ship CRFs to',
                        'Ship investigational product (IP) to',
                        'Send Contract (LOA) to'
                    };
                    
                    opptyFormQAs.add(newContactRole('Study Specific', 'Lilly Rep', oppty.Owner.Name, contactTemplate, c, opptyForm.Id));
                    /*opptyFormQAs.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                        Question_Type__c = 'Short Text',
                        Question_Text__c = 'Lilly Rep',
                        Answer__c = oppty.Owner.Name,
                        SEC_Forms_Oppty_Form_Template__c = contactTemplate,
                        Question_Layout_Order__c = c,
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Date_Answered__c = now
                    ));*/
                    c++;
                    
                    opptyFormQAs.add(newContactRole('Study Specific', 'Compound', oppty.Campaign.Compound_Name__c, contactTemplate, c, opptyForm.Id));
                    /*opptyFormQAs.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                        Question_Type__c = 'Short Text',
                        Question_Text__c = 'Compound',
                        Answer__c = oppty.Campaign.Compound_Name__c,
                        SEC_Forms_Oppty_Form_Template__c = contactTemplate,
                        Question_Layout_Order__c = c,
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Date_Answered__c = now
                    ));*/
                    c++;
                    
                    opptyFormQAs.add(newContactRole('Study Specific', 'Trial Alias', oppty.Campaign.Name, contactTemplate, c, opptyForm.Id));
                    /*opptyFormQAs.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                        Question_Type__c = 'Short Text',
                        Question_Text__c = 'Trial Alias',
                        Answer__c = oppty.Campaign.Name,
                        SEC_Forms_Oppty_Form_Template__c = contactTemplate,
                        Question_Layout_Order__c = c,
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Date_Answered__c = now
                    ));*/
                    c++;
                    
                    opptyFormQAs.add(newContactRole('Study Specific', 'Site Name', oppty.Account.Name, contactTemplate, c, opptyForm.Id));
                    /*opptyFormQAs.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                        Question_Type__c = 'Short Text',
                        Question_Text__c = 'Site Name',
                        Answer__c = oppty.Account.Name,
                        SEC_Forms_Oppty_Form_Template__c = contactTemplate,
                        Question_Layout_Order__c = c,
                        SEC_Forms_Oppty_Form__c = opptyForm.Id,
                        Date_Answered__c = now
                    ));*/
                    c++;
                    /*SV: change the address fields 
                    for(OpportunityContactRole ocr : [select Id, Contact.Name, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, Contact.Phone, Contact.MobilePhone, Contact.Fax, Contact.Email, Role from OpportunityContactRole where OpportunityId = :opptyId]) 
                                        {
                        
                        String cName = (ocr.Contact.Name == null) ? '' : ocr.Contact.Name;
                        String cStreet = (ocr.Contact.MailingStreet == null) ? '' : ocr.Contact.MailingStreet;
                        String cCity = (ocr.Contact.MailingCity == null) ? '' : ocr.Contact.MailingCity;
                        String cState = (ocr.Contact.MailingState == null) ? '' : ocr.Contact.MailingState;
                        String cZip = (ocr.Contact.MailingPostalCode == null) ? '' : ocr.Contact.MailingPostalCode;
                        String cCntry = (ocr.Contact.MailingCountry == null) ? '' : ocr.Contact.MailingCountry;
                        String cPhone = (ocr.Contact.Phone == null) ? '' : ocr.Contact.Phone;
                        String cMobile = (ocr.Contact.MobilePhone == null) ? '' : ocr.Contact.MobilePhone;
                        String cFax = (ocr.Contact.Fax == null) ? '' : ocr.Contact.Fax;
                        String cEmail = (ocr.Contact.Email == null) ? '' : ocr.Contact.Email;*/
                    
                    //PwC Update: Replace OpportunityContactRole with Opportunity_Contact_Role__c                    
                    /*
                        for(OpportunityContactRole ocr : [select Id, Contact.Name, Contact.Mailing_Street__c, 
                    Contact.Mailing_City__c, contact.Additional_email_address__c,
                    Contact.Mailing_State_Province__c, Contact.Mailing_Zip_PostalCode__c, 
                    Contact.Mailing_Country__c, Contact.Phone, Contact.MobilePhone, Contact.Fax, Contact.Email, Role 
                    from OpportunityContactRole where OpportunityId = :opptyId]) {  
                        String cName = (ocr.Contact.Name == null) ? '' : ocr.Contact.Name;
                        String cStreet = (ocr.Contact.Mailing_Street__c == null) ? '' : ocr.Contact.Mailing_Street__c;
                        String cCity = (ocr.Contact.Mailing_City__c == null) ? '' : ocr.Contact.Mailing_City__c;
                        String cState = (ocr.Contact.Mailing_State_Province__c == null) ? '' : ocr.Contact.Mailing_State_Province__c;
                        String cZip = (ocr.Contact.Mailing_Zip_PostalCode__c == null) ? '' : ocr.Contact.Mailing_Zip_PostalCode__c;
                        String cCntry = (ocr.Contact.Mailing_Country__c == null) ? '' : ocr.Contact.Mailing_Country__c;
                        String cPhone = (ocr.Contact.Phone == null) ? '' : ocr.Contact.Phone;
                        String cMobile = (ocr.Contact.MobilePhone == null) ? '' : ocr.Contact.MobilePhone;
                        String cFax = (ocr.Contact.Fax == null) ? '' : ocr.Contact.Fax;
                        String cEmail = (ocr.Contact.Email == null) ? '' : ocr.Contact.Email;
                        string SafrnsEmail =(ocr.contact.additional_email_address__c == null) ? '':ocr.contact.additional_email_address__c;
                        
                        //Name
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Name', cName, contactTemplate, c, opptyForm.Id, true));
                        c++;
                        //Address
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Address', cStreet, contactTemplate, c, opptyForm.Id));
                        c++;
                        //City
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - City', cCity, contactTemplate, c, opptyForm.Id));
                        c++;
                        //State
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - State', cState, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Zip
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Zip', cZip, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Country
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Country', cCntry, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Phone
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Phone', cPhone, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Mobile
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Mobile', cMobile, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Fax
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Fax', cFax, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Email
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role + ' - Email', cEmail, contactTemplate, c, opptyForm.Id));
                        c++;
                        
                        System.debug('###adde role:' + ocr.Role);
                        
                        Integer x = -1;
                        for(Integer i = 0; i < roles.size(); i++) {
                            if (roles[i] == ocr.Role) {
                                x = i;
                                break;
                            }
                        }
                        if (x != -1) {
                            roles.remove(x);
                        }
                        
                    }
                    */
                    
                        for(Opportunity_Contact_Role__c ocr : [select Id, Contact__r.Name, Contact__r.Mailing_Street__c, 
                    Contact__r.Mailing_City__c, contact__r.Additional_email_address__c,
                    Contact__r.Mailing_State_Province__c, Contact__r.Mailing_Zip_PostalCode__c, 
                    Contact__r.Mailing_Country__c, Contact__r.Phone, Contact__r.MobilePhone, Contact__r.Fax, Contact__r.Email, Role__c 
                    from Opportunity_Contact_Role__c where TrialSite__c = :opptyId]) {  
                        String cName = (ocr.Contact__r.Name == null) ? '' : ocr.Contact__r.Name;
                        String cStreet = (ocr.Contact__r.Mailing_Street__c == null) ? '' : ocr.Contact__r.Mailing_Street__c;
                        String cCity = (ocr.Contact__r.Mailing_City__c == null) ? '' : ocr.Contact__r.Mailing_City__c;
                        String cState = (ocr.Contact__r.Mailing_State_Province__c == null) ? '' : ocr.Contact__r.Mailing_State_Province__c;
                        String cZip = (ocr.Contact__r.Mailing_Zip_PostalCode__c == null) ? '' : ocr.Contact__r.Mailing_Zip_PostalCode__c;
                        String cCntry = (ocr.Contact__r.Mailing_Country__c == null) ? '' : ocr.Contact__r.Mailing_Country__c;
                        String cPhone = (ocr.Contact__r.Phone == null) ? '' : ocr.Contact__r.Phone;
                        String cMobile = (ocr.Contact__r.MobilePhone == null) ? '' : ocr.Contact__r.MobilePhone;
                        String cFax = (ocr.Contact__r.Fax == null) ? '' : ocr.Contact__r.Fax;
                        String cEmail = (ocr.Contact__r.Email == null) ? '' : ocr.Contact__r.Email;
                        string SafrnsEmail =(ocr.Contact__r.additional_email_address__c == null) ? '':ocr.Contact__r.additional_email_address__c;

                        //Name
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Name', cName, contactTemplate, c, opptyForm.Id, true));
                        c++;
                        //Address
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Address', cStreet, contactTemplate, c, opptyForm.Id));
                        c++;
                        //City
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - City', cCity, contactTemplate, c, opptyForm.Id));
                        c++;
                        //State
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - State', cState, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Zip
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Zip', cZip, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Country
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Country', cCntry, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Phone
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Phone', cPhone, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Mobile
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Mobile', cMobile, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Fax
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Fax', cFax, contactTemplate, c, opptyForm.Id));
                        c++;
                        //Email
                        opptyFormQAs.add(newContactRole('Contact', ocr.Role__c + ' - Email', cEmail, contactTemplate, c, opptyForm.Id));
                        c++;
                        
                        System.debug('###adde role:' + ocr.Role__c);
                        
                        Integer x = -1;
                        for(Integer i = 0; i < roles.size(); i++) {
                            if (roles[i] == ocr.Role__c) {
                                x = i;
                                break;
                            }
                        }
                        if (x != -1) {
                            roles.remove(x);
                        }
                        
                    }
                    //PwC Update End

                    if (roles.size() > 0) {
                        for(String role : roles) {
                            /*
                            opptyFormQAs.add(new SEC_Forms_Oppty_Forms_Question_Answer__c(
                                Question_Type__c = 'Comments',
                                Question_Text__c = role,
                                Answer__c = '',
                                SEC_Forms_Oppty_Form_Template__c = contactTemplate,
                                Question_Layout_Order__c = c,
                                SEC_Forms_Oppty_Form__c = opptyForm.Id,
                                Date_Answered__c = now
                            ));
                            c++;
                            */
                            //Name
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Name', '', contactTemplate, c, opptyForm.Id, true));
                            c++;
                            //Address
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Address', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //City
                            opptyFormQAs.add(newContactRole('Contact', role + ' - City', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //State
                            opptyFormQAs.add(newContactRole('Contact', role + ' - State', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Zip
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Zip', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Country
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Country', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Phone
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Phone', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Mobile
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Mobile', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Fax
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Fax', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //Email
                            opptyFormQAs.add(newContactRole('Contact', role + ' - Email', '', contactTemplate, c, opptyForm.Id));
                            c++;
                            //safrns email
                            if (role == 'Principal Investigator' ){
                                opptyformQAs.add(newcontactrole('Contact', role + ' - SAFR NS Email', '', contactTemplate,c,opptyform.id));
                            }
                            
                            System.debug('###added role:' + role);
                        }
                    }
                    
                }
                
                Map<Id,Id> formTemplateToOpptyTemplate = new Map<Id,Id>{};
                for (SEC_Forms_Oppty_Form_Template__c oft : opptyFormTemplates) {
                    formTemplateToOpptyTemplate.put(oft.Form_Template__c, oft.Id);
                }
                                
                //halfway there
                
                
                for(SEC_Forms_Template__c template : [select Id, Label__c, Section_Header_Pre_Text__c from SEC_Forms_Template__c where Id in :templateIds and Active__c = true]) {
                    //SEC_Forms_Oppty_Form_Template__c opptyFormTemplate = new SEC_Forms_Oppty_Form_Template__c(
                    //  SEC_Forms_Oppty_Form__c = opptyForm.Id,
                    //  Section_Header_Pre_Text__c = template.Section_Header_Pre_Text__c,
                    //  Template_Layout_Order__c = template.Template_Layout_Order__c,
                    //  SEC_Forms_Template__c = template.Id,
                    //  Template_Name__c = template.Name
                    //);
                    for(SEC_Forms_Oppty_Form_Template__c oft : opptyFormTemplates) {
                        if (oft.Form_Template__c == templateMap.get(template.Id)) {
                            oft.Section_Header_Pre_Text__c = template.Section_Header_Pre_Text__c;
                            oft.Label__c = template.Label__c;
                            oft.SEC_Forms_Template__c = template.Id;
                            System.debug('oft:' + oft);
                        }
                    }
                    
                    
                    
                    //opptyFormTemplates.add(opptyFormTemplate);
                }
                
                update opptyFormTemplates;
                
                Map<Id,Id> templateToFormTemplate = new Map<Id,Id>{};
                for(SEC_Forms_Oppty_Form_Template__c formTemplate : opptyFormTemplates) {
                    templateToFormTemplate.put(formTemplate.SEC_Forms_Template__c, formTemplate.Id);
                }
                
                //Map<Id, SEC_Forms_Question_Option__c> questionOptions = new Map<Id, SEC_Forms_Question_Option__c>{};
                Map<Id,Id> questionsWithParents = new Map<Id,Id>{};
                
                
                Map<Id, List<SEC_Forms_Question_Option__c>> questionOptions = new Map<Id, List<SEC_Forms_Question_Option__c>>{};
                for(SEC_Forms_Template_Question__c templateQuestion : [select Id, Question_Layout_Order__c, Parent_Question__c, Required__c, Question_Type__c, SEC_Forms_Question__r.Question_Text__c, SEC_Forms_Question__r.Pre_population__c, SEC_Forms_Question__r.Active__c, SEC_Forms_Question__r.QID__c, SEC_Forms_Question__r.Question_Type__c, Parent_Trigger_Behavior__c, Parent_Trigger_Values__c, SEC_Forms_Question__c, SEC_Forms_Template__c from SEC_Forms_Template_Question__c where SEC_Forms_Template__c in :templateIds]) {
                    templateQuestions.add(templateQuestion);
                    questionOptions.put(templateQuestion.SEC_Forms_Question__c, new List<SEC_Forms_Question_Option__c> {});
                }
                
                for(SEC_Forms_Question_Option__c questionOption : [select Id, Option_Values__c, Question__c from SEC_Forms_Question_Option__c where Question__c in :questionOptions.keySet()]) {
                    //questionOptions.put(questionOption.Question__c, questionOption);
                    //System.debug('#####q option: ' + questionOption.Option_Values__c);
                    //System.debug('#####qid: ' + questionOption.Id);
                    
                    if (questionOptions.containsKey(questionOption.Question__c)) {
                        questionOptions.get(questionOption.Question__c).add(questionOption);
                    }
                    else {
                        questionOptions.put(questionOption.Question__c, new List<SEC_Forms_Question_Option__c> { questionOption });
                    }
                }
                
                for(SEC_Forms_Template_Question__c templateQuestion : templateQuestions) {
                    if (templateQuestion.SEC_Forms_Question__r.Active__c) {
                        SEC_Forms_Oppty_Forms_Question_Answer__c opptyQA = new SEC_Forms_Oppty_Forms_Question_Answer__c();
                        
                        opptyQA.Parent_Question_Trigger_Behavior__c = templateQuestion.Parent_Trigger_Behavior__c; //template_question
                        opptyQA.Parent_Question_Trigger_Value__c = templateQuestion.Parent_Trigger_Values__c; //template_question
                        
                        if (questionOptions.containsKey(templateQuestion.SEC_Forms_Question__c)) {
                            List<SEC_Forms_Question_Option__c> qos = questionOptions.get(templateQuestion.SEC_Forms_Question__c);
                            String options = '';
                            for(SEC_Forms_Question_Option__c questionOption : qos) {
                                options += questionOption.Option_Values__c + ';';
                            }
                            if (options.length() != 0) {
                                options = options.substring(0, options.length() - 1);
                            }
                            System.debug('#####options: ' + options);
                            opptyQA.Question_Options__c = options; //question_options.option_values
                        }
                        
                        opptyQA.Question_Layout_Order__c = templateQuestion.Question_Layout_Order__c;
                        opptyQA.Question_Text__c = templateQuestion.SEC_Forms_Question__r.Question_Text__c; //question_template
                        opptyQA.Question_Type__c = templateQuestion.Question_Type__c; //question_template
                        opptyQA.Required__c = templateQuestion.Required__c; //question_template
                        opptyQA.SEC_Forms_Oppty_Form_Template__c = templateToFormTemplate.get(templateQuestion.SEC_Forms_Template__c);
                        opptyQA.SEC_Forms_Template_Question__c = templateQuestion.Id; //question_template.id
                        opptyQA.SEC_Forms_Oppty_Form__c = retId;
                        opptyQA.Pre_population__c = templateQuestion.SEC_Forms_Question__r.Pre_population__c;
                        opptyQA.Answer__c = templateQuestion.SEC_Forms_Question__r.Pre_population__c;
                        opptyQA.QID__c = templateQuestion.SEC_Forms_Question__r.QID__c;
                        opptyQA.Question_Type_2__c = templateQuestion.SEC_Forms_Question__r.Question_Type__c;
                        
                        //System.debug('#######w:' + templateQuestion.SEC_Forms_Template__c);
                        //System.debug('#######x:' + templateToFormTemplate.keySet());
                        //System.debug('#######y:' + templateToFormTemplate.get(templateQuestion.SEC_Forms_Template__c));
                        //System.debug('#######z:' + formTemplateToOpptyTemplate.get(templateToFormTemplate.get(templateQuestion.SEC_Forms_Template__c)));
                        //System.debug('##########Form_Template:' + opptyQA.SEC_Forms_Oppty_Form_Template__c);
                        
                        
                        opptyFormQAs.add(opptyQA);
                        
                        if (templateQuestion.Parent_Question__c != null) {
                            questionsWithParents.put(templateQuestion.Id, templateQuestion.Parent_Question__c);
                        }
                    }
                }       
                
                insert opptyFormQAs;
        
                //don't know the parent Id until after it has been inserted
                
                for(SEC_Forms_Oppty_Forms_Question_Answer__c opptyQA : opptyFormQAs) {
                    if (questionsWithParents.containsKey(opptyQA.SEC_Forms_Template_Question__c)) {
                        
                        Id parentId = questionsWithParents.get(opptyQA.SEC_Forms_Template_Question__c);
                        
                        for(SEC_Forms_Oppty_Forms_Question_Answer__c opptyQAP : opptyFormQAs) {
                            if (opptyQAP.SEC_Forms_Template_Question__c == parentId) {
                                opptyQA.Parent_Question__c = opptyQAP.Id;
                                break;
                            }
                        }
                    }
                }
                
                update opptyFormQAs;
                
                
            
            }
            catch (System.Exception ex) {
                //all or nothing
                Database.rollback(sp);
                System.debug('exception: ' + ex);
                
                retId = null;
            
            }
            
        }
        
        return retId;
    }
    
    public static void copyForm(Id sourceId, Id targetId) {
        //for all questions in target, if source has matching QID and generic, copy answer
        //if template zero, then contacts, check for name populated
        //else check if global, and has QID
        /*
        Map<Id,Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c>> qas = new Map<Id,Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c>> {
            sourceId => new Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c>{},
            targetId => new Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c>{}
        };
        */
        Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c> sourceQuestions = new Map<String,SEC_Forms_Oppty_Forms_Question_Answer__c>{};
        Map<String,List<SEC_Forms_Oppty_Forms_Question_Answer__c>> targetQuestions = new Map<String,List<SEC_Forms_Oppty_Forms_Question_Answer__c>>{};
        
        //Map<Integer,Id> sourceOrderedContacts = new Map<Integer,Id>{};
        //Map<Integer,Id> targetOrderedContacts = new Map<Integer,Id>{};
        //Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c> sourceContacts = new Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c>{};
        //Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c> targetContacts = new Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c>{};
        
        Map<String,Map<String,String>> sourceContacts = new Map<String,Map<String,String>>{};  //contact => field => value
        Map<String,Map<String,Id>> targetContacts = new Map<String,Map<String,Id>>{};
        String lastSourceContact = '';
        String lastTargetContact = '';
        Boolean queueTargetContact = false;
        
        for(SEC_Forms_Oppty_Forms_Question_Answer__c question : [select Id, Question_Text__c, QID__c, Question_Type_2__c, Answer__c, Is_Contact_Name__c, SEC_Forms_Oppty_Form_Template__r.Template_Layout_Order__c, SEC_Forms_Oppty_Form__c from SEC_Forms_Oppty_Forms_Question_Answer__c where SEC_Forms_Oppty_Form__c in (:sourceId, :targetId) and Question_Type_2__c in ('Global/Generic', 'Contact') order by Question_Layout_Order__c]) {
            
            System.debug('#####question:' + question);
            
            if (question.Question_Type_2__c == 'Global/Generic' && question.QID__c != null) {
                //qas.get(question.SEC_Forms_Oppty_Form__c).put(question.QID__c, question);
                if (question.SEC_Forms_Oppty_Form__c == sourceId) {
                    sourceQuestions.put(question.QID__c, question);
                }
                else if (question.SEC_Forms_Oppty_Form__c == targetId) {
                    if (targetQuestions.containsKey(question.QID__c)) {
                        targetQuestions.get(question.QID__c).add(question);
                    }   
                    else {
                        targetQuestions.put(question.QID__c, new List<SEC_Forms_Oppty_Forms_Question_Answer__c> { question });
                    }
                }
            }
            else if (question.Question_Type_2__c == 'Contact') {
                //todo
                //soql call is being ordered by Layout_Order
                if (question.SEC_Forms_Oppty_Form__c == sourceId) {
                    if (question.Is_Contact_Name__c) {
                        lastSourceContact = question.Question_Text__c;
                        sourceContacts.put(lastSourceContact, new Map<String,String> {
                            lastSourceContact => question.Answer__c
                        });
                        
                        System.debug('####source:adding contact:' + lastSourceContact + ', ' + question.Question_Text__c + ', ' + question.Answer__c);
                    }
                    else {
                        sourceContacts.get(lastSourceContact).put(question.Question_Text__c, question.Answer__c);
                        
                        System.debug('####source:adding contact:' + lastSourceContact + ', ' + question.Question_Text__c + ', ' + question.Answer__c);
                    }
                }
                else if (question.SEC_Forms_Oppty_Form__c == targetId) {
                    if (question.Is_Contact_Name__c) {
                        if (question.Answer__c == null) {
                            lastTargetContact = question.Question_Text__c;
                            queueTargetContact = true;
                            targetContacts.put(lastTargetContact, new Map<String,Id> {
                                lastTargetContact => question.Id
                            });
                            
                            System.debug('####target:adding contact:' + lastTargetContact + ', ' + question.Question_Text__c + ', ' + question.Id);
                        }
                        else {
                            lastTargetContact = '';
                            queueTargetContact = false;
                        }
                    }
                    else if (queueTargetContact) {
                        targetContacts.get(lastTargetContact).put(question.Question_Text__c, question.Id);
                        
                        System.debug('####target:adding contact:' + lastTargetContact + ', ' + question.Question_Text__c + ', ' + question.Id);
                    }
                }
                
            }
            
        }
        
        //List<SEC_Forms_Oppty_Forms_Question_Answer__c> questionsToUpdate = new List<SEC_Forms_Oppty_Forms_Question_Answer__c>{};
        Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c> questionsToUpdate = new Map<Id,SEC_Forms_Oppty_Forms_Question_Answer__c>{};
        
        //now loop through target, if answer is null source has matching qid, copy over
        for(String QID : targetQuestions.keySet()) {
            if (sourceQuestions.containsKey(QID)) {
                for(SEC_Forms_Oppty_Forms_Question_Answer__c question : targetQuestions.get(QID)) {
                    if (question.Answer__c == null) {
                        String sourceAnswer = sourceQuestions.get(QID).Answer__c;
                        question.Answer__c = sourceAnswer;
                        questionsToUpdate.put(question.Id, question);
                        
                        System.debug('####COPYING ANSWER TO:' + question);
                    }
                }
            }
        }
        
        //copy contacts here
        if (!targetContacts.isEmpty()) {
            for(String role : targetContacts.keySet()) {
                
                System.debug('#####role:' + role);
                
                if (sourceContacts.containsKey(role)) {
                    Map<String,String> sourceContact = sourceContacts.get(role);
                    Map<String,Id> targetContact = targetContacts.get(role);
                    
                    
                    
                    for(String field : targetContact.keySet()) {
                        
                        System.debug('####field:' + field);
                        
                        if (sourceContact.containsKey(field)) {
                            Id fieldId = targetContact.get(field);
                            
                            questionsToUpdate.put(fieldId, new SEC_Forms_Oppty_Forms_Question_Answer__c(
                                Id = fieldId,
                                Answer__c = sourceContact.get(field)
                            ));
                            
                            System.debug('adding field:' + fieldId + ', ' + sourceContact.get(field));
                        }
                    }
                }
            }
        }
        
        if (!questionsToUpdate.isEmpty()) {
            update questionsToUpdate.values();
            
            //also update targetform w/sourceform
            update(new SEC_Forms_Oppty_Form__c(
                Id = targetId,
                Source_Form__c = sourceId
            ));
            
        }
    }
    
    private SEC_Forms_Oppty_Forms_Question_Answer__c newContactRole(String qType, String text, String answer, Id contactTemplateId, Integer order, Id formId) {
        return newContactRole(qType, text, answer, contactTemplateId, order, formId, false);
    }
    
    private SEC_Forms_Oppty_Forms_Question_Answer__c newContactRole(String qType, String text, String answer, Id contactTemplateId, Integer order, Id formId, Boolean master) {
        
        SEC_Forms_Oppty_Forms_Question_Answer__c qa = new SEC_Forms_Oppty_Forms_Question_Answer__c(
            Question_Type__c = 'Short Text',
            Question_Text__c = text,
            Answer__c = answer,
            SEC_Forms_Oppty_Form_Template__c = contactTemplateId,
            Question_Layout_Order__c = order,
            SEC_Forms_Oppty_Form__c = formId,
            Date_Answered__c = now,
            Question_Type_2__c = qType,
            Is_Contact_Name__c = master
        );
        return qa;
    }
    
}