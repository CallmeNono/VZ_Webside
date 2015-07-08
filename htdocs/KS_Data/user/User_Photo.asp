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
Set KSCls = New User_Photo
KSCls.Kesion()
Set KSCls = Nothing

Class User_Photo
        Private KS,KSUser
		Private CurrentPage,totalPut,RS,MaxPerPage
		Private ComeUrl,AddDate,Weather,PhotoUrls,descript
		Private XCID,Title,Tags,UserName,Face,Content,Status,PicUrl,Action,I,ClassID,password
		Private Sub Class_Initialize()
		  MaxPerPage =20
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
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		ElseIf KS.SSetting(0)=0 Then
		  KS.Die "<script>$.dialog.tips('对不起，本站关闭空间门户功能！',1,'error.gif',function(){location.href='index.asp';});</script>"
		 Exit Sub
		ElseIf Conn.Execute("Select Count(BlogID) From KS_Blog Where UserName='" & KSUser.UserName & "'")(0)=0 Then
		 response.Redirect("User_Blog.asp")
		 Exit Sub
		ElseIf Conn.Execute("Select top 1 status From KS_Blog Where UserName='" & KSUser.UserName & "'")(0)<>1 Then
		    Response.Write "<script>$.dialog.tips('对不起，你的空间还没有通过审核或被锁定！',1,'error.gif',function(){history.back();});</script>"
			response.end
		End If

		Call KSUser.SpaceHead()
		Call KSUser.InnerLocation("我的相册")
		KSUser.CheckPowerAndDie("s05")
		%>
		<div class="tabs">	
		   <ul>
				<li<%If KS.S("Status")="" then response.write " class='puton'"%>><a href="?">我的相册</a></li>
				<li<%If KS.S("Status")="1" then response.write " class='puton'"%>><a href="?Status=1">已审相册(<span class="red"><%=conn.execute("select count(id) from ks_photoxc where username='" & ksuser.username & "' and status=1")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="0" then response.write " class='puton'"%>><a href="?Status=0">待审相册(<span class="red"><%=conn.execute("select count(id) from ks_photoxc where username='" & ksuser.username & "' and status=0")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="2" then response.write " class='puton'"%>><a href="?Status=2">锁定相册(<span class="red"><%=conn.execute("select count(id) from ks_photoxc where username='" & ksuser.username & "' and status=2")(0)%></span>)</a></li>
			</ul>
        </div>
			 <div class="writeblog"><img src="images/tp.gif" align="absmiddle"> <a href="User_Photo.asp?Action=Add">上传照片</a>
			 
			 </div>

		<%

			Select Case KS.S("Action")
			 Case "Del"	  Call Delxc()
			 Case "Delzp"	  Call Delzp()
			 Case "Editzp"	  Call Editzp()
			 Case "Add"  	  Call Addzp()
			 Case "AddSave"	  Call AddSave()
			 Case "EditSave"  Call EditSave()
			 Case "ViewZP"    Call ViewZP()
			 Case "Editxc","Createxc"  Call Managexc()
			 Case "photoxcsave"	  Call photoxcsave()
			 Case Else  Call PhotoxcList()
			End Select
	   End Sub
	   '查看照片
	   Sub ViewZP()
	    Dim title
	    Dim xcid:xcid=KS.Chkclng(KS.S("XCID"))
	    Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "select top 1 xcname from KS_Photoxc WHERE ID=" & XCID,CONN,1,1
		if rs.Eof And RS.Bof Then 
		 rs.close:set rs=nothing
		 response.write "<script>alert('参数传递出错！');history.back();</script>"
		 response.end
		end if
		title=rs(0)
		rs.close
		Call KSUser.InnerLocation("查看照片")
	  			  %>
			   
	   		<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
            <tr class="title">
              <td align=center colspan=5><%=Title%></td>
            </tr>
			<%
			   		       If KS.S("page") <> "" Then
						          CurrentPage = KS.ChkClng(KS.S("page"))
							Else
								  CurrentPage = 1
							End If
			 rs.open "select * from KS_PhotoZP where xcid=" & xcid,conn,1,1
			if rs.eof and rs.bof then
			  response.write "<tr class='tdbg'><td  height='30' colspan='5'>该相册下没有相片，请<a href=""?action=Add&xcid=" & xcid &""">上传</a>！</td></tr>"
			else
			 				    MaxPerPage =5
								totalPut = RS.RecordCount
								If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
								End If
								Call showzplist(xcid)
        end if%>
      </table>
	  <div style="padding-right:30px">
	  <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
	  </div>
<%End Sub
sub showzplist(xcid)
%>
    <script type="text/javascript" src="../ks_inc/highslide/highslide.js"></script>
    <link href="../ks_inc/highslide/highslide.css" type=text/css rel=stylesheet>
	<script type="text/javascript">
		hs.graphicsDir = '/ks_inc/highslide/graphics/';
		hs.transitions = ['expand', 'crossfade'];
		hs.wrapperClassName = 'dark borderless floating-caption';
		hs.fadeInOut = true;
		hs.dimmingOpacity = .75;
		
		if (hs.addSlideshow) hs.addSlideshow({
			interval: 5000,
			repeat: false,
			useControls: true,
			fixedControls: 'fit',
			overlayOptions: {
				opacity: .6,
				position: 'bottom center',
				hideOnMouseOut: true
			}
		});
	</script>
<%
     Dim I
    Response.Write "<FORM Action=""?Action=Delzp"" name=""myform"" method=""post"">"
			 do while not rs.eof
			 %>
			<tr class="tdbg"> 
            
          </tr>
          <tr class="tdbg"> 
<td width="16%" rowspan="4">
			<table border="0" align="center" cellpadding="2" cellspacing="1" class="border">
                <tr> 
                  <td><a href="<%=rs("photourl")%>" class="highslide" onClick="return hs.expand(this)"  title="<%=rs("title")%>"><img src="<%=rs("photourl")%>" width="85" height="100" border="0"></a>
                  </td>
                </tr>
              </table></td>		  
            <td><div align="center">创建日期：</div></td>
            <td><%=rs("adddate")%></td>
            <td><div align="center">图片大小：</div></td>
            <td><%=rs("photosize")%>byte   </td>
          </tr>
          <tr class="tdbg"> 
            <td><div align="center">相片地址：</div></td>
            <td colspan="3"><%=rs("photourl")%></td>
          </tr>
          <tr class="tdbg"> 
            <td><div align="center">相片描述：</div></td>
            <td colspan="3"><%=rs("descript")%></td>
          </tr>
          <tr class="tdbg"> 
            <td><div align="center">浏览次数：</div></td>
            <td><%=rs("hits")%> 人次</td>
            <td colspan="2" height="28"><div align="center"><a href="?Action=Editzp&Id=<%=rs("id")%>" class="box">修改</a> <a href="?id=<%=rs("id")%>&Action=Delzp" onClick="{if(confirm('确定删除该照片吗？')){return true;}return false;}" class="box">删除</a> 
                <INPUT id="ID" onClick="unselectall()" type="checkbox" value="<%=RS("ID")%>"  name="ID">
              </div></td>
          </tr>
          <tr> 
            <td colspan="5" height="3" class="splittd">&nbsp;</td>
          </tr>
			<% rs.movenext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
			 loop
		 %>
		 <tr class="tdbg">
		   <td colspan="5" align="right">
		  								&nbsp;&nbsp;&nbsp;<INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中本页显示的所有照片&nbsp;<INPUT class="button" onClick="return(confirm('确定删除选中的照片吗?'));" type=submit value=删除选定的照片 name=submit1>  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        </td>
		 </tr>
		 </form>
		 <%
	   End Sub
	    '相册，添加／修改
	   Sub Managexc()
		
		If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(37))  And KS.ChkClng(KS.SSetting(37))>0 Then  '判断有没有到达积分要求
			KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(37)) &"</font> 分才可以发表上传照片，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
		End If   

	    Dim xcname,ClassID,Descript,PhotoUrl,PassWord,ListReplayNum,ListGuestNum,OpStr,TipStr,TemplateID,Flag,ListLogNum
		Dim ID:ID=KS.ChkCLng(KS.S("ID"))
	    Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		RS.Open "Select top 1 * From KS_Photoxc Where ID=" & ID,conn,1,1
		If Not RS.EOF Then
		Call KSUser.InnerLocation("修改相册")
		 xcname=RS("xcname")
		 ClassID=RS("ClassID")
		 Descript=RS("Descript")
		 flag=RS("Flag")
		 PhotoUrl=RS("PhotoUrl")
		 PassWord=RS("PassWord")
		 OpStr="OK了，确定修改":TipStr="修 改 我 的 相 册"
		Else
		 Call KSUser.InnerLocation("创建相册")
		 xcname=FormatDatetime(Now,2)
		 ClassID="0"
		 flag="1"
		 PhotoUrl=""
		 OpStr="OK了，立即创建":TipStr="创 建 我 的 相 册"
		End if
		RS.Close:Set RS=Nothing
	    %>
		<script>
		 function CheckForm()
		 {
		  if (document.myform.xcname.value=='')
		  {
		   $.dialog.alert('请输入相册名称!',function(){
		   document.myform.xcname.focus();
		   });
		   return false;
		  }
		  if (document.myform.ClassID.value=='0')
		  {
		   $.dialog.alert('请选择相册类型!',function(){
		   document.myform.ClassID.focus();
		   });
		   return false;
		  }
		  return true;
		 }

		</script>
		<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
          <form  action="User_Photo.asp?Action=photoxcsave&id=<%=id%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
            <tr class="title">
              <td colspan=2 align=center><%=TipStr%></td>
            </tr>
            <tr class="tdbg">
              <td  height="25" class="clefttitle">相册名称：</td>
              <td><input class="textbox" name="xcname" type="text" id="xcname" style="width:230px; " value="<%=xcname%>" maxlength="100" />
              <span style="color: #FF0000">*</span><span class="msgtips">请给你的相册取个合适的名称,如个人写真集。</span></td>
            </tr>
<tr class="tdbg">
              <td class="clefttitle" height="25">相册分类：</td>
              <td><select class="select" size='1' name='ClassID' style="width:250px">
                    <option value="0">-请选择类别-</option>
                    <% Set RS=Server.CreateObject("ADODB.RECORDSET")
							  RS.Open "Select * From KS_PhotoClass order by orderid",conn,1,1
							  If Not RS.EOF Then
							   Do While Not RS.Eof 
							   If ClassID=RS("ClassID") Then
								  Response.Write "<option value=""" & RS("ClassID") & """ selected>" & RS("ClassName") & "</option>"
							   Else
								  Response.Write "<option value=""" & RS("ClassID") & """>" & RS("ClassName") & "</option>"
							   End iF
								 RS.MoveNext
							   Loop
							  End If
							  RS.Close:Set RS=Nothing
							  %>
                  </select>          <span class="msgtips">相册分类，以便查找浏览</span>     </td>
            </tr>
			<tr class="tdbg"> 
                  <td class="clefttitle">是否公开：</td>
                  <td><select class="select" style="width:160px" onChange="if(this.options[selectedIndex].value=='3'){document.myform.all.mmtt.style.display='block';}else{document.myform.all.mmtt.style.display='none';}"  name="flag">
                      <option value="1"<%if flag="1" then response.write " selected"%>>完全公开</option>
                      <option value="2"<%if flag="2" then response.write " selected"%>>会员开见</option>
                      <option value="3"<%if flag="3" then response.write " selected"%>>密码共享</option>
                      <option value="4"<%if flag="4" then response.write " selected"%>>隐私相册</option>
                    </select><span class="msgtips">可以设置为只有权限的用户才能浏览。 </span><span class=child id=mmtt name="mmtt" <%if flag<>3 then%>style="display:none;"<%end if%>>密码：<input class="textbox" type="password" name="password" style="width:160px" maxlength="16" value="<%=password%>" size="20"></span> 
				   </td>
            </tr>
            <tr class="tdbg">
              <td class="clefttitle">相册封面：</td>
              <td><input class="textbox" name="PhotoUrl" type="text" id="PhotoUrl" style="width:230px; " value="<%=PhotoUrl%>" />                  <span class="msgtips">只支持jpg、gif、png，小于100k，默认尺寸为85*100</span>
				  <div><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_UpFile.asp?Type=Pic&FieldName=PhotoUrl&MaxFileSize=100&ext=*.jpg;*.png;*.gif&ChannelID=9998' frameborder="0" align="center" width='100%' height='30' scrolling="no"></iframe>
				  </div>
				  </td>
            </tr>
            <tr class="tdbg">
              <td class="cleftittle">相册介绍： </td>
              <td><textarea class="textbox" name="Descript" id="Descript" style="overflow:auto;width:350px;height:60px"><%=Descript%></textarea>              <span class="msgtips">关于此相册的简要文字说明。</span>
				  </td>
            </tr>
            <tr class="tdbg">
			  <td></td>
              <td>
			    <button class="pn" type="submit"><strong><%=OpStr%></strong></button>
              </td>
            </tr>
          </form>
</table>
		<%
	   End Sub
	   '保存相册
	   Sub photoxcsave()
	     Dim xcname:xcname=KS.S("xcname")
		 Dim ClassID:ClassID=KS.ChkClng(KS.S("ClassID"))
		 Dim Descript:Descript=KS.S("Descript")
		 Dim Flag:Flag=KS.S("Flag")
		 Dim PhotoUrl:PhotoUrl=KS.S("PhotoUrl")
		 Dim PassWord:PassWord=KS.S("PassWord")
		 Dim ID:ID=KS.Chkclng(KS.S("id"))
		 If PhotoUrl="" Or IsNull(PhotoUrl) Then PhotoUrl="/images/user/nopic.gif"
		 If xcname="" Then Response.Write "<script>$.dialog.tips('请输入相册名称!',1,'error.gif',function(){history.back();});</script>"
		 If ClassID=0 Then Response.Write "<script>$.dialog.tips('请选择相册类型!',1,'error.gif',function(){history.back();});</script>"
	     Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select top 1 * From KS_Photoxc Where id=" & id ,conn,1,3
		 If RS.Eof And RS.Bof Then
		   RS.AddNew
		    RS("AddDate")=now
			if ks.SSetting(4)=1 then
			RS("Status")=0 '设为已审
			else
			RS("Status")=1 '设为已审
			end if
		 End If
		    RS("UserName")=KSUser.UserName
		    RS("xcname")=xcname
			RS("ClassID")=ClassID
			RS("Descript")=Descript
			RS("Flag")=Flag
			RS("Password")=PassWord
			RS("PhotoUrl")=PhotoUrl
		  RS.Update
		  RS.MoveLast
		  ID=rs("id")
		  RS.Close:Set RS=Nothing
		  If KS.Chkclng(KS.S("id"))=0 Then
		   Call KS.FileAssociation(1028,ID,PhotoUrl,0)
		   Response.Write "<script>$.dialog.tips('恭喜!相册创建成功,进入上传照片',1,'success.gif',function(){location.href='User_Photo.asp?action=Add&xcid=" & id &"';});</script>"
		  Else
		   Call KS.FileAssociation(1028,ID,PhotoUrl,1)
		   Response.Write "<script>$.dialog.tips('恭喜，相册修改成功!',1,'success.gif',function(){location.href='User_Photo.asp';});</script>"
		  End If
	   End Sub


	  
	   '相册列表
	   Sub PhotoxcList()
			  
			   		       If KS.S("page") <> "" Then
						          CurrentPage = KS.ChkClng(KS.S("page"))
							Else
								  CurrentPage = 1
							End If
                                    
									Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
									IF KS.S("status")<>"" Then
									  Param=Param & " And status=" & KS.ChkClng(KS.S("status"))
									End if
									
									
									'If KS.S("XCID")<>"" And KS.S("XCID")<>"0" Then Param=Param & " And XCID=" & KS.ChkClng(KS.S("XCID")) & ""
									Dim Sql:sql = "select * from KS_Photoxc "& Param &" order by AddDate DESC"


								    Call KSUser.InnerLocation("所有相册列表")
								  %>
								     
				                     <table width="98%"  border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                                               
                                           
                                      <%
									Set RS=Server.CreateObject("AdodB.Recordset")
									RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' align='center' colspan=6 height=30 valign=top>您还没有创建相册!</td></tr>"
								 Else
									totalPut = RS.RecordCount
						         	If CurrentPage < 1 Then	CurrentPage = 1
			
								If CurrentPage = 1 Then
									Call ShowXC
								Else
									If (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
										Call ShowXC
									Else
										CurrentPage = 1
										Call ShowXC
									End If
								End If
				End If
     %>                      
                        </table>
		  <%
  End Sub
  
  Sub ShowXC()
     Dim I,K
   Do While Not RS.Eof
         %>
           <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
		   <%
		   For K=1 To 4
		   %>
            <td width="25%" height="22" align="center">
									  <table width=154 height=185 border=0 cellPadding=0 cellSpacing=0 bgcolor="#FFFFFF" id=AutoNumber2 style="BORDER-COLLAPSE: collapse">
										  <td width=123 height=185>
											<table id=AutoNumber3 style="BORDER-COLLAPSE: collapse" borderColor=#b2b2b2 height=179 cellSpacing=0 cellPadding=0 width="117%" border=0>
											  <tr>
												<td width="100%" height=179>
												  <table style="BORDER-COLLAPSE: collapse" cellSpacing=0 cellPadding=0 width="99%" border=0>
													<tr>
													  <td align=middle width="100%" height=22><strong><a href="?xcid=<%=rs("id")%>&action=ViewZP"><%=ks.gottopic(rs("xcname"),18)%></a></strong><%select case rs("status")
													     case 1:response.write "[已审]"
														 case 2:response.write "<font color=blue>[锁定]</font>"
														 case 0:response.write "<font color=red>[未审]</font>"
														end select
														%>
													  </td>
													</tr>
													<tr>
													  <td align=middle width="100%">
														<table style="BORDER-COLLAPSE: collapse" cellSpacing=0 cellPadding=0>
														  <tr>
															<td background="images/pic.gif" width="136" height="106" valign="top"><a href="?xcid=<%=rs("id")%>&action=ViewZP"><img style="margin-left:0px;margin-top:5px" src="<%=rs("photourl")%>" width="120" height="90" border=0></a></td>
														  </tr>
														</table>
													  </td>
													</tr>
													<tr>
													  <td align=middle width="100%" height=23><%=rs("xps")%>张/<%=rs("hits")%>次</td>
													</tr>
													<tr>
													  <td align=middle width="100%" height=23><a href="?Action=Editxc&id=<%=rs("id")%>">修改</a>&nbsp;<a href="?Action=Del&id=<%=rs("id")%>" onClick="return(confirm('删除相册将删除该相册里的所有照片，确定删除吗？'))">删除</a>&nbsp;
													  <% select case rs("flag")
													      case 1
													       response.write "<font color=red>[公开]</font>"
														  case 2
													       response.write "<font color=red>[会员]</font>"
														  case 3
													       response.write "<font color=red>[密码]</font>"
														  case 4
													       response.write "<font color=red>[稳私]</font>"
														 end select
													%>
													  </td>
													</tr>
												  </table>
												</td>
											  </tr>
											</table>
										  </td>
										</tr>
			  </table>
			 </td>
                       
					                  <%
							RS.MoveNext
							I=I+1
					  If I >= MaxPerPage Or RS.Eof Then Exit For
				  Next
			      do While K<4 
				   response.write "<td width=""25%""></td>"
				   k=k+1
				  Loop%>
		    </tr>
				 <%
					  If I >= MaxPerPage Or RS.Eof Then Exit do
	   Loop
%>
								<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
								  <td colspan=6 valign=top align="right">
								<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
								  </td>
								</tr>
								<% 
  End Sub
  '删除相册
  Sub Delxc()
	Dim ID:ID=KS.S("ID")
	ID=KS.FilterIDs(ID)
	If ID="" Then Call KS.Alert("你没有选中要删除的相册!",ComeUrl):Response.End
	Conn.Execute("Delete From KS_Photoxc Where ID In(" & ID & ")")
	Dim RS:Set rs=server.createobject("adodb.recordset")
	rs.open "select * from ks_photozp where xcid in(" &id & ")",conn,1,1
	if not rs.eof then
	  do while not rs.eof
	   Conn.Execute("Delete From KS_UploadFiles Where Channelid=1029 and infoid=" & rs("id"))
	   KS.DeleteFile(rs("photourl"))
	   rs.movenext
	   loop
	end if
	Conn.execute("delete from ks_photozp where xcid in(" & id& ")")
	Conn.execute("delete from ks_uploadfiles where channelid=1028 and infoid in(" & id& ")")
	rs.close:set rs=nothing
	Response.Redirect ComeUrl
  End Sub
  '删除照片
  Sub Delzp()
	Dim ID:ID=KS.S("ID")
	ID=KS.FilterIDs(ID)
	If ID="" Then Call KS.Alert("你没有选中要删除的照片!",ComeUrl):Response.End
	Dim RS:Set rs=server.createobject("adodb.recordset")
	rs.open "select * from ks_photozp where id in(" &id & ")",conn,1,1
	if not rs.eof then
	  do while not rs.eof
	   KS.DeleteFile(rs("photourl"))
	   Conn.execute("update ks_photoxc set xps=xps-1 where id=" & rs("xcid"))
	   rs.movenext
	   loop
	end if
	Conn.Execute("Delete From KS_UploadFiles Where Channelid=1029 and infoid in(" & id& ")")
	Conn.execute("delete from ks_photozp where id in(" & id& ")")
	rs.close:set rs=nothing
	Response.Redirect ComeUrl
  End Sub
  '上传照片
  Sub Addzp()
        Call KSUser.InnerLocation("上传照片")
		
		If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(37))  And KS.ChkClng(KS.SSetting(37))>0 Then  '判断有没有到达积分要求
			KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(37)) &"</font> 分才可以发表上传照片，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
		End If   

		adddate=now:XCID=KS.ChkCLng(KS.S("XCID")):UserName=KSUser.GetUserInfo("RealName")
		%>
		<script language = "JavaScript">
				function CheckForm()
				{ 
				 if ($("input[name=pubtype]:checked").val()==1){
					if (document.myform.Title.value=="")
					  {
						$.dialog.alert("请输入相册名称！",function(){
						document.myform.Title.focus();});
						return false;
					  }
				 }else if (document.myform.XCID.value==""){
					$.dialog.alert("请选择所属相册！",function(){
					document.myform.XCID.focus();});
					return false;
				  }	
				  	
				  var picSrcs='';
				  var src='';
				  $("#thumbnails").find(".pics").each(function(){
					 src=$(this).next().val().replace('|||','').replace('|','')+'@@@'+$(this).val()
					 if(picSrcs==''){
					  picSrcs=src;
					 }else{
					  picSrcs+='|'+src;
					 }
				  });
				  if (picSrcs==''){
				   $.dialog.alert('请上传照片!',function(){});
				   return false;
				  }
				  $('#PhotoUrls').val(picSrcs);
				 return true;  
				}
				</script>
	
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="User_Photo.asp?Action=AddSave&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr class="title">
					  <td colspan=2 align=center>上 传 照 片</td>
					</tr>
					<%
					Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
					RS.Open "Select * From KS_Photoxc where username='" & KSUser.Username & "' order by id desc",conn,1,1
					%>
                    <tr class="tdbg">
					    <%If Not RS.Eof Then%>
                       <td width="12%"  height="25" align="center"><span>选择相册：</span></td>
                       <td width="88%">
					     <label><input type="radio" name="pubtype" value="0" onclick="$('#pub1').hide();$('#pub0').show();" checked>发到已有相册</label>
					     <label><input type="radio" name="pubtype" value="1" onclick="$('#pub1').show();$('#pub0').hide();">创建新相册</label>
<br/>
						 <div id="pub0" style="margin-top:5px">
						 <table><tr>
						   <td><strong>选择相册</strong></td><td>
					   <select class="select" size='1' name='XCID' style="width:150">
							<% 
							Dim HasXC:HasXC=False
							If Not RS.EOF Then
							   HasXC=true
							   Do While Not RS.Eof 
							     If XCID=RS("ID") Then
								  Response.Write "<option value=""" & RS("ID") & """ selected>" & RS("XCName") & "</option>"
								 Else
								  Response.Write "<option value=""" & RS("ID") & """>" & RS("XCName") & "</option>"
								 End If
								 RS.MoveNext
							   Loop
							End If
							RS.Close:Set RS=Nothing
							  %>
                         </select></td></tr></table>	
						 
						 </div>						 
						 <%Else%>
                       <td width="12%"  height="25" align="center"><span>创建相册：</span></td>
                       <td width="88%">
						  <span style='display:none'><input type="radio" name="pubtype" value="1" checked></span>
						 <%End If%>
						 
						 <%If HasXC=true Then%>
						 <div id="pub1" style="display:none;margin-top:5px">
						 <%Else%>
						 <div id="pub1" style="margin-top:5px">
						 <%End If
						 
						 %>
						   <table border="0">
						    <tr>
							 <td>
						   <strong>相册名称：</strong>
						     </td>
							 <td colspan="2">
						   <input class="textbox" name="Title" type="text" id="Title" style="width:300px; " value="<%=Title%>" maxlength="100" /><span style="color: #FF0000">*</span>
						     </td>
						   </tr>
						   <tr>
						     <td><strong>相册介绍：</strong></td>
							 <td colspan="2"><textarea class="textbox" style="height:50px" name="Descript" cols="50" rows="5"></textarea></td>
						   </tr>
						   <tr>
						     <td><strong>是否公开：</strong></td>
							 <td><select class="select" onChange="if(this.options[selectedIndex].value=='3'){document.myform.all.mmtt.style.display='block';}else{document.myform.all.mmtt.style.display='none';}"  name="flag"><option value="1" selected>完全公开</option>
                      <option value="2">会员开见</option>
                      <option value="3">密码共享</option>
                      <option value="4">隐私相册</option>
                    </select></td><td><span class=child id=mmtt name="mmtt" style="display:none;">密码：<input type="password" name="password" style="width:120px" maxlength="16" value="" size="20"></span></td>
				           </tr>
						   <tr>
						     <td><strong>相册分类</strong></td>
							 <td colspan="2"> <select class="select" size='1' name='ClassID' style="width:250"><% Set RS=Server.CreateObject("ADODB.RECORDSET")
							  RS.Open "Select * From KS_PhotoClass order by orderid",conn,1,1
							  If Not RS.EOF Then
							   Do While Not RS.Eof 
							   If ClassID=RS("ClassID") Then
								  Response.Write "<option value=""" & RS("ClassID") & """ selected>" & RS("ClassName") & "</option>"
							   Else
								  Response.Write "<option value=""" & RS("ClassID") & """>" & RS("ClassName") & "</option>"
							   End iF
								 RS.MoveNext
							   Loop
							  End If
							  RS.Close:Set RS=Nothing
							  %></select></td>
							 </tr>
						  </table>
						   
						   
						 </div>
						 
						  <input class="textbox" name="PhotoUrls" type="hidden" id="PhotoUrls" style="width:350px; " maxlength="100" />
						   </td>
                    </tr>
                      

					<tr class="tdbg">
					  <td align="center"><span>上传照片：</span></td>
					  <td style="padding-top:8px">
					  <style type="text/css">
			#thumbnails{background:url(../plus/swfupload/images/albviewbg.gif) no-repeat;min-height:200px;_height:expression(document.body.clientHeight > 200? "200px": "auto" );}
			#thumbnails div.thumbshow{text-align:center;margin:2px;padding:2px;width:158px;border: dashed 1px #B8B808; background:#FFFFF6;float:left}
			#thumbnails div.thumbshow img{width:130px;height:92px;border:1px solid #CCCC00;padding:1px}

			</style>
			<link href="../plus/swfupload/images/default.css" rel="stylesheet" type="text/css" />
			<script type="text/javascript" src="../ks_inc/kesion.box.js"></script>
			<script type="text/javascript" src="../plus/swfupload/swfupload/swfupload.js"></script>
			<script type="text/javascript" src="../plus/swfupload/js/handlers.js"></script>
	 <script type="text/javascript">
			var swfu;
			var pid=0;
			function SetAddWater(obj){
			 if (obj.checked){
			 swfu.addPostParam("AddWaterFlag","1");
			 }else{
			 swfu.addPostParam("AddWaterFlag","0");
			 }
			}
			//删除已经上传的图片
			function DelUpFiles(pid)
			{
			 $("#thumbshow"+pid).remove();
			}	
			
			function addImage(bigsrc,smallsrc,text) {
				var newImgDiv = document.createElement("div");
				var delstr = '';
				delstr = '<a href="javascript:DelUpFiles('+pid+')" style="color:#ff6600">[删除]</a>';
				newImgDiv.className = 'thumbshow';
				newImgDiv.id = 'thumbshow'+pid;
				document.getElementById("thumbnails").appendChild(newImgDiv);
				newImgDiv.innerHTML = '<a href="'+bigsrc+'" target="_blank"><span id="show'+pid+'"></span></a>';
				newImgDiv.innerHTML += '<div style="margin-top:10px;text-align:left">'+delstr+' <b>注释：</b><input type="hidden" class="pics" id="pic'+pid+'" value="'+bigsrc+'"/><input type="text" name="picinfo'+pid+'" value="'+text+'" style="width:155px;" /></div>';
			
				var newImg = document.createElement("img");
				newImg.style.margin = "5px";
			
				document.getElementById("show"+pid).appendChild(newImg);
				if (newImg.filters) {
					try {
						newImg.filters.item("DXImageTransform.Microsoft.Alpha").opacity = 0;
					} catch (e) {
						newImg.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity=' + 0 + ')';
					}
				} else {
					newImg.style.opacity = 0;
				}
			
				newImg.onload = function () {
					fadeIn(newImg, 0);
				};
				newImg.src = smallsrc;
				pid++;
				
			}
		
			window.onload = function () {
				swfu = new SWFUpload({
					// Backend Settings
					upload_url: "swfupload.asp",
					post_params: {"BasicType":9997,"ChannelID":9997,"AutoRename":4,"UserName" : "<%=KS.C("UserName") %>","RndPassWord":"<%=KS.C("RndPassWord")%>"},
	
					// File Upload Settings
					file_size_limit : <%=KS.ChkClng(KS.SSetting(32))%>,	// 2MB
					file_types : "*.jpg; *.gif; *.png",
					file_types_description : "支持.JPG.gif.png格式的图片,可以多选",
					file_upload_limit : 0,
	
					// Event Handler Settings - these functions as defined in Handlers.js
					//  The handlers are not part of SWFUpload but are part of my website and control how
					//  my website reacts to the SWFUpload events.
					swfupload_preload_handler : preLoad,
					swfupload_load_failed_handler : loadFailed,
					file_queue_error_handler : fileQueueError,
					file_dialog_complete_handler : fileDialogComplete,
					upload_start_handler : uploadStart,
					upload_progress_handler : uploadProgress,
					upload_error_handler : uploadError,
					upload_success_handler : uploadSuccess,
					upload_complete_handler : uploadComplete,
	
					// Button Settings
					//button_image_url : "../plus/swfupload/images/SmallSpyGlassWithTransperancy_17x18d.png",
					button_placeholder_id : "spanButtonPlaceholder",
					button_width: 152,
					button_height: 22,
					
					button_text : '<span class="button">批量上传(单图<%If KS.ChkClng(KS.SSetting(32))<1024 Then%><%=KS.ChkClng(KS.SSetting(32))%> K<%Else%> <%=round(KS.ChkClng(KS.SSetting(32))/1024,2)%> M<%End If%>)</span>',
					button_text_style : '.button { line-height:22px;font-family: Helvetica, Arial, sans-serif;color:#666666;font-size: 14px; } ',
					button_text_top_padding: 3,
					button_text_left_padding: 0,
					button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
					button_cursor: SWFUpload.CURSOR.HAND,
					
					// Flash Settings
					flash_url : "../plus/swfupload/swfupload/swfupload.swf",
					flash9_url : "../plus/swfupload/swfupload/swfupload_FP9.swf",
	
					custom_settings : {
						upload_target : "divFileProgressContainer"
					},
					
					// Debug Settings
					debug: false
				});
			};
		</script>
	<script type="text/javascript">
	function OnlineCollect(){
	var p=new KesionPopup();
	p.MsgBorder=5;
	p.BgColor='#fff';
	p.ShowBackground=false;
	p.popup("<div style='text-align:left;padding-left:2px'>网上图片地址</div>","<div style='padding:3px'>带http://开头的远程图片地址,每行一张图片地址:<br/><textarea id='collecthttp' style='width:400px;height:150px'></textarea><br/><input type='button' value='确 定' onclick='ProcessCollect()' class='button'/> <input type='button' value='取 消' class='button' onclick='closeWindow()'/></div>",420);
	}
	function AddTJ(){
	var p=new KesionPopup();
	p.MsgBorder=5;
	p.BgColor='#fff';
	p.ShowBackground=false;
	p.popup("<div style='text-align:left;padding-left:2px'>从上传文件中选择</div>","<div style='padding:3px'><strong>图片地址:</strong><input type='text' name='x1' id='x1'> <input type='button' onclick=\"OpenThenSetValue('Frame.asp?url=SelectPhoto.asp&pagetitle=<%=Server.URLEncode("选择图片")%>&ChannelID=9997',550,290,window,$('#x1')[0]);\" value='选择图片' class='button'/><br/><strong>简要介绍:</strong><input type='text' name='x3' id='x3'><br/><br/><input type='button' value='加 入' onclick='ProcessAddTj()' class='button'/> <input type='button' value='取 消' class='button' onclick='closeWindow()'/></div>",420);
	}
	function ProcessAddTj(){
	  if ($("#x1").val()==''){
	   $.dialog.alert('请选择一张图片地址!',function(){
	   $("#x1").focus();});
	   return false;
	  }
	  addImage($("#x1").val(),$("#x1").val(),$("#x3").val())
	  $("#x1").val('');
	  $("#x3").val('');
	}
	function ProcessCollect(){
	 var collecthttp=$("#collecthttp").val();
	 if (collecthttp==''){
	   $.dialog.alert('请输入远程图片地址,一行一张地址!',function(){
	   $("#collecthttp").focus();});
	   return false;
	 }
	 var carr=collecthttp.split('\n');
	 for(var i=0;i<carr.length;i++){
	   
	   var bigsrc=carr[i];
	   var smallsrc=carr[i];
	   addImage(bigsrc,smallsrc,'')
	 }
	 //$("#collecthttp").empty();
	 closeWindow();
	}
	</script>
	<table cellspacing="0" cellpadding="0">
		 <tr>
		  <td><div class="pn" style="margin: -6px 0px 0 0;"><span id="spanButtonPlaceholder"></span></div>
		 </td>
		 <td>
		<!-- <button type="button"  class="pn" onClick="OnlineCollect()" style="margin: -6px 0px 0 0;"><strong>网上地址</strong></button>-->
		 <button type="button"  class="pn" onClick="AddTJ();" style="margin: -6px 0px 0 0;"><strong>图片库...</strong></button>
		 </td>
		 </tr>
		</table>

		<label><input type="checkbox" name="AddWaterFlag" value="1" onClick="SetAddWater(this)" checked="checked"/>照片添加水印</label>
		<div id="divFileProgressContainer"></div>
		
		<div id="thumbnails"></div>

	   </td>
	   </tr>
	   
														 
                    <tr class="tdbg">
					  <td></td>
                      <td height="30">
					   <button id="button1" type="submit" class="pn"><strong>OK,立即发布</strong></button>
					</td>
                    </tr>
                  </form>
			    </table>
		  <%
  End Sub
    '编辑照片
  Sub Editzp()
        Call KSUser.InnerLocation("编辑照片")
		If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(37))  And KS.ChkClng(KS.SSetting(37))>0 Then  '判断有没有到达积分要求
			KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(37)) &"</font> 分才可以发表上传照片，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
		End If   
		
		  Dim KS_A_RS_Obj:Set KS_A_RS_Obj=Server.CreateObject("ADODB.RECORDSET")
		   KS_A_RS_Obj.Open "Select top 1 * From KS_PhotoZp Where ID=" & KS.ChkClng(KS.S("ID")),Conn,1,1
		   If Not KS_A_RS_Obj.Eof Then
		     XCID  = KS_A_RS_Obj("XCID")
			 Title    = KS_A_RS_Obj("Title")
			 UserName   = KS_A_RS_Obj("UserName")
			 descript = ks_a_rs_obj("descript")
			 PhotoUrlS  = KS_A_RS_Obj("PhotoUrl")
		   End If
		   KS_A_RS_Obj.Close:Set KS_A_RS_Obj=Nothing
		%>
		<script language = "JavaScript">
				function CheckForm()
				{
				if (document.myform.XCID.value=="0") 
				  {
					alert("请选择所属相册！");
					document.myform.XCID.focus();
					return false;
				  }		
				if (document.myform.Title.value=="")
				  {
					alert("请输入相片名称！");
					document.myform.Title.focus();
					return false;
				  }		
				 return true;  
				}
				
				</script>
				
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
                  <form  action="User_Photo.asp?Action=EditSave&ID=<%=KS.S("ID")%>" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
				    <tr class="title">
					  <td colspan=2 align=center>上 传 照 片</td>
					</tr>
                    <tr class="tdbg">
                       <td width="12%"  height="25" align="center"><span>选择相册：</span></td>
                       <td width="88%"><select class="textbox" size='1' name='XCID' style="width:150">
                             <option value="0">-请选择相册-</option>
							  <% Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
							  RS.Open "Select * From KS_Photoxc where username='" & KSUser.UserName & "' order by id desc",conn,1,1
							  If Not RS.EOF Then
							   Do While Not RS.Eof 
							     If XCID=RS("ID") Then
								  Response.Write "<option value=""" & RS("ID") & """ selected>" & RS("XCName") & "</option>"
								 Else
								  Response.Write "<option value=""" & RS("ID") & """>" & RS("XCName") & "</option>"
								 End If
								 RS.MoveNext
							   Loop
							  End If
							  RS.Close:Set RS=Nothing
							  %>
                         </select>					  </td>
                    </tr>
                      <tr class="tdbg"  style="display:none">
                           <td  height="25" align="center"><span>照片名称：</span></td>
                              <td><input class="textbox" name="Title" type="text" id="Title" style="width:350px; " value="<%=Title%>" maxlength="100" />
                                        <span style="color: #FF0000">*
                                        <input class="textbox" name="PhotoUrls" type="hidden" id="PhotoUrls" style="width:350px; " maxlength="100" value="<%=photourls%>"/>
                                        </span></td>
                    </tr>
								<tr class="tdbg">
								  <td height="20" align="center">照片预览：</td>
								  <td id="viewarea">
								    <table style='BORDER-COLLAPSE: collapse' borderColor='#c0c0c0' cellSpacing='1' cellPadding='2' border='1'><tr><td align='center' width='83' height='100' bgcolor='#ffffff'><img name='view1' width='83' height='100' src='<%=Photourls%>' title='照片预览'></td></tr></table> <input class="button" type='button' name='Submit3' value='选择照片地址...' onClick="OpenThenSetValue('Frame.asp?url=SelectPhoto.asp&pagetitle=<%=Server.URLEncode("选择图片")%>&ChannelID=9997',500,360,window,document.myform.PhotoUrls);" />
								</td>
				    </tr>
														 
								<tr class="tdbg">
                                   <td height="25" align="center"><span>照片介绍：</span></td>
                                  <td><textarea class="textbox" style="height:50px" name="Descript" cols="70" rows="5"><%=DESCRIPT%></textarea></td>
							  </tr>							 
                    <tr class="tdbg">
                      <td height="30" align="center" colspan=2>
					 <input type="submit" name="Submit"  class="button" value=" OK,立即发布 " />
                      <input type="reset" name="Submit2"   class="button" onClick="javascript:history.back()" value=" 取 消 " />						</td>
                    </tr>
                  </form>
			    </table>
		  <%
  End Sub

   Sub EditSave()
		If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(37))  And KS.ChkClng(KS.SSetting(37))>0 Then  '判断有没有到达积分要求
			KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(37)) &"</font> 分才可以发表上传照片，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
		End If   
    Dim RSObj,Descript,PhotoUrlArr,i
                 XCID=KS.ChkClng(KS.S("XCID"))
				 Title=Trim(KS.S("Title"))
				 UserName=Trim(KS.S("UserName"))
				 Descript=KS.S("Descript")
				 PhotoUrls=KS.S("PhotoUrls")
				 If PhotoUrls="" Then 
				    Response.Write "<script>alert('你没有上传相片!');history.back();</script>"
				    Exit Sub
				  End IF
				  on error resume next
				Set RSObj=Server.CreateObject("Adodb.Recordset")
				RSObj.Open "Select top 1 * From KS_PhotoZP Where ID=" & KS.ChkClng(KS.S("ID")),Conn,1,3
				  RSObj("Title")=left(Descript,200)
				  RSObj("XCID")=XCID
				  RSObj("PhotoUrl")=PhotoUrls
				  RSObj("Descript")=Descript
				  RSObj("PhotoSize") =KS.GetFieSize(Server.Mappath(replace(PhotoUrls,ks.getdomain,ks.setting(3))))
				RSObj.Update
				 RSObj.Close:Set RSObj=Nothing
				 Call KS.FileAssociation(1029,KS.ChkClng(KS.S("ID")),PhotoUrls,1)
				 Response.Write "<script>alert('相片修改成功!');location.href='User_Photo.asp?Action=ViewZP&XCID=" & XCID& "';</script>"
  End Sub
  
  Sub AddSave()
		If KS.ChkClng(KSUser.GetUserInfo("score"))<KS.ChkClng(KS.SSetting(37))  And KS.ChkClng(KS.SSetting(37))>0 Then  '判断有没有到达积分要求
			KS.Die "<script>$.dialog.tips('对不起，本站要求积分达到 <font color=red>" & KS.ChkClng(KS.SSetting(37)) &"</font> 分才可以发表上传照片，您当前积分 <font color=green>" & KSUser.GetUserInfo("score") & "</font> 分!',5,'error.gif',function(){history.back();});</script>"
		End If   
  
    Dim RSObj,Descript,PhotoUrlArr,i,UpFiles,PhotoUrl,PubType,ClassID
	             PubType=KS.ChkClng(KS.S("PubType"))
                 XCID=KS.ChkClng(KS.S("XCID"))
				 ClassID=KS.ChkClng(KS.S("ClassID"))
				 Title=Trim(KS.S("Title"))
				 UserName=Trim(KS.S("UserName"))
				 Descript=KS.S("Descript")
				 PhotoUrls=KS.S("PhotoUrls")
				 If PhotoUrls="" Then 
				    Response.Write "<script>alert('你没有上传相片!');history.back();</script>"
				    Exit Sub
				  End IF
				 PhotoUrlArr=Split(PhotoUrls,"|")
				 
				  If XCID=0 And PubType=0 Then
				    Response.Write "<script>alert('你没有选择相册!');history.back();</script>"
				    Exit Sub
				  End IF
				  If Title="" And PubType=1 Then
				    Response.Write "<script>alert('你没有输入相册名称!');history.back();</script>"
				    Exit Sub
				  End IF
				
				Set RSObj=Server.CreateObject("Adodb.Recordset")
				If PubType=1 Then
			        RSObj.Open "Select top 1 * From KS_Photoxc" ,conn,1,3
					  RSObj.AddNew
						RSObj("AddDate")=now
						if ks.SSetting(4)=1 then
						RSObj("Status")=0 '设为已审
						else
						RSObj("Status")=1 '设为已审
						end if
						RSObj("UserID")=KSUser.GetUserInfo("userid")
						RSObj("UserName")=KSUser.UserName
						RSObj("xcname")=Title
						RSObj("ClassID")=ClassID
						RSObj("Descript")=Descript
						RSObj("Flag")=KS.ChkClng(KS.S("Flag"))
						RSObj("Password")=KS.S("PassWord")
						RSObj("PhotoUrl")=Split(PhotoUrlArr(0),"@@@")(1)
					  RSObj.Update
					  RSObj.MoveLast
					  XCID=RSObj("id")
					   Call KS.FileAssociation(1028,XCID,RSObj("PhotoUrl"),0)
				RSObj.Close
				End If
				
				
				dim picstr
				RSObj.Open "Select top 1 * From KS_PhotoZP",Conn,1,3
				 For I=0 to ubound(PhotoUrlArr)
			    	RSObj.AddNew
					 PhotoUrl=Split(PhotoUrlArr(I),"@@@")(1)
					 RSObj("PhotoSize") =KS.GetFieSize(Server.Mappath(Replace(PhotoUrl,KS.GetDomain,KS.Setting(3))))
				     RSObj("Title")=left(Split(PhotoUrlArr(I),"@@@")(0),200)
				     RSObj("XCID")=XCID
					 RSObj("UserName")=KSUser.UserName
					 RSObj("PhotoUrl")=PhotoUrl
					 RSObj("Adddate")=Now
					 RSObj("Descript")=Split(PhotoUrlArr(I),"@@@")(0)
				   RSObj.Update
				   RSObj.MoveLast
				    if i<1 then
				     picstr=picstr &"[img]" & replace(lcase(photourl),lcase(ks.setting(2)),"") & "[/img]"
				   end if
				   Call KS.FileAssociation(1029,RSObj("ID"),PhotoUrlArr(i),0)
				 Next
				 RSObj.Close
				 
				 dim xcname
				 RSObj.Open "select top 1 xcname from KS_PhotoXC Where id=" & XCID,conn,1,1
				 if not rsobj.eof then
				   xcname=rsobj(0)
				 end if
				 RSObj.Close
				 Set RSObj=Nothing
				 
				 
				 Conn.Execute("update KS_Photoxc set xps=xps+" & Ubound(PhotoUrlArr)+1 & " where id=" & xcid)
				 Call KSUser.AddToWeibo(KSUser.UserName,"上传" & Ubound(PhotoUrlArr)+1 & "张照片到相册【" & left(XCName,10) &"】 [url=../space/?" & KSUser.GetUserInfo("userid") & "/showalbum/" & xcid & "]查看&raquo;[/url]"&picstr,3)
				 Response.Write "<script>if (confirm('相片保存成功，继续上传吗?')){location.href='User_Photo.asp?Action=Add';}else{location.href='User_Photo.asp?Action=ViewZP&XCID=" & XCID& "';}</script>"
  End Sub

End Class
%> 
