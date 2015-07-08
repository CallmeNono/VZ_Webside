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
Set KSCls = New SaveData
KSCls.Kesion()
Set KSCls = Nothing

Class SaveData
        Private KS,KSUser,Node,LoginTF,FieldRndID,TopicID,UserID,PostTable,verific
        Private UserName, Email, Subject, Oicq, Verifycode, IP, Pic, TxtHead, HomePage, Content, ErrorMsg, a,BoardID,Purview,ShowIP,ShowSign,ShowScore,CategoryId,PopTips,posttype,VoteItemArr,VoteNum,VoteNumArr,voteitem,ValidDays,TimeBegin,TimeEnd,voteid,i
		Private O_LastPost,N_LastPost,O_LastPost_A,BSetting,Master,UserDefineFieldArr,ClassID,FieldXML,FieldNode
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
	   %>
	   <!--#include file="../KS_Cls/ClubFunction.asp"-->
	   <!--#include file="../KS_Cls/ubbFunction.asp"-->
	   <%
	   Public Sub Kesion()
		Dim I,SplitStrArr
		If KS.CheckOuterUrl() = TRUE Then '外部提交的数据
			Call KS.Alert("数据提交错误!", "")
			Exit Sub
		End If
		If Request.servervariables("REQUEST_METHOD") <> "POST" Then
			KS.Die "<script>alert('请不要非法提交！');</script>"
		End If
		If KS.IsNul(Request.ServerVariables("HTTP_REFERER")) Then
			KS.Die "<script>alert('请不要非法提交！');</script>"
		End If
		if instr(lcase(Request.ServerVariables("HTTP_REFERER")),"post.asp")<=0 then
			KS.Die "<script>alert('非法提交！');</script>"
		end if
		
		LoginTF=KSUser.UserLoginChecked
		If KS.ChkClng(KS.C("UserID"))<>0 Then
			UserID = KS.ChkClng(KS.C("UserID"))
		Else
			UserID = KS.ChkClng(KSUser.GetUserInfo("userid"))
		End If
		
	   If KS.Setting(57)="1" and LoginTF=false Then
	     KS.Die "<script>alert('没有发表权限!');</script>"
	   End If
		
		FieldRndID=Session("Rnd")

		if mid(KS.Setting(161),3,1)="1" Then
			If KS.IsNul(Session("Qid")) Then
			 Call KS.Alert("会话超时，请重新打开发帖窗口再提交!", "")
			 Exit Sub
			Else
			 If Lcase(Request.Form("Answer" & FieldRndID))<>Lcase(Split(KS.GetCurrQuestion(163),vbcrlf)(KS.ChkClng(Session("Qid")))) Then
				 KS.Die "<script>alert('对不起，您的回答不正确!');</script>"
				 Exit Sub
			 End If
			End If
		End If
		
		Dim LastLoginIP:LastLoginIP = KS.GetIP
			UserName = KS.S("Name")
			Email = KS.S("Email")
			HomePage = KS.S("HomePage")
			Oicq = KS.ChkClng(KS.S("Oicq"))
			Verifycode = KS.S("verifycode")
			IP = LastLoginIP
			Pic = KS.S("Pic")
			TxtHead = KS.S("txthead")
			Subject = KS.S("Subject")
			posttype=KS.ChkClng(KS.S("posttype"))
			If posttype=1 Then  '投票
			 voteitem=KS.S("voteitem")
			 If KS.IsNul(voteitem) Then
				 KS.Die "<script>alert('对不起，投票帖必须输入投票选项!');</script>"
				 Exit Sub
			 End If
			 VoteItemArr=Split(voteitem,",")
			 If Ubound(VoteItemArr)<1 Then
				 KS.Die "<script>alert('对不起，投票选项不能少于两项!');</script>"
				 Exit Sub
			 End If
			 ValidDays=KS.ChkClng(Request.Form("ValidDays"))
			 If KS.S("timelimit")="1" And ValidDays<=0 Then
				 KS.Die "<script>alert('对不起，有效天数必须大于0!');</script>"
				 Exit Sub
			 End If
			 TimeBegin=now
			 TimeEnd=dateadd("d",ValidDays,now)
			End If
			
			
			Content = Request.Form("Content")
			'Content=replace(Content,chr(10),"[br]")
			'非管理员及版主过滤标题html
			If KSUser.GetUserInfo("ClubSpecialPower")="0"  Then
			 Subject=KS.LoseHtml(Subject)
			End If

			BoardID=KS.ChkClng(KS.S("BoardID"))
			Purview=KS.ChkClng(Request.Form("purview"))
			showip=KS.ChkClng(Request.Form("showip"))
			showsign=KS.ChkClng(Request.Form("showsign"))
			showscore=KS.ChkClng(Request.Form("showscore"))
			CategoryId=KS.ChkClng(Request.Form("CategoryId"))
			Content=KS.FilterIllegalChar(Content)
			If KS.IsNul(Pic) Then Pic=KS.GetPictureFromStr(ubbcode(content,1),1)
			
			'防发帖机
            dim kk,sarr
            sarr=split(WordFilter,"|")
            for kk=0 to ubound(sarr)
               if instr(KS.R(content),sarr(kk))<>0 or instr(KS.R(Subject),sarr(kk))<>0 then 
                  ks.die "<script>alert('含有非法关键词:" & sarr(kk) &",请不要非法提交恶意信息！');</script>"
               end if
            next
				
		If Content="" Then KS.Die "<script>alert('对不起，发表内容不能为空！!');</script>"
	    If BoardID<>0 Then
			 KS.LoadClubBoard()
			 Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
			 O_LastPost=Node.SelectSingleNode("@lastpost").text
			 BSetting=Node.SelectSingleNode("@settings").text
			 Master=Node.SelectSingleNode("@master").text
	    Else
		 KS.Die "<script>alert('对不起，没有选择发帖版面！!');</script>"
		End If
			BSetting=BSetting&"$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$"
			BSetting=Split(BSetting,"$")
			
			If KS.ChkClng(BSetting(59))=1 Then
			Content=KS.ClearBadChr(Content)
			Else
			Content=Server.HTMLEncode(Content)    '如果编辑器开启html功能，则这段要屏掉
		    End If
			
			CheckEnter
			If KS.ChkCLng(BSetting(40))<>0 Then
			  If len(replace(replace(KS.LoseHtml(Content),"	",""),vbcrlf,""))<KS.ChkCLng(BSetting(40)) Then
				Call KS.Alert("内容字数不能少于" &KS.ChkCLng(BSetting(40)) & "个字节!" , "")
				Response.End
			  End If
			End If
			
			If KS.ChkClng(BSetting(57))<>0 And showscore>KS.ChkClng(BSetting(57)) Then KS.Die "<script>alert('售价不能高于" & KS.ChkClng(BSetting(57)) & "!');</script>"

		     
			If KS.S("Action")="edit" Then
			 EditSave()
			Else 
			 SaveData()
			End If
			
			If verific="0" Then   '帖子需要审核
			  if KS.ChkClng(request("from3g"))=1 then
			   Response.Write("<script>alert('发布成功,您发表的主题审核后才会显示！');parent.location.href='../3g/bbs.asp?boardid=" & boardid & "';</script>")

			 else
			    Response.Write("<script>alert('发布成功,您发表的主题审核后才会显示！');top.location.href='" & KS.GetClubListUrl(boardid) & "';</script>")
			  end if
			Else
				Session("PopTips")=PopTips
				if KS.ChkClng(request("from3g"))=1 then
				 Response.Write("<script>parent.location.href='../3g/display.asp?id=" & topicid &" ';</script>")
				else
				 Response.Write("<script>top.location.href='" & KS.GetClubShowUrl(TopicID)& "';</script>")
				end if
			End If
	End Sub
	
	Function CheckEnter()
	        If KS.C("UserName")="" then
			  UserName="游客：" & UserName
			Else
			  UserName=KS.C("UserName")
			end if
			IF lcase(Trim(Verifycode))<>lcase(Trim(Session("Verifycode"))) And KS.ChkClng(BSetting(53))=1 then 
			 KS.Die "<script>alert('验证码有误，请重新输入！');</script>"
			Else
			    If Subject="" Then  KS.Die "<script>alert('请填写主题！');</script>"
			End If
		End Function
		
		'新增保存
		Sub SaveData()
			if datediff("n",KSUser.GetUserInfo("RegDate"),now)<KS.ChkClng(bsetting(9)) Then
				KS.Die "<script>alert('对不起,本版面限制" & bsetting(9) & "分钟内注册的会员不能发帖!');</script>"
			End if
			If (Not KS.IsNul(BSetting(2)) Or KS.ChkCLng(BSetting(3))<0) And LoginTF=false Then
				KS.Die "<script>alert('对不起,请先登录!');parent.ShowLogin()</script>"
			End If
			If KS.ChkCLng(BSetting(3))<0 And KS.ChkCLng(KSUser.GetUserInfo("Score"))<-KS.ChkCLng(BSetting(3)) Then
				KS.Die "<script>alert('对不起,在此版面发帖的需要清耗" & -KS.ChkCLng(BSetting(3)) & "分的积分,您当然积分余额为" & KSUser.GetUserInfo("Score") & "分不足以支付!');</script>"
			End If
			
			If KS.ChkClng(BSetting(41))<>0 Then
             If IsDate(Session(KS.SiteSN & "posttime"))  Then
				If DateDiff("s",Session(KS.SiteSN & "posttime"),Now())<KS.ChkClng(BSetting(41)) Then
					KS.Die "<script>alert('对不起,此版面设定发帖间隔时间不能少于" & BSetting(41)& "秒!');</script>"
				End If
			 End If
			 Session(KS.SiteSN & "posttime")=Now()
			End If
						
			Dim GroupPurview:GroupPurview= True : If Not KS.IsNul(BSetting(2)) and KS.FoundInArr(Replace(BSetting(2)," ",""),KSUser.GroupID,",")=false Then GroupPurview=false
			Dim LimitPostNum:LimitPostNum=KS.ChkClng(BSetting(13))
			If KSUser.GroupID<>1 Then  '判断有没有权限
				         Dim CheckResult:CheckResult=CheckPermissions(KSUser,BSetting,"")
						 If CheckResult<>"true" Then
						    'KS.Die "<script>alert('"& CheckResult &"');<//script>"
						    KS.Die "<script>alert('对不起,认证版本，您没有权限发表！');</script>"
						 ElseIf GroupPurview=false Then  '判断有没有启用用户组
							KS.Die "<script>alert('对不起,您的级别不能在本版面发帖!');</script>"
					     ElseIf KSUser.GetUserInfo("LockOnClub")="1" Then
							KS.Die "<script>alert('对不起,您的账号在本论坛被锁定,无权发帖!');</script>"
					     ElseIf LimitPostNum>0 Then
								 Dim PostNum:PostNum=Conn.Execute("Select count(1) From KS_GuestBook Where BoardId=" & BoardID & " and UserName='" & KSUser.UserName &"' And DateDiff(" & DataPart_D & ",AddTime," & SqlNowString & ")<1")(0)
								 If PostNum>=LimitPostNum Then
								    KS.Die "<script>alert('对不起,本版面每天限制发表" & LimitPostNum & "个主题，您已发布了" & PostNum & "个主题!');</script>"
								 End If
						End If
			 End If 
			
			If KS.IsNul(Subject) Then Subject=Left(KS.LoseHtml(Content),100)
			
			Dim ChannelID:ChannelID=KS.ChkClng(BSetting(60))
			If ChannelID<>0 Then   '绑定模型
			 Call KSCls.LoadModelField(ChannelID,FieldXML,FieldNode)
			 Call KSUser.CheckDiyField(FieldXML,false)
			End If
			
			If KS.ChkClng(BSetting(63))=1 Then  '远程存图
					Dim SaveFilePath:SaveFilePath = KS.ReturnChannelUserUpFilesDir(9994,KS.Setting(67))
					KS.CreateListFolder(SaveFilePath)
					Content = KS.ReplaceBeyondUrl(Content, SaveFilePath)
			End If
			
			verific=KS.ChkClng(BSetting(61)): If verific=2 Or Verific=1 Then verific=0 Else Verific=1
			
			'保存数据，并返回帖子ID号
			If ChannelID<>0 Then   '绑定模型,则content只保存到模型表里。以减少数据库压力
		     TopicID=InsertPost(BoardID,PostType,UserName,UserID,Subject," ",Pic,KS.S("AnnexExt"),Purview,ShowIP,ShowSign,ShowScore,CategoryId,0,0,0,0,O_LastPost,verific,PostTable)
			Else
		     TopicID=InsertPost(BoardID,PostType,UserName,UserID,Subject,Content,Pic,KS.S("AnnexExt"),Purview,ShowIP,ShowSign,ShowScore,CategoryId,0,0,0,0,O_LastPost,verific,PostTable)
			End If
			
			If posttype=1 Then   '投票
			      Dim RSObj:Set RSObj=Server.CreateObject("ADODB.RECORDSET")
					rsobj.open "select top 1 * from KS_Vote",conn,1,3
					rsobj.addnew
						 rsobj("TopicID")=TopicID
						 rsobj("Title")=Subject
						 rsobj("timelimit")=KS.ChkClng(KS.G("TimeLimit"))
						 rsobj("TimeBegin")=TimeBegin
						 rsobj("TimeEnd")=TimeEnd
						 rsobj("nmtp")=KS.ChkClng(Request("nmtp"))
						 rsobj("groupids")=""
						 rsobj("ipnum")=1
						 rsobj("ipnums")=1
						 rsobj("templateid")="{@TemplateDir}/投票页.html"
						 rsobj("status")=1
						 rsobj("AddDate")=Now
						 rsobj("VoteType")=KS.S("VoteType")
						 rsobj("UserName")=UserName
						 rsobj("NewestTF")=0
						 rsobj("VoteNums")=0
					 rsobj.update
					 rsobj.movelast
					 voteid=rsobj("id")
					 rsobj.close
					 Set RSObj = Nothing

					Dim XMLStr:XMLStr="<?xml version=""1.0"" encoding=""utf-8"" ?>" &vbcrlf
					XMLStr=XMLStr&" <vote>" &vbcrlf
					for i=0 to ubound(VoteItemArr)
					  if trim(VoteItemArr(i))<>"" Then
					    XMLStr=XMLStr & "  <voteitem id=""" & i+1 &""">"&vbcrlf
						XMLStr=XMLStr & "    <name><![CDATA[" & VoteItemArr(i) &"]]></name>" &vbcrlf
						XMLStr=XMLStr & "    <num>0</num>" &vbcrlf
					    XMLStr=XMLStr & "  </voteitem>"&vbcrlf
					  End If
					Next
					XMLStr=XMLStr &" </vote>" &vbcrlf
					Call KS.WriteTOFile(KS.Setting(3) & "config/voteitem/vote_" & voteid & ".xml",xmlstr)
			        Application(KS.SiteSN&"_Configvoteitem/vote_"&VoteID)=empty
			End If
			
			If ChannelID<>0 Then   '绑定模型
			  	 Dim Fname,FnameType,TemplateID,WapTemplateID
				 ClassID=KS.S("ClassID")
				 FnameType=KS.C_C(ClassID,23)
				 Fname=KS.GetFileName(KS.C_C(ClassID,24), Now, FnameType)
				 TemplateID=KS.C_C(ClassID,5)
				 WapTemplateID=KS.C_C(ClassID,22)
				 Set RSObj=Server.CreateObject("ADODB.RECORDSET")
	             RSObj.Open "Select top 1 * From " & KS.C_S(ChannelID,2) &" Where 1=0",Conn,1,3
				 RSObj.AddNew
				 RSObj("PostId")=TopicId
				 RSObj("PostTable")=PostTable
				 RSObj("Title")=Subject
				 RSObj("Tid")=ClassID
				 RSObj("TemplateID")=TemplateID
				 RSObj("WapTemplateID")=WapTemplateID
                 RSObj("Fname")=FName
				 RSObj("Adddate")=Now
				 RSObj("Rank")="★★★"
				 RSObj("Hits")=0
				 RSObj("Comment")=1
				 RSObj("Verific")=Verific
				 RSObj("Inputer")=UserName
				 RSObj("ArticleContent")=Content
				 Call KSUser.AddDiyFieldValue(RSObj,FieldXML)
				 RSObj.Update
				RSObj.MoveLast
				Dim InfoID:InfoID=RSObj("ID")
				If Left(Ucase(Fname),2)="ID" Then
						RSObj("Fname") = InfoID & FnameType
						RSObj.Update
				End If
				 RSObj.Close:Set RSObj=Nothing
				 Call LFCls.InserItemInfo(ChannelID,InfoID,Subject,ClassId,Subject," "," ",UserName,Verific,Fname)
				 Conn.Execute("Update KS_GuestBook Set ChannelID=" & ChannelID & ",InfoID=" & InfoID & " Where ID=" & TopicID )
			End If
			
			Dim FileIds:FileIds=LFCls.GetFileIDFromContent(Content)
            If Not KS.IsNul(FileIds) Then 
				 Conn.Execute("Update [KS_UpLoadFiles] Set InfoID=" & TopicID &",classID=" & BoardID & " Where ID In (" &FileIds & ")")
			End If
			
			If KS.ChkClng(BSetting(3))>0 and LoginTF=true Then
			    PopTips="<strong>积分" & KSUser.GetUserInfo("Score") &"+</strong>" & KS.ChkClng(BSetting(3))
				Call KS.ScoreInOrOut(KSUser.UserName,1,KS.ChkClng(BSetting(3)),"系统","在论坛发表主题[" & Subject & "]所得!",0,0)
			End If
			If KS.ChkClng(BSetting(3))<0 and LoginTF=true Then
			    PopTips="<strong>积分" & KSUser.GetUserInfo("Score") &"-</strong>" & -KS.ChkClng(BSetting(3))
				Session("ScoreHasUse")="+" '设置只累计消费积分
				Call KS.ScoreInOrOut(KSUser.UserName,2,-KS.ChkClng(BSetting(3)),"系统","在论坛发表主题[" & Subject & "]消费!",0,0)
			End If
			If LoginTF=true Then
			  If KS.ChkClng(BSetting(30))<>0 Then
			  if PopTips="" then
			   PopTips="<strong>威望" & KSUser.GetUserInfo("Prestige") &"+</strong>" & -KS.ChkClng(BSetting(30))
			  Else
			   PopTips=PopTips & ",<strong>威望" & KSUser.GetUserInfo("Prestige") &"+</strong>" & KS.ChkClng(BSetting(30))
			  end if
			  If IsObject(Session(KS.SiteSN&"UserInfo")) Then Session(KS.SiteSN&"UserInfo").DocumentElement.SelectSingleNode("row").SelectSingleNode("@prestige").Text=KS.ChkClng(KSUser.GetUserInfo("Prestige"))+KS.ChkClng(BSetting(30))
			  Conn.Execute("Update KS_User Set Prestige=Prestige+" & KS.ChkClng(BSetting(30)) & " Where UserName='" & KSUser.UserName &"'")
			  End If
			  
			  '====================同步微博====================================
			  If BSetting(67)="1" Then
				  Dim WeiboContent:WeiboContent="主题：[url=" & KS.GetClubShowUrl(TopicID) &"]" & left(Subject,40) &"[/url][br]"
				  If Content<>"" Then 
					if ks.isnul(pic) then
					  WeiboContent=WeiboContent & Left(KS.LoseHtml(UbbCode(Content,0)),130) 
					else
					  WeiboContent=WeiboContent & Left(KS.LoseHtml(UbbCode(Content,0)),90) &"[br][img]" &replace(lcase(pic),lcase(ks.setting(2)) ,"") & "[/img]"
					end if
				  end if
				  Call KSUser.AddToWeibo(KSUser.UserName,WeiboContent,1)
				End If
			End If
			'===================================================================
			
		End sub
		
		'修改保存数据
		Sub EditSave
		 Dim TopicID:TopicID=KS.ChkClng(KS.S("TopicID"))
		 Dim ReplyID:ReplyID=KS.ChkClng(KS.S("replyId"))
		 Dim IsTopic:IsTopic=KS.ChkClng(KS.S("IsTopic"))
		 Dim IsTop,Page:Page=KS.ChkClng(KS.S("Page"))
		 If Page=0 Then Page=1
		 Dim PostUserName,ChannelID,InfoID
		 if TopicID=0 Or ReplyID=0 Then
			 KS.Die "<script>alert('参数出错!');</script>"
		 End If
		 
		 
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select top 1 PostTable,IsTop,ChannelID,InfoID From KS_GuestBook Where ID=" & TopicID,conn,1,1
		 If RS.Eof And RS.Bof Then
		    RS.Close : Set RS=Nothing
		    KS.Die "<script>alert('参数出错!');</script>"
		 End If
		    PostTable=RS(0):IsTop=RS(1): ChannelID=RS(2):InfoID=RS(3)
		 RS.Close
		 RS.Open "Select top 1 * From " & PostTable  & " Where ID=" & ReplyID,conn,1,3
	     If RS.Eof And RS.Bof Then
		    RS.Close : Set RS=Nothing
		    KS.Die "<script>alert('参数出错!');</script>"
		  End If
		  PostUserName=RS("UserName")
		  
		  
		  '检查编辑权限
		  If CheckIsMater=false Then
			If KSUser.UserName<>PostUserName Or KS.ChkClng(BSetting(29))=0 Then
			  RS.Close :Set RS=Nothing
			  KS.Die "<script>alert('对不起,您没有修改帖子权限!');</script>"
			End If
		  End If
		  If IsTopic=1 And KS.ChkClng(ChannelID)<>0 And KS.ChkClng(InfoID)<>0  And Instr(RS("Content"),"$@$")<>0 Then
				Content="$@$"&Split(RS("Content"),"$@$")(1)
		  Else
			  If rs("parentid")=0 and Instr(RS("Content"),"$@$")<>0 Then
				Content=Content&"$@$"&Split(RS("Content"),"$@$")(1)
			  End If
		  End If
			  If KS.ChkClng(BSetting(63))=1 Then  '远程存图
						Dim SaveFilePath:SaveFilePath = KS.ReturnChannelUserUpFilesDir(9994,KS.Setting(67))
						KS.CreateListFolder(SaveFilePath)
						Content = KS.ReplaceBeyondUrl(Content, SaveFilePath)
			  End If
		       RS("Content")=Content
		       RS("ShowSign")=ShowSign
			   RS("ShowIP")=ShowIP
		  RS.Update
		  RS.Close:Set RS=Nothing
		  
		  	If IsTopic=1 then 
				Dim IsPic:IsPic=0
				If Not KS.IsNul(Pic) Then
				   If lcase(Right(pic,"3"))="gif" Then IsPic=1 Else IsPic=2
				Else '当图片不存在时默认关闭该主题的幻灯
				 Conn.Execute("Update KS_GuestBook Set isSlide=0 Where ID=" & TopicID)
				End If
				Conn.Execute("Update KS_GuestBook Set isPic=" & IsPic &",Face='"&Pic&"' Where ID=" & TopicID)
			End If

		  
		    Dim FileIds:FileIds=LFCls.GetFileIDFromContent(Content)
            If Not KS.IsNul(FileIds) Then 
				 Conn.Execute("Update [KS_UpLoadFiles] Set InfoID=" & TopicId &",classID=" & BoardID & " Where ID In (" &FileIds & ")")
			End If
		  
		  If IsTopic=1 Then
		   
		     If ChannelID<>0 And InfoID<>0 Then  '绑定模型
			    ClassID=KS.S("ClassID")
				 Call LoadModelField(ChannelID,FieldXML,FieldNode)
				   Set RSObj=Server.CreateObject("ADODB.RECORDSET")
					 RSObj.Open "Select top 1 * From " & KS.C_S(ChannelID,2) &" Where ID=" & InfoID,Conn,1,3
					 RSObj("Title")=Subject
					 RSObj("Tid")=ClassID
					 RSObj("ArticleContent")=KS.FilterIllegalChar(Request.Form("Content"))
					 Call KSUser.AddDiyFieldValue(RSObj,FieldXML)
					 RSObj.Update
					 RSObj.Close:Set RSObj=Nothing
					 Call LFCls.ModifyItemInfo(ChannelID,InfoID,Subject,classid,Content,"","",1)
			 End IF
			 
		     If PostType=1 Then
			        VoteNum=KS.S("VoteNum") &",0,0,0,0,0,0,0,0,0,0,0,0"
					VoteNumArr=Split(VoteNum,",")
			        Dim RSObj:Set RSObj=Server.CreateObject("adodb.recordset")
			        rsobj.open "select top 1 * from KS_Vote Where TopicID=" &TopicID ,conn,1,3
					If Not rsobj.eof Then
						 rsobj("Title")=Subject
						 rsobj("timelimit")=KS.ChkClng(KS.G("TimeLimit"))
						 rsobj("TimeBegin")=TimeBegin
						 rsobj("TimeEnd")=TimeEnd
						 rsobj("nmtp")=KS.ChkClng(Request("nmtp"))
						 rsobj("VoteType")=KS.S("VoteType")
					 rsobj.update
					 rsobj.movelast
					 voteid=rsobj("id")
					
					Dim XMLStr:XMLStr="<?xml version=""1.0"" encoding=""utf-8"" ?>" &vbcrlf
					XMLStr=XMLStr&" <vote>" &vbcrlf
					for i=0 to ubound(VoteItemArr)
					  if trim(VoteItemArr(i))<>"" Then
					    XMLStr=XMLStr & "  <voteitem id=""" & i+1 &""">"&vbcrlf
						XMLStr=XMLStr & "    <name><![CDATA[" & VoteItemArr(i) &"]]></name>" &vbcrlf
						XMLStr=XMLStr & "    <num>" & VoteNumArr(i) & "</num>" &vbcrlf
					    XMLStr=XMLStr & "  </voteitem>"&vbcrlf
					  End If
					Next
					XMLStr=XMLStr &" </vote>" &vbcrlf
					Call KS.WriteTOFile(KS.Setting(3) & "config/voteitem/vote_" & voteid & ".xml",xmlstr)
			        Application(KS.SiteSN&"_Configvoteitem/vote_"&VoteID)=empty
				End If
				rsobj.close : Set RSObj=Nothing
			 End If
		  
		    Conn.Execute("Update KS_GuestBook Set ShowScore=" & ShowScore &",Subject='" & Subject & "',categoryid=" & KS.ChkClng(KS.S("CategoryID")) &" Where ID=" & TopicID)
			Call KS.FileAssociation(1036,ReplyID,Content,1)
		  Else
		    Call KS.FileAssociation(1035,ReplyID,Content,0)
		  End If
          If IsTop<>0 Then MustReLoadTopTopic
       
		  
          KS.Die "<script>top.location.href='" & KS.GetClubShowUrlPage(TopicId,Page) & "';</script>"
		End Sub
		
		
		'检查版主或管理员
       function CheckIsMater()
	    If Cbool(LoginTF)=false Then
		  CheckIsMater=false : Exit Function
		Elseif KSUser.GetUserInfo("ClubSpecialPower")=1 Or KSUser.GetUserInfo("ClubSpecialPower")=2 Or KSUser.GroupID=1 Then
		  CheckIsMater=true : Exit function
		else
		  CheckIsMater=KS.FoundInArr(master, KSUser.UserName, ",")
		end if
       End function
End Class
%> 
