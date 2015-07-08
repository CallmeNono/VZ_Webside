<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%

Dim KSCls
Set KSCls = New User_myask
KSCls.Kesion()
Set KSCls = Nothing

Class User_myask
        Private KS,KSUser
		Private CurrPage,totalPut,i,PageNum
		Private RS,MaxPerPage,SQL,tablebody,action
		Private ComeUrl,TotalPages
		Private Sub Class_Initialize()
			MaxPerPage =10
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
		ComeUrl=Request.ServerVariables("HTTP_REFERER")
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  KS.Die "<script>top.location.href='Login';</script>"
		End If
		KSUser.CheckPowerAndDie("s19")
		Action=Request("action")
		CurrPage=KS.ChkClng(Request("page"))
		if CurrPage<=0 Then CurrPage=1
		Call KSUser.Head()
		TopNav
		Select Case action
		  case "cancel"  Call FavCancel() : KS.Die ""
		  case "applyMedal" applyMedal
		  case "medal" Medal
		  case else	 info
        End select
	  End Sub

	  Sub TopNav()
	  %>
	  <div class="tabs">	
			<ul>
				<li<%If action="" then KS.Echo " class='puton'"%>><a href="?">我的主题</a></li>
				<li<%If action="cy" Then KS.Echo " class='puton'"%>><a href="?action=cy">参与的主题</a></li>
				<li<%If action="fav" Then KS.Echo " class='puton'"%>><a href="?action=fav">我的收藏</a></li>
				<li<%If action="medal" Then KS.Echo " class='puton'"%>><a href="?action=medal">勋章中心</a></li>
			</ul>
		</div>
	  <%
	  End Sub
	  sub info()
		Call KSUser.InnerLocation("我发表的主题")
		%>
		<div style="padding:5px;margin:10px;background:#EFF8FF;border:1px dashed #84BDE9">
	   <form action="user_mytopic.asp" method="post" name="searchform">
	   <input type="hidden" name="action" value="<%=request("action")%>"/>
				主题搜索：</strong>  关键字 <input type="text" name="KeyWord" onfocus="if (this.value=='关键字'){this.value=''}" class="textbox" value="<%if request("keyword")<>"" then response.write ks.s("keyword") else response.write "关键字"%>" size=20>&nbsp;<input class="button" type="submit" name="submit1" value=" 搜 索 ">
		</form>
        </div>
		<table height='400' width="99%" align="center">
			<tr>
			<td valign="top">
		
   <%
          select Case Action
		   case "fav" fav
		   case else quesion
		  end select
		  
    Call KS.ShowPage(totalput, MaxPerPage, "", CurrPage,false,true)
   %>
			 </td>
			 </tr>
		    </table>
		<%
			if request("action")="cy" then
	  ks.echo "<div style='color:red'><strong>说明：</strong>我参与的主题最多列出当前数据表的200条记录。</div>"
	end if

	end sub
	
	Sub Quesion()
	%>
	<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1" class="border">
			<tr height="28" class="title">
				<td height="25" align="center">主题</td>
				<td height="25" align="center">版块</td>
				<td width="10%" align="center">回复</td>
				<td width="15%" align="center">最后发表</td>
			</tr>
		<% 
		   dim 	sql

		
			dim param:param=" where username='" & ksuser.username &"'"
				if not ks.isnul(ks.s("keyword")) then param=param & " and subject like '%" & ks.s("keyword") & "%'"

		
			'取帖子存放数据表
			if request("action")="cy" then
				Dim Nodes,Doc,TableName
				set Doc = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
				Doc.async = false
				Doc.setProperty "ServerHTTPRequest", true 
				Doc.load(Server.MapPath(KS.Setting(3)&"Config/clubtable.xml"))
				Set Nodes=Doc.DocumentElement.SelectSingleNode("item[@isdefault='1']")
				TableName=nodes.selectsinglenode("tablename").text
				Set Doc=Nothing
				sql="select * from KS_Guestbook where id in(select top 200 topicid from " & TableName & param &") order by LastReplayTime desc"
			else
			    sql="select * from KS_Guestbook " & param & " order by id desc"
			end if
		
			set rs=server.createobject("adodb.recordset")
			rs.open sql,Conn,1,1
			if rs.eof and rs.bof then
		%>
			<tr>
				<td height="26" colspan=4 align=center valign=middle  class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">您没有发表过任何主题！</td>
			</tr>
		<%else
		          totalPut = RS.RecordCount
			      If CurrPage > 1  and (CurrPage - 1) * MaxPerPage < totalPut Then
						RS.Move (CurrPage - 1) * MaxPerPage
				  End If
				  i=0
		      do while not rs.eof
			    if i mod 2=0 then
				%>
				<tr class='tdbg'  onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
				<%
				else
				%>
				<tr class='tdbg trbg'>
				<%
				end if
				Dim PhotoUrl:PhotoUrl=RS("face")
		        If KS.IsNul(PhotoUrl) Then PhotoUrl=KSUser.GetUserInfo("UserFace")
				%>
							<td height="25" class="splittd">
							<div class="ContentTitle">
							<a href="<%=KS.GetClubShowUrl(rs("id"))%>" target="_blank"><img src="<%=PhotoUrl%>" style="margin-right:3px;border:1px solid #ccc;padding:2px" onerror="this.src='../images/face/boy.jpg';" width="52" height="52" align="left"/></a>
							 <a href="<%=KS.GetClubShowUrl(rs("id"))%>" target="_blank"><%=rs("subject")%></a> 
							</div>
							<div class="Contenttips">
			                 &nbsp;<span>发表时间:[<%=KS.GetTimeFormat1(rs("addtime"),false)%>]
							  状态:[<%if rs("verific")="1" then response.write "已审核" else response.write "未审核"%>]
							 </span>
							 </div>
							</td>
                            <td class="splittd" align="center">
							<%
							Dim Node
							KS.LoadClubBoard
			               Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & rs("boardid") &"]")
						   if not node is nothing then
						     KS.Echo "<a href='" & KS.GetClubListUrl(rs("boardid")) &"' target='_blank'>" & Node.SelectSingleNode("@boardname").text & "</a>"
						   else
						     KS.Echo "---"
						   end if
						   Set Node=Nothing
							%>
							</td>
							<td class="splittd" align=center>
							<%=RS("TotalReplay")%>
							</td>
							<td class="splittd" align=center>
							<a href='<%=KS.GetSpaceUrl(RS("LastReplayUserID"))%>' target='_blank'><%=RS("LastReplayUser")%></a>
							<div class="Contenttips"><%=KS.GetTimeFormat1(RS("LastReplayTime"),True)%></div>
							</td>
						</tr>
		<%
			  rs.movenext
			  I = I + 1
			  If I >= MaxPerPage Then Exit Do
			loop
			end if
			rs.close
			set rs=Nothing
		%>
