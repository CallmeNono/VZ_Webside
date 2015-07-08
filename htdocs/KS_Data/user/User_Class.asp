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
Set KSCls = New User_Class
KSCls.Kesion()
Set KSCls = Nothing

Class User_Class
        Private KS,KSUser
		Private CurrentPage,totalPut,RS,MaxPerPage
		Private Descript,OrderID
		Private ComeUrl
		Private TypeID,ClassName,KeyWords,Author,Origin,Content,Verific,PicUrl,Action,I,UserDefineFieldArr,UserDefineFieldValueStr
		Private Sub Class_Initialize()
			MaxPerPage =15
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
		Call KSUser.InnerLocation("我的所有专栏目")
		KSUser.CheckPowerAndDie("s07")
		%>
		<div class="tabs">	
			<ul>
	        <li class="puton">我的专栏</li>
			<span>总数[<font color="red"><%=conn.execute("select count(classid) from ks_userclass where username='"& KSUser.UserName &"'")(0)%></font>]
</span>
			</ul>
		</div>						  
			<div class="writeblog"><img src="images/icon7.png" align="absmiddle"><a href="User_Class.asp?Action=Add">增加专栏</a></div>
      
		<%
		Select Case KS.S("Action")
		 Case "View"
		  Call ReadRss()
		 Case "Del"
		  Call ClassDel()
		 Case "Add","Edit"
		  Call ClassAdd()
		 Case "AddSave"
		  Call AddSave()
		 Case "EditSave"
		  Call EditSave()
		 Case Else
		  Call ClassList()
		End Select
	   End Sub
	   Sub ClassList()
			   		       If KS.S("page") <> "" Then
						          CurrentPage = KS.ChkClng(KS.S("page"))
							Else
								  CurrentPage = 1
							End If
                                    
									Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
									Dim Sql:sql = "select * from KS_UserClass "& Param &" order by AddDate DESC"

								    
								  %>
								     
				                     <table width="100%"  border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                                                <tr class="title">
                                                  <td width="8%" height="25" align="center">类型</td>
                                                  <td width="41%" height="25" align="center">专栏名称</td>
												  <td width="12%" height="25" align="center">归属者</td>
                                                  <td width="12%" height="25" align="center">创建时间</td>
                                                  <td width="21%" height="25" align="center" nowrap>管理操作</td>
                                                </tr>
                                           
                                      <%
									Set RS=Server.CreateObject("AdodB.Recordset")
									RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>你没有添加专栏目!</td></tr>"
								 Else
									totalPut = RS.RecordCount
						
											If CurrentPage < 1 Then
												CurrentPage = 1
											End If
			
								If (CurrentPage - 1) * MaxPerPage > totalPut Then
									If (totalPut Mod MaxPerPage) = 0 Then
										CurrentPage = totalPut \ MaxPerPage
									Else
										CurrentPage = totalPut \ MaxPerPage + 1
									End If
								End If
			
								If CurrentPage = 1 Then
									Call showContent
								Else
									If (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
										Call showContent
									Else
										CurrentPage = 1
										Call showContent
									End If
								End If
				End If
     %>                     
                        </table>
						<br>
						<div>&nbsp;&nbsp;&nbsp;<font color=red>专栏作用：建立专栏可以给自己发表的日志、RSS订阅、相片等归类</font></div>
		  <%
  End Sub
  
  Sub ShowContent()
     Dim I
    Response.Write "<FORM Action=""User_Class.asp?Action=Del"" name=""myform"" method=""post"">"
   Do While Not RS.Eof
         %>
                                          <tr>
                                            <td class='splittd' width="10%" height="25" align="center">
											 <% Select Case rs("typeid")
											     case 1 response.write "RSS订阅"
												 case 2 Response.write "日志分类"
												 case 3 response.write "产品分类"
												 case 4 response.write "新闻分类"
												 end select
											%>
											  </td>                                           
										 <td class='splittd' width="35%" height="25" align="left"><%=KS.GotTopic(trim(RS("ClassName")),35)%></td>
											<td class='splittd' width="10%" height="25" align="center"><%=rs("UserName")%></td>
                                            <td class='splittd' width="18%" height="25" align="center"><%=formatdatetime(rs("AddDate"),2)%></td>
                                            <td class='splittd' height="25" align="center">
											<a href="User_Class.asp?id=<%=rs("ClassID")%>&Action=Edit&&page=<%=CurrentPage%>" class="box">修改</a> <a href="User_Class.asp?action=Del&TypeID=<%=RS("TypeID")%>&ID=<%=rs("ClassID")%>" onclick = "return (confirm('归属该专栏的信息也将被删除，确定删除吗?'))" class="box">删除</a>
											</td>
                                          </tr>
                  
                                      <%
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
								<% 
  End Sub
  '删除专栏
  Sub ClassDel()
	Dim ID:ID=KS.S("ID")
	If ID="" Then Call KS.Alert("你没有选中要删除的专栏!",ComeUrl):Response.End
	Select Case KS.ChkClng(KS.S("TypeID"))
	 Case 1
	  Conn.Execute("Delete From KS_RssUrl Where ClassID=" & KS.ChkClng(ID))
	 Case 2
	  Conn.Execute("Delete From KS_BlogInfo Where ClassID=" & KS.ChkClng(ID))
	End Select
	Conn.Execute("Delete From KS_UserClass Where ClassID In(" & KS.FilterIDs(ID) & ")")
	Response.Redirect ComeUrl
  End Sub
  '添加专栏
  Sub ClassAdd()
        Call KSUser.InnerLocation("增加专栏")
  		if KS.S("Action")="Edit" Then
		  Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		   RS.Open "Select * From KS_UserClass Where ClassID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If Not RS.Eof Then
		     TypeID  = RS("TypeID")
			 ClassName    = RS("ClassName")
			 Descript = RS("Descript")
			 OrderID   = RS("OrderID")
		   End If
		   RS.Close:Set RS=Nothing
		   Action="EditSave"
		Else
		  TypeID=0:Action="AddSave":TypeID=KS.S("TypeID")
		End If
		%>
		<script language = "JavaScript">
				function CheckForm()
				{
				if (document.myform.TypeID.value=="0") 
				  {
					$.dialog.alert("请选择类型！",function(){
					document.myform.TypeID.focus();
					});
					return false;
				  }		
				if (document.myform.ClassName.value=="")
				  {
					$.dialog.alert("请输入专栏名称！",function(){
					document.myform.ClassName.focus();
					});
					return false;
				  }		
				if (document.myform.OrderID.value=='')
					{
					$.dialog.alert("请输入专栏系号！",function(){
					document.myform.OrderID.focus();
					});
					return false;
					}
				if (document.myform.OrderID.value>10000)
					{
					$.dialog.alert("专栏系号必须小于等于10000！",function(){
					document.myform.OrderID.focus();
					});
					return false;
					}
				 return true;  
				}
				</script>
				
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="User_Class.asp?Action=<%=Action%>&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr class="title">
					  <td colspan=2 align=center> 创 建 专 栏</td>
					</tr>
                    <tr class="tdbg">
                       <td class="clefttitle" width="80">选择类型：</td>
                       <td><select class="select" size='1' name='TypeID' style="width:250px">
                                            <option value="0">-请选择类型-</option>
											<option value="2"<%if typeid="2" then response.write " selected"%>>-日志分类-</option>
											<option value="3"<%if typeid="3" then response.write " selected"%>>-企业产品分类-</option>
											<option value="4"<%if typeid="4" then response.write " selected"%>>-企业新闻分类-</option>
                                        </select>	<span class="msgtips">一旦选择，不能修改</span> </td>
                     </tr>
                     <tr class="tdbg">
					    <td  class="clefttitle">专栏名称：</td>
                        <td><input class="textbox"  name="ClassName" type="text" id="ClassName" style="width:250px; " value="<%=ClassName%>" maxlength="100" /></td>
                       </tr>
                     <tr class="tdbg">
                                      <td  class="clefttitle">专栏序号：</td>
                                      <td><input class="textbox"  name="OrderID" type="text" id="OrderID" style="width:250px; " value="<%=OrderID%>" maxlength="100" /></td>
                              </tr>
                              <tr class="tdbg">
                                      <td class="clefttitle"><span>专栏描述：</span></td>
                                      <td><textarea class="textbox" name="Descript" style="width:90%;height:80px" id="Descript" cols=70 rows=6 ><%=descript%></textarea></td>
                              </tr>
								
                    <tr class="tdbg">
					  <td></td>
                      <td height="30">
					   <button type="submit" name="Submit" class="pn"><strong> OK,保 存 </strong></button>
                      </td>
                    </tr>
                  </form>
			    </table>
		  <%
  End Sub
  
   Sub EditSave()
                 TypeID=KS.S("TypeID")
				 ClassName=Trim(KS.S("ClassName"))
				 OrderID=Trim(KS.S("OrderID"))
				 Descript=Trim(KS.S("Descript"))			
				  if TypeID="" Then TypeID=0
				  If ClassName="" Then
				    Response.Write "<script>alert('你没有输入标题!');history.back();</script>"
				    Exit Sub
				  End IF
				  If OrderID="" Then
				    Response.Write "<script>alert('你没有输入栏目序号!');history.back();</script>"
				    Exit Sub
				  End IF
				  If Not Isnumeric(OrderID) Then
				    Response.Write "<script>alert('栏目序号只能填写数字!');history.back();</script>"
				    Exit Sub
				  End IF
				
				  Dim RSObj:Set RSObj=Server.CreateObject("Adodb.Recordset")
				RSObj.Open "Select * From KS_UserClass Where ClassID=" & KS.ChkClng(KS.S("ID")),Conn,1,3
				  RSObj("ClassName")=ClassName
				 ' RSObj("TypeID")=TypeID
				  RSObj("OrderID")=OrderID
				  RSObj("Descript")=Descript
				RSObj.Update
				 RSObj.Close:Set RSObj=Nothing
				 Response.Write "<script>alert('专栏修改成功!');location.href='User_Class.asp';</script>"
  End Sub
  
  Sub AddSave()
                 TypeID=KS.S("TypeID")
				 ClassName=Trim(KS.S("ClassName"))
				 OrderID=Trim(KS.S("OrderID"))
				 Descript=Trim(KS.S("Descript"))			
				 Dim RSObj
				  if TypeID="" Then TypeID=0
				  If TypeID=0 Then
				    Response.Write "<script>alert('你没有选择类型!');history.back();</script>"
				    Exit Sub
				  End IF
				  If ClassName="" Then
				    Response.Write "<script>alert('你没有输入标题!');history.back();</script>"
				    Exit Sub
				  End IF
				  If OrderID="" Then
				    Response.Write "<script>alert('你没有输入栏目序号!');history.back();</script>"
				    Exit Sub
				  End IF
				  If Not Isnumeric(OrderID) Then
				    Response.Write "<script>alert('栏目序号只能填写数字!');history.back();</script>"
				    Exit Sub
				  End IF
				Set RSObj=Server.CreateObject("Adodb.Recordset")
				RSObj.Open "Select * From KS_UserClass",Conn,1,3
				RSObj.AddNew
				  RSObj("ClassName")=ClassName
				  RSObj("TypeID")=TypeID
				  RSObj("OrderID")=OrderID
				  RSObj("Descript")=Descript
				  RSObj("UserName")=KSUser.UserName
				  RSObj("Adddate")=Now
				RSObj.Update
				 RSObj.Close:Set RSObj=Nothing
				 Response.Write "<script>if (confirm('添加专栏成功，继续添加吗?')){location.href='User_Class.asp?Action=Add&typeid=" & TypeID&"';}else{location.href='User_Class.asp';}</script>"
  End Sub

End Class
%> 
