<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New SetTemplate
KSCls.Kesion()
Set KSCls = Nothing

Class SetTemplate
        Private KS,KSUser
		Private TempStr,SqlStr,TemplateID,BlogName
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		
	   Sub Kesion
	   IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		Dim RS:Set RS=Conn.Execute("Select top 1 TemplateID,BlogName From KS_Blog Where UserName='" & KSUser.UserName & "'")
		If RS.Eof And RS.Bof Then
		  RS.Close:Set RS=Nothing
		  Response.Write "<script>location.href='User_Blog.asp?Action=BlogEdit';</script>"
		  response.end
		End If
		TemplateID=RS(0) : BlogName=RS(1)
		RS.Close : Set RS=Nothing
       %>
		<html>
	   <head>
	    <title>空间风格DIY 当前站点：<%=BlogName%></title>
		<meta http-equiv=Content-Type content="text/html; charset=utf-8">
		<script src="../ks_inc/jquery.js" type="text/javascript"></script>
		<script src="../ks_inc/common.js" type="text/javascript"></script>
	   <style type="text/css">
		body{
			margin:0;
			color:#000;font:12px Verdana,Arial,Helvetica,sans-serif;
		}
		td{font:12px Verdana,Arial,Helvetica,sans-serif;}
        form,h1,ul,li{margin:0px;padding:0px;list-style-type:none}
		a {color:#555; padding:0px; text-decoration:none;blr:expression(this.onFocus=this.blur())}
		a:link {
			background: none transparent scroll repeat 0% 0%;color:#555;
		}
		a:hover {
			color: #ff0000; text-decoration: underline
		}
		.diytitle{height:30px;background:url(images/skinBg.png) 0px -40px;font-size:14px;padding-left:30px;font-weight:bold;padding-top:4px;cursor: move;}
		.diytitle span{font-size:12px;font-weight:normal;color:#999;float:right;padding-right:20px}
		
/* TABS模块 */
.tabs{height:35px; margin-bottom:5px;background:#fff;border-bottom:#CCC 1px solid;width:100%}
.tabs ul{ margin-top:3px;margin-left:2px; display:inline; float:left; position:relative; bottom:-1px;}
.tabs li{margin-left:1px;width:116px;height:32px;line-height:32px; color:#2C602F; padding:0 1px; background:url(images/t2.gif) no-repeat; cursor:pointer; float:left;text-align:center;}
.tabs li a{font-size:12px;font-weight:bold;}

.tabs li.select{line-height:32px;  background:url(images/t1.gif) no-repeat;width:116px;height:32px; cursor:auto;}
.tplist{padding-left:30px;}
.tplist li{position:relative;list-style-type:none;width:155px;float:left;}
.tplist li a{cursor:pointer;display:block;width:128px;border:1px solid #efefef;padding:2px}
.tplist li a:hover{border:1px solid #ff6600;filter:alpha(opacity=60);}
.tplist li div{background:#000;color:#fff;width:125px;border:1px solid #cccccc}
.tplist .vip{background:url(images/skinbg.png) -20px 23px;display:block;width:20px;height:20px;position:absolute;z-index:21;top:0px;right:0px}
.tplist .page{text-align:right;padding-right:30px;padding-bottom:2px}
.tplist .page a{font-size:14px;font-weight:bold}

/*DIY*/
#c1{}
#c1 h1{padding-left:10px;font-size:14px;font-weight:bold}
#c1 h1 span{color:#ff6600}
#c1 .photoname{height:130px;overflow:auto;width:240px}
#c1 .photoname li{text-align:center;width:100px;float:left;border:1px dashed #ccc;height:30px;line-height:30px;margin:2px}
.redborder a{color:red;}

#Layer1 {
	position:absolute;
	width:98%;
	height:225px;
	z-index:1;
	background:#fff;
	top:0px;
	border:1px solid #000;
	border-bottom:5px solid #999;
}	

/*按钮*/
button::-moz-focus-inner{border:0;padding:0;}
.pn{margin-right:3px;padding:0 20px;height:30px;border:1px solid #CFCFCF;-moz-border-radius:30px;-webkit-border-radius:30px;border-radius:30px;z-index:0;background:url(images/pnp.png) no-repeat 50% -41px;color:#666;line-height:30px;font-size:14px;vertical-align:middle;cursor:pointer;position:relative\9;padding:0 0 0 20px\9;border:none\9;background:url(images/pnp.png) no-repeat 0 0\9;overflow:visible\9;}
@media screen and (-webkit-min-device-pixel-ratio:0){.pn{font-family:"Microsoft YaHei","Hiragino Sans GB",STHeiti,SimHei,sans-serif;}}
.pn *{position:relative\9;display:block\9;padding-right:20px\9;*height:30px\9;background:url(images/pnp.png) no-repeat 100% -40px\9;*line-height:30px\9;white-space:nowrap\9;font-weight:700;text-shadow:1px 1px 1px #EEE;}
.pn strong{padding-left:2px;letter-spacing:2px;font-weight:normal}

.pnc{color:#FFF;border-color:#10297B;background-position:50% -281px;background-position:0 -240px\9;}
.pnc *{background-position:100% -280px\9;text-shadow:1px 1px 1px #10297B;}
.pnp{background-position:50% -121px;background-position:0 -80px\9;border-color:#F0F3E6;}
.pnp *{background-position:100% -120px\9;text-shadow:1px 1px 1px #F0F3E6;}
	
.clear{height:1px;overflow:hidden;clear:both}
.hid{display:none}
</style>
	   </head>
	 <body scroll="no">
	   <script type="text/javascript">
	    var templateid=0;
	    $(document).ready(function(){
		  getTemplate(1);
		  $("#tplist").find("a").click(function(){
		    $("#tplist").find("a").attr("style","");
		    $(this).attr("style","border:1px solid #ff3300;background:#ff6600");
		  });
		  $(".tabs").find("li").click(function(){
		    $(".tabs").find("li").removeClass("select");
			$(this).addClass("select");
			for(var i=0;i<$(".tabs").find("li").length;i++){
			 if (i==$(".tabs").find("li").index(this))
			 $("#c"+i).show();
			 else
			 $("#c"+i).hide();
			}
		  });
		});
	    function getTemplate(page){
		  $.ajax({type:"get",async:false,url:"userajax.asp?page="+page+"&action=SpaceTemplate&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
		  
		  $("#tplist").html(d);	
	 }});}
	    function setTemplate(id){
		 templateid=id;
		 $("#viewframe").attr("src","../space/?<%=KS.C("userid")%>&"+id);
		}
		function closeDiy(){
		 if (templateid!=0){
			 if (confirm('自定义风格窗口将关闭，是否保存当然预览!')){
			  saveTemplate();
			 }
		  }else{
		   location.href='../space/?<%=KS.C("userid")%>';
		  }
		  
		}
		function saveTemplate(){
		 if (parseInt(templateid)!=0){
		  $.ajax({type:"get",async:false,url:"userajax.asp?templateid="+templateid+"&action=SaveSpaceTemplate&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
		   if (d!='success'){
		     alert(unescape(d))
		    }else{
			 if (!confirm('恭喜，当前模板已保存,是否继续修改?')){
			 location.href='../space/?<%=KS.C("userid")%>';
			  }
			}
		  }});
		 }else{
		  alert('您还没有选择模板风格哦!!!');
		 }
		}
		function loadDiy(){
		 $.ajax({type:"get",async:false,url:"userajax.asp?action=loadTemplateDiy&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
		    $("#c1").html(unescape(d));
		  }});
		}
		function updatePhoto(photoid){
		 $.ajax({type:"get",async:false,url:"userajax.asp?action=upPhoto&photoid=" +photoid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
		    $("#uphtml").html(unescape(d));
			setTimeout(function(){$("#UpPhotoFrame").attr('src','User_UpFile.asp?fieldname=PhotoUrl&type=Pic&ChannelID=8000&MaxFileSize=500&ext=*.jpg;*.gif;*.png');},10);
		  }});
		}
		function savePhoto(pu,lu,orderid,templateid){
		 var photourl=$("#PhotoUrl").val();
		 var linkurl=$("#LinkUrl").val();
		 if (photourl==''){
		  alert('您还没有上传图片哦!');
		  $("#PhotoUrl").focus();
		  return false;
		 }else if(photourl==pu && linkurl==lu){
		  alert('没有更换图片，不需要保存!');
		  return false;
		 }
		 $.ajax({type:"get",async:false,url:"userajax.asp?action=saveTemplatePhoto&photourl="+photourl+"&linkurl="+linkurl+"&templateid="+templateid+"&orderid=" +orderid+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
		    if (d=="success"){
		     loadDiy();
			 alert('恭喜，图片更新成功!');
			 frames["viewframe"].location.reload();
			}else{
		    alert(unescape(d));
			}
		  }});
		}
		function delPhoto(id){
		 if (confirm("确定删除该图片，还原为默认的吗？")){
		    $.ajax({type:"get",async:false,url:"userajax.asp?action=delTemplatePhoto&id="+id+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
			  if (d=="success"){
			   alert('恭喜，成功删除自定义图片!');
			   loadDiy();
			   frames["viewframe"].location.reload();
			  }else{
			   alert(unescape(d));
			  }
			 }});
		 }
		}
	   </script>
	   
	   <SCRIPT LANGUAGE="JavaScript">
		<!--
		//定义函数divMove
		function divMove(divObj)
		{
		 with (this)
		 {
		  if (!divObj) return;
		  this.hasDraged = false;
		  this.dragObj = divObj;
		  // 把鼠标的形状改成移动形
		  dragObj.style.cursor = "move";
		  // 定义鼠标按下时的操作
		  dragObj.onmousedown = function()  {
		   var ofs = Offset(dragObj);
		   dragObj.style.position = "absolute";
		   dragObj.style.left = ofs.l;
		   dragObj.style.top = ofs.t;
		   dragObj.X = event.clientX - ofs.l;
		   dragObj.Y = event.clientY - ofs.t;
		   hasDraged = true;
		  };
		
		  // 定义鼠标移动时的操作
		  dragObj.onmousemove = function()
		  {
		   if (!hasDraged) return;
		   dragObj.setCapture();
		   dragObj.style.left = event.clientX - dragObj.X;
		   dragObj.style.top = event.clientY - dragObj.Y;
		  };
		  // 定义鼠标提起时的操作
		  dragObj.onmouseup = function()
		  {
		   hasDraged = false;
		   dragObj.releaseCapture();
		  };
		  function Offset(e)
		  {
		   var t = e.offsetTop;
		   var l = e.offsetLeft;
		   var w = e.offsetWidth;
		   var h = e.offsetHeight;
		   while(e=e.offsetParent)
		   {
			t+=e.offsetTop;
			l+=e.offsetLeft;
		   }
		   return { t:t, l:l, w:w, h:h }
		  };
		 }
		};
		
		//-->
		</SCRIPT>
	   
	   <div id="Layer1">
		   <div class="diytitle"  onMouseDown="divMove($('#Layer1')[0]);">
		   	<span><script>if (document.all){
			 document.write('可以将鼠标移到这里，然后按住鼠标移动，查看被挡住的区域');
			 }</script> <label style="cursor:pointer" onClick="closeDiy()"><img src="../images/default/close.gif" align="absmiddle" /><strong>关闭</strong></label></span>

		   空间风格DIY
		   </div>
			<div class="tabs">	
			  <ul>
				 <li class="select"><a href="#">选择风格</a></li>
				 <li><a href="#" onClick="loadDiy()">自定义装扮</a></li>
			 </ul>
			</div>
			
			<div id="contentlist">
				<div class="tplist" id="c0">
				  <ul id="tplist">
					  loading...
				  </ul>
				  <div style="margin-top:0px;padding-top:3px;padding-bottom:4px;padding-left:30px;border-top:1px dashed #ccc">
					 <button type="button" class="pn pnc" onClick="saveTemplate()"><strong> 保 存 </strong></button>
					 <button type="button" class="pn pnc" onClick="closeDiy()"><strong> 取 消 </strong></button>
					</div>
				  
				</div>
				<div id="c1" class="hid">
				   loading...
				</div>
			</div>
			
			
	   </div>
	   <iframe name="viewframe" id="viewframe" src="../space/?<%=ks.c("userid")%>" height="100%" width="100%"></iframe>
	   </body>
	   </html>
	   <%
       End Sub
  
End Class
%> 
