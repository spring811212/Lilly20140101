/**
 * SECFormCommonUtils
 * The class is used to store all the common methods and web services supporting business logic on SEC Form traversal
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */


global class SECFormCommonUtils {
    
    //Page Template Status
    public static final String PAGE_STATUS_INITIAL = 'Initial';
    public static final String PAGE_STATUS_DRAFTSAVED = 'Draft Saved';
    public static final String PAGE_STATUS_COMPLETED = 'Completed';
    public static final String PAGE_CURRENT = 'Current';
    
    //Trial Stie Form Status
    public static final String TRIALSITEFORM_STATUS_CREATED = 'Created';
    public static final String TRIALSITEFORM_STATUS_DRAFTSAVED = 'Draft Saved';
    public static final String TRIALSITEFORM_STATUS_PENDING = 'Pending';
    public static final String TRIALSITEFORM_STATUS_APPROVED = 'Approved';
    public static final String TRIALSITEFORM_STATUS_REJECTED = 'Rejected';
    
    /*
    //Define Role and Optional Role 
    public static List<String> roleList = new List<String>();
    public static List<String> optionalRoleList = new List<String>();
    
    static{
        //Pre-defined Role 
        roleList.add('Principal Investigator');
        roleList.add('Sub-Investigator');
        roleList.add('Primary Study Coordinator');
        roleList.add('Regulatory');
        roleList.add('Pharmacist');
        roleList.add('Budgets');
        roleList.add('Other Key Staff');
        roleList.add('Laboratory');
        roleList.add('Ship Lab Supplies to');
        roleList.add('Ship CRFs to');
        roleList.add('Ship investigational product (IP) to');
        roleList.add('Send Contract (LOA) to');
        roleList.add('Grant Payments');
        roleList.add('Ltr of Agreement/Study Work Orders(SWO)');
        
        //Pre-defined Optional Role
        optionalRoleList.add('Back-up Rater');
        optionalRoleList.add('Back-Up Study Coordinator');
        optionalRoleList.add('Business Development');
        optionalRoleList.add('CDE');
        optionalRoleList.add('Clinical Nurse Specialist');
        optionalRoleList.add('Contracts');
        optionalRoleList.add('D.O.');
        optionalRoleList.add('Data Manager');
        optionalRoleList.add('Diabetes Educator');
        optionalRoleList.add('Dietician');
        optionalRoleList.add('Director');
        optionalRoleList.add('Director of Research');
        optionalRoleList.add('Imaging');
        optionalRoleList.add('Intensivist');
        optionalRoleList.add('Manager/Supervisor');
        optionalRoleList.add('Pathologist');
        optionalRoleList.add('Pharmacy Technician');
        optionalRoleList.add('PNP');
        optionalRoleList.add('Previous PI or Sub-I');
        optionalRoleList.add('Project Manager/Administrator');
        optionalRoleList.add('Rater');
        optionalRoleList.add('Recruiter');
        optionalRoleList.add('Research Assistant');
        optionalRoleList.add('Research Manager');
        optionalRoleList.add('RN');
        optionalRoleList.add('Study Coordinator - Satellite Site');
    } */
    
    //Get Trial Site ID related to the SEC Form
    public static ID getTrialSiteId(ID SECFormOpptyFormId){
      
        ID trialSiteId;
        
        for(SEC_Forms_Oppty_Form__c opptyForm : [Select Opportunity__c From SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId LIMIT 1]){
          trialSiteId = opptyForm.Opportunity__c;
        }
        return trialSiteId;
    }
    
     public static ID getocrId(ID SECFormOpptyFormId, ID ContactId, string role){
      
        ID ocrId;
        
        for(opportunity_contact_role__c oppC : [Select id From opportunity_contact_role__c WHERE trialsite__c = :SECFormOpptyFormId and contact__c = :ContactId and role__c = :role  LIMIT 1]){
          ocrId = oppC.id;
        }
        return ocrId;
    }
    
    //Get Trial Site Contact Role's column - Role's picklist values 
    public static List<String> getRolePicklistValues() {
        
        List<String> rolePicklistValuesList = new List<String>();
        
        Schema.DescribeFieldResult field = Opportunity_Contact_Role__c.Role__c.getDescribe();
        
        for (Schema.PicklistEntry f : field.getPicklistValues()){
            rolePicklistValuesList.add(f.getLabel());
        }
        return rolePicklistValuesList;          
    }
    
    //Get mandatory role list, which is below tag 'ROLES REQUIRED/LISTED ON SEC'
    public static List<String> getMandatoryRoleList() {
        Boolean mandatoryRole = false;
        
        List<String> mandatoryRoleList = new List<String>();
        List<String> rolePicklistValuesList = getRolePicklistValues();
        for(String role : rolePicklistValuesList){
            if(role == 'ROLES REQUIRED/LISTED ON SEC'){
                mandatoryRole = true;
                continue;
            }
            else if(role == 'OPTIONAL VALUES NOT REQUIRED FOR SEC'){
                mandatoryRole = false;
                break;
            }
            
            if(mandatoryRole == true){
                mandatoryRoleList.add(role);
            }
        }
        
        return mandatoryRoleList;
    }
    
    
    //Get optional role list,  which is below tag 'OPTIONAL VALUES NOT REQUIRED FOR SEC'
    public static List<String> getOptionalRoleList() {
        Boolean optionalRole = false;
        
        List<String> optionalRoleList = new List<String>();
        List<String> rolePicklistValuesList = getRolePicklistValues();
        for(String role : rolePicklistValuesList){
            if(role == 'ROLES REQUIRED/LISTED ON SEC'){
                continue;
            }
            else if(role == 'OPTIONAL VALUES NOT REQUIRED FOR SEC'){
                optionalRole = true;
                continue;
            }
            
            if(optionalRole == true){
                optionalRoleList.add(role);
            }
        }
        
        return optionalRoleList;
    }
    
    
    //When Trial Site Form status is 'Pending' or 'Approved', form will be readonly; otherwise, form will be editable.
    webservice static String checkSECFormViewMode(ID SECFormOpptyFormId){
      
      String formStatus = null;
      String msg = null;
        
        msg = getSECFormViewMode(SECFormOpptyFormId);
        String result = JSON.serialize(msg);
        return result;
            
    }
    
    //Get SEC Form mode: ReadOnly / Editable
    public static String getSECFormViewMode(ID SECFormOpptyFormId){
      
      String formStatus = null;
      String result = null;
      
      for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT Approval_Status__c, Id FROM SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId LIMIT 1]){
        formStatus = opptyForm.Approval_Status__c;
      }
      
      if(formStatus == 'Pending' || formStatus == 'Approved'){
          result = 'Readonly';
        }
        else{
            result = 'Editable';
        }
      
      return result;
    }
    
    //Check if form type is 'Feasibility 1', add DemographicsPage to collect roles' information when return true;
  public static Boolean addDemographicsPage(ID SECFormOpptyFormId){
      
      String formType = 'unknown Form Type';
      
      for(SEC_Forms_Oppty_Form__c opptyForm : [SELECT Form_Type__c FROM SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId LIMIT 1]){
        formType = opptyForm.Form_Type__c;
      }
       //SV: 12/4/2013. accomodate form type =demographics
        //if(formType == 'Feasibility 1'){
        if (formType=='Demographics'){
        
       // if(formType == 'Feasibility 1'){
            return true;
        }else{
            return false;
        }
    }
    
    //Get role name by roleId
    public static String getRoleByRoleId(String roleId){
        String role = 'unknown role';
        
        Integer mandatoryRoleListSize = SECFormCommonUtils.getMandatoryRoleList().size();
        Integer mandatoryAndOptionalRoleListSize = SECFormCommonUtils.getMandatoryRoleList().size() + SECFormCommonUtils.getOptionalRoleList().size();
        
        if(Integer.valueOf(roleId) <= mandatoryRoleListSize)
        {
            role = SECFormCommonUtils.getMandatoryRoleList().get(Integer.valueOf(roleId) - 1); //Get mandatory role
        }
        else if(Integer.valueOf(roleId) <= mandatoryAndOptionalRoleListSize){
            role = SECFormCommonUtils.getOptionalRoleList().get(Integer.valueOf(roleId) - mandatoryRoleListSize - 1); //Get optional role
        }
        
        return role;
    }
    
    //Web service for Opportunity - Button - Display PI Change
    webservice static void setDisplayFormsFlagToTrue(ID trialSiteId){
        SECTrialSiteHelper.setDisplayFormsFlagToTrue(trialSiteId);
    }
     
    //Web service for Opportunity - Button - Display PI Change
    webservice static void setDisplayFormsFlagToFalse(ID trialSiteId){
        SECTrialSiteHelper.setDisplayFormsFlagToFalse(trialSiteId);
    }
    
    
    //Web service for Opportunity - Button - Display Loc Change
    webservice static void setDisplayLocChangeFormsFlagToTrue(ID trialSiteId){
        SECTrialSiteHelper.setDisplayLocChangeFormsFlagToTrue(trialSiteId);
    }
    
    //Web service for Opportunity - Button - Display Loc Change
    webservice static void setDisplayLocChangeFormsFlagToFalse(ID trialSiteId){
        SECTrialSiteHelper.setDisplayLocChangeFormsFlagToFalse(trialSiteId);
    }
    
}