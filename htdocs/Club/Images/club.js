//提示增加积分和威望,参数:bgdir 背景图路径,tipstr 提示信息,用逗号分开
function popShowMessage(tipstr){
 if(document.readyState=="complete"){ 
	if (tipstr==null || tipstr=='')return;
	$.dialog.tips('<div id="tipsmessage" style="font-size:14px;color:#ff6600;margin-top:12px;text-align:center">'+tipstr.split(',')[0]+'</div>',4,'face-smile.png',function(){}); 
	showtips(0,tipstr);
	}else{ 
  setTimeout(function(){popShowMessage(tipstr);},10); 
  }
}
function showtips(n,tipstr){
  var tipsarr=tipstr.split(',')
  $("#tipsmessage").html(tipsarr[n]);
  n++;
  if (n>tipsarr.length) {
  $("#mesWindowContent").slideToggle('fast'); return;
  }
  setTimeout(function () { showtips(n,tipstr); }, n==1?2200:1000);
}
var box='';
function mcategory(title,dir,boardid,topicid,categoryid){
	box=$.dialog({title:'更改主题归类',content:'url:../'+dir+'/ajax.asp?action=showchangecategory&boardid='+boardid+'&topicid='+ topicid+'&categoryid='+categoryid+'&title='+escape(title),width:'500px',height:'150px',min:false,max:false});
}
//投票
function doVote(dir,voteid,votetype){
 var VoteOption='';
 if (votetype=='Single'){
	VoteOption=$("input[@name=VoteOption]:checked").val(); 
 }else{
	 $("input[name=VoteOption]").each(function(){
					if ($(this).attr("checked")==true){if (VoteOption==''){VoteOption=$(this).val();}else{VoteOption+=","+$(this).val();}}
	});
 }
 if (VoteOption==undefined||VoteOption==''){$.dialog.alert('请选项择投票项!');return false;}
 	 $.get("../"+dir+"/ajax.asp",{action:"dovote",voteid:voteid,VoteOption:VoteOption},function(r){
		  var rstr=unescape(r);
		  if (rstr.substring(0,7)=='success'){$("#showvote").html(rstr.split('@@@')[1]);}else{$.dialog.alert(rstr); }
	});
}
function showVoteUser(dir,voteid){
	box=$.dialog({title:'查看投票详情',content:"url:../"+dir+"/showvoteuser.asp?voteid="+voteid,width:'330px',height:'360px',min:false,max:false});
}
function movetopic(dir,topicid,title){
	box=$.dialog({title:'帖子移动',content:"url:../"+dir+"/ajax.asp?action=showmovietopic&topicid="+ topicid+"&title="+escape(title),width:'530px',height:'150px',min:false,max:false});
}
 //发帖