</table>
	<%
	End Sub
	
	
	Sub Fav()
	%>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1">
			<tr height="28" class="title">
				<td height="25" align="center">主题</td>
				<td height="25" align="center">版块</td>
				<td width="10%" align="center">回复</td>
				<td width="15%" align="center">最后发表</td>
			</tr>
			<form name="myform" action="?action=cancel" method="post">
		<% 
			set rs=server.createobject("adodb.recordset")
			sql="select a.*,f.favorid from KS_Guestbook a inner join KS_AskFavorite f on a.id=f.topicid where f.Username='"&KSUser.UserName&"' order by LastReplayTime desc"
			rs.open sql,Conn,1,1
			if rs.eof and rs.bof then
		%>
			<tr>
				<td height="26" colspan=3 align=center valign=middle  class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">您没有收藏问题！</td>
			</tr>
		<%else
		
		            totalPut = RS.RecordCount
					If CurrPage > 1  and (CurrPage - 1) * MaxPerPage < totalPut Then RS.Move (CurrPage - 1) * MaxPerPage
					i=0
		      do while not rs.eof
				if i mod 2=0 then
						%>
						<tr class='tdbg'  onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
						<%
						else
						%>
						<tr class='tdbg trbg'>
						<%
						end if
				%>
							<td height="25" class="splittd">
							<div class="ContentTitle">
							<input type="checkbox" name="favorid" value="<%=rs("favorid")%>">
							·<a href="<%=KS.GetClubShowUrl(rs("id"))%>" target="_blank"><%=rs("subject")%></a> 
							</div>
							<div class="Contenttips">
			                 &nbsp;<span>发表时间:[<%=KS.GetTimeFormat1(rs("addtime"),false)%>]
							  状态:[<%if rs("verific")="1" then response.write "已审核" else response.write "未审核"%>]
							 </span>
							 </div>
							</td>
                            <td class="splittd" align="center">
							<%
							Dim Node
							KS.LoadClubBoard
			               Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & rs("boardid") &"]")
						   if not node is nothing then
						     KS.Echo "<a href='" & KS.GetClubListUrl(rs("boardid")) &"' target='_blank'>" & Node.SelectSingleNode("@boardname").text & "</a>"
						   else
						     KS.Echo "---"
						   end if
						   Set Node=Nothing
							%>
							</td>
							<td class="splittd" align=center>
							<%=RS("TotalReplay")%>
							</td>
							<td class="splittd" align=center>
							<a href='<%=KS.GetSpaceUrl(RS("LastReplayUserID"))%>' target='_blank'><%=RS("LastReplayUser")%></a>
							<div class="Contenttips"><%=KS.GetTimeFormat1(RS("LastReplayTime"),True)%></div>
							</td>
						</tr>	
						
						
						
		<%
			  rs.movenext
			  I = I + 1
			  If I >= MaxPerPage Then Exit Do
			
			loop
			end if
			rs.close
			set rs=Nothing
		%>
		<tr>
		 <td><input type="submit" value="取消收藏" class="button" onClick="return(confirm('确定取消收藏吗?'))"></td>
		</tr>
		</form>
	 </table>
	 <%
	End Sub
		
	Sub FavCancel()
		 Dim FavorID:Favorid=KS.FilterIDS(KS.S("favorid"))
		 if FavorID="" Then KS.AlertHintScript "对不起,您没有选择记录!"
		 Conn.Execute("Delete From KS_AskFavorite Where Favorid in(" & Favorid & ") and username='" & KSUser.UserName & "'")
		 Response.Redirect ComeUrl
	End Sub	
	
	Sub applyMedal()
	 dim i,mstr,medalArr,MedalID,Expression
	 medalID=KS.ChkClng(KS.G("MedalID"))
	 If MedalID=0 Then KS.AlertHintScript "出错啦！"
	 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
	 RS.Open "Select top 1 * From KS_GuestMedal Where MedalID=" & MedalID,conn,1,1
	 If RS.Eof And RS.Bof Then
	   RS.Close : Set RS=Nothing
	   KS.AlertHIntScript "对不起，传递参数有误！"
	 End If
	 Dim LQFs,GradeID,medalname
	 Lqfs=rs("Lqfs")
	 GradeID=rs("GradeID")
	 medalname=rs("medalname")
	 Expression=split(rs("Expression")&",0,0,0,0,0,0,0,0,0,",",")
	 mstr=rs("medalid") &"|" & rs("medalname") & "|" & rs("ico")
	 RS.Close :Set RS=Nothing
	 If Lqfs="1" Then
		 If Not KS.IsNul(GradeID) Then
		   If KS.FoundInArr(gradeid,KSUser.GetUserInfo("gradeid"),",")=false Then
			 KS.AlertHintScript "对不起，您所以的论坛级别不够，申请失败！"
		   end if
		 End If
		 If KS.ChkClng(Expression(0))>0 And KS.ChkClng(KSUser.GetUserInfo("PostNum"))<KS.ChkClng(Expression(0)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少要求发帖量大于等于" & Expression(0) &"帖,您当前发了" & KSUser.GetUserInfo("PostNum") & "帖！"
		 End If
		 If KS.ChkClng(Expression(1))>0 And KS.ChkClng(KSUser.GetUserInfo("BestTopicNum"))<KS.ChkClng(Expression(1)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少要求精华帖大于等于" & Expression(1) &"帖,您当前精华帖子" & KSUser.GetUserInfo("BestTopicNum") & "帖！"
		 End If
		 If KS.ChkClng(Expression(2))>0 And KS.ChkClng(conn.execute("select count(1) from ks_guestbook where username='" & ksuser.username &"'")(0))<KS.ChkClng(Expression(2)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少要求主题帖大于等于" & Expression(2) &"帖,您当前主题帖子" & KS.ChkClng(conn.execute("select count(1) from ks_guestbook where username='" & ksuser.username &"'")(0)) & "帖！"
		 End If
		 If KS.ChkClng(Expression(3))>0 And KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(Expression(3)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少积分大于等于" & Expression(3) &"分,您当前积分" & KSUser.GetUserInfo("score") & "分！"
		 End If
		 If KS.ChkClng(Expression(4))>0 And KS.ChkClng(KSUser.GetUserInfo("Prestige"))<KS.ChkClng(Expression(4)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少威望大于等于" & Expression(4) &"分,您当前威望" & KSUser.GetUserInfo("Prestige") & "分！"
		 End If
		 If KS.ChkClng(Expression(5))>0 And KS.ChkClng(KSUser.GetUserInfo("money"))<KS.ChkClng(Expression(5)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少资金大于等于" & Expression(4) &"元,您当前资金" & KSUser.GetUserInfo("Money") & "元！"
		 End If
		 If KS.ChkClng(Expression(6))>0 And KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(Expression(6)) Then
			 KS.AlertHintScript "对不起，申请该勋章至少点券大于等于" & Expression(6) &"点,您当前点券" & KSUser.GetUserInfo("Money") & "点！"
		 End If
	 ElseIf Lqfs="2" Then '积分购买
	   If KS.ChkClng(Expression(7))>0 Then
	     If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(Expression(7)) Then
		    KS.AlertHintScript "对不起，您的积分不够，本枚勋章需要花 " & KS.ChkClng(Expression(7)) & " 分积分，您当前可用积分为 " & KS.ChkClng(KSUser.GetUserInfo("score")) & " 分!"
		 Else
		    Session("ScoreHasUse")="+" '设置只累计消费积分
		 	Call KS.ScoreInOrOut(KSUser.UserName,2,KS.ChkClng(Expression(7)),"系统","购买论坛勋章[" & medalname & "]消费!",0,0)

		 End If
	   Else
	    KS.AlertHIntScript "停止购买！"
	   End If
	 Else 
	   KS.AlertHIntScript "出错！"
	 End If
	 
	 Dim newMedalStr,MyMedal:MyMedal=KSUser.GetUserInfo("medal")
	 If Not KS.IsNul(MyMedal) Then
	   medalArr=split(MyMedal,"@@@")
	   for i=0 to ubound(medalArr)
	     if split(medalArr(i),"|")(0)<>medalid then
		   if newMedalStr="" then
		   newMedalStr=medalArr(i)
		   else
		    newmedalStr=newmedalStr & "@@@" & medalArr(i)
		   end if
		 end if
	   next
	 End If
	 if newmedalStr="" then
	   newmedalStr=mstr
	 else
	   newmedalStr=newmedalStr & "@@@" & mstr
	 end if
	If IsObject(Session(KS.SiteSN&"UserInfo")) Then Session(KS.SiteSN&"UserInfo").DocumentElement.SelectSingleNode("row").SelectSingleNode("@medal").Text=newmedalStr
	 Conn.Execute("Update KS_User Set Medal='" & newmedalStr & "' where username='" & KSUser.UserName &"'")
	 If Lqfs="1" Then
	  KS.AlertHintScript "恭喜，勋章申请成功！！！"
	 Else
	  KS.AlertHintScript "恭喜，勋章购买成功！！！"
	 End If
	End Sub
	
	Sub Medal()
	 Call KSUser.InnerLocation("勋章中心")
	 Dim i,medalArr,MyMedal,MedalIds
	 MyMedal=KSUser.GetUserInfo("medal")
	%>
	<style type="text/css">
	 .medallist{margin:6px;}
	 .medallist li{width:150px;float:left;text-align:center;}
	 .medallist .h{height:130px}
	 .normal{color:#999;font-weight:normal}
	</style>
	<script src="../ks_inc/jquery.imagePreview.1.0.js"></script>
	 <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="border">
		<tr height="28" class="title">
				<td height="25">&nbsp;我 的 勋 章</td>
				<td class="normal"><%if KS.IsNul(myMedal) Then
		     response.write "您拥有有 0 枚勋章!"
			else
			  medalArr=split(mymedal,"@@@")
			 response.write "您拥有有 <font color=#ff6600>" & ubound(medalArr)+1 & "</font> 枚勋章!"
			end if
			
		  %></td>
	    </tr>
		<tr>
		 <td class="splittd" colspan="2">
		  <div class="medallist">
		   <ul>
		  <%if isArray(medalArr) Then
		    for i=0 to ubound(medalArr)
			  MedalIds=MedalIds & split(medalArr(i),"|")(0) & ","
			  response.write "<li><img src='../" & KS.Setting(66) & "/images/medal/" & split(medalArr(i),"|")(2) &"'><br/>" & split(medalArr(i),"|")(1) & "</li>"
			next
			else
			  response.write "<li>您没有勋章!</li>"
			end if
		  %>
		  </ul>
		  </div>
		 </td>
		</tr>
		<tr height="28" class="title">
				<td height="25">&nbsp;全 部 勋 章</td>
				<td class="normal">以下列出本站的全部勋章，带申请的勋章您可以申请拥有。</td>
	    </tr>
		<tr>
		 <td class="splittd" colspan="2">
		  <div class="medallist">
		   <ul>
		  <%
		  dim rs:set rs=conn.execute("select medalid,medalname,ico,descript,LQFS,Expression From KS_GuestMedal Where status=1 order by medalid")
		  Do While Not RS.Eof
			  response.write "<li class=""h""><a target='_blank' title='" & rs("descript") & "' href='../" & KS.Setting(66) & "/images/medal/" & rs("ico") &"' class='preview'><img width='30' src='../" & KS.Setting(66) & "/images/medal/" & rs("ico") &"'></a><br/><strong>" & rs("medalname") & "</strong>"
			 if KS.FoundInArr(MedalIds,rs("medalid"),",") Then
			    response.write "<div><input type='button' value='已拥有√' disabled></div>"
			 Else
			  if rs("lqfs")="1" then
			    response.write "<div><form action='?' method='post'><input type='hidden' name='medalid' value='" & rs("medalid") & "'/><input type='hidden' name='action' value='applyMedal'/><input type='submit' value=' 申 请 ' class='button'></form></div>"
			  elseif rs("lqfs")="2" then
			    response.write "<div><form action='?' method='post'><input type='hidden' name='medalid' value='" & rs("medalid") & "'/><input type='hidden' name='action' value='applyMedal'/><input type='submit' value=' 购买（花" & split(rs("Expression"),",")(7) &" 积分） ' class='button'></form></div>"
			  else
			    response.write "<div><input type='button' value='人工授予' disabled></div>"
			  end if
			 End If
			  response.write "</li>"
			  rs.movenext
		  Loop
		  RS.Close
		  Set RS=Nothing
		  %>
		  </ul>
		  </div>
		 </td>
		</tr>
	</table>
	<%
	End Sub
End Class
%> 
