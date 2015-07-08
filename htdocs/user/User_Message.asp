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
Set KSCls = New User_Message
KSCls.Kesion()
Set KSCls = Nothing

Class User_Message
        Private KS,KSUser
		Private Max_sEnd
        Private Max_sms
		Private Max_Num
        Private Action
        Private RS,SqlStr,ComeUrl
		Private FoundErr,Errmsg
		Private i
		Private TotalPut,MaxPerPage
		Private Sub Class_Initialize()
		   MaxPerPage=10
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
				  Response.Write "<script>top.location.href='Login';</script>"
				  Exit Sub
				End If
				
			   Max_sEnd=KS.ChkClng(KS.U_S(KSUser.GroupID,15))	'群发限制人数
			   Max_sms=KS.ChkClng(KS.U_S(KSUser.GroupID,14))	'内容最多字符数
			   Max_Num=KS.ChkClng(KS.U_S(KSUser.GroupID,13))   '最多允许存放条数
		
			  Action=Lcase(request("action"))
			  ComeUrl=Cstr(Request.ServerVariables("HTTP_REFERER"))
			  If ComeUrl="" Then ComeUrl="User_Message.asp"
			  Call KSUser.Head()
		%>
				<script language = "JavaScript">
				function CheckForm()
				{
				if (document.myform.Touser.value=='')
				{
				   alert('请输入收信人!')
				   document.myform.Touser.focus();
				   return false;
				 }
				if (document.myform.title.value=='')
				{
				   alert('请输入信件主题!')
				   document.myform.title.focus();
				   return false;
				 }

				if (CKEDITOR.instances.message.getData()=="")
					{
					alert("请输入信件内容！");
					CKEDITOR.instances.message.focus();
					return false;
					}
				 return true;  
				}
				</script>
				
				<div class="tabs">	
			<ul>
				<li<%if Action="" or Action="inbox" or action="read" or action="fw" or Action="issend" or Action="new" then response.write " class='puton'"%>><a href="User_Message.asp">短消息(<span class="red"><%=Conn.Execute("Select Count(ID) From KS_Message Where Incept='" &KSUser.UserName &"' And Flag=0 and IsSend=1 and delR=0")(0)%></span>)</a></li>
				<%If KS.SSetting(0)="1" Then%>
				<li<%If action="friendrequest" then KS.Echo " class='puton'"%>><a href="?action=friendrequest">好友请求(<font color=red><%=conn.execute("select count(id) from ks_friend where friend='" & ksuser.username & "' and accepted=0")(0)%></font>)</a></li>
				<li<%if Action="message" or Action="replaymessage" or Action="savemessagereplay" then response.write " class='puton'"%>><a href="?action=Message">空间留言(<span class="red"><%=Conn.Execute("Select Count(ID) From KS_BlogMessage Where username='" &KSUser.UserName &"' And readtf=0")(0)%></span>)</a></li>
				<li<%if Action="comment" or Action="replaycomment" or Action="savecommentreplay" then response.write " class='puton'"%>><a href="?action=Comment">博文评论(<span class="red"><%=Conn.Execute("Select Count(ID) From KS_BlogComment Where username='" &KSUser.UserName &"' And readtf=0")(0)%></span>)</a></li>
               <%End If%>
			</ul>
        </div>
		<%
		IF Action="" or action="fw" or action="read" or action="outread" or Action="inbox" or Action="issend" or Action="new" Then
		 %>
		 
		 <table border="0" width="100%" cellpadding="0" cellspacing="0">
		  <tr>
		   <td width="100" style="line-height:30px;border-right:1px solid #ccc" valign="top">
		    <br/>
		    <a href="User_Message.asp?action=new"><img src='images/m_9.png' align="absmiddle"/> 发送消息</a><br/>
		    <a href="User_Message.asp?action=inbox"><img src='images/m_11.png' align="absmiddle"/> 收件箱</a><br/>
		    <a href="User_Message.asp?action=issend"><img src='images/m_10.png' align="absmiddle"/> 已发送</a><br/>
		   </td>
		   <td>
		     <%
			  select case action
			    case "new" sendMessage :Call KSUser.InnerLocation("发送消息")
				case "read","outread" read : Call KSUser.InnerLocation("阅读消息")
				Case "fw" : fw: Call KSUser.InnerLocation("转发消息")
				Case Else 
				%>
				  
				  <table width="98%" border="0" align="center" cellpadding="0" cellspacing="1"  class="border">
		<form action="User_Message.asp" method="post" name="myform">
		 <tr>
		  <%if KS.ChkClng(Max_Num)<>0 then%>
		  <td>
		  <div style="margin:10px;">您的邮箱容量为 <font color=red><%=Max_Num%></font> 条，当前已使用 <font color=blue><%=conn.execute("select count(*) from KS_Message where Incept='"&KSUser.UserName&"' and IsSend=1 and delR=0")(0)%></font> 条</div></td>
		  <%end if%>
		  <td height="40"><strong>搜索:</strong>
		   <select name="action">
		    <option value="inbox"<%if ks.s("action")="inbox" then response.write " selected"%>>收件箱</option>
		    <option value="issend"<%if ks.s("action")="issend" then response.write " selected"%>>已发送</option>
		   </select>
		   <select name="searcharea">
		    <option value="1">短消息主题</option>
			<option value="2">短消息内容</option>
		   </select>
		   <input type="text" class="textbox" name="keyword" value="关键字" onFocus="this.value='';" onBlur="if (this.value=='') this.value='关键字';">
		   <input type="submit" value=" 搜 索 " name="submit1" class="button">
		  </td>		  
		 </tr>
		 </form>
		</table>
			 <%
				 MessageMain
			  end select
			 %>
		   </td>
		  </tr>
		 </table>
		 
		 
		 <%

		Else
		 Response.Write "<br>"
		End IF
		
		Select Case Action
		Case "delet" : delete
		Case "send" : savemsg
		Case "删除收件" : delinbox
		Case "清空收件箱" : AllDelinbox
		Case "删除已发送的消息" : DelIsSend
		Case "清空已发送的消息" : AllDelIsSend
		Case "message" : Message
		Case "replaymessage" : ReplayMessage
		Case "savemessagereplay" :  SaveMessageReplay
        Case "messagedel" : MessageDel
		Case "comment" : Comment
		Case "replaycomment" :ReplayComment
		Case "savecommentreplay" : SaveCommentReplay
		Case "friendrequest" : friendrequest
		Case "accepta" : friendAcceptA
		Case "accept" : friendaccept
		Case "delfriend" : FriendDel
		Case "deletefriend" : FriendDelete
		Case "commentdel" : CommentDel
		End Select

		End Sub
		
		'处理好友请求
		Sub friendrequest()
                Dim Accepted                  
				Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
				Dim Sql:sql = "select * from KS_Friend Where Friend='" &KSUser.UserName & "' and accepted<>1 order by id DESC" 
				  Call KSUser.InnerLocation("好友请求")
		  %>
	      <table width="98%"  border="0" align="center" cellpadding="1" cellspacing="1" class="border">
		  <form name="myform" id="myform" action="User_Message.asp" method="post">
		  <input type="hidden" name="action" id="action" value="accepta">
                             <%
									Set RS=Server.CreateObject("AdodB.Recordset")
									RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' class='splittd' align='center' colspan='6' height='30' valign='top'>还没有用户给您发邀请，要加油哦!</td></tr>"
								 Else
									totalPut = RS.RecordCount
						
								If CurrentPage > 1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
								End If
								Dim XML,Node
								Set XML=KS.ArrayToxml(RS.GetRows(maxperpage),rs,"row","root")
								If IsObject(XML) Then
								  For Each Node In XML.DocumentElement.SelectNodes("row")
								    Accepted=Node.SelectSingleNode("@accepted").text
								    Response.Write "<tr>"
									Response.Write " <td width='45' align='center' class='splittd'><input type='checkbox' name='id' value='" & Node.SelectSingleNode("@id").text & "'></td>"
									Response.Write " <td height='45' class='splittd'><img src='../images/user/log/106.gif'/>朋友：<a href='../space?" & Node.SelectSingleNode("@username").text & "' target='_blank'>" & Node.SelectSingleNode("@username").text & "</a>请求您成为他的好友!"
									if accepted="2" then response.write "<font color=#ff6600>(已拒绝)</font>"
									Response.Write "<br/>附言：" & Node.SelectSingleNode("@message").text & "</td>"
									Response.Write " <td class='splittd' align='center' width='240'>"
									If Accepted="2" Then
									Response.Write "<a href='?action=deletefriend&id=" & Node.SelectSingleNode("@id").text & "' onclick=""return(confirm('此操作不可逆，确定删除该请求吗？'))"" class='box'>删除</a>"
									Else
									Response.Write "<a href='?action=AcceptA&id=" & Node.SelectSingleNode("@id").text & "' class='box'>接受并加为好友</a> <a href='?action=Accept&id=" & Node.SelectSingleNode("@id").text & "' class='box'>接受</a> <a href='?action=delfriend&id=" & Node.SelectSingleNode("@id").text & "' onclick=""return(confirm('此操作不可逆，确定拒绝该请求吗？'))"" class='box'>拒绝</a>"
									Response.Write " <a href='?action=deletefriend&id=" & Node.SelectSingleNode("@id").text & "' onclick=""return(confirm('此操作不可逆，确定删除该请求吗？'))"" class='box'>删除</a>"
									End If
									Response.Write "</td>"
									Response.Write "</tr>"
								  Next
								End If
								XML=Empty
				End If
           %>   
		     <tr>
			   <td colspan='4' height='35' class='splittd'>
			     <table borer='0' width='100%'>
				  <td>
			    &nbsp;&nbsp;<label><input id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中所有</label><input class="button" onClick="$('#action').val('accepta')" type="submit" value="接受并加为好友" name=submit1> <input class="button" onClick="$('#action').val('accept')" type="submit" value=" 接 受 " name=submit1> <input class="button" onClick="$('#action').val('delfriend');return(confirm('此操作不可逆,确定拒绝选中的请求吗？'));" type="submit" value=" 拒 绝 " name=submit1> <input class="button" onClick="$('#action').val('deltefriend');return(confirm('此操作不可逆,确定删除吗?'));" type="submit" value=" 接 受 " name=submit1>
			      </td>

				 </tr>
				</table>
				<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
			  </td>
			 </tr>                  
             </table>
		  <%
		End Sub
		
		'同意加为好友，并加他
		Sub friendAcceptA()
		 Dim ID:ID=KS.S("ID")
		 If ID="" Then Call KS.AlertHistory("对不起，您没有选择!",-1)
		 ID=KS.FilterIDs(ID)
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select UserName,Accepted From KS_Friend Where ID in(" & ID & ")",conn,1,3
		 Do While Not RS.Eof 
		   RS("Accepted")=1
		   RS.Update
		   Conn.Execute("insert into KS_Friend (username,friend,addtime,flag,message,accepted) values ('"&KSUser.UserName&"','"&RS("UserName")&"',"&SqlNowString&",1,'',1)")
		   Call KS.SendInfo(rs("username"),KS.Setting(0),KSUser.UserName & "已通过您的好友请求!","亲爱的" & RS("UserName") & "!<br />&nbsp;&nbsp;&nbsp;&nbsp;恭喜您！<br/><br/>本站会员：<a href=""../space?" & KSUser.UserName & """ target=""_blank"">" & KSUser.UserName & "</a>已接受您的加为好友请求！并将您加为好友了。<br /><br />备注：此信息由系统自动发布，请不要回复！！！")
		  RS.MoveNext
		 Loop
		 RS.Close
		 Set RS=Nothing
		 KS.AlertHintScript("恭喜，操作成功!")
		End Sub
		'同意好邀请
		Sub friendaccept()
         Dim ID:ID=KS.S("ID")
		 If ID="" Then Call KS.AlertHistory("对不起，您没有选择!",-1)
		 ID=KS.FilterIDs(ID)
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select UserName,Accepted From KS_Friend Where ID in(" & ID & ")",conn,1,3
		 Do While Not RS.Eof 
		   RS("Accepted")=1
		   RS.Update
		   Call KS.SendInfo(rs("username"),KS.Setting(0),KSUser.UserName & "已通过您的好友请求!","亲爱的" & RS("UserName") & "!<br />&nbsp;&nbsp;&nbsp;&nbsp;恭喜您！<br/><br/>本站会员：<a href=""../space?" & KSUser.UserName & """ target=""_blank"">" & KSUser.UserName & "</a>已接受您的加为好友请求！<br /><br />备注：此信息由系统自动发布，请不要回复！！！")
		  RS.MoveNext
		 Loop
		 RS.Close
		 Set RS=Nothing
		 KS.AlertHintScript("恭喜，操作成功!")		
		End Sub
		
		'拒绝好友请求
		Sub FriendDel()
         Dim ID:ID=KS.S("ID")
		 If ID="" Then Call KS.AlertHistory("对不起，您没有选择!",-1)
		 ID=KS.FilterIDs(ID)
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select UserName,Accepted From KS_Friend Where Accepted=0 and ID in(" & ID & ")",conn,1,3
		 Do While Not RS.Eof 
		   RS("Accepted")=2
		   RS.Update
		   Call KS.SendInfo(rs("username"),KS.Setting(0),KSUser.UserName & "拒绝您的好友请求!","亲爱的" & RS("UserName") & "!<br /><br/>本站会员：<a href=""../space?" & KSUser.UserName & """ target=""_blank"">" & KSUser.UserName & "</a>已拒绝了您的加为好友请求！<br /><br />备注：此信息由系统自动发布，请不要回复！！！")
		  RS.MoveNext
		 Loop
		 RS.Close
		 Set RS=Nothing
		 KS.AlertHintScript("恭喜，操作成功!")		
		End Sub
		
		'删除好友请求
		Sub FriendDelete()
         Dim ID:ID=KS.S("ID")
		 If ID="" Then Call KS.AlertHistory("对不起，您没有选择!",-1)
		 ID=KS.FilterIDs(ID)
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select UserName,Accepted From KS_Friend Where  ID in(" & ID & ")",conn,1,3
		 Do While Not RS.Eof 
		   RS.Delete
		  RS.MoveNext
		 Loop
		 RS.Close
		 Set RS=Nothing
		 KS.AlertHintScript("恭喜，操作成功!")		
		End Sub
		
		
		 '评论管理
	   Sub Comment()
							Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
							Dim Sql:sql = "select * from KS_BlogComment "& Param &" order by AddDate DESC" 
							Call KSUser.InnerLocation("空间博文评论")
				  %>
				   <table width="98%"  border="0" align="center" cellpadding="1" cellspacing="1" class="border">
                                      <tr class="title">
                                                  <td width="6%" height="30" align="center">选中</td>
												  <td width="12%" align="center">发表人</td>
                                                  <td width="33%" align="center">评论内容</td>
                                                  <td width="12%" align="center">发表时间</td>
                                                  <td width="8%" align="center">主页</td>
                                                  <td align="center">标志</td>
                                                  <td align="center" nowrap>管理操作</td>
                                     </tr>
                                           
                                  <%
									Set RS=Server.CreateObject("AdodB.Recordset")
									RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>没有用户给你评论!</td></tr>"
								 Else
									totalPut = RS.RecordCount
								    If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
								    End If
									Call ShowComment

				End If
     %>                     
                        </table>
		  <%
	   End Sub
	   
	   Sub ShowComment()
	     Dim I
    Response.Write "<FORM Action=""?Action=CommentDel"" name=""myform"" method=""post"">"
   Do While Not RS.Eof
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
             <td class="splittd" height="25" align="center"><INPUT id="ID" type="checkbox" value="<%=RS("ID")%>"  name="ID"></td>
				<td class="splittd" align="center"><%=RS("AnounName")%></td>
                <td class="splittd" align="left"><a href="<%=KS.Setting(3)%>space/?<%=KSUser.GetUserInfo("userId")%>/log/<%=rs("logid")%>" target="_blank" class="link3"><%=KS.GotTopic(trim(RS("Content")),35)%></a>
											
				</td>
                <td class="splittd" align="center"><%=KS.GetTimeFormat(rs("adddate"))%></td>
                <td class="splittd" align="center">
				  <%if rs("homepage")="" or lcase(rs("homepage"))="http://" then%>
				     ---
				  <%else%>
					 <a href="<%=rs("homepage")%>" target="_blank">访问</a>
				  <%end if%>
				  </td>
				  <td class="splittd" align="center">
				  <%
				   if rs("readtf")="1" then
				     response.write "<span style='color:#999999'>已读</font>"
				   else
				     response.write "<span style='color:red'>未读</font>"
				   end if
				   if KS.IsNul(rs("replay")) Then
				     response.write " <span style='color:red'>未回复</font>"
					else
					 response.write " <span style='color:#999999'>已回复</font>"
					end if
				  %>
				  </td>
                <td class="splittd" height="22" align="center">
					<a href="?id=<%=rs("id")%>&Action=ReplayComment&page=<%=CurrentPage%>" class="box">查看/回复</a> <a href="?action=CommentDel&ID=<%=rs("id")%>" onclick = "return (confirm('确定删除评论吗?'))" class="box">删除</a>
				</td>
            </tr>
                  
                                      <%
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
								<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
								  <td colspan=6 valign=top>
								&nbsp; <INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中本页显示的所有评论<INPUT class='button' onClick="return(confirm('确定删除选中的评论吗?'));" type=submit value=删除选定的评论 name=submit1>  
								  </td>
								  </FORM>
								</tr>
								<tr><td colspan="6">
								<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
								</td>
								</tr>
								<% 

	   End Sub
	   '回复评论
	   Sub ReplayComment()
	     Call KSUser.InnerLocation("回复评论")
		  Dim KS_A_RS_Obj:Set KS_A_RS_Obj=Server.CreateObject("ADODB.RECORDSET")
		   KS_A_RS_Obj.Open "Select top 1 * From KS_BlogComment Where ID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If KS_A_RS_Obj.Eof And KS_A_RS_Obj.Bof Then
		    Response.Write "<script>alert('参数出错!');history.back();</script>"
			Response.end
		   End If
		   Dim LogID:LogID=KS_A_RS_Obj("logid")
		   If Conn.Execute("Select top 1 * From KS_BlogInfo Where ID=" & LogID & " and username='" &KSUser.UserName & "'").eof Then
		    KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		    Response.Write "<script>alert('对不起，没有权限操作，请确认该文章是否属于您!');history.back();</script>"
			Response.end
		   End If
		   Dim Title:Title=KS_A_RS_Obj("Title")
		   Dim Content:Content=KS_A_RS_Obj("Content")
		   Dim Replay:Replay=KS_A_RS_Obj("Replay"):If IsNull(Replay) Then Replay=""
		   KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		   Conn.Execute("Update KS_BlogComment Set ReadTF=1 Where ID=" & KS.ChkClng(KS.S("ID")))
		%>
			<script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
		<script language = "JavaScript">
				function CheckForm()
				{
				  if (CKEDITOR.instances.Replay.getData()=="")
					{
					  alert("请输入回复内容！");
					  CKEDITOR.instances.Replay.focus();
					  return false;
					}
				
				 return true;  
				}
				</script>
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="?Action=SaveCommentReplay&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr class="title">
					  <td colspan=2 align=center>回 复 评 论</td>
					</tr>

                      <tr class="tdbg">
                           <td  height="25" align="center"><span>评论标题：</span></td>
                              <td style="word-break:break-all;">  <%=KS.CheckXSS(Title)%><input class="textbox" name="Title" type="hidden" id="Title" style=" color:#999;border:1px solid #ccc;background:#FBFBFB;width:250px; " value="<%=Title%>" maxlength="100" /></td>
                    </tr>
							 
                              <tr class="tdbg">
                                  <td  height="25" align="center"><span>评论内容：</span></td>
                                  <td style="word-break:break-all;"><%=KS.CheckXSS(Content)%>
								  <textarea name="Content" style="display:none;color:#999;border:1px solid #ccc;background:#FBFBFB;overflow:auto;width:500px;height:70px"><%=Server.HtmlEncode(Content)%></textarea>
					<!--<script type="text/javascript">
                CKEDITOR.replace('Content', {width:"98%",height:"150px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
			    </script> -->
								  </td>
                            </tr>
                              <tr class="tdbg">
                                  <td  height="25" align="center"><span>回复内容：</span></td>
                                  <td>
								  <textarea name="Replay" style="color:#999;border:1px solid #ccc;background:#FBFBFB;overflow:auto;width:500px;height:70px"><%=Server.HtmlEncode(Replay)%></textarea>
					<!--<script type="text/javascript">
                CKEDITOR.replace('Replay', {width:"98%",height:"150px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
			    </script> -->
								
								  </td>
                            </tr>
								
                    <tr class="tdbg">
					  <td></td>
                      <td height="30">
					   <button class="pn" type="submit"><strong>OK,立即回复</strong></button>
                      </td>
                    </tr>
                  </form>
			    </table>
		  <%
	   End Sub
	   
	   '保存评论回复
	   Sub SaveCommentReplay()
	    Dim ID:ID=KS.ChkClng(KS.S("ID"))
		Dim Title:Title=KS.S("Title")
		Dim Content:Content=Request.Form("Content")
		Dim Replay:Replay=Request.Form("Replay")
		Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select top 1 * From KS_BlogComment Where ID=" & ID,conn,1,3
		If Not RS.Eof Then
		  RS("Title")=Title
		  RS("Content")=Content
		  RS("Replay")=Replay
		  RS("ReplayDate")=Now
		 RS.Update
		End If
		RS.Close:Set RS=Nothing
		Response.Write "<script>alert('恭喜,您已成功回复！');location.href='?Action=Comment';</script>"
	   End Sub 
	     '删除评论
	  Sub CommentDel()
		Dim ID:ID=KS.S("ID")
		ID=KS.FilterIDs(ID)
		If ID="" Then Call KS.Alert("你没有选中要删除的博文评论!",ComeUrl):Response.End
		Dim RS:Set RS=Conn.Execute("Select * From KS_BlogComment Where UserName='" & KSUser.UserName & "' and ID In(" & ID & ")")
		Do While Not RS.EOF 
		  Conn.Execute("Update KS_BlogInfo Set TotalPut=TotalPut-1 Where TotalPut>0 And ID=" & RS("LogID"))
		RS.MoveNext
		Loop
		RS.Close :Set RS=Nothing
		Conn.Execute("Delete From KS_BlogComment Where UserName='" & KSUser.UserName & "' and ID In(" & ID & ")")
		Response.Redirect ComeUrl
	  End Sub
	  
		
		
		 '留言管理
	   Sub Message()

                Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
				Dim Sql:sql = "select * from KS_BlogMessage "& Param &" order by AddDate DESC" 
				  Call KSUser.InnerLocation("空间留言管理")
					  %>
				         <table width="98%"  border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                               <tr class="title">
                                   <td width="6%" height="22" align="center">选中</td>
								   <td width="12%" align="center">发表人</td>
                                   <td width="41%" align="center">留言内容</td>
                                   <td width="12%" align="center">发表时间</td>
                                   <td align="center">标志</td>
                                   <td align="center" nowrap>管理操作</td>
                              </tr>
                                           
                                      <%
									Set RS=Server.CreateObject("AdodB.Recordset")
									RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>没有用户给你留言!</td></tr>"
								 Else
									totalPut = RS.RecordCount
								    If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
									End If
									Call ShowMessage

				End If
     %>                     
                        </table>
		  <%
	   End Sub
	   
	   Sub ShowMessage()
	        Dim I:I=0
    Response.Write "<FORM Action=""?Action=MessageDel"" name=""myform"" method=""post"">"
   Do While Not RS.Eof
        if i mod 2=0 then
		%>
		<tr class='tdbg'  onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
		<%
		else
		%>
		<tr class='tdbg trbg'>
		<%
		end if
  %>       <td width="5%" height="25" class="splittd" align="center">
				<INPUT id="ID" type="checkbox" value="<%=RS("ID")%>"  name="ID">
		  </td>
		  <td width="10%" class="splittd" align="center"><%=RS("AnounName")%></td>
          <td width="35%" class="splittd" align="left"><a href="<%=KS.Setting(3)%>space/?<%=KS.C("UserID")%>/message#<%=rs("id")%>" target="_blank" class="link3"><%=KS.GotTopic(trim(KS.LoseHtml(RS("Content"))),35)%>...</a>
				
		</td>
        <td width="18%" class="splittd" align="center"><%=KS.GetTimeFormat(rs("adddate"))%></td>
        <td class="splittd" align="center"><%
		if rs("readtf")="1" then
		 response.write "<span style='color:#999999'>已读</span>"
		else
		 response.write "<span style='color:red'>未读</span>"
		end if%>
		<%if Not KS.IsNul(rs("replay")) Then
			response.write " <span style='color:#999999'>已回复</span>"
		  else
			response.write " <span style='color:red'>未回复</span>"
		  end if
		%>
		</td>
        <td class="splittd" align="center">
			<a href="?id=<%=rs("id")%>&Action=ReplayMessage&page=<%=CurrentPage%>" class="box">查看/回复</a> <a href="?action=MessageDel&ID=<%=rs("id")%>" onclick = "return (confirm('确定删除留言吗?'))" class="box">删除</a>
		</td>
     </tr>
                                      <%
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
								<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
								  <td colspan=2 valign=top><label><INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">选中</label><INPUT class='button' onClick="return(confirm('确定删除选中的留言吗?'));" type=submit value=删除留言 name=submit1> 
								   </td>
								   <td colspan='10' align='right'>    
				<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
								  </td>
								  </FORM>
								</tr>
								<% 

	   End Sub
		

	   '回复留言
	   Sub ReplayMessage()
	     Call KSUser.InnerLocation("回复留言")
		  Dim KS_A_RS_Obj:Set KS_A_RS_Obj=Server.CreateObject("ADODB.RECORDSET")
		   KS_A_RS_Obj.Open "Select top 1 * From KS_BlogMessage Where ID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If KS_A_RS_Obj.Eof And KS_A_RS_Obj.Bof Then
			KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		    Response.Write "<script>alert('参数出错!');history.back();</script>"
			Response.end
		   End If
		   Conn.Execute("update KS_BlogMessage set readtf=1 Where ID=" & KS.ChkClng(KS.S("ID")))
		   Dim Title:Title=KS_A_RS_Obj("Title")
		   Dim Content:Content=KS_A_RS_Obj("Content")
		   Dim Replay:Replay=KS_A_RS_Obj("Replay"):If IsNull(Replay) Then Replay=""
		   KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		%>
		<script language = "JavaScript">
			function CheckForm()
			{
				if ($("#Replay").val()=="")
					{
					  alert("请输入回复内容！");
					  $("#Replay").focus();
					  return false;
					}
				
				 return true;  
			}
		</script>
				
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form action="?Action=SaveMessageReplay&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr class="title">
					  <td colspan=2 align=center>回 复 留 言</td>
					</tr>

                      <tr class="tdbg" style="display:none">
                           <td  height="25" align="center"><span>留言标题：</span></td>
                              <td>  <input class="textbox" name="Title" type="text" id="Title" style="width:250px; " value="<%=Title%>" maxlength="100" /></td>
                    </tr>
                              <tr class="tdbg">
                                  <td width="80" height="25" align="center"><span>留言内容：</span></td>
                                  <td style="word-break:break-all;"><%=KS.CheckXSS(Content)%><textarea  name="Content" style="display:none;color:#999;border:1px solid #ccc;background:#FBFBFB;overflow:auto;width:500px;height:70px" id="Content"><%=Server.HtmlEncode(Content)%></textarea>
				   </td>
                            </tr>
                              <tr class="tdbg">
                                  <td  height="25" align="center"><span>回复内容：</span></td>
                                  <td><textarea name="Replay" style="color:#999;border:1px solid #ccc;background:#FBFBFB;overflow:auto;width:500px;height:70px" id="Replay"><%=Server.HtmlEncode(Replay)%></textarea>
                            </td>
                            </tr>
								
                    <tr class="tdbg">
					  <td></td>
                      <td height="30">
					 <button class="pn" type="submit"><strong>OK,立即回复</strong></button>
                     </td>
                    </tr>
                  </form>
			    </table>
		  <%
	   End Sub		
		
		
	   
	   '保存留言回复
	   Sub SaveMessageReplay()
	    Dim ID:ID=KS.ChkClng(KS.S("ID"))
		Dim Title:Title=KS.S("Title")
		Dim Content:Content=Request.Form("Content")
		Dim Replay:Replay=Request.Form("Replay")
		Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select top 1 * From KS_BlogMessage Where ID=" & ID,conn,1,3
		If Not RS.Eof Then
		  RS("Title")=Title
		  RS("Content")=Content
		  RS("Replay")=Replay
		  RS("ReplayDate")=Now
		 RS.Update
		End If
		RS.Close:Set RS=Nothing
		Response.Write "<script>alert('恭喜,您已成功回复！');location.href='?Action=Message';</script>"
	   End Sub
	   '删除留言
	  Sub MessageDel()
		Dim ID:ID=KS.S("ID")
		ID=KS.FilterIDs(ID)
		If ID="" Then Call KS.Alert("你没有选中要删除的留言!",ComeUrl):Response.End
		Conn.Execute("Delete From KS_BlogMessage Where UserName='" & KSUser.UserName & "' and ID In(" & ID & ")")
		Response.Redirect ComeUrl
	  End Sub
	  
		
		
		'发送信息
		Sub sendMessage()
			dim SendTime,title,content
			If KS.S("ID")<>"" and isNumeric(KS.S("ID")) Then
				Set rs=server.createobject("adodb.recordSet")
				SqlStr="Select top 1 SendTime,title,content from KS_Message where Incept='"&KSUser.UserName&"' and id="&Clng(KS.S("ID"))
				RS.open SqlStr,Conn,1,1
				If not(RS.eof and RS.bof) Then
					SendTime=rs("SendTime")
					Title="RE " & rs("title")
					Content=rs("content")
				End If
				RS.close
				Set rs=Nothing
			End If
		%>
		<table width="98%" align="center" cellpadding="3" cellspacing="1" class="border">
				<form action="User_Message.asp"  name="myform" method="post" id="myform" onSubmit="return CheckForm();">
				  <tr> 
					<td colspan=2 align=center class="title">发送短消息</td>
				  </tr>
				  <tr class='tdbg'> 
					<td width="100" align="right" valign=middle><b>收件人：</b></td>
					<td valign=middle>
					  <input type=hidden name="action" value="sEnd">
					  <input class="textbox" type=text name="Touser" value="<%=KS.S("Touser")%>" size=60>
					  <Select class="textbox" name=font onchange=DoTitle(this.options[this.selectedIndex].value)>
					  <OPTION selected value="">选择</OPTION>
						<%
						Set rs=server.createobject("adodb.recordSet")
						SqlStr="Select friend from KS_Friend where Username='"&KSUser.UserName&"' order by Addtime desc"
						RS.open SqlStr,Conn,1,1
						Do While not RS.eof
						%>
						<OPTION value="<%=rs(0)%>"><%=rs(0)%></OPTION>
						<%
						RS.movenext
						loop
						RS.close:Set rs=Nothing
						%>
					  </Select>
					  <a href="User_Friend.asp?action=addF">添加好友</a>
					</td>
				  </tr>
				  <tr class='tdbg'> 
					<td width="100" align="right" valign=top><b>标　题：</b></td>
					<td valign=middle>
					  <input class="textbox" type=text name="title" size=70 maxlength=90 value="<%=title%>">
					</td>
				  </tr>
				  <tr class='tdbg'> 
					<td width="100" align="right" valign=top><b>内　容：</b></td>
					<td valign=middle>
					  <textarea cols=50 rows=16 name="message" id="message" style="display:none" title="Ctrl+Enter发送">
					  <%If KS.S("ID")<>"" Then%>
						============= 在 <%=SendTime%> 您来信中写道： ==============<br>
						<%=server.htmlencode(content)%>
						<br>=======================================================
					<%End If%>
		             </textarea>
					 <script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
					 <script type="text/javascript">
						CKEDITOR.replace('message', {width:"98%",height:"200px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
					 </script>
					 
					
					</td>
				  </tr>
				  <tr class='tdbg'> 
				    <td align="right"><b>说明</b>：</td>
					<td colspan=2>
		① 可以用英文状态下的逗号将用户名隔开实现群发<%if Max_sEnd<>0 then%>，最多<b><%=max_sEnd%></b>个用户<%end if%><br>
		② 标题最多<b>200</b>个字符<%if Max_sms<>0 then%>，内容最多<b><%=max_sms%></b>个字符<%end if%><br>
					</td>
				  </tr>
				  <tr class='tdbg'>
				    <td></td> 
					<td>
					  <button id="button" type="submit" class="pn"><strong>OK,发 送</strong></button>
					</td>
				  </tr>
		
				</form>
</table>
		<%
			DoTitleJs
		End Sub
		'读取信息
		Sub read()
			If KS.S("id")=0 Then
				Response.Write "<script>alert('请指定正确的参数。');history.back();</script>"
			End If
			Set rs=server.createobject("adodb.recordSet")
			If request("action")="read" Then
				Conn.Execute("Update KS_Message Set flag=1 where ID="&Clng(KS.S("id")))
			End If
			SqlStr="Select * from KS_Message where (Incept='"&KSUser.UserName&"' or sEnder='"&KSUser.UserName&"') and id="&Clng(KS.S("ID"))
			RS.open SqlStr,Conn,1,1
			If RS.eof and RS.bof Then
				RS.close:Set rs=Nothing
				Response.Write "<script>alert('你是不是跑到别人的信箱啦、或者该信息已经被收件人删除。');history.back();</script>"
			Else
		%>
		<table width="98%" align=center cellpadding=3 cellspacing=1>
					<tr>
						<th class="title" style="text-align:left" colspan=3>欢迎使用短消息接收，<%=KSUser.UserName%>
						&nbsp;&nbsp;<a href="User_Message.asp?action=delet&id=<%=rs("id")%>&ComeUrl=<%=ComeUrl%>">[删除]</a> <a href="User_Message.asp?action=new">[发送]</a> <a href="User_Message.asp?action=new&Touser=<%=KS.HTMLEncode(rs("sEnder"))%>&id=<%=KS.S("ID")%>">[回复]</a> <a href="User_Message.asp?action=fw&id=<%=KS.S("ID")%>">[转发]</a>
						</th>
					</tr>

						<tr>
							<td height=25>
		<%If request("action")="outread" Then%>
							在<b><%=rs("SendTime")%></b>，您发送此消息给<b><%=KS.HTMLEncode(rs("Incept"))%></b>！
		<%Else%>
					在<b><%=rs("SendTime")%></b>，<b><%=KS.HTMLEncode(rs("sEnder"))%></b>给您发送的消息！
		<%End If%></td>
						</tr>
						<tr>
							<td valign=top align=left>
							<b>消息标题：<%=KS.CheckXSS(rs("title"))%></b><hr size=1>
							<%=KS.HtmlCode(rs("content"))%>
					</td>
						</tr>
		<%
			RS.close:Set rs=Nothing
			SqlStr="Select id,sEnder from KS_Message where Incept='"&KSUser.UserName&"' and flag=0 and IsSend=1 and id>"&KS.ChkClng(KS.S("ID")&" order by SendTime")
			Set rs=Conn.Execute(SqlStr)
			If not (RS.eof and RS.bof) Then
		%>
						<tr>
							<td valign=top align=right><a href=User_Message.asp?action=read&id=<%=rs(0)%>&sEnder=<%=rs(1)%>>[读取下一条信息]</a>
					</td>
						</tr>
		<%
		End If
		RS.close:Set rs=Nothing
		%>
</table>
		<%
			End If
		End Sub
		'转发信息
		Sub fw()
			dim title,content,sEnder
			If KS.S("ID")<>"" and isNumeric(KS.S("ID")) Then
				Set rs=server.createobject("adodb.recordSet")
				SqlStr="Select top 1 title,content,sEnder from KS_Message where (Incept='"&KSUser.UserName&"' or sEnder='"&KSUser.UserName&"') and id="&Clng(KS.S("ID"))
				RS.open SqlStr,Conn,1,1
				If RS.eof and RS.bof Then
					RS.close:Set rs=Nothing
					Response.Write "<script>alert('请指定正确的参数。');history.back();</script>"
				Else
				title=rs("title"):content=rs("content"):sEnder=rs("sEnder")
				End If
				RS.close:Set rs=Nothing
			End If
		%>
		<table width="100%" align=center cellpadding=3 cellspacing=1 class=border>
				<form action="User_Message.asp"  name="myform" method="post" id="myform" onSubmit="return CheckForm();">
				  <tr class="title"> 
					<td colspan=2 align=center height=25>转发短消息</td>
				  </tr>
				  <tr class='tdbg'> 
					<td width=100 align="right"><b>收件人：</b></td>
					<td valign=middle>
					  <input type="hidden" name="action" value="sEnd">
					  <input class='textbox' type=text name="Touser" value="<%=KS.S("Touser")%>" size=70>
					  <Select name="font" onChange="DoTitle(this.options[this.selectedIndex].value)">
					  <OPTION selected value="">选择</OPTION>
						<%
						Set rs=server.createobject("adodb.recordSet")
						SqlStr="Select friend from KS_Friend where Username='"&KSUser.UserName&"' order by Addtime desc"
						RS.open SqlStr,Conn,1,1
						Do While not RS.eof
						%>
						<OPTION value="<%=rs(0)%>"><%=rs(0)%></OPTION>			
						<%
						RS.movenext
						loop
						RS.close:Set rs=Nothing
						%>
					  </Select>
					</td>
				  </tr>
				  <tr class='tdbg'> 
					<td valign=top align="right"><b>标　题：</b></td>
					<td valign=middle>
					  <input class='textbox' type=text name="title" size=80 maxlength=90 value="Fw：<%=title%>">&nbsp;
					</td>
				  </tr>
				  <tr class='tdbg'> 
					<td valign=top align="right"><b>内　容：</b></td>
					<td valign=middle>
					  <textarea cols=76 rows=16 name="message" id="message" title="Ctrl+Enter发送" style="display:none">
		
		
		======================== 下面是转发信息 =====================<br>
		原发件人：<%=sEnder%><br>
		<%=server.htmlencode(content)%>
		=======================================================</textarea>
					 <script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
					 <script type="text/javascript">
						CKEDITOR.replace('message', {width:"98%",height:"200px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
					 </script>
	
					</td>
				  </tr>
				  <tr class='tdbg'> 
				   <td align="right"><b>说明</b></td>
					<td>
		① 可以用英文状态下的逗号将用户名隔开实现群发<%if Max_sEnd<>0 then%>，最多<b><%=max_sEnd%></b>个用户<%end if%><br>
		② 标题最多<b>200</b>个字符<%if Max_sms<>0 then%>，内容最多<b><%=max_sms%></b>个字符<%end if%><br>
					</td>
				  </tr>
				  <tr class='tdbg'> 
				    <td></td>
					<td> 
					 <button id="button" type="submit" class="pn"><strong>OK,发 送</strong></button>
					</td>
				  </tr>
			　</form>
		</table>
		<%
			DoTitleJs
		End Sub
		
		Sub savemsg()
			dim Incept,title,message,Subtype,i,sUname
			If KS.S("Touser")="" Then
				Response.Write("<script>alert('您忘记填写发送对象了吧。');history.back();</script>")
			Else
				Incept=KS.S("Touser")
				Incept=split(Incept,",")
			End If
			If KS.S("Title")="" Then
				Response.Write("<script>alert('您还没有填写标题呀。');history.back();</script>")
			ElseIf KS.strLength(KS.S("title"))>200 Then
				Response.Write("<script>alert('标题限定最多200个字符。');history.back();</script>")
			Else
				title=KS.S("title")
			End If
			If KS.S("Message")="" Then
				Response.Write("<script>alert('内容是必须要填写的噢。');history.back();</script>")
			ElseIf KS.strLength(KS.S("Message"))>Cint(max_sms) and max_sms<>0 Then
				Response.Write("<script>alert('内容限定最多"&max_sms&"个字符。');history.back();</script>")
			Else
				message=Replace(Request.Form("message"),"'","''")
			End If
		
			for i=0 to ubound(Incept)
				sUname=replace(Incept(i),"'","")
				if lcase(sUname)=lcase(KSUser.UserName) then
					call KS.AlertHistory("不能给自己发消息！",-1)
					response.end
				end if
				SqlStr="Select top 1 UserName from KS_User where UserName='"&sUname&"'"
				Set rs=Conn.Execute(SqlStr)
				If RS.eof and RS.bof Then
					RS.close:Set rs=Nothing
					call KS.AlertHistory("系统没有这个用户，看看你的发送对象写对了嘛？",-1)
					response.end
				End If
				RS.Close
				rs.open "select username from ks_friend where username='" & sUname & "' and friend='" & ksuser.username & "' and flag=3",conn,1,1
				if not rs.eof then
					RS.close:Set rs=Nothing
					call KS.AlertHistory("对不起，你被" & sUname & "列为黑名单,不能发送短信给他！",-1)
					response.end
				end if
				RS.close:Set rs=Nothing
			  
				If cbool(KS.SendInfo(sUname,KSUser.UserName,title,message))=false then
				 KS.Die "<script>alert('用户" & sUname & "不存在或是该用户邮箱已满，信件发送失败！');history.back();</script>"
				end if
						
				
				If i>Cint(max_sEnd)-1 and max_sEnd<>0 Then
					Response.Write("<script>alert('最多只能发送给"&max_sEnd&"个用户，您的名单"&max_sEnd&"位以后的请重新发送');history.back();</script>")
					exit for
				End If
			next
		Response.Write("<script>alert('恭喜您，发送短信息成功。发送的消息同时保存在您的"&Subtype&"中。');location.href='User_Message.asp';</script>")
		
		End Sub
		
		
		'收件置于回收站，参数字段delR，可用于批量及单个删除
		Sub delinbox()
			dim DelID
			DelID=KS.S("ID")
			DelID=KS.FilterIDs(DelID)
			If DelID="" or isnull(DelID) or Not IsNumeric(Replace(Replace(DelID,",","")," ","")) Then
				Response.Write "<script>alert('请选择相关参数!');history.go(-1);</script>"
				Exit Sub
			Else
				Conn.Execute("Delete From KS_Message where Incept='"&KSUser.UserName&"' and id in ("&DelID&")")
				Response.Write "<script>alert('恭喜，删除短信息成功!');location.href='" & ComeUrl & "';</script>"
			
			End If
		End Sub
		
		Sub AllDelinbox()
			Conn.Execute("Delete From KS_Message where Incept='"&KSUser.UserName&"' and delR=0")
			Response.Write "<script>alert('恭喜，删除短信息成功!');location.href='" & ComeUrl & "';</script>"
			Response.End
		End Sub
		

		'已发送置于回收站，入口字段delS，可用于批量及单个删除
		'delS：0未操作，1发送者删除，2发送者从回收站删除
		Sub DelIsSend()
			dim DelID
			DelID=KS.S("ID")
			'Response.Write delid
			'Response.End()
			DelID=KS.FilterIDs(DelID)
			If DelID="" or isnull(DelID) or Not IsNumeric(replace(Replace(DelID,",","")," ","")) Then
				Response.Write "<script>alert('请选择相关参数!');history.go(-1);</script>"
			Else
				Conn.Execute("Update KS_Message Set delS=1 where Sender='"&KSUser.UserName&"' and IsSend=1 and id in ("&DelID&")")
				Response.Write "<script>alert('删除短信息成功。删除的消息将转移到您的回收站!');location.href='" & ComeUrl & "';</script>"
				Response.End
			End If
		End Sub
		
		Sub AllDelIsSend()
			Conn.Execute("Update KS_Message Set delS=1 where Sender='"&KSUser.UserName&"' and delS=0 and IsSend=1")
			Response.Write "<script>alert('删除短信息成功。删除的消息将转移到您的回收站!');location.href='" & ComeUrl & "';</script>"
			Response.End
		End Sub
		
		
		Sub delete()
			dim DelID
			DelID=KS.S("id")
			ComeUrl=Request("ComeUrl")
			'Response.End()
			If ComeUrl="" Then ComeUrl="User_Message.asp"
			If not isNumeric(DelID) or DelID="" or isnull(DelID) Then
				Response.Write "<script>alert('请选择相关参数!');history.go(-1);</script>"
			Else
				Conn.Execute("Delete From  KS_Message where Incept='"&KSUser.UserName&"' and id="&Clng(DelID))
				Conn.Execute("Delete From KS_Message where sEnder='"&KSUser.UserName&"' and id="&Clng(DelID))
				Response.Write "<script language=""javascript"">alert('恭喜，删除短信息成功!');location.href='"&ComeUrl&"';</script>"
				Response.End
			End If
		End Sub
		
		Sub MessageMain()
			dim SqlStr,boxName,smstype,readaction,turl
			dim keyword,param
			keyword=KS.S("KeyWord")
			if keyword<>"" then
			  if ks.s("searcharea")=1 then
			   param=" and title like '%" & keyword & "%'"
			  else
			   param=" and content like '%" & keyword & "%'"
			  end if
			end if
			Select Case Action
			Case "inbox"
				boxName="收件箱":smstype="inbox":readaction="read":turl="readsms"
				SqlStr="select * from KS_Message where Incept='"&KSUser.UserName&"'" & param & " and IsSend=1 and delR=0 order by flag,SendTime desc"
			Case "issend"
				boxName="已发送的消息":smstype="issend":readaction="outread":turl="readsms"
				SqlStr="select * from KS_Message where Sender='"&KSUser.UserName&"'" & param & " and IsSend=1 and delS=0 order by SendTime desc"
			Case Else
				boxName="收件箱":smstype="inbox":readaction="read":turl="readsms"
				SqlStr="select * from KS_Message where Incept='"&KSUser.UserName&"'" & param & " and IsSend=1 and delR=0 order by flag,SendTime desc"
			End Select
		Call KSUser.InnerLocation("我的" & boxname)
		%>
		<table width="98%" border="0" align="center" cellpadding="0" cellspacing="1"  class="border">
		<form action="User_Message.asp" method="post" name="inbox">
		<tr height='23' class="title">
		<td align="center">已读</td>
		<td align="center">主题</td>
		<td  height="26" align="center">
		<%if smstype="inbox" then Response.Write "发件人" else Response.Write "收件人"%></td>
		<td align="center">日期</td>
		<td align="center">大小</td>
		<td align="center">操作</td>
		</tr>
		<%
			Dim RS:Set RS=server.createobject("adodb.recordset")
			OpenConn
			RS.open SqlStr,Conn,1,1
			if RS.eof and RS.bof then
		%>
		<tr>
		<td colspan=6 align=center valign=middle class='tdbg'>您的<%=boxname%>中没有任何内容。</td>
		</tr>
		<%else
		
		         totalPut = RS.RecordCount
					If CurrentPage > 1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
						RS.Move (CurrentPage - 1) * MaxPerPage
					End If
		 dim i:i=0
		Do While not RS.eof
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
		<td height="32" align=center valign=middle>
		<%
			if rs("flag")=0 then
				Response.Write "<img src=""images/news.gif""  title=""未读"">"
			else
				Response.Write "<img src=""images/olds.gif"" title=""已读"">"
			end if
		%>
		</td>
		<td align=left><a href="User_Message.asp?action=<%=readaction%>&id=<%=rs("id")%>&sender=<%=rs("sender")%>"><%=KS.CheckXSS(rs("title"))%></a>	</td>
		<td height="25" align=center valign=middle>
		<%if smstype="inbox" then%>
		<%=KS.HTMLEncode(rs("sender"))%>
		<%else%>
		<%=KS.HTMLEncode(rs("Incept"))%>
		<%end if%>
		</td>
		<td><%=formatdatetime(rs("SendTime"),2)%></td>
		<td><%=len(rs("content"))%>Byte</td>
		<td width=30align=center valign=middle><input type=checkbox name=id value=<%=rs("id")%>></td>
		</tr>
		<%
		  i=I+1
		 if i>maxperpage or rs.eof then exit do
			RS.movenext
			loop
			end if
			RS.close:set rs=Nothing
		%>
		<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'"> 
		<td height="26" colspan=6 align=right valign=middle>节省每一分空间，请及时删除无用信息&nbsp;
		  <input type=checkbox name=chkall value=on onClick="CheckAll(this.form)">选中所有显示记录&nbsp;<input class="button" type=submit name=action onClick="{if(confirm('确定删除选定的纪录吗?')){this.document.inbox.submit();return true;}return false;}" value="删除<%=replace(boxname,"箱","")%>">&nbsp;
		  <input type=submit class="button" name=action onClick="{if(confirm('确定清除<%=boxname%>所有的纪录吗?')){this.document.inbox.submit();return true;}return false;}" value="清空<%=boxname%>"></td>
		</tr>
		</form>
		<tr>
		<td colspan=6>
		 <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>

		</td>
		</tr>
</table>
		<br>
		
		<script language=javascript>
		function CheckAll(form)
		{
		for (var i=0;i<form.elements.length;i++)    {
		var e = form.elements[i];
		if (e.name != 'chkall')       e.checked = form.chkall.checked; 
		}
		}
		</script>
		<%
		end sub
		
		Sub DoTitleJs()
		%>
		<script language="javascript"> 
		function DoTitle(addTitle) {  
		 var revisedTitle;  
		 var currenttitle = document.myform.Touser.value; 
		
		 if(currenttitle=="") revisedTitle = addTitle; 
		 else { 
		  var arr = currenttitle.split(","); 
		  for (var i=0; i < arr.length; i++) { 
		   if( addTitle.indexOf(arr[i]) >=0 && arr[i].length==addTitle.length ) return; 
		  } 
		  revisedTitle = currenttitle+","+addTitle; 
		 } 
		
		 document.myform.Touser.value=revisedTitle;  
		 document.myform.Touser.focus(); 
		 return; 
		} 
		function document.onkeydown()
		{
			if(event.ctrlKey && window.event.keyCode==13)
			{
				CheckForm();
			}
			
		}
		</script>
		<%
		End Sub


End Class
%> 
