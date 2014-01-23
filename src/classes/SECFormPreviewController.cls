/**
 * SECFormPreviewController
 * The class is used to store all the common methods supporting PDF generator on Trial Site
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */

public class SECFormPreviewController {
    public List<Opportunity_Contact_Role__c> ocrList {get;set;}
    public String trialSiteId {get;set;}
    public SECFormQuestionTemplate.SECCompleteFormForPreview completeForm {get;set;}
    public Opportunity trialSite {get;set;}
    public String trialId {get;set;}
    
    public SECFormPreviewController(){
        String value = ApexPages.currentPage().getParameters().get('TrialSiteId');
        trialSiteId = value;
    }
    
    public void getCompleteForm(){ 
    	Id userId = UserInfo.getUserId();
    	for(Opportunity oppty : [SELECT Id, StageName, CampaignId FROM Opportunity WHERE Id =: trialSiteId]){
        	trialSite = oppty;
        	trialId = oppty.CampaignId;
        }
        
   		completeForm = SECFormQuestionTemplate.getCompleteSECFormForPreview(trialId, trialSiteId);
    }
    
}