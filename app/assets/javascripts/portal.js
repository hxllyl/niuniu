// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){
  var validCodeBut = $('#valid_code_but');
  var validCode = $('.valid-code');
  
  validCodeBut.on('click', function(event){
    event.preventDefault();
    
    var mobile = $('#mobile').val();
    
    $.post('/valid_codes.json', { mobile: mobile, type: 0 }, function(data){
       if(data.status == 'success'){
         validCode.val(data.code);
       }else{
         alert(data.error_msg);
       }
     });

  });
});
