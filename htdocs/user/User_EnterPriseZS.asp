<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.UpFileCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New EnterPriseZSCls
KSCls.Kesion()
Set KSCls = Nothing

Class EnterPriseZSCls
        Private KS,KSUser
		Private totalPut,RS,MaxPerPage
		Private ComeUrl,Selbutton,Verific,PhotoUrl,bigclassid,smallclassid,flag
		Private F_B_Arr,F_V_Arr,ClassID,Title,Sxrq,Fzjg,Jzrq,Intro,Action,I
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
		Call KSUser.InnerLocation("所有荣誉证书列表")
		KSUser.CheckPowerAndDie("s13")
	
		If KS.SSetting(0)=0 Then
		  KS.Die "<script>$.dialog.tips('对不起，本站关闭空间门户功能！',1,'error.gif',function(){location.href='index.asp';});</script>"
		 Exit Sub
		ElseIf Conn.Execute("Select Count(username) From KS_Blog Where UserName='" & KSUser.UserName & "'").eof Then
		    Response.Write "<script>$.dialog.tips('您还没有开通空间,按确定转向开通页面！',1,'error.gif',function(){location.href='User_Enterprise.asp';});</script>"
		End If

		%>
		<div class="tabs">	
			<ul>
				<li<%If KS.S("Status")="" then response.write " class='puton'"%>><a href="?">我的荣誉证书(<span class="red"><%=conn.execute("select count(id) from ks_EnterPriseZS where username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="2" then response.write " class='puton'"%>><a href="?Status=2">已审核(<span class="red"><%=conn.execute("select count(id) from ks_EnterPriseZS where status=1 and username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="1" then response.write " class='puton'"%>><a href="?Status=1">待审核(<span class="red"><%=conn.execute("select count(id) from ks_EnterPriseZS where status=0 and username='"& KSUser.UserName &"'")(0)%></span>)</a></li>
			</ul>
       </div>
		<%
		Select Case KS.S("Action")
		 Case "Del"  Call ArticleDel()
		 Case "Add","Edit" Call DoAdd()
		 Case "DoSave" Call DoSave()
		 Case Else Call ProductList()
		End Select
	   End Sub
	   Sub ProductList()
									Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
                                    Verific=KS.S("Status")
                                    IF Verific<>"" Then 
									   Param= Param & " and status=" & KS.ChkClng(Verific)-1
									End If
									IF KS.S("Flag")<>"" Then
									  IF KS.S("Flag")=0 Then Param=Param & " And Title like '%" & KS.S("KeyWord") & "%'"
									  IF KS.S("Flag")=1 Then Param=Param & " And Sxrq like '%" & KS.S("KeyWord") & "%'"
									End if
									Dim Sql:sql = "select * from KS_EnterPriseZS " & Param &" order by AddDate DESC"

								  
								  %>
								  <div class="writeblog"><img src="images/m_list_22.gif" align="absmiddle"><a href="?Action=Add"><font color=red>发布荣誉证书</font></a></div>
    <script src="../ks_inc/jquery.imagePreview.1.0.js"></script>
				                     <table width="98%"  border="0" align="center" cellpadding="1" cellspacing="1">
                                                <tr class="title">
                                                  <td colspan="6" height="22">
												  <%if KS.S("Status")="1" Then
												     response.write "待审核荣誉证书"
													 elseif ks.s("status")="2" then
													 response.write "已审核荣誉证书"
													 else
													 response.write "所有荣誉证书列表"
													 end if
												  %>
												  </td>
                                                </tr>
                                           
                                      <%
								 Set RS=Server.CreateObject("AdodB.Recordset")
								 RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>找不到任何荣誉证书!</td></tr>"
								 Else
									totalPut = RS.RecordCount
			
									If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
												RS.Move (CurrentPage - 1) * MaxPerPage
									End If
									Call showContent
				End If
     %>               
	   <tr>
	     <td colspan=6>
		  <table border='0'>
		   <tr>
		    <td width="340" height="30">
			 <label><INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">选中所有荣誉证书</label>&nbsp;
			 <button id="button1" onclick="return(confirm('确定删除选中的荣誉证书吗?'));" type="submit" class="pn pnc"><strong>删除选中</strong></button>
			</form>
			</td>
			
			</tr>
		   </table>
		   <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
		 </td>
	   </tr>
	 </table>
	 <table width="100%" border="0" cellpadding="0" cellspacing="0">
	 <form action="?" method="post" name="searchform">
	        <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
                <td height="45" width="100"><strong>荣誉证书搜索：</strong></td>
				<td align="left" width="120"><select class="select" name="Flag">
										   <option value="0">荣誉证书名称</option>
										   <option value="1">生效日期</option>
									      </select></td>
		        <td width="80" align="center">关键字</td><td align="left"><input type="text" name="KeyWord" onfocus="if(this.value=='关键字'){this.value=''}" class="textbox" value="关键字" size=20>&nbsp;<input class="button" type="submit" name="submit1" value=" 搜 索 ">
		      </td>
       </form>
                                </tr>
                        </table>
		  <%
  End Sub
  
  Sub ShowContent()
    Response.Write "<FORM Action=""?Action=Del"" name=""myform"" method=""post"">"
   
	%>
	   <style type="text/css">
	   	.onmouseover { background: #fffff0; }
		.onmouseout {}
		.zslist ul {float:left;margin:6px;padding:5px;width:152px!important;width:165px;height:180px;overflow:hidden;border: 1px #f4f4f4 solid;background: #fcfcfc;}
		.zslist ul li {
		list-style-type:none;line-height:1.5;margin:0;padding:0;}
		.zslist ul li.l1 img {width:150px;height:90px;}
		.zslist ul li.l1 a {display:block;margin:auto;padding:1px;width:156px;height:96px;background:url("images/tbg.png") no-repeat left top;text-align:left;}
		.zslist ul li.l2 {margin: 3px 0 0 0; width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
		.zslist ul li.l3 {margin: 3px 0 0 0; width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
		.zslist ul li.l4 {margin:10px 0 0 0;text-align:center;}
	   </style>
	   <%
	     dim i,k
	     do while not rs.eof
		   response.write "<tr>"
		   for i=1 to 4
		    response.write "<td width=""25%"" class=""zslist"">"
			 dim pic:pic=rs("photourl")
			 if pic="" or isnull(pic) then pic="../images/nopic.gif"
			%>
			<ul onMouseOver="this.className='onmouseover'" onMouseOut="this.className='onmouseout'" class="onmouseout">
				<li class="l1"><a href='<%=pic%>' title="<%=rs("Title")%>" class='preview' target="_blank"><img src="<%=pic%>"  border="0" /></a></li>
				<li class="l2">证书名称：<strong><%=rs("Title")%></strong></li>
				<li class="l3">发证机关：<%=rs("fzjg")%></li>
				<li class="l4"><INPUT id="ID"  type="checkbox" value="<%=RS("ID")%>"  name="ID">
				<a href="?action=Edit&id=<%=RS("ID")%>">修改</a> | <a href="?Action=Del&ID=<%=RS("ID")%>" onClick="return(confirm('确定删除证书吗?'));">删除</a>
				</li>									
			</ul>
			<%
			response.write "</td>"
			rs.movenext
			k=k+1
			if rs.eof or k>=MaxPerPage then exit for 
		   next
		   for i=k+1 to 4
		    response.write "<td width=""25%"">&nbsp;</td>"
		   next
		  response.write "</tr>"
		  if rs.eof or k>=MaxPerPage then exit do
		 loop

  End Sub
  '删除文章
  Sub ArticleDel()
	Dim ID:ID=KS.S("ID")
	ID=KS.FilterIDs(ID)
	If ID="" Then Call KS.Alert("你没有选中要删除的荣誉证书!",ComeUrl):Response.End
	Conn.Execute("Delete From KS_EnterPriseZS Where UserName='" & KSUser.UserName & "' And ID In(" & ID & ")")
	Conn.Execute("Delete From KS_UploadFiles Where UserName='" & KSUser.UserName & "' and channelid=1039 and infoid in(" & ID & ")")
	if ComeUrl="" then
	Response.Redirect("../index.asp")
	else
	Response.Redirect ComeUrl
	end if
  End Sub

  '添加文章
  Sub DoAdd()
        Call KSUser.InnerLocation("发布证书")
			If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(40))  And KS.ChkClng(KS.SSetting(40))>0 Then  '判断有没有到达积分要求
				KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(40)) &"</font> 分才可以上传企业荣誉证书，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
			End If  

  		if KS.S("Action")="Edit" Then
		  Dim RSObj:Set RSObj=Server.CreateObject("ADODB.RECORDSET")
		   RSObj.Open "Select top 1 * From KS_EnterPriseZS Where UserName='" & KSUser.UserName &"' and ID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If Not RSObj.Eof Then
			 Title    = RSObj("Title")
			 Fzjg = RSObj("Fzjg")
			 Jzrq   = RSObj("Jzrq")
			 Sxrq  = RSObj("Sxrq")
			 PhotoUrl  = RSObj("PhotoUrl")
			 If PhotoUrl="" Or IsNull(PhotoUrl) Then PhotoUrl="/Images/Nopic.gif"
			 flag=true
		   End If
		   RSObj.Close:Set RSObj=Nothing
		Else
		 PhotoUrl="/images/Nopic.gif"
		 ClassID=KS.S("ClassID")
		 If ClassID="" Then ClassID="0"
		 flag=false
		End If
		%>
		<script language="javascript" src="../ks_inc/popcalendar.js"></script>
		<script language = "JavaScript">
				function CheckForm()
				{
				if (document.myform.Title.value=="")
				  {
					$.dialog.alert("请输入荣誉证书名称！",function(){
					document.myform.Title.focus();
					});
					return false;
				  }	
				if (document.myform.Fzjg.value=="")
				  {
					$.dialog.alert("请输入发证机构！",function(){
					document.myform.Fzjg.focus();});
					return false;
				  }	
				if (document.myform.Sxrq.value=="")
				  {
					$.dialog.alert("请输入生效日期！",function(){
					document.myform.Sxrq.focus();});
					return false;
				  }	
				if (document.myform.Jzrq.value=="")
				  {
					$.dialog.alert("请输入截止日期！",function(){
					document.myform.Jzrq.focus();});
					return false;
				  }	
				    
				 return true;  
				}
				</script>
				
				
				<table  width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="?Action=DoSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();" enctype="multipart/form-data">
				   <input type="hidden" value="<%=KS.S("ID")%>" name="id">
				    <tr  class="title">
					  <td colspan=3 align=center>
					       <%IF KS.S("Action")="Edit" Then
							   response.write "修改荣誉证书"
							   Else
							    response.write "发布荣誉证书"
							   End iF
							  %>  </td>
					</tr>
                    
                      <tr class="tdbg">
                           <td width="12%"  height="25" align="center"><span>证书名称：</span></td>
                           <td width="52%"> <input class="textbox" name="Title" type="text" id="Title" style="width:250px; " value="<%=Title%>" maxlength="100" />
                                          <span style="color: #FF0000">*</span><br/> <span class="msgtips">如：营业执照，税务登记证，专利证等</span></td>
                              <td width="36%" rowspan="4" align="center">
							  <div style="width:140px;height:142px;background:url(images/bg_head.gif)">
							  <img src="<%=photourl%>" width="133" height="134" border="1">					
							  </div>		  </td>
                      </tr>
					 
                      <tr class="tdbg">
                                      <td align="center"><span>发证机构：</span></td>
                                      <td><input name="Fzjg" class="textbox" type="text" style="width:250px; " value="<%=Fzjg%>" maxlength="30" />
                                        <span style="color: #FF0000">*</span><br/>
										<span class="msgtips">请填写发证机构所注明的发证机构</span>
										</td>
                              </tr>
			  
                              <tr class="tdbg">
                                <td height="25" align="center">生效日期：</td>
                                <td height="25"><input name="Sxrq" class="textbox" type="text" id="Sxrq" onClick="popUpCalendar(this, document.all.Sxrq, dateFormat,-1,-1)" style="width:250px; " value="<%=Sxrq%>" maxlength="30" />
<span style="color: #FF0000">*</span><br/><span class="msgtips">格式：年-月-日</span></td>
                              </tr>
                              <tr class="tdbg">
                                      <td align="center"><span>截止日期：</span></td>
                                      <td><input name="Jzrq" class="textbox" type="text" id="Jzrq" onClick="popUpCalendar(this, document.all.Jzrq, dateFormat,-1,-1)"  style="width:250px; " value="<%=Jzrq%>" maxlength="30" />
                                        <span style="color: #FF0000">*</span><br/><span class="msgtips">格式：年-月-日</span></td>
                              </tr>
                      <tr class="tdbg">
                           <td  height="25" align="center"><span>证书照片：</span></td>
                        <td><input type="file" class="textbox" name="photourl" size="40">
                          <span style="color: #FF0000">*</span> <br><span class="msgtips">说明：只支持JPG、GIF、PNG格式图片，不超过500K</span></td>
                      </tr>
                        
                             
			  
                    <tr class="tdbg">
					  <td></td>
                      <td height="30"  colspan=2>
					   <button id="button1"  type="submit" class="pn"><strong>OK, 保 存</strong></button>
					 </td>
                    </tr>
                  </form>
			    </table>
		        <br>
		        <table  width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <TR class="title">
                    <TD  height="24" style="padding-left:15px;">注意事项：</TD>
                  </TR>
                  <TR>
                    <TD bgColor="#ffffff" height="26"><TABLE cellSpacing="0" cellPadding="0" width="100%" border="0">
                          <TR>
                            <TD height="21">请不要重复发布内容相同的证书，其它内容相同的证书将拒绝审核！ </TD>
                          </TR>
                          <TR>
                            <TD height="21">请确保您的证书的准确性，合法性，否则后果自负，<%=KS.Setting(1)%>不承担任何责任。</TD>
                          </TR>
                          <TR>
                            <TD height="21">尽可能的完善您的证书信息。</TD>
                          </TR>
                    </TABLE></TD>
                  </TR>
            </table>
		        <%
  End Sub
  
  Sub DoSave()
			If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(40))  And KS.ChkClng(KS.SSetting(40))>0 Then  '判断有没有到达积分要求
				KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(40)) &"</font> 分才可以上传企业荣誉证书，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
			End If  

            Dim fobj:Set FObj = New UpFileClass
			FObj.GetData
            Dim MaxFileSize:MaxFileSize = 500   '设定文件上传最大字节数
			Dim AllowFileExtStr:AllowFileExtStr = "gif|jpg|png"
			Dim FormPath:FormPath =KS.ReturnChannelUserUpFilesDir(9002,KSUser.GetUserInfo("UserID"))
			Call KS.CreateListFolder(FormPath) 
			

				 Title=KS.LoseHtml(Fobj.Form("Title"))
				  If Title="" Then
				    Response.Write "<script>$.dialog.tips('你没有输入荣誉证书名称!',1,'error.gif',function(){history.back();});</script>"
				    Exit Sub
				  End IF
				 
				 Fzjg=KS.DelSql(Fobj.Form("Fzjg"))
				 Jzrq=Fobj.Form("Jzrq")
				 Sxrq=Fobj.Form("Sxrq")
				 If Not IsDate(jzrq)  Or Not IsDate(Sxrq) Then Call KS.AlertHistory("日期不正确!",-1):response.End()
			
			Dim ReturnValue:ReturnValue = FObj.UpSave(FormPath,MaxFileSize,AllowFileExtStr,year(now)&month(now)&day(now)&hour(now)&minute(now)&second(now))
			Select Case ReturnValue
			  Case "errext" KS.Die "<script>$.dialog.tips('文件上传失败,文件类型不允许。允许的类型有" & AllowFileExtStr&"!',1,'error.gif',function(){history.back();});</script>"
			  
	          Case "errsize" KS.Die "<script>$.dialog.tips('文件上传失败,文件超过允许上传的大小。允许上传" & MaxFileSize & " KB的文件!',1,'error.gif',function(){history.back();});</script>"
			End Select
			If ReturnValue="" and KS.ChkClng(Fobj.Form("ID"))=0 Then KS.Die "<script>$.dialog.tips('您没有上传证书照片，请上传!',1,'error.gif',function(){history.back();});</script>"

				  
				Dim RSObj:Set RSObj=Server.CreateObject("Adodb.Recordset")
				RSObj.Open "Select * From KS_EnterPriseZS Where UserName='" & KSUser.UserName & "' and ID=" & KS.ChkClng(Fobj.Form("ID")),Conn,1,3
				If RSObj.Eof Then
				  RSObj.AddNew
				  If KS.SSetting(20)="1" Then
				  RSObj("Status")=0
				  Else
				  RSObj("Status")=1
				  End If
				  RSObj("Adddate")=Now
				 End If
				  RSObj("UserName")=KSUser.UserName
				  RSObj("Title")=Title
				  RSObj("Fzjg")=Fzjg
				  RSObj("Jzrq")=Jzrq
				  RSObj("Sxrq")=Sxrq
				  If ReturnValue<>"" then
				  RSObj("PhotoUrl")=ReturnValue
				  end if
				RSObj.Update
				 RSObj.MoveLast
				 Dim ZSUrl:ZSUrl=RSObj("PhotoUrl")
				 Call KS.FileAssociation(1039,RSObj("id"),ZSUrl ,1)
				 RSObj.Close:Set RSObj=Nothing
				 
               If KS.ChkClng(Fobj.Form("ID"))=0 Then
			     Set Fobj=Nothing
				 Dim LogStr:LogStr="[br][url=" & ZSUrl&"][img]" & ZSUrl &"[/img][/url]"
				 Call KSUser.AddToWeibo(KSUser.UserName,"上传了荣誉证书:" & Title & ",[url={$GetSiteUrl}user/weibo.asp?userid=" & KSUser.GetUserInfo("userid") &"]TA的微博[/url] [url={$GetSiteUrl}space/?" & KSUser.GetUserInfo("userid") &"]TA的空间[/url]" & logstr,8)
				 Response.Write "<script>$.dialog.confirm('荣誉证书发布成功，继续发布吗?',function(){location.href='?Action=Add';},function(){location.href='User_EnterPriseZS.asp';});</script>"
			   Else
			     Set Fobj=Nothing
				 Response.Write "<script>$.dialog.tips('恭喜,荣誉证书修改成功!',1,'success.gif',function(){location.href='User_EnterPriseZS.asp';});</script>"
			   End If
  End Sub
  
End Class
%> 
