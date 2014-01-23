public class CustomNewContactExt {
	public Contact con {get;set;}
	public CustomNewContactExt(ApexPages.StandardController stdController) {
        con = new Contact();
        String SECFormOpptyFormId = ApexPages.currentPage().getParameters().get('oid');
        String opptyId = [Select s.Opportunity__c From SEC_Forms_Oppty_Form__c s Where s.Id=:SECFormOpptyFormId Limit 1].Opportunity__c;
        String accId = [Select o.AccountId From Opportunity o Where o.Id=:opptyId Limit 1].AccountId;
        
        con.AccountId = accId;
        
        //system.debug('*** accountId: ' + SECFormOpptyFormId + ': ' + opptyId + ': ' + con.AccountId);
    }
    
    public PageReference save() {
        insert this.con;
        String SECFormOpptyFormId = ApexPages.currentPage().getParameters().get('oid');
        ID trialId = [Select Trial_Campaign__c From SEC_Forms_Oppty_Form__c WHERE Id =: SECFormOpptyFormId LIMIT 1].Trial_Campaign__c;
        
        CampaignMember cMember = new CampaignMember();
        cMember.ContactId = this.con.Id;
        cMember.CampaignId = trialId;
        insert cMember;
        
        PageReference newPage = New PageReference('/' + this.con.Id);
        //newPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        newPage.setRedirect(true);
        return newPage;
    }

	
	
}