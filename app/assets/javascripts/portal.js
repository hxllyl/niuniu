// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){

  // 用户获取手机验证码
  var validCodeBut = $('#valid_code_but');
  var validCode = $('.valid-code');
  var nextStep = $('#next-step');
  var codeBut  = $('#valid_code_but');
  var countdown = $("#countdown");
  
  validCodeBut.on('click', function(event){
    event.preventDefault();
    
    var mobile = $('#mobile');
    
    $.post('/valid_codes.json', { mobile: mobile.val(), type: 0 }, function(data){
       if(data.status == 'success'){
         validCodeBut.hide();
         countdown.show();
         
         updateCountdown(60, countdown);
         codeBut.prop('disabled', true);
         nextStep.prop('disabled', false);
       }else{
         alert(data.error_msg);
       }
     });
  });
  
  // 用户获取省市
  var province = $('#province');

  province.on('change', function(e){
    e.preventDefault();
    
    var city = $('#city');
    var pid = $(this).val(); 
    var url = 'areas/' + pid + '.json';
    
    $.get(url, function(d){
      if(d.status == 'success'){
        city.empty();
        $.each(d.datas, function(index, value){
          city.append("<option value=" + value[1]+ ">"+ value[0] +"</option>");
        });
      }else{
        alert(d.error_msg);
      }
    });
  
  });
  
});

function updateCountdown(seconds, selected) {
    seconds--;
    if (seconds > 0) {
       selected.text(seconds);
       setTimeout(updateCountdown(seconds, selected), 1000);
    } else {
      selected.hide();
      return 0;
    }
}
