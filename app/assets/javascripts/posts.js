$(function(){
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
