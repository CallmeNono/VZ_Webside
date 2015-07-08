﻿<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Conn.asp"-->
<!--#include file="../Plus/md5.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%

Dim KSCls
Set KSCls = New User_Order
KSCls.Kesion()
Set KSCls = Nothing

Class User_Order
        Private KS,KSUser
		Private totalPut
		Private RS,MaxPerPage,Action
		Private TempStr,SqlStr,totalscore
		Private InfoIDArr,InfoID,DomainStr
		Private Sub Class_Initialize()
			MaxPerPage =20
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		  DomainStr=KS.GetDomain
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
		Action=Request("action")
		Call KSUser.Head()
		Call KSUser.InnerLocation("我的订单")
		Select Case Action
		  Case "setok" Call setok()   '结清订单
		  Case "OrderDown" Call OrderDown
		  Case "ShowOrder" Call ShowOrder
		  Case "DelOrder" Call DelOrder
		  Case "SignUp"  Call SignUp
		  Case "AddPayment"  Call AddPayment '从账户余额付款
		  Case "SavePayment"  Call SavePayment
		  Case "coupon"  Call CouPon
		  case "dosave"   dosave
		  Case "PaymentOnline"  '在线支付
		   Response.Redirect "User_PayOnline.asp?Action=Payonline&id=" & KS.S("ID")
		  Case Else Call OrderList
		 End Select
		End Sub
		
		'结清订单
		sub setok()
		 dim totalscore,AllianceUser,orderid,scoretf,DeliverStatus,paystatus,usescore
		 dim id:id=KS.ChkClng(Request("id"))
		 Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		 RS.Open "select top 1 * from ks_order where id=" & id & " and username='" & KSUser.UserName & "'",conn,1,1
		 If RS.Eof And RS.Bof Then
		   rs.close:set rs=nothing
		   KS.AlertHintScript "出错啦，找不到订单！"
		 End If
		 totalscore=rs("totalscore")
		 orderid=rs("orderid")
		 scoretf=rs("scoretf")
		 DeliverStatus=rs("DeliverStatus")
		 paystatus=KS.ChkClng(rs("paystatus"))
		 usescore=KS.ChkClng(rs("usescore"))
		 rs.close
		 
		 
		 if totalscore>0 and scoretf="0" and DeliverStatus<>3 and paystatus<>3 then
		    Call KS.ScoreInOrOut(KSUser.UserName,1,totalscore,"系统","商城购物赠送的积分，订单号：" & orderid & "。",0,0)
		    AllianceUser=KSUser.GetUserInfo("AllianceUser")
			if not ks.isnul(AllianceUser) then
			  rs.open "select top 1 groupid from ks_user where username='" & AllianceUser &"'",conn,1,1
			  if not rs.eof then
			    if KS.U_S(rs("GroupID"),19)="1"  then   '享受推广获积分
				   dim per:per=KS.U_S(rs("GroupID"),20)
				   if not isnumeric(per) then per=0
				   if per>0 then
				      dim myscore:myscore=KS.ChkClng(totalscore*per/100)
					  if myscore>0 then
					   	Call KS.ScoreInOrOut(AllianceUser,1,myscore,"系统","您推荐的用户[" & KSUser.UserName & "]在商城购物成功,订单号：" & orderid & "，您享受该订单总赠送积分(" & totalscore & "分)的 " & per& "% 奖励。",0,0)

					  end if
				   end if
				end if
			  end if
			  rs.close
			end if
		 elseif paystatus=3 or DeliverStatus=3 and usescore>0 then  '退货或是退款时返还积分
			Session("ScoreHasUse")="-" '设置只累计消费积分
			Call KS.ScoreInOrOut(KSUser.UserName,1,usescore,"系统","购物失败，返还积分。订单号<font color=red>" & orderid & "</font>!",0,0)

		 end if
		 set rs=nothing
		 Conn.Execute("update ks_order set status=2,scoretf=1 where UserName='" & KSUser.UserName & "' and id=" & id)
		
		 '判断自动升级
		 call KSUser.UserAutoUpdateGroup(ksuser.username)
		 
		 KS.Die "<script>alert('恭喜，订单已结清!');location.href='user_order.asp';</script>"
		end sub
		
		Sub OrderList()
		%>
		<div class="tabs">	
			<ul>
				<li<%If action<>"coupon" then ks.echo " class='puton'"%>><a href="?">我的订单</a></li>
				<li<%If action="coupon" then ks.echo " class='puton'"%>><a href="?action=coupon">我的优惠券</a></li>
			</ul>
        </div>
				
				<div class="writeblog">
				 <table border="0">
				<form action="user_order.asp" method="post" name="search">
				 <tr><td><strong>订单状态:</strong></td>
				 <td>
				<select class="select" name="OrderStatus">
				 <option value="">不限制</option>
				  <option value="0">等待确认</option>
				  <option value="1">已经确认</option>
				  <option value="2">已结清</option>
				</select></td>
				<td><strong>订单编号:</strong></td>
				<td>
				 <input type="text" name="keyword" class="textbox">
				 <input type="submit" value="快速搜索" class="button">
				</td>
				</tr>
				</form>				   
				</table>
				</div>

				<table width="100%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
					<tr class=title align=middle>
					  <td height="25">订单编号</td>
					  <td>收货人</td>
					  <td>下单时间</td>
					  <td>赠送积分</td>
					  <td>应付金额</td>
					  <td>已付金额</td>
					  <td>发票信息</td>
					  <td>订单状态</td>
					  <td>付款状态</td>
					  <td>物流状态</td>
					  <td>服务跟踪</td>
					</tr>
					<%
					  Dim Param:Param=" Where UserName='" & KSUser.UserName & "'"
					  If KS.S("OrderStatus")<>"" Then 
					    Param=Param & " and status=" & KS.ChkClng(KS.S("OrderStatus"))
					  End If
					  If KS.S("KeyWord")<>"" Then  
					    Param=Param & " and OrderID like '%" & KS.S("KeyWord") & "%'"
					  End If
					  
						 SqlStr="Select * From KS_Order " & Param & " order by id desc"
						 Set RS=Server.createobject("adodb.recordset")
						 RS.open SqlStr,conn,1,1

				If RS.EOF And RS.BOF Then
								  Response.Write "<tr class='tdbg'><td align=center height=25 colspan=9 valign=top>您没有下任何订单!</td></tr>"
				Else
					totalPut = RS.RecordCount
					If (CurrentPage - 1) * MaxPerPage < totalPut Then
							RS.Move (CurrentPage - 1) * MaxPerPage
					End If
					Call ShowContent
				End If
           %>
					
          </table>
		  <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
		  </td>
		  </tr>
