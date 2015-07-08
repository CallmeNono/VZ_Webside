<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../Plus/md5.asp"-->
<!--#include file="../API/cls_api.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New UserLogin
KSCls.Kesion()
Set KSCls = Nothing

Class UserLogin
        Private KS
		Private KSUser,UserID
		Private UserName,PassWord,Verifycode,ExpiresDate,RndPassword
		Private LoginVerificCodeTF
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		
		
		Public Sub Kesion()
		    KS.Echo "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">"
			KS.Echo "<html xmlns=""http://www.w3.org/1999/xhtml"">"
			KS.Echo "<script src=""" & KS.GetDomain & "ks_inc/jquery.js""></script>"
			KS.Echo "<script src=""" & KS.GetDomain & "ks_inc/lhgdialog.js""></script>"
			KS.Echo "<body>"
			UserName=KS.R(KS.S("UserName"))
			PassWord=KS.R(KS.S("PassWord"))
			ExpiresDate=KS.R(KS.S("ExpiresDate"))
			Verifycode=KS.R(KS.S("Verifycode"))
			LoginVerificCodeTF=KS.ChkClng(KS.Setting(34))
			RndPassword=KS.R(KS.MakeRandomChar(20))
			Dim parentbox:parentbox=KS.ChkClng(Request("parentbox"))
			If parentbox=1 Then parentbox="frameElement.api.opener." Else parentbox=""
			IF UserName="" Then
		   	 KS.Die "<script>" & parentbox & "$.dialog.tips('用户名不能为空，请输入！',1,'error.gif',function(){history.back();});</script>"
			End IF
		    IF PassWord="" Then
		   	 KS.Die "<script>" & parentbox & "$.dialog.tips('登录密码不能为空，请输入！',1,'error.gif',function(){history.back();});</script>"
			End IF
			IF lcase(Trim(Verifycode))<>lcase(Trim(Session("Verifycode"))) And LoginVerificCodeTF=1 then 
		   	 KS.Die "<script>" & parentbox & "$.dialog.tips('验证码有误，请重新输入！',1,'error.gif',function(){history.back();});</script>"
			End IF
            UserName=lcase(UserName)
			PassWord=MD5(PassWord,16)
			Dim Param:Param=" Where PassWord='" & PassWord & "'"
			If InStr(UserName,"@")<>0 Then
			 Param=Param & " and Email='"& UserName & "'"
			ElseIf Len(UserName)<10 and IsNumerIc(UserName) Then
			 Param=Param & " and (UserId=" & KS.ChkClng(UserName) & " or username='" & UserName &"')"
			Else
			 Param=Param & " and UserName='" &UserName & "'"
			End If
			 Dim UserRS:Set UserRS=Server.CreateObject("Adodb.RecordSet")
			 UserRS.Open "Select top 1 * From KS_User" & Param,Conn,1,3
			 If UserRS.Eof And UserRS.BOf Then
				  UserRS.Close:Set UserRS=Nothing
				  KS.Die "<script>" & parentbox & "$.dialog.tips('你输入的用户名或密码有误，请重新输入！',1,'error.gif',function(){history.back();});</script>"
			 ElseIf UserRS("Locked")=1 Then
			   UserRS.Close:Set UserRS=Nothing
			   KS.Die "<script>" & parentbox & "$.dialog.tips('您的账号已被管理员锁定，请与管理员联系！',1,'error.gif',function(){history.back();});</script>"
			 ElseIF UserRS("Locked")=3 Then
			   UserRS.Close:Set UserRS=Nothing
			   KS.Die "<script>" & parentbox & "$.dialog.tips('您的账号还没有激活，请注意查收您的邮箱并进行激活！',1,'error.gif',function(){history.back();});</script>"
			 ElseIF UserRS("Locked")=2 Then
			   UserRS.Close:Set UserRS=Nothing
			   KS.Die "<script>$.dialog.tips('您的账号还没有通过认证！',1,'error.gif',function(){history.back();});</script>"
			 Else
			            UserName=UserRS("UserName")
			        	'-----------------------------------------------------------------
						'系统整合
						'-----------------------------------------------------------------
						Dim API_KS,API_SaveCookie,SysKey
						If API_Enable Then
							Set API_KS = New API_Conformity
							API_KS.NodeValue "action","login",0,False
							API_KS.NodeValue "username",UserName,1,False
							Md5OLD = 1
							SysKey = Md5(API_KS.XmlNode("username") & API_ConformKey,16)
							Md5OLD = 0
							API_KS.NodeValue "syskey",SysKey,0,False
							API_KS.NodeValue "password",KS.R(KS.S("PassWord")),0,False
							API_KS.SendHttpData
							If API_KS.Status = "1" Then
								KS.Die "<script>alert('" & API_KS.Message & "');history.back();</script>"
							Else
							    Dim usercookies:usercookies=1
								API_SaveCookie = API_KS.SetCookie(SysKey,UserName,Password,usercookies)
							End If
							Set API_KS = Nothing
						End If
						'-----------------------------------------------------------------
			 
			            '登录成功，更新用户相应的数据
						Dim ScoreTF:ScoreTF=False
						If KS.ChkClng(KS.U_S(UserRS("GroupID"),8))>0 and KS.ChkClng(KS.U_S(UserRS("GroupID"),9))>0 And datediff("n",UserRS("LastLoginTime"),now)>=KS.ChkClng(KS.U_S(UserRS("GroupID"),8)) then '判断时间
						ScoreTF=true
						End if
						UserRS("LastLoginIP") = KS.GetIP
                        UserRS("LastLoginTime") = Now()
                        UserRS("LoginTimes") = UserRS("LoginTimes") + 1
						UserRS("RndPassword")= RndPassword
						UserRS("IsOnline")=1
						'判断上一次是不是通过充值卡充值
						If UserRS("UserCardID")<>0 Then
						  Dim RSCard,ValidUnit,ExpireGroupID
						  Set RSCard=Conn.Execute("Select top 1 * From KS_UserCard Where ID=" & UserRS("UserCardID"))
						  If Not RSCard.Eof Then
						     ValidUnit=RSCard("ValidUnit")
							 ExpireGroupID=RSCard("ExpireGroupID")
							 If ValidUnit=1 Then                      '点券
							   If UserRS("Point")<=0 And ExpireGroupID<>0 Then
							     UserRS("GroupID")=ExpireGroupID
								 UserRS("UserCardID")=0
								 UserRS("ChargeType")=KS.ChkClng(KS.U_G(ExpireGroupID,"chargetype"))
							   End If
							 ElseIf ValidUnit=2 Then                   '有效天数
							   If UserRS("Edays")-DateDiff("D",UserRS("BeginDate"),now())<=0 And ExpireGroupID<>0 Then
							     UserRS("GroupID")=ExpireGroupID
								 UserRS("UserCardID")=0
								 UserRS("ChargeType")=KS.ChkClng(KS.U_G(ExpireGroupID,"chargetype"))
							   End If 
							 ElseIf ValidUnit=3 Then                  '资金
							   If UserRS("Money")<=0 And ExpireGroupID<>0 Then
							     UserRS("GroupID")=ExpireGroupID
								 UserRS("UserCardID")=0
								 UserRS("ChargeType")=KS.ChkClng(KS.U_G(ExpireGroupID,"chargetype"))
							   End If
							 End If
						  End If
						  RSCard.Close : Set RSCard=Nothing
						End If
                        UserRS.Update
						Dim CurrScore:CurrScore=KS.ChkClng(UserRS("Score"))
						Dim GroupID:GroupID=KS.ChkClng(UserRS("GroupID"))
						Dim PostNum:PostNum=KS.ChkClng(UserRS("PostNum"))
						Dim ClubSpecialPower:ClubSpecialPower=KS.ChkClng(UserRS("ClubSpecialPower"))
						UserID=UserRS("UserID")
						UserRS.Close
						Set UserRS=Nothing
						
						'更新论坛等级
						If ClubSpecialPower=0 Then
						  Dim RSG:Set RSG=Conn.Execute("select top 1 GradeID,UserTitle from KS_AskGrade where TypeFlag=1 and Special=0 and ClubPostNum<=" & PostNum & " And score<=" & CurrScore & " order by score desc,ClubPostNum Desc")
						  If Not RSG.Eof Then
						  Conn.Execute("Update KS_User Set ClubGradeID=" & RSG(0) & " WHERE GroupID<>1 and UserName='" & UserName & "'")
						  End If
						End If
						'更新问答等级
						Set RSG=Conn.Execute("select top 1 GradeID,UserTitle from KS_AskGrade where typeflag=0 and Special=0 and score<=" & CurrScore & " order by score desc,gradeid Desc")
						If Not RSG.Eof Then
						  Conn.Execute("Update KS_User Set GradeID=" & RSG(0) & ",GradeTitle='" & RSG(1) & "' WHERE UserName='" & UserName & "' and gradeid>5")
						End If
						'
						
						RSG.Close:Set RSG=Nothing
						
						
						If ScoreTF then 
						Session("PopTips")=KS.U_S(GroupID,8) & "分钟后重新登录，奖励积分 +" & KS.U_S(GroupID,9) & "分！"     '用于在论坛里显示
						Call KS.ScoreInOrOut(UserName,1,KS.ChkClng(KS.U_S(GroupID,9)),"系统",KS.ChkClng(KS.U_S(GroupID,8)) & "分钟后,重新登录奖励获得",0,0)
						End if
						
						'更新购物车的ID号
						If Not KS.IsNul(KS.C("CartID")) Then
						Conn.Execute("Update KS_ShopPackageSelect Set UserName='" & UserName & "' where username='" & KS.C("CartID") & "'")
						Conn.Execute("Update KS_ShoppingCart Set UserName='" & UserName & "' where username='" & KS.C("CartID") & "'")
						End If
						
							If EnabledSubDomain Then
							 Response.Cookies(KS.SiteSn).domain=RootDomain					
							Else
                             Response.Cookies(KS.SiteSn).path = "/"
							End If
						    If ExpiresDate<>"" Then Response.Cookies(KS.SiteSn).Expires = Date + 365
							Response.Cookies(KS.SiteSn)("UserID") = UserID
							Response.Cookies(KS.SiteSn)("UserName") = UserName
							Response.Cookies(KS.SiteSn)("Password") = Password
							Response.Cookies(KS.SiteSN)("RndPassword")= RndPassword
		
							
							'-----------------------------------------------------------------
							'系统整合
							'-----------------------------------------------------------------
								
								If API_Enable Then
									Response.Write API_SaveCookie
									Response.Flush
									If API_LoginUrl <> "0" Then
										Response.Write "<script language=JavaScript>"
										Response.Write "setTimeout(""top.location='"& API_LoginUrl &"'"",1000);"
										Response.Write "</script>"
										Response.End
									End If
								End If
								
								
								If KS.S("Action")="PopLogin" Then
								 response.write "<script>window.parent.location.reload(); </script>"
								Else
									Dim ToUrl
									If InStr(lcase(Request.ServerVariables("HTTP_REFERER")), "/login") > 0 Then 
									     ToUrl="index.asp"
									ElseIf InStr(lcase(Request.ServerVariables("HTTP_REFERER")), "login") > 0 Then 
										 ToUrl= KS.GetDomain & "User/userlogin.asp?action=" & KS.S("Action")
									else
										 ToUrl= Request.ServerVariables("HTTP_REFERER")
									end if
									if GCls.ComeUrl<>"" then 
									 ToUrl=GCls.ComeUrl
									 GCls.ComeUrl=""
									 if request("from3g")="1" then
									 response.write "<script>location.href='" & ToUrl & "';</script>"
									 else
									 response.write "<script>top.location.href='" & ToUrl & "';</script>"
									 end if
									Else
									 response.write "<script>location.href='" & ToUrl & "';</script>"
									End If
								End If
			 End IF
			
        End Sub
End Class
%>

 
