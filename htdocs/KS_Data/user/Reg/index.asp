<!--#include file="../../Conn.asp"-->
<!--#include file="../../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="../../ks_cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../../plus/md5.asp"-->
<!--#include file="../../api/cls_api.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New RegCls
KSCls.Kesion()
Set KSCls = Nothing

Class RegCls
        Private KS,KSR,Tp
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		End Sub
		Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSR=Nothing
		End Sub
		
		Public Sub Kesion()
		  GCls.ComeUrl=request.ServerVariables("HTTP_REFERER")
		  IF KS.Setting(21)=0 Then : Response.Redirect "../../plus/error.asp?action=error&message=" & Server.URLEncode("<li>对不起，本站暂停新会员注册!</li>") :  Response.End
		   If KS.Setting(117)="" Then Response.Write "请先到""基本信息设置->模板绑定""进行模板绑定操作!":response.end
		   Tp = KSR.LoadTemplate(KS.Setting(117))
		   FCls.RefreshType="UserRegStep1"
		   If Trim(Tp) = "" Then Tp = "模板不存在!"
          Dim UserRegMustFill:UserRegMustFill=KS.Setting(33)
		  Dim ShowCheckEmailTF:ShowCheckEmailTF=true
		  Dim ShowVerifyCodeTF:ShowVerifyCodeTF=false
		 
		 IF KS.Setting(28)="1" Then ShowCheckEmailTF=false
		 IF KS.Setting(27)="1" then ShowVerifyCodeTF=true
		 
		 If KS.Setting(33)="0" Then
		 Tp = Replace(Tp, "{$ShowUserType}", "<input type='hidden' id='GroupID' value='2'/>")
		 Tp = Replace(Tp, "{$DisplayUserType}", " style='display:none'")
		 Else
		 Tp = Replace(Tp, "{$ShowUserType}", UserGroupList())
		 Tp = Replace(Tp, "{$DisplayUserType}", "")
		 End If
		 
		 If KS.Setting(32)="1" Then 
		 Tp = Replace(Tp, "{$Show_Detail}", " style='display:none'")
		 Tp = Replace(Tp, "{$Show_DetailTF}", 1)
		 Else
		 Tp = Replace(Tp, "{$Show_Detail}", "")
		 Tp = Replace(Tp, "{$Show_DetailTF}", 2)
		 End If
		 
		 If KS.Setting(148)="1" Then
		 Tp = Replace(Tp, "{$DisplayQestion}", "")
		 Else
		 Tp = Replace(Tp, "{$DisplayQestion}", " style=""display:none""")
		 End If

		 If KS.Setting(149)="1" Then
		 Tp = Replace(Tp, "{$DisplayMobile}", "")
		 Else
		 Tp = Replace(Tp, "{$DisplayMobile}", " style=""display:none""")
		 End If
		 If KS.Setting(143)="1" Then
		 Tp = Replace(Tp, "{$DisplayAlliance}", "")
		 Else
		 Tp = Replace(Tp, "{$DisplayAlliance}", " style=""display:none""")
		 End If
		 
		 If Mid(KS.Setting(161),1,1)="1" Then
		 Dim RndReg:rndReg=GetRegRnd()
		 Tp = Replace(Tp, "{$DisplayRegQuestion}", "")
		 Tp = Replace(Tp, "{$RegQuestion}", GetRegQuestion(RndReg))
		 Tp = Replace(Tp, "{$AnswerRnd}", GetRegAnswerRnd(RndReg))
		 Else
		 Tp = Replace(Tp, "{$DisplayRegQuestion}", " style=""display:none""")
		 Tp = Replace(Tp, "{$RegQuestion}", "")
		 Tp = Replace(Tp, "{$AnswerRnd}", "")
		 End If
		 
		 Tp = Replace(Tp, "{$Show_Question}", KS.Setting(148))
		 Tp = Replace(Tp, "{$Show_Mobile}", KS.Setting(149))
		 If Request("u")<>"" Then
		 Tp = Replace(Tp, "{$UserName}", " value=""" & split(Request("u"),"@")(0) & """")
		 Else
		 Tp = Replace(Tp, "{$UserName}", "")
		 End If
		 If KS.S("Uid")<>"" Then
		  if not Conn.Execute("Select top 1 UserName From KS_User Where UserID=" & KS.ChkClng(KS.S("Uid"))).eof then
		  Tp = Replace(Tp, "{$AllianceUser}", " value=""" & Conn.Execute("Select top 1 UserName From KS_User Where UserID=" & KS.ChkClng(KS.S("Uid")))(0) & """ readonly")
		  End If
		  Tp = Replace(Tp, "{$Friend}", " value=""" & KS.S("F") & """")
		 Else
		  Tp = Replace(Tp, "{$AllianceUser}", "")
		  Tp = Replace(Tp, "{$Friend}", "")
		 End If

		 Tp = Replace(Tp, "{$GetUserRegLicense}", Replace(KS.Setting(23),chr(10),"<br/>"))
		 Tp = Replace(Tp,"{$Show_UserNameLimitChar}",KS.Setting(29))
		 Tp = Replace(Tp,"{$Show_UserNameMaxChar}",KS.Setting(30))
		 Tp = Replace(Tp, "{$Show_CheckEmail}", IsShow(ShowCheckEmailTF))
		 Tp = Replace(Tp, "{$Show_VerifyCodeTF}", IsShow(ShowVerifyCodeTF))
		 
		 Dim LoginStr
		 If cbool(API_QQEnable) Then
		   LoginStr="<a title=""使用qq账号登录"" href=""" & KS.GetDomain & "api/qq/redirect_to_login.asp""><img src=""" &KS.GetDomain & "images/default/icon_qq.png"" align=""absmiddle""/> QQ登录</a>&nbsp;&nbsp;"
		 End If
		 If cbool(API_SinaEnable) Then
		   LoginStr=LoginStr & " <a title=""使用新浪微博账号登录"" href=""" & KS.GetDomain & "api/sina/redirect_to_login.asp""><img src=""" &KS.GetDomain & "images/default/icon_sina.png"" align=""absmiddle""/> 新浪微博</a>&nbsp;&nbsp;"
		 End If
		 If cbool(API_AlipayEnable) Then
		   LoginStr=LoginStr & " <a title=""使用支付宝登录"" href=""" & KS.GetDomain & "api/alipay/alipay_auth_authorize.asp""><img src=""" &KS.GetDomain & "images/default/icon_alipay.png"" align=""absmiddle""/> 支付宝</a>"
		 End If
		 If LoginStr<>"" Then LoginStr=LoginStr & "<br/><div style='color:#999;margin:5px'>与合作网站内容互通，快速登录</div>"

		 Tp=Replace(Tp,"{$ShowQuickLogin}",LoginStr)		 
		 
	
         Tp = KSR.KSLabelReplaceAll(Tp) '替换函数标签
		 Response.Write Tp  
		end sub
		
		Function GetRegRnd()
		  Dim QuestionArr:QuestionArr=Split(KS.GetCurrQuestion(162),vbcrlf)
		  Dim RandNum,N: N=Ubound(QuestionArr)
          Randomize
          RandNum=Int(Rnd()*N)
          GetRegRnd=RandNum
		End Function
		Function GetRegQuestion(ByVal RndReg)
		  Dim QuestionArr:QuestionArr=Split(KS.GetCurrQuestion(162),vbcrlf)
		  GetRegQuestion=QuestionArr(rndReg)
		End Function
		Function GetRegAnswerRnd(ByVal RndReg)
		  GetRegAnswerRnd=md5(rndReg,16)
		End Function        '会员类型
		Function UserGroupList()
			If  KS.Setting(33)="0" Then UserGroupList="":Exit Function
			 Dim Node,Tips
			 Call KS.LoadUserGroup()
			 If KS.ChkClng(KS.S("GroupID"))<>0 Then
				Set Node=Application(KS.SiteSN&"_UserGroup").DocumentElement.SelectSingleNode("row[@id=" & KS.S("GroupID") & "]")
				If Not Node Is Nothing Then
				If KS.ChkClng(Node.SelectSingleNode("@showonreg").text)=0 Then KS.Die "<script>alert('对不起，该用户组不允许注册!');</script>"
				UserGroupList="<span style='font-weight:bold;color:#ff6600'>" & Node.SelectSingleNode("@groupname").text &"</span><input type='hidden' value='" & KS.S("GroupID") & "' id='GroupID' name='GroupID'><span style='display:none' id='tips_" &Node.SelectSingleNode("@id").text&"'>" &Node.SelectSingleNode("@descript").text &"</span>"
			    End If 
				Set Node=Nothing
			Else
			  For Each Node In Application(KS.SiteSN&"_UserGroup").DocumentElement.SelectNodes("row[@showonreg=1 && @id!=1]")
			  If UserGroupList="" Then
			  Tips=Node.SelectSingleNode("@descript").text
			  UserGroupList="<label><input type=""radio""  value=""" & Node.SelectSingleNode("@id").text & """ name=""GroupID"" checked>" & Node.SelectSingleNode("@groupname").text  & "</label><span style='display:none' id='tips_" &Node.SelectSingleNode("@id").text&"'>" &Node.SelectSingleNode("@descript").text &"</span>"
			  Else
			  UserGroupList=UserGroupList & " <label><input type=""radio""  value=""" & Node.SelectSingleNode("@id").text & """ name=""GroupID"">" & Node.SelectSingleNode("@groupname").text & "</label><span style='display:none' id='tips_" &Node.SelectSingleNode("@id").text&"'>" &Node.SelectSingleNode("@descript").text &"</span>"
			  End If
			 Next
			End If
		End Function
		
		Function IsShow(Show)
			If Show =true Then
				IsShow = ""
			Else
				IsShow = " Style='display:none'"
			End If
		End Function		
		
		'===================会员注册结束=====================
End Class
%>