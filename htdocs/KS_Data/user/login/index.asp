<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../../Conn.asp"-->
<!--#include file="../../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../../api/cls_api.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New Admin_Index
KSCls.Kesion()
Set KSCls = Nothing

Class Admin_Index
        Private KS,KSR,KSUser,FileContent
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		 Set KSR=Nothing
		End Sub
		Public Sub Kesion()
		IF Cbool(KSUser.UserLoginChecked)=True Then
		 Response.Redirect("../")
		End If
		
		 Dim TemplatePath:TemplatePath=KS.Setting(3) & KS.Setting(90) & "Common/login.html"  '模板地址
		 FileContent = KSR.LoadTemplate(TemplatePath)    
		 FCls.RefreshType = "userlogin" '设置刷新类型，以便取得当前位置导航等
		 FCls.RefreshFolderID = "0" '设置当前刷新目录ID 为"0" 以取得通用标签
		 
         FileContent=Replace(FileContent,"{$IsShowVerifyCode}",KS.ChkClng(KS.Setting(34)))
		 If KS.ChkClng(KS.Setting(34))=1 Then
         FileContent=Replace(FileContent,"{$ShowVerifyCode}","")
		 Else
         FileContent=Replace(FileContent,"{$ShowVerifyCode}"," style=""display:none""")
		 End If
		 
		 Dim LoginStr
		 If cbool(API_QQEnable) Then
		   LoginStr="<a title=""使用qq账号登录"" href=""" & KS.GetDomain & "api/qq/redirect_to_login.asp""><img src=""" &KS.GetDomain & "images/default/icon_qq.png"" align=""absmiddle""/>QQ</a>&nbsp;&nbsp;"
		 End If
		 If cbool(API_SinaEnable) Then
		   LoginStr=LoginStr & " <a title=""使用新浪微博账号登录"" href=""" & KS.GetDomain & "api/sina/redirect_to_login.asp""><img src=""" &KS.GetDomain & "images/default/icon_sina.png"" align=""absmiddle""/>新浪微博</a>&nbsp;&nbsp;"
		 End If
		 If cbool(API_AlipayEnable) Then
		   LoginStr=LoginStr & " <a title=""使用支付宝登录"" href=""" & KS.GetDomain & "api/alipay/alipay_auth_authorize.asp""><img src=""" &KS.GetDomain & "images/default/icon_alipay.png"" align=""absmiddle""/>支付宝</a>"
		 End If
		 If LoginStr<>"" Then LoginStr="" & LoginStr
		 FileContent=Replace(FileContent,"{$ShowQuickLogin}",LoginStr)
		 
		 
		 FileContent=KSR.KSLabelReplaceAll(FileContent)
		 KS.Die FileContent
  End Sub
End Class
%> 
