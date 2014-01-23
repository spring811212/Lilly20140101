/**
 * SECFormStartEvaluation
 * The class is used to store all the common methods and web services supporting business logic on page 'SECFormStartEvaluation'
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */
global class SECFormStartEvaluation {
  
  public class SECFormInfo{
    public String pageHeader {get;set;}
    public String pageFooter {get;set;}
    public String titleLabel {get;set;}
    public String purpose {get;set;}
    public String instructions {get;set;}
    public String trialOpportunityNameText {get;set;}
  }
  
  //Get different information for different types of form
  webservice static String getSECFormInfo(ID SECFormOpptyFormId){
    
    SECFormInfo form = new SECFormInfo();
    
    for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT Trial_Opportunity_Name_Text__c, Purpose__c, Page_Header__c, Page_Footer__c, Label__c, Instructions__c 
                         FROM SEC_Forms_Oppty_Form__c 
                         WHERE Id =: SECFormOpptyFormId LIMIT 1]){
      form.pageHeader = opptyForm.Page_Header__c;
      form.pageFooter = opptyForm.Page_Footer__c;
      form.titleLabel = opptyForm.Label__c;
      form.purpose = opptyForm.Purpose__c;
      form.instructions = opptyForm.Instructions__c;
      form.trialOpportunityNameText = opptyForm.Trial_Opportunity_Name_Text__c;
    }
    
    String result = JSON.serialize(form);
    return result;
  }
  
  //Check if the form has any question template
  webservice static Boolean checkFormValid(ID SECFormOpptyFormId){
    
    List<SEC_Forms_Oppty_Form_Template__c> formTemplateList = new List<SEC_Forms_Oppty_Form_Template__c>();
    
    for(SEC_Forms_Oppty_Form_Template__c formTemplate : [SELECT Id FROM SEC_Forms_Oppty_Form_Template__c WHERE SEC_Forms_Oppty_Form__c =: SECFormOpptyFormId]){
          formTemplateList.add(formTemplate);
        }
        
        if(!formTemplateList.isEmpty()){
          return true;
        }
        else{
          return false; //invalid form
        }
        
  }
}