<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%Option Explicit%>
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.WebFilesCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New Frame
KSCls.Kesion()
Set KSCls = Nothing

Class Frame
        Private KS,KSUser
		Private TopDir
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
		  Response.Write "<script>window.close();</script>"
		  Exit Sub
		End If
		TopDir=KSUser.GetUserFolder(ksuser.getuserinfo("userid"))
		 Call KSUser.Head()
		 Call KSUser.InnerLocation("我的文件管理")
		 Call KS.CreateListFolder(TopDir)
		  call showframe()
		  call filelist()
		  response.write "<div style=""padding:8px;color:red"">温馨提醒：为免浪费您的保贵空间，请及时删除无用的文件！</div>"
		end sub
		
		sub showframe()
        %>
		


<table width="98%"  border="0" align="center" cellpadding="0" cellspacing="1">
						<tr class="tdbg">
						<td>您的总空间<font color=red><%=round(KSUser.GetUserInfo("SpaceSize")/1024,2)%>M</font>,已使用<font color=green><%dim sy:sy=Round(KS.GetFolderSize(TopDir)/1024/1024,2)
						if sy<1 then response.write "0" & sy else response.write sy%>M</font></strong></td>
                       </tr>
            </table>
		<%
		end sub
		
		sub filelist()
		 Response.Buffer = True
		Response.Expires = -1
		Response.ExpiresAbsolute = Now() - 1
		Response.Expires = 0
		Response.CacheControl = "no-cache"
		Dim WFCls:Set WFCls = New WebFilesCls
		Call WFCls.Kesion(0,TopDir,"",20,"","Images/Css.css")
		Set WFCls = Nothing
	  
      End Sub
	   '（图片对象名称，标题对象名称，更新数，总数）
		Function ShowTable(SrcName,TxtName,str,c)
		Dim Tempstr,Src_js,Txt_js,TempPercent
		If C = 0 Then C = 99999999
		Tempstr = str/C
		TempPercent = FormatPercent(tempstr,0,-1)
		Src_js = "document.getElementById(""" + SrcName + """)"
		Txt_js = "document.getElementById(""" + TxtName + """)"
			ShowTable = VbCrLf + "<script>"
			ShowTable = ShowTable + Src_js + ".width=""" & FormatNumber(tempstr*600,0,-1) & """;"
			ShowTable = ShowTable + Src_js + ".title=""容量上限为："&c/1024&" MB，已用（"&FormatNumber(str/1024,2)&"）MB！"";"
			ShowTable = ShowTable + Txt_js + ".innerHTML="""
			If FormatNumber(tempstr*100,0,-1) < 80 Then
				ShowTable = ShowTable + "已使用:" & TempPercent & """;"
			Else
				ShowTable = ShowTable + "<font color=\""red\"">已使用:" & TempPercent & ",请赶快清理！</font>"";"
			End If
			ShowTable = ShowTable + "</script>"
		End Function
		
End Class
%> 
