$(document).ready(function(){
  $(".dropdown-toggle").dropdown();
  /*标签切换*/
  $(".nav-tabs a").click(function (e) {
    e.preventDefault();
    $(this).tab("show");
  });
  $(".carousel").carousel();
  /*翻页居中*/
  $(".pageList").css("margin-left", -$(".pageList").outerWidth(true)/2 + "px");
  /*表单验证*/
  $("form,#forget_step2").Validform();
  /*placeholder兼容*/
  $(function() {
    $('input, textarea').placeholder();
  });
  /*nav fixed*/
  $(window).scroll(function(){
    var scrollTop = $(this).scrollTop();
    if(scrollTop > 0){
      $("#topBar").addClass("fixed");
    }else{
      $("#topBar").removeClass("fixed");
    };
  });
  /*提醒框*/
  setTimeout(function() {
      $(".alertTips").fadeOut("fast");
  }, 2000);

  $(function() {
    //IE也能用textarea
    $("textarea[maxlength]").keyup(function() {
      var area = $(this);
      var max = parseInt(area.attr("maxlength"), 10); //获取maxlength的值
      if (max > 0) {
        if (area.val().length > max) { //textarea的文本长度大于maxlength
          area.val(area.val().substr(0, max)); //截断textarea的文本重新赋值
        }
      }
    });
    //复制的字符处理问题
    $("textarea[maxlength]").blur(function() {
      var area = $(this);
      var max = parseInt(area.attr("maxlength"), 10); //获取maxlength的值
      if (max > 0) {
        if (area.val().length > max) { //textarea的文本长度大于maxlength
          area.val(area.val().substr(0, max)); //截断textarea的文本重新赋值
        }
      }
    });
  });
});
