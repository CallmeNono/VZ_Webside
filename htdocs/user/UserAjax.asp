<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.EscapeCls.asp"-->
<!--#include file="../api/cls_api.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
response.cachecontrol="no-cache"
response.addHeader "pragma","no-cache"
response.expires=-1
response.expiresAbsolute=now-1
Response.CharSet="utf-8"
Dim KSCls
Set KSCls = New UserAjax
KSCls.Kesion()
Set KSCls = Nothing

Class UserAjax
        Private KS,KSUser
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/UbbFunction.asp"-->
		<%
		Public Sub Kesion()
		  Select Case KS.S("Action")
		   Case "CheckToken" Call CheckToken()
		   Case "GetNewMessage" Call GetNewMessage()
		   Case "GetAdminMessage" Call GetAdminMessage()
		   Case "TalkSave" Call TalkSave()
		   Case "TalkTrans" Call TalkTrans()
		   Case "DelTalk" Call DelTalk()
		   Case "ShowTalkCmt" Call ShowTalkCmt()
		   Case "TalkCmtSave" Call TalkCmtSave()
		   Case "addAttention" Call addAttention()
		   Case "cancelAttention" Call cancelAttention()
		   Case "SpaceTemplate" Call SpaceTemplate()
		   Case "SaveSpaceTemplate" Call SaveSpaceTemplate()
		   Case "loadTemplateDiy" Call loadTemplateDiy
		   Case "upPhoto" Call updatePhoto()
		   Case "saveTemplatePhoto" Call saveTemplatePhoto()
		   Case "delTemplatePhoto" Call delTemplatePhoto()
		  End Select
		End Sub
		
		'增加关注
		Sub addAttention()
		  IF Cbool(KSUser.UserLoginChecked)=false Then  KS.Die Escape("请先登录！")
		  Dim UserID:UserID=KS.ChkClng(Request("userid"))
		  If UserID=0 Then KS.Die Escape("出错啦！")
		  Dim MyUserID:MyUserID=KS.ChkClng(KSUser.GetUserInfo("userid"))
		  If MyUserID=UserID Then
		   KS.Die Escape("出错啦,不能自己关注自己哦！")
		  End If
		  
		  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		  RS.Open "select top 1 * From KS_UserR Where Type=1 and A=" & MyUserID &" and B=" & UserID,conn,1,3
		  If Not RS.Eof Then
		        RS.Close:Set RS=Nothing
				KS.Die Escape("己添加过关注！")
		  Else
		      RS.AddNew
			  RS("A")=MyUserID
			  RS("B")=UserID
			  RS("Type")=1
			  RS("AddDate")=Now
			  RS.Update
			  RS.AddNew
			  RS("A")=UserID
			  RS("B")=MyUserID
			  RS("Type")=0
			  RS("AddDate")=Now
			  RS.Update
			  RS.Close
			  Set RS=Nothing
				 Conn.Execute("Update KS_User Set AttentionNum=AttentionNum+1 Where UserID=" & MyUserID)
				 Conn.Execute("Update KS_User Set FansNum=FansNum+1 Where UserID=" & UserID)
				 Session(KS.SiteSN&"userinfo")=""	
				 KS.Die "success"
		  End If
		End Sub
		
		'取消关注
		Sub cancelAttention()
		  IF Cbool(KSUser.UserLoginChecked)=false Then  KS.Die Escape("请先登录！")
		  Dim UserID:UserID=KS.ChkClng(Request("userid"))
		  If UserID=0 Then KS.Die Escape("出错啦！")
		  Dim MyUserID:MyUserID=KS.ChkClng(KSUser.GetUserInfo("userid"))
		  If MyUserID=UserID Then
		   KS.Die Escape("出错啦！")
		  End If
		  
		  if Not Conn.Execute("select top 1 [type] from KS_UserR Where [Type]=1 and A=" & MyUserID & " and B=" & UserID).eof Then
			Conn.Execute("Delete From KS_UserR Where [Type]=1 and A=" & MyUserID & " and B=" & UserID)
			Conn.Execute("Delete From KS_UserR Where [Type]=0 and A=" & UserID & " and B=" & MyUserID)
			Conn.Execute("Update KS_User Set AttentionNum=AttentionNum-1 Where UserID=" & MyUserID & " and AttentionNum>=1")
			Conn.Execute("Update KS_User Set FansNum=FansNum-1 Where UserID=" & UserID & " and FansNum>=1")
			Session(KS.SiteSN&"userinfo")=""	
			KS.Die "success"
		  Else
		   KS.Die Escape("出错啦！")
		  End If

		End Sub
		
		'广播
		Sub TalkSave()
		 IF Cbool(KSUser.UserLoginChecked)=false Then  KS.Die Escape("请先登录！")
		 IF KS.ChkClng(KS.SSetting(55))=0 Then  KS.Die Escape("对不起，本站没有开通微博频道！")
		 Dim TransID:TransID=KS.ChkClng(request("TransID"))
		 Dim Content:Content=KS.DelSQL(UnEscape(Request("Content")))
		 Dim CopyFrom:CopyFrom="会员广播"
		 If TransID<>0 Then CopyFrom="转播"
		 Dim AddResult:AddResult=KSUser.AddWeiBo(KSUser.UserName,KSUser.GetUserInfo("UserID"),TransID,Content,CopyFrom)
		
		  if  KS.S("qqweibo")="1" Then	Call KSUser.add_qq_weibo(Content&",来自：" & KS.GetDomain &"user/weibo.asp","")
		  If KS.S("sinaweibo")="1" Then
			dim result:result=KSUser.add_sina_weibo(Content&",来自：" & KS.GetDomain&"user/weibo.asp","")
			dim obj:set obj = getjson(result)
			if isobject(obj) then
			  dim newid:newid=conn.execute("select max(id) from KS_UserLog")(0)
			  conn.execute("update KS_UserLog Set SinaWeiboID='" & obj.idstr & "' where id=" & newid)
			end if
			set obj=nothing
		  End If
		  KS.Die Escape(AddResult)
	End Sub
	
	'删除广播
	Sub DelTalk()
	  IF Cbool(KSUser.UserLoginChecked)=false Then  KS.Die Escape("请先登录！")
	  Dim ID:ID=KS.ChkClng(Request("id"))
	  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
	  RS.Open "select top 1 * From KS_UserLogR Where ID=" & id,conn,1,1
	  If RS.Eof AND RS.Bof Then
	    RS.Close:Set RS=Nothing
	    KS.Die "error"
	  End If
	  Dim bType:bType=RS("Type")
	  Dim UserName:UserName=RS("UserName")
	  Dim MsgId:MsgId=RS("MsgId")
	  RS.Close:Set RS=Nothing
	  If UserName<>KSUser.UserName THEN
		   KS.Die Escape("对不起，没有权限删除非自己发的微博！")
	  End If
	  If BType=0 Then
	    Conn.Execute("Delete From KS_UserLog Where ID=" & MsgId)
		Conn.Execute("Delete From KS_UserLogCMT Where MsgID=" & MsgId)
	  Else
	    Conn.Execute("Update KS_UserLog set TransNum=TransNum-1  Where id=" & MsgId &" and TransNum>=1")
	  End If
	    Conn.Execute("Delete From KS_UserLogR Where ID=" & id)
	    Conn.Execute("Update KS_User set MsgNum=MsgNum-1  Where UserName='" & KSUser.UserName &"' and MsgNum>=1")
		Session(KS.SiteSN&"userinfo")=""
	  KS.Die "success"
	End Sub
		
	'显示转播
	Sub TalkTrans()
		  dim ID:ID=KS.ChkClng(request("id"))
		  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		  RS.Open "select top 1 note from ks_UserLog Where ID=" & id,conn,1,1
		  If RS.EOF And RS.Bof Then
		    RS.Close
			Set RS=Nothing
			Exit Sub
		  End If
		  Response.Write " <div class=""transdiv"">转播：“" & ubbcode(RS(0),1)  &"”，把它分享给你的听众。"
		  Response.Write "<br/><textarea class=""transtxt"" name=""transmsg"" id=""transmsg""></textarea>"
		  Response.Write "<div style=""text-align:right""><input onclick=""dotrans(" & id & ");"" type=""button"" value=""转发"" class=""button""></div>"
		  Response.Write "</div>"
		  RS.Close:Set RS=Nothing
	End Sub
	'显示评论
	Sub ShowTalkCmt()
		  dim ID:ID=KS.ChkClng(request("id"))
		  If ID=0 Then KS.Die "error!"
		  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		  RS.Open "select top 1 username from ks_userlog where id=" & id,conn,1,1
		  if rs.eof and rs.bof then
		    rs.close:set rs=nothing
			ks.die "error!"
		  end if
		  dim UserName:UserName=RS("UserName")
		  rs.close
		  %>
		  <div class="cmtbox">
		  <div><span style="cursor:hand;" title="关闭评论框" onclick="$('#cmt<%=ID%>').hide();"><img src='../images/default/pageclose.gif' onmouseover="this.src='../images/default/pageclose1.gif';" onmouseout="this.src='../images/default/pageclose.gif';"/></span>评论原文：</div>
			<textarea id="c<%=ID%>" name="cmt" onblur="ThisBlur(<%=ID%>)" onfocus="ThisFocus(<%=ID%>)" class="textbox" id="cmt">我也说一句...</textarea>
		  <div><span><input type="button" value="评论" onclick="dopostcmt(<%=ID%>);" class="button"/></span>
		   <%if ks.c("username")<>username then%>
		    <label><input type="checkbox" name="addtomyweibo" id="addtomyweibo<%=id%>" value="1" />同时转播到我的微博</label>
		   <%end if%>
		   </div>
		  </div>
		  <%
		  Dim MyStr,TotalNum,PageNum,MaxPerPage,CurrentPage
		  MaxPerPage=6
		  CurrentPage=KS.ChkClng(Request("page"))
		  If CurrentPage<1 Then CurrentPage=1
		  Dim SQLStr:SQLStr="select * from KS_UserLogCMT Where MsgId=" & ID & " and status=1 order by id desc"
		  RS.Open SQLStr,conn,1,1
		  If RS.Eof And RS.Bof Then
		     TotalNUM=0
		  Else
		     TotalNum=Conn.Execute("select count(1) From KS_UserLogCMT Where MsgId=" & ID & " and status=1 ")(0)
			 If (TotalNum Mod MaxPerPage) = 0 Then
				PageNum = TotalNum \ MaxPerPage
			 Else
				PageNum = TotalNum \ MaxPerPage + 1
			 End If
			 If CurrentPage >1 And (CurrentPage - 1) * MaxPerPage < totalNum Then
				RS.Move (CurrentPage - 1) * MaxPerPage
			 End If
			 Dim I:i=0
		     Do While Not RS.Eof 
			    MyStr=MyStr & "<dd><img title='" & rs("username") & "' onerror=""this.src='images/noavatar_small.gif';"" src=""../uploadfiles/user/avatar/" & rs("userid") & ".jpg"" width=""30"" height=""30""  align=""left"" /> <a href='../space/?" & rs("userid") & "' class='cname' target='_blank' title='进入" & rs("username") & "的空间'>" & rs("username") & "</a>：" & rs("content") & "<span>" & KS.GetTimeFormat(RS("adddate")) & "</span></dd>"
			   RS.MoveNext
			   I=I+1
			   If I>=MaxPerPage Then Exit Do
			 Loop
		  End If
		  RS.Close
		  Set RS=Nothing
		  
		  If TotalNum>0 Then
		  %>
			  <div class="cmtlist">
			   <dl>
			  共有 <span class="num"><%=TotalNum%></span> 条评论，分 <span class="num"><%=PageNum%></span> 页显示：<br/>
				 <%=MyStr%>
			  </dl>
			  <ul class="page">
			   <table border="0" width="300" align="right">
			    <tr>
				 <td nowrap="nowrap">
			  <%If CurrentPage>1 then%>
			   <a href='javascript:;' title='上一页' onclick="quickreply(<%=id%>,<%=currentpage-1%>);">上一页</a>
			  <%end if%>
			  <%
			  if pagenum>1 then
			    dim t:t=0
				dim start:start=1
				if currentpage>5 then start=currentpage
			    for i=start to pagenum
				 t=t+1
				 if t>5 then exit for
				  if currentpage=i then
				 response.write "<a href='javascript:;' class='curr' title='第" & i & "页' onclick=""quickreply(" & id & "," & i & ");"">" & I & "</a>"
				  else
				 response.write "<a href='javascript:;' title='第" & i & "页' onclick=""quickreply(" & id & "," & i & ");"">" & I & "</a>"
				 end if
				next
			  end if
			  %>
			  <%if currentpage<PageNum Then%>
			   <a href='javascript:;' title='下一页' onclick="quickreply(<%=id%>,<%=currentpage+1%>);">下一页</a>
			   <%End If%>
			    </td>
			   </tr>
			   </table>
			   </ul>
			 </div>
			 

			 
			 
		 <%
		 End If
	 End Sub
	 
	 '保存评论
	 Sub TalkCmtSave()
	   IF Cbool(KSUser.UserLoginChecked)=false Then  KS.Die Escape("评论需要先登录！")
	   Dim ID:ID=KS.ChkClng(Request("id"))
	   Dim addtomyweibo:addtomyweibo=KS.ChkClng(Request("addtomyweibo"))
	   If Id=0 Then Exit Sub
	   Dim Content:Content=KS.DelSQL(UnEscape(Request("Content")))
	   Dim RS:Set RS=Server.CreateObject("adodb.recordset")
	   RS.Open "select top 1 * From KS_UserLogCMT Where 1=0",conn,1,3
	   RS.AddNew
	    RS("userid")=KSUser.GetUserInfo("UserID")
		RS("username")=KSUser.UserName
		RS("MsgID")=ID
		RS("Content")=Content
		RS("AddDate")=Now
		RS("Status")=1
	  RS.Update
	  RS.Close
	  Set RS=Nothing
	  Conn.Execute("Update KS_UserLog Set CmtNum=CmtNum+1 Where ID=" & ID)
	  If addtomyweibo=1 Then  '转播
	   Dim AddResult:AddResult=KSUser.AddWeiBo(KSUser.UserName,KSUser.GetUserInfo("UserID"),ID,Content,"转播")
	  End If
	  KS.Die "success"
	 End Sub
		
		
		
		
		Sub SpaceTemplate()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die "error!"
		  End If
		  Dim Flag,MaxPerPage,CurrentPage,RS,TotalPut,N,PageNum
		  If KSUser.GetUserInfo("UserType")=1 Then Flag=4 Else Flag=2
		  MaxPerPage=6
		  CurrentPage = KS.ChkClng(KS.S("page"))
		  If CurrentPage<=0 Then CurrentPage=1
		  Set RS=Server.CreateObject("AdodB.Recordset")
		  RS.open "select * from ks_blogtemplate where TemplateAuthor='" & KSUser.username & "' or (usertag=0 and flag=" & Flag &") order by usertag desc,id desc",conn,1,1
			If RS.EOF And RS.BOF Then
				  Response.Write Escape("没有可用模板!")
			Else
				totalPut = RS.RecordCount
				if (TotalPut mod MaxPerPage)=0 then
				    PageNum = TotalPut \ MaxPerPage
				else
					PageNum = TotalPut \ MaxPerPage + 1
				end if
				If CurrentPage>PageNum Then CurrentPage=PageNum
				If CurrentPage>1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
					RS.Move (CurrentPage - 1) * MaxPerPage
			    End If
				N=0
				Do While Not RS.Eof
				N=N+1 
				dim pic:pic=rs("templatepic")
			    if KS.IsNul(pic) then pic="../images/nopic.gif"%>
				<li>
				<%if rs("groupid")<>"0" and Not KS.IsNul(rs("groupid")) And KS.FoundInArr(rs("groupid"),KSUser.GroupID,",")=false Then%>
				<a title="VIP模板,您的当前级别不可用！" disabled href="javascript:void(0)">
                 <span class="vip"></span>
				<%else%>
			    <a title="作者：<%=rs("templateauthor")%>"  href="javascript:void(0)" onclick="setTemplate(<%=rs("id")%>)">
				<%end if%>
			    <div><img src="<%=pic%>" width="125" height="80"/>
				<%=KS.Gottopic(rs("templatename"),30)%>
				</div>
				</a>
			   </li>
				<%
				If N>=MaxPerPage Then Exit Do
				RS.MoveNext
				Loop
		   End If
		   RS.Close:Set RS=nothing
		   response.write "<div class=""clear""></div>"
		   If PageNum>1 Then
		     response.write "<div class=""page"">"
			 if currentpage=1 then 
			  response.write " <a href=""#"" disabled>上一页</a> "
			 else
		     response.write " <a href=""javascript:void(0)"" onclick=""getTemplate(" & CurrentPage-1 & ")"">上一页</a>"
			 end if
			 if currentpage=pagenum then
			  response.write " <a href=""#"" disabled>下一页</a> "
			 else
		     response.write " <a href=""javascript:void(0)"" onclick=""getTemplate(" & CurrentPage+1 & ")"">下一页</a>"
			 end if
			 response.write "</div>"
		   End If
		End Sub
		Sub SaveSpaceTemplate()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die Escape("没有权限")
		  End If
		  Dim TemplateID:TemplateID=KS.ChkClng(KS.G("TemplateID"))
		  If TemplateID=0 Then
		   KS.Die Escape("模板ID不存在！")
		  End If
		  Conn.Execute("Update KS_Blog Set TemplateID=" & TemplateID & " Where UserName='" & KSUser.UserName & "'")
		  KS.Die "success"
		End Sub
		Sub loadTemplateDiy()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die Escape("没有权限")
		  End If
		  Dim RS,TemplateID,XML,Node
		  Set RS=Conn.Execute("Select top 1 b.TemplateName,b.id From KS_Blog a Inner Join KS_BlogTemplate b on a.templateid=b.id Where a.UserName='" & KSUser.UserName & "'")
		  If RS.EOf And RS.Bof Then
			 RS.Close : Set RS=Nothing
		     KS.Die Escape("您还没有开通站点!")
		  End If
		  TemplateID=RS(1)
		  KS.Echo "<h1>"
		  KS.Echo Escape("您当前使用的风格是<span>“" & RS(0) &"”</span>")
		  RS.Close
		  RS.Open "Select top 100 * From KS_BlogSkin Where TemplateID=" & TemplateID &" And IsDefault=1 order by OrderID,id",conn,1,1
		  If RS.Eof And RS.Bof Then
		    RS.Close : Set RS=Nothing
		    KS.Echo Escape(",该风格不允许自行更新图片!</h1>")
		  Else
		    KS.Echo Escape(",该风格允许更换<span>" & rs.recordcount &"</span>张图片,请点击以下图片名称上传更换!红色部分表示您有更换过图片。</h1>")
			KS.Echo "<table border=""0"" width=""100%"">"
			KS.Echo "<tr><td width=""200""><div class='photoname'><ul>"
			Set XML=KS.RsToXml(RS,"row","")
			RS.Close :Set RS=Nothing
			If IsObject(XML) Then
			  Dim PicID,I:I=0
			  For Each Node In XML.DocumentElement.SelectNodes("row")
			    If I=0 Then PicID=Node.SelectSingleNode("@id").text
				if conn.execute("select top 1 * from ks_blogskin where username='"& KSUser.UserName &"' and isdefault=0 and templateid=" & KS.ChkClng(Node.SelectSingleNode("@templateid").text) & " and orderid=" & KS.ChkClng(Node.SelectSingleNode("@orderid").text)).eof Then
			    KS.Echo escape("<li>")
				Else
			    KS.Echo escape("<li class=""redborder"">")
				End If
			    KS.Echo escape("<a href=""javascript:void(0)"" onclick=""updatePhoto("& Node.SelectSingleNode("@id").text &")"">" & KS.Gottopic(Node.SelectSingleNode("@photoname").text,15) &"</a></li>")
				I=i+1
			  Next
			End If
			KS.Echo "</ul></div></td>"
			KS.Echo "<td id=""uphtml"">" &GetUploadTemplatePic(PicID) &" </td>"
			KS.Echo "</tr>"
			KS.Echo "</table>"
		  End If
		  
		End Sub
		
		Sub updatePhoto()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die Escape("没有权限")
		  End If
		  KS.Die GetUploadTemplatePic(KS.ChkClng(KS.S("PhotoID")))
		End Sub
		Function GetUploadTemplatePic(PicID)
		 Dim str:str=""
		 Dim RS:Set RS=Conn.Execute("Select top 1 * From KS_BlogSkin Where ID=" & PicID)
		 If RS.Eof And RS.Bof Then
		  RS.Close :Set RS=Nothing
		  Exit Function
		 End If
		 str=str &"当前正在更换图片“<font color=blue><strong>" & rs("photoname") & "</strong></font>”"
		 If KS.ChkClng(RS("Width"))<>0 Then str=str &" 建议图片宽度:<span>" & rs("width")&"px</span>"
		 If KS.ChkClng(RS("Height"))<>0 Then str=str &" 高度:<span>" & rs("height") &"px</span>"
		 Dim PhotoUrl,OrderID,TemplateID,modifylink
		 PhotoUrl  = rs("photourl")
		 OrderID   = rs("OrderID")
		 TemplateID= rs("TemplateID")
		 modifylink= rs("modifylink")
		 RS.Close 
		 '判断有没有上传过了
		 Dim DiyPhotoUrl,DiyLinkUrl,DiyID
		 RS.Open "select top 1 * from KS_BlogSkin Where OrderID=" & OrderID & " and TemplateID=" & TemplateID &" And IsDefault=0 And UserName='" & KSUser.UserName &"'",conn,1,1
		 If Not RS.Eof Then
		    DiyID=rs("ID")
		    DiyPhotoUrl=rs("photourl")
			DiyLinkUrl=rs("linkurl")
		    str=str & " <font color=#ff6600>您已有上传过该图片了，您还可以更换！</font>"
		 End If
		 RS.Close
		 Set RS=Nothing
		 str=str & "<form name=""myform"" action=""?"" method=""post""><br/><table border='0'><tr><td>图片地址：<input type=""text"" name=""PhotoUrl"" id=""PhotoUrl"" value=""" & DiyPhotoUrl & """ size=""30""></td><td width=""200""><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_UpFile.asp?fieldname=PhotoUrl&type=Pic&ChannelID=8000&MaxFileSize=500&ext=*.jpg;*.gif;*.png' frameborder=""0"" scrolling=""No"" align=""center"" width='200' height='30'></iframe></td></tr>"
		 if modifylink="1" then
		 str=str & "<tr>"
		 Else
		 str=str &"<tr style=""display:none"">"
		 End If
		 str=str &"<td colspan=""2"">链接地址：<input value=""" & DiyLinkUrl & """ size=""30"" type=""text"" name=""LinkUrl"" id=""LinkUrl""> <span style='color:#999'>可以不填，表示不加链接</span></td></tr>"
		 str=str & "<tr><td colspan=2><button type=""button"" class=""pn pnc"" onClick=""savePhoto('" & DiyPhotoUrl &"','" & DiyLinkUrl &"',"&OrderID&"," & TemplateID&")""><strong> 保 存 </strong></button>"
		 if KS.ChkClng(DiyID)<>0 Then
		  str=str & "<button type=""button"" class=""pn pnc"" onClick=""delPhoto("&DiyID&")""><strong> 删除用默认图片 </strong></button>"
		 end if
		 str=str &"</td></tr></table></form>"
		 GetUploadTemplatePic=escape(str)
		End Function
		
		Sub saveTemplatePhoto()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die Escape("没有权限")
		  End If
		  Dim modifylink:modifylink=0
		  Dim PhotoUrl:PhotoUrl=KS.G("PhotoUrl")
		  Dim LinkUrl:LinkUrl=KS.G("LinkUrl")
		  Dim OrderID:OrderID=KS.ChkClng(ks.G("OrderID"))
		  Dim TemplateID:TemplateID=KS.ChkClng(KS.G("TemplateID"))
		  If TemplateID=0 or OrderID=0 Then KS.Die escape("出错啦!")
		  Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		  RS.Open "select top 1 modifylink from KS_BlogSkin Where IsDefault=1 And TemplateID=" & TemplateID &" And OrderID=" & OrderID,conn,1,1
		  If Not RS.Eof Then
		    modifylink=rs("modifylink")
		  End If
		  RS.Close
		  RS.Open "Select top 1 * From KS_BlogSkin Where IsDefault=0 and TemplateID=" & TemplateID & " And OrderID=" & OrderID & " And UserName='" & KSUser.UserName &"'",conn,1,3
		  If RS.Eof Then
		    RS.AddNew
		  End If
		  RS("TemplateID")=TemplateID
		  RS("PhotoUrl")=PhotoUrl
		  If modifylink="1" Then
		  RS("LinkUrl")=LinkUrl
		  End If
		  RS("IsDefault")=0
		  RS("UserName")=KSUser.UserName
		  RS("OrderID")=OrderID
		  RS.Update
		  RS.Close
		  Set RS=Nothing
		  '从KS_UploadFiels表中删除无用记录
		  Conn.Execute("Delete From KS_UploadFiles Where ChannelID=1013 and InfoID=" & TemplateID &" And UserName='" & KSUser.UserName &"' and FileName not in(Select photourl From KS_BlogSkin Where (IsDefault=0 and TemplateID=" & TemplateID & " And UserName='" & KSUser.UserName &"') or isdefault=1)")
		  Call KS.FileAssociation(1013,templateid,PhotoUrl ,0)
		  KS.Die "success"
		End Sub
		Sub delTemplatePhoto()
		  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die Escape("没有权限")
		  End If
		  dim rs:set rs=server.createobject("adodb.recordset")
		  rs.open "select top 1 * from KS_BlogSkin Where ID=" & KS.ChkClng(KS.G("ID")) & " And UserName='" & KSUser.UserName &"'",conn,1,1
		  if not rs.eof then
		   Conn.Execute("Delete From KS_BlogSkin Where ID=" & KS.ChkClng(KS.G("ID")) & " And UserName='" & KSUser.UserName &"'")
		   '从KS_UploadFiels表中删除无用记录
		   Conn.Execute("Delete From KS_UploadFiles Where ChannelID=1013 and InfoID=" & rs("TemplateID") &" And UserName='" & KSUser.UserName &"' and FileName not in(Select photourl From KS_BlogSkin Where (IsDefault=0 and TemplateID=" & rs("TemplateID") & " And UserName='" & KSUser.UserName &"') or isdefault=1)")
		  end if
		  rs.close:set rs=nothing
		  KS.Die "success"
		End Sub
		
		
		
		Sub GetNewMessage()
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write Escape("站内消息(0)")
		  Exit Sub
		End If
		Dim MyMailTotal:MyMailTotal=Conn.Execute("Select Count(ID) From KS_Message Where Incept='" &KSUser.UserName &"' And Flag=0 and IsSend=1 and delR=0")(0)
		'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_BlogMessage Where UserName='" &KSUser.UserName &"' And readtf=0")(0)
		'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_BlogComment Where UserName='" &KSUser.UserName &"' And readtf=0")(0)
		'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_Friend Where Friend='" &KSUser.UserName &"' And accepted=0")(0)

		Response.write Escape("站内消息(<font color='#ff0000'>" & MyMailTotal&"</font>)")
		If MyMailTotal>0 Then Response.Write "<bgsound src=""images/mail.wmv"" border=0>"
		End Sub

		Sub GetAdminMessage()
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "(0)"
		  Exit Sub
		End If
		Dim MyMailTotal:MyMailTotal=Conn.Execute("Select Count(ID) From KS_Message Where Incept='" &KSUser.UserName &"' And Flag=0 and IsSend=1 and delR=0")(0)
		Response.write "(<font color='#ff0000'>" & MyMailTotal&"</font>)"
		If MyMailTotal>0 Then Response.Write "<bgsound src=""../User/images/mail.wmv"" border=0>"
		End Sub
		
		
	
	'检查第三方接口有没有登录过期了，过期要求重新授权
	Sub CheckToken()
	  IF Cbool(KSUser.UserLoginChecked)=false Then
		   KS.Die "nologin"
	  End If
	  Dim checktype:checktype=KS.S("Checktype")
	  If session("api" & checktype)<>"" then ks.die "success"
	  Dim Result
	  if checktype="qqweibo" then
	     if ksuser.getuserinfo("qqopenid")="" then
		   ks.die "nobind"
		 else
			 result=get_user_info(1,ksuser.getuserinfo("qqtoken"),ksuser.getuserinfo("qqopenid"))
			 if result="" then
			   ks.die "error"
			 else
			   dim obj:set obj = getjson(result)
			   if isobject(obj) Then
				 if obj.ret=0 then session("api" & checktype)="true":ks.die "success" else ks.die "error"
			   else
				 ks.die "error"
			   end if
			 end if
		end if
	  elseif checktype="sinaweibo" then
	     if ksuser.getuserinfo("sinaid")="" then
		     ks.die "nobind"
		 else
			 result=get_user_info(2,ksuser.getuserinfo("sinatoken"),ksuser.getuserinfo("sinaid"))
			 if instr(result,"error_code")<>0 then
			   ks.die "error"
			 else
			   session("api" & checktype)="true"
			   ks.die "success"
			 end if
		 end if
	  end if
	End Sub
End Class
%> 
