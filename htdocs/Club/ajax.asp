<!--#include file="../conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.EscapeCls.asp"-->
<!--#include file="../KS_Cls/ClubFunction.asp"-->
<!--#include file="../KS_Cls/UbbFunction.asp"-->
<!--#include file="../Plus/Session.asp"-->
<%
response.cachecontrol="no-cache"
response.addHeader "pragma","no-cache"
response.expires=-1
response.expiresAbsolute=now-1
Response.CharSet="utf-8"
Dim master,BSetting
Dim KS:Set KS=New PublicCls
Dim id:id=KS.ChkClng(KS.S("ID"))
Dim BoardID:BoardID=KS.ChkClng(KS.S("BoardID"))
Dim TopicID:TopicID=KS.ChkClng(KS.S("TopicID"))
Dim Action:Action=KS.S("Action")
select case Action
     case "change" changeIndexStyle
     case "fav" call fav
	 case "delusertopic" call delusertopic
	 case "settop" Call SetTOP
	 case "setbest" Call SetBest
	 case "canceltop" Call CancelTop
	 case "cancelbest" Call CancelBest
	 case "delsubject" Call delsubject
	 case "delreply" Call delreply
	 case "verify" Call verify
	 case "lockorunlock" Call LockorUnlock
	 case "openorclose" Call openorclose
	 case "replylock" call replylock
	 case "replyunlock" call replyunlock
	 case "movetopic" call movetopic
	 case "pushtopic" call pushtopic
	 case "support" support
	 case "opposition" opposition
	 case "lockuser" lockuser
	 case "unlockuser" unlockuser
	 case "verifictopic" verifictopic
	 case "dovote" dovote
	 case "checkcomments" checkcomments
	 case "comments" comments
	 case "getcommentpage" getcommentpage
	 case "delcomment" delcomment
	 case "dotopiccategorysave" dotopiccategorysave
	 case "showchangecategory" showchangecategory 
	 case "showmovietopic" showmovietopic
	 case "showpushtopic" showpushtopic
	 case else ks.die "error!"
End select	
Set KS=Nothing
CloseConn

