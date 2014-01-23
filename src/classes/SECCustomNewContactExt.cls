/**
 * SECCustomNewContactExt
 * The class is used as extension class for page 'SECCustomNewContact'
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */
public class SECCustomNewContactExt {
    public Contact con {get;set;}
    public SECCustomNewContactExt(ApexPages.StandardController stdController) {
        con = new Contact();
        String SECFormOpptyFormId = ApexPages.currentPage().getParameters().get('oid');
        
        String opptyId = null;
        String accId = null;
        
        //Get Trial Site Id
        List<SEC_Forms_Oppty_Form__c> opptyFormList =  [SELECT s.Opportunity__c FROM SEC_Forms_Oppty_Form__c s WHERE s.Id=:SECFormOpptyFormId Limit 1];
        
        if(opptyFormList.size() > 0){
        	opptyId = opptyFormList[0].Opportunity__c;
        }
        
        //Get Site Id
        List<Opportunity> opptyList = [SELECT o.AccountId FROM Opportunity o WHERE o.Id=:opptyId Limit 1];
        
        if(opptyList.size() > 0){
        	accId = opptyList[0].AccountId;
        }
        
        con.AccountId = accId;
        
    }
    
    public PageReference save() {
        insert this.con;
        
        PageReference newPage = New PageReference('/' + this.con.Id);
        newPage.setRedirect(true);
        return newPage;
    }

    
    
}