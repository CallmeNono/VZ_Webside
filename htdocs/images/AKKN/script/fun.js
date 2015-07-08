//--
var imgScrollNum2=new Array();
for(i=0;i<50;i++){
  imgScrollNum2[i]=0;	
}
function imgScrollRight2(a,b,c,d){
	    //a.stop();
		if(imgScrollNum2[d]<b){
			imgScrollNum2[d]++;
			a.animate({scrollLeft: imgScrollNum2[d]*c}, 200);
			}
	}	
function imgScrollLeft2(a,b,c,d){
	    //a.stop();
		if(imgScrollNum2[d]>0){
			imgScrollNum2[d]--;
			a.animate({scrollLeft: imgScrollNum2[d]*c}, 200);		
			}
	}
//-------弹出对话框	
function prompt_fun(a){
	              $(a).after("<div id='Layer1'></div>"); 
				  if($('body').height()>$(window).height()){
				      $('#Layer1').height($('body').height());
				  }else{
					  $('#Layer1').height($(window).height());
					  }
				  $('#Layer1').width($('body').width());
				  $(a).css({left:($('body').width()-$(a).width())/2,top:$(window).scrollTop()+($(window).height()-$(a).height())/2});
				  $('#Layer1').fadeTo("fast",0.2); 
				  $(a).show();
				  //$(a).fadeIn("slow"); 
				  $('#Layer1').click(function(){
					  close_prompt_fun(a);
					  })	
	}
function close_prompt_fun(a){
	              //$(a).fadeOut("fast"); 
				  $(a).hide();
				  $('#Layer1').fadeOut("slow",function(){
					  $('#Layer1').remove();
					  }); 
	}	
//--
var indexProductScroll=0;
var indexProductWidth;
function indexProductFun(){
	if(indexProductScroll<indexProductWidth){
		indexProductScroll++;
		}else{
			indexProductScroll=0;
			}
	$('.indexProduct').find('.list').scrollLeft(indexProductScroll);
	}
//--
var fadeFlashNow=new Array();
for(i=0;i<50;i++){
  fadeFlashNow[i]=0;	
}	
function fadeFlashFun(i){
	$('.fadeFlash').eq(i).find('.btnDiv').find('span').removeClass('spanNow');
	$('.fadeFlash').eq(i).find('li').eq(fadeFlashNow[i]).fadeOut(1000);
	if(fadeFlashNow[i]<$('.fadeFlash').eq(i).find('li').length-1){
		fadeFlashNow[i]++;
		}else{
			fadeFlashNow[i]=0;
			}
	$('.fadeFlash').eq(i).find('li').eq(fadeFlashNow[i]).fadeIn(1000);
	$('.fadeFlash').eq(i).find('.btnDiv').find('span').eq(fadeFlashNow[i]).addClass('spanNow');
	}		
//--
function createflash2(src,img)
{
 $("#video").html("");
 var so = new SWFObject("http://accu.kt85.com/images/akkn/flash/CuPlayerMiniV20_Black_S.swf","CuPlayer","690","450","9","#000000");
so.addParam("allowfullscreen","true");
so.addParam("allowscriptaccess","always");
so.addParam("wmode","opaque");
so.addParam("quality","high");
so.addParam("salign","lt");
so.addVariable("CuPlayerFile",src);
so.addVariable("CuPlayerImage",img);
so.addVariable("CuPlayerShowImage","true");
so.addVariable("CuPlayerWidth","730");
so.addVariable("CuPlayerHeight","450");
so.addVariable("CuPlayerAutoPlay","false");
so.addVariable("CuPlayerAutoRepeat","false");
so.addVariable("CuPlayerShowControl","true");
so.addVariable("CuPlayerAutoHideControl","false");
so.addVariable("CuPlayerAutoHideTime","6");
so.addVariable("CuPlayerVolume","80");
so.write("video");
}