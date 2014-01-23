public class SECFormStartPageController{
    public SECFormStartPageController(){
        //to force IE to use latest document model
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge,chrome=1');     
    }
}