function Posted(){
	box=$.dialog({title:'<img src="../user/images/icon11.png" align="absmiddle"> 快速选择版面发帖',content:'<div style="background:url(../user/images/loginbg.png) repeat-x;padding:5px;">版面导航<span id="navlist1"></span><span id="navlist2"></span><br/><div id="boardlist"><img src="../images/loading.gif" /></div></div>',width:'600px',height:'250px',min:false,max:false});
   $.get("../plus/ajaxs.asp",{action:"getclubboard",anticache:Math.floor(Math.random()*1000)},function(d){
    $("#boardlist").html(d);
   });
}
function checklength(cobj,cmax)
{   
    var star='';
    if (PresetPoint!=null){
	 for(var k=0;k<PresetPoint.length;k++){
		 if ($("#star"+k).val()!=''){
			 if (star==''){
				  star=$("#star"+k).val();
			 }else{
				  star+=' '+$("#star"+k).val();
			 }
		 }
	 }
	}
	if (cmax-cobj.value.length-star.length<0) {
	 cobj.value = cobj.value.substring(0,cmax);
	 $.dialog.alert("点评字数不能超过"+cmax+"个字符!");
	}
	else {
	 $('#cmax').html(cmax-cobj.value.length-star.length);
	}
}
//点评
function comments(dir,topicid,replayid,boardid,n,userId){
	box=$.dialog({title:'<img src="../user/images/icon11.png" align="absmiddle"> 点评',content:'<div style="background:url(../user/images/loginbg.png) repeat-x;padding:5px;"><div id="comts"></div><textarea name="comment" onkeydown="checklength(this,255);" onkeyup="checklength(this,255);" id="comment" cols="50" rows="4" style="border:1px solid #ccc;color:#666;width:450px;height:90px"></textarea><div style="margin-top:6px;margin-bottom:10px;">威望<select id="Prestige"><option value="-1">-1</option><option value="-2">-2</option><option value="0">0</option><option value="1" selected>+1</option><option value="2">+2</option></select>&nbsp;&nbsp;<input type="button" onclick="saveComments(\''+dir+'\','+topicid+','+replayid+','+boardid+','+n+','+userId+')" class="btn" value="发表"/> <span style="color:#999">Tips:您还可以输入<span id="cmax">255</span>个字符!</span></div></div>',width:'500px',height:'200px',min:false,max:false});
	$.ajax({type:"get",url:"../"+dir+"/ajax.asp?action=checkcomments&userId="+userId+"&n="+n+"&topicid="+topicid+"&id="+replayid+"&boardid="+boardid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
	    var rstr=unescape(d).split('|');
		if (rstr[0]=='success'){
			showPresetPoint(rstr[1]);
		}else{
			$.dialog.alert(rstr[1]);
			box.close();
		}
	}
  });
}
var startnum = 5;	//星的个数
var selectedcolor = "#ff6600";	//选上的颜色
var uselectedcolor = "#999999";//未选的颜色
var PresetPoint=null;
function setstar(k,index)
{
	for(var i=1;i<=index;i++){
		$("#s"+k+i)[0].style.color=selectedcolor;
		$("#s"+k+i)[0].style.cursor="hand";
	}
	for(var i=(index+1);i<=startnum;i++){
		$("#s"+k+i)[0].style.color=uselectedcolor;
		$("#s"+k+i)[0].style.cursor="hand";
	}
}
function clickstar(presetpoint,k,index)
{   
    $("#star"+k).val(presetpoint+'：<i>'+index+'</i>');
	checklength($("#comment")[0],255);
}
function showPresetPoint(s){
 if (s=='') return;
 var str='';
 PresetPoint=s.split(',');
 for (var k=0;k<PresetPoint.length;k++){
        str+=PresetPoint[k]+':<input type="hidden" name="star'+k+'" id="star'+k+'">';
	 for(var i=1;i<=startnum;i++){
			str+=('<span id="s'+k+i+'" style="color:#999;font-size:14px;" onclick="clickstar(\''+PresetPoint[k]+'\','+k+','+i+')" title="'+i+'星" onmouseout="setstar('+k+','+i+')" onmouseover="setstar('+k+','+i+')">★</span>');
		}
		str+="&nbsp;"
 }
  $("#comts").html(str);
}
function saveComments(dir,topicid,replayid,boardid,n,userId){
	var star='';
	var c=$("#comment").val();
	if(c==''){$.dialog.alert('请输入点评内容!');$("#comment").focus();return;}
	if (PresetPoint!=null){
	 for(k=0;k<PresetPoint.length;k++){
		 if ($("#star"+k).val()!=''){
			 if (star==''){
				  star=$("#star"+k).val();
			 }else{
				  star+=' '+$("#star"+k).val();
			 }
		 }
	 }
	}
	if (star!='') c=star+"<br/>"+c
 	$.get("../"+dir+"/ajax.asp",{action:"comments",n:n,userId:userId,Prestige:$("#Prestige option:selected").val(),comment:escape(c),topicid:topicid,boardid:boardid,id:replayid},function(r){
	    var rstr=unescape(r).split('|');
		if (rstr[0]=="success"){box.close();$("#comment_"+replayid).html(rstr[1]);}else{$.dialog.alert(rstr[1]);}
	 });
}
//点评翻页显示
function ShowCmtPage(dir,p,pid,boardid){
	$("#comment_"+pid).html("加载中...");
	$.ajax({type:"get",url:"../"+dir+"/ajax.asp?action=getcommentpage&p="+p+"&pid="+pid+"&boardid="+boardid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
			$("#comment_"+pid).html(d);																																																									   }
 });
}
//删除点评
function delCmt(dir,id,pid,boardid,p){
	if (confirm('删除后，不可恢复，确定删除吗？')){
	$.ajax({type:"get",url:"../"+dir+"/ajax.asp?action=delcomment&p="+p+"&id="+id+"&boardid="+boardid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
	  if (d=="success"){	
	    $.dialog.alert('恭喜，删除成功!');
		ShowCmtPage(dir,p,pid,boardid);	
	  }else
	    $.dialog.alert(d);
	  }
 });
	}
}

