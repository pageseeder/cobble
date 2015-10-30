/**
 * JavaScript for Cobble
 */
$(document).ready(function(){


  $('body').xsltDoc();

});

// Main Plugin declaration
$.fn.xsltDoc = function() {

 return this.each(function() {
   var $doc = $(this);
   var $nav = $doc.find('nav');

   $nav.find('a').on('click', function() {
     var $tab = $(this);
     var $target = $doc.find($tab.attr('href'));
     $doc.find('section').hide();
     $target.show();
     $tab.addClass('active');
     return false;
   });

 });

};