// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){

  // 用户获取手机验证码
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