</table>
      </div>
		  <%
  End Sub
    
  Sub ShowContent()
    Dim i,MoneyTotal,MoneyReceipt
   Do While Not RS.Eof
		%>
                <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
                       <td height='30' nowrap="nowrap" class="splittd"><a href="User_Order.asp?Action=ShowOrder&ID=<%=RS("ID")%>"><%=rs("orderid")%></a>          <%if rs("ordertype")="1" then
				  response.write "<font color=red><b><i>团</li></b></font>"
				  end if
				 %>
					   </td>
					   <td class="splittd" height="22" align="center"><%=rs("contactman")%></td>
                       <td class="splittd" align="center"><%=KS.GetTimeFormat(rs("inputtime"))%></td>
                       <td class="splittd" align="center">
					   <%
					    if rs("totalscore")>0 and rs("DeliverStatus")<>3 then
						   response.write "<font color=green>" & rs("totalscore") & " 分</font>"
						   if rs("scoretf")=1 then
						     response.write "<font color=#999999>,已送</font>"
						   else
						     response.write "<font color=red>,未送</font>"
						   end if
						else
						   response.write "无"
						end if
					    %>
					   </td>
                       <td class="splittd" align="right"><%=formatnumber(rs("MoneyTotal"),2,-1)%></td>
                       <td class="splittd" align="right"><%=formatnumber(rs("MoneyReceipt"),2,-1)%></td>
                       <td class="splittd" align="center">
											<%If RS("NeedInvoice")=1 Then
											     Response.Write "<Font color=red>需要</font>"
											  	 If RS("Invoiced")=1 Then
												   Response.Write "<font color=green>(已开)</font>"
												  Else
												   Response.Write "<font color=red>(未开)</font>"
												  End If
                                              Else
											    Response.Write "-"
											  End If
											 
											  %>
						</td>
                        <td class="splittd" align="center">
											<%If RS("Status")=0 Then
												  Response.Write "<font color=red>等待确认</font>"
												  ElseIf RS("Status")=1 Then
												  Response.WRITE "<font color=green>已经确认</font>"
												  ElseIf RS("Status")=2 Then
												  Response.Write "<font color=#a7a7a7>已结清</font>"
												  ElseIf RS("Status")=3 Then
												  Response.Write "<font color=#a7a7a7>无效订单</font>"
				                              End If%></td>
                           <td class="splittd" align="center">
											<%
										if rs("alipaytradestatus")<>"" and RS("Status")<>2 then
				  select case rs("alipaytradestatus")
				    Case "WAIT_BUYER_PAY" Response.Write "<font color=red>等待汇款</font>"
					Case "WAIT_SELLER_SEND_GOODS" Response.Write "<font color=brown>已付款等待发货</font>"
					Case "WAIT_BUYER_CONFIRM_GOODS" Response.Write "<font color=blue>等待买家确认收货</font>"
					Case "TRADE_FINISHED" Response.Write "<font color=#a7a7a7>交易完成</font>"
				  end select
				else
					if rs("paystatus")="100" then
					  Response.WRITE "<font color=""green"">凭单消费</font>"
					elseif rs("paystatus")="3" then
					  Response.WRITE "<font color=blue>退款</font>"
					elseIf RS("MoneyReceipt")<=0 Then
					   Response.Write "<font color=red>等待汇款</font>"
					ElseIf RS("MoneyReceipt")<RS("MoneyTotal") Then
					   Response.WRITE "<font color=blue>已收定金</font>"
					Else
					   Response.Write "<font color=green>已经付清</font>"
					End If
				end if	  %></td>
                         <td class="splittd" align="center">				
							<% If RS("DeliverStatus")=0 Then
											 Response.Write "<font color=red>未发货</font>"
											 ElseIf RS("DeliverStatus")=1 Then
											  Response.Write "<font color=blue>已发货</font>"
											 ElseIf RS("DeliverStatus")=2 Then
											  Response.Write "<font color=green>已签收</font>"
											 ElseIf RS("DeliverStatus")=3 Then
											  Response.Write "<font color=#ff6600>退货</font>"
											 End If
						 %></td>
                         <td class="splittd" align="center">				
							<% If RS("isservice")="1" Then
								 Response.Write "<a href='?Action=ShowOrder&ID=" & rs("id") & "#service'><font color=blue>查看</font></a>"
								Else
								Response.Write "<font color=""#999999"">不需要</font>"
								End If
						 %></td>

                          </tr>

                        <%
							MoneyReceipt=RS("MoneyReceipt")+MoneyReceipt
							MoneyTotal=RS("MoneyTotal")+MoneyTotal
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
 <tr align='center' class='tdbg' onMouseOut="this.className='tdbg'" onMouseOver="this.className='tdbgmouseover'">           <td colspan='4' align='right'><b>本页合计：</b></td>           <td align='right'><%=formatnumber(MoneyTotal,2)%></td>           <td align='right'><%=formatnumber(MoneyReceipt,2)%></td>           <td colspan='5'>&nbsp;</td>         </tr> 
 <tr align='center' class='tdbg' onMouseOut="this.className='tdbg'" onMouseOver="this.className='tdbgmouseover'">           <td colspan='4' align='right'><b>所有总计：</b></td>           <td align='right'><%=formatnumber(Conn.execute("Select sum(moneytotal) from KS_Order Where UserName='" & KSUser.UserName & "'")(0),2)%></td>           <td align='right'><%=formatnumber(Conn.execute("Select sum(MoneyReceipt) from KS_Order Where UserName='" & KSUser.UserName & "'")(0),2)%></td>           <td colspan='5'>&nbsp;</td>         </tr> 
 <%  End Sub
		
Sub ShowOrder()
		 Dim ID:ID=KS.ChkClng(KS.S("ID"))
		 Dim RS:Set RS=Server.CreateObject("adodb.recordset")
		 RS.Open "Select * from ks_order where username='" & KSUser.UserName & "' and id=" & ID ,conn,1,1
		 IF RS.Eof And RS.Bof Then
		   RS.Close:Set RS=Nothing
		   Response.Write "<script>alert('参数错误!');history.back();</script>"
		   response.end
		 End If
		 
		response.write "<br>"
		response.write OrderDetailStr(RS)
         %><br/>
		 
		 <div align=center id='buttonarea'>
		 <% 
If RS("Status")=3 Then
		response.write "本订单在指定时间内没有付款,已作废!"
