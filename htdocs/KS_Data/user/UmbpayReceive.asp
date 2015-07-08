<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"--> 
<!--#include file="../Plus/md5.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="payfunction.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Response.Buffer = true 
Response.Expires = 0 
Response.CacheControl = "no-cache"

Dim KSUser:Set KSUser=New UserCls
Dim KS:Set KS=New PublicCls
Dim PaymentPlat:PaymentPlat=14

Dim RSP:Set RSP=Server.CreateObject("ADODB.RECORDSET")
RSP.Open "Select top 1 * From KS_PaymentPlat where id=" & PaymentPlat,conn,1,1
If RSP.Eof Then
		 RSP.Close:Set RSP=Nothing
		 Response.Write "Error!"
		 Response.End()
End If
Dim AccountID:AccountID=RSP("AccountID")
Dim MD5Key:MD5Key=RSP("MD5Key")
RSP.Close:Set RSP=Nothing

Call umbpay()

'支付宝即时到账
Sub umbpay()
	Dim merchantid
	Dim merorderid
	Dim amountsum
	Dim currencytype
	Dim subject
	Dim remark
	Dim state
	Dim mac_rec
	Dim mac,merkey,paybank,banksendtime,merrecvtime,strInterface,mac_src
	
	'商户接收平台返回支付成功信息   ***平台只返回支付成功的订单信息***
	
	merchantid	  = KS.S("merchantid")        '商户编号
	merorderid    = KS.DelSQL(KS.S("merorderid"))        '订单号
	amountsum     = KS.S("amountsum")         '金额
	currencytype  = Request("currencytype")      '币种
	subject       = Request("subject")           '商品种类
	remark        = Request("remark")            '备注
	state         = Request("state")             '状态 1--支付成功
	paybank       = Request("paybank")           '支付银行
	banksendtime  = Request("banksendtime")      '发送到银行时间
	merrecvtime   = Request("merrecvtime")       '返回到商户时间
	strInterface  = Request("interface")      '接口版本
	mac_rec       = Request("mac")               '加密串
	merkey        = MD5Key                     '商户支付密钥
	If Instr(remark,"|")<>0 Then
		 SUserName=Split(remark,"|")(0)
		 sPayFrom=split(remark,"|")(1)
		 SUserCardID=split(remark,"|")(2)
	End if	
	
	mac_src = "merchantid=" & merchantid & "&merorderid=" & merorderid & "&amountsum=" & amountsum & "&currencytype=" & currencytype & "&subject=" & subject & "&state=" & state & "&paybank=" & paybank & "&banksendtime=" & banksendtime & "&merrecvtime=" & merrecvtime & "&interface=" & strInterface & "&merkey=" & merkey
	mac=md5(mac_src,32)
	'校验码正确
	if(ucase(mac)=ucase(mac_rec) and state="1") then
	    Call UpdateOrder(amountsum,"在线充值，订单号为:" & merorderid,merorderid,paybank)  
		Call ShowResult("恭喜你！在线支付成功！")
	Else
		Call ShowResult("交易信息无效！")          '这里可以指定你需要显示的内容
	End If
End Sub

Sub ShowResult(byval message)
Session(KS.SiteSN&"UserInfo")=empty
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>用户管理中心</title>
<link href="images/css.css" type="text/css" rel="stylesheet" />
</head>
<body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0"><br><br><br>
	<table class=border cellSpacing=1 cellPadding=2 width="60%" align=center border=0>
  <tr class="title"> 
    <td height=22 align=center><b><font color="#FF0000">提示：</font> 您网上在线支付情况反馈如下：</b></td>
 </tr>
 <tr class="tdbg"><td>
      <p>
        <%=message%>
	  </p>
     </td>
  </tr>
  <tr class="title">
   <td  height="22" align="center"><a href="<%=KS.getdomain%>user/index.asp">进入会员中心</a> | <a href="<%=KS.getdomain%>">返回首页</a>
   </td>
  </tr>
</table>
<%
End Sub
Set KS=Nothing
CloseConn
%>