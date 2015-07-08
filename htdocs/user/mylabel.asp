<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%
response.cachecontrol="no-cache"
response.addHeader "pragma","no-cache"
response.expires=-1
response.expiresAbsolute=now-1
Response.CharSet="utf-8"

'****************************************************
' Software name:Kesion CMS 8.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New mylabel
KSCls.Kesion()
Set KSCls = Nothing

Class mylabel
        Private KS, KSUser
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		
       Public Sub Kesion()
	   		   IF Cbool(KSUser.UserLoginChecked)=false Then
			  Response.Write "<script>top.location.href='Login';</script>"
			  Exit Sub
			End If
%>
	   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="/user/images/css.css" />
		<script src="../ks_inc/common.js" language="javascript"></script>
		<script src="../ks_inc/jquery.js" type="text/javascript"></script>
		<script src="../ks_inc/lhgdialog.js?skin=default"></script>
		<style type="text/css">
		.border td{color:888;}
		.inputs{padding:2px;color:#888;height:24px;line-height:24px;width:340px;}
		.labellist{}
		.labellist li{color:#fff;border:0px solid #FFCC00;padding:2px;margin-right:10px;margin-top:5px;float:left}
		.labellist li a{color:#fff;}
		</style>
		<script type="text/javascript">
		 function check(){
		   var mylabel=$("#mylabel").val();
		   if (mylabel=='多个标签之间请用空格隔开' || mylabel==''){
		     frameElement.api.opener.$.dialog.alert('请输入标签，多个标签用空格隔开!',function(){
			 $("#mylabel").focus();
			});
			return false;
		   }
		 }
		 
 jQuery(document).ready(function(){
	var tags = $(".labellist li");  
	for(i=0;i<tags.length;i++)
	{
		var str = "0123456789abcdef";
		var t = "#";
		for(j=0;j<6;j++)
		{t = t+ str.charAt(Math.random()*str.length);}
		tags[i].style.background=t; 
	}
})

		</script>
	    </head>
		<body>
             <br/>
			 <%
			 If request("action")="dosave" then
			  dim mylabel:mylabel=KS.S("mylabel")
			  if ks.isnul(mylabel) then 
			    ks.die "<script>frameElement.api.opener.$.dialog.tips('请输入标签!',1,'error.gif',function(){history.back();});</script>"
			  end if
			  mylabel=split(mylabel," ")
			  dim i,j,haslabel:haslabel=split(ksuser.getuserinfo("mylabel")&""," ")
			  dim newlabel
			  for i=0 to ubound(mylabel)
			       if len(mylabel(i))>8 then
			        ks.die "<script>frameElement.api.opener.$.dialog.tips('对不起，标签" & mylabel(i) & "字数太多，最多只能是8个字符!',1,'error.gif',function(){history.back();});</script>"
				   end if
			       dim findlabel:findlabel=false
			       for j=0 to ubound(haslabel)
				     if mylabel(i)=haslabel(j) then
					  findlabel=true
					  exit for
					 end if 
				   next
				   if findlabel=false then
				     if newlabel="" then
					    newlabel=mylabel(i)
					 else
					    newlabel=newlabel& " " & mylabel(i)
					 end if
				   end if
			  next
			  if not ks.isnul(ksuser.getuserinfo("mylabel")) then
			   newlabel=ksuser.getuserinfo("mylabel")&" " & newlabel
			  end if
			  if ubound(split(newlabel," "))>20 then
			        ks.die "<script>frameElement.api.opener.$.dialog.tips('对不起，最多只能添加20个标签!',1,'error.gif',function(){history.back();});</script>"
			  end if
			  conn.execute("update ks_user set mylabel='" & newlabel & "' where username='" & ksuser.username &"'")
			  session(KS.SiteSn&"userinfo")=""
			    ks.die "<script>frameElement.api.opener.$.dialog.confirm('标签添加成功，继续添加吗?',function(){location.href='mylabel.asp';},function(){top.location.reload();});</script>"
			 end if
			 
			 if request("tag")<>"" then
			    dim tag:tag=ks.s("tag")
				mylabel=split(ksuser.getuserinfo("mylabel")&""," ")
				newlabel=""
				for i=0 to ubound(mylabel)
				   if mylabel(i)<>tag then
				     if newlabel="" then
					   newlabel=mylabel(i)
					 else
					   newlabel=newlabel & " " & mylabel(i)
					 end if
				   end if
				next
			  conn.execute("update ks_user set mylabel='" & newlabel & "' where username='" & ksuser.username &"'")
			  session(KS.SiteSn&"userinfo")=""
			    ks.die "<script>location.href='mylabel.asp';</script>"
			 end if
			 %>
			 
		    <form name="myform" method="post" action="?action=dosave" >
                 <table width="96%"  border="0" align="center" cellpadding="0" cellspacing="1" class="border">
				    <%if not ks.isnul(ksuser.getuserinfo("mylabel")) then %>
					<tr>
					 <td colspan="2" height="90" valign="top">
					   <h2>我已经添加的标签：</h2>
					   
					   <div class="labellist">
					   <%
					   mylabel=split(ksuser.getuserinfo("mylabel")&""," ")
					   for i=0 to ubound(mylabel)
					     response.write "<li>" & mylabel(i) & "&nbsp;<a onclick=""return(confirm('确定删除该标签吗？'));"" href=""?tag=" & server.URLEncode(mylabel(i)) & """ title=""删除标签"">X</a></li>"
					   next
					   
					   %>
					   </div>
					 </td>
					 </tr>
					<%end if%>
						  <TR>
						   <td>
							 <h2>添加新标签：</h2><br/>
							<input name="mylabel" onblur="if(this.value==''){this.value='多个标签之间请用空格隔开';}" onfocus="if(this.value=='多个标签之间请用空格隔开'){this.value='';}" class="inputs" type="text" id="mylabel" value="多个标签之间请用空格隔开">                           
							<input type="submit" value="添加标签" onclick="return(check());" class="button" />
							</td>
			              </TR>
						
					<tr>
					 <td colspan="2" style="color:#999;padding-top:20px;">
						<strong>关于标签：</strong><br/>
						<li>·标签是自定义描述自己职业、兴趣爱好的关键词，让更多人找到你，让你找到更多同类。</li>
						<li>·在此查看你自己添加的所有标签，还可以方便地管理，最多可添加20个标签,每个标签不能超过8个字。 </li>
						<li>·点击你已添加的标签，可以搜索到有同样兴趣的人。</li>
					 </td>
					</tr>
				 </table>
              </form>
			

		   <%
		End Sub

End Class
%>

 