Else
		 if rs("status")=0 and rs("DeliverStatus")=0 and rs("MoneyReceipt")=0 Then%>
		 <input class="button" type='button' name='Submit' value='删除订单' onClick="javascript:if(confirm('确定要删除此订单吗？')){window.location.href='User_Order.asp?Action=DelOrder&ID=<%=rs("id")%>';}">&nbsp;&nbsp;
		 <%end if%>
		 <%If RS("MoneyReceipt")<RS("MoneyTotal") and rs("paystatus")<>3 and rs("paystatus")<>100 Then%>
		 <span>
		 <input class="button" type='button' name='Submit' value='在线支付' onClick="window.location.href='user_PayOnline.asp?Action=Payonline&ID=<%=rs("id")%>'">
		 </span>
		 <input class="button" type='button' name='Submit' value='从余额中扣款支付' onClick="window.location.href='User_Order.asp?Action=AddPayment&ID=<%=rs("id")%>'">&nbsp;&nbsp;
		 <%end if%>
		 <% if rs("DeliverStatus")=1 Then%>
		 <input class="button" type='button' name='Submit' value='签收商品' onClick="window.location.href='User_Order.asp?Action=SignUp&ID=<%=RS("ID")%>'">
		 <%end if%>
		 <%
		 end if
             If RS("Status")<>2 Then
			   If RS("MoneyReceipt")>=RS("MoneyTotal") and  RS("PayStatus")<>"3"  and rs("DeliverStatus")<>3 Then
			   %>
			   <%if rs("totalscore")>0  and rs("DeliverStatus")<>3 and rs("usescoremoney")<=0 then%>
			   <input type="button" value="满意无需退换货,立即获得<%=totalscore%>分积分" onclick="if (confirm('结清订单后将不可以再申请退换货,确定结清吗？')){location.href='?action=setok&id=<%=rs("id")%>';}" class="button" />
			   <%else%>
			   <input type="button" value="结清订单" onclick="if (confirm('结清订单后将不可以再申请退换货,确定结清吗？')){location.href='?action=setok&id=<%=rs("id")%>';}" class="button" />
			   <%end if%>
			  <%ElseIf RS("PayStatus")="3" or rs("DeliverStatus")=3 Then
			    if rs("usescore")>0 then
				%>
			   <input type="button" value="结清订单,返还我的<%=rs("usescore")%>分积分" onclick="if (confirm('结清订单将立即返还您的积分，确定结清吗？')){location.href='?action=setok&id=<%=rs("id")%>';}" class="button" />
				<%
				else
				%>
			   <input type="button" value="结清订单" onclick="if (confirm('确定结清吗？')){location.href='?action=setok&id=<%=rs("id")%>';}" class="button" />
				<%
				end if
			   end if
			End If
		 %>
		 <input class="button" type='button' name='Submit' value='打印订单' onClick="document.all.buttonarea.style.display='none';window.print();">
		&nbsp; <input class="button" type='button' name='Submit' value='订单首页' onClick="location.href='User_Order.asp';">
		 </div>
		 <br />
	<%if rs("isservice")="1" then%>
		<a name="service"></a><strong> 服务记录明细：<br/></strong>
		 <%
		         dim times,sytimes,validity,firstservicetime
				  times=conn.execute("select count(1) from ks_orderservice where orderid=" & rs("id"))(0)
				  if times>rs("servicetimes") then sytimes=0 else sytimes=rs("servicetimes")-times
				  dim rsi:set rsi=conn.execute("select top 1 adddate from ks_orderservice where orderid=" & rs("id"))
				  if not rsi.eof then
					firstservicetime=rsi(0)
					validity=dateadd("m",rs("validity"),firstservicetime)
				  else
					validity=dateadd("m",rs("validity"),now)
				  end if
				  rsi.close
				  set rsi=nothing
				  %>
				   <div style="border:#B2D9F6 1px solid; line-height:26px;padding-left:5px;margin-bottom:10px;background:#F3F9FF;">
				  
				  服务商品名称：<%=rs("servicename")%>&nbsp;&nbsp;服务次数：<%=rs("servicetimes")%>次,剩余：<font color=red><%=sytimes%></font>次&nbsp;服务有效期：<%=rs("validity")%>个月,载止日期：<%=year(validity) & "-" & month(validity) & "-" & day(validity)%>
				   
				   </div>
				 <table  cellpadding="1" style="margin-bottom:6px;border:1px solid #999;" cellspacing="1" width="100%">

				   <tr style="background:#f1f1f1;height:23px;text-align:center">
					  <td width="50">次数</td>
					  <td width="350">内容</td>
					  <td width="70">时间</td>
					  <td width="70">签收人</td>
				   </tr>
				   <%
				   dim rss:set rss=server.CreateObject("adodb.recordset")
				   RSS.Open "select * from ks_orderservice where orderid=" & rs("id") & " order by id desc",conn,1,1
				   if RSS.Eof Then
					str="<tr><td colspan=4 class=""splittd"">没有找到服务记录！</td></tr>"
				   Else
					dim totalnum:totalnum=rss.recordcount
					dim str,num,qsr
					num=0
					if totalnum<5 then
					str="<tr><td colspan=4><div>"
					else
					str="<tr><td colspan=4><div style=""overflow-x:hidden;overflow-y:auto;height:130px"">"
					end if
					do while not rss.eof
					str=str &"<table width='100%' cellspacing='0' cellpadding='0' border='0'>"
					str=str &"<tr id='tr1" & rss("id") & "'>"
					str=str &"<td width=""50"" height=""25"" class=""splittd"">第" & totalnum-num & "次</td>"
					str=str &"<td width=""350"" class=""splittd"" style=""width:290px;word-break:break-all;"">" & rss("content") & "</td>"
					str=str &"<td width=""70"" class=""splittd"" style='text-align:center'>" & year(rss("adddate")) & "-" & month(rss("adddate")) & "-" & day(rss("adddate")) & "</td>"
					qsr=rss("qsr")
					if ks.isnul(qsr) then qsr="---"
					str=str &"<td width=""70"" class=""splittd"" style='text-align:center'>&nbsp;" & qsr & "&nbsp;</td>"
					str=str &"</tr></table>"
					num=num+1
					rss.movenext
					loop
					str=str & "</div></td></tr>"
				  end if
				  rss.close
					response.write str
					
				  %>
				 </table>
		<%
		end if
		 rs.close:set rs=nothing
		End Sub
		
		'优惠券
		Sub Coupon
		Call KSUser.InnerLocation("优惠券查询")
		%>
		<div class="tabs">	
			<ul>
				<li<%If action<>"coupon" then ks.echo " class='puton'"%>><a href="?">我的订单</a></li>
				<li<%If action="coupon" then ks.echo " class='puton'"%>><a href="?action=coupon">我的优惠券</a></li>
			</ul>
        </div>
        <script src="../ks_inc/kesion.box.js"></script>
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="border">
			<tr height="28" class="title">
				<td height="25" align="center">优惠券号</td>
				<td height="25" align="center">优惠券名称</td>
				<td align="center">面值</td>
				<td align="center">剩余金额</td>
				<td  align="center">最小订单金额</td>
				<td  align="center">截止使用日期</td>
				<td align="center">最大抵扣额</td>
				<td align="center">使用情况</td>
			</tr>
		<% 
			set rs=server.createobject("adodb.recordset")
			sql="select a.*,b.title,b.enddate,b.facevalue,b.minamount,b.maxdiscount from KS_ShopCouponUser a inner join KS_ShopCoupon b on a.couponid=b.id where a.Username='"&KSUser.UserName&"' order by a.id desc"
			rs.open sql,Conn,1,1
			if rs.eof and rs.bof then
		%>
			<tr>
				<td height="26" colspan=10align=center valign=middle  class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">对不起,暂没有优惠券可用！</td>
			</tr>
		<%else
		
		                       totalPut = RS.RecordCount
								
								   If CurrentPage > 1  and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
									End If
									i=0
		      do while not rs.eof
		%>
						<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
							<td class="splittd" align="center"><div class="ContentTitle"><%=rs("couponnum")%></div></td>
							<td height="25" class="splittd">
							<%=rs("title")%>
							
							</td>
							<td class="splittd" align=center>
							<%=RS("facevalue")%> 元
							</td>
							<td class="splittd" align=center>
							<font color=red><%=RS("AvailableMoney")%></font> 元
							</td>
							<td class="splittd" align=center>
							<%=RS("minAmount")%> 元
							</td>
							<td class="splittd" align=center>
							<%=formatdatetime(RS("EndDate"),2)%>
							</td>
							<td class="splittd" align=center>
							<%
							If rs("maxdiscount")="0" Then
							Response.Write "实际优惠券面值"
						   Else
							Response.Write "按订单总额的" & formatnumber(rs("maxdiscount"),2,-1) & "%,但不超过实际优惠券面值"
						   End If
							%>
							
							</td>
							
							<td class="splittd" align=center>
							<%select case  rs("useflag")
								 case 1
								     if RS("AvailableMoney")>0 then
									  response.write "已使用,未用完"
									 else
									  response.write "已用完"
									 end if
									 response.write "<span style='cursor:pointer' onclick=""new KesionPopup().mousepopup('说明','" & RS("note") & "',300)""><font color=blue>(详情)</font></span>"
								 case else
								  response.write " <font color=#999999>未使用</font>"
								end select
							%>
							</td>
							
						</tr>
		<%
			  rs.movenext
			  I = I + 1
			  If I >= MaxPerPage Then Exit Do
			
			loop
			end if
			rs.close
			set rs=Nothing
		%>
						
				
