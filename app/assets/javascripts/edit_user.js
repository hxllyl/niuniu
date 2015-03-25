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
  
  // 跟新头像
  // $('.fileBtn').on('click', function(e){
  //
  //   var box = $('.user_image');
  //   $.post("/photos/level_uploads", {'_img[image]': box.val(), '_img[type]': box.attr('data_bype'),
  //                                    '_img[level]': box.attr('data_level')},
  //                                    function(data){
  //                                      if(data.status == 'success'){
  //                                        location.reload();
  //                                      }else{
  //
  //                                      }
  //
  //                                    });
  // });
  //
})