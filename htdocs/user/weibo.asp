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
Set KSCls = New WeiBoCls
KSCls.Kesion()
Set KSCls = Nothing

Class WeiBoCls
        Private KS,KSUser,KSR,F_C,UserID,UserXML,Nickname
		Private Sub Class_Initialize()
		 If (Not Response.IsClientConnected)Then
			Response.Clear
			Response.End
		 End If
		  Set KS=New PublicCls
		  Set KSUser=New  UserCls
		  Set KSR = New Refresh
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/Kesion.IfCls.asp"-->
		<!--#include file="../KS_Cls/UbbFunction.asp"-->
		<%
       Sub Echo(sStr)
			 Response.Write sStr 
			 'Response.Flush()
		End Sub
		public Sub ScanTemplate(ByVal sTemplate)
			Dim iPosLast, iPosCur
			iPosLast    = 1
			Do While True 
				iPosCur    = InStr(iPosLast, sTemplate, "{#") 
				If iPosCur>0 Then
					Echo    Mid(sTemplate, iPosLast, iPosCur-iPosLast)
					iPosLast  = ParseTemplate(sTemplate, iPosCur+2)
				Else 
					Echo    Mid(sTemplate, iPosLast)
					Exit Do  
				End If 
			Loop
		End Sub	
			
		Public Sub Kesion()
		   UserID=KS.ChkClng(Request("UserID"))
		   If KSUser.UserLoginChecked=FALSE Then Response.Redirect("login")
		   If UserID=0 Then  UserID=KS.CHkClng(KSUser.GetUserInfo("UserID"))
		   InitialUserInfo
		   IF KS.ChkClng(Request("UserID"))=0 Then
		     Nickname="我"
		   Else
		     If GetNodeText("sex")="男" Then Nickname="他" Else NickName="她"
		   End If
		   IF KS.ChkClng(KS.SSetting(55))=0 Then  Call KS.ShowTips("error","对不起，本站没有开通微博频道!"):KS.Die ""
		   
		   
		   Dim TPath:TPath=KS.SSetting(31)  '模板地址
		   F_C = RexHtml_IF(KSR.LoadTemplate(TPath))
		   FCls.RefreshType = "weibo" '设置刷新类型，以便取得当前位置导航等
		   FCls.RefreshFolderID = "0" '设置当前刷新目录ID 为"0" 以取得通用标签
		   F_C=KSR.KSLabelReplaceAll(F_C)
		   ScanTemplate F_C
		   
		End Sub
		
		'初始化会员资料
		Sub InitialUserInfo()
		  Dim RS:Set RS=server.CreateObject("adodb.recordset")
		  RS.Open "select top 1 * From KS_User Where Userid=" & UserID,conn,1,1
		  If RS.Eof And RS.Bof THen
		  Else
		    Set UserXML=KS.RsToxml(RS,"row","userxml")
		  End If
		  RS.Close:Set RS=Nothing
		End Sub
		Function GetNodeText(ByVal fieldname)
		  fieldname=lcase(FieldName)
		  If Not IsObject(UserXML) Then GetNodeText="":Exit Function
		  Dim Node:Set Node=UserXML.documentElement.selectSingleNode("row/@" & fieldname)
		  If Node Is Nothing Then
		    GetNodeText=""
		  Else
		    GetNodeText=Node.Text
		  ENd If
		End Function
		