</table>
   
    <div style="text-align:right">
   <%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
    </div>
	<div style="clear:both"></div>
	  <br><br><br>
	  
	  <table width="98%" border="0" align="center" cellpadding="0" cellspacing="1" class="border">
	        <form name="myform" action="?action=dosave" method="post">
	        <tr>
			   <td height="35" class="title">&nbsp;<img src="images/VIP.png" align="absmiddle"> <strong>添加优惠券</strong></td>
			<tr>
				<td height="45">&nbsp;&nbsp;&nbsp;&nbsp; <strong>请输入优惠券号:</strong>
				<input type="text" name="CouponNum" class="textbox">
				<input type="submit" value=" 添 加 " class="button">
				</td>
			</tr>
			</form>
	   </table>	

		<%
		end sub
		Sub dosave()
		   Dim CouponNum:CouponNum=KS.S("CouponNum")
	   
		
	       If CouponNum="" Then Response.Write "<script>alert('优惠券号必须输入!');history.back();</script>":response.end
           If KS.ChkClng(Session("CouponNum"))>=3 Then 
		    Response.Write "<script>alert('对不起,您的错误次数过多,已关闭!');history.back();</script>":response.end
		   End If
            Dim RS: Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select * From KS_ShopCouponUser Where CouponNum='" & CouponNum & "'",Conn,1,3
			  If RS.Eof And RS.Bof Then
			   Session("CouponNum")=KS.ChkClng(Session("CouponNum"))+1
			   RS.Close:Set RS=Nothing
			   Response.Write "<script>alert('对不起,您输入的优惠券号不正确!错误次数" & Session("CouponNum") & "次!');history.back();</script>":response.end 
			  ElseIf RS("UserName")<>"" And Not IsNull(RS("UserName")) Then
			   RS.Close:Set RS=Nothing
			   Response.Write "<script>alert('对不起,您输入的优惠券号已被添加!');history.back();</script>":response.end 
			  Else
				 RS("UserName")=KSUser.UserName
		 		 RS.Update
			 End If
			     RS.Close
				 Set RS=Nothing
            Response.Write "<script>alert('恭喜,优惠券添加成功!');location.href='" & Request.ServerVariables("HTTP_REFERER") & "';</script>"
	   End Sub
		
		'删除订单
		Sub DelOrder()
		  Dim ID:ID=KS.ChkClng(KS.S("ID"))
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select OrderID,CouponUserID From KS_Order where username='" & KSUser.UserName & "' and status=0 and DeliverStatus=0 and MoneyReceipt=0 and id=" & ID,Conn,1,3
		 If Not rs.EOF Then
		   Conn.execute("Update KS_ShopCouponUser Set UseFlag=0,OrderID='' Where ID=" & rs(1))
		   Conn.execute("delete from ks_orderitem Where OrderID='" & rs(0) &"'")
		   rs.delete
		 End if
         Response.redirect "User_Order.asp"
		End Sub
		
		'签收商品
		Sub SignUp()
		 Dim OrderID,id:ID=KS.ChkClng(KS.S("ID"))
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select * From KS_Order Where UserName='" & KSUser.UserName & "' and ID=" & ID,Conn,1,3
		 If RS.Eof Then
		  rs.close:set rs=nothing
		  response.write "<script>alert('出错啦!');history.back();</script>":response.end
		 End If
         rs("DeliverStatus")=2
		 rs("BeginDate")=Now
		 rs.update
		 OrderID=RS("OrderID")
		 rs.close:set rs=nothing
		 Conn.execute("Update KS_LogDeliver Set Status=1 Where OrderID='" & OrderID & "'")
		 Response.Redirect "User_Order.asp?Action=ShowOrder&ID=" & id
		End Sub
		
		Sub AddPayment()
		 Dim ID:ID=KS.ChkClng(KS.S("ID"))
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select top 1 * From KS_Order Where UserName='" & KSUser.UserName & "' and ID="& ID,Conn,1,1
		 If RS.Eof Then
		  rs.close:set rs=nothing
		  response.write "<script>alert('出错啦!');history.back();</script>":response.end
		 End If
		 
		 If KS.ChkCLng(KS.Setting(49))=1 Then
		  If RS("Status")=0 Then
		    RS.Close:Set RS=Nothing
		   	KS.Die "<script>alert('对不起，该订单还未确认，本站启用只有后台确认过的订单才能付款!');history.back();</script>"
		  End If
		End If
		 %>
		 <FORM name=form4 onSubmit="return confirm('确定所输入的信息都完全正确吗？一旦确认就不可更改哦！')" action=User_Order.asp method=post>
  <table class=border cellSpacing=1 cellPadding=2 width="98%" align="center" border=0>
    <tr class=title align=middle>
      <td colSpan=2 height=22><B>使用账户资金支付订单</B></td>
    </tr>
    <tr class=tdbg>
      <td align=right><B>用 户 名：</B></td>
      <td align=left><%=KSUser.UserName%></td>
    </tr>
    <tr class=tdbg>
      <td align=right><B>客户名称：</B></td>
      <td align=left><%=RS("ContactMan")%></td>
    </tr>
    <tr class=tdbg>
      <td align=right><B>资金余额：</B></td>
      <td align=left><%=formatnumber(KSUser.GetUserInfo("Money"),2,-1)%> 元 <%if Round(KSUser.GetUserInfo("Money"),2)<=0 then response.write "<a href=""user_payonline.asp"">资金不足,请点此充值</a>"%></td>
    </tr>
    <tr class=tdbg>
      <td align=right><B>支付内容：</B></td>
      <td align=left>
        <table cellSpacing=2 cellPadding=0 border=0>
          <tr>
            <td align=right>订单编号：</td>
            <td align=left>
              <%=RS("OrderID")%></td>
          </tr>
          <tr>
            <td align=right>订单金额：</td>
            <td align=left><font color=red><%=formatnumber(RS("MoneyTotal"),2,-1)%></font> 元</td>
          </tr>
          <tr>
            <td align=right>已 付 款：</td>
            <td align=left>
             <font color=blue><%=formatnumber(RS("MoneyReceipt"),2,-1)%></font> 元</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr class=tdbg>
      <td align=right><B>支出金额：</B></td>
      <td align=left>
        <Input id="Money" readonly maxLength=20 size=10 value="<%=rs("moneytotal")-rs("MoneyReceipt")%>" name="Money"> 元&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=#0000ff>支付成功后，将从您的资金余额中扣除相应款项。</font></td>
    </tr>
    <tr class=tdbg>
      <td colSpan=2 height=30><B><font color=#ff0000>注意：支出信息一旦录入，就不能再修改！所以在保存之前确认输入无误！</font></B></td>
    </tr>
    <tr class=tdbg align=middle>
      <td colSpan=2 height=30>
  <Input id=Action type="hidden" value="SavePayment" name="Action"> 
  <Input id=ID type=hidden value="<%=rs("id")%>" name="ID"> 
        <Input type=submit value=" 确认支付 " class="button" name=Submit></td>
    </tr>
  </table>
