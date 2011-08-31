/*
	Easy plugin to get element index position
	Author: Peerapong Pulpipatnan
	http://themeforest.net/user/peerapong
*/

$.fn.getIndex = function(){
	var $p=$(this).parent().children();
    return $p.index(this);
}

$.fn.pSlider = function(options){
	
	settings = jQuery.extend({
     	nav: '#slider_nav',
     	navWrapper: '.slider_nav_btn',
     	fadeSpeed: 800,
     	delay: 5000
  	}, options);
	
	var slideWrapper = $(this);
	var slideNav = settings.nav+' '+settings.navWrapper;
	
	$(this).children('div').css({ 'display': 'none' });
	
	var i = 0;
	$(this).children('div').each(function(){
		
		if($(this).attr('id') != 'slider_nav')
		{
			var slideTitle = $(this).children('span.title').html();
			$(slideNav).append('<a href="javascript:;" rel="'+i+'">'+slideTitle+'</a>');
			
			if($(this).children('span.title').children('img').length > 0)
			{
				$(slideNav).children('a[rel='+i+']').css({ 'padding': '6px 15px 0px 15px' });
			}
			
			i++;
		}
	});
	
	$(slideNav).children('a').eq(0).addClass('active');
	$(this).children('div').eq(0).css({ 'display': 'block' });
	
	var it = setInterval(function(){
     	
     	if($(slideNav+' a.active').next().length > 0)
     	{
     		
     		var nextSlide = $(slideNav+' a.active').next();
     		var slideTarget = $(slideNav+' a.active').next().attr('rel');
		
			// Remove all active slide
			slideWrapper.children('div').css({ 'display': 'none' });
			
			if(BrowserDetect.browser != 'Explorer')
			{
				slideWrapper.children('div').eq(slideTarget).fadeIn(settings.fadeSpeed);
			}
			else
			{
				slideWrapper.children('div').eq(slideTarget).css({ 'display': 'block' });
			}
			
			$(settings.nav+' a').removeClass('active');
			nextSlide.addClass('active');
     		
     	}
     	else
     	{
     	
     		// Remove all active slide
			slideWrapper.children('div').css({ 'display': 'none' });
			
			if(BrowserDetect.browser != 'Explorer')
			{
				slideWrapper.children('div').eq(0).fadeIn(settings.fadeSpeed);
			}
			else
			{
				slideWrapper.children('div').eq(0).css({ 'display': 'block' });
			}
			
			$(settings.nav+' a').removeClass('active');
			$(settings.nav+' a').eq(0).addClass('active');

     	}
     	 
    }, settings.delay);
    $(slideNav+' a').click(function(){
	
		$(settings.nav+' a').removeClass('active');
		$(this).addClass('active');
		
		var targetSlide = $(this).attr('rel');
		
		slideWrapper.children('div').css({ 'display': 'none' });
		
		if(BrowserDetect.browser != 'Explorer')
		{
			slideWrapper.children('div').eq(targetSlide).fadeIn(settings.fadeSpeed);
		}
		else
		{
			slideWrapper.children('div').eq(targetSlide).css({ 'display': 'block' });
		}
		
		clearInterval(it);
	
		return false;
	});
	
	$(slideNav).children('a').eq(0).addClass('active');
	$(this).children('div').eq(0).css({ 'display': 'block' });
	
}

$(document).ready(function(){ 

	$('input[title!=""]').hint();
	
	$('#content_slider').coinslider({ width: 920, height: 360, opacity: 0.9, navigation: true, titleSpeed: 800 , delay: 8000, sDelay: 10 });
	
	$('#content_slider_slide').pSlider({ nav: '#slider_nav', navWrapper: '.slider_nav_btn', fadeSpeed: 800, delay: 5000 });

	$('.two_third').hover(function(){  
 			$(this).find('.gallery1_hover').css({ 'top': '-411px', 'visibility': 'visible', 'opacity': 0.8 }).fadeIn(400);
 			
 			$(this).click(function(){
 				$(this).find('a').click();
 			});
 		}  
  		, function(){  
  		
  			$(this).find('.gallery1_hover').fadeOut();
  		}  
  		
	);
	
	$('.one_half .gallery_image').hover(function(){  
 			$(this).find('.gallery2_hover').css({ 'top': '-301px', 'visibility': 'visible', 'opacity': 0.8 }).fadeIn(400);
 			
 			$(this).click(function(){
 				$(this).find('a').click();
 			});
 		}  
  		, function(){  
  		
  			$(this).find('.gallery2_hover').fadeOut();
  		}  
  		
	);
	
	$('.one_third .gallery_image').hover(function(){  
 			$(this).find('.gallery3_hover').css({ 'top': '-193px', 'visibility': 'visible', 'opacity': 0.8 }).fadeIn(400);
 			
 			$(this).click(function(){
 				$(this).find('a').click();
 			});
 		}  
  		, function(){  
  		
  			$(this).find('.gallery3_hover').fadeOut();
  		}  
  		
	);
	
	$('.one_fourth .gallery_image').hover(function(){  
 			$(this).find('.gallery4_hover').css({ 'top': '-142px', 'visibility': 'visible', 'opacity': 0.8 }).fadeIn(400);
 			
 			$(this).click(function(){
 				$(this).find('a').click();
 			});
 		}  
  		, function(){  
  		
  			$(this).find('.gallery4_hover').fadeOut();
  		}  
  		
	);
	
	$.validator.setDefaults({
		submitHandler: function() { 
		    var actionUrl = $('#contact_form').attr('action');
		    
		    $.ajax({
  		    	type: 'POST',
  		    	url: actionUrl,
  		    	data: $('#contact_form').serialize(),
  		    	success: function(msg){
  		    		$('#contact_form').hide();
  		    		$('#reponse_msg').html(msg);
  		    	}
		    });
		    
		    return false;
		}
	});
		    
		
	$('#contact_form').validate({
		rules: {
		    your_name: "required",
		    email: {
		    	required: true,
		    	email: true
		    },
		    message: "required"
		},
		messages: {
		    your_name: "Please enter your name",
		    email: "Please enter a valid email address",
		    agree: "Please enter some message"
		}
	});	
	
	if(BrowserDetect.browser == 'Explorer' && BrowserDetect.version < 8)
	{
		var zIndexNumber = 1000;
		$('div').each(function() {
			$(this).css('zIndex', zIndexNumber);
			zIndexNumber -= 10;
		});
	}
	
	Cufon.replace('h1.cufon', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '32px'
	});
	Cufon.replace('h2.cufon', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '28px'
	});
	Cufon.replace('h3.cufon', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '22px'
	});
	Cufon.replace('h4.cufon', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '20px'
	});
	Cufon.replace('h5.cufon', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '18px'
	});
	Cufon.replace('a.big_button span', {
		textShadow: '0 -1px rgba(0, 0, 0, 0.6)',
		fontSize: '20px'
	});
	Cufon.replace('#footer h2.widgettitle', {
		fontSize: '16px'
	});
	Cufon.replace('.page_caption p', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '16px'
	});
	Cufon.replace('.cs-title strong.header', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '36px'
	});
	Cufon.replace('#content_slider_slide h3', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '36px'
	});
	Cufon.replace('.left_tagline h2', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '22px'
	});
	Cufon.replace('.dropcap1', {
		textShadow: '1px 1px rgba(255, 255, 255, 1)',
		fontSize: '40px'
	});

});