function TurnToFloor(dir,t,m,topicid){
	   var n=$('#tofloor').val();
	   if (n==''){$.dialog.alert('请输入楼层!',function(){$("#tofloor").focus();});return false;}
	   if (isNaN(n)){$.dialog.alert('跳转的楼层必须是有效数字!',function(){$("#tofloor").val('');});return false;}
	   if (n>t+1){alert('您输入的数字超过总楼层了，最高只有'+(t+1)+'层！');return false;}
	   if(window.location.href.toLowerCase().indexOf("display.asp") >=0){
        location.href=dir+"/display.asp?id=" +topicid + "&page=" + Math.ceil(n/m) +"#" +n;
       }else{
        location.href="/forumthread-"+topicid+"-"+Math.ceil(n/m)+".html#"+n;
       }
}


function loadBoard(v){
  if (v==''||v=='0') return;
  var str=$("#pid>option:selected").text();
   $("#navlist1").html("->"+str);
   $("#navlist2").html("");
  $.get("../plus/ajaxs.asp",{action:"getclubboard",pid:v},function(d){
    $("#boardlist").html(d);
   });
}
function toBoard(){
 var bid=$('#bid>option:selected').val();
 if (bid!='' && bid!=undefined)
 location.href='?boardid='+bid;
 else
  $.dialog.alert('请选择要进入的子版面!');
}
function toPost(){
 var bid=$('#bid option:selected').val();
 if (bid!='' && bid!=undefined)
  return true;
 else
  $.dialog.alert('请选择要进入发帖子版面!');
  return false
}