sub managehead()
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" /> 
<script src="../ks_inc/jquery.js"></script>
<script src="../ks_inc/common.js"></script>
<script src="../ks_inc/lhgdialog.js"></script>
<script src="images/club.js"></script>
<style type="text/css">
body {padding:10px;margin: 0px auto; font: 12px/1.5em Arial Helvetica "sans-serif"; height: 100%;  font-size:12px;}
.btn{border:#0192BE 1px solid;margin-right:1em;color:#fff;background:#2EB8E2;cursor:pointer;padding:.1em 1em;*padding:0 1em;font-size:9pt; height:22px; line-height:22px;overflow:visible;}
</style>
</head>
<body>
<%
end sub

sub showmovietopic()
   managehead
   response.write "<form name='moveform' action='ajax.asp' method='get'><img src='images/p_up.gif'><b>移动帖子：</b>"&KS.S("title")& "<br/><br/>&nbsp;&nbsp;<b>移到版面：</b><span id='showboardselect'></span><div style='text-align:center;margin:20px'><input type='submit' value='确定移动' class='btn'><input type='hidden' value='" & topicid & "' name='id' id='id'><input type='hidden' value='movetopic' name='action'><input type='button' value=' 取 消 ' onclick='parent.box.close()' class='btn'></div></form>"
   response.write "<script type=""text/javascript"">$.get(""../plus/ajaxs.asp"",{action:""GetClubBoardOption""},function(r){ $(""#showboardselect"").html(unescape(r));});</script>"
end sub

sub showpushtopic()
   managehead
   response.write "<div id='showtips'><form name='moveform' action='ajax.asp' method='get'><img src='images/p_up.gif'><b>帖子推送：</b>" & KS.S("title") &"<br/><br/><b>请选择模型：</b><span id='showmodel'></span><select style='width:150px' name='classid' id='classid' size='5'></select><br/><strong>推送选项：</strong><label><input type='checkbox' id='recommend' value='1'>推荐</label> <label><input type='checkbox' id='rolls' value='1'>滚动</label> <label><input type='checkbox' id='strip' value='1'>头条</label> <label><input type='checkbox' id='popular' value='1'>热门</label> <br/><strong>发布选项：</strong><label><input type='checkbox' name='pubindex' id='pubindex' value='1' checked>发布首页</label> <label><input type='checkbox' name='pubclass' id='pubclass' value='1' checked>发布栏目页</label> <label><input name='pubcontent' type='checkbox' id='pubcontent' value='1' checked>发布内容页</label><br/><font color='blue'>tips:建议仅将帖子推送到没有自定义字段的文章模型中！！！</font> <div style='text-align:center;margin:20px'><input type='button' onclick='dopush(" & topicid & ")' value='确定推送' class='btn'><input type='hidden' value=" & topicid & " name='id' id='id'><input type='hidden' value='pushtopic' name='action'><input type='button' value=' 取 消 ' onclick='parent.box.close()' class='btn'></div></form></div>"
   %>
   <script type="text/javascript">
   $.get("../plus/ajaxs.asp",{action:"GetClubPushModel"},function(r){$("#showmodel").html(unescape(r));})
   function dopush(topicid){
	 var modelId=$("#ModelID option:selected").val();
	 if (modelId==undefined){alert('请选择要推送到的模型!');return false;}
	 var classid=$("#classid option:selected").val();
	 if (classid==undefined){alert("请选择栏目!");return false;}
	 var recommend=0;if($("#recommend").attr("checked")){recommend=1;}
	 var rolls=0;if($("#rolls").attr("checked")){rolls=1;}
	 var strip=0;if($("#strip").attr("checked")){strip=1;}
	 var popular=0;if($("#popular").attr("checked")){popular=1;}
	 var pubindex=0;if($("#pubindex").attr("checked")){pubindex=1;}
	 var pubclass=0;if($("#pubclass").attr("checked")){pubclass=1;}
	 var pubcontent=0;if($("#pubcontent").attr("checked")){pubcontent=1;}
	 $.ajax({type:"get",url:"ajax.asp?action=pushtopic&id="+topicid+"&modelid="+modelId+"&classid="+classid+"&recommend="+recommend+"&rolls="+rolls+"&strip="+strip+"&popular="+popular+"&pubindex="+pubindex+"&pubclass="+pubclass+"&pubcontent="+pubcontent+"&anticache=" + Math.floor(Math.random()*1000),cache:false,dataType:"html",success:function(d){
	    d=unescape(d);
		if (d.indexOf('err:')!=-1){
		 alert(d.split(':')[1]);
		}else{
		$("#showtips").html(d);}																																																								   }});
	 return false;
}
</script>
<%
end sub

sub showchangecategory()
   managehead
  response.write "<iframe src='about:blank' name='hidframe' style='display:none'></iframe><form name='cform' action='ajax.asp' method='get' target='hidframe'><img src='images/p_up.gif'><b>更改帖子归类：</b>"& KS.S("title") &"<br/><br/>&nbsp;&nbsp;<b>选择主题归类：</b>" & gettopiccategory &"<div style='text-align:center;margin:20px'><input type='submit' value='确定修改' class='btn'><input type='hidden' value='" & topicid & "' name='topicid' id='topicid'><input type='hidden' value='" & boardid & "' name='boardid' id='boardid'><input type='hidden' value='dotopiccategorysave' name='action'><input type='button' value=' 取 消 ' onclick='parent.box.close()' class='btn'></div></form>"
end sub
function gettopiccategory()
    If BoardID=0 Then KS.Die "error"
 	KS.LoadClubBoard()
	Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
	BSetting=Node.SelectSingleNode("@settings").text
	If KS.IsNul(BSetting) Then KS.Die "err|参数出错!"
	BSetting=Split(BSetting&"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$","$")
	If BSetting(23)<>"0" Then
		Dim CategoryStr,CateGoryID
		CateGoryID=KS.ChkClng(KS.G("CategoryID"))
		KS.LoadClubBoardCategory
		 For Each CategoryNode In Application(KS.SiteSN&"_ClubBoardCategory").DocumentElement.SelectNodes("row[@boardid=" &BoardID &"]")
			if trim(CategoryId)=trim(CategoryNode.SelectSingleNode("@categoryid").text) Then
				CategoryStr=CategoryStr & "<option value='" &CategoryNode.SelectSingleNode("@categoryid").text  & "' selected>" & CategoryNode.SelectSingleNode("@categoryname").text &"</option>"
			Else
				CategoryStr=CategoryStr & "<option value='" &CategoryNode.SelectSingleNode("@categoryid").text  & "'>" & CategoryNode.SelectSingleNode("@categoryname").text &"</option>"
			End If
		 Next
		 If Not KS.IsNul(CategoryStr) Then
			CategoryStr="<select name=""CategoryId"" id=""CategoryId""><option value='0'>主题分类</option>"  & CategoryStr &"</select>"
		  End If
		  gettopiccategory=CategoryStr
     End If
end function

function dotopiccategorysave()
    If BoardID=0 Then KS.Die "error"
	if check=false Then KS.Die "<script>alert('对不起，您没有操作的权限！');top.location.reload();</script>"
 	KS.LoadClubBoard()
	 managehead
	Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
	BSetting=Node.SelectSingleNode("@settings").text
	If KS.IsNul(BSetting) Then KS.Die "err|参数出错!"
	BSetting=Split(BSetting&"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$","$")
 dim categoryid:categoryid=KS.ChkClng(KS.G("Categoryid"))
 if Bsetting(24)="1" and categoryid=0 then KS.Die "<script>$.dialog.alert('此版面设定主题必须归类，请选择主题分类!');</script>"
 Conn.Execute("Update KS_GuestBook Set CategoryID=" & categoryid & " where id=" & topicid)
 KS.Die "<script>top.box.content('<div style=""text-align:center;font-size:14px;padding-top:20px;""><img src=""../../images/default/2.png"" align=""absmiddle""/>恭喜，帖子主题归类更改成功!<br/><input type=""button"" class=""btn"" value=""确定"" onclick=""top.location.reload();""/></div>').title('操作成功');</script>"
end function

function changeIndexStyle()
 Response.Cookies("clubindex")=KS.S("S")
 Response.Cookies("clubindex").Expires = Date + 365
 Response.Redirect "index.asp"
end function
function getPostTable()
   dim rs :set rs=conn.execute("select top 1 PostTable From KS_GuestBook Where ID=" & TopicID)
   If RS.Eof Then
      RS.Close :Set RS=Nothing
	  KS.Die "error"
   End If
   getPostTable=RS(0)
   RS.Close : Set RS=Nothing
end function

'检查是否允许点评
sub checkcomments()
	Dim KSUser:Set KSUser=New UserCls
	Dim LoginTF:LoginTF=KSUser.UserLoginChecked()
	If Cbool(LoginTF)=False Then
	  KS.Die ("err|对不起，登录后才可以点评!")
	End If
  Call doCheckComments(KSUser)
  If Conn.Execute("Select top 1 ID From KS_GuestComment Where pid=" & ID &" and UserName='" & KSUser.UserName & "' and Comment like '%：<i>%'").eof Then
  KS.Die "success|" & BSetting(49)
  Else
  KS.Die "success|"
  End If
  Set KSUser=Nothing		 
end sub
Sub doCheckComments(KSUser)
  if Boardid=0 then KS.Die "err|参数出错!"
  KS.LoadClubBoard()
  Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
  BSetting=Node.SelectSingleNode("@settings").text
  If KS.IsNul(BSetting) Then KS.Die "err|参数出错!"
  BSetting=Split(BSetting&"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$","$")
  if KS.ChkClng(BSetting(44))=0 Then
    KS.Die "err|本版面没有开启点评功能!"
  End If

  If KSUser.GetUserInfo("userId")=KS.S("UserId") And KS.ChkClng(BSetting(48))=0 Then
    KS.Die "err|本版面不允许对自己的帖子进行点评!"
  End If
  If KS.ChkClng(KSUser.GetUserInfo("prestige"))<KS.ChkClng(BSetting(45)) Then
    KS.Die "err|对不起，您的威望值不够，无法对帖子进行点评!"
  End If
  if KS.ChkClng(BSetting(46))=0 And KS.ChkClng(KS.S("N"))=1 Then
    KS.Die "err|本版面不允许对主题进行点评!"
  End If
  if KS.ChkClng(BSetting(47))=0 And KS.ChkClng(KS.S("N"))>1 Then
    KS.Die "err|本版面不允许对回复进行点评!"
  End If
 End Sub

'保存点评
Sub comments()
	Dim KSUser:Set KSUser=New UserCls
	Dim RS,LoginTF:LoginTF=KSUser.UserLoginChecked()
	If Cbool(LoginTF)=False Then
	  KS.Die Escape("err|对不起，登录后才可以点评!")
	End If
	Call doCheckComments(KSUser)
	If ID=0 Then KS.Die Escape("err|参数出错啦!")
	if IsDate(Request.Cookies("clubcmts")) then
      If DateDiff("s",Request.Cookies("clubcmts"),now)<15 Then
	     KS.Die Escape("err|两次发表间隔时间不能少于15秒，请稍候发表!")
	  End If
    end if
	If KS.ChkClng(KS.S("Prestige"))>2 Or KS.ChkClng(KS.S("Prestige"))<-2 Then
	     KS.Die Escape("err|您提交了，不合法的威望值!")
	End If

    Dim Comment:Comment=KS.DelSQL(UnEscape(Replace(KS.LoseHtml(Request("Comment")),"'","")))
	If KS.IsNul(Comment) Then KS.Die Escape("err|没有输入点评内容!")
	Conn.Execute("Insert Into KS_GuestComment(tid,pid,username,userface,userid,comment,adddate,Prestige,OrderID) values(" & topicid &"," & id & ",'" & KSUser.UserName & "','" & KSUser.GetUserInfo("userface") &"'," & KS.ChkClng(KSUser.GetUserInfo("UserID")) & ",'" & comment & "'," & SQLNowString& "," & KS.ChkClng(KS.S("Prestige"))&",1)")
	If Instr(comment,"：<i>")<>0 Then
	  Set RS=Server.CreateObject("ADODB.RECORDSET")
	  RS.Open "Select top 1 * From KS_GuestComment Where Pid=" & id & " and username='' and userid=0",conn,1,3
	  If RS.Eof And RS.Bof Then
	    RS.AddNew
		 RS("TID")=topicid
		 RS("Pid")=id
		 RS("UserID")=0
		 RS("UserName")=""
		 RS("AddDate")=Now
		 RS("Comment")=split(comment,"<br/>")(0)
		 RS("Prestige")=0
		 RS("OrderID")=0
		RS.Update
	  Else
		 Call UpdateCommentStar(RS)
	  End If
	  RS.Close :Set RS=Nothing
	End If
	If KS.ChkClng(KS.S("Prestige"))<>0 Then
	    Set RS=Conn.Execute("Select top 1 UserID From " & getPostTable & " Where ID=" & ID)
		If Not RS.Eof Then
		Conn.Execute("Update KS_User Set Prestige=prestige+" & KS.ChkClng(KS.S("Prestige")) &" where userid=" & KS.ChkClng(RS(0)))
		End If
		RS.Close
    End If
    Response.Cookies("clubcmts")=Now
	
	'更新今日帖子数
	If Bsetting(50)="1" Then
	 dim Doc:set Doc = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
		Doc.async = false
		Doc.setProperty "ServerHTTPRequest", true 
		Doc.load(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
		Dim XMLDate:XMLDate=doc.documentElement.attributes.getNamedItem("date").text
					If DateDiff("d",xmldate,now)=0 Then
					  doc.documentElement.attributes.getNamedItem("todaynum").text=doc.documentElement.attributes.getNamedItem("todaynum").text+1
					  If KS.ChkClng(doc.documentElement.attributes.getNamedItem("todaynum").text)>KS.ChkClng(doc.documentElement.attributes.getNamedItem("maxdaynum").text) then
					   doc.documentElement.attributes.getNamedItem("maxdaynum").text=doc.documentElement.attributes.getNamedItem("todaynum").text
					  end if
					  Conn.Execute("Update KS_GuestBoard set postnum=postnum+1 where id=" & BoardID)
					  Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]/@todaynum").text=KS.ChkClng(Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]/@todaynum").text)+1
					Else
					  doc.documentElement.attributes.getNamedItem("date").text=now
					  doc.documentElement.attributes.getNamedItem("yesterdaynum").text=doc.documentElement.attributes.getNamedItem("todaynum").text
					  doc.documentElement.attributes.getNamedItem("todaynum").text=0
					  Conn.Execute("Update KS_GuestBoard set postnum=1 where id=" & BoardID)
					  Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]/@todaynum").text=1
					End If
					  doc.documentElement.attributes.getNamedItem("postnum").text=doc.documentElement.attributes.getNamedItem("postnum").text+1
	  doc.save(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
	  Conn.Execute("Update KS_GuestBook Set LastReplayTime=" & SQLNowString &",LastReplayUser='" & KSUser.UserName&"',LastReplayUserID=" & KS.ChkClng(KSUser.GetUserInfo("userid")) & " Where id=" & topicid) '更新主题最后发表时间
	End If
	Set KSUser=Nothing
	KS.Echo "success|"
	Set RS=Conn.Execute("Select * From KS_GuestComment Where Pid=" & ID & " Order By orderid,Id Desc")
	If Not RS.Eof Then
	   Dim Xml:Set XML=KS.RsToXml(RS,"row","")
	   KS.echo GetComments(XML,BoardID,id,KS.ChkClng(BSetting(44)),check)
	End If
	Set RS=Nothing
End Sub
'更新点评的星星数
Sub UpdateCommentStar(RST)
  Dim Comment:Comment=RST("Comment")
  Dim CommentArr:CommentArr=Split(Comment,"：")
  Dim K,GD,TempStr
  For K=0 To Ubound(CommentArr)
    If K=0 Then
	  GD=CommentArr(k)
	  TempStr=GetGDStar(GD,RST("Pid"))
	ElseIf Instr(CommentArr(k),"</i> ")<>0 Then
	  GD=split(CommentArr(k),"</i> ")(1)
	  TempStr=TempStr &" " & GetGDStar(GD,RST("Pid"))
	End If
  Next
  If Not KS.IsNUL(BSetting(49)) Then
    Dim DefaultGDArr:DefaultGDArr=Split(BSetting(49),",")
    For K=0 To Ubound(DefaultGDArr)
	 If Instr(TempStr,DefaultGDArr(k)&"：")=0 Then
	  TempStr=TempStr &" " & GetGDStar(DefaultGDArr(k),RST("Pid"))
	 End If
    Next
  End If
  Conn.Execute("Update KS_GuestComment Set AddDate=" & SQLNowString& ",Comment='" & TempStr& "' Where ID=" & RST("id"))
End Sub
Function GetGDStar(GD,pid)
  Dim RS,N,Star
  Set RS=Conn.Execute("Select Comment From KS_GuestComment Where Comment Like '%" & GD&"：<i>%' and UserID<>0 And Pid=" & PID)
  N=0:Star=0
  Do While Not RS.Eof
     N=n+1
	 Star=Star+KS.CutFixContent(RS(0),GD&"：<i>","</i>",0)
  RS.MoveNext
  Loop
  If N<>0 Then
  GetGDStar=GD&"：<i>" & Star/N & "</i>"
  Else
  GetGDStar=""
  End If
End Function
'按分页取点评数据
Sub GetCommentPage()
    Dim Pid:Pid=KS.ChkClng(KS.S("pid"))
	If Pid=0 Then KS.Die "加载出错!"
	if Boardid=0 then KS.Die "err|参数出错!"
	KS.LoadClubBoard()
	Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
	BSetting=Node.SelectSingleNode("@settings").text
	If KS.IsNul(BSetting) Then KS.Die "err|参数出错!"
	BSetting=Split(BSetting&"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$","$")

    Dim RS:Set RS=Conn.Execute("Select * From KS_GuestComment Where Pid=" & PID & " Order By orderid,Id Desc")
	If Not RS.Eof Then
	   Dim Xml:Set XML=KS.RsToXml(RS,"row","")
	   KS.echo GetComments(XML,BoardID,pid,KS.ChkClng(BSetting(44)),check)
	End If
	Set RS=Nothing
End Sub
'删除点评
Sub delcomment()
    If BoardID=0 Then KS.Die "参数出错啦!"
	If cbool(check)=false Then
		KS.Die "对不起，你没有设置的权限!"
	End If
	Conn.Execute("Delete From KS_GuestComment Where ID=" & KS.ChkClng(KS.S("ID")))
	KS.Die "success"
End Sub


'投票操作
Sub dovote()
           Dim ID:ID=KS.ChkClng(KS.S("voteid"))
		   If Id=0 Then KS.Die "error!"
		   Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		   RS.Open "Select Top 1 * From KS_Vote Where id=" & id,CONN,1,3
		   If RS.Eof And RS.Bof Then
		     RS.Close:Set RS=Nothing
			 KS.Die "error!"
		   End If
		   
		   Dim LoopStr,XML,Node,Str,LC,Xstr,TotalVote
		   
		   '投票操作
		     If RS("Status")="0" Then RS.Close:Set RS=Nothing : KS.Die Escape("该投票已关闭!")
			 Set KSUser=New UserCls
			 Dim LoginTF:LoginTF=KSUser.UserLoginChecked()
			 Dim GroupIds:GroupIds=RS("GroupIDs")
			 Dim TopicID:TopicID=RS("TopicID")
			 If RS("nmtp")<>"1" and LoginTF=false Then RS.Close:Set RS=Nothing:KS.Die Escape("对不起，只会登录会员才能投票!")
			 If Not KS.IsNul(GroupIDs) And KS.FoundInArr(GroupIDs, KSUser.GroupID, ",")=False Then
			 	RS.Close:Set RS=Nothing
				KS.Die Escape("对不起，您所在的会员组不允许投票!'")
			 End If
			 If RS("TimeLimit")="1" Then
			 	if now<RS("TimeBegin") then RS.Close:Set RS=Nothing: KS.Die Escape("对不起，该投票于" & RS("TimeBegin") & "开放!")
		        if now>RS("TimeEnd") then RS.Close:Set RS=Nothing : KS.Die Escape("对不起，该投票已在" & RS("TimeBegin") & "停止！")
			 End If
			 
			 
		     Dim VoteOption,ItemArr,I,UserName
			 VoteOption=KS.FilterIds(KS.S("VoteOption"))
			 If KS.IsNul(VoteOption) Then KS.Die Escape("您没有选择投票项目!")
			 
			 Dim IPNum:IPNum=KS.ChkClng(RS("IpNum"))
			 Dim IPNums:IPNums=RS("IPNums")
			 If IpNums<>0 Then
			 	If Conn.Execute("Select Count(ID) From KS_PhotoVote Where UserIp='" & KS.GetIP & "' and ChannelID=-1 And InfoID='" & ID & "'")(0)>=IPNums  Then
				 RS.Close:Set RS=Nothing
	             KS.Die Escape("对不起，每个IP最多只能投" & IPNums & "次!")
	             End If
			 End If
			 If IpNum<>0 Then
			 	If Conn.Execute("Select Count(ID) From KS_PhotoVote Where Year(VoteTime)=" & Year(Now) & " and Month(VoteTime)=" & Month(Now) & " and Day(VoteTime)=" & Day(Now) & " and UserIp='" & KS.GetIP & "' and ChannelID=-1 And InfoID='" & ID & "'")(0)>=IPNum  Then
				 RS.Close:Set RS=Nothing
	             KS.Die Escape("对不起，每个IP一天最多只能投" & IPNum & "次!")
	             End If
			 End If
			 
			 ItemArr=Split(VoteOption,",")
		     set XML = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
			 XML.async = false
			 XML.setProperty "ServerHTTPRequest", true 
			 XML.load(Server.MapPath(KS.Setting(3)&"Config/voteitem/vote_" &id&".xml"))
			 For I=0 To Ubound(ItemArr)
				 Set Node=XML.DocumentElement.SelectSingleNode("voteitem[@id=" & KS.ChkClng(ItemArr(i)) & "]")
				 Node.childNodes(1).text=KS.ChkClng(Node.childNodes(1).text)+1
				 XML.Save(Server.MapPath(KS.Setting(3)&"Config/voteitem/vote_" &id&".xml"))
			 Next
			 If LoginTF=False Then UserName="游客" Else UserName=KSUser.UserName
			 Conn.Execute("Insert Into [KS_PhotoVote]([ChannelID],[ClassID],[InfoID],[VoteTime],[UserName],[UserIP],[VoteOptions]) Values(-1,'-1','" & ID & "'," & SqlNowString & ",'" & UserName & "','" & KS.GetIP() & "','" & VoteOption & "')")
		     RS("VoteNums")=RS("VoteNums")+1
			 Dim VoteUserList:VoteUserList=RS("VoteUserList")
			 If KS.FoundInArr(VoteUserList,UserName,",")=false Then
			   If Instr(VoteUserList,",")=0 Then
			    RS("VoteUserList")=UserName
			   Else
			    RS("VoteUserList")=VoteUserList&"," & UserName
			   End If
			 End If
			 RS.Update
			 RS.Close:Set RS=Nothing

			 Application(KS.SiteSN&"_Configvoteitem/vote_"&ID)=empty
			 KS.Die "success@@@"&escape(GetVote(TopicID,XML))
end sub

sub fav()
  Dim KSUser:Set KSUser=New UserCls
  If Cbool(KSUser.UserLoginChecked)=false Then 
    KS.Die "请先登录！"
	exit sub
  else
    dim rs:set rs=conn.execute("select top 1 id from ks_guestbook where ID=" & TopicID)
	if rs.eof and rs.bof then 
	 rs.close :set rs=noting
	 KS.Die "参数出错！"
	end if
	rs.close
	rs.open "select top 1 * From  KS_AskFavorite where username='" & KSUser.UserName & "' and typeflag=1 and topicid=" & TopicID,conn,1,3
	if not rs.eof then
	  rs.close:set rs=nothing
	  KS.Die "已收藏过了!"
	else
	  rs.addnew
	   rs("username")=KSUser.UserName
	   rs("topicid")=topicid
	   rs("typeflag")=1
	   rs("FavorTime")=now
	  rs.update
	end if 
	rs.close:set rs=nothing
	ks.die "success"
  end if
end sub

'删除指定用户的全部发帖,不重计总帖数
sub delusertopic()
 	Dim KSUser:Set KSUser=New UserCls
	If Cbool(KSUser.UserLoginChecked)=false Then 
	 KS.Die "err|对不起,您没有此操作权限!"
	end if
	if KS.ChkClng(KSUser.GroupId)<>1 Then
  	 KS.Die "err|对不起,只有管理员有此权限!"
    end if
	Dim DelType:DelType=KS.ChkClng(KS.S("DelType"))
	Dim RZM:RZM=UnEscape(KS.S("RZM"))
	If DelType<>0 And RZM<>SiteManageCode Then
	 KS.Die "err|对不起，您输入的认证码不正确！"
	End If
	
	'Dim KSLoginCls:Set KSLoginCls = New LoginCheckCls1
    'If KSLoginCls.Check=false Then
  	' KS.echo "<script>alert('对不起,为了安全起见，管理员必须先登录后台才可以执行此操作!');<//script>"
	' Response.Redirect "../" & KS.Setting(89) &"login.asp"
	' Exit Sub
    'End If
	
	Dim RS,TopicIDs,UserName:UserName=KS.DelSQL(UnEscape(Request("UserName")))
	Dim deltime:deltime=KS.ChkClng(Request("deltime"))
	If KS.IsNul(UserName) Then
  	 KS.Die "err|对不起,参数出错啦!"
	End If
	Dim Param:Param=" Where DelTF=0 and UserName='" & UserName & "'"
	If deltime<>0 Then
	 Param=Param & " and datediff(" & DataPart_D & ",AddTime," & SQLNowString &")<=" & DelTime
	End If
	If DelType<>1 Then
	  Conn.Execute("Update KS_GuestBook Set DelTF=1" & Param)
	Else
	  Set RS=Conn.Execute("Select ID,ChannelID,InfoID From KS_GuestBook " & Param)
	  Do While Not RS.Eof 
	  	
		 If KS.ChkClng(rs("ChannelID"))<>0 And KS.ChkClng(rs("InfoID"))<>0 Then  '删除绑定模型数据
			 Conn.Execute("Delete From " & KS.C_S(KS.ChkClng(rs("ChannelID")),2) & " Where PostID=" & rs(0))
			 Conn.Execute("Delete From KS_ItemInfo Where ChannelID=" & KS.ChkClng(rs("ChannelID")) & " and InfoID=" & KS.ChkClng(rs("InfoID")))
		 End If

	    If TopicIDs="" Then
		 TopicIDs=RS(0)
		Else
	     TopicIDs=TopicIDs & "," & RS(0)
		End If
	    Conn.Execute("Delete From KS_GuestComment Where Tid=" & RS(0))
	  RS.MoveNext
	  Loop
	  RS.Close : Set RS=Nothing
	  Conn.Execute("Delete From KS_GuestBook Where UserName='" & UserName &"'")
	End If
	
	set TableXML = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
	TableXML.async = false
	TableXML.setProperty "ServerHTTPRequest", true 
	TableXML.load(Server.MapPath(KS.Setting(3)&"Config/clubtable.xml"))
	Dim Url,N:N=0
	Param=" Where DelTf=0 and UserName='" & UserName & "'"
	If deltime<>0 Then
	 Param=Param & " and datediff(" & DataPart_D & ",ReplayTime," & SQLNowString &")<=" & DelTime
	End If
    For Each Node In TableXML.DocumentElement.SelectNodes("item")
	  Set RS=Server.CreateObject("ADODB.RECORDSET")
	  RS.Open "Select TopicID,ID From " & Node.SelectSingleNode("tablename").text & Param,conn,1,1
	  Do While Not RS.Eof
	   n=n+1
	   Conn.Execute("Update KS_GuestBook Set TotalReplay=TotalReplay-1 Where ID=" & RS(0) & " And TotalReplay>0")
	   If DelType=1 Then
	    Conn.Execute("Delete From KS_GuestComment Where Pid=" & RS(1)&" And Tid=" & RS(0))
	   End If
	   RS.MoveNext
	  Loop
	  RS.Close
	  Set RS=Nothing
	  If TopicIDs<>"" Then Param=Param & " Or TopicID in(" & TopicIDs &")"
	  If DelType<>1 Then
	   Conn.Execute("update " & Node.SelectSingleNode("tablename").text & " set deltf=1 "& Param)
	  Else
	   Conn.Execute("Delete From " & Node.SelectSingleNode("tablename").text & Param)
	  End If
	Next
	If KS.S("N")="1" Then Url=KS.GetClubListUrl(BoardID) Else Url=KS.GetClubShowUrl(TopicID)
	KS.die "succ|恭喜,您已删除用户[" & UserName & "]的所有帖子啦,累计"&n&"帖!|" & url
end sub

sub support()
 dim sql
 if Not KS.IsNul(Request.Cookies("clubsupport" &ID)) then
   ks.echo "error"
   exit sub
 end if
 dim rs
 sql="select top 1 Support from " & getPostTable & " where id=" & id
 set rs=server.createobject("adodb.recordset")
 rs.open sql,conn,1,3
 if not rs.eof then
  rs(0)=ks.chkclng(rs(0))+1
  rs.update
 end if
 Response.Cookies("clubsupport" &ID)="ok"
 ks.echo rs(0)
 rs.close
 set rs=nothing
end sub
sub opposition()
 dim sql
 if Not KS.IsNul(Request.Cookies("clubsupport" &ID)) then
   ks.echo "error"
   exit sub
 end if
 dim rs
   sql="select top 1 opposition from " & getPostTable & " where id=" & id
 set rs=server.createobject("adodb.recordset")
 rs.open sql,conn,1,3
 if not rs.eof then
  rs(0)=ks.chkclng(rs(0))+1
  rs.update
 end if
 Response.Cookies("clubsupport" &ID)="ok"
 ks.echo rs(0)
 rs.close
 set rs=nothing
end sub


Sub SetBest()
    	Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		If TopicIds="" Then
		  KS.Die "对不起,您没有选中要设置精华的主题!"
		End If

		If cbool(check)=false Then
		 KS.Die "对不起，你没有设置的权限!"
		End If
		Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select UserName,isbest,boardid,subject,id From KS_GuestBook Where ID in(" & TopicIds &")",conn,1,3
		If Not RS.Eof Then
		 Do While Not RS.Eof
			  ID=rs("id")
			  rs(1)=1
			  rs.update
			  Conn.Execute("Update KS_User Set BestTopicNum=BestTopicNum+1 Where UserName='" & rs(0) & "'")
			  boardid=rs(2)
			  if boardid<>0 and not KS.ISNul(rs(0)) then
				 KS.LoadClubBoard()
				 Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
				 BSetting=Node.SelectSingleNode("@settings").text
				 If Not KS.IsNul(BSetting) Then
				  If KS.ChkClng(Split(BSetting,"$")(33))<>0 Then
				  Conn.Execute("Update KS_User Set Prestige=Prestige+" & KS.ChkClng(Split(BSetting,"$")(33)) & " Where UserName='" & rs(0) &"'")
				  End If
				   If KS.ChkClng(Split(BSetting,"$")(6))>0 Then
					Call KS.ScoreInOrOut(rs(0),1,KS.ChkClng(Split(BSetting,"$")(6)),"系统","在论坛发表主题[" & rs(3) & "]被设置成精华!",0,0)
				   End If
				 End If
			  end if
		   rs.movenext
		 loop
		End If
		rs.close:set rs=nothing
		KS.Die "success"
	 End Sub
	 Sub SetTop()
		Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		Dim V:V=KS.ChkClng(KS.S("v"))
		If V=0 Then V=1
		If TopicIds="" Then
		  KS.Die "对不起,您没有选中要置顶的主题!"
		End If
		If check=false Then
		  KS.Die "对不起，你没有设置的权限!"
		End If
		
		Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select UserName,istop,boardid,subject,id From KS_GuestBook Where ID in(" & TopicIds &")",conn,1,3
		If Not RS.Eof Then
		  Do While Not RS.Eof
			  ID=rs("id")
			  rs(1)=v
			  rs.update
			  boardid=rs(2)
			  if boardid<>0 and not KS.ISNul(rs(0)) then
				 KS.LoadClubBoard()
				 Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
				 BSetting=Node.SelectSingleNode("@settings").text
				 If Not KS.IsNul(BSetting) Then
				  If KS.ChkClng(Split(BSetting,"$")(32))<>0 Then
				  Conn.Execute("Update KS_User Set Prestige=Prestige+" & KS.ChkClng(Split(BSetting,"$")(32)) & " Where UserName='" & rs(0) &"'")
				  End If
				   If KS.ChkClng(Split(BSetting,"$")(5))>0 Then
					Call KS.ScoreInOrOut(rs(0),1,KS.ChkClng(Split(BSetting,"$")(5)),"系统","在论坛发表主题[" & rs(3) & "]被设置成置顶!",0,0)
				   End If
				 End If
			  end if
			 RS.MoveNext
		  Loop
		End If
		rs.close:set rs=nothing
		MustReLoadTopTopic
		KS.Die "success"
	 End Sub
	 Sub CancelBest()
	    Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		If TopicIds="" Then
		  KS.Die "对不起,您没有选中要取消精华的主题!"
		End If

		If cbool(check)=false Then
		   KS.Die "对不起，你没有设置的权限!"
		End If
        Conn.Execute("Update KS_Guestbook set isbest=0 where id in(" & TopicIds &")")
		KS.Die "success"
	 End Sub
	 Sub CancelTop()
		Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		If TopicIds="" Then
		  KS.Die "对不起,您没有选中要取消置顶的主题!"
		End If
		If check=false Then
		  KS.Die "对不起，你没有设置的权限!"
		End If
        Conn.Execute("Update KS_Guestbook set istop=0 where id in(" & TopicIds &")")
		MustReLoadTopTopic
		KS.Die "success"
	 End Sub
	 
	
	 
	 Sub delsubject()
		Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		Dim DelType:DelType=KS.ChkClng(KS.S("DelType"))
		Dim RZM:RZM=UnEscape(KS.S("RZM"))
		If TopicIds="" Then
		  KS.Die "对不起,您没有选中要删除的主题!"
		End If
		If cbool(check)=false Then
		  KS.Die "对不起，你没有删帖的权限!"
		End If
		
		If DelType<>0 And RZM<>SiteManageCode Then   '彻底删除检查认证码
		  KS.Die "对不起，您输入的认证码有误！"
		End If
		
		If DelType<>1 Then     '放入回收站，不计算今日数等
		   Conn.Execute("Update KS_GuestBook  Set DelTF=1 Where ID In(" & TopicIDs &")")
		Else
			Dim TodayNum:TodayNum=0
			dim boardid,postTable,userName,ChannelID,InfoID
			Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
			RS.Open "Select UserName,boardid,subject,AddTime,PostTable,ID,ChannelID,InfoID From KS_GuestBook Where ID in(" & TopicIds &")",conn,1,1
			If Not RS.Eof Then
			 Do While Not RS.Eof
				  id=RS("ID"):boardid=rs(1):postTable=rs(4):userName=rs(0)
				  ChannelID=RS("ChannelID"): InfoID=RS("Infoid")
				  If DateDiff("d",rs(3),Now)=0 Then
				   TodayNum=TodayNum+1
				  End If
				  If boardid<>0 then 
					 KS.LoadClubBoard()
					 Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
					 Dim LastPost,LastPostArr:LastPostArr=Split(Node.SelectSingleNode("@lastpost").text,"$")
					 
					 '更新首页的最新主题
					 If KS.ChkClng(LastPostArr(0))=ID Then
					   Dim RSNew:Set RSNew=Conn.Execute("Select top 1 ID,BoardID,Subject,AddTime From KS_GuestBook Where BoardID=" & boardid & " and verific=1 and id<>" & id & " order by id desc")
					   If Not RSNew.Eof Then
						 LastPost=RSNew(0) & "$" & RSNew(3) & "$" & Replace(left(RSNew(2),200),"$","") & "$$$$$$$$"
					   Else
						 LastPost="无$无$无$$$$$$$$"
					   End If
					   Conn.Execute("Update KS_GuestBoard Set LastPost='" & LastPost & "' Where ID=" & BoardID)
					   Node.SelectSingleNode("@lastpost").text=LastPost
					 End If
				  end if
				  
				  if not KS.ISNul(rs(0)) then
					 BSetting=Node.SelectSingleNode("@settings").text
					 If Not KS.IsNul(BSetting) Then
						 If KS.ChkClng(Split(BSetting,"$")(34))<>0 Then
						  Conn.Execute("Update KS_User Set Prestige=Prestige-" & KS.ChkClng(Split(BSetting,"$")(34)) & " Where UserName='" & rs(0) &"' and Prestige>0")
						 End If
					 
					   If KS.ChkClng(Split(BSetting,"$")(7))>0 Then
						Call KS.ScoreInOrOut(rs(0),2,KS.ChkClng(Split(BSetting,"$")(7)),"系统","在论坛您发表的主题[" & rs(2) & "]被删除!",0,0)
					   End If
					 End If
				  end if
				  
				  Dim Num,replyNum:replyNum=Conn.Execute("Select count(id) from " & PostTable & " where topicid=" & id)(0)
				  TodayNum=TodayNum+Conn.Execute("Select count(id) from " & PostTable & " where topicid=" & id &" and datediff(" & DataPart_D & ",ReplayTime," & SqlNowString&")=0")(0)
				  Dim Doc:set Doc = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
				  Doc.async = false
				  Doc.setProperty "ServerHTTPRequest", true 
				  Doc.load(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
				  Dim XMLDate:XMLDate=doc.documentElement.attributes.getNamedItem("date").text
				  Num=KS.ChkClng(doc.documentElement.attributes.getNamedItem("todaynum").text)-TodayNum
				  If Num<0 Then Num=0
				  doc.documentElement.attributes.getNamedItem("todaynum").text=Num
				  Num=KS.ChkClng(doc.documentElement.attributes.getNamedItem("postnum").text)-replyNum
				  If Num<0 Then Num=0
				  doc.documentElement.attributes.getNamedItem("postnum").text=Num
				  Num=KS.ChkClng(doc.documentElement.attributes.getNamedItem("topicnum").text)-1
				  If Num<0 Then Num=0
				  doc.documentElement.attributes.getNamedItem("topicnum").text=Num
				  
				  Conn.Execute("Update KS_GuestBoard Set TodayNum=TodayNum-" & TodayNum & " where id=" &boardid &" and todaynum>=" & TodayNum)
				  Conn.Execute("Update KS_GuestBoard Set PostNum=PostNum-" & replyNum -1& " where id=" &boardid &" and PostNum>=" & replyNum-1)
				  Application(KS.SiteSN&"_ClubBoard").DocumentElement.selectSingleNode("row[@id=" & boardid & "]/@postnum").text=Conn.Execute("Select PostNum From KS_GuestBoard Where id=" & boardid)(0)
				  Application(KS.SiteSN&"_ClubBoard").DocumentElement.selectSingleNode("row[@id=" & boardid & "]/@todaynum").text=Conn.Execute("Select TodayNum From KS_GuestBoard Where id=" & boardid)(0)
		
				  doc.save(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
				  
				  If KS.ChkClng(ChannelID)<>0 And KS.ChkClng(InfoID)<>0 Then  '删除绑定模型数据
				    Conn.Execute("Delete From " & KS.C_S(ChannelID,2) & " Where PostID=" & ID)
				    Conn.Execute("Delete From KS_ItemInfo Where ChannelID=" & ChannelID & " and InfoID=" & InfoID)
				  End If
				  	
					Conn.Execute("update KS_User set postNum=postNum-1 where userName='" & UserName & "' and postNum>0")
					Conn.Execute("delete from KS_Guestbook where id=" & ID)
					Conn.Execute("delete from " & PostTable & " where TopicID=" & ID)
					Conn.Execute("delete from KS_GuestComment Where Tid=" & ID)
					Conn.Execute("delete from KS_UploadFiles where InfoID=" & ID & " and channelid=9994")
			  RS.MoveNext
			Loop 
			End If
			rs.close:set rs=nothing
		End If
		Call KS.delweibo("论坛主题",TopicIds)
		KS.Echo "success"
	 End Sub
	 
	 Sub delreply()
		If cbool(check)=false Then
		  KS.Die "对不起，你没有设置的权限!"
		  Exit Sub
		End If
		Dim DelType:DelType=KS.ChkClng(KS.S("DelType"))
		Dim RZM:RZM=UnEscape(KS.S("RZM"))
		If ID=0 or KS.ChkClng(KS.S("ReplyID"))=0 Then
		  KS.Die "对不起,您没有选中要删除的回复!"
		End If

		If DelType<>0 And RZM<>SiteManageCode Then   '彻底删除检查认证码
		  KS.Die "对不起，您输入的认证码有误！"
		End If
		
		dim boardid,postTable,userName
		Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select top 1 UserName,boardid,subject,TotalReplay,postTable From KS_GuestBook Where ID=" & ID,conn,1,1
		If Not RS.Eof Then
		  if rs(3)>0 then 
		    conn.execute("update ks_guestbook set TotalReplay=TotalReplay-1 where id=" & id & " and TotalReplay>=1")
		  end if
		  boardid=rs(1)
		  postTable=rs(4)
		  userName=rs(0)
		  
		  Dim ReplayTime:ReplayTime=Conn.Execute("Select top 1 ReplayTime From " & postTable &" where ID=" & KS.ChkClng(KS.S("ReplyID")))(0)
		  '减少帖子数
		  Dim Num
		  Dim Doc:set Doc = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
		  Doc.async = false
		  Doc.setProperty "ServerHTTPRequest", true 
		  Doc.load(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
		  Dim XMLDate:XMLDate=doc.documentElement.attributes.getNamedItem("date").text
		  If DateDiff("d",xmldate,ReplayTime)=0 Then
		    Conn.Execute("Update KS_GuestBoard Set TodayNum=TodayNum-1 where id=" &boardid &" and todaynum>0")
		    Num=KS.ChkClng(doc.documentElement.attributes.getNamedItem("todaynum").text)-1
			If Num<0 Then Num=0
		    doc.documentElement.attributes.getNamedItem("todaynum").text=Num
			
			Application(KS.SiteSN&"_ClubBoard").DocumentElement.selectSingleNode("row[@id=" & boardid & "]/@todaynum").text=Conn.Execute("Select TodayNum From KS_GuestBoard Where id=" & boardid)(0)
          End If
		    Conn.Execute("Update KS_GuestBoard Set PostNum=PostNum-1 where id=" &boardid &" and PostNum>0")
		    Num=KS.ChkClng(doc.documentElement.attributes.getNamedItem("postnum").text)-1
			If Num<0 Then Num=0
		    doc.documentElement.attributes.getNamedItem("postnum").text=Num
			doc.save(Server.MapPath(KS.Setting(3)&"Config/guestbook.xml"))
			Application(KS.SiteSN&"_ClubBoard").DocumentElement.selectSingleNode("row[@id=" & boardid & "]/@postnum").text=Conn.Execute("Select PostNum From KS_GuestBoard Where id=" & boardid)(0)

		  if boardid<>0 and not KS.ISNul(rs(0)) then
		     KS.LoadClubBoard()
			 Dim Node:Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & boardid &"]")
			 BSetting=Node.SelectSingleNode("@settings").text
			 If Not KS.IsNul(BSetting) Then
			     Dim ReplyUser:ReplyUser=Conn.Execute("Select top 1 UserName From " & postTable &" where ID=" & KS.ChkClng(KS.S("ReplyID")))(0)
			     If KS.ChkClng(Split(BSetting,"$")(35))<>0 Then
					  Conn.Execute("Update KS_User Set Prestige=Prestige-" & KS.ChkClng(Split(BSetting,"$")(35)) & " Where UserName='" & ReplyUser &"' and Prestige>0")
				 End If
			   If KS.ChkClng(Split(BSetting,"$")(8))>0 Then
			    Call KS.ScoreInOrOut(ReplyUser,2,KS.ChkClng(Split(BSetting,"$")(8)),"系统","在论坛对主题[" & rs(2) & "]的回复被删除!",0,0)
			   End If
			 End If
		  end if

		End If
		rs.close:set rs=nothing
		If DelType=1  Then  '彻底删除
		 Conn.Execute("delete from " & postTable & " where topicid=" & id & " and ID=" & KS.ChkClng(KS.S("ReplyID")))
		 Conn.Execute("delete from KS_GuestComment Where tid=" & id & " and PID=" & KS.ChkClng(KS.S("ReplyID")))
		Else
		 Conn.Execute("update " & postTable & " set deltf=1 where topicid=" & id & " and ID=" & KS.ChkClng(KS.S("ReplyID")))
		End If
		KS.Echo "success"
	 End Sub
	 
sub verify()
	If check=false Then
	  KS.Die "<script>alert('对不起，你没有设置的权限!');history.back();</script>"
	End If
	Conn.Execute("update " & getPostTable &" set verific=1 where ID=" & KS.ChkClng(KS.S("ReplyID")))
	If KS.ChkClng(KS.S("N"))=1 Then
	   Conn.Execute("Update KS_GuestBook Set verific=1 Where ID=" & KS.ChkClng(KS.S("TopicID")))
	   Dim RS,ChannelID,InfoID
		Set RS=Conn.Execute("Select Top 1 * From KS_GuestBook Where ID=" & KS.ChkClng(KS.S("TopicID")))
		If Not RS.Eof Then
		  Do While Not RS.Eof
			ChannelID=RS("ChannelID"): InfoID=RS("InfoID")
			If ChannelID<>0 And InfoID<>0 Then
			  Conn.Execute("Update " & KS.C_S(ChannelID,2) & " Set verific=1 Where ID=" & InfoID)
			  Conn.Execute("Update KS_ItemInfo Set verific=1 Where ChannelID=" & ChannelID & " And ID=" & InfoID)
			End If
			RS.MoveNext
		  Loop
		End If
		RS.Close :Set RS=Nothing
	End If
	Response.Redirect request.servervariables("http_referer")
end sub

sub LockorUnlock()
		If check=false Then
		  KS.Echo "对不起，你没有此项操作的权限!"
		  Exit Sub
		End If
		dim flag:flag=KS.ChkClng(request("flag"))
		dim v:v=1
		if flag=0 then  v=2
		Conn.Execute("update ks_guestbook set verific=" & v & " where ID=" & KS.ChkClng(KS.S("ID")))
		Conn.Execute("update " & getPostTable &" set verific=" & v & " where parentid=0 and topicid=" & KS.ChkClng(KS.S("TopicID")))
		KS.Echo "success"
end sub

sub openorclose()
		If check=false Then
		  KS.Echo "对不起，你没有此项操作的权限!"
		  Exit Sub
		End If
		dim flag:flag=KS.ChkClng(request("flag"))
		Conn.Execute("update ks_guestbook set isclose=" & flag & " where ID=" & KS.ChkClng(KS.S("ID")))
		KS.Echo "success"
end sub

 sub replyLock()
		If check=false Then
		  Response.Write"<script>alert('对不起，你没有锁定的权限!');history.back();</script>"
		  Exit Sub
		End If
		dim rs:set rs=server.CreateObject("adodb.recordset")
		rs.open "select top 1 * from " & getPostTable & " Where ID="& KS.ChkClng(KS.S("replyID")),CONN,1,3
		If Not RS.Eof then
		rs("verific")=2
		rs.update
		if rs("parentid")=0 then
		conn.execute("update ks_guestbook set verific=2 where id=" & rs("topicid"))
		end if
		end if
		rs.close : set rs=nothing

		'Conn.Execute("update " & getPostTable &" set verific=2 where ID=" & KS.ChkClng(KS.S("replyID")))
		Response.Redirect request.servervariables("http_referer")
end sub
 sub replyunlock()
		If check=false Then
		  Response.Write"<script>alert('对不起，你没有锁定的权限!');history.back();</script>"
		  Exit Sub
		End If
		dim rs:set rs=server.CreateObject("adodb.recordset")
		rs.open "select top 1 * from " & getPostTable & " Where ID="& KS.ChkClng(KS.S("replyID")),CONN,1,3
		If Not RS.Eof then
		rs("verific")=1
		rs.update
		if rs("parentid")=0 then
		conn.execute("update ks_guestbook set verific=1 where id=" & rs("topicid"))
		end if
		end if
		rs.close : set rs=nothing
		
		'Conn.Execute("update " & getPostTable &" set verific=1 where ID=" & KS.ChkClng(KS.S("replyID")))
		Response.Redirect request.servervariables("http_referer")
end sub
sub lockuser()
		If check=false Then
		  Response.Write"<script>alert('对不起，你没有锁定用户的权限!');history.back();</script>"
		  Exit Sub
		End If
		Conn.Execute("update KS_User set lockonclub=1 where UserID=" & KS.ChkClng(KS.S("UserId")))
		Response.Redirect request.servervariables("http_referer")
end sub
sub UNlockuser()
		If check=false Then
		  Response.Write"<script>alert('对不起，你没有锁定用户的权限!');history.back();</script>"
		  Exit Sub
		End If
		Conn.Execute("update KS_User set lockonclub=0 where UserID=" & KS.ChkClng(KS.S("UserId")))
		Response.Redirect request.servervariables("http_referer")
end sub

sub movetopic()
        managehead
		Dim TopicIds:TopicIds=KS.FilterIds(KS.S("ID"))
		If TopicIds="" Then
		  KS.AlertHintScript "对不起,您没有选中要移动的主题!"
		End If
		If check=false Then
		  Response.Write"<script>$.dialog.alert('对不起，您没有移动帖子到目标版面的权限!',function(){history.back();});</script>"
		  Exit Sub
		End If
		dim rs,oldboardid,replynum,boardid
		boardid=KS.ChkClng(KS.S("Boardid"))
		if boardid=0 then
		 KS.AlertHintScript "版面参数出错!"
		end if
		set rs=server.createobject("adodb.recordset")
		rs.open "select top 100 * from ks_guestbook where id in(" & TopicIds & ")",conn,1,1
		if not rs.eof then
		 Do While Not RS.Eof
			 oldboardid=rs("boardid")
			 if oldboardid=boardid then
			  rs.close
			  set rs=nothing
			   Response.Redirect request.servervariables("http_referer")
			 end if
			 replynum=conn.execute("select count(id) from " & rs("postTable") & " where topicid=" & rs("id"))(0)
			 Conn.Execute("Update KS_GuestBoard set PostNum=PostNum-" & replynum &",TopicNum=TopicNum-1 where PostNum>" & replynum & " and id=" & oldboardid)
			 Conn.Execute("Update KS_GuestBoard set PostNum=PostNum+" & replynum &",TopicNum=TopicNum+1 where id=" & boardid)
			 Conn.Execute("update ks_guestbook set BoardID=" & Boardid & " where ID=" & rs("id"))
		 RS.MoveNext
		 Loop
			 rs.close
			 set rs=nothing
			 
			KS.Die "<script>top.box.content('<div style=""text-align:center;font-size:14px;padding-top:20px;""><img src=""../../images/default/2.png"" align=""absmiddle""/>恭喜，帖子移动成功!<br/><input type=""button"" class=""btn"" value=""确定"" onclick=""parent.location.href=\'" & KS.GetClubListUrl(oldboardid) &"\';""/></div>').title('操作成功');</script>"
		end if
		rs.close
		set rs=nothing
		Response.Redirect request.servervariables("http_referer")
end sub

'帖子推送
sub pushtopic()
		Dim TopicId:TopicId=KS.ChkClng(KS.S("ID"))
		Dim ModelID:ModelID=KS.ChkClng(KS.S("ModelID"))
		Dim ClassID:ClassID=KS.S("ClassID")
		If TopicId=0 Then  KS.Die escape("err:对不起,您没有选中要推送的主题!")
		If ModelID=0 Then  KS.Die escape("err:对不起，您没有选择模型!") 
		If ClassID="" Then KS.Die escape("err:对不起，您没有选择目标栏目!")
		If check=false or KS.IsNul(KS.C("AdminName")) Then
		  KS.Die Escape("err:对不起，您没有推送帖子的权限!")
		End If
		Dim RS:Set RS=Conn.Execute("Select top 1 * From KS_GuestBook Where ID=" & ID)
		If RS.Eof And RS.Bof Then
		  RS.Close : Set RS=Nothing
		  KS.Die Escape("err:对不起，找不到要推送的帖子!")
		End If
		Dim Title,PhotoUrl,Inputer,PostTable,Content,IsPic,Hits,Fname,FnameType,TemplateID,WapTemplateID
		PostTable=RS("PostTable")
		Title=KS.LoseHtml(RS("Subject"))
		PhotoUrl=RS("Face") : IsPic=RS("IsPic") : If IsPic<>0 Then IsPic=1
		Inputer=RS("UserName"): Hits=RS("Hits")
		
		RS.Close
		Set RS=Conn.Execute("Select top 1 * From " & PostTable & " Where TopiciD=" & ID & " And ParentID=0")
		If RS.Eof And RS.Bof Then
		  RS.CLose : Set RS=Nothing
		  KS.Die escape("err:对不起，读取帖子内容出错!")
		End If
		Content=Ubbcode(RS("Content"),0)
		RS.Close
		Dim Recommend:Recommend=KS.ChkClng(KS.G("Recommend"))
		Dim Rolls:Rolls=KS.ChkClng(KS.G("Rolls"))
		Dim Strip:Strip=KS.ChkClng(KS.G("Strip"))
		Dim Popular:Popular=KS.ChkClng(KS.G("Popular"))
		Dim pubindex:pubindex=KS.ChkClng(KS.G("pubindex"))
		Dim PubClass:PubClass=KS.ChkClng(KS.G("PubClass"))
		Dim PubContent:PubContent=KS.ChkClng(KS.G("PubContent"))
		
		Dim RSC:Set RSC=Server.CreateObject("ADODB.RECORDSET")
		RSC.Open "select top 1 * from KS_Class Where ID='" & ClassID & "'",conn,1,1
			 if RSC.Eof Then 
			      RSC.Close :Set RSC=Nothing
				  KS.Die escape("err:栏目不存在!")
			 Else
					 FnameType=RSC("FnameType")
					 Fname=KS.GetFileName(RSC("FsoType"), Now, FnameType)
					 TemplateID=RSC("TemplateID")
					 WapTemplateID=RSC("WapTemplateID")
			End If
		 RSC.Close:Set RSC=Nothing
		
		RS.Open "select top 1 * from " & KS.C_S(ModelID,2) &" where 1=0", conn, 1, 3
			RS.AddNew
			RS("Title")          = Title
			RS("Intro")          = KS.Gottopic(Intro,200)
			RS("ArticleContent") = Content
			RS("PicNews")        = IsPic
			RS("PhotoUrl")       = PhotoUrl
			RS("Recommend")      = Recommend
			RS("Rolls")          = Rolls
			RS("Strip")          = Strip
			RS("Popular")        = Popular
			RS("Verific")        = 1
			RS("IsTop")  = 0 : RS("IsVideo")  = 0 : RS("Slide")=0
			RS("Tid")            = classid
			RS("Author")         = Inputer
			RS("AddDate")        = Now
			RS("Rank")           = "★★★"
			RS("Comment")        = 1 : RS("Changes")   = 0 : RS("DelTF")   = 0 : RS("ReadPoint")   = 0
			RS("TemplateID")     = TemplateID
			RS("WapTemplateID")  = WapTemplateID
			RS("Hits")           = Hits
			RS("HitsByDay")      = 0 : 	RS("HitsByWeek")     = 0 : RS("HitsByMonth")    = 0
			RS("Fname")          = Fname
			RS("Inputer")        = Inputer
			RS("RefreshTF")      = PubContent
			RS("PostID")         = ID
			RS("PostTable")      = PostTable
            RS.Update
		    RS.MoveLast
			Dim ItemID:ItemID=RS("ID")
		  If Left(Ucase(Fname),2)="ID" Then
				RS("Fname") = ItemID & FnameType
				RS.Update
		  End If
					 
			 Call LFCls.AddItemInfo(ModelID,ItemID,Title,ClassID,KS.Gottopic(Intro,200),"",PhotoUrl,now,Inputer,Hits,0,0,0,Recommend,Rolls,Strip,Popular,0,0,1,1,RS("Fname"))
	 		 '关联上传文件
			Call KS.FileAssociation(ModelID,Rs("ID"),Content & PhotoUrl,0)
			Conn.Execute("Update KS_GuestBook Set ChannelID=" & ModelID &",InfoID=" & ItemID & " Where ID=" & ID)	
			Dim RefreshTips
			If PubContent=1 Or PubClass=1 Or PubIndex=1 Then
				Dim KSRObj:Set KSRObj=New Refresh
				If PubContent=1 Then
					If (KS.C_S(ModelID,7)="1" or KS.C_S(ModelID,7)="2") Then
							 Dim DocXML:Set DocXML=KS.RsToXml(RS,"row","root")
							 Set KSRObj.Node=DocXml.DocumentElement.SelectSingleNode("row")
							  KSRObj.ModelID=ModelID
							  KSRObj.ItemID = KSRObj.Node.SelectSingleNode("@id").text 
							  Call KSRObj.RefreshContent()
							  RefreshTips="生成内容页成功! 地址:<a href='" & KS.GetItemURL(modelID,classid, KSRObj.Node.SelectSingleNode("@id").text, KSRObj.Node.SelectSingleNode("@fname").text) & "' target='_blank'>" & KS.GetItemURL(modelID,classid, KSRObj.Node.SelectSingleNode("@id").text, KSRObj.Node.SelectSingleNode("@fname").text) & "</a><BR/>"
					End If
					RS.Close
				End If
				
				If PuBClass=1 And KS.C_S(ModelID,7)="1" Then
				 Dim TS:TS=KS.C_C(ClassID,8)
				 If TS<>"" Then
				   FCls.FsoListNum=3
				   RS.Open "Select * From KS_Class Where ID in('" & Replace(TS,",","','") & "')",Conn,1,1
				   Do While Not RS.EOf 
				    Call KSRobj.RefreshFolder(RS("ChannelID"),RS)
				    RefreshTips=RefreshTips & "生成栏目页成功！地址：<a href='" & KS.GetFolderPath(RS("ID")) & "' target='_blank'>" & KS.GetFolderPath(RS("ID")) &"</a><br/>"
				   RS.MoveNext
				   Loop
				   RS.Close
				 End If
				End If
				If PubIndex=1 And Split(KS.Setting(5),".")(1)<>"asp" Then
				  Call KSRObj.FSOSaveFile(KSRObj.ReplaceRA(KSRObj.KSLabelReplaceAll(KSRObj.LoadTemplate(KS.Setting(110))),""), KS.Setting(3) & KS.Setting(5))
				  RefreshTips=RefreshTips & "生成网站首页成功！地址：<a href='" & KS.GetDomain & KS.Setting(5)& "' target='_blank'>" & KS.GetDomain & KS.Setting(5) &"</a><br/>"
				End If
				Set KSRobj=Nothing
            Else
			 RS.Close
			End If
			Set RS = Nothing
	If RefreshTips="" Then 
	  RefreshTips=	"恭喜，帖子成功推送！<a href=""../item/show.asp?m=" & ModelID & "&d=" & ItemID & """ target=""_blank"">点此查看</a>!" 
    Else 
	 RefreshTips="<strong><font color=""#ff6600"">恭喜，帖子成功推送! </font></strong><br/> "& RefreshTips	
	End If
	KS.Die Escape(RefreshTips)
end sub 


'批量审核
sub verifictopic()
    dim id:id=KS.FilterIds(KS.S("ID"))
	If Id="" Then
	   KS.Die "没有选择要审核的帖子!"
	End If
	If check=false Then
	   KS.Die "对不起，你没有批量审核权限!"
	End If

	Dim RS,ChannelID,InfoID,Verify,PostTable
	Verify=KS.ChkClng(KS.S("V")) : If Verify=2 Then Verify=0
	Set RS=Conn.Execute("Select Top 1 * From KS_GuestBook Where Id in(" & Id & ")")
	If Not RS.Eof Then
	  Do While Not RS.Eof
	    ChannelID=RS("ChannelID"): InfoID=RS("InfoID"):PostTable=RS("PostTable")
		If ChannelID<>0 And InfoID<>0 Then
		  Conn.Execute("Update " & KS.C_S(ChannelID,2) & " Set verific=" & Verify & " Where ID=" & InfoID)
		  Conn.Execute("Update KS_ItemInfo Set verific=" & Verify & " Where ChannelID=" & ChannelID & " And ID=" & InfoID)
		End If
	    Conn.Execute("Update "& PostTable & " Set Verific=" & KS.ChkClng(KS.S("V")) &" Where parentid=0 and topicId=" & rs("Id"))
		RS.MoveNext
	  Loop
	End If
	RS.Close :Set RS=Nothing

	Conn.Execute("Update KS_GuestBook Set Verific=" & KS.ChkClng(KS.S("V")) &" Where Id in(" & Id & ")")
	KS.Die "success"
End Sub


'检查版主或管理员	 
function check()
	 	Dim KSLoginCls
		Set KSLoginCls = New LoginCheckCls1
		If cbool(KSLoginCls.Check)=true Then
		  check=true
		  Exit function
		else
		    master=LFCls.GetSingleFieldValue("select top 1 master from ks_guestboard where id=" & BoardID)
			Dim KSUser:Set KSUser=New UserCls
			If Cbool(KSUser.UserLoginChecked)=false Then 
			  check=false
			  exit function
			elseif KSUser.GetUserInfo("ClubSpecialPower")=2 Or KSUser.GetUserInfo("ClubSpecialPower")=1 Then
			  check=true
			  exit function
			else
			   check=KS.FoundInArr(master, KSUser.UserName, ",")
			End If
		end if
End function

			
			

%>