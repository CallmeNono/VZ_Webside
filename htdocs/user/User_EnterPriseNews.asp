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
Set KSCls = New EnterPriseNewsCls
KSCls.Kesion()
Set KSCls = Nothing

Class EnterPriseNewsCls
        Private KS,KSUser,ChannelID
		Private totalPut,RS,MaxPerPage
		Private ComeUrl,ClassID
		Private title,Content,Verific,Action,AddDate
		Private Sub Class_Initialize()
			MaxPerPage =12
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/SpaceFunction.asp"-->
		<%
       Public Sub loadMain()
		ComeUrl=Request.ServerVariables("HTTP_REFERER")
		Call KSUser.SpaceHead()
		Call KSUser.InnerLocation("所有新闻列表")
		KSUser.CheckPowerAndDie("s11")
		
		%>
		<div class="tabs">	
			<ul>
			  <li<%If KS.S("Status")="" then response.write " class='puton'"%>><a href="?">所有新闻(<span class="red"><%=conn.execute("select count(id) from KS_EnterPrisenews where username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="2" then response.write " class='puton'"%>><a href="?Status=2">已审核(<span class="red"><%=conn.execute("select count(id) from KS_EnterPrisenews where status=1 and username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="1" then response.write " class='puton'"%>><a href="?Status=1">待审核(<span class="red"><%=conn.execute("select count(id) from KS_EnterPrisenews where status=0 and username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
			</ul>
        </div>
		<%
		Select Case KS.S("Action")
		 Case "Del"  Call ArticleDel()
		 Case "Add","Edit" Call ArticleAdd()
		 Case "DoSave" Call DoSave()
		 Case Else Call ArticleList()
		End Select
	   End Sub
	   Sub ArticleList()
						   Dim Sql,Param:Param=" where UserName='" & KSUser.UserName & "'"
						   IF KS.S("Status")<>"" Then Param= Param & " and status=" & KS.ChkClng(KS.S("Status"))-1
                           If (KS.S("KeyWord")<>"") Then Param = Param  & " and title like '%" & KS.S("KeyWord") & "%'"
						   sql = "select * from KS_EnterPriseNews " & Param & " order by id desc"
								  %>
                                     <div class="writeblog"><img src="images/m_list_22.gif" align="absmiddle"><a href="?Action=Add">发布新闻</a></div>
				                     <table width="100%"  border="0" align="center" cellpadding="1" cellspacing="1" class="border">
                                        <tr class="title">
                                                  <td width="6%" height="22" align="center">选中</td>
                                                  <td width="41%" height="22" align="center">新闻标题</td>
                                                  <td width="15%" height="22" align="center"> 分 类</td>
												  <td width="16%" height="22" align="center">更新时间</td>
												  <td width="10%" height="22" align="center">状态</td>
                                                  <td height="22" align="center" nowrap>管理操作</td>
                                        </tr>
                                           
                                      <%
							Set RS=Server.CreateObject("AdodB.Recordset")
							RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>没有你要的新闻!</td></tr>"
								 Else
									totalPut = RS.RecordCount
								   If CurrentPage > 1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
									End If
								   Call showContent
				End If
     %>                      
                        </table>			

		  <%
  End Sub
  
  Sub ShowContent()
     Dim I
    Response.Write "<FORM Action=""?Action=Del"" name=""myform"" method=""post"">"
   Do While Not RS.Eof
         %>
                   <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
                        <td class='splittd' width="5%" height="23" align="center">
						  <INPUT id="ID" onClick="unselectall()" type="checkbox" value="<%=RS("ID")%>"  name="ID">
						</td>
                        <td class='splittd' align="left"><a href="?Action=Edit&id=<%=rs("id")%>" class="link3"><%=KS.GotTopic(trim(RS("title")),45)%></a></td>
                        <td class='splittd' align="center">
						<%
						If RS("ClassID")=0 Then
						 Response.Write "没有指定分类"
						Else
						 on error resume next
						 Response.Write conn.execute("select classname from ks_userclass where classid=" & RS("ClassID"))(0)
						End If
						%></td>
                        <td class='splittd' align="center"><%=formatdatetime(rs("AddDate"),2)%></td>
                        <td class='splittd' align="center"><%
						if rs("status")=1 then
						 response.write "已审核"
						else
						 response.write "<font color=red>未审核</font>"
						end if
						%></td>
                        <td class='splittd' align="center">
						<a href="?id=<%=rs("id")%>&Action=Edit&&page=<%=CurrentPage%>" class="link3">修改</a> <a href="?action=Del&ID=<%=rs("id")%>" onclick = "return (confirm('确定删除新闻吗?'))" class="link3">删除</a>
										
						</td>
                     </tr>
                                      <%
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
								<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
								  <td colspan=2 valign=top>&nbsp;&nbsp<label><INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">选中所有</label>&nbsp;<button class="pn pnc" onClick="return(confirm('确定删除选中的新闻吗?'));" type=submit><strong>删除选定</strong></button></FORM> 
								</td>
								<td  colspan="4" align="right"><%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%></td>
								</tr>
								<tr>
								<td colspan="4"> 
								     
								<form action="User_EnterPriseNews.asp" method="post" name="searchform">  <strong>新闻搜索：</strong>  关键字<input type="text" name="KeyWord" class="textbox" value="关键字" onfocus="if(this.value=='关键字'){this.value=''}" size=20>&nbsp;<input class="button" type="submit" name="submit1" value=" 搜 索 "> </form>
								  </td>
								  
								</tr>
								<% 
  End Sub
  '删除文章
  Sub ArticleDel()
	Dim ID:ID=KS.S("ID")
	ID=KS.FilterIDs(ID)
	If ID="" Then Call KS.Alert("你没有选中要删除的新闻!",ComeUrl):Response.End
	Conn.Execute("Delete From KS_EnterPriseNews Where UserName='" & KSUser.UserName & "' and ID In(" & ID & ")")
	if ComeUrl="" then
	Response.Redirect("../index.asp")
	else
	Response.Redirect ComeUrl
	end if
  End Sub

  '添加文章
  Sub ArticleAdd()
        Call KSUser.InnerLocation("发布新闻")
		
		   If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(39))  And KS.ChkClng(KS.SSetting(39))>0 Then  '判断有没有到达积分要求
				KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(39)) &"</font> 分才可以发布企业新闻，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
			End If  
		
  		if KS.S("Action")="Edit" Then
		  Dim KS_A_RS_Obj:Set KS_A_RS_Obj=Server.CreateObject("ADODB.RECORDSET")
		   KS_A_RS_Obj.Open "Select top 1 * From KS_EnterPriseNews Where ID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If Not KS_A_RS_Obj.Eof Then
			 Title    = KS_A_RS_Obj("Title")
			 Content  = KS_A_RS_Obj("Content")
			 AddDate  = KS_A_RS_Obj("AddDate")
			 ClassID  = KS_A_RS_Obj("ClassID")
		   End If
		   KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		Else
		   AddDate=Now:ClassID=0
		End If
		%>
		<script language = "JavaScript">
				function CheckForm()
				{	
				if (document.myform.Title.value=="")
				  {
					$.dialog.alert("请输入新闻标题！",function(){
					document.myform.Title.focus();
					});
					return false;
				  }	
		
				    if (CKEDITOR.instances.Content.getData()=="")
					{
					  $.dialog.alert("新闻内容不能留空！",function(){
					  CKEDITOR.instances.Content.focus();});
					  return false;
					}
				 return true;  
				}
				</script>
				
				
				<table  width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="?Action=DoSave&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr  class="title">
					  <td colspan=2 align=center>
					       <%IF KS.S("Action")="Edit" Then
							   response.write "修改新闻"
							   Else
							    response.write "发布新闻"
							   End iF
							  %> 
					 </td>
					</tr>
                    <tr class="tdbg">
                       <td width="12%"  height="25" align="center"><span>新闻标题：</span></td>
                       <td width="88%"><input class="textbox" name="Title" type="text" id="Title" style="width:250px; " value="<%=Title%>" maxlength="100" />
                                        <span style="color: #FF0000">*</span> </td>
                    </tr>
					<tr class="tdbg">
                       <td width="12%"  height="25" align="center"><span>选择分类：</span></td>
                       <td colspan="2"><select class="select" size='1' name='ClassID' style="width:150">
                                            <option value="0">-不指定分类-</option>
                                            <%=KSUser.UserClassOption(4,ClassID)%>
                         </select>		
				
						 <a href="User_Class.asp?Action=Add&typeid=4"><font color="red">添加我的分类</font></a>					  </td>
                    </tr>
						  
                     <tr class="tdbg">
                                <td align="center">发布时间：</td>
                                <td><input class="textbox" readonly name="AddDate" type="text" style="width:250px; " value="<%=AddDate%>" maxlength="100" /></td>
                              </tr>
                              <tr class="tdbg">
                                  <td align="center">新闻内容：</td>
								  <td>
							<%	
								Response.Write "<textarea name=""Content"" style=""display:none"">" & KS.HtmlCode(Content) & "</textarea>"
							%>	
							<script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
							<script type="text/javascript">
						CKEDITOR.replace('Content', {width:"98%",height:"300px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
						</script> 
							</td>
                            </tr>
                    <tr class="tdbg">
					  <td></td>
                      <td height="30">
					   <button id="submit1" type="submit" class="pn"><strong>OK, 保 存</strong></button>
					 </td>
                    </tr>
                  </form>
			    </table>
		  <%
  End Sub
  
   Sub DoSave()
            If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(39))  And KS.ChkClng(KS.SSetting(39))>0 Then  '判断有没有到达积分要求
				KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(39)) &"</font> 分才可以发布企业新闻，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
			End If  
			   
      Dim Id:Id=KS.ChkClng(Request("ID"))
				 Title=KS.LoseHtml(KS.S("Title"))
				 Content=KS.HtmlEncode(Request.Form("Content"))
				  Dim RSObj
				  
				  If Title="" Then
				    Response.Write "<script>$.dialog.tips('你没有输入新闻标题!',1,'error.gif',function(){history.back();});</script>"
				    Exit Sub
				  End IF
				  If Content="" Then
				    Response.Write "<script>$.dialog.tips('你没有输入新闻内容!',1,'error.gif',function(){history.back();});</script>"
				    Exit Sub
				  End IF
				  
				'读企业信息
				Set RSObj=Server.CreateObject("Adodb.Recordset")
				RSObj.Open "select top 1 a.*,b.[Domain] From KS_Enterprise a inner join KS_Blog B On a.username=b.UserName Where a.UserName='" & KSUser.UserName & "'",conn,1,1
				If RSObj.Eof And RSObj.Bof Then
				  RSObj.Close:Set RS=Nothing
				  KS.AlertHIntScript "对不起，您没有开通企业空间!"
				End If
				Dim SmallClassID,BigClassID,Domain
				SmallClassID=RSobj("SmallClassID")
				BigClassID=RSObj("ClassID")
				Domain=RSObj("Domain")
				RSObj.Close
				  
				RSObj.Open "Select top 1 * From KS_EnterpriseNews Where UserName='" & KSUser.UserName & "' and ID=" & Id,Conn,1,3
				If rsobj.eof then
				  RSObj.Addnew
				  RSObj("UserName")=KSUser.UserName
				  RSObj("Adddate")=Now
				  If KS.SSetting(18)=1 Then
				  RSObj("Status")=0
				  Else
				  RSObj("Status")=1
				  End If
				 End If
				  RSObj("Title")=Title
				  RSObj("Content")=Content
				  RSObj("ClassID")=KS.ChkClng(KS.S("ClassID"))
				  RSObj("SmallClassID")=SmallClassID
				  RSObj("BigClassID")=BigClassID
				  RSObj("UserID")=KSUser.GetUserInfo("UserID")
				  RSObj("Domain")=Domain
				 RSObj.Update
				 RSObj.MoveLast
				 Id=RSObj("ID")
				 RSObj.Close:Set RSObj=Nothing
				 IF KS.ChkClng(KS.S("id"))=0 Then
				   Call KSUser.AddToWeibo(KSUser.UserName,"[url={$GetSiteUrl}space/?" & KSUser.GetUserInfo("userid") & "/shownews/" & id & "]" & left(Title,30) & "[/url][br]"& left(KS.LoseHTML(Request.Form("Content")&""),130) &"...",7)
				   Response.Write "<script>$.dialog.confirm('成功添加新闻，继续添加吗?',function(){location.href='?Action=Add';},function(){location.href='User_EnterPriseNews.asp';});</script>"
				 Else
				 Response.Write "<script>$.dialog.tips('恭喜，新闻修改成功!',1,'success.gif',function(){location.href='User_EnterpriseNews.asp';});</script>"
				 End If
  End Sub
End Class
%> 
