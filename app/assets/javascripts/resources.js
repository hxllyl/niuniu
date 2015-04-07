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

  var position_url = '/users/'+ id +'/my_posts/update_position.js';

  $(".mySourceTab .table").find("tr").hover(function(){
    $(this).find(".btnGroups").show();
  },function(){
    $(this).find(".btnGroups").hide();
  });

  var trLength = $(".btnGroups").find(".downBtn").length;
  $(".btnGroups").find(".upBtn").each(function(){
    $(this).click(function(){
      var $tr = $(this).parents("tr");
      var id = $tr.attr('data-id');
      if ($tr.index() != 0){
        var swap_id = $tr.prev().attr('data-id');
        
        $.post(position_url, {id: id, type: 'up', swap_id: swap_id}, function(){});
        $tr.prev().before($tr);
      }
    });
  });

  $(".btnGroups").find(".downBtn").each(function(){
    $(this).click(function(){
      var $tr = $(this).parents("tr");
      if ($tr.index() != trLength - 1){
        var id = $tr.attr('data-id');
        var swap_id = $tr.next().attr('data-id');
        $.post(position_url, {id: id, type: 'down', swap_id: swap_id}, function(){});
        $tr.next().after($tr);
      }
    });
  });

});

