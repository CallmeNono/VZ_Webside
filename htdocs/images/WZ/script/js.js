$(function(){
	//--背景图切换
	if($('.bodyImg').length>0){
	  bodyImgFun();
	  $(window).resize(function(){
		  bodyImgFun();
		  })
	  $('.bodyImg').find('img:first').fadeIn('slow');
	}
	//--
	/*$('.indexBtn').find('.name').toggle(
	   function(){
		   $('.indexDiv').animate({left: -500}, 200);
		   $('.indexDiv').find('.logo').animate({left: 400}, 500);
		   $(this).addClass('nameNow');
		   $('.indexAbout').animate({right: 0}, 200);
		   },
	   function(){
		   $('.indexDiv').animate({left: 0}, 200);
		   $('.indexDiv').find('.logo').animate({left: 100}, 500);
		   $(this).removeClass('nameNow');
		   $('.indexAbout').animate({right: -500}, 200);
		   }
	)*/
	$('.indexBtn').find('.name').hover(
	   function(){
		   $('.indexDiv').animate({left: -500}, 800);
		   $('.indexDiv').find('.logo').animate({left: 400}, 900);
		   $(this).addClass('nameNow');
		   $('.indexAbout').animate({right: 0}, 800);
		   },
	   function(){}
	)
	$('.indexAbout').hover(
	   function(){},
	   function(){
		   $('.indexDiv').animate({left: 0}, 800);
		   $('.indexDiv').find('.logo').animate({left: 100}, 900);
		   $('.indexBtn').find('.name').removeClass('nameNow');
		   $('.indexAbout').animate({right: -500}, 800);
		   }
	)
	//--
	var caseScrollNow=0;
	$('.caseScroll').find('.name').find('li:first').show();
	$('.caseScroll').find('.list').find('li:first').find('img').fadeIn(300);
	$('.caseScroll').find('.list2').find('li:first').fadeIn(300);
	$('.caseScroll').find('.list').find('li').each(function(i){
		$(this).hover(
		   function(){
			   $('.caseScroll').find('.list').find('li').find('img').fadeOut(300);
			   $(this).find('img').fadeIn(300);
			   $('.caseScroll').find('.list2').find('li').eq(caseScrollNow).fadeOut(300);
			   $('.caseScroll').find('.list2').find('li').eq(i).fadeIn(300);
			   caseScrollNow=i;
			   $('.caseScroll').find('.num').find('span').html(Number(i)+1);
			   },
		   function(){}
		)
		})
	/*$('.caseScroll').find('.rightBtn').click(function(){
		imgScrollRight2($('.caseScroll').find('.list'),$('.caseScroll').find('.list').find('li').length-3,268,0);
		$('.caseScroll').find('.num').find('span').html(Number(imgScrollNum2[0])+1);
		$('.caseScroll').find('.name').find('li').hide();
		$('.caseScroll').find('.name').find('li').eq(imgScrollNum2[0]).show();
		})
	$('.caseScroll').find('.leftBtn').click(function(){
		imgScrollLeft2($('.caseScroll').find('.list'),$('.caseScroll').find('.list').find('li').length-3,268,0);
		$('.caseScroll').find('.num').find('span').html(Number(imgScrollNum2[0])+1);
		$('.caseScroll').find('.name').find('li').hide();
		$('.caseScroll').find('.name').find('li').eq(imgScrollNum2[0]).show();
		})*/	
	//--
	$('.case').find('li').hover(
	   function(){
		   $(this).find('.img2').fadeOut(300);
		   },
	   function(){
		   $(this).find('.img2').fadeIn(300);
		   }
	)	
	//--
	$('.caseSide').find('.name').find('a').each(function(i){
	$(this).toggle(
	   function(){
		   $(this).addClass('aNow');
		   $('.caseSide').find('.list').eq(i).show();
		   },
	   function(){
		   $(this).removeClass('aNow');
		   $('.caseSide').find('.list').eq(i).hide();
		   }
	)
	})
	//--
	$('.ewmLayer2A').hover(
	   function(){
		   $('.ewmLayer2').show();
		   },
	   function(){
		   $('.ewmLayer2').hide();
		   }
	)
	//
	})