// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){

  // 用户获取手机验证码
  var validCodeBut = $('.valid_code_but');
  var validCode = $('.valid-code');
  var nextStep = $('#next-step');
  var codeBut  = $('#valid_code_but');
  var countdown = $("#countdown");
  
  validCodeBut.on('click', function(event){
    event.preventDefault();
    
    var mobile = $('#mobile');
    
    $.post('/valid_codes.json', { mobile: mobile.val(), type: 0 }, function(data){
       if(data.status == 'success'){
       }else{
         alert(data.error_msg);
       }
     });
  });
  
  validCode.keyup(function(event){
    event.preventDefault();
    
    if(validCode.val().length == 6){
      $.get('/valid_codes/_valid.json?mobile='+$('#mobile').val()+'&valid_code=' + validCode.val(),
            function(data){
              if(data.status == 'success'){
                nextStep.prop('disabled', false);
              }else{
                nextStep.prop('disabled', true);
                alert("手机或验证码输入错误！");
              }
            })
    }
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
