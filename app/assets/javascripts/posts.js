$(function(){
  $(".methodSelect > .form-group").find(".selectTag").click(function (e) {
    $(".selectInput").find("input.form-control").attr("disabled","true");
    $(this).next(".selectInput").find("input.form-control").removeAttr("disabled");
    $(".selectInput").removeClass("active");
    $(this).addClass("active").siblings().removeClass("active");
    $(this).next(".selectInput").addClass("active").focus();
  });

  $(".selectInput").find("input.form-control").keyup(function(){
    clearNoNum(this);
  });

  function clearNoNum(obj){
    obj.value = obj.value.replace(/[^\d.]/g,""); //清除"数字"和"."以外的字符
    obj.value = obj.value.replace(/^(\-)*(\d+)\.(\d\d).*$/,'$1$2.$3'); //只能输入两个小数
  }
  
  
  // 举报
  $('.complaint_redio').on('change', function(e){
    e.preventDefault();
    
    var $this = $(this);
    var $id = $this.attr('data_id');
    
    if($this.prop('checked')){
      $('#resource_id').val($id);
    }
  })
  
  $('input.complaint_commit').on('click', function(e){
    e.preventDefault();
    
    $('form#new_complaint').submit();
  });
});