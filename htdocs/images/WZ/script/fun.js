/*背景自适应*/	
function bodyImgFun(){
	$('.scrollDiv').height($(window).height()-100);
	//Vertical_scrollFun();
	$('.indexDiv').height($(window).height());
	var winW=$(window).width();
	var winH=$(window).height();
	var pro=1.7;
	$('.bodyImg').width(winW);
	$('.bodyImg').height(winH);
	if(winW/winH>=pro){
		    $('.bodyImg').find('img').width(winW);
			$('.bodyImg').find('img').height(winW/pro);
			$('.bodyImg').scrollTop(($('.bodyImg').find('img').height()-$('.bodyImg').height())/2);
		}else{
			$('.bodyImg').find('img').height(winH);
			$('.bodyImg').find('img').width(winH*pro);
			$('.bodyImg').scrollLeft(($('.bodyImg').find('img').width()-$('.bodyImg').width())/2);
			}	
	}
//--	
function Vertical_scrollFun(){
	$(".Vertical_scroll").jscroll({ W:"8px"
	,BgUrl:"url(image/scrollBg.gif)"
	//,Bg:"#eee"
	,Bar:{  Bd:{Out:"#373737",Hover:"#373737"}
			,Bg:{Out:"-8px center repeat-y",Hover:"-8px center repeat-y",Focus:"-8px center repeat-y"}
			}
	,Btn:{  btn:false
			,uBg:{Out:"-0px center repeat-y",Hover:"-0px center repeat-y",Focus:"-0px center repeat-y"}
			,dBg:{Out:"none",Hover:"none",Focus:"none"}
			}
	,Fn:function(){}
	});
	}
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