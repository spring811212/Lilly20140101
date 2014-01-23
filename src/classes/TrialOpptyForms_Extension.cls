public class TrialOpptyForms_Extension {

    private final Opportunity oppty;
    //private final String formView = '/apex/Form_View';

    public List<TrialOpptyFormWrapper> links {get;private set;} 

    public TrialOpptyForms_Extension(ApexPages.StandardController controller) {
        oppty = (Opportunity)controller.getRecord();
        links = new List<TrialOpptyFormWrapper>{};
        
        List<SEC_Forms_Trial_Form__c> trialForms = [select Id, SEC_Forms_Form__c, Form_Type__c, SEC_Forms_Form__r.Name/*, SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c*/ from SEC_Forms_Trial_Form__c where Trial_Campaign__c = :oppty.CampaignId];
        List<SEC_Forms_Oppty_Form__c> opptyForms = [select Id, SEC_Forms_Form__c, CreatedDate, Approval_Status__c, Submitted_Date__c from SEC_Forms_Oppty_Form__c where Trial_Campaign__c = :oppty.CampaignId and Opportunity__c = :oppty.Id];
        
        Id userId = UserInfo.getUserId();
        Integer i = 0;
        
        for(SEC_Forms_Trial_Form__c trialForm : trialForms) {
            
            Id oid;
            SEC_Forms_Oppty_Form__c foundOpptyForm;
            
            String linkText = '';
            //String linkHref = formView;
            
            Boolean exists = false;
            Boolean owner = false;
            Boolean stage = false;
            //Boolean locked = false; //may not be needed at this level

            for (SEC_Forms_Oppty_Form__c opptyForm : opptyForms) {
                if (opptyForm.SEC_Forms_Form__c == trialForm.SEC_Forms_Form__c) {
                    exists = true;
                    //locked = trialForm.SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c;
                    oid = opptyForm.Id;
                    foundOpptyForm = opptyForm;
                    break;
                }
            }
            
            owner = (userId == oppty.OwnerId);
            stage = foundOpptyForm == null? true : (foundOpptyForm.Approval_Status__c == 'Draft Saved' || foundOpptyForm.Approval_Status__c == 'Created' || foundOpptyForm.Approval_Status__c == 'Rejected' || foundOpptyForm.Approval_Status__c == '');
            
            //System.debug('####flags: exists=' + exists + ', owner=' + owner + ', stage=' + stage);
            
            linkText = viewEditCreateMatrix(owner, stage, exists, trialForm.Form_Type__c);

            if (linkText != '') {
                
                PageReference url;
                
                if (linkText == 'Create') { //goto CreateForm
                    //linkHref += '?tid=' + trialForm.Id + 
                    //  '&opptyId=' + oppty.Id + 
                    //  '&cmpgnId=' + oppty.CampaignId + 
                    //  '&fnom=' + trialForm.SEC_Forms_Form__c;
                    url = Page.CreateForm;
                    url.getParameters().putAll(new Map<String,String> {
                        'tid' => trialForm.Id,
                        'opptyId' => oppty.Id,
                        'cmpgnId' => oppty.CampaignId,
                        'fnom' => trialForm.SEC_Forms_Form__c
                    });
                }
                else { //goto Form_View
                    //linkHref += '?oid=' + oid +
                    //  '&tid=' + trialForm.Id +
                    //  '&opptyId=' + oppty.Id + 
                    //  '&fnom=' + trialForm.SEC_Forms_Form__c;
                    
                    //PwC updates: Change from FLEX to web page
                    url = Page.SECFormStartPage;
                    //url = Page.Form_View;
                    //PwC updates end
                    
                    url.getParameters().putAll(new Map<String,String>{
                        'oid' => oid,
                        'tid' => trialForm.Id,
                        'opptyId' => oppty.Id,
                         'fnom' => trialForm.SEC_Forms_Form__c
                    });
                }
                
                if(trialForm.Form_Type__c != 'PI Change' && trialForm.Form_Type__c != 'Location Change'){
                	links.add(new TrialOpptyFormWrapper(
                    trialForm.SEC_Forms_Form__r.Name,
                    //linkHref,
                    url.getUrl(),
                    linkText,
                    i,
                    foundOpptyForm==null? '':foundOpptyForm.Approval_Status__c,
                    foundOpptyForm==null? null:foundOpptyForm.Submitted_Date__c,
                    foundOpptyForm==null? null:foundOpptyForm.CreatedDate,
                    foundOpptyForm==null? '':foundOpptyForm.Id,
                    trialForm.Form_Type__c,
                    trialForm.SEC_Forms_Form__c
                	));
                }
                else if(trialForm.Form_Type__c == 'PI Change' && (oppty.StageName == 'Selected' || oppty.StageName == 'PI Change Submitted' || oppty.StageName == 'PI Change Rejected') && oppty.Display_Forms_Flag__c == true){
                	links.add(new TrialOpptyFormWrapper(
                    trialForm.SEC_Forms_Form__r.Name,
                    //linkHref,
                    url.getUrl(),
                    linkText,
                    i,
                    foundOpptyForm==null? '':foundOpptyForm.Approval_Status__c,
                    foundOpptyForm==null? null:foundOpptyForm.Submitted_Date__c,
                    foundOpptyForm==null? null:foundOpptyForm.CreatedDate,
                    foundOpptyForm==null? '':foundOpptyForm.Id,
                    trialForm.Form_Type__c,
                    trialForm.SEC_Forms_Form__c
                	));
                }
                else if(trialForm.Form_Type__c == 'Location Change' && (oppty.StageName == 'Selected' || oppty.StageName == 'Site Loc Change Rejected' || oppty.StageName == 'Site Loc Change Submitted') && oppty.Display_Location_Change__c == true){
                	links.add(new TrialOpptyFormWrapper(
                    trialForm.SEC_Forms_Form__r.Name,
                    //linkHref,
                    url.getUrl(),
                    linkText,
                    i,
                    foundOpptyForm==null? '':foundOpptyForm.Approval_Status__c,
                    foundOpptyForm==null? null:foundOpptyForm.Submitted_Date__c,
                    foundOpptyForm==null? null:foundOpptyForm.CreatedDate,
                    foundOpptyForm==null? '':foundOpptyForm.Id,
                    trialForm.Form_Type__c,
                    trialForm.SEC_Forms_Form__c
                	));
                }else{}
                
                i++;
            }
            
        }
        
        links.sort();
        
    }
    
    private String viewEditCreateMatrix(Boolean owner, Boolean stage, Boolean exists, String formType) {
        String retTxt = '';
        
        //view
        if ( (exists && !stage)
            ) {
            retTxt = 'View';
        }
        //edit
        else if ( (exists && stage)
            ) {
            retTxt = 'Edit';
        }
        //create
        else if ( (owner && !exists)
            ){
            retTxt = 'Create';
        }
        //[empty]
        return retTxt;
    }
    
}