$(document).ready(function(){
  $(".nav-tabs a").click(function (e) {
    e.preventDefault();
    $(this).tab("show");
  });
  $(window).scroll(function(){
    var scrollTop = $(this).scrollTop();
    if(scrollTop > 0){
      $("#topBar").addClass("fixed");
    }else{
      $("#topBar").removeClass("fixed");
    };
  });
});
