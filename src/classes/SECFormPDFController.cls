/**
 * SECFormPDFController
 * The class is used to store all the common methods supporting PDF preview and print
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */

public class SECFormPDFController {
	public List<Opportunity_Contact_Role__c> ocrList {get;set;}
	public String opptyFormId {get;set;}
	public SECFormQuestionTemplate.SECForm opptyForm{get;set;}
	
	public SECFormPDFController(){
		String value = ApexPages.currentPage().getParameters().get('oid');
		if(value==null || value == ''){
			value = 'a0He00000026ouJ'; 
		}
		opptyFormId = value;
	}
	
	public void getOpptyForm(){
		opptyForm = SECFormQuestionTemplate.getSECForm(opptyFormId);
	}
}