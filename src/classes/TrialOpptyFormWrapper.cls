global class TrialOpptyFormWrapper implements Comparable {
  public String formName {get;set;}
  public String formLink {get;set;}
  public String formLinkText {get;set;}
  public Integer index {get;set;}
  public String status {get;set;}
  public DateTime submittedDatetime {get;set;}
  public DateTime createdDate {get;set;}
  public String opptyFormId {get;set;}
  public String formId {get;set;}
  public String formType {get;set;}
  public String submittedDateText{
  	get{
  		return submittedDatetime==null? '' : submittedDatetime.format('MM/dd/yyyy HH:mm:ss');
  	}
  }
  public String createdDateText{
  	get{
  		return createdDate==null? '' : createdDate.format('MM/dd/yyyy HH:mm:ss');
  	}
  }
  public String cssStyle {
  	get{
  		if(status==null){
  			return '';
  		}
  		if(status.equals('Pending')){
  			return 'color:#E5C130;font-weight:bold;'; //Dark Yellow
  		}
  		else if(status.equals('Approved')){
  			return 'color:#A1F78D;font-weight:bold;'; //Light Blue
  		}
  		else if(status.equals('Rejected')){
  			return 'color:Red;font-weight:bold;';
  		}
  		else{
  			return '';
  		}
  	}
  }
  
  public TrialOpptyFormWrapper(String FormName, String FormLink, String FormLinkText, Integer Index, String status, 
  	DateTime submittedDatetime, DateTime createdDate, String opptyFormId, String formType, String formId) {
    this.formName = FormName;
    this.formLink = FormLink;
    this.formLinkText = FormLinkText;
    this.Index = Index;
    this.status = status;
    this.submittedDatetime = submittedDatetime;
    this.createdDate = createdDate;
    this.opptyFormId = opptyFormId;
    this.formType = formType;
    this.formId = formId;
  }
  
  global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        TrialOpptyFormWrapper compareToForm = (TrialOpptyFormWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if(this.createdDate == null){
        	returnValue = 1;
        }
        else if(compareToForm.createdDate == null){
        	returnValue = -1;
        }
        else if (this.createdDate > compareToForm.createdDate) {
	        // Set return value to a positive value.
	        returnValue = -1;
        } 
        else if (this.createdDate < compareToForm.createdDate) {
            // Set return value to a negative value.
            returnValue = 1;
        }
	     /*   
        if (this.submittedDatetime > compareToForm.submittedDatetime) {
            // Set return value to a positive value.
            returnValue = -1;
        } 
        else if (this.submittedDatetime < compareToForm.submittedDatetime) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        else{
        	if (this.createdDate > compareToForm.createdDate) {
            // Set return value to a positive value.
            returnValue = -1;
	        } else if (this.createdDate < compareToForm.createdDate) {
	            // Set return value to a negative value.
	            returnValue = 1;
	        }
        }*/
        
        return returnValue;       
    }
}