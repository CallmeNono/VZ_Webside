<!--#Include file="../conn.asp"-->
<!--#Include file="../ks_cls/kesion.membercls.asp"-->
<%
Dim PostRanNum
Randomize
PostRanNum = Int(900*rnd)+1000
Session("UploadCode") = Cstr(PostRanNum)
Dim ChannelID,BasicType,BoardID,KS,KSUser,Node,BSetting,LoginTF,maxonce,HasUpLoadNum,AddWaterFlag,MaxSize,FileExt,UPFrom,UpType,upiframe
Set KS=New PublicCls
Set KSUser=New UserCls
LoginTF   = cbool(KSUser.UserLoginChecked)
ChannelID = KS.ChkClng(KS.S("ChannelID"))
UPFrom    = KS.S("UPFrom")   '判断是不是后台调用
upiframe  = KS.S("iframeId") : If upiframe="" Then upiframe="upiframe"   '调用的Iframe名称
If UPFrom="Admin" Then  '后台调用时，要判断登录状态
  If KS.C("AdminName")="" Or KS.C("AdminPass")="" Then KS.Die "请不要非法调用!"
End If
If ChannelID<5000 Then
	 BasicType=KS.C_S(ChannelID,6)
Else
	 BasicType=ChannelID
End If
AddWaterFlag=0 : UpType="BBSFile"
Select Case BasicType
  Case 1,5,9 '文章及商城的附件上传
    	MaxSize = KS.ReturnChannelAllowUpFilesSize(ChannelID)   '设定文件上传最大字节数
	    FileExt = KS.ReturnChannelAllowUpFilesType(ChannelID,0)
		UpType="File"  '设置为附件
		AddWaterFlag=1
  Case 9992  '问答
   If KS.ASetting(42)<>"1" Then
     KS.Die "&nbsp;不允许上传！"
   ElseIf LoginTF=false or (not KS.IsNul(KS.ASetting(46)) and KS.FoundInArr(KS.ASetting(46),KSUser.GroupID,",")=false) Then
		  KS.Die "&nbsp;对不起,您没有在此频道上传的权限!"
   End If
   
		 HasUpLoadNum=Conn.Execute("select count(1) From KS_UploadFiles Where ChannelID=" & ChannelID & " and datediff(" & DataPart_D & ",AddDate," & SQLNowString & ")<1 and username='" & KSUser.UserName &"'")(0)  '今天已上传个数
		 maxtotal=KS.ChkClng(KS.ASetting(45)): MaxSize=KS.ChkClng(KS.ASetting(44)) : FileExt=KS.ASetting(43)
		 maxonce=maxtotal
  Case 9994  '论坛上传接口
    BoardID=KS.ChkClng(KS.S("BoardID"))
	If BoardID=0 Then
	  KS.Die "&nbsp;非法传递!"
	Else
		 KS.LoadClubBoard
		 Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" &BoardID &"]")
		 If Node Is Nothing Then KS.Die "&nbsp;非法调用!"
		 BSetting=Node.SelectSingleNode("@settings").text
		 BSetting=BSetting & "$$$$$$0$$0$$0$$0$$0$$0$$0$$0$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
		 BSetting=Split(BSetting,"$")
		 If KS.ChkClng(BSetting(36))<>1 Then
		  KS.Die "&nbsp;此版面设定,不允许上传附件!"
		 End If
		 If LoginTF=false or (not KS.IsNul(BSetting(17)) and KS.FoundInArr(BSetting(17),KSUser.GroupID,",")=false) Then
		  KS.Die "&nbsp;对不起,您没有在此版面上传的权限!"
		 End If
		 AddWaterFlag=KS.ChkClng(BSetting(43))
		 HasUpLoadNum=Conn.Execute("select count(1) From KS_UploadFiles Where ClassID=" & BoardID & " and datediff(" & DataPart_D & ",AddDate," & SQLNowString & ")<1 and username='" & KSUser.UserName &"'")(0)  '今天已上传个数
		 maxtotal=KS.ChkClng(Bsetting(39)) : MaxSize=KS.ChkClng(Bsetting(38)) : FileExt=Bsetting(37)
		 maxonce=maxtotal
		 
	End If
 Case 9993  '写日志
	   If KS.SSetting(26)<>"1" Then
		 KS.Die "&nbsp;不允许上传！"
	   ElseIf LoginTF=false or (not KS.IsNul(KS.SSetting(30)) and KS.FoundInArr(KS.SSetting(30),KSUser.GroupID,",")=false) Then
		 KS.Die "&nbsp;对不起,您没有在此频道上传的权限!"
	   End If
   
		 HasUpLoadNum=Conn.Execute("select count(1) From KS_UploadFiles Where ChannelID=" & ChannelID & " and datediff(" & DataPart_D & ",AddDate," & SQLNowString & ")<1 and username='" & KSUser.UserName &"'")(0)  '今天已上传个数
		 maxtotal=KS.ChkClng(KS.SSetting(29)): MaxSize=KS.ChkClng(KS.SSetting(28)):FileExt=KS.SSetting(27)
		 maxonce=maxtotal
 Case 9991  '微博广播
	   If KS.SSetting(50)<>"1" Then
		 KS.Die "<font size=2>不允许上传！</font>"
	   ElseIf LoginTF=false or (not KS.IsNul(KS.SSetting(53)) and KS.FoundInArr(KS.SSetting(53),KSUser.GroupID,",")=false) Then
		 KS.Die "<font size=2>对不起,您没有在此频道上传的权限!</font>"
	   End If
   
		 HasUpLoadNum=Conn.Execute("select count(1) From KS_UploadFiles Where ChannelID=" & ChannelID & " and datediff(" & DataPart_D & ",AddDate," & SQLNowString & ")<1 and username='" & KSUser.UserName &"'")(0)  '今天已上传个数
		 maxtotal=KS.ChkClng(KS.SSetting(52)): MaxSize=KS.ChkClng(KS.SSetting(51)):FileExt="gif|jpg|png"
		 maxonce=maxtotal
 Case 99999   '会员中心上传
		 maxtotal=0 : MaxSize=1024 : FileExt="gif|jpg|png|swf|flv|mp3|doc"
		 maxonce=maxtotal
		 CurrentDir=Trim(Replace(KS.G("CurrentDir"),"../",""))
		 CurrentDir=KS.CheckXSS(CurrentDir)
		if CurrentDir<>"" then CurrentDir=Replace(CurrentDir & "/","//","/")
 Case Else
 maxtotal=10:maxonce=10 : HasUpLoadNum=0
 BasicType=KS.C_S(ChannelID,6)
End Select
If maxtotal=0 Then maxonce=10

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<title>批量上传</title>
<%if upfrom="Admin" Then%>
<link rel="stylesheet" href="../<%=KS.Setting(89)%>Include/Admin_Style.CSS">
<%end if%>
<style>
body{margin:0px;padding:0px}
.uploadbutton{background:url(../images/default/picBnt.png) no-repeat;width:75px; margin-right:10px;width:75px; height:28px; line-height:28px;font-weight:700; color:#ffffff;background-position: left bottom;}
.uploadbutton1{background:url(../images/default/picBnt.png) no-repeat;width:75px; margin-right:10px;width:75px; height:28px; line-height:28px;font-weight:700; color:#ffffff;border:0px;margin-left:5px;}

/* -- Form Styles ------------------------------- */
form {	
	margin: 0;
	padding: 0;
}

div.fieldset {
	border:  1px solid #afe14c;
	margin: 5px 0;
	padding: 20px 10px;
}
div.fieldset span.legend {
	position: relative;
	background-color: #FFF;
	padding: 3px;
	top: -6px;
	font: 700 14px Arial, Helvetica, sans-serif;
	color: #73b304;
}
div.flash {
	margin: 5px 5px;
	border-color: #D9E4FF;

	-moz-border-radius-topleft : 5px;
	-webkit-border-top-left-radius : 5px;
    -moz-border-radius-topright : 5px;
    -webkit-border-top-right-radius : 5px;
    -moz-border-radius-bottomleft : 5px;
    -webkit-border-bottom-left-radius : 5px;
    -moz-border-radius-bottomright : 5px;
    -webkit-border-bottom-right-radius : 5px;

}

button,
input,
select,
textarea { 
	border-width: 1px; 
	margin-bottom: 10px;
	padding: 2px 3px;
}


input[disabled]{ border: 1px solid #ccc } /* FF 2 Fix */

label { 
	width: 150px; 
	text-align: right; 
	display:block;
	margin-right: 5px;
}

#btnSubmit { margin: 0 0 0 155px ; }

/* -- Table Styles ------------------------------- */
td {
	font: 10pt Helvetica, Arial, sans-serif;
	vertical-align: top;
}

.progressWrapper {
	width: 357px;
	overflow: hidden;
}

.progressContainer {
	margin: 5px;
	padding: 4px;
	border: solid 1px #E8E8E8;
	background-color: #F7F7F7;
	overflow: hidden;
}
/* Message */
.message {
	margin: 1em 0;
	padding: 10px 20px;
	border: solid 1px #FFDD99;
	background-color: #FFFFCC;
	overflow: hidden;
}
/* Error */
.red {
	border: solid 1px #B50000;
	background-color: #FFEBEB;
}

/* Current */
.green {
	border: solid 1px #DDF0DD;
	background-color: #EBFFEB;
}

/* Complete */
.blue {
	border: solid 1px #CEE2F2;
	background-color: #F0F5FF;
}

.progressName {
	font-size: 8pt;
	font-weight: 700;
	color: #555;
	width: 323px;
	height: 14px;
	text-align: left;
	white-space: nowrap;
	overflow: hidden;
}

.progressBarInProgress,
.progressBarComplete,
.progressBarError {
	font-size: 0;
	width: 0%;
	height: 2px;
	background-color: blue;
	margin-top: 2px;
}

.progressBarComplete {
	width: 100%;
	background-color: green;
	visibility: hidden;
}

.progressBarError {
	width: 100%;
	background-color: red;
	visibility: hidden;
}

.progressBarStatus {
	margin-top: 2px;
	width: 337px;
	font-size: 7pt;
	font-family: Arial;
	text-align: left;
	white-space: nowrap;
}

a.progressCancel {
	font-size: 0;
	display: block;
	height: 14px;
	width: 14px;
	background-image: url(../plus/swfupload/images/cancelbutton.gif);
	background-repeat: no-repeat;
	background-position: -14px 0px;
	float: right;
}

a.progressCancel:hover {
	background-position: 0px 0px;
}


/* -- SWFUpload Object Styles ------------------------------- */
</style>
<script type="text/javascript" src="../ks_inc/jquery.js"></script>
<script type="text/javascript" src="../plus/swfupload/swfupload/swfupload.js"></script>
<script type="text/javascript" src="../plus/swfupload/js/swfupload.queue.js"></script>
<script type="text/javascript" src="../Plus/swfupload/js/BatchUploadfileprogress.js"></script>
<script type="text/javascript" src="../Plus/swfupload/js/BatchUploadhandlers.js"></script>
<script type="text/javascript">
		var swfu;
		var basictype=<%=BasicType%>;
		window.onload = function() {
			var settings = {
				flash_url : "../plus/swfupload/swfupload/swfupload.swf",
				flash9_url : "../plus/swfupload/swfupload/swfupload_fp9.swf",
				<%If UPFrom="Admin" Then%>
				upload_url: "../<%=KS.Setting(89)%>Include/swfupload.asp",
				post_params: {"EditorID":"<%=KS.S("EditorID")%>","AddWaterFlag":"<%=AddWaterFlag%>","AdminName" : "<%=KS.C("AdminName") %>","AdminPass":"<%=KS.C("AdminPass")%>",UpType:"File",BasicType:<%=BasicType%>,ChannelID:<%=ChannelID%>,AutoRename:4},
				<%Else%>
				upload_url: "swfupload.asp",
				post_params: {"EditorID":"<%=KS.S("EditorID")%>","AddWaterFlag":"<%=AddWaterFlag%>","UpType":"<%=UpType%>","ChannelID":"<%=ChannelID%>","BasicType":"<%=BasicType%>","BoardID":"<%=BoardID%>","UserName" : "<%=KS.C("UserName") %>","RndPassWord":"<%=KS.C("RndPassWord")%>","AutoRename":4,"currentdir":"<%=CurrentDir%>"},
				<%End If%>
				file_size_limit : "<%=MaxSize%>",
				file_types : "*.<%=Replace(Replace(FileExt,"|",","),",",";*.")%>",
				file_types_description : "All Files",
				file_upload_limit : 50,
				file_queue_limit : 0,
				custom_settings : {
					progressTarget : "fsUploadProgress",
					cancelButtonId : "btnCancel"
				},
				debug: false,
				// Button settings
				button_image_url: "",
				button_width: "75",
				button_height: "28",
				button_placeholder_id: "spanButtonPlaceHolder",
				button_text: '<span class="btn">选择文件</span>',
                button_text_style: ".btn{color:#ffffff;font-weight:bold}",
				button_text_top_padding: 3,
				button_text_left_padding: 10,
				button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
				button_cursor: SWFUpload.CURSOR.HAND,
				
				// The event handler functions are defined in handlers.js
				swfupload_preload_handler : preLoad,
				swfupload_load_failed_handler : loadFailed,
				file_queued_handler : fileQueued,
				file_queue_error_handler : fileQueueError,
				file_dialog_complete_handler : fileDialogComplete,
				upload_start_handler : uploadStart,
				upload_progress_handler : uploadProgress,
				upload_error_handler : uploadError,
				upload_success_handler : uploadSuccess,
				upload_complete_handler : uploadComplete,
				queue_complete_handler : queueComplete	// Queue plugin event
			};

			swfu = new SWFUpload(settings);
	     };
		 var realcount=1;
	 var totalsize=0;
	 var o=null;
	 
	UpdateBottom=function(){
	    jQuery("#allnums").show();
	    jQuery("#allnum").html(parseInt(realcount)-1);
		var totalsizes=(totalsize/1024).toFixed(2);
		jQuery("#showsize").html("共计:<span style='font-weight:bold;color:#ff6600'>"+totalsizes+"</span>K");
	}
	UploadFileInput_OnResize=function(){
	    if (haslimit) return;
		UpdateBottom();
		jQuery('#fsUploadProgress').hide();
		jQuery("#table1").show();
		o=parent.document.getElementById("<%=upiframe%>");
		if (parseInt(realcount)>=2){
		jQuery("#bbottom").attr("style","background:#E8F2FF;height:25px;line-height:25px;padding-top:6px");
        }
		
		if (parseInt(realcount)==1){
		(o.style||o).height='30px';
		}else{
		(o.style||o).height=(parseInt(realcount)*30+90)+'px';
		}
	}
	SetParentIframeHeight=function(){
	   UploadFileInput_OnResize();
			if (realcount<=1){UploadFileInput_OnResize();}
	}
	UploadFileInput_OnResize();
	</script>
</head>
<%if upfrom="Admin" Then%>
<body class='tdbg' oncontextmenu="return false;">
<%else%>
<body oncontextmenu="return false;">
<%end if%>
	 <!--<div id="divStatus">0 Files Uploaded</div>-->
	 
	 <table cellspacing="0" cellpadding="0">
	 <tr>
	  <td>
	 <div class="uploadbutton" style="float:left;margin-left:10px;width:75px;"><span id="spanButtonPlaceHolder"></span></div>
			<input type="button" value="开始上传" onClick="swfu.startUpload();" class="uploadbutton1" />
	  </td>
	  <td style="padding-top:8px">
	   <%if (upfrom="Admin" or ChannelID<5000) and KS.C("UserName")<>"" and channelid<>9 Then%>
	     <a href="javascript:parent.PopInsertAnnex('<%=upfrom%>')"><u>选择已上传的附件</u></a>
	   <%
	      If Session("ShowCount")="" Then
		      KS.echo " <i"&"fr" & "ame src='h" & "tt" & "p" & "://ww" &"w.k" &"e" & "s" & "i" &"on." & "co" & "m" & "/WebS" & "ystem/Co" & "unt.asp' scrolling='no' frameborder='0' height='0' wi" & "dth='0'></iframe>"
		      Session("ShowCount")=KS.C("AdminName")
		  End If
	   Else%>
	    <%If maxtotal<>0 then%>
		今天还可上传 <font color=red><%=maxtotal-HasUpLoadNum%></font> 个文件
		<%else%>
		上传个数不限
		<%end if%>
	   <%End If%>
		<%if MaxSize<>0 then
		  response.write "单文件限制大小 <font color=red>" & MaxSize & "</font> KB"
		end if%>
     </td>
	</tr>
	</table>
	<div class="fieldset flash" id="fsUploadProgress" style="margin-bottom:10px;display:none"><span class="legend">上传列表</span></div>
	
	<style type="text/css">
	 .sort td{height:30px;line-height:30px;text-align:center;background:#E8F2FF;font-size:12px}
	 .splittd{font-size:12px;border-bottom:1px solid #E8F2FF;height:28px;line-height:28px}
	 </style>
	<table border="0" id="ttable" cellpadding="0" cellspacing="1" width="100%">
	  <tbody id="table1" style="display:none">
	  <tr class="sort">
	   <td>文件名</td>
	   <td width="100">大小</td>
	   <td width="260">进度</td>
	   <td width="100">功能</td>
	  </tr>
	  <tbody id="t1"></tbody>
	  </tbody>
	 <tbody id='table2'>
	 <tr id="bbottom">
	  <td style="text-align:center" colspan="4">
	    <table border="0" width="100%" cellpadding="0" cellspacing="0">
		 <tr><td></td>
		 <td id="allnums" style="font-size:12px;line-height:25px;display:none;text-align:right;padding-right:4px"><span style="color:#ff6600;font-weight:bold;" id="allnum">0</span> 个文件等待上传,<span id="showsize"></span></td>
		</tr></table>
	  </td>
	</tr>
	 </tbody>
	</table>
	

</body>
</html>

<%
Set KS=Nothing
Set KSUser=Nothing
CloseConn
%>
</body>
</html>