Function ParseTemplate(sTemplate, iPosBegin)
		Dim iPosCur, sToken, sTemp,MyNode,CheckJS
		iPosCur      = InStr(iPosBegin, sTemplate, "}")
		sTemp        = Mid(sTemplate,iPosBegin,iPosCur-iPosBegin)
		iPosBegin    = iPosCur+1
		select case Lcase(sTemp)
			case "userid"  echo userid
			case "username" echo GetNodeText("username")
			case "groupname" echo KS.U_G(GetNodeText("groupid"),"groupname")
			case "nickname" echo Nickname
			case "showrealname" if GetNodeText("realname")<>"" then echo GetNodeText("realname") Else Echo GetNodeText("UserName")
			case "spaceurl" ShowSpaceUrl
			case "showattentionbutton" ShowAttentionButton
			case "showrightattention" ShowRightAttention
			case "showrightfans" ShowRightFans
			case "showannounce"  ShowAnnounce
			case "myusername" echo KSUser.GetUserInfo("username")
			case "mygroupname" echo KS.U_G(KSUser.GetUserInfo("groupid"),"groupname")
			case "mymsgnum" echo KS.ChkClng(KSUser.GetUserInfo("msgnum"))
			case "myattentionnum" echo KS.ChkClng(KSUser.GetUserInfo("attentionnum"))
			case "myfansnum" echo KS.ChkClng(KSUser.GetUserInfo("fansnum"))
			case "mylabelnum" showmylabelnum
			case "mylabel" showmylabel
			
			case "maxlen" if KS.ChkClng(KS.SSetting(50))=0 or KS.ChkClng(KS.SSetting(34))>255 then echo "255" else echo KS.ChkClng(KS.SSetting(34))
			case "showsynchronizedoption"  echo KSUser.ShowSynchronizedOption(CheckJS)
			case "checkjs" echo checkjs
			case "weibotitle" ShowWeiboTitle
			case "weibolist" 
			  if request("f")="att" then
			    ShowAttentionList
			  Elseif request("f")="fans" then
			    ShowFansList
			  Else
			    ShowWeiBoList
			  End If
			case "userface"
			  Dim UserFaceSrc:UserFaceSrc=GetNodeText("UserFace")
			  if left(userfacesrc,1)<>"/" and lcase(left(userfacesrc,4))<>"http" then userfacesrc=KS.Setting(3) & userfacesrc
			  response.write userfacesrc
			case else
			  response.write GetNodeText(sTemp)
		end select
		 ParseTemplate=iPosBegin
End Function
'显示我的标签
Sub showmylabel()
    dim mylabel:mylabel=ksuser.getuserinfo("mylabel")&""
	dim labelnum:labelnum=ubound(split(mylabel," "))
	dim i
	 if labelnum<=0 then
		    ks.echo "<br/>您还没有设置个性标签，<label href=""javascript:;"" style=""text-decoration:underline;cursor:hand;"" onclick=""setlabel()"">点此设置</label>。"
	 else
		 mylabel=split(mylabel," ")
		 for i=0 to ubound(mylabel)
			echo "<a target='_blank' class='mylink' title=""查找相同会员"" href='UserList.asp?tag=" & server.URLEncode(mylabel(i)) & "'>" & mylabel(i) & "</a>"
		next
	 end if
End Sub
Sub showmylabelnum()
    dim mylabel:mylabel=ksuser.getuserinfo("mylabel")&""
	dim labelnum:labelnum=ubound(split(mylabel," "))
	if labelnum<0 then labelnum=0
	echo labelnum
End Sub

'显示Title
Sub ShowWeiboTitle()
 if ks.chkclng(request("userid"))=0 then
   if request("f")="att" then
     echo "微博-我的关注"
   elseif request("f")="fans" then
     echo "微博-我的粉丝"
   else
     echo "微博-广播大厅"
   end if
 else
    Dim U:U=GetNodeText("realname")
	if ks.isnul(u) then u=GetNodeText("username")
   if request("f")="att" then
     echo U & "的微博-" & NickName & "的关注"
   elseif request("f")="fans" then
     echo U & "的微博-" & NickName & "的粉丝"
   else
     echo U & "的微博-" & NickName & "的广播"
   end if
 end if
End Sub

'显示关注按钮
Sub ShowAttentionButton()
 If not conn.execute("select top 1 [type] from ks_userr where a=" & KS.ChkClng(KSUser.GetUserInfo("UserID")) & " and b=" & userid & " and [type]=1").eof then
   If not conn.execute("select top 1 [type] from ks_userr where B=" & KS.ChkClng(KSUser.GetUserInfo("UserID")) & " and A=" & userid & " and [type]=1").eof then
    echo "<span><img src=""images/gz.jpg"" align=""absmiddle""/>我与" & GetNodeText("UserName") & "已相互关注</span>，<a href=""javascript:;"" onclick=""cancelatt(" & userid& ",0,'true');"">取消关注</a>"
   Else
    echo "<span><img src=""images/ok.gif"" align=""absmiddle""/>已关注，<a href=""javascript:;"" onclick=""cancelatt(" & userid& ",0,'true');"">取消关注</a></span>"
   End If
 Else
   echo "<a href=""javascript:;"" onclick=""addatt(" & UserID & ",'true')""><img src=""../images/default/addgz.gif"" align=""absmiddle"" title=""添加关注""/></a>"
 End If
