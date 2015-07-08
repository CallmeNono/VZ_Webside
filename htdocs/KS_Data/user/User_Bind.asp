<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../API/cls_api.asp"-->
<%

'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************

Dim KSCls
Set KSCls = New User_Bind
KSCls.Kesion()
Set KSCls = Nothing

Class User_Bind
        Private KS,KSUser
		Private CurrentPage,totalPut,TotalPages,SQL
		Private RS,MaxPerPage
		Private TempStr,SqlStr
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/UserFunction.asp"-->
		<%
		Public Sub loadMain()	
			IF Cbool(KSUser.UserLoginChecked)=false Then
			  Response.Write "<script>top.location.href='Login';</script>"
			  Exit Sub
			End If
			Call KSUser.Head()
			Call KSUser.InnerLocation("帐号通设置")
			Select Case KS.S("Action")
			  Case "dosave" dosave
			  Case "delbind" delbind
			  Case Else Main
			End Select
	   End Sub	

'解除绑定	   
Sub delbind()
  Select Case KS.ChkClng(Request("v"))
    case 1:conn.execute("update ks_user set qqopenid='',qqtoken='' where username='" & KSUser.UserName&"'")
    case 2:conn.execute("update ks_user set sinaid='',sinatoken='' where username='" & KSUser.UserName&"'")
    case 3:conn.execute("update ks_user set alipayid='' where username='" & KSUser.UserName&"'")
  End Select
  Session(KS.SiteSN&"UserInfo")=""
  KS.Die "<script>$.dialog.tips('恭喜，解除绑定成功!',1,'success.gif',function(){location.href='user_bind.asp';});</script>"
End Sub
	 
