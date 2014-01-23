public with sharing class TrialOpptyForms_Link {

	public String formName {get;set;}
	public String formLink {get;set;}
	public String formLinkText {get;set;}
	public Integer index {get;set;}
	
	public TrialOpptyForms_Link(String FormName, String FormLink, String FormLinkText, Integer Index) {
		this.formName = FormName;
		this.formLink = FormLink;
		this.formLinkText = FormLinkText;
		this.Index = Index;
	}

}