End Sub

'显示公告
Sub ShowAnnounce()
 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
 RS.Open "select top 1 * From KS_Announce Where channelid=9990 order by NewestTF desc,id desc",conn,1,1
 if rs.eof and rs.bof then
  echo "没有公告!"
 else
   echo KS.Gottopic(KS.LoseHtml(rs("content")),70) & " <a href='../plus/Announce/?" & rs("Id") & "' target='_blank'>查看详情&raquo;</a>"
 end if
 rs.close:set rs=nothing
End Sub

'显示右边的关注
Sub ShowRightAttention()
   Dim SQLStr:SQLStr="select  top 6 a.id,b.username,b.userid,b.msgnum,b.fansnum,b.attentionnum from KS_UserR a inner join KS_User b On a.B=b.userID Where a.type=1 and A.A=" &UserID & " order by b.UserID"
   Dim RS:Set RS=SERVER.CreateObject("ADODB.RECORDSET")
   RS.Open SQLStr,conn,1,1
   If RS.Eof And RS.Bof Then
   echo NickName & "没有关注!"
   Else
     Do While Not RS.Eof
%>
         <li> <div class="avatar48"><a title="关注<%=rs("attentionnum")%>人，粉丝<%=rs("fansnum")%>人,广播<%=rs("msgnum")%>条。" href="?userid=<%=rs("userid")%>" target="_blank"><img onerror="this.src='images/noavatar_small.gif';" src="../uploadfiles/user/avatar/<%=rs("userid")%>.jpg"  /></a></div>
		<p><a href="?userid=<%=rs("userid")%>" title="<%=rs("username")%>" target="_blank"><%=rs("username")%></a></p></li>
<%   RS.MoveNext
    Loop
  End If
  RS.Close
  Set RS=Nothing
End Sub
'显示右边粉丝列表
Sub ShowRightFans()
   Dim SQLStr:SQLStr="select  top 6 a.id,b.username,b.userid,b.msgnum,b.fansnum,b.attentionnum,b.province,b.city from KS_UserR a inner join KS_User b On a.b=b.userID  Where a.type=0 and A.A=" & UserID & " order by b.fansnum Desc,b.UserID"
   Dim RS:Set RS=SERVER.CreateObject("ADODB.RECORDSET")
   RS.Open SQLStr,conn,1,1
   If RS.Eof And RS.Bof Then
   echo NickName & "没有粉丝!"
   Else
     Do While Not RS.Eof
%>
     <li>
		<h1><div class="avatar48"><a title="关注<%=rs("attentionnum")%>人，粉丝<%=rs("fansnum")%>人,广播<%=rs("msgnum")%>条。" href="?userid=<%=rs("userid")%>" target="_blank"><img onerror="this.src='images/noavatar_small.gif';" src="../uploadfiles/user/avatar/<%=rs("userid")%>.jpg"  /></a></div></h1>
		<div class="mr4_r">
			<h2><span><a href="javascript:;" onclick="addatt(<%=rs("UserID")%>,'true')">+关注</a></span><a href="?userid=<%=rs("userid")%>"><%=rs("username")%></a></h2>
			<p class="num">广播<%=rs("attentionnum")%>条 粉丝<%=rs("fansnum")%>人</p>
		</div>
	</li>
<%   RS.MoveNext
    Loop
  End If
  RS.Close
  Set RS=Nothing
End Sub