function popUserInfo(obj,n){
	jQuery('#user'+n).show();
	jQuery('#f'+n).html(obj.innerHTML);
}
function showPopUserInfo(n){
		jQuery('#user'+n).show();
}
function hidPopUserInfo(n){
	jQuery('#user'+n).hide();
}
var selectId='';
var bstr='';
function showmanage(c,v,dir,boardid){
	if (c){
		if (selectId==''){
		 selectId=v;
		}else{
		  var sarr=selectId.split(',');
		  var fv=false;
		  for(var i=0;i<sarr.length;i++){
			   if (sarr[i]==v){
				   fv=true;
				   break;}
		  }
		  if (fv==false){ selectId+=","+v;}
		}
	}else{
		var sarr=selectId.split(',');
		var nstr=''
		for(var i=0;i<sarr.length;i++){
			if (sarr[i]!=v){
				if (nstr==''){
					nstr=sarr[i]
				}else{
					nstr+=','+sarr[i];
				}
			}
		}
		selectId=nstr;
	}

	if (selectId.indexOf(',')==-1){
	box=$.dialog({title:"帖子批量管理",content:"<strong><label><input type='checkbox' id='checkall' onclick='checkall()'/>全选</label> 已选择帖子ID如下:</strong><span id='selids'>"+selectId+"</span><br /><br /><div><a href='javascript:void(0)' onclick=\"verifictopic(1,selectId,'"+dir+"',"+boardid+")\">批量审核主题</a> | <a href='javascript:void(0)' onclick=\"verifictopic(0,selectId,'"+dir+"',"+boardid+")\">批量取消审核</a> | <a href='javascript:void(0)' onclick=\"verifictopic(2,selectId,'"+dir+"',"+boardid+")\">批量锁定选中主题</a> | <a href='javascript:void(0)' onclick=\"delsubject(selectId,'"+dir+"',"+boardid+")\">批量删除主题</a><br/> <a href='javascript:void(0)' onclick=\"settop(selectId,'"+dir+"',"+boardid+",1)\">批量置顶主题</a> | <a href='javascript:void(0)' onclick=\"canceltop(selectId,'"+dir+"',"+boardid+")\">批量取消置顶</a> | <a href='javascript:void(0)' onclick=\"setbest(selectId,'"+dir+"',"+boardid+")\">批量设置精华</a> | <a href='javascript:void(0)' onclick=\"cancelbest(selectId,'"+dir+"',"+boardid+")\">批量取消精华</a><br/><br/><strong>将选中主题移动到版面</strong><br/><form name='moveform' action='../"+dir+"/ajax.asp' method='get' target='hidframe'><iframe name='hidframe' src='about:blank' width='0' height='0'></iframe></b><span id='showboardselect'></span><input type='submit' value='确定移动' class='btn'><input type='hidden' value="+selectId+" name='id' id='id'>&nbsp;<input type='hidden' value='movetopic' name='action'></form></div><br/>",width:'430px',height:'150px',min:false,max:false});
	}else{
		  $('#selids').html(selectId);
		  $('#id').val(selectId);
	}
	      if (bstr==''){
		  $.get("../plus/ajaxs.asp",{action:"GetClubBoardOption"},function(r){
		    $("#showboardselect").html(unescape(r));});
		  	      bstr=$("#showboardselect").html();
		  }else{
			  $("#showboardselect").html(bstr);
		  }
	      
	
	if (selectId==''){
		box.close();
	}
}
function checkall(){
	if ($("#checkall")[0].checked){
	selectId='';
	$(document).find("input[type=checkbox]").not("#checkall").each(function(){
           $(this).attr("checked",true);
	       if (selectId=='') {selectId=$(this).val()}else{selectId+=','+$(this).val();}
		   $("#selids").html(selectId);
																			});
	}else{
	$(document).find("input[type=checkbox]").not("#checkall").attr("checked",false);
	selectId='';
	closeWindow();
	}
}
function verifictopic(v,id,dir,boardid){
   	$.get("../"+dir+"/ajax.asp",{action:"verifictopic",v:v,id:id,boardid:boardid},function(r){
		if (r=="success"){switch(v){
			case 0 :$.dialog.alert('恭喜,对选中帖子取消审核的操作成功！');break;
		    case 1:	$.dialog.alert('恭喜,对选中帖子批量审核的操作成功！');break;
			case 2:	$.dialog.alert('恭喜,对选中帖子批量锁定的操作成功！');break;
		}
		location.reload();}else{alert(r);}
	});
}
function settop(id,dir,boardid,v){
	$.dialog.confirm('确定设为置顶吗？',function(){$.get("../"+dir+"/ajax.asp",{action:"settop",id:id,boardid:boardid,v:v},function(r){if (r=="success"){$.dialog.tips('恭喜,对选中主题置顶操作成功！',1,'success.gif',function(){this.reload();});}else{$.dialog.alert(r);}}); },function(){});
}
function canceltop(id,dir,boardid){
	$.dialog.confirm('确定取消置顶吗？',function(){$.get("../"+dir+"/ajax.asp",{action:"canceltop",id:id,boardid:boardid},function(r){if (r=="success"){$.dialog.tips('恭喜,对选中主题取消置顶操作成功！',1,'success.gif',function(){this.reload();});}else{$.dialog.alert(r);}
	});},function(){});
   	
}
function setbest(id,dir,boardid){
	$.dialog.confirm('确定设为精华帖吗？',function(){$.get("../"+dir+"/ajax.asp",{action:"setbest",id:id,boardid:boardid},function(r){if (r=="success"){$.dialog.tips('恭喜,对选中主题设为精华帖操作成功！',1,'success.gif',function(){this.reload()});}else{$.dialog.alert(r);}});},function(){});
}
function cancelbest(id,dir,boardid){
	$.dialog.confirm('确定取消精华帖吗？',function(){$.get("../"+dir+"/ajax.asp",{action:"cancelbest",id:id,boardid:boardid},function(r){if (r=="success"){$.dialog.tips('恭喜,对选中主题取消精华帖操作成功！',1,'success.gif',function(){this.reload();});}else{$.dialog.alert(r);}});},function(){});
}
function topicfav(id,dir,boardid){
	$.get("../"+dir+"/ajax.asp",{action:"fav",id:id,topicid:id,boardid:boardid},function(r){if (r=="success"){$.dialog.tips('恭喜,已收藏！',1,'success.gif',function(){});}else{$.dialog.alert(r);}});
}
function lockorunlock(flag,id,dir,boardid){$.get("../"+dir+"/ajax.asp",{flag:flag,action:"lockorunlock",id:id,topicid:id,boardid:boardid},function(r){
if (r=="success"){location.reload();}else{$.dialog.alert(r);}});}
function openorclose(flag,id,dir,boardid){$.get("../"+dir+"/ajax.asp",{flag:flag,action:"openorclose",id:id,topicid:id,boardid:boardid},function(r){
if (r=="success"){location.reload();}else{$.dialog.alert(r);}});}