</FORM>
		 <%
		 rs.close:set rs=nothing
		End Sub
		
		'开始余额支付操作
		Sub SavePayment()
		 Dim ID:ID=KS.ChkClng(KS.S("ID"))
		 Dim Money:Money=KS.S("Money")
		 If Not IsNumeric(Money) Then Response.Write "<script>alert('请输入有效的金额!');history.back();</script>":Response.end
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select top 1 * From KS_Order Where UserName='" & KSUser.UserName & "' and ID=" & ID,Conn,1,3
		 If RS.Eof Then
		   RS.Close:Set RS=Nothing
		   Response.Write "<script>alert('出错啦!');history.back();</script>"
		 End If
		 If Round(Money,2)>Round(KSUser.GetUserInfo("Money"),2) or Round(KSUser.GetUserInfo("Money"),2)<=0  Then
		  %>
		  <br><br>
		  <table cellpadding=2 cellspacing=1 border=0 width=400 class='border' align=center>
		  <tr align='center' class='title'><td height='22'><strong>错误信息</strong></td></tr>
		  <tr class='tdbg'><td height='100' valign='top'><b>产生错误的可能原因：</b><li>您输入的支付金额超过了您的资金余额，无效支付！</li></td></tr>
		  <tr align='center' class='tdbg'><td><a href='javascript:history.go(-1)'>&lt;&lt; 返回上一页</a></td></tr>
		</table>
		  <%
		  RS.Close:Set RS=Nothing:Exit Sub
		 End If
		   RS("MoneyReceipt")=RS("MoneyReceipt")+Money
		   Dim OrderStatus:OrderStatus=rs("status")
		   RS("Status")=1
		   RS("PayTime")=now   '记录付款时间
		   RS.Update
		   If RS("MoneyReceipt")>=RS("MoneyTotal") Then
		  	 RS("PayStatus")=1  '已付清
		  ElseIf RS("MoneyReceipt")<>0 Then
		     RS("PayStatus")=2  '已收定金
		  Else
		     RS("PayStatus")=0  '未付款
		  End If
		  RS.Update

		   Call KS.MoneyInOrOut(RS("UserName"),RS("Contactman"),Money,4,2,now,RS("OrderID"),KSUser.UserName,"支付订单费用，订单号：" & RS("Orderid"),0,0,0)

	
					'====================更新库存量========================
					If RS("MoneyReceipt")>=RS("MoneyTotal") Then
						Dim rsp:set rsp=conn.execute("select id,title from ks_product where id in(select proid from KS_OrderItem where orderid='" & rs("orderid") & "')")
						do while not rsp.eof
						  dim rsi:set rsi=conn.execute("select amount,attrid from ks_orderitem where orderid='" & rs("orderid") & "' and proid=" & rsp(0))
						  if not rsi.eof then
							  if OrderStatus<>1 Then  '扣库存量
							   If RSI("AttrID")<>0 Then
								  Conn.Execute("update KS_ShopSpecificationPrice set amount=amount-" & RSI(0) & " Where amount>=" & RSI(0) & " and ID=" & RSI(1))
							  Else
							   conn.execute("update ks_product set totalnum=totalnum-" & rsi(0) &" where totalnum>=" & rsi(0) &" and id=" & rsp(0))        
							  End If
							  End If
						  end if
						  rsi.close
						  set rsi=nothing
						  'Call KS.ScoreInOrOut(KSUser.UserName,1,KS.ChkClng(rsp(0))*amount,"系统","购买商品<font color=red>" & rsp("title") & "</font>赠送!",0,0)
						rsp.movenext
						loop
						rsp.close
						set rsp=nothing
					End If
					'================================================================
		 
		 RS.Close:Set RS=Nothing
		  Response.Redirect "User_Order.asp?Action=ShowOrder&id=" & id 
		End Sub
		
		'返回订单详细信息
		Function  OrderDetailStr(RS)
		 OrderDetailStr="<table width='98%' border='0' align='center' cellpadding='2' cellspacing='1' class='border'> "&vbcrlf
		 OrderDetailStr=OrderDetailStr & "<tr align='center' class='title'>    <td height='22'><b>订 单 信 息</b>（订单编号：" & RS("ORDERID") & "）</td>  </tr>"&vbcrlf
		 OrderDetailStr=OrderDetailStr & "<tr>" & vbcrlf
		 OrderDetailStr=OrderDetailStr & " <td height='25'>" &vbcrlf
		 OrderDetailStr=OrderDetailStr & "  <table width='100%'  border='0' cellpadding='2' cellspacing='0'> "   & vbcrlf
		 OrderDetailStr=OrderDetailStr & "    <tr class='tdbg'>"
		 OrderDetailStr=OrderDetailStr & "	         <td width='18%'>客户姓名：<font color='red'>" & RS("Contactman") & "</td>      "
		 OrderDetailStr=OrderDetailStr & "			 <td width='20%'>用 户 名：<font color='red'>" & rs("username") & "</td> " &vbcrlf
		OrderDetailStr=OrderDetailStr & "			 <td width='20%'>获赠积分："
		if rs("totalscore")=0  or rs("DeliverStatus")=3 then
			OrderDetailStr=OrderDetailStr & "无"
		else
			if rs("scoretf")=1 then
			OrderDetailStr=OrderDetailStr & "<font color=green>" & rs("totalscore") & "分,已送出</font>"
			else
			OrderDetailStr=OrderDetailStr & "<font color=red>" & rs("totalscore") & "分,未送出</font>"
			end if
		end if
		OrderDetailStr=OrderDetailStr & "			 </td><td width='18%'>购买日期：<font color='red'>" & formatdatetime(rs("inputtime"),2) & "</font></td>" & vbcrlf
		OrderDetailStr=OrderDetailStr & "			 <td width='24%'>下单时间：<font color='red'>" & formatdatetime(rs("inputtime"),2) & "</font></td>" & vbcrlf
		OrderDetailStr=OrderDetailStr & "	</tr>"
		OrderDetailStr=OrderDetailStr & "	<tr class='tdbg'> "      
		OrderDetailStr=OrderDetailStr & "	  <td width='18%'>需要发票："
			    If RS("NeedInvoice")=1 Then
				  OrderDetailStr=OrderDetailStr & "<Font color=red>√</font>"
				  Else
				  OrderDetailStr=OrderDetailStr & "<font color=red>×</font>"
				  End If
		OrderDetailStr=OrderDetailStr & "		 </td> "       
		OrderDetailStr=OrderDetailStr & "	 <td width='20%'>已开发票："	
				  If RS("Invoiced")=1 Then
				   OrderDetailStr=OrderDetailStr & "<font color=green>√</font>"
				  Else
				   OrderDetailStr=OrderDetailStr & "<font color=red>×</font>"
				  End If
		OrderDetailStr=OrderDetailStr & "	</td> "
		OrderDetailStr=OrderDetailStr & "	<td width='20%'>订单状态："	
			if RS("Status")=0 Then
				 OrderDetailStr=OrderDetailStr & "<font color=red>等待确认</font>"
				  ElseIf RS("Status")=1 Then
				 OrderDetailStr=OrderDetailStr & "<font color=green>已经确认</font>"
				  ElseIf RS("Status")=2 Then
				 OrderDetailStr=OrderDetailStr & "<font color=#a7a7a7>已结清</font>"
				  End If
		OrderDetailStr=OrderDetailStr & "	</td>"
		OrderDetailStr=OrderDetailStr & "	  <td width='18%'>付款情况："	
		if rs("paystatus")="100" then
				OrderDetailStr=OrderDetailStr & "<font color=""green"">凭单消费</font>"
		elseif rs("paystatus")="3" then
				   OrderDetailStr=OrderDetailStr & "<font color=blue>退款</font>"
		   else	
			     If RS("MoneyReceipt")<=0 Then
				   OrderDetailStr=OrderDetailStr & "<font color=red>等待汇款</font>"
				  ElseIf RS("MoneyReceipt")<RS("MoneyTotal") Then
				   OrderDetailStr=OrderDetailStr & "<font color=blue>已收定金</font>"
				  Else
				  OrderDetailStr=OrderDetailStr & "<font color=green>已经付清</font>"
				  End If
           end if
       OrderDetailStr=OrderDetailStr & "</td>"
	   OrderDetailStr=OrderDetailStr & "        <td width='24%'>物流状态："
				if RS("DeliverStatus")=0 Then
				 OrderDetailStr=OrderDetailStr & "<font color=red>未发货</font>"
				 ElseIf RS("DeliverStatus")=1 Then
				  OrderDetailStr=OrderDetailStr & "<font color=blue>已发货</font>"
				 ElseIf RS("DeliverStatus")=2 Then
				  OrderDetailStr=OrderDetailStr & "<font color=blue>已签收</font>"
				 ElseIf RS("DeliverStatus")=3 Then
				  OrderDetailStr=OrderDetailStr & "<font color=#ff6600>退货</font>"
				 End If
	OrderDetailStr=OrderDetailStr & "		</td></tr>    </table> "
    OrderDetailStr=OrderDetailStr & " </td>  </tr> " 
	OrderDetailStr=OrderDetailStr & "   <tr align='center'>"
	OrderDetailStr=OrderDetailStr & "       <td height='25' style='text-align:left'>"
	OrderDetailStr=OrderDetailStr & "	   <table width='100%' border='0' cellpadding='2' cellspacing='1'>"
	OrderDetailStr=OrderDetailStr & "	           <tr class='tdbg'>"
	OrderDetailStr=OrderDetailStr & "			             <td width='12%' align='right'>收货人姓名：</td>"
	OrderDetailStr=OrderDetailStr & "						 <td width='38%'>" & rs("contactman") & "</td>"
	OrderDetailStr=OrderDetailStr & "						 <td width='12%' align='right'>联系电话：</td> "      
	OrderDetailStr=OrderDetailStr & "						 <td width='38%'>" & rs("phone") & "</td>"
	OrderDetailStr=OrderDetailStr & "				</tr>"
	OrderDetailStr=OrderDetailStr & "				<tr class='tdbg' valign='top'>"
	OrderDetailStr=OrderDetailStr & "				          <td width='12%' align='right'>收货人地址：</td>"    
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>" & rs("address") & "</td>"          
	OrderDetailStr=OrderDetailStr & "						  <td width='12%' align='right'>邮政编码：</td>"    
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>" &rs("zipcode") & "</td>"
	OrderDetailStr=OrderDetailStr & "				</tr>  "      
	OrderDetailStr=OrderDetailStr & "				<tr class='tdbg'> "         
	OrderDetailStr=OrderDetailStr & "				          <td width='12%' align='right'>收货人邮箱：</td>"    
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>" & rs("email") & "</td> "         
	OrderDetailStr=OrderDetailStr & "						  <td width='12%' align='right'>收货人手机：</td>"    
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>" & rs("mobile") & "</td>       "
	OrderDetailStr=OrderDetailStr & "			   </tr>"        
	OrderDetailStr=OrderDetailStr & "			   <tr class='tdbg'> "         
	OrderDetailStr=OrderDetailStr & "			              <td width='12%' align='right'>付款方式：</td>"    
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>" & KS.ReturnPayMent(rs("PaymentType"),0) & "</td>"   
	if rs("tocity")="" then
    OrderDetailStr=OrderDetailStr & "						  <td colspan='2' width='38%'>送货方式：免运费订单，由商家指定" 
	else
    OrderDetailStr=OrderDetailStr & "						  <td colspan='2' width='38%'>快递公司：" 
	
	  dim rst,foundexpress
	  Set RST=Server.CreateObject("ADODB.RECORDSET")
	 RST.Open "select Top 1 a.fweight,carriage,c_fee,w_fee,b.typename from KS_Delivery a inner join KS_DeliveryType b on A.ExpressID=B.TypeID where a.ExpressID="& rs("delivertype") &" and a.tocity like '%"&rs("tocity")&"%'",conn,1,1
	 If RST.Eof Then
	    foundexpress=false
	 Else
	    foundexpress=true
	    OrderDetailStr=OrderDetailStr & "<span style='color:green'>" & rst("typename") & "</span> 首重<span style='color:#ff6600'>"&rst("fweight")&"kg/"&rst("carriage")&"元</span>  续重<span style='color:#ff6600'>"&rst("W_fee")&"kg/"&rst("C_fee")&"元</span>"
	 End If
	 RST.Close
	 If foundexpress=false Then
	  RST.Open "select Top 1 a.fweight,carriage,c_fee,w_fee,b.typename from KS_Delivery a inner join KS_DeliveryType b on A.ExpressID=B.TypeID where a.ExpressID="& rs("delivertype") &" and (a.tocity='' or a.tocity is null)",conn,1,1
	  if rst.eof then
	  else
	   OrderDetailStr=OrderDetailStr & "<span style='color:green'>" & rst("typename") & "</span> 首重<span style='color:#ff6600'>"&rst("fweight")&"kg/"&rst("carriage")&"元</span>  续重<span style='color:#ff6600'>"&rst("W_fee")&"kg/"&rst("C_fee")&"元</span>"
	  end if
	 rst.close : set rst=nothing
	 End If
	
	
	OrderDetailStr=OrderDetailStr & " 发往<span style='color:red'>" & rs("tocity") & "</span>"
	end if
	
	
	OrderDetailStr=OrderDetailStr & "				</td></tr> "       
	OrderDetailStr=OrderDetailStr & "				<tr class='tdbg' valign='top'>  "        
	OrderDetailStr=OrderDetailStr & "				          <td width='12%' align='right'>发票信息：</td>"          
	OrderDetailStr=OrderDetailStr & "						  <td width='38%'>"
	 If RS("NeedInvoice")=1 Then OrderDetailStr=OrderDetailStr & replace(rs("InvoiceContent"),chr(10),"<br/>") &"</td>"
    OrderDetailStr=OrderDetailStr & "						 <td width='12%' align='right'>备注/留言：</td>"          
	OrderDetailStr=OrderDetailStr & "							<td width='38%'>" & rs("Remark") & "</td>       "
	OrderDetailStr=OrderDetailStr & "				 </tr>  "  
	OrderDetailStr=OrderDetailStr & "				 </table>"
	OrderDetailStr=OrderDetailStr & "			</td>  "
	OrderDetailStr=OrderDetailStr & "		</tr>  "
	OrderDetailStr=OrderDetailStr & "		<tr><td>"
	OrderDetailStr=OrderDetailStr & "		<table width='100%' border='0' align='center' cellpadding='2' cellspacing='1' class='border'> "
	OrderDetailStr=OrderDetailStr & "		  <tr align='center' class='title' height='25'>  "  
	OrderDetailStr=OrderDetailStr & "		   <td><b>商 品 名 称</b></td> "   
	OrderDetailStr=OrderDetailStr & "		   <td width='45'><b>单位</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='55'><b>数量</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='65'><b>参考价</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='65'><b>商城价</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='65'><b>您的价格</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='85'><b>金 额</b></td>   " 
	OrderDetailStr=OrderDetailStr & "		   <td width='65'><b>赠送积分</b></td>  "  
	OrderDetailStr=OrderDetailStr & "		   <td width='45'><b>备注</b></td>  "
	OrderDetailStr=OrderDetailStr & "		  </tr> "
			 Dim TotalPrice,attributecart,RSI:Set RSI=Server.CreateObject("ADODB.RECORDSET")
			   RSI.Open "Select * From KS_OrderItem Where SaleType<>5 and SaleType<>6 and OrderID='" & RS("OrderID") & "' order by ischangedbuy,id",conn,1,1
			   If RSI.Eof Then
			     RSI.Close:Set RSI=Nothing
				' Response.Write "<script>alert('找不到相关商品');history.back();<//script>"
			  Else
			  Do While Not RSI.Eof
			  attributecart=rsi("attributecart")
			  if not ks.isnul(attributecart) then attributecart="<br/><font color=#888888>" & attributecart & "</font>"
		OrderDetailStr=OrderDetailStr & "	  <tr valign='middle' class='tdbg' height='20'>"    
		OrderDetailStr=OrderDetailStr & "	   <td width='*'>" 
		 Dim OrderType:OrderType=KS.ChkClng(rs("ordertype"))
		 If OrderType=1 Then
		  OrderDetailStr=OrderDetailStr & "<a href='" & DomainStr & "shop/groupbuyshow.asp?id=" & RSi("proid") & "' target='_blank'>" & Conn.execute("select top 1 subject from ks_groupbuy where id=" & rsi("proid"))(0)
		 Else
		  OrderDetailStr=OrderDetailStr & "<a href='" & DomainStr & "item/show.asp?m=5&d=" & RSi("proid") & "' target='_blank'>" & Conn.execute("select top 1 title from ks_product where id=" & rsi("proid"))(0) 
		 End If
		If RSI("IsChangedBuy")="1" Then OrderDetailStr=OrderDetailStr & "(换购)"
		
		
			  Dim SqlStr,RSP:Set RSP=Server.CreateObject("ADODB.RECORDSET")
			  If OrderType=1 Then
			    SqlStr="Select top 1 Subject as title,'件' as unit,0 as IsLimitBuy,0 as LimitBuyPrice,0 as LimitBuyPayTime From KS_GroupBuy Where ID=" & RSI("ProID")
			  Else
			    SqlStr="Select top 1 I.Title,I.Unit,I.IsLimitBuy,I.LimitBuyPrice,L.LimitBuyPayTime From KS_Product I Left Join KS_ShopLimitBuy L On I.LimitBuyTaskID=L.Id  Where I.ID=" & RSI("ProID")
			  End If
			  RSP.Open SqlStr,conn,1,1
			  dim title,unit,LimitBuyPayTime
			  If Not RSP.Eof Then
				  title=rsp("title")
				  Unit=rsp("unit")
				  If RSI("IsChangedBuy")=1 Then 
				   title=title &"(换购)"
				  else
				    if RSP("LimitBuyPayTime") then
					   If LimitBuyPayTime="" Then
					   LimitBuyPayTime=RSP("LimitBuyPayTime")
					   ElseIf LimitBuyPayTime>RSP("LimitBuyPayTime") Then
						LimitBuyPayTime=RSP("LimitBuyPayTime")
					   End If
					end if
				  end  if
				  If RSI("IsLimitBuy")="1" Then OrderDetailStr=OrderDetailStr & "<span style='color:green'>(限时抢购)</span>"
				  If RSI("IsLimitBuy")="2" Then OrderDetailStr=OrderDetailStr & "<span style='color:blue'>(限量抢购)</span>"
			  End If
			  RSP.Close:Set RSP=Nothing
		
		OrderDetailStr=OrderDetailStr & "</a>" & attributecart & "</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='45' align=center>"& unit & "</td>               <td width='55' align='center'>" & rsi("amount") &"</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='65' align='center'>" & formatnumber(rsi("price_original"),2) & "</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='65' align='center'>" & formatnumber(rsi("price"),2) & "</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='65' align='center'>" & formatnumber(rsi("realprice"),2) & "</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='85' align='right'>" & formatnumber(rsi("realprice")*rsi("amount"),2) & "</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td width='65' align=center>" & ks.chkclng(rsi("score")*rsi("amount")) & " 分</td>    "
		OrderDetailStr=OrderDetailStr & "	   <td align=center'>" 
		totalscore=totalscore+ks.chkclng(rsi("score")*rsi("amount"))
		Set RSP=Conn.Execute("Select Top 1 DownUrl From KS_Product Where ID=" & RSI("ProID"))
		If Not RSP.Eof Then
			If Not KS.IsNul(RSP("DownUrl")) Then
				If RS("MoneyReceipt")>=RS("MoneyTotal") Then
				  OrderDetailStr=OrderDetailStr & "<a href='?action=OrderDown&orderid=" & rs("id") & "&proid=" & rsi("proid") &"'><img src='../images/default/download.gif'></a>"
				Else
				 OrderDetailStr=OrderDetailStr & "<a href='#' disabled>未付清</a>"
				End If
			Else
				 OrderDetailStr=OrderDetailStr & "---"
			End If
		Else
		  OrderDetailStr=OrderDetailStr & "---"
		End If
		RSP.Close :Set RSP=Nothing
		
		OrderDetailStr=OrderDetailStr & "</td>  "
		OrderDetailStr=OrderDetailStr & "	   </tr> " 
		OrderDetailStr=OrderDetailStr & GetBundleSalePro(TotalPrice,RSI("ProID"),RSI("OrderID"))  '取得捆绑销售商品
		
		
			  TotalPrice=TotalPrice+ rsi("realprice")*rsi("amount")
			    rsi.movenext
			  loop
			  rsi.close:set rsi=nothing
		End If
		
		OrderDetailStr=OrderDetailStr & GetPackage(TotalPrice,RS("OrderID"))         '超值礼包
		
		
		OrderDetailStr=OrderDetailStr & "	   <tr class='tdbg' height='30' > "   
		OrderDetailStr=OrderDetailStr & "	    <td colspan='6' align='right'><b>合计：</b></td> "   
		OrderDetailStr=OrderDetailStr & "		<td align='right'><b>" & formatnumber(totalprice,2) & "</b></td>    "
		OrderDetailStr=OrderDetailStr & "		<td colspan='3'> </td>  "
		OrderDetailStr=OrderDetailStr & "	  </tr>    "
		OrderDetailStr=OrderDetailStr & "	  <tr class='tdbg'>"
       OrderDetailStr=OrderDetailStr & "         <td colspan='4'>付款方式折扣率：" & rs("Discount_Payment") & "%&nbsp;&nbsp;" 
	   If RS("Weight")>0 Then
	   OrderDetailStr=OrderDetailStr & "重量：" & rs("weight") & " KG"
	   End If
	   OrderDetailStr=OrderDetailStr & "&nbsp;&nbsp;运费：" & rs("Charge_Deliver")&" 元&nbsp;&nbsp;&nbsp;&nbsp;税率：" & KS.Setting(65) &"%&nbsp;&nbsp;&nbsp;&nbsp;价格含税："
				IF KS.Setting(64)=1 Then 
				   OrderDetailStr=OrderDetailStr & "是"
				  Else
				   OrderDetailStr=OrderDetailStr & "不含税"
				  End If
				  Dim TaxMoney
				  Dim TaxRate:TaxRate=KS.Setting(65)
				 If KS.Setting(64)=1 Or rs("NeedInvoice")=0 Then TaxMoney=1 Else TaxMoney=1+TaxRate/100

				OrderDetailStr=OrderDetailStr & "<br>实际金额：(" & rs("MoneyGoods") & "×" & rs("Discount_Payment") & "%＋"&rs("Charge_Deliver") & ")×"
				if KS.Setting(64)=1 Or rs("NeedInvoice")=0 Then OrderDetailStr=OrderDetailStr & "100%" Else OrderDetailStr=OrderDetailStr & "(1＋" & TaxRate & "%)" 
				OrderDetailStr=OrderDetailStr & "＝" & formatnumber(rs("NoUseCouponMoney"),2) & "元  </td>"
    OrderDetailStr=OrderDetailStr & "<td  colspan='3' align=right><b>订单金额：</b> ￥" & formatnumber(rs("NoUseCouponMoney"),2) & " 元<br>"
	If KS.ChkClng(RS("CouponUserID"))<>0 and RS("UseCouponMoney")>0 Then
	OrderDetailStr=OrderDetailStr & "<b>使用优惠券：</b> <font color=#ff6600>￥" & formatnumber(RS("UseCouponMoney"),2) & " 元</font><br>"
    ElseIf RS("UseScoreMoney")<>"0" Then
	OrderDetailStr=OrderDetailStr & "<b>花费<font color=green>" &RS("UseScore") & "</font>积分抵扣了<font color=#ff6600>" & formatnumber(RS("UseScoreMoney"),2) & "</font>元<br>"
	End If
	OrderDetailStr=OrderDetailStr & "<b>应付金额：</b> ￥" & formatnumber(rs("MoneyTotal"),2) & "  元</td>"
    OrderDetailStr=OrderDetailStr & "<td colspan='3' align='left'><b>已付款：</b>￥<font color=red>" & formatnumber(rs("MoneyReceipt"),2) & "</font></b>"
	If RS("MoneyReceipt")<RS("MoneyTotal") Then
	OrderDetailStr=OrderDetailStr & "<br><B>尚欠款：￥<font color=blue>" & formatnumber(RS("MoneyTotal")-RS("MoneyReceipt"),2) &"</B>"
	End If
	OrderDetailStr=OrderDetailStr & "</td></tr></table></td>  "
	OrderDetailStr=OrderDetailStr & "</tr>"  
	OrderDetailStr=OrderDetailStr & "     <tr><td><br><b>注：</b><br/>1、“<font color='blue'>参考价</font>”指商品的市场参考价，“<font color='green'>商城价</font>”指本商城的销售价格，“<font color='red'>您的价格</font>”指根据会员灯级折扣系统自动算出的优惠价。商品的最终销售价格以“您的价格”为准。“订单金额”指系统自动算出来的价格，本订单的最终价格以“<font color=#ff6600>应付金额</font>”为准。<br>2、积分的赠送为结清订单后送出；<br/>3、限时抢购商品、特惠礼包、使用优惠券及使用积分抵扣费用的订单将不再赠送积分。"
	OrderDetailStr=OrderDetailStr & "	 </td>"
	OrderDetailStr=OrderDetailStr & "	 </tr>"
	
	If not conn.execute("select top 1 * from ks_orderitem where orderid='" & RS("OrderID") &"' and islimitbuy<>0").eof Then
	OrderDetailStr=OrderDetailStr & "     <tr><td><div style='margin:10px;color:red;padding:10px;margin-top:3px;border:1px solid #f9c943;background:#FFFFF6'>温馨提示:本订单是限时/限量抢购订单,限制下单后" & LimitBuyPayTime & "小时之内必须付款,即如果您在[" & DateAdd("h",LimitBuyPayTime,RS("InputTime")) & "]之前用户没有付款,本订单自动作废。</div>"
	OrderDetailStr=OrderDetailStr & "	 </td>"
	OrderDetailStr=OrderDetailStr & "	 </tr>"
	End If
	
	If RS("DeliverStatus")=1 Then
	 Dim RSD,DeliverStr
	 Set RSD=Conn.Execute("Select Top 1 * From KS_LogDeliver Where DeliverType=1 And OrderID='" & RS("OrderID") & "'")
	 If Not RSD.Eof Then
	  DeliverStr="快递公司:" & RSD("ExpressCompany") & " 物流单号:" & RSD("ExpressNumber") & " 发货日期:" & RSD("DeliverDate") & " 发货经手人:" & RSD("HandlerName")
	 End If
	 RSD.Close : Set RSD=Nothing
	OrderDetailStr=OrderDetailStr & "     <tr><td><div style='margin:10px;color:blue;padding:10px;margin-top:3px;border:1px solid #f9c943;background:#FFFFF6'>温馨提示:本订单已发货。" & DeliverStr & "</div>"
	OrderDetailStr=OrderDetailStr & "	 </td>"
	OrderDetailStr=OrderDetailStr & "	 </tr>"
	End If
	
	
	OrderDetailStr=OrderDetailStr & "	</table>"
	  End Function
	  
