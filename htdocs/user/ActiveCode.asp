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
Set KSCls = New ActiveCodeCls
KSCls.Kesion()
Set KSCls = Nothing

Class ActiveCodeCls
        Private KS,RS,KSR,KSUser
		Private CurrentOpStr,Action,ID,FileContent,FormStr
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		 CloseConn
		End Sub
		
	   Sub GetPassWordForm()
	       FormStr="<h1>重发激活码</h1><table  border=""0"" align=""center"" cellpadding=""0"" cellspacing=""1"" class=""border"">" & vbcrlf
		   FormStr=FormStr &"<form name=""myform"" method=""post"" action=""?Action=Send"" onSubmit=""return CheckForm();"">"& vbcrlf
		   FormStr=FormStr & "<tr class=""tdbg"">"& vbcrlf
		   FormStr=FormStr & "  <td width=""40%"" height=""30"" align=""right""> 用户名：</td>" 
		   FormStr=FormStr & "  <td width=""60%""><input name=""UserName"" class=""textbox"" type=""text"" id=""UserName"" size=""20"" /></td>"& vbcrlf
		   FormStr=FormStr & "</tr>"& vbcrlf
		   FormStr=FormStr & "<tr class=""tdbg"">"& vbcrlf
		   FormStr=FormStr & "  <td align=""right""> 您的邮箱：</td>"& vbcrlf
		   FormStr=FormStr & "  <td><input name=""Email"" type=""text"" class=""textbox"" id=""Email"" size=""20"" /></td>"& vbcrlf
		   FormStr=FormStr & "</tr>"& vbcrlf
		   FormStr=FormStr & " <tr class=""tdbg"">"& vbcrlf
		   FormStr=FormStr & "   <td colspan=2 height=""42"" align=""center""><input class=""button"" name=""Submit2"" type=""submit"" value="""" /></td></tr></form></table>"& vbcrlf
	   End Sub
	   
	   
       Public Sub Kesion()
		 Action=KS.S("Action")
		 Dim TemplatePath:TemplatePath=KS.Setting(3) & KS.Setting(90) & "Common/ActiveCode.html"  '模板地址
		 FileContent = KSR.LoadTemplate(TemplatePath)    
		 FCls.RefreshType = "getactivecode" '设置刷新类型，以便取得当前位置导航等
		 FCls.RefreshFolderID = "0"         '设置当前刷新目录ID 为"0" 以取得通用标签
		Select Case lcase(Action)
		  Case "send" Call CheckTimes():Call Send()
		  Case "active" Call Active()
		  Case "docheck" Call docheck()
		  Case Else
			 GetPassWordForm
			 FileContent=Replace(FileContent,"{$ActiveTitle}","重发激活码")
		End Select
		 FileContent=Replace(FileContent,"{$GetActiveCodeForm}",FormStr)
		 FileContent=KSR.KSLabelReplaceAll(FileContent)
		 KS.Die FileContent
       End Sub
	   
	   sub CheckTimes()
	    If KS.ChkClng(KS.Setting(128))=0 Then Exit Sub
		'删除大于10天的无用记录
		Conn.Execute("Delete From KS_UserRecord Where flag=2 and datediff(" & DataPart_D & ",adddate," & sqlnowstring &")>10")
		
		if ks.chkclng(conn.execute("select count(1) from ks_userrecord where flag=2 and datediff(" & DataPart_D & ",adddate," & sqlnowstring &")=0 and userip='" & ks.getip &"'")(0))>=KS.ChkClng(KS.Setting(128)) then
				 Response.Write("<script>alert('对不起，系统限定每天只能使用" & KS.ChkClng(KS.Setting(128)) & "次重发激活码功能!');history.back();</script>")
				 Response.End
			 end if
	 end sub 
	   
	   Sub Active()
	     Dim UserID:UserID=KS.ChkClng(KS.S("UserID"))
		 If UserId=0 Then KS.Die "error"
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "select top 1 * from KS_User Where UserID=" & UserId,Conn,1,1
		 If RS.Eof And RS.Bof Then
		  RS.Close:Set RS=Nothing
		  KS.Die "error"
		 End If
		if rs("locked")<>3 then
		  rs.close:set rs=nothing
		  KS.Die "<script>alert('已激活过了，不需要再次激活!');location.href='../';</script>"
		end if
		 Dim UserName:UserName=RS("UserName")
		 
			 FileContent=Replace(FileContent,"{$ActiveTitle}","会员账号激活")
			 FormStr="<form name=""myform"" method=""post"" action=""ActiveCode.asp"" onSubmit=""return CheckForm();"">"& vbcrlf
             FormStr=FormStr &"<input type=""hidden"" name=""action"" value=""docheck""/>"& vbcrlf
             FormStr=FormStr &"<table  border=""0"" align=""center"" cellpadding=""0"" cellspacing=""1"" class=""border"">"& vbcrlf
			 FormStr=FormStr &"<tr class=""title"">"& vbcrlf
			 FormStr=FormStr &"	<td height=""24"" align=""center"" colspan=""2"">用 户 激 活</td>"& vbcrlf
			 FormStr=FormStr &"</tr>"& vbcrlf
			 FormStr=FormStr &"<TR class=""tdbg"">"
			 FormStr=FormStr &"    <TD width=""100%"" height=25 align=""right"">您的用户名：</TD>"& vbcrlf
			 FormStr=FormStr &"    <TD style=""text-align:left"">" & KS.CheckXSS(UserName) &"<input name=""UserId"" type=""hidden""  size=""20"" value=""" & UserId & """></TD>"& vbcrlf
			 FormStr=FormStr &"</TR>"& vbcrlf
			 FormStr=FormStr &"<TR class=""tdbg"">"& vbcrlf
			 FormStr=FormStr &"	<TD height=25 align=""right""> 您的激活码：</TD>"& vbcrlf
			 FormStr=FormStr &" <TD><input name=""CheckNum"" class=""textbox"" type=""text"" id=""CheckNum"" size=""20"" value=""" & KS.S("CheckNum") & """></TD></TR>"& vbcrlf
			 FormStr=FormStr &"<TR class=""tdbg""><TD  colspan=""2"" height=42 align=""center""> <input name=""Submit"" type=""submit"" class=""button"" value=""确定激活"" style=""padding:3px""></TD></TR>"& vbcrlf
			 FormStr=FormStr &"</TABLE></form>"& vbcrlf
	   End Sub
	   
	   Sub DoCheck()
	        Dim UserId:UserID=KS.ChkClng(KS.S("UserID"))
			Dim CheckNum:CheckNum=KS.S("CheckNum")
	        Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
			RS.Open "Select top 1 UserName,RndPassWord,Email,CheckNum,locked,AllianceUser From KS_User Where UserId=" & UserId ,Conn,1,3
			If RS.Eof And RS.Bof Then
			 rs.close:set rs=nothing
			 Response.Write "<script>alert('对不起，用户不存在！');history.back();</script>":response.end
			else
			  if rs("checknum")<>checknum then
			   rs.close:set rs=nothing
			   Response.Write "<script>alert('激活码有误，请重新输入！');history.back();</script>":response.end
              elseif rs("locked")<>3 then
				  rs.close:set rs=nothing
				  Response.Write "<script>alert('您的账号已经激活，请勿重复激活！');history.back();</script>":response.end
			  else
			   rs("locked")=0
			   rs.update
			   
			    Dim MailBodyStr,ReturnInfo
			    MailBodyStr = Replace(KS.Setting(147), "{$UserName}", rs("UserName"))
				MailBodyStr = Replace(MailBodyStr, "{$PassWord}", rs("RndPassWord"))
				MailBodyStr = Replace(MailBodyStr, "{$SiteName}", KS.Setting(0))
				ReturnInfo=KS.SendMail(KS.Setting(12), KS.Setting(13), KS.Setting(14), KS.Setting(0) & "-会员注册成功", RS("Email"),rs("UserName"), MailBodyStr,KS.Setting(11))

				IF ReturnInfo="OK" Then
				  ReturnInfo="<li>注册激活成功!您的用户名:<span style=""color:red"">" & RS("UserName") & "</span>,已将用户名和密码发到您的信箱!</li>"
				End If
				'给推荐人加积分
				Dim AllianceUser:AllianceUser=RS("AllianceUser")
				If AllianceUser<>RS("UserName") Then
				  If Not Conn.Execute("Select Top 1 UserID From KS_User Where UserName='" & AllianceUser & "'").eof Then
				   '判断有没有恶意推荐注册,恶意注册的不给积分
				   If Conn.Execute("Select top 1 * From KS_PromotedPlan Where UserIP='" & KS.GetIP & "' And DateDiff(" & DataPart_D & ",AddDate," & SqlNowString & ")<1 And UserName='" & AllianceUser & "'").eof Then
				   Call KS.ScoreInOrOut(AllianceUser,1,KS.ChkClng(KS.Setting(144)),"系统","成功推荐一个注册用户:" & UserName & "!",0,0)
				   
				   Conn.Execute("Insert InTo KS_PromotedPlan(UserName,UserIP,AddDate,ComeUrl,Score,AllianceUser) values('" & AllianceUser & "','" & KS.GetIP & "'," & SqlNowString & ",'" & KS.URLDecode(Request.ServerVariables("HTTP_REFERER")) & "'," & KS.ChkClng(KS.Setting(144)) & ",'" & UserName & "')")
				   End If
				 End If
				End If
				rs.close:set rs=nothing
			   Response.Write "<script>alert('恭喜您,账号激活成功,您现在可以正常登录了！');location.href='../user/login';</script>":response.end
			  end if
			end if
	   End Sub
	   
	   Sub Send()
	    Dim UserName:UserName=KS.R(KS.S("UserName"))
		Dim Email:Email=KS.S("Email")
		If UserName="" Then
		  Call KS.AlertHistory("请输入用户名!",-1)
		  Exit Sub
		End If
		If Email="" Then
		  Call KS.AlertHistory("请输入您的邮箱!",-1)
		  Exit Sub
		End If
		If KS.IsValidEmail(Email)=false Then
		  Call KS.AlertHistory("请正确的邮箱地址!",-1)
		  Exit Sub
		End If
		
		Call KSUser.AddUserRecord(2,"重发激活码操作，输入的用户" & UserName &",邮箱" & Email & "!") '记录操作
		
		Dim RS:Set RS=KS.InitialObject("ADODB.RECORDSET")
		RS.Open "Select top 1 * From KS_User Where UserName='" & UserName & "'",conn,1,3
		If RS.Eof And RS.Bof Then
		  RS.Close:Set RS=Nothing
		  Call KS.AlertHistory("对不起,您输入的用户不存在!",-1)
		   Exit Sub
		 End If
		 If RS("Locked")<>3 Then
		   RS.Close:Set RS=Nothing
		   Call KS.AlertHistory("对不起,该用户已经激活过了!",-1)
		   Exit Sub
		 End If
		 Dim RSG:Set RSG=Server.CreateObject("ADODB.RECORDSET")
		 RSG.Open "Select * From KS_UserGroup Where ID=" & RS("GroupID"),conn,1,1
		 If RSG.Eof Then RSG.Close : Set RSG=Nothing :Response.Write "<script>location.href='../../';</script>"
			
		 Dim UserRegSendMail:UserRegSendMail=RSG("ValidType")
		 Dim CheckNum:CheckNum = KS.MakeRandomChar(6)  '随机字符验证码
		 Dim CheckUrl:CheckUrl = Request.ServerVariables("HTTP_REFERER")
		 CheckUrl=KS.GetDomain &"User/ActiveCode.asp?Action=Active&UserId=" & RS("UserID") &"&CheckNum=" & CheckNum
		    Dim MailBodyStr
			MailBodyStr = Replace(RSG("ValidEmail"), "{$CheckNum}", CheckNum)
			MailBodyStr = Replace(MailBodyStr, "{$CheckUrl}", CheckUrl)
	        RSG.Close:Set RSG=Nothing
	       Dim ReturnInfo:ReturnInfo=KS.SendMail(KS.Setting(12), KS.Setting(13), KS.Setting(14), "新用户注册激活信", Email,KS.Setting(0), MailBodyStr,KS.Setting(11))
			  IF ReturnInfo="OK" Then
			     RS("CheckNum")=CheckNum
				 RS("Email")=Email
				 RS.Update
				 RS.Close:Set RS=Nothing
				 Response.Write "<script>alert('恭喜,激活码已发送到您的信箱" &Email &",请查收!');location.href='../';</script>"
			  Else
			     RS.Close:Set RS=Nothing
				 Response.Write "<script>alert('对不起,激活码发送失败!失败原因:" & ReturnInfo & "');history.back();</script>"
			  End if

	   End Sub
End Class
%> 
