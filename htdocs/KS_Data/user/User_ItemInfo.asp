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
Set KSCls = New MyArticleCls
KSCls.Kesion()
Set KSCls = Nothing

Class MyArticleCls
        Private KS,KSUser,ChannelID,ID,ClassID,RS
		Private totalPut,MaxPerPage,PubUrl
		Private ComeUrl,LoginTF
		Private Verific,PhotoUrl,Action,I
		Private XmlFields,XmlFieldArr,Fi,IXml,INode
		Private Sub Class_Initialize()
			MaxPerPage =10
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
        
		Public Sub LoadMain()
		ComeUrl=Request.ServerVariables("HTTP_REFERER")
		ChannelID=KS.ChkClng(KS.S("ChannelID"))
		If ChannelID=0 Then ChannelID=1
		LoginTF=Cbool(KSUser.UserLoginChecked)
		IF LoginTF=false  Then
		  Call KS.ShowTips("error","<li>你还没有登录或登录已过期，请重新<a href='../user/login/'>登录</a>!</li>")
		  Exit Sub
		End If
		if KS.C_S(ChannelID,36)=0 then
		  Call KS.ShowTips("error","<li>本频道不允许投稿!</li>")
		  Exit Sub
		end if
		
		'设置缩略图参数
		Session("ThumbnailsConfig")=KS.C_S(ChannelID,46)
		
		Select Case KS.ChkClng(KS.C_S(ChannelID,6))
		 Case 1 PubUrl="user_post.asp"
		 Case 2 PubUrl="user_post.asp"
		 Case 3 PubUrl="user_post.asp"
		 Case 4 PubUrl="User_Myflash.asp"
		 Case 5 PubUrl="User_MyShop.asp"
		 Case 7 PubUrl="User_MyMovie.asp"
		 Case 8 PubUrl="User_MySupply.asp"
		End Select

		Call KSUser.Head()
		%>
		<div class="tabs">	
			<ul>
				<li<%If KS.S("Status")="" then response.write " class='puton'"%>><a href="?ChannelID=<%=ChannelID%>">我发布的<%=KS.C_S(ChannelID,3)%>(<span class="red"><%=Conn.Execute("Select count(id) from " & KS.C_S(ChannelID,2) &" where Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="1" then response.write " class='puton'"%>><a href="?ChannelID=<%=ChannelID%>&Status=1">已审核(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=1 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="0" then response.write " class='puton'"%>><a href="?ChannelID=<%=ChannelID%>&Status=0">待审核(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=0 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="2" then response.write " class='puton'"%>><a href="?ChannelID=<%=ChannelID%>&Status=2">草 稿(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=2 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="3" then response.write " class='puton'"%>><a href="?ChannelID=<%=ChannelID%>&Status=3">被退稿(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=3 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
			</ul>
        </div>
		<%
		Action=KS.S("Action")
		Select Case Action
		 Case "Del"	  Call KSUser.DelItemInfo(ChannelID,"user_iteminfo.asp?" & KS.QueryParam("id,action"))
		 Case "refresh" Call KSUser.RefreshInfo(KS.C_S(ChannelID,2))
		 Case Else  Call MainList()
		End Select
	   End Sub
	   Sub MainList()
			Response.Write "<script src=""../ks_inc/jquery.imagePreview.1.0.js""></script>"
		    XmlFields=LFCls.GetConfigFromXML("usermodelfield","/modelfield/model",ChannelID)
			If Not KS.IsNul(XmlFields) Then
			 XmlFieldArr=Split(XmlFields,",")
			End If
			Dim Param:Param=" Where Deltf=0 AND Inputer='"& KSUser.UserName &"'"
			Verific=KS.S("Status")
			If Verific="" or not isnumeric(Verific) Then Verific=4
            IF Verific<>4 Then Param= Param & " and Verific=" & Verific
			IF KS.S("Flag")<>"" Then
					  IF KS.S("Flag")=0 Then Param=Param & " And Title like '%" & KS.S("KeyWord") & "%'"
					  IF KS.S("Flag")=1 Then Param=Param & " And KeyWords like '%" & KS.S("KeyWord") & "%'"
			End if
			If KS.S("ClassID")<>"" And KS.S("ClassID")<>"0" Then Param=Param & " And TID='" & KS.S("ClassID") & "'"
			 Select Case Verific
				   Case 0 Call KSUser.InnerLocation("待审" & KS.C_S(ChannelID,3) & "列表")
				   Case 1 Call KSUser.InnerLocation("已审" & KS.C_S(ChannelID,3) & "列表")
				   Case 2 Call KSUser.InnerLocation("草稿" & KS.C_S(ChannelID,3) & "列表")
				   Case 3 Call KSUser.InnerLocation("退稿" & KS.C_S(ChannelID,3) & "列表")
                   Case Else Call KSUser.InnerLocation("所有" & KS.C_S(ChannelID,3) & "列表")
			 End Select
		 %>
		<div class="writeblog"><img src="images/icon1.png" align="absmiddle"><a href="<%=PubUrl%>?ChannelID=<%=ChannelID%>&Action=Add">发布<%=KS.C_S(ChannelID,3)%></a></div>

		<table  width="99%"  border="0" align="center" cellpadding="1" cellspacing="1" class="border">
         <%
		    Dim FieldStr:FieldStr="ID,Tid,Title,Inputer,AddDate,PhotoUrl,Verific,Recommend,Popular,Strip,Rolls,Slide,IsTop,Hits,Fname,RefreshTF"
	 		If KS.C_S(ChannelID,6)=1 Then
			  FieldStr=FieldStr & ",IsVideo"
			End If

			 If IsArray(XmlFieldArr) Then
			 For Fi=0 To Ubound(XmlFieldArr)
			  if lcase(Split(XmlFieldArr(fi),"|")(1))<>"modeltype" and lcase(Split(XmlFieldArr(fi),"|")(1))<>"attribute" and ks.foundinarr(lcase(FieldStr),lcase(Split(XmlFieldArr(fi),"|")(1)),",")=false then
			   FieldStr=FieldStr & "," & Split(XmlFieldArr(fi),"|")(1)
			  end if
			 Next
			End If
			Dim Sql:sql = "select " & FieldStr & " from " & KS.C_S(ChannelID,2) & Param &" order by ID Desc"
			 Set RS=Server.CreateObject("AdodB.Recordset")
			  RS.open sql,conn,1,1
			  If RS.EOF And RS.BOF Then
			   RS.Close : Set RS=Nothing
			  Response.Write "<tr><td class='tdbg' align='center' colspan=12 height=30 valign=top>当前没有任何" & KS.C_S(ChannelID,3) & "!</td></tr>"
			 Else
				totalPut = RS.RecordCount
					
				If CurrentPage > 1  and (CurrentPage - 1) * MaxPerPage < totalPut Then
					RS.Move (CurrentPage - 1) * MaxPerPage
				End If
				Set IXML=KS.ArrayToxml(RS.GetRows(MaxPerPage),rs,"row","")
				RS.Close : Set RS=Nothing
				If IsArray(XmlFieldArr) Then
				 Call ShowDiyList
				Else
				 Call showContent
				End If
			End If
     %>
	  </table>
	  
			 <table cellspacing="0" cellpadding="0" border="0" width="100%">
				 <tr>
				 <td>
					<label><input id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中所有</label>&nbsp;<button id="btn1"  class="pn pnc" onClick="return(confirm('确定删除选中的<%=KS.C_S(ChannelID,3)%>吗?'));" type=submit><strong>删除选定</strong></button></FORM>       
				 </td>
				 <td align='right'>
					<%
					   Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)
					%>
				 </td>
				 </tr>
			 </table>
									 
	<table>				
	 
	 <tr class='tdbg'>
           <form action="User_ItemInfo.asp" method="post" name="searchform">
		   <input type="hidden" name="ChannelID" value="<%=ChannelID%>" />
           <td height="45" colspan=14>
				<strong><%=KS.C_S(ChannelID,3)%>搜索：</strong>
				 <select name="Flag">
					<option value="0">标题</option>
					<option value="1">关键字</option>
				 </select>
										  
				关键字
				<input type="text" name="KeyWord" class="textbox" onclick="if(this.value=='关键字'){this.value=''}" value="关键字" size=20>&nbsp;<input class="button" type="submit" name="submit1" value=" 搜 索 ">
			 </td>
			 </form>
             </tr>
         </table>
		 
		 <table  width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
             <tr class="title">
                <td height="24" style="padding-left:15px;">注意事项：</td>
             </tr>
             <tr>
                    <td bgColor="#ffffff" height="26">
					 1、请确保您的发布的内容不含黄色信息。确定真实性，合法性，否则后果自负。<br/>
					 2、请不要重复发布同一条信息<%If KS.ChkClng(Split(KS.C_S(ChannelID,46)&"||||","|")(3))=1 Then%>，您可以利用本站的刷新功能，将信息的添加时间刷新为当前时间<%end if%>。
					</td>
			 </tr>
		</table> 
					
		 
		 
	</div>
 <%
  End Sub
  
  Sub ShowDiyList()
  %>
  <tr align="center" class="title">
   <td><b>选择</b></td><td><b>标题</b></td>
   <%
   If IsArray(XmlFieldArr) Then
	 For Fi=0 To Ubound(XmlFieldArr)
	   KS.echo ("<td nowrap>" & Split(XmlFieldArr(fi),"|")(0) & "</td>")
	 Next
   End If
   %>
   <td><b>管理</b></td>
  </tr>
  <%
   For Each INode In IXml.DocumentElement.SelectNodes("row")
    Dim AttributeStr:AttributeStr = ""
	If Instr(lcase(XmlFields),"attribute")<>0 then
		If Cint(INode.SelectSingleNode("@recommend").text) = 1 Or Cint(INode.SelectSingleNode("@popular").text) = 1 Or Cint(INode.SelectSingleNode("@strip").text) = 1 Or Cint(INode.SelectSingleNode("@rolls").text) = 1 Or Cint(INode.SelectSingleNode("@slide").text) = 1 Or Cint(INode.SelectSingleNode("@istop").text) = 1 Then
			If Cint(INode.SelectSingleNode("@recommend").text) = 1 Then AttributeStr = AttributeStr & (" <span title=""推荐" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""green"">荐</font></span>&nbsp;")
			If Cint(INode.SelectSingleNode("@popular").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""热门" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""red"">热</font></span>&nbsp;")
			If Cint(INode.SelectSingleNode("@strip").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""今日头条"" style=""cursor:default""><font color=""#0000ff"">头</font></span>&nbsp;")
			If Cint(INode.SelectSingleNode("@rolls").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""滚动" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""#F709F7"">滚</font></span>&nbsp;")
			If Cint(INode.SelectSingleNode("@slide").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""幻灯片" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""black"">幻</font></span>")
			IF Cint(INode.SelectSingleNode("@istop").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""固顶" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""brown"">固</font></span>")
			If KS.C_S(Channelid,6)=1 Then
			IF KS.ChkClng(INode.SelectSingleNode("@isvideo").text) = 1 Then AttributeStr = AttributeStr & ("<span title=""视频" & KS.C_S(ChannelID,3) & """ style=""cursor:default""><font color=""#ff6600"">频</font></span>")
			End If
			If AttributeStr="" Then AttributeStr="---"
		Else
			AttributeStr = "---"
		End If
	End If
	if i mod 2=0 then
		%>
		<tr class='tdbg'  onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
		<%
		else
		%>
		<tr class='tdbg trbg'>
		<%
		end if
		i=i+1
  %>
	<td class="splittd" align="center"><input id="ID" type="checkbox" value="<%=INode.SelectSingleNode("@id").text%>"  name="ID"></td>
	<td class="splittd">
	 <%
	 Dim ItemUrl
	 if INode.SelectSingleNode("@refreshtf").text="1" then
	  ItemUrl=KS.GetItemURL(ChannelID,INode.SelectSingleNode("@tid").text,INode.SelectSingleNode("@id").text,INode.SelectSingleNode("@fname").text)
	 else
	  ItemUrl="../item/show.asp?m=" & ChannelID & "&d=" & INode.SelectSingleNode("@id").text
	 end if%>
	<a href="<%=ItemUrl%>" title="<%=INode.SelectSingleNode("@title").text%>" target="_blank"><%=KS.Gottopic(INode.SelectSingleNode("@title").text,30)%></a></td>
	<%
	If IsArray(XmlFieldArr) Then
		For Fi=0 To Ubound(XmlFieldArr)
			KS.echo ("<td class='splittd' nowrap align='center'>&nbsp;")
		   select case lcase(Split(XmlFieldArr(fi),"|")(1))
				    case "modeltype" KS.echo KS.C_S(ChannelID,3)
					case "attribute" KS.echo AttributeStr
					case "adddate" ks.echo KS.GetTimeFormat(INode.SelectSingleNode("@adddate").text)
					case "refreshtf" 
						If KS.C_S(ChannelId,7)="0" then
						  ks.echo "<span style='color:blue;cursor:default' title='本模型没有启用生成静态HTML,无需生成'>无需生成</span>"
					   Else
						   if INode.SelectSingleNode("@refreshtf").text="1" then
								ks.echo "<font color=green>已生成</font>"
						   else 
								ks.echo "<font color='#ff3300'>未生成</font>"
						   end if
					   End If
					case else
					  ks.echo INode.SelectSingleNode("@" &lcase(Split(XmlFieldArr(fi),"|")(1))).text
					end  select
			ks.echo ("&nbsp;</td>")
	 Next
	End If
	%>
	<td class="splittd" align="center">
	<%If KS.ChkClng(Split(KS.C_S(KS.G("ChannelID"),46)&"||||","|")(3))=1 Then%>
		<a href="?ChannelID=<%=ChannelID%>&action=refresh&id=<%=INode.SelectSingleNode("@id").text%>" class="box">刷新</a>
	<%end if%>
	<%if cint(INode.SelectSingleNode("@verific").text)<>1 or KS.ChkClng(KS.U_S(KSUser.GroupID,1))=1 then%>
											<a class='box' href="<%=PubUrl%>?channelid=<%=channelid%>&id=<%=INode.SelectSingleNode("@id").text%>&Action=Edit&&page=<%=CurrentPage%>">修改</a> <a class='box' href="javascript:;" onclick = "$.dialog.confirm('确定删除<%=KS.C_S(ChannelID,3)%>吗?',function(){location.href='?channelid=<%=channelid%>&action=Del&ID=<%=INode.SelectSingleNode("@id").text%>&<%=ks.queryparam("id,action,channelid")%>';},function(){})">删除</a>
	<%else
		If KS.C_S(ChannelID,42)=0 Then
			Response.write "---"
		Else
			Response.Write "<a  class='box' href='" & PubUrl &"?channelid=" & channelid & "&id=" & INode.SelectSingleNode("@id").text &"&Action=Edit&&page=" & CurrentPage &"'>修改</a> <a class='box' href='#' disabled>删除</a>"
		End If
	end if
	%>
	</td>
   </tr>
  <%
   Next
  End Sub
  
  Sub ShowContent()
    Dim I,PhotoUrl
    Response.Write "<FORM Action=""?ChannelID=" & ChannelID & "&Action=Del"" name=""myform"" method=""post"">"
    For Each INode In IXml.DocumentElement.SelectNodes("row")
        If Not KS.IsNul(INode.SelectSingleNode("@photourl").text) Then
		 PhotoUrl=INode.SelectSingleNode("@photourl").text
		Else
		 PhotoUrl="Images/nopic.gif"
		End If %>
           <tr>
			<td class="splittd" width="10"><input id="ID" type="checkbox" value="<%=INode.SelectSingleNode("@id").text%>"  name="ID"></td>
		    <td class="splittd" width="33"><div style="cursor:pointer;text-align:center;width:33px;height:33px;border:1px solid #f1f1f1;padding:1px;"><a href="<%=PhotoUrl%>" target="_blank" title="<%=INode.SelectSingleNode("@title").text%>" class="preview"><img  src="<%=PhotoUrl%>" width="32" height="32"></a></div>
			</td>
            <td height="45" align="left" class="splittd">
			             <%
						 Dim ItemUrl
						 if INode.SelectSingleNode("@refreshtf").text="1" then
						  ItemUrl=KS.GetItemURL(ChannelID,INode.SelectSingleNode("@tid").text,INode.SelectSingleNode("@id").text,INode.SelectSingleNode("@fname").text)
						 else
						  ItemUrl="../item/show.asp?m=" & ChannelID & "&d=" & INode.SelectSingleNode("@id").text
						 end if%>
						<div class="Contenttitle"><a href="<%=ItemUrl%>" target="_blank"><%=trim(INode.SelectSingleNode("@title").text)%></a>
						</div>
						
						<div class="Contenttips">
			            <span>
						 栏目：[<%=KS.C_C(INode.SelectSingleNode("@tid").text,1)%>] 发布人：<%=INode.SelectSingleNode("@inputer").text%> 发布时间：<%=KS.GetTimeFormat(INode.SelectSingleNode("@adddate").text)%>
						 状态：<%Select Case cint(INode.SelectSingleNode("@verific").text)
									Case 0
									   Response.Write "<span style=""color:green"">待审</span>"
									Case 1
									   Response.Write "<span>已审</span>"
                                    Case 2
									  Response.Write "<span style=""color:red"">草稿</span>"
									 Case 3
									  Response.Write "<span style=""color:blue"">退稿</span>"
                               end select
							 %>
						 </span>
						</div>
						</td>
                        <td class="splittd" align="center">
						<%If KS.ChkClng(Split(KS.C_S(KS.G("ChannelID"),46)&"||||","|")(3))=1 Then%>
						   <a href="?ChannelID=<%=ChannelID%>&action=refresh&id=<%=INode.SelectSingleNode("@id").text%>" class="box">刷新</a>
						<%end if%>
							<%if cint(INode.SelectSingleNode("@verific").text)<>1 or KS.ChkClng(KS.U_S(KSUser.GroupID,1))=1 then%>
											<a class='box' href="<%=PubUrl%>?channelid=<%=channelid%>&id=<%=INode.SelectSingleNode("@id").text%>&Action=Edit&&page=<%=CurrentPage%>">修改</a> <a class='box' href="javascript:;" onclick = "$.dialog.confirm('确定删除<%=KS.C_S(ChannelID,3)%>吗?',function(){location.href='?channelid=<%=channelid%>&action=Del&ID=<%=INode.SelectSingleNode("@id").text%>&<%=ks.queryparam("id,action,channelid")%>';},function(){})">删除</a>
							<%else
								  If KS.C_S(ChannelID,42)=0 Then
									  Response.write "---"
								  Else
									  Response.Write "<a  class='box' href='" & PubUrl & "?channelid=" & channelid & "&id=" & INode.SelectSingleNode("@id").text &"&Action=Edit&&page=" & CurrentPage &"'>修改</a> <a class='box' href='#' disabled>删除</a>"
								  End If
							end if
							%>
						</td>
                       </tr>
 <%
   Next

 End Sub

%>
<!--#include file="../ks_cls/UserFunction.asp"-->
<%
 
End Class
%> 