'取得捆绑销售商品
Dim ProIds
Function GetBundleSalePro(ByRef TotalPrice,ProID,OrderID)
  If KS.FoundInArr(ProIDS,ProID,",")=true Then Exit Function
  ProIds=ProIDs & "," & ProID
  Dim Str,RS,XML,Node
  Set RS=Server.CreateObject("adodb.recordset")
  RS.Open "Select I.Title,I.Unit,O.* From KS_OrderItem O inner join KS_Product I On O.ProID=I.ID Where O.SaleType=6 and BundleSaleProID=" & ProID & " and OrderID='" & OrderID & "' order by O.id",conn,1,1
  If Not RS.Eof Then
    Set XML=KS.RsToXml(rs,"row","")
  End If
  RS.Close:Set RS=Nothing
  If IsObject(XML) Then
	     str=str & "<tr height=""25"" align=""left""><td colspan=9 style=""color:green"">&nbsp;&nbsp;选购捆绑促销:</td></tr>"
       For Each Node In Xml.DocumentElement.SelectNodes("row")
         str=str & "<tr>"
		 str=str &" <td style='color:#999999'>&nbsp;" & Node.SelectSingleNode("@title").text &"</td>"
		 str=str &" <td align='center'>" & Node.SelectSingleNode("@unit").text &"</td>"
		 str=str &" <td align='center'>" & Node.SelectSingleNode("@amount").text &"</td>"
		 str=str &" <td align='center'>" & formatnumber(Node.SelectSingleNode("@price_original").text,2,-1) &"</td>"
		 str=str &" <td align='center'>" & formatnumber(Node.SelectSingleNode("@realprice").text,2,-1) &"</td>"
		 str=str &" <td align='center'>" & formatnumber(Node.SelectSingleNode("@realprice").text,2,-1) &"</td>"
		 str=str &" <td align='right'>" & formatnumber(Node.SelectSingleNode("@realprice").text*Node.SelectSingleNode("@amount").text,2,-1) &"</td>"
		 str=str &" <td align='center'>" & Node.SelectSingleNode("@serviceterm").text &"</td>"
		 str=str &" <td align='center'>" & Node.SelectSingleNode("@remark").text &"</td>"
		 str=str & "</tr>"
		 TotalPrice=TotalPrice +round(Node.SelectSingleNode("@realprice").text*Node.SelectSingleNode("@amount").text,2) 
       Next
  End If
  GetBundleSalePro=str
