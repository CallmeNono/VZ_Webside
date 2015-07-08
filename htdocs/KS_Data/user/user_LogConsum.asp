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
Set KSCls = New User_LogMoney
KSCls.Kesion()
Set KSCls = Nothing

Class User_LogMoney
        Private KS,KSUser
		Private CurrentPage,totalPut
		Private RS,MaxPerPage
		Private TempStr,SqlStr
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
		<!--#include file="../KS_Cls/UserFunction.asp"-->
		<%
		Public Sub loadMain()	
		
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		Call KSUser.Head()
		Call KSUser.InnerLocation("查询我的使用记录")
		 If KS.S("page") <> "" Then
						          CurrentPage = CInt(KS.S("page"))
							Else
								  CurrentPage = 1
							End If
							%>
		<div class="tabs">	
			<ul>
				<li><a href="user_logmoney.asp">资金明细</a></li>
				<li><a href="user_logpoint.asp">点券明细</a></li>
				<li><a href="user_logedays.asp">有效期明细</a></li>
				<li><a href="user_logscore.asp">积分明细</a></li>
				<li class="puton"><a href="user_LogConsum.asp">使用记录</a></li>
			</ul>
		</div>
			<div style="text-align:right;height:30px;line-height:30px;">  <a href='User_LogConsum.asp'><font color=red>＋所有记录</font></a> ＋<a href='?d=1'>今天[<%=conn.execute("select count(1) from KS_LogConsum where username='" & KSUser.UserName & "' and year(AddDate)=" & year(Now) & " and month(AddDate)=" & month(now) & " and day(AddDate)=" & day(now) &"")(0)%>]</a> ＋<a href='?d=2'>2天内[<%=conn.execute("select count(1) from KS_LogConsum where username='" & KSUser.UserName & "' and datediff(" &DataPart_D&",adddate," & SQLNowString &")<2")(0)%>]</a> ＋<a href='?d=7'>一周内[<%=conn.execute("select count(1) from KS_LogConsum where username='" & KSUser.UserName & "' and datediff(" &DataPart_D&",adddate," & SQLNowString &")<7")(0)%>]</a>
		   </div>
				<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1" class="border">
					<tr class=titlename align=middle>
					  <td width=80>用户名</td>
					  <td>标题</td>
					  <td width=150 height="25">使用时间</td>
					  <td width=50>类型</td>
					  <td>分类</td>
					  <td>点击</td>
					</tr>
					<%
					    Dim Param:Param=" Where l.channelid=i.channelid and UserName='" & KSUser.UserName &"'"
					    if ks.s("d")="1" then
						 Param=Param & " and year(l.AddDate)=" & year(Now) & " and month(l.AddDate)=" & month(now) & " and day(l.AddDate)=" & day(now)
						elseif KS.ChkClng(KS.S("d"))<>0 Then Param=Param & " and datediff(" &DataPart_D&",l.adddate," & SQLNowString &")<" & KS.ChkClng(KS.S("D"))
						end if
                        SqlStr="Select l.*,i.hits,i.tid,i.fname From KS_LogConsum l left join ks_iteminfo i on l.infoid=i.infoid " & Param & " order by logid desc"
						
						 Set RS=Server.createobject("adodb.recordset")
						 RS.open SqlStr,conn,1,1

						 If RS.EOF And RS.BOF Then
								  Response.Write "<tr class='tdbg'><td align=center height=25 colspan=9 valign=top>找不到您要的使用记录!</td></tr>"
								 Else
									totalPut = RS.RecordCount
									If CurrentPage < 1 Then CurrentPage = 1
		
			
								If CurrentPage = 1 Then
									Call ShowContent
								Else
									If (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
										Call ShowContent
									Else
										CurrentPage = 1
										Call ShowContent
									End If
								End If
				End If

						
						 %>
					
          </table>
		  </td>
		  </tr>
</table>
		  <%
		  Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
		  <%
  End Sub
    
  Sub ShowContent()
     on error resume next
     Dim I,intotalmoney,outtotalmoney
     Do While Not rs.eof 
	%>
    <tr class=tdbg onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
      <td  class="splittd" align=middle><%=rs("username")%></td>
      <td  class="splittd"><a href="<%=KS.GetItemURL(rs("ChannelID"),rs("Tid"),rs("InfoID"),rs("Fname"))%>" target="_blank"><%=rs("title")%></a></td>
      <td  class="splittd" align=middle><%=rs("adddate")%></td>
      <td   class="splittd" align=middle>
	  <% Select Case rs("basictype")
	      Case 1:Response.WRite "文章"
		  Case 2:Response.Write "图片"
		  Case 3:Response.Write "下载"
		  Case 4:Response.Write "动漫"
		  Case 7:Response.Write "影片"
		  Case 9:Response.Write "试卷"
		 End Select
	 %>
	  </td>
      <td  class="splittd" align=center><%=KS.C_C(RS("Tid"),1)%></td>
      
      <td  class="splittd" align=center><%=rs("hits")%></td>
    </tr>
	<%
	   I = I + 1
	   RS.MoveNext
	  If I >= MaxPerPage Then Exit Do

	 loop
	%>
    
  </table>
		<%
		End Sub
  
End Class
%> 