function topicpush(topicid,dir,boardid,title){
	box=$.dialog({title:'主题帖子推送',content:'url:../'+dir+'/ajax.asp?action=showpushtopic&topicid='+ topicid+'&boardid='+boardid+'&title='+escape(title),width:'520px',height:'320px',min:false,max:false});
}
function getpushclass(modelid){
	 $.ajax({type:"get",url:"../plus/ajaxs.asp?action=GetClassOption&channelid="+modelid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
			$("#classid").empty().append(unescape(d));																																																									   }});
}
var f='';
function delsubject(id,dir,bid){
	if (box!=''){box.close();f='b';}
	box=$.dialog({title:'帖子删除提示',content:"<strong>删除选项：</strong><label><input type='hidden' value='"+id+"' id='did' name='did'/><input onclick=\"$('#oprzm').hide();\" type='radio' value='0' name='deltype' checked>放入回收站</label> <label><input type='radio' value='1' name='deltype' onclick=\"$('#oprzm').show();\">彻底删除</label><br/><div id='oprzm' style='display:none'><strong>认 证 码：</strong><input type='text' name='rzm' id='rzm'> <br/><font color='#999999'>tips:彻底删除需要输入认证码，认证码位于conn.asp里设定。 </font></div><br/><input type='submit' id='delbtn' value='确定删除' class='btn' onclick=\"dodelsubject('"+dir+"',"+bid+");\"><br/>",width:'430px',height:'150px',min:false,max:false});
}
function dodelsubject(dir,bid){
	var id=$("#did").val();
	var deltype=$("input[name=deltype]:checked").val();
	var rzm=$("#rzm").val();
	if (parseInt(deltype)==1 && rzm==''){
		 $.dialog.alert('彻底删除，请输入操作认证码!');
		 return;
	}
  if (parseInt(deltype)==1 && !(confirm('删除主题，所有的回复将删除，确定执行删除操作吗？'))){
	  closeWindow();
  }
  box.content('<div style=""text-align:center;font-size:14px;padding-top:10px;""><img align=left src=../ks_inc/skins/icons/alert.gif />正在执行删除操作，请稍候...</div>').title('删除操作');
 // $("#delbtn").attr("value","正在删除中...");
  //$("#delbtn").attr("disabled",true);
   $.get("../"+dir+"/ajax.asp",{action:"delsubject",id:id,boardid:bid,deltype:deltype,rzm:rzm},function(r){
  			if (r=="success"){$.dialog.tips('恭喜,删除成功!',2,'success.gif',function(){if (f=='b'){this.reload();}else{location.href='../'+dir+'/index.asp?boardid='+bid;}});}else{alert(r);$("#delbtn").attr("disabled",false);$("#delbtn").attr("value",'确定删除');$("#rzm").val('');}
  	});
}
function delreply(dir,topicid,replyid,boardid,n){
	box=$.dialog({title:'删除回复',content:"<strong>删除选项：</strong><label><input onclick=\"$('#oprzm').hide();\" type='radio' value='0' name='deltype' checked>放入回收站</label> <label><input type='radio' value='1' name='deltype' onclick=\"$('#oprzm').show();\">彻底删除</label><br/><div id='oprzm' style='display:none'><strong>认 证 码：</strong><input type='text' name='rzm' id='rzm'> <br/><font color='#999999'>tips:删除用户帖子操作需要输入认证码，认证码位于conn.asp里设定。 </font></div><br/><input type='submit' id='delbtn' value='确定删除' class='btn' onclick=\"dodelreply('"+dir+"',"+topicid+","+replyid+","+boardid+","+n+");\">",width:'430px',height:'150px',min:false,max:false});
}
function dodelreply(dir,topicid,replyid,boardid,n){
	var deltype=$("input[name=deltype][checked]").val();
	var rzm=$("#rzm").val();
	if (parseInt(deltype)==1 && rzm==''){
		 $,dialog.alert('彻底删除，请输入操作认证码!');
		 return;
	}
  box.content('<div style=""text-align:center;font-size:14px;padding-top:10px;""><img align=left src=../ks_inc/skins/icons/alert.gif />正在执行删除操作，请稍候...</div>').title('删除操作');

 // $("#delbtn").attr("value","正在删除中...");
//  $("#delbtn").attr("disabled",true);
  $.get("../"+dir+"/ajax.asp",{action:"delreply",deltype:deltype,id:topicid,replyid:replyid,boardid:boardid,rzm:escape(rzm)},function(r){
  			if (r=="success"){$.dialog.tips('恭喜,删除成功!',1,'success.gif',function(){box.close();$("#floor"+n).hide();});}else{$.dialog.alert(r);$("#delbtn").attr("disabled",false);$("#delbtn").attr("value",'确定删除');$("#rzm").val('');}
	});
}
function delusertopic(topicid,page,n,postusername,boardid,dir){
		  box=$.dialog({title:"删除用户[<font color=#ff6600>"+postusername+"</font>]的所有发帖",content:"<strong>时间限制：</strong><select id='deltime'><option value='0'>删除所有数据</option><option value='1'>一天内的数据</option><option value='2'>两天内的数据</option><option value='3' selected>三天内的数据</option><option value='7'>一周内的数据</option><option value='15'>两周内的数据</option><option value='30'>一个月内的数据</option><option value='90'>三个月内的数据</option><option value='180'>半年内的数据</option><option value='365'>一年内的数据</option><option value='730'>两年内的数据</option></select><br/><strong>删除选项：</strong><label><input onclick=\"$('#oprzm').hide();\" type='radio' value='0' name='deltype' checked>放入回收站</label> <label><input type='radio' value='1' name='deltype' onclick=\"$('#oprzm').show();\">彻底删除</label><br/><div id='oprzm' style='display:none'><strong>认 证 码：</strong><input type='text' name='rzm' id='rzm'> <br/><font color='#999999'>tips:删除用户帖子操作需要输入认证码，认证码位于conn.asp里设定。 </font></div><br/><input type='submit' id='delbtn' value='确定删除' class='btn' onclick=\"dodelusertopic('"+dir+"',"+topicid+","+page+","+n+",'"+postusername+"',"+boardid+");\"><br/>",width:'430px',height:'150px',min:false,max:false});
}
function dodelusertopic(dir,topicid,page,n,postusername,boardid){
	var deltype=$("input[name=deltype][checked]").val();
	var rzm=$("#rzm").val();
	var deltime=$("#deltime option:selected").val();
	if (parseInt(deltype)==1 && rzm==''){
		 $.dialog.alert('彻底删除，请输入操作认证码!');
		 return;
	}
  if (parseInt(deltype)==1 && !(confirm('删除主题，所有的回复将删除，确定执行删除操作吗？'))){
	  box.close();
  }
    box.content('<div style=""text-align:center;font-size:14px;padding-top:10px;""><img align=left src=../ks_inc/skins/icons/alert.gif />正在执行删除操作，请稍候...</div>').title('删除操作');

  $.get("../"+dir+"/ajax.asp",{action:"delusertopic",deltime:deltime,deltype:deltype,topicid:topicid,page:page,n:n,username:escape(postusername),boardid:boardid,rzm:escape(rzm)},function(r){
		 var rstr=r.split('|');
		 if (rstr[0]=="succ"){$.dialog.tips(rstr[1],1,'success.gif',function(){location.href=rstr[2];});}else{$.dialog.alert(rstr[1]);$("#delbtn").attr("disabled",false);$("#delbtn").attr("value",'确定删除');$("#rzm").val('');}
	});
}

function support(topicid,id,dir){$.get("../"+dir+"/ajax.asp",{action:"support",id:id,topicid:topicid},function(r){if (r=="error"){$.dialog.alert('您已投过票了!');}else{	$("#supportnum"+id).html(r);}});}
function opposition(topicid,id,dir){$.get("../"+dir+"/ajax.asp",{action:"opposition",id:id,topicid:topicid},function(r){if (r=="error"){$.dialog.alert('您已投过票了!');}else{	$("#oppositionnum"+id).html(r);}});}
function checkmsg()
 {   var message=escape($("#message").val());
	 var username=escape($("#username").val());
	 if (username==''){
		 $.dialog.tips('参数传递出错!',1,'error.gif',function(){box.close();});
		 return false;
	 }
	 if (message==''){
		 $.dialog.alert('请输入消息内容!',function(){$("#message").focus();});
		 return false;
	 }
	 $("#sendmsgbtn").attr("disabled",true);
	 $.get("../plus/ajaxs.asp",{action:"SendMsg",username:username,message:message},function(r){
			   r=unescape(r);
	             $("#sendmsgbtn").attr("disabled",false);
			   if (r!='success'){
		        $.dialog.alert(r,function(){});
			   }else{
				 $.dialog.tips('恭喜，您的消息已发送!',1,'success.gif',function(){box.close();});
			   }
			 });
 }
function sendMsg(ev,username){
	box=$.dialog({title:"<img src='../images/user/mail.gif' align='absmiddle'>发送消息",content:"<div style='padding:5px'>对方登录后可以看到您的消息(可输入255个字符)<br /><textarea name='message' id='message' style='width:330px;height:80px'></textarea><div style='text-align:center;margin:10px'><input type='button' id='sendmsgbtn' onclick='return(checkmsg())' value=' 确 定 ' class='btn'><input type='hidden' value="+username+" name='username' id='username'> <input type='button' value=' 取 消 ' onclick='box.close()' class='btn'></div></div>",width:'360px',height:'150px',min:false,max:false});
		  $.get("../plus/ajaxs.asp",{action:"CheckLogin"},function(r){
		   if (r!='true'){ShowLogin();}});
}
function check()
{
		 var message=escape($("#message").val());
		 var username=escape($("#username").val());
		 if (username==''){
			  $.dialog.tips('参数传递出错!',1,'error.gif',function(){box.close();});
			  return false;
		 }
		 if (message==''){
		   $.dialog.alert('请输入附言!',function(){$("#message").focus();});
		   return false;
		 }
		 $.get("../plus/ajaxs.asp",{action:"AddFriend",username:username,message:message},function(r){
		   r=unescape(r);
		   if (r!='success'){
			  $.dialog.tips(r,1,'error.gif',function(){box.close();});
		   }else{
			  $.dialog.tips('您的请求已发送,请等待对方的确认!',1,'success.gif',function(){box.close();});
		   }
		 });
}
function addF(ev,username)
{ 
		 show(ev,username);
		 var isMyFriend=false;
		 $.get("../plus/ajaxs.asp",{action:"CheckMyFriend",username:escape(username)},function(b){
		    if (b=='nologin'){
			  box.close();
			  ShowLogin();
			}else if (b=='true'){
			  $.dialog.alert('用户['+username+']已经是您的好友了！',function(){box.close();});
			  return false;
			 }else if(b=='verify'){
			  $.dialog.alert('您已邀请过['+username+'],请等待对方的认证!',function(){box.close();});
			  return false;
			 }else{
			 }
		 })
}
function show(ev,username){
	box=$.dialog({title:"<img src='../images/user/log/106.gif'>添加好友",content:"<div style='padding:5px'>通过对方验证才能成为好友(可输入255个字符)<br /><textarea name='message' id='message' style='width:330px;height:80px'></textarea><div style='text-align:center;margin:10px'><input type='button' onclick='return(check())' value=' 确 定 ' class='btn'><input type='hidden' value="+username+" name='username' id='username'> <input type='button' value=' 取 消 ' onclick='box.close()' class='btn'></div></div>",width:'430px',height:'150px',min:false,max:false});
}
function ShowLogin()
{ if(document.readyState=="complete"){ 
	  box=$.dialog({title:'<img src="../user/images/icon18.png" align="absmiddle">会员登录',content:'url:../user/userlogin.asp?Action=Poplogin',width:'430px',height:'204px',min:false,max:false});
}else{
		setTimeout(function(){ShowLogin();},10); 
	}
}
function ChkLogin(c){
  if ($('#username').val()==''||$("#username").val()=='UID/用户名/Email'){$.dialog.alert('登录用户名必须输入！',function(){$('#username').focus()});return false;}
  if ($('#password').val()==''){$.dialog.alert('登录密码必须输入！',function(){$('#password').focus()});return false;}
  if (c==1){if($('#Verifycode').val()==''){$.dialog.alert('请输入认证码！',function(){$('#Verifycode').focus();});return false;}}
  return true;
}
function checksearch()
{
     if ($("#keyword").val()==""){ $.dialog.alert('请输入搜索关键字!',function(){$('#keyword').focus();});
	  return false; }
}
/*
*兼容Ie && Firefox 的CopyToClipBoard
*
*/
function copyToClipBoard(txt) {
    if (window.clipboardData) {
        window.clipboardData.clearData();
        window.clipboardData.setData("Text", txt);
    } else if (navigator.userAgent.indexOf("Opera") != -1) {
    } else if (window.netscape) {
        try {
            netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
        } catch (e) {
            alert("被浏览器拒绝！\n请在浏览器地址栏输入'about:config'并回车\n然后将 'signed.applets.codebase_principal_support'设置为'true'");
        }
        var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
        if (!clip)   return;
        var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
        if (!trans) return;
        trans.addDataFlavor('text/unicode');
        var str = new Object();
        var len = new Object();
        var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
        var copytext = txt;
        str.data = copytext;
        trans.setTransferData("text/unicode", str, copytext.length * 2);
        var clipid = Components.interfaces.nsIClipboard;
        if (!clip)   return false;
        clip.setData(trans, null, clipid.kGlobalClipboard);
    }
    $.dialog.alert("你已经成功复制本地址，请直接粘贴推荐给你的朋友!");
}
function showOnlneList(){
	if ($("#onlineText").html()=='详细在线列表'){
		$("#onlineText").html('关闭在线列表');
		 $("#showOnline").fadeIn('slow');
		  $.get("../plus/ajaxs.asp",{action:"getonlinelist"},function(d){
			$("#showOnline").html(d);
			onlineList(1);
		   });
	}else{
		$("#onlineText").html('详细在线列表');
		$("#showOnline").fadeOut('fast');
	}
}
function onlineList(p){$.get("../plus/ajaxs.asp",{action:"getonlinelist",page:p},function(d){$("#showOnline").html(d);});}

function CopyCode(obj) {
	if (typeof obj != 'object') {
		if (document.all) {
			window.clipboardData.setData("Text",obj);
			$.dialog.tips('恭喜，复制成功!',2,'success.gif',function(){});
		} else {
			prompt('按Ctrl+C复制内容', obj);
		}
	} else if (document.all) {
		var js = document.body.createTextRange();
		js.moveToElementText(obj);
		js.select();
		js.execCommand("Copy");
		$.dialog.tips('恭喜，复制成功!',2,'success.gif',function(){});
	}
	return false;
}
function setCookie(name, value) {document.cookie = name + "=" + escape (value)}
function IndexDis(id,v){
	 setCookie("clubdis_"+id,v);
	 if ($("#img_"+id).attr("src").indexOf("close")!=-1)
	 $("#img_"+id).attr("src",$("#img_"+id).attr("src").replace("close","open"));
	 else
	 $("#img_"+id).attr("src",$("#img_"+id).attr("src").replace("open","close"));
	 $("#cate_"+id).toggle();
}
$(function(){initialLinkOpenType(1);});
function setNewWin(){
	 if ($("#setNewWin").attr("checked")){
		 setCookie("listNewWin", 1)
	}else{
		 setCookie("listNewWin", 0)
	}
	initialLinkOpenType(0);
}
function initialLinkOpenType(t){
	var listNewWin=getCookie("listNewWin");
	if (t==1){
	if (listNewWin==1){
		$("#setNewWin").attr("checked",true);
	}else{
		$("#setNewWin").attr("checked",false);
	}}
	 $(".topiclink").each(function(){
	  if (listNewWin==1){
	  $(this).attr("target","_blank");
	  }else{
	  $(this).attr("target","_parent");
	 }
	});
 }

/*内容页回复*/
function reply(id,user,time){  
	    var str="[quote]以下是引用 "+user +"在"+time+"的发言：[br]"+document.getElementById('content'+id).innerHTML+"[/quote]";
		Editor.writeEditorContents(str);
}