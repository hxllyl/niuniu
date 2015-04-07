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
  
  // 个人删除操作
  $('#alertModal').on('show.bs.modal', function(event){
    var cancel = $(event.relatedTarget);

    var id = cancel.attr('data-id');
    var clazz = cancel.attr('data-clazz');
    var type = cancel.attr('data-type');
    var ban = cancel.attr('data-update');
    var way = cancel.attr('data-way');
    
    var query = "?id=" + id + "&clazz=" + clazz + "&type=" + type + '&way=' + way;
    
    $('#del-btn').on('click', function(e){
      e.preventDefault();
      $.get('/users/delete_relation.json' + query, function(data){
        if(data.status == 'success'){
          cancel.parent().parent().hide();
          $('#'+ban).text(data.number);
          // $('#alertModal').fadeOut('fast');
        }
      });
    })
  })
})

