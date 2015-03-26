$(document).ready(function(){
  $(".nav-tabs a").click(function (e) {
    e.preventDefault();
    $(this).tab("show");
  });
  /*翻页居中*/
  $(".pageList").css("margin-left", -$(".pageList").outerWidth(true)/2 + "px");
  /*placeholder兼容*/
  var doc = document,
  inputs = doc.getElementsByTagName("input"),
  supportPlaceholder = "placeholder" in doc.createElement("input"),
  placeholder = function(input) {
    var text = input.getAttribute("placeholder"),
    defaultValue = input.defaultValue;
    if (defaultValue == "") {
      input.value = text
    }
    input.onfocus = function() {
      if (input.value === text) {
        this.value = ""
      }
    };
    input.onblur = function() {
      if (input.value === "") {
        this.value = text
      }
    }
  };
  if (!supportPlaceholder) {
    for (var i = 0,
    len = inputs.length; i < len; i++) {
      var input = inputs[i],
      text = input.getAttribute("placeholder");
      if (input.type === "text" && text) {
        placeholder(input)
      }
    }
  }
  /*nav fixed*/
  $(window).scroll(function(){
    var scrollTop = $(this).scrollTop();
    if(scrollTop > 0){
      $("#topBar").addClass("fixed");
    }else{
      $("#topBar").removeClass("fixed");
    };
  });
});