'显示空间地址
Sub ShowSpaceUrl()
  If KS.SSetting(0)<>0 Then  '判断有没有开通空间
			 dim spacedomain,predomain
			 If KS.SSetting(14)<>"0" and not conn.execute("select top 1 username from ks_blog where username='" & GetNodeText("UserName") & "'").eof Then
			   predomain=conn.execute("select top 1 [domain] from ks_blog where username='" & GetNodeText("UserName") & "'")(0)
			 end if
			 if Not KS.IsNul(predomain) then
				if instr(predomain,".")=0 then
					spacedomain="http://" & predomain & "." & KS.SSetting(16)
				else
				  spacedomain="http://" & predomain
				end if
			 else
					 If KS.SSetting(21)="1" Then
						 spacedomain=KS.GetDomain & "space/" & GetNodeText("UserID")
					 Else
						 spacedomain=KS.GetDomain & "space/?" & GetNodeText("UserID")
					 End If
			 end if
		 If KSUser.CheckPower("s01")=false then
		   spacedomain=KS.GetDomain & "company/show.asp?username=" & GetNodeText("UserName")
		 End If
		
		 KS.Echo "<a href=""" & spacedomain & """ target=""_blank"" class=""modbtn"">" & spacedomain & "&nbsp;</a>"
	End If
  
 End Sub

'我的关注
Sub ShowAttentionList()
  Dim TotalPut,MaxPerPage,CurrentPage
  MaxPerPage=15
  CurrentPage=KS.ChkClng(request("page"))
  If CurrentPage<1 Then CurrentPage=1
  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
  Dim SQLStr:SQLStr="select a.id,b.username,b.userid,b.msgnum,b.fansnum,b.attentionnum,b.province,b.city,c.note,c.adddate,c.copyfrom from ((KS_UserR a inner join KS_User b On a.B=b.userID) left join ks_userlog c on c.id=b.lastpostweiboid) Where a.type=1 and A.A=" &UserID & " order by b.LastPostWeiBoTime Desc,b.UserID"
  
  RS.Open SQLStr,Conn,1,1
  If  RS.Eof and RS.Bof Then
    %>
	<div class="attentiontr" >
	<%=Nickname%>，没有关注任何人！
	</div>
	<%
  Else
     TotalPut=RS.Recordcount
	 If CurrentPage > 1  and (CurrentPage - 1) * MaxPerPage < totalPut Then
			RS.Move (CurrentPage - 1) * MaxPerPage
	 End If
	 Dim I:I=0
	 %>
	 <div class="atips"><%=Nickname%>关注了 <span id="attnum"><%=GetNodeText("attentionnum")%></span> 人：</div>
	 <%
	 do while not rs.eof
%>
 
 <dl class="attentiontr" id="attention<%=rs("id")%>" onmouseover="$('#hid<%=rs("id")%>').show();" onmouseout="$('#hid<%=rs("id")%>').hide();">
				<div class="l">
						<div class="avatar48"><a href="../user/weibo.asp?userid=<%=rs("userid")%>" target="_blank"><img onerror="this.src='images/noavatar_small.gif';" src="../uploadfiles/user/avatar/<%=rs("userid")%>.jpg"  alt="<%=rs("username")%>的头像" /></a></div>
				</div>
				<div class="r">
					<div class="t">
					  <span class="gz">
					   <%
					   if rs("userid")=ks.chkclng(ksuser.getuserinfo("userid")) then
					     response.write ""
					   elseif request("userid")<>"" and ksuser.getuserinfo("userid")<>userid  then  '访问其它人微博时
					     If not conn.execute("select top 1 [type] from ks_userr where a=" & ks.chkclng(ksuser.getuserinfo("userid")) & " and b=" & rs("userid") & " and [type]=1").eof then
						  response.write "<img src=""images/ok.gif""/>我已关注" & rs("username") 
						 Else
						   response.write  "<a href=""javascript:;"" onclick=""addatt(" & rs("UserID") & ",'true')""><img src=""../images/default/addgz.gif"" align=""absmiddle"" title=""添加关注""/></a>"

						 End If
					    %>
					   <%else%>
						   <%If not conn.execute("select top 1 [type] from ks_userr where a=" & rs("userid") & " and b=" & userid & " and [type]=1").eof then%>
							<img src="images/gz.jpg" align="absmiddle"/><br/>已相互关注
								<%if ksuser.getuserinfo("userid")=userid then%>
								<div id="hid<%=rs("id")%>" class="hid"><a href="javascript:;" onclick="cancelatt(<%=rs("userid")%>,<%=rs("id")%>);">取消关注</a></div>
								<%end if%>
						   <%else%>
						   <img src="images/ok.gif"/>已关注
							<%if ksuser.getuserinfo("userid")=userid then%>
							  <div id="hid<%=rs("id")%>" class="hid"><a href="javascript:;" onclick="cancelatt(<%=rs("userid")%>,<%=rs("id")%>);">取消关注</a></div>
							<%end if%>
						   <%end if%>
					   <%end if%>
					  </span>
					  <a href="../user/weibo.asp?userid=<%=rs("userid")%>" target="_blank" class="tname"><%=rs("username")%></a> <span class="f999"><%=rs("province")%><%=rs("city")%></span>
					 </div>
					
					 <div class="newgp"><span>最新广播：<%=KS.GetTimeFormat(RS("adddate"))%> 来自：<%=rs("copyfrom")%></span><br/><a href="#"><%=rs("note")%></a></div>
					 <span class="total">关注 <a href="#"><%=rs("attentionnum")%></a> 人 | 粉丝 <a href="#"><%=rs("fansnum")%></a> 人 | 广播 <a href="#"><%=rs("msgnum")%></a> 条</span>
										
				</div>
</dl>
	 <%
	  i=i+1
	  If I>=MaxPerPage Then Exit Do
	 rs.movenext
	 loop
	 %>
	 <div id='fenye' class='fenye'> <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%></div>
	 <%
  End If
End Sub

'我的粉丝
Sub ShowFansList()
 Dim TotalPut,MaxPerPage,CurrentPage
  MaxPerPage=15
  CurrentPage=KS.ChkClng(request("page"))
  If CurrentPage<1 Then CurrentPage=1
  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
  Dim SQLStr:SQLStr="select a.id,b.username,b.userid,b.msgnum,b.fansnum,b.attentionnum,b.province,b.city,c.note,c.adddate,c.copyfrom,a.type from ((KS_UserR a inner join KS_User b On a.b=b.userID) left join ks_userlog c on c.id=b.lastpostweiboid) Where a.type=0 and A.A=" & UserID & " order by b.LastPostWeiBoTime Desc,b.UserID"
  RS.Open SQLStr,Conn,1,1
  If  RS.Eof and RS.Bof Then
    %>
	<div class="attentiontr" >
	 要加油了，还没有人关注<%=Nickname%>哦 ^-^
	</div>
	<%
  Else
     TotalPut=RS.Recordcount
	 If CurrentPage > 1  and (CurrentPage - 1) * MaxPerPage < totalPut Then
			RS.Move (CurrentPage - 1) * MaxPerPage
	 End If
	 Dim I:I=0
	 %>
	 <div class="atips"><%=Nickname%>有 <span id="attnum"><%=GetNodeText("fansnum")%></span> 人粉丝：</div>
	 <%
	 do while not rs.eof
%>
 
 <dl class="attentiontr" id="attention<%=rs("id")%>" onmouseover="$('#hid<%=rs("id")%>').show();" onmouseout="$('#hid<%=rs("id")%>').hide();">
				<div class="l">
					<div class="avatar48"><a href="../user/weibo.asp?userid=<%=rs("userid")%>" target="_blank"><img onerror="this.src='images/noavatar_small.gif';" src="../uploadfiles/user/avatar/<%=rs("userid")%>.jpg"  alt="<%=rs("username")%>的头像" /></a></div>
				</div>
				<div class="r">
					<div class="t">
					  <span class="gz">
					  <%
					   if rs("userid")=ks.chkclng(ksuser.getuserinfo("userid")) then
					     response.write ""
					   elseif request("userid")<>"" and ksuser.getuserinfo("userid")<>userid  then  '访问其它人微博时
					     If not conn.execute("select top 1 [type] from ks_userr where a=" & ks.chkclng(ksuser.getuserinfo("userid")) & " and b=" & rs("userid") & " and [type]=1").eof then
						  response.write "<img src=""images/ok.gif""/>我已关注" & rs("username") 
						 Else
						   response.write  "<a href=""javascript:;"" onclick=""addatt(" & rs("UserID") & ",'true')""><img src=""../images/default/addgz.gif"" align=""absmiddle"" title=""添加关注""/></a>"

						 End If
					    %>
					   <%else
					     if not conn.execute("select top 1 [type] From KS_UserR Where A=" &UserID & " and B=" & RS("UserID") & " and [type]=1").eof then%>
					    <img src="images/gz.jpg" align="absmiddle"/><br/>已相互关注
						 <%if ksuser.getuserinfo("userid")=userid then%>
						  <div id="hid<%=rs("id")%>" class="hid"><a href="javascript:;" onclick="cancelatt(<%=rs("userid")%>,<%=rs("id")%>,'true');">取消关注</a></div>
						 <%end if%>
					   <%else%>
					    <a href="javascript:;" onclick="addatt(<%=rs("userid")%>,'true')"><img src="../images/default/addgz.gif" align="absmiddle" title="添加关注"/></a>
					   <%end if
					   end if%>
					  </span>
					  <a href="../user/weibo.asp?userid=<%=rs("userid")%>" target="_blank" class="tname"><%=rs("username")%></a> <span class="f999"><%=rs("province")%><%=rs("city")%></span>
					 </div>
					
					 <div class="newgp"><span>最新广播：<%=KS.GetTimeFormat(RS("adddate"))%> 来自：<%=rs("copyfrom")%></span><br/><a href="#"><%=ReplaceEmot(Ubbcode(WeiboUBB(rs("note")),i))%></a></div>
					 <span class="total">关注 <a href="#"><%=rs("attentionnum")%></a> 人 | 粉丝 <a href="#"><%=rs("fansnum")%></a> 人 | 广播 <a href="#"><%=rs("msgnum")%></a> 条</span>
										
				</div>
</dl>
	 <%
	  i=i+1
	  If I>=MaxPerPage Then Exit Do
	 rs.movenext
	 loop
	 %>
	 <div id='fenye' class='fenye'> <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%></div>
	 <%
  End If
 
 End Sub

'广播大厅
Sub ShowWeiBoList()
  Dim TotalPut,MaxPerPage,CurrentPage
  MaxPerPage=20
  CurrentPage=KS.ChkClng(request("page"))
  If CurrentPage<1 Then CurrentPage=1
  Dim Param:Param=" where a.status=1"
  If Request("f")="my" Then Param=Param & " and a.userid=" & KS.ChkClng(KSUser.GetUserInfo("UserID"))
  if request("topic")<>"" then Param=Param & " and b.note like '%" & KS.S("Topic") & "%'"
  if KS.ChkCLng(Request("UserID"))<>0 Then  Param=Param & " and a.userid=" & UserID
  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
  Dim ShowFields:ShowFields="b.id,a.userid,a.username,a.transtime,a.msg,b.adddate,b.copyfrom,b.note,b.cmtnum,b.username as busername,b.userid as buserid,b.transnum,a.type,a.id as rid"
  If DataBaseType=1 Then
                Dim Cmd : Set Cmd = Server.CreateObject("ADODB.Command")
				Set Cmd.ActiveConnection=conn
				Cmd.CommandText="KS_WeiBoLists"
				Cmd.CommandType=4	
				CMD.Prepared = true 	
				Cmd.Parameters.Append cmd.CreateParameter("@pagenow",3)
				Cmd.Parameters.Append cmd.CreateParameter("@pagesize",3)
				Cmd.Parameters.Append cmd.CreateParameter("@fields",200,1,2000)
				Cmd.Parameters.Append cmd.CreateParameter("@param",200,1,110)
				Cmd("@pagenow")=CurrentPage
				Cmd("@pagesize")=MaxPerPage
				Cmd("@fields")=ShowFields
				Cmd("@param")=param
				Set Rs=Cmd.Execute
				'rs.close  '注意：若要取得参数值，需先关闭记录集对象
				'TotalPut= cmd("@totalput")
				'rs.open
				Set Cmd =  Nothing
  Else
    Dim SQLStr:SQLStr="select top 500 " & ShowFields &" from ks_userlogr a left join ks_userlog b on a.msgid=b.id " & param & " order by a.id desc"
    Set RS=Conn.Execute(SQLStr)
  End If
  
  If  RS.Eof and RS.Bof Then
    %>
	<div class="original_content" >
	没有广播记录！
	</div>
	<%
  Else
     TotalPut=conn.execute("select count(1) from ks_userlogr a left join ks_userlog b on a.msgid=b.id " & param)(0)
	 If DataBaseType=0 Then
		 If CurrentPage > 1  and (CurrentPage - 1) * MaxPerPage < totalPut Then
				RS.Move (CurrentPage - 1) * MaxPerPage
		 End If
	 End If
	 Dim I:I=0
	 do while not rs.eof
	 %>
	 <div id="w<%=rs("rid")%>" class="original_content" onmouseover="$('#hid<%=rs("id")%>').show();" onmouseout="$('#hid<%=rs("id")%>').hide();">
	 
	         
			 <div class="userphoto" onmouseout="$('#gz<%=rs("rid")%>').hide();" onmouseover="$('#gz<%=rs("rid")%>').show();">
			 <div class="avatar48"><a href="../user/weibo.asp?userid=<%=rs("buserid")%>" target="_blank"><img onerror="this.src='images/noavatar_small.gif';" src="../uploadfiles/user/avatar/<%=rs("userid")%>.jpg" width="50" height="50" alt="<%=rs("username")%>的头像" /></a></div>
			 
				 <div class="popuser" id="gz<%=rs("rid")%>">
				   <%If ks.c("username")<>rs("username") then%>
				    <a href="javascript:;" onclick="addatt(<%=rs("userid")%>)">+加关注</a>
				   <%end if%>
				 </div>
			 
			 </div> 
			 
			  <div class="usertopic_main">
						<div class="c-name">
							 <a class="tx-name" href="../user/weibo.asp?userid=<%=rs("userid")%>" target="_blank"><%=RS("UserName")%></a>&nbsp;
							 <%
							   If rs("type")=0 then
							    response.write "：" & ReplaceEmot(Ubbcode(WeiboUBB(rs("note")),i))
							   else
							    response.write "转播：" & RS("Msg")
							   end if
							 %>
						 </div>
						 <%if rs("type")=1 then%>
							 <div class="clear"></div>
							 <div class="c-content">
							   <%If ks.isnul(rs("buserid")) then%>
							      <span class="tx-date">对不起，原文已经被作者删除。</span>
							   <%else%>
								  <a href="../user/weibo.asp?userid=<%=rs("buserid")%>" target="_blank"><%=rs("busername")%></a>：<%=ReplaceEmot(Ubbcode(WeiboUBB(rs("note")),i))%>
								  <div class="clear"></div>
								  <span class="tx-date"><%=KS.GetTimeFormat(RS("adddate"))%></span>
							   <%end if%>
							 </div>
						 <%end if%>
													  
						 <div class="clear"></div>
						 <div class="c-bottom" style="padding-bottom:10px">
								<span class="r">
								    
								    <span style="display:none" id="hid<%=rs("id")%>">
									<%If ksuser.username=rs("username") then%>
									<a href="javascript:;" onclick="delmsg(<%=rs("rid")%>)">删除</a> | 
									<%end if%>
									</span>
									<%If not ks.isnul(rs("buserid")) then%>
									<a href="javascript:;" id="relay_93913" onclick="trans(<%=rs("id")%>);">转播(<%=rs("transnum")%>)</a> | <a href="javascript:;" onclick="quickreply(<%=rs("id")%>)">评论(<%=rs("cmtnum")%>)</a>                                   <%end if%>
								</span>
								<span class="tx-date"><%=KS.GetTimeFormat(RS("TransTime"))%></span>
								<%if rs("type")=1 then
								  response.write "&nbsp;来自：转播@" & rs("busername")
								  elseif not ks.isnul(rs("copyfrom")) then
								  response.write "&nbsp;来自：" & rs("copyfrom")
								  end if
								%>
								
								<div class="cmt" id="cmt<%=rs("id")%>"></div>
								
						</div>
						
					 

			 </div>
	  </div>
	 <%
	  i=i+1
	  If I>=MaxPerPage Then Exit Do
	 rs.movenext
	 loop
	 %>
	 <div id='fenye' class='fenye'> <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%></div>
	 <%
  End If
  
  
End Sub	
  
   '替换表情
   Function ReplaceEmot(c)
		 Dim str:str=":)|:(|:D|:'(|:@|:o|:P|:$|;P|:L|:Q|:lol|:loveliness:|:funk:|:curse:|:dizzy:|:shutup:|:sleepy:|:hug:|:victory:|:time:|:kiss:|:handshake|:call:|55555|不是我|不要啊|亲一亲|加油|向前进|吓死你|呐喊|鸣哇|呵呵|呸|哈哈|哼|嗯|嘿嘿|困死了|天打雷劈|好闷啊|对不起|开心|很忙|抓狂|放电|无聊|汗一个|看我历害|脑残|飞吻|good|不妙啊|不是啦|交出来|亲亲|偷笑|哭|喜欢|嗯|坏笑|太好啦|好主意|好同志|悄悄走|我爱你|打你|晕菜|没良心"
		 Dim strArr:strArr=Split(str,"|")
		 Dim K,NS
		 For K=1 To 70
		  NS=Right("0" & K,2)
		  c=replace(c,"[em"&NS &"]","<img title='" & strarr(k-1) & "' alt='" & strarr(k-1) & "' src='" & KS.Setting(2) &KS.Setting(3) & "editor/ubb/images/smilies/default/" & NS & ".gif'/>")
		 Next
		 if ks.s("topic")<>"" then
		   C=replace(C,KS.S("topic"),"<font style='color:red'>" & KS.CheckXSS(KS.S("topic")) & "</font>")
		   C=replace(C,"topic=<font style='color:red'>" & KS.S("topic") & "</font>","topic=" & KS.S("topic") & "")
		   C=replace(C,"查看涉及#<font style='color:red'>" & KS.S("topic") & "</font>#话题的微博","查看涉及#" & KS.S("topic") & "#话题的微博")
		 end if
		 C=Replace(C,"{$GetSiteUrl}",KS.GetDomain)
		 ReplaceEmot=C
	End Function
	
	Function WeiboUBB(StrContent)
		If KS.IsNUL(StrContent) Then WeiboUBB=" " : Exit Function
		Dim i,re:Set re=new RegExp
		re.IgnoreCase =true
		re.Global=True
	 	'话题
		re.pattern="\#(.*?)\#"
		if re.Test(strcontent) then strcontent=re.replace(strcontent,"<a title=""查看涉及#$1#话题的微博"" class=""topiclink"" href=""weibo.asp?topic=$1"" target=new>#$1#</a>")
		'图片UBB
		re.pattern="\[img\](.*?)\[\/img\]"
		strcontent=replace(replace(strcontent,"   ","&nbsp; &nbsp;"),"  ","&nbsp;&nbsp;")
		if re.Test(strcontent) then strcontent=re.replace(strcontent,"<a onfocus=""this.blur()"" href=""javascript:;"" onclick=""showbigpic('$1');""><img src=""$1"" border=""0"" alt=""点击查看原图"" style=""max-width:400px;max-height:400px;"" onload=""if(400<this.offsetWidth)this.width='400';if(400<this.offsetHeight)this.height='400';""></a>")
	
		re.pattern="\[img=*([0-9]*),*([0-9]*)\](.*?)\[\/img\]"
		if re.Test(strcontent) then strcontent=re.replace(strcontent,"<a onfocus=""this.blur()"" href=""javascript:;"" onclick=""showbigpic('$3');""><img src=""$3"" border=""0""  width=""$1"" heigh=""$2"" alt=""点击查看原图"" style=""max-width:400px;max-height:400px;"" onload=""if(400<this.offsetWidth)this.width='400';if(400<this.offsetHeight)this.height='400';""></a>")
        WeiboUBB=StrContent
	End Function
End Class
%>
