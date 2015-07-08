<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.ClubCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New Guest_SaveData
KSCls.Kesion()
Set KSCls = Nothing

Class Guest_SaveData
        Private KS,KSUser,Node,BSetting,PostTable,Rid,TopicNode,PopTips,UserID
        Private UserName,Subject, TxtHead, Content, ErrorMsg,TopicID,BoardID,LoginTF,ShowIP,ShowSign
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
	   <%
	   Sub Tips(str)
	    %>
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml" >
			<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
			<title>操作提示消息！</title>
			<script src="../ks_inc/jquery.js" type="text/javascript"></script>
			<script src="../ks_inc/lhgdialog.js"></script>
			</head>
		    <body>
		   <%
		   if KS.ChkClng(request("from3g"))=1 then
			KS.Die ("<script>alert('" & str & "');history.back();</script>")
		   Else
			KS.Die ("<script>$.dialog.tips('" & str & "',1,'error.gif',function(){;$('#submitbtn',parent.document).attr('value',' 提交回复 (按Ctrl+Enter直接提交) ');	$('#submitbtn',parent.document).attr('disabled',false);	});</script>")
		   End If
		   %>
		   </body>
		   </html>
		   <%
	   End Sub
	   
	   Public Sub Kesion()
		Dim I,SplitStrArr
		    If KS.CheckOuterUrl() = TRUE Then 	tips "数据提交错误！"
		    LoginTF=KSUser.UserLoginChecked
			If KS.Setting(54)<>"3" And LoginTF=false Then
			 tips " 对不起，你没有发表的权限！"
			ElseIf KSUser.GetUserInfo("LockOnClub")="1" Then
			 tips "对不起，你的账号被锁定,无法回帖!"
			ElseIf KS.Setting(54)=1 And KSUser.GroupID<>1 Then
			 tips "对不起，本站只允许管理人员回复!"
			ElseIf KS.Setting(54)=2 And LoginTF=False Then
			 tips "对不起，本站至少要求是会员才可以发表回复！"
			End If
			If KS.Setting(54)<>"3" And LoginTF=false Then KS.Die ("<script>alert('没有发表权限!');</script>")
			BoardID=KS.ChkClng(Request("BoardID"))
			If BoardID<>0 Then
			 KS.LoadClubBoard()
			 Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
			 BSetting=Node.SelectSingleNode("@settings").text
			End If
			BSetting=BSetting & "$$$0$0$0$0$0$0$1$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$"
			BSetting=Split(BSetting,"$")
			'If Not KS.IsNul(BSetting(2)) And KS.FoundInArr(BSetting(2),KSUser.GroupID,",")=false Then KS.Die escape("error|你所在的用户组,没有发表权限!")
			
			If LoginTF= True Then UserName=KSUser.UserName Else UserName="游客"
			TopicID = KS.ChkClng(KS.S("TopicID"))
			If KS.ChkClng(KS.C("UserID"))<>0 Then
			    UserID = KS.ChkClng(KS.C("UserID"))
			Else
				UserID = KS.ChkClng(KSUser.GetUserInfo("userid"))
			End If
			
			Content = UnEscape(Request.Form("Content"))
			If KS.IsNul(Content) Then tips "回复字数必须录入!"
			If len(replace(replace(KS.LoseHtml(Content),"	",""),vbcrlf,""))<KS.ChkCLng(BSetting(40)) Then tips "回复字数不能少于" & KS.ChkCLng(BSetting(40)) & "个字符!"

			Content=replace(Content,chr(10),"[br]")
            Content=Server.HTMLEncode(Content)
			Content=KS.CheckScript(content)
			ShowIP=KS.ChkClng(Request("showip"))
			ShowSign=KS.ChkClng(Request("showsign"))
			TxtHead = KS.S("TxtHead")
			Content=KS.FilterIllegalChar(Content)
			PostTable=KS.S("PostTable")
			If PostTable="" Then tips "非法参数！"
			If lcase(left(PostTable,8))<>"ks_guest" Then tips "非法参数！"
			
		    If TopicID=0 Then tips "非法参数!"
	        If Content="" Then tips "你没有输入回复内容!"
			If KS.ChkClng(BSetting(14))=0 Then   '判断是否回复自己的帖子
			  If Conn.Execute("Select top 1 UserName From KS_GuestBook Where ID=" & TopicID)(0)=UserName And UserName<>"游客" Then
			  tips "本版面设置会员不能回复自己的主题帖!"
			  End If
			End If
			
			'防发帖机
            dim kk,sarr
            sarr=split(WordFilter,"|")
            for kk=0 to ubound(sarr)
               if instr(Content,sarr(kk))<>0 then 
                  tips "含有非常关键词:" & sarr(kk) &",请不要非法提交恶意信息！"
               end if
            next
			
			If KS.ChkClng(BSetting(41))<>0 Then
             If IsDate(Session(KS.SiteSN & "posttime"))  Then
				If DateDiff("s",Session(KS.SiteSN & "posttime"),Now())<KS.ChkClng(BSetting(41)) Then
				   tips "请休息下稍候再灌,此版面设定发帖间隔时间不能少于" & BSetting(41)& "秒!"
				End If
			 End If
			 Session(KS.SiteSN & "posttime")=Now()
			End If
			
			Dim GroupPurview:GroupPurview= True : If Not KS.IsNul(BSetting(62)) and KS.FoundInArr(Replace(BSetting(62)," ",""),KSUser.GroupID,",")=false Then GroupPurview=false
			If KSUser.GroupID<>1 Then  '判断有没有权限
				         Dim CheckResult:CheckResult=CheckPermissions(KSUser,BSetting,"")
						 If CheckResult<>"true" Then
						    tips "对不起,认证版本，您没有权限发表！"
						 ElseIf GroupPurview=false Then  '判断有没有启用用户组
							tips "对不起,您的级别不能在本版面发帖!"
					     ElseIf KSUser.GetUserInfo("LockOnClub")="1" Then
							tips "对不起,您的账号在本论坛被锁定,无权发帖!"
						End If
			 End If 
			
			

			SaveData
			If KS.ChkClng(KS.S("IsTop"))<>0 Then MustReLoadTopTopic
			If KS.ChkClng(KS.S("toend"))=1 Then
			 Dim MaxPerPage:MaxPerPage=KS.ChkClng(BSetting(21)) : If MaxPerPage=0 Then MaxPerPage=10
			 Dim Page,totalPut:totalPut=Conn.Execute("Select count(1) From " & PostTable &" Where Verific=1 and TopicID=" & TopicID)(0)
			 If totalput Mod MaxPerPage = 0 Then
				Page=totalput\MaxPerPage
			 Else
				Page=totalput\MaxPerPage + 1
			 End If
			 Session("PopTips")=PopTips
			 if KS.ChkClng(request("from3g"))=1 then
			  response.redirect "../3g/display.asp?id=" & topicid & "&page=" & page
			 else
			   ks.die "<script>top.location.href='" &  KS.GetClubShowUrlPage(TopicID,page) & "';</script>"
			 end if
			ElseIf KS.ChkClng(Session("TopicMustReply"))=1 Then
			 Session("PopTips")=PopTips
			 KS.Die ("<script>top.location.href='" & KS.GetClubShowUrl(TopicID) & "';</script>")
			Else
			 Dim UserXml,UN,LC
			 Dim Floor:Floor=Conn.Execute("Select Count(1) From " & PostTable &" Where TopicID=" & TopicID)(0)-1
			 Dim KesionClub:Set KesionClub=New ClubDisplayCls
			 Dim RSU:Set RSU=Conn.Execute("Select top 1 " & KesionClub.UserFields & " From KS_User Where UserName='" & UserName & "'")
			 If Not RSU.Eof Then Set UserXml=KS.RsToXml(RSU,"row","")
			 RSU.Close :Set RSU=Nothing
			 If IsObject(UserXML) Then set UN=UserXml.DocumentElement.SelectSingleNode("row[@username='" & TopicNode.SelectSingleNode("@username").text & "']") Else Set UN=Nothing
			 Set KesionClub.TopicNode=TopicNode
			 Set KesionClub.UN=UN
			 KesionClub.PostUserName=TopicNode.SelectSingleNode("@username").text
			 KesionClub.BSetting=BSetting
			 KesionClub.N=Floor+1
			 KesionClub.TopicID=TopicID
			 KesionClub.BoardID=BoardID
			 Set KesionClub.KSUser=KSUser
			 KesionClub.ReplayID=TopicNode.SelectSingleNode("@id").text
			 KesionClub.Immediate=false
			 KesionClub.Scan Application(KS.SiteSN&"LoopTemplate"&BoardID)
			' KS.Echo (PopTips&"@@@@@"&KesionClub.Templates)
			 Dim JS:JS=replace(Replace(Replace(Replace(Replace(Replace(KesionClub.Templates, Chr(13)& Chr(10), ""),"'","\'"),"""","\"""),vbcrlf,""),chr(13),""),chr(10),"")
			 PopTips= Replace(Replace(Replace(Replace(Replace(Replace(PopTips, Chr(13)& Chr(10), ""),"'","\'"),"""","\"""),vbcrlf,""),chr(13),""),chr(10),"")        
			 KS.DIE "<script type='text/javascript' src='../ks_inc/jquery.js'></script><script>parent.Editor.writeEditorContents('');$('#ShowTopicByAjax', parent.document).append('" & JS & "');parent.popShowMessage('" & PopTips &"');$('#submitbtn',parent.document).attr('value',' 提交回复 (按Ctrl+Enter直接提交) ');	$('#submitbtn',parent.document).attr('disabled',false);	</script>"   
			 Set KesionClub=Nothing
			 KS.Die ""
			End If
	End Sub
		
	Sub SaveData()
		    Dim verific:verific=KS.ChkClng(BSetting(61)): If verific=2 Or Verific=3 Then verific=0 Else Verific=1
			  If KS.ChkClng(BSetting(63))=1 Then  '远程存图
						Dim SaveFilePath:SaveFilePath = KS.ReturnChannelUserUpFilesDir(9994,KS.Setting(67))
						KS.CreateListFolder(SaveFilePath)
						Content = KS.ReplaceBeyondUrl(Content, SaveFilePath)
			  End If
			
	        '写入回复表
		    Call InsertReply(PostTable,UserName,UserID,TopicID,Content,ShowIP,ShowSign,TopicID,Verific,SQLNowString)
			Dim O_LastPost,N_LastPost,O_LastPost_A
			Rid=Conn.Execute("Select Max(ID) From " & PostTable)(0) '回复ID
			If KS.ChkClng(KS.S("toend"))=0 Then
			 Dim RSObj:Set RSObj=Conn.Execute("Select top 1 * From " & PostTable & " Where ID=" & Rid)
			 Dim Xml: Set Xml=KS.RsToXml(RSObj,"","row")
			 Set TopicNode=Xml.DocumentElement.SelectSingleNode("row")
			End If
			
			'关联上传文件
			Call KS.FileAssociation(1036,RID,Content,0)
			
            Dim FileIds:FileIds=LFCls.GetFileIDFromContent(Content)
            If Not KS.IsNul(FileIds) Then 
				 Conn.Execute("Update [KS_UpLoadFiles] Set InfoID=" & TopicId &",classID=" & BoardID & " Where ID In (" &FileIds & ")")
			End If			


			Dim Subject:Subject=KS.DelSQL(Replace(UnEscape(Request("Subject")),"%","％"))
			Conn.Execute("Update KS_GuestBook Set LastReplayTime=" & SqlNowString &",LastReplayUser='" & UserName &"',LastReplayUserID=" & UserID & ",TotalReplay=TotalReplay+1 where id=" & TopicID)
			
			N_LastPost=topicid & "$" & now & "$" & Replace(Subject,"$","") &"$" & UserName & "$" &UserID&"$$"
			
			If KS.ChkClng(BSetting(4))>0 and LoginTF=true Then
			     PopTips="<strong>积分" & KSUser.GetUserInfo("Score") &"+</strong>" & KS.ChkClng(BSetting(4))
				 Call KS.ScoreInOrOut(KSUser.UserName,1,KS.ChkClng(BSetting(4)),"系统","在论坛回复主题[" & Subject & "]所得!",0,0)
			End If
			If KS.ChkClng(BSetting(4))<0 and LoginTF=true Then
			    PopTips="<strong>积分" & KSUser.GetUserInfo("Score") &"-</strong>" & -KS.ChkClng(BSetting(4))
				Session("ScoreHasUse")="+" '设置只累计消费积分
				Call KS.ScoreInOrOut(KSUser.UserName,2,-KS.ChkClng(BSetting(4)),"系统","在论坛回复主题[" & Subject & "]消费!",0,0)
			End If
			
            If LoginTF=true Then
			  If KS.ChkClng(BSetting(31))<>0 Then
			  if PopTips="" then
			   PopTips="<strong>威望" & KSUser.GetUserInfo("Prestige") &"+</strong>" & KS.ChkClng(BSetting(31))
			  Else
			   PopTips=PopTips & ",<strong>威望" & KSUser.GetUserInfo("Prestige") &"+</strong>" & KS.ChkClng(BSetting(31))
			  end if
			  If IsObject(Session(KS.SiteSN&"UserInfo")) Then Session(KS.SiteSN&"UserInfo").DocumentElement.SelectSingleNode("row").SelectSingleNode("@prestige").Text=KS.ChkClng(KSUser.GetUserInfo("Prestige"))+KS.ChkClng(BSetting(30))
			  Conn.Execute("Update KS_User Set Prestige=Prestige+" & KS.ChkClng(BSetting(31)) & " Where UserName='" & KSUser.UserName &"'")
			  End If
			  If KS.ChkClng(Session("TopicMustReply"))=1 Then  '回复帖，记录回复ID
			   Set RSObj=Server.CreateObject("ADODB.RECORDSET")
			   RSObj.Open "Select top 1 Content From " & PostTable & " Where TopicID=" & TopicID & " and parentid=0",conn,1,3
			   If NOt RSObj.Eof Then
			      Dim CArr:Carr=Split(RSObj(0)&"$@$","$@$")
				  If KS.FoundInArr(Carr(1),KSUser.GetUserInfo("userid"),",")=false Then
				   If Instr(RSObj(0),"$@$")=0 Then
				    RSObj(0)=RSObj(0) &"$@$" & KSUser.GetUserInfo("userid")
				   Else
				    RSObj(0)=RSObj(0) &"," & KSUser.GetUserInfo("userid")
				   End If
				   RSObj.Update
				  End If
			   End If
			   RSObj.Close :Set RSObj=Nothing
			  End If
			End If			
			
			'更新版面数据
			If BoardID<>0 Then
			  KS.LoadClubBoard()
			  O_LastPost=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]/@lastpost").text
			  Call UpdateBoardPostNum(0,BoardID,Verific,O_LastPost,N_LastPost)
			End If
			UpdateTodayPostNum '更新今日发帖数等
			
		End sub
		
		function check()
	 	Dim KSLoginCls,Master
		Set KSLoginCls = New LoginCheckCls1
		If KSLoginCls.Check=true Then
		  check=true
		  Exit function
		else
		    master=LFCls.GetSingleFieldValue("select top 1 master from ks_guestboard where id=" & KS.ChkClng(FCls.RefreshFolderID))
			Dim KSUser:Set KSUser=New UserCls
			If Cbool(KSUser.UserLoginChecked)=false Then 
			  check=false
			  exit function
			else
			   check=KS.FoundInArr(master, KSUser.UserName, ",")
			End If
		end if
 End function	
End Class
%> 
