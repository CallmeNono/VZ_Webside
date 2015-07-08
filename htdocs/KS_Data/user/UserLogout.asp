<%@language=vbscript CODEPAGE="65001" %>
<!--#include file="../conn.asp"-->
<!--#include file="../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="../Plus/md5.asp"-->
<!--#include file="../API/cls_api.asp"-->
<%
Dim UserName,PassWord
UserName=KS.C("UserName")
If UserName<>"" And Not IsNull(UserName) Then
Conn.Execute("Update KS_User Set isonline=0 Where UserName='" & UserName & "'")
End If
If EnabledSubDomain Then
	Response.Cookies(KS.SiteSn).domain=RootDomain					
Else
    Response.Cookies(KS.SiteSn).path = "/"
End If
Response.Cookies(KS.SiteSn)("UserName") = ""
Response.Cookies(KS.SiteSn)("Password") = ""
Response.Cookies(KS.SiteSn)("RndPassword")=""
Response.Cookies(KS.SiteSn)("PowerList")=""
Response.Cookies(KS.SiteSn)("AdminName")=""
Response.Cookies(KS.SiteSn)("AdminPass")=""
Response.Cookies(KS.SiteSn)("SuperTF")=""
Response.Cookies(KS.SiteSn)("AdminLoginCode")=""
Response.Cookies(KS.SiteSn)("ModelPower")=""
Session(KS.SiteSN&"UserInfo")=""
session.Abandon()

'-----------------------------------------------------------------
'系统整合
'-----------------------------------------------------------------
Dim API_KS,API_SaveCookie,SysKey
If API_Enable Then
	Set API_KS = New API_Conformity
	Md5OLD = 1
	SysKey = Md5(UserName & API_ConformKey,16)
	Md5OLD = 0
	API_SaveCookie = API_KS.SetCookie(SysKey,UserName,Password,0)
	Set API_KS = Nothing
	Response.Write API_SaveCookie
	If API_LogoutUrl <> "0" Then
		Response.Write "<script language=JavaScript>"
		Response.Write "setTimeout(""top.location='"& API_LogoutUrl &"'"",1000);"
		Response.Write "</script>"
	ElseIf trim(Request.ServerVariables("http_referer"))="" Then 
	    Response.Redirect "/"
	Else
		Response.Write "<script language=""javascript"">window.setInterval(""location.reload('" & Request.ServerVariables("http_referer") & "')"",1000);</script>"

	End If
Else
    If trim(Request.ServerVariables("http_referer"))="" Then 
	  Response.Redirect "/"
    elseif instr(Lcase(Request.ServerVariables("HTTP_REFERER")),"index.asp")>0 then
	Response.Redirect("../")
	else
    Response.Redirect Request.ServerVariables("http_referer")
	end if
	'Response.Write "<script>top.location='" & ks.setting(3) & "';<//script>"
End If
'-----------------------------------------------------------------

Set KS=Nothing
%> 