End Function
	  
	  
 '得到超值礼包
 Function GetPackage(ByRef TotalPrice,OrderID)
	    If KS.IsNul(OrderID) Then Exit Function
		Dim RS,RSB,GXML,GNode,str,n,Price
		Set RS=Conn.Execute("select packid,OrderID from KS_OrderItem Where SaleType=5 and OrderID='" & OrderID & "' group by packid,OrderID")
		If Not RS.Eof Then
		 Set GXML=KS.RsToXml(Rs,"row","")
		End If
		RS.Close : Set RS=Nothing
		If IsOBJECT(GXml) Then
		   FOR 	Each GNode In GXML.DocumentElement.SelectNodes("row")
		     Set RSB=Conn.Execute("Select top 1 * From KS_ShopPackAge Where ID=" & GNode.SelectSingleNode("@packid").text)
			 If Not RSB.Eof Then
					  
						Dim RSS:Set RSS=Server.CreateObject("adodb.recordset")
						RSS.Open "Select a.title,a.Price_Member,a.Price,b.* From KS_Product A inner join KS_OrderItem b on a.id=b.proid Where b.SaleType=5 and b.packid=" & GNode.SelectSingleNode("@packid").text & " and  b.orderid='" & OrderID & "'",Conn,1,1
						  str=str & "<tr class='tdbg' height=""25"" align=""center""><td colspan=2><strong><a href='" & DomainStr & "shop/pack.asp?id=" & RSB("ID") & "' target='_blank'>" & RSB("PackName") & "</a></strong></td>"
						  n=1
						  Dim TotalPackPrice,tempstr,i
						  TotalPackPrice=0 : tempstr=""
						Do While Not RSS.Eof
						 
						  For I=1 To RSS("Amount") 
							  '得到单件品价格 
							  If RSS("AttrID")<>0 Then 
							  Dim RSAttr:Set RSAttr=Conn.Execute("Select top 1  * From KS_ShopSpecificationPrice Where ID=" & RSS("AttrID"))
							  If Not RSAttr.Eof Then
								Price=RSAttr("Price")
							  Else
								Price=RSS("Price_member")
							  End If
							  RSAttr.CLose:Set RSAttr=Nothing
							 Else
								Price=RSS("Price_member")
							 End If
							
							   TotalPackPrice=TotalPackPrice+Price
							  tempstr=tempstr & n & "." & rss("title") & " " & rss("AttributeCart") & "<br/>"
							  n=n+1
						  Next
						  RSS.MoveNext
						Loop
						
						str=str &"<td>1</td><td>￥" & TotalPackPrice & "</td><td>￥" & TotalPackPrice & "</td><td>￥" & formatnumber((TotalPackPrice*rsb("discount")/10),2,-1) &"</td><td>￥" & formatnumber((TotalPackPrice*rsb("discount")/10),2,-1) & "</td><td>---</td><td>---</td>"
					   
						str=str & "</tr><tr><td align='left' colspan=9>您选择的套装详细如下:<br/>" & tempstr & "</td></tr>" 
						
						TotalPrice=TotalPrice+round(formatnumber((TotalPackPrice*rsb("discount")/10),2,-1))   '将礼包金额加入总价
						
						RSS.Close
						Set RSS=Nothing
					
			End If
			RSB.Close
		   Next
			
	    End If
		GetPackage=str
		
