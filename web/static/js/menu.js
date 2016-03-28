(function($){
$(document).ready(function(){

$('#menu1').prepend('<div id="menu-button">MP etc.</div>');
$('#menu2').prepend('<div id="menu-button">Days</div>');
$('#menu3').prepend('<div id="menu-button">Service</div>');
  $('.cssmenu #menu-button').on('click', function(){
    var menu = $(this).next('ul');
    if (menu.hasClass('open')) {
      menu.removeClass('open');
    } else {
      menu.addClass('open');
    }
});

});
})(jQuery);
