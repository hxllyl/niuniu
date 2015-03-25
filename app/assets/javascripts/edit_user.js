$(function(){
  // 用户获取省市
  var province = $('#province');

  province.on('change', function(e){
    e.preventDefault();
    
    var city = $('#city');
    var pid = $(this).val(); 
    var url = '/areas/' + pid + '.json';
    
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
})