End Function
'下载
Sub OrderDown()
  Dim OrderID:OrderID=KS.ChkClng(KS.S("OrderID"))
  Dim ProID:ProID=KS.ChkClng(KS.S("ProID"))
  If ProID=0 Or OrderID=0 Then KS.AlertHintScript "出错了！！！"
  Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
  RS.Open "Select top 1 O.* From KS_Order O Inner Join KS_OrderItem I ON O.OrderID=I.OrderID Where O.UserName='" & KSUser.UserName & "' and O.Id=" & OrderID & " And O.MoneyReceipt>=O.MoneyTotal",Conn,1,1
  If RS.Eof And RS.Bof Then
   RS.Close :Set RS=Nothing
   KS.AlertHintScript "订单不存在或是订单款项还没有付清，无法下载！！!"
  Else
    RS.Close
	RS.Open "Select top 1 DownUrl From KS_Product Where ID=" & ProID,conn,1,1
	If RS.EOf And RS.Bof Then
	 RS.Close :Set RS=Nothing
	 KS.AlertHintScript "下载已不存在！"
	Else
	 DownURL=RS(0)
	 RS.Close :Set RS=Nothing
	End If
	If Not KS.IsNul(DownUrL) Then Response.Redirect DownUrl
  End If
  
End Sub

 End Class
%> 