Sub Main()
%>
	 <br/>
	 <style type="text/css">
	 label{color:#999999}
	 </style>
	 
	 <div class="tabs">	
			<ul>
				<li class='puton'>账号通绑定</li>
			</ul>
	  </div>
 <div style="margin:20px;font-size:14px">
	 绑定第三方网站账号后，就可以使用以下网站的帐号登录，并同步分享新鲜事，微博等！
 </div>

	<table border="0" width="95%" align="center">
	 <tr class="title">
	   <td>第三方接口名称</td>
	   <td>绑定状态</td>
	   <td>功能描述</td>
	 </tr>
	 <form name="myform" action="user_bind.asp" method="post">
	 <input type="hidden" name="action" value="dosave"/>
	 <%if cbool(API_QQEnable)=true then%>
				<tr>
				  <td height="50" class="splittd"><img src="../images/default/qq.png"/></td>
				   <td class="splittd">
				   <%
				   if not ks.isnul(ksuser.getuserinfo("qqopenid")) then
					  response.write "<span title='qq登录已绑定'><img src='../images/default/icon_qq.png' align='absmiddle' alt='qq登录已绑定'/>QQ已绑定</span>,<a href='?action=delbind&v=1' style='color:#ff6600;text-decoration:underline'>解除绑定</a>&nbsp;&nbsp;"
					else
					  response.write "<span title='qq登录未绑定'><img src='../images/default/icon_qq_no.png' align='absmiddle' alt='qq登录未绑定'/>QQ登录未绑定</span>,<a onclick=""$.dialog({width:'520px',height:'370px',title:'绑定QQ登录',content:'url:" & KS.GetDomain & "api/qq/redirect_to_login.asp'});"" href='javascript:;' style='color:green;font-weight:bold;text-decoration:underline'>立即绑定</a>&nbsp;&nbsp;"
					end if
				   %>
				   </td>
				  <td  class="splittd"> <strong>轻松绑定QQ帐号,您可以实现以下功能：</strong><br/>
                   <label><input type='checkbox' disabled="disabled" checked="checked"/>使用QQ帐号登录</label>
                   <label><input type='checkbox' name='Synchronization'<%if KS.FoundInArr(KSUser.GetUserInfo("Synchronization")&",","1",",") Then Response.Write(" checked")%> value='1'/>微博，论坛新帖等同步至腾讯微博</label>
				  </td>
				</tr>
	 <%end if%>
	 <%if cbool(API_SinaEnable)=true then%>
				<tr>
				  <td height="50" class="splittd"><img src="../images/default/sina.png"/></td>
				   <td class="splittd">
				   <%
				   if not ks.isnul(ksuser.getuserinfo("sinaid")) then
					  response.write "<span title='新浪微博登录已绑定'><img src='../images/default/icon_sina.png' align='absmiddle' alt='新浪微博登录已绑定'/>新浪微博已绑定</span>,<a href='?action=delbind&v=2' style='color:#ff6600;text-decoration:underline'>解除绑定</a>&nbsp;&nbsp;"
					else
					  response.write "<span title='新浪微博登录未绑定'><img src='../images/default/icon_sina_no.png' align='absmiddle' alt='新浪微博登录未绑定'/>新浪微博登录未绑定</span>,<a href=""" & KS.GetDomain & "api/sina/redirect_to_login.asp"" style='color:green;font-weight:bold;text-decoration:underline'>立即绑定</a>&nbsp;&nbsp;"
					end if
				   %>
				   </td>
				  <td  class="splittd"> <strong>轻松绑定新浪微博账号登录,您可以实现以下功能：</strong><br/>
                   <label><input type='checkbox'  disabled="disabled" checked="checked"/>使用新浪微博帐号登录</label>
                   <label><input type='checkbox'<%if KS.FoundInArr(KSUser.GetUserInfo("Synchronization")&",","2",",") Then Response.Write(" checked")%> name='Synchronization' value='2'/>微博，论坛新帖等同步至新浪微博</label>
				  </td>
				</tr>
	 <%end if%>
	 <%if cbool(API_AlipayEnable)=true then%>
				<tr>
				  <td height="50" class="splittd"><img src="../images/default/alipay.png"/></td>
				   <td class="splittd">
				   <%
				   if not ks.isnul(ksuser.getuserinfo("alipayid")) then
					  response.write "<span title='支付宝登录已绑定'><img src='../images/default/icon_alipay.png' align='absmiddle' alt='支付宝登录已绑定'/>支付宝已绑定</span>,<a href='?action=delbind&v=3'  style='color:#ff6600;text-decoration:underline'>解除绑定</a>&nbsp;&nbsp;"
					else
					  response.write "<span title='支付宝登录未绑定'><img src='../images/default/icon_alipay_no.png' align='absmiddle' alt='支付宝登录未绑定'/>支付宝登录未绑定</span>,<a href='../api/alipay/alipay_auth_authorize.asp' target='_blank' style='color:green;font-weight:bold;text-decoration:underline'>立即绑定</a>&nbsp;&nbsp;"
					end if
				   %>
				   </td>
				  <td  class="splittd"> <strong>轻松绑定支付宝账号登录,您可以实现以下功能：</strong><br/>
                   <label><input type='checkbox' disabled="disabled"  checked="checked"/>使用支付宝帐号登录</label>
				  </td>
				</tr>
	 <%end if%>
			<tr class="title"><td style="height:50px;text-align:center" colspan="5"> <button type="submit" class="pn"><strong>OK,保存设置</strong></button>
</td></tr>
	</table> 
				
		  <%
  End Sub
  
  Sub DoSave()
    Dim Synchronization:Synchronization=KS.S("Synchronization")
	if Synchronization<>"" Then Synchronization=replace(Synchronization," ","")
	Conn.Execute("Update KS_User Set Synchronization='" & Synchronization &"' Where UserName='" & KSUser.UserName &"'")
	Session(KS.SiteSN&"UserInfo")=""
	KS.Die "<script>$.dialog.tips('恭喜，设置成功!',1,'success.gif',function(){location.href='user_bind.asp';});</script>"
  End Sub 
    
  
End Class
%> 
