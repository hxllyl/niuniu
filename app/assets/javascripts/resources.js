$(function(){
  
  // 根据品牌搜索资源
  var brand_select = $('#brand_select');
  var type = 0;
  var id = brand_select.attr('data_id');
  
  brand_select.on('change', function(e){
    e.preventDefault();
    var brand_id = brand_select.val();
    var url = '/users/' + id + '/my_posts?_type=' + type + '&brand_id=' + brand_id;
    
    location.href = url;
  });
  
  //全部更新
  
})