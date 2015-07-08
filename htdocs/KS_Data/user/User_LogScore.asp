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
Set KSCls = New User_LogScore
KSCls.Kesion()
Set KSCls = Nothing

Class User_LogScore
        Private KS,KSUser
		Private CurrentPage,totalPut,TotalPages,SQL
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
		Call KSUser.InnerLocation("查询我的积分明细")
		If KS.S("page") <> "" Then
		  CurrentPage = CInt(KS.S("page"))
		Else
		  CurrentPage = 1
		End If
	  %>
		<div class="tabs">	
			<ul>
				<li><a href="user_logmoney.asp">资金明细</a></li>
				<li><a href="user_LogPoint.asp">点券明细</a></li>
				<li><a href="user_logedays.asp">有效期明细</a></li>
				<li class="puton"><a href="user_logscore.asp">积分明细</a></li>
				<li><a href="user_LogConsum.asp">使用记录</a></li>
			</ul>
		</div>
		
	<table width="98%" align="center" border="0">

  <tr>
    <td  style="height:30px;line-height:30px;padding:6px;font-size:14px;" colspan="2">
	   您的总积分：<font color="green"><%=KS.ChkClng(KSUser.GetUserInfo("score"))%></font> 分，已消费：<font color=#ff6600><%=KS.ChkClng(KSUser.GetUserInfo("scorehasuse"))%></font> 分，可用积分：<font color=red>
	   <%=KSUser.GetScore()%> </font>分。
		
	<!-- <a href="?channelid=1000">点广告积分收入明细</a> | <a href="?channelid=1001">点友情链积分收入明细</a>
	-->
	</td>
    <td align="right"><a href='User_LogScore.asp'><font color=red>＋所有记录</font></a> ＋<a href='?InOrOutFlag=1'>收入记录[<%=conn.execute("select count(id) from ks_LogScore where InOrOutFlag=1 and username='" & KSUser.UserName & "'")(0)%>]</a> ＋<a href='?InOrOutFlag=2'>支出记录[<%=conn.execute("select count(id) from ks_LogScore where InOrOutFlag=2 and username='" & KSUser.UserName & "'")(0)%>]</a></td>
  </tr>
</table>

			
				<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1" class="border">
					<tr class="titlename">
					<td width="80" height="25" align="center"><strong> 用户名</strong></td>
					<td align="center"><strong>产生时间</strong></td>
					<td nowrap="nowrap" align="center"><strong>收入</strong></td>
					<td nowrap align="center"><strong>支出</strong></td>
					<td nowrap align="center"><strong>摘要</strong></td>
					<td align="center"><strong> 余额</strong></td>
					<td align="center"><strong>备注</strong></td>
				  </tr>
					<%  
					  dim param
					 If KS.ChkClng(Request("channelid"))<>0 then
					   param=" and channelid=" & KS.ChkClng(Request("channelid"))
					 end if
					 
					If KS.ChkClng(KS.S("InOrOutFlag"))=1 Or KS.ChkClng(KS.S("InOrOutFlag"))=2 Then
						  SqlStr="Select ID,UserName,AddDate,IP,Score,InOrOutFlag,CurrScore,Descript,AvailableScore From KS_LogScore Where InOrOutFlag=" & KS.ChkClng(KS.S("InOrOutFlag")) & " And  UserName='" & KSUser.UserName &"'" & param & " order by id desc"
 					    Else
						  SqlStr="Select ID,UserName,AddDate,IP,Score,InOrOutFlag,CurrScore,Descript,AvailableScore From KS_LogScore Where UserName='" & KSUser.UserName &"'" & param & " order by id desc"
						End if
						 Set RS=Server.createobject("adodb.recordset")
						 RS.open SqlStr,conn,1,1

						 If RS.EOF And RS.BOF Then
								  Response.Write "<tr class='tdbg'><td align=center height=25 colspan=9 valign=top>找不到您要的记录!</td></tr>"
								 Else
									TotalPut=rs.recordcount
									if (TotalPut mod MaxPerPage)=0 then
										TotalPages = TotalPut \ MaxPerPage
									else
										TotalPages = TotalPut \ MaxPerPage + 1
									end if
									if CurrentPage > TotalPages then CurrentPage=TotalPages
									if CurrentPage < 1 then CurrentPage=1
									rs.move (CurrentPage-1)*MaxPerPage
									SQL = rs.GetRows(MaxPerPage)
									rs.Close:set rs=Nothing
									ShowContent
				End If

						
						 %>
          </table>
		  </td>
		  </tr>
</table>
		  <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
		  <br/><br/>
	<table width="98%" align="center" border="0">

  <tr>
    <td  style="height:30px;line-height:30px;padding:6px;font-size:14px;" colspan="2">
	   <strong>积分说明：</strong><br/>
	   1、为避免影响论坛及问答中心的晋级，“消费的积分（如礼品兑换)”直接累计到已消费积分，不扣除总积分。<br/>

	  2、“可用积分”指可用于消费的积分，如可用于兑换礼品的积分， 其中:可用积分=总积分-已消费的积分。  
	</td>
  </tr>
</table>
		  
		  <%
  End Sub
    
  Sub ShowContent
 Dim i,InPoint,OutPoint
For i=0 To Ubound(SQL,2)
	%>
  <tr height="25" class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
    <td width="80" align="center" class="splittd"><%=SQL(1,i)%></td>
    <td align="center" class="splittd"><%=SQL(2,i)%></td>
    <td align="right" nowrap class="splittd"><%if SQL(5,I)=1 Then Response.Write SQL(4,I) & "分":InPoint=InPoint+SQL(4,I) ELSE Response.Write "-"%></td>
    <td align="right" nowrap class="splittd"><%if SQL(5,I)=2 Then Response.Write SQL(4,I) & "分":OutPoint=OutPoint+SQL(4,I) ELSE Response.Write "-"%></td>
    <td align="center" class="splittd"><%if SQL(5,I)=1 Then Response.Write "<font color=red>收入</font>" Else Response.Write "支出"%></td>
    <td nowrap class="splittd">累计<%=SQL(6,i)%>分,可用<font color=green><%=KS.ChkClng(SQL(8,I))%></font>分</td>
	<td width="350" class="splittd"><%=SQL(7,i)%></td>
  </tr>
  <%Next%>
  <tr class='tdbg' onMouseOut="this.className='tdbg'" onMouseOver="this.className='tdbgmouseover'">   
   <td colspan='2'  class="splittd" align='right'>本页合计：</td>    <td  class="splittd" align='right'><%=InPoint%>分</td>    <td align='right'><%=KS.ChkClng(OutPoint)%>分</td>    <td  class="splittd" colspan='4'>&nbsp;</td>  </tr> 
  <% Dim totalinpoint:totalinpoint=conn.execute("Select sum(score) From KS_LogScore where username='" & KSUser.UserName & "'AND InOrOutFlag=1")(0)
     Dim TotalOutPoint:TotalOutPoint=conn.execute("Select sum(score) From KS_LogScore where username='" & KSUser.UserName & "'AND  InOrOutFlag=2")(0)
	 If KS.ChkClng(totalInPoint)=0 Then totalInPoint=0
	 If KS.ChkClng(TotalOutPoint)=0 Then TotalOutPoint=0
  %>
    <tr class='tdbg' onMouseOut="this.className='tdbg'" onMouseOver="this.className='tdbgmouseover'">    <td  class="splittd" colspan='2' align='right'>所有合计：</td>    <td  class="splittd" align='right'><%=KS.ChkClng(totalInPoint)%>分</td>    <td  class="splittd" align='right'><%=KS.ChkClng(totalOutPoint)%>分</td>    <td  style="display:none" class="splittd" colspan='4' align='center'>累计还剩：<%=totalInPoint-totalOutPoint%>分</td>  </tr> 

  <%  

End Sub
  
End Class
%> 
