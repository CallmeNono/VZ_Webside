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
Set KSCls = New SpaceCls
KSCls.Kesion()
Set KSCls = Nothing

Class SpaceCls
        Private KS,KSUser,LoginTF,TopDir,KSR
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		  Set KSR=New Refresh
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		 Set KSR=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/SpaceFunction.asp"-->
        <!--#include file="../ks_cls/ubbfunction.asp"-->
		<%
       Public Sub loadMain()
		'Call KSUser.Head()
		'Call KSUser.InnerLocation("会员首页")
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		
        If KS.SSetting(0)=0 Then
		 KS.Die "<script>$.dialog.tips('对不起，本站没有开通空间门户功能!',1,'error.gif',function(){location.href='index.asp';});</script>"
		End If
		%>	 <style>
			 .userrightdetail{float:left;margin-bottom:40px;}
			 .userrightdetail .uname{font-weight:bold;font-size:14px;}
			 .userrightdetail li{height:30px;line-height:30px}
			 .userrightdetail .uid{font-weight:normal;font-size:12px;color:#888;}
			 .spacelimit{padding-left:5px;border-left:1px solid #efefef;height:80px;margin-top:40px;}
			 .noopen{font-size:16px;text-align:center;color:#FF0000}
			 </style>
			 

	  
			 
			 <%
			  Dim RS:Set RS=Server.CreateObject("adodb.recordset")
			  RS.Open "select top 1 * From KS_Blog Where UserName='" & KSUser.UserName &"'",conn,1,1
			  If RS.Eof And RS.Bof Then
			  %>
			  <h2><img src='images/icon8.png'/> 门户信息</h2>
			  <div class="noopen"><img src="images/wrong.gif"/> 您还没有开通空间门户，<a href="User_Blog.asp?action=BlogEdit">点此开通</a></div>
			  <%
			  Else
				  Dim UserFaceSrc:UserFaceSrc=RS("Logo")
				  if left(userfacesrc,1)<>"/" and lcase(left(userfacesrc,4))<>"http" then userfacesrc="../" & userfacesrc
				%>
				<h2><img src='images/icon8.png'/> 我的空间门户信息
				 <%if rs("status")=1 then%>
				  <img src="images/ok.gif"/><font color=green>已审核</font>
				 <%else%>
				  <img src="images/wrong.gif"/> <font color=red>未审核</font>
				 <%end if%>
				</h2>
				 <div class="ar_r_t"><div class="ar_l_t"><div class="ar_r_b"><div class="ar_l_b"><a href="User_Blog.asp?action=BlogEdit" title="修改空间LOGO"><img width="120" height="120" src="<%=UserFaceSrc%>" onerror="this.onerror=null;this.src='images/noavatar_middle.gif'" alt="修改空间LOGO"></a></div></div></div></div>
				
				
				 <div class="userrightdetail">
				   <li>
				   <span class="uname">
				  <%If Not KS.IsNul(KSUser.GetUserInfo("realname")) Then
					 response.write KSUser.GetUserInfo("realname") &"(" & KSUser.UserName &")"
					Else
					 response.write KSUser.UserName
					End If		 
				  %>
				  </span>
				   <span class="uid">会员ID：<%=KSUser.GetUserInfo("UserID")%> &nbsp;&nbsp;&nbsp;用户组：<%=KS.U_G(KSUser.GroupID,"groupname")%></span>
				  
				   </li>
				   
				   <li>
				    空间名称：<%=rs("blogname")%> &nbsp;&nbsp;开通时间：<%=rs("adddate")%>  &nbsp;&nbsp;空间访问量：<%=rs("hits")%> 次
				   </li>
				   <li>博文：<a href="User_Blog.asp"><%=conn.execute("select count(1) from ks_bloginfo where username='" & KSUser.UserName & "'")(0)%></a> 篇&nbsp;&nbsp;相册：<a href="User_Photo.asp"><%=conn.execute("select count(1) from ks_photoxc where username='" & KSUser.UserName & "'")(0)%></a> 个&nbsp;&nbsp;相片：<a href="User_Photo.asp"><%=conn.execute("select count(1) from ks_PhotoZP where username='" & KSUser.UserName & "'")(0)%></a> 张&nbsp;&nbsp;圈子：<a href="User_Team.asp"><%=conn.execute("select count(1) from ks_team where username='" & KSUser.UserName & "'")(0)%></a> 个&nbsp;&nbsp;音乐：<a href="User_Music.asp"><%=conn.execute("select count(1) from ks_BlogMusic where username='" & KSUser.UserName & "'")(0)%></a> 首&nbsp;&nbsp;</li>
				   
				   <li>
				   <%
				   If KS.SSetting(0)<>0 Then  '判断有没有开通空间
							 dim spacedomain,predomain
							 If KS.SSetting(14)<>"0" and not conn.execute("select top 1 username from ks_blog where username='" & ksuser.username & "'").eof Then
							   predomain=conn.execute("select top 1 [domain] from ks_blog where username='" & ksuser.username & "'")(0)
							 end if
							 if Not KS.IsNul(predomain) then
								if instr(predomain,".")=0 then
									spacedomain="http://" & predomain & "." & KS.SSetting(16)
								else
								  spacedomain="http://" & predomain
								end if
							 else
									 If KS.SSetting(21)="1" Then
										 spacedomain=KS.GetDomain & "space/" & ks.c("userid")
									 Else
										 spacedomain=KS.GetDomain & "space/?" & ks.c("userid")
									 End If
							 end if
						 If KSUser.CheckPower("s01")=false then
						   spacedomain=KS.GetDomain & "company/show.asp?username=" & ksuser.username
						 End If
						 KS.Echo "<div style=""cursor:default;padding-left:4px;border:1px dashed #789""><b>我的空间首页：</b><span style=""padding:4px;"" ondblclick=""copyToClipboard(this.innerHTML)"">" & spacedomain & "</span><a href=""" & spacedomain & """ target=""_blank"" class=""modbtn"">&nbsp;<b>访问&raquo;</b></a></div>"
						 KS.Echo "<div class=""msgtips"">双击上面虚线框将自动复制您的的空间地址到剪切板，您可以发给您的QQ、MSN等好友。</div>"
					End If
				   %>
				   </li>
				 </div>
			   <%End IF
			   RS.Close
			   %>
			
			
			 <div class="clear"></div>
			 <h2><span><a href="../space/morephoto.asp" target="_blank">更多&raquo;</a></span><img src="images/tp.gif" align="absmiddle" /> 最新照片</h2>
			 <div class="loglist" style="padding:12px">
			
			 
			  <div id="Roll20125640992981" style="overflow:hidden;height:170px;width:750px;">
		   <table align="left" cellpadding="0" cellspacing="0" border="0">
			<tr>
			  <td id="Roll201256409929811">
				<table width="100%" height="100%" border="0">
				 <tr>

				 <%
			  RS.Open "select top 50 a.xcid,a.id,b.userid,a.username,a.title,a.photourl from KS_Photozp a inner join KS_PhotoXC b On a.xcid=b.id Where b.flag=1 and  b.status=1 order by a.adddate desc,a.id",conn,1,1
			   do while not rs.eof 
			  %>
			  <td style="text-align:center;padding:10px;">
 <div class="img"><a target="_blank" href="../space/?<%=rs("userid")%>/showalbum/<%=rs("xcid")%>/<%=rs("id")%>" title="<%=rs("title")%>"><Img Src="<%=rs("photourl")%>" style="border:1px solid #efefef;padding:1px;" border="0" alt="<%=rs("title")%>" width="130" height="120" align="absmiddle"/></a></div>
 <div class="t"><a target="_blank" href="../space/?<%=rs("userid")%>/showalbum/<%=rs("xcid")%>/<%=rs("id")%>" title="<%=rs("title")%>"><%=ks.Gottopic(rs("title"),20)%></a> </div>
</td>

			  <% rs.movenext
			  loop
			  rs.close
			 %>
				
</tr></table>
 
			  </td>
			  <td id="Roll201256409929812"></td>
			</tr>
			</table>
		 </div>
		  <script laguage="javascript" type="text/javascript">
		   <!--
			var leftspeed20125640992981 = 10;
			document.getElementById("Roll201256409929812").innerHTML = document.getElementById("Roll201256409929811").innerHTML;
			function MarqueeLeft20125640992981(){
			if(document.getElementById("Roll201256409929812").offsetWidth-document.getElementById("Roll20125640992981").scrollLeft<=0)
			document.getElementById("Roll20125640992981").scrollLeft-=document.getElementById("Roll201256409929811").offsetWidth
			else{
			 document.getElementById("Roll20125640992981").scrollLeft++
			}}
			var MyMarleft20125640992981 = setInterval(MarqueeLeft20125640992981, leftspeed20125640992981)
			document.getElementById("Roll20125640992981").onmouseover=function() {clearInterval(MyMarleft20125640992981)}
			document.getElementById("Roll20125640992981").onmouseout=function() {MyMarleft20125640992981=setInterval(MarqueeLeft20125640992981,leftspeed20125640992981)}
			//-->
		 </script>

			 
			 
			 </div>
			 
			 <div class="clear"></div>
			 <h2><span><a href="../space/morelog.asp" target="_blank">更多&raquo;</a></span><img src="images/icon7.png" align="absmiddle" /> 最新博文</h2>
			 <div class="loglist">
			    <table width="98%"  border="0" align="center" cellpadding="1" cellspacing="1" class="border">
			  <%RS.Open "select top 5 * From KS_BlogInfo Where Status=0 order by id desc",conn,1,1
			  do while not rs.eof 
			  %>
			  <tr class='tdbg'  onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
					<%
					Dim PhotoUrl:PhotoUrl=RS("PhotoUrl")
					If KS.IsNul(PhotoUrl) Then PhotoUrl="../uploadfiles/user/avatar/" & rs("userid") &".jpg"
					%>
                   <td class="splittd" style="width:60px;">
						<div class="avatar48"><a title="进入<%=rs("username")%>的空间" href="../space/?<%=rs("userid")%>/log/<%=rs("id")%>" target="_blank"><img src="<%=PhotoUrl%>" onerror="this.src='../images/face/boy.jpg';" /></a></div>
					</td>
					<td valign="top" class="splittd" style="width:650px">
					  <div class="Contenttitle"><a href="../space/?<%=rs("userid")%>/log/<%=rs("id")%>" target="_blank"><%=KS.Gottopic(RS("title"),40)%></a>
					  
					  <span>   
					   <%=KS.GetTimeFormat(rs("adddate"))%> 
					    <%  Dim RST:Set RST=Conn.Execute("Select TOP 1 TypeName From KS_BlogType Where TypeID=" & RS("TypeID"))
							IF NOT RST.Eof Then
								   Response.Write " 分类:" & RST(0)
							End If
							RST.Close:Set RST=Nothing%>
							 状态：  <%Select Case rs("Status")
											   Case 0
											     Response.Write "<span class=""font10"">正常</span>"
                                               Case 2
											     Response.Write "<span class=""font13"">未审</span>"
                               end select %>
						  </span>
						  <%if rs("userid")=KS.ChkClng(ksuser.getuserinfo("userid")) then%>
						<a href="User_Blog.asp?id=<%=rs("id")%>&Action=Edit&">修改</a> <a href="javascript:;" onclick = "$.dialog.confirm('确定删除博文吗?',function(){location.href='User_Blog.asp?action=Del&ID=<%=rs("id")%>';},function(){})">删除</a>
					      <%end if%>
					  </div>

						<div class="blogtext"><%=KS.Gottopic(ks.losehtml(ks.ClearBadChr(ubbcode(rs("content"),1))),160)%>...
						
						<a href="../space/?<%=KSUser.GetUserInfo("userid")%>/log/<%=rs("id")%>" target="_blank">[阅读全文]</a>
						</div>				  
											  </td>
                                           
                                          </tr>
			  <%
			    rs.movenext
			  loop
			  rs.close
			  %>
			   </table>
			  
			 </div>
			 
			
	<% 
  End Sub
  
	  
End Class
%> 
