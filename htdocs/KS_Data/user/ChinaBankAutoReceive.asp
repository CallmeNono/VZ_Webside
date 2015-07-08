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
Response.Expires = 1 
Response.CacheControl = "no-cache"

Dim KSUser:Set KSUser=New UserCls
Dim KS:Set KS=New PublicCls
Dim PaymentPlat:PaymentPlat=1

Dim RSP:Set RSP=Server.CreateObject("ADODB.RECORDSET")
RSP.Open "Select top 1 * From KS_PaymentPlat where id=" & PaymentPlat,conn,1,1
If RSP.Eof Then
		 RSP.Close:Set RSP=Nothing
		 Response.Write "Error!"
		 Response.End()
End If
Dim AccountID:AccountID=RSP("AccountID")
Dim MD5Key:MD5Key=RSP("MD5Key")
Dim PayOnlineRate:PayOnlineRate=KS.ChkClng(RSP("Rate")) 
Dim RateByUser:RateByUser=KS.ChkClng(RSP("RateByUser")) 
RSP.Close:Set RSP=Nothing

 Call ChinaBank()
'网银在线返回
Sub ChinaBank() 
 Dim v_oid,v_pmode,v_pstatus,v_pstring,v_string,v_amount,v_moneytype,remark2,v_md5str,text,md5text,zhuangtai
' 取得返回参数值
	v_oid=KS.S("v_oid")                               ' 商户发送的v_oid定单编号
	v_pmode=request("v_pmode")                           ' 支付方式（字符串） 
	v_pstatus=request("v_pstatus")                       ' 支付状态 20（支付成功）;30（支付失败）
	v_pstring=request("v_pstring")                       ' 支付结果信息 支付完成（当v_pstatus=20时）；失败原因（当v_pstatus=30时）；
	v_amount=request("v_amount")                         ' 订单实际支付金额
	v_moneytype=request("v_moneytype")                   ' 订单实际支付币种
	remark2=request("remark2")                           ' 备注字段2
	v_md5str=request("v_md5str")                         ' 网银在线拼凑的Md5校验串
	if request("v_md5str")="" then
		response.Write("v_md5str：空值")
		response.end
	end if
	text = v_oid&v_pstatus&v_amount&v_moneytype&MD5Key 'md5校验
	md5text = Ucase(trim(md5(text,32)))    '商户拼凑的Md5校验串
	if md5text<>v_md5str then		' 网银在线拼凑的Md5校验串 与 商户拼凑的Md5校验串 进行对比
	  	response.write("error") '告诉服务器验证失败，要求重发
	    response.end '中断程序
	else
	  response.write("ok")
	  if v_pstatus=20 then '支付成功
		Call UpdateOrder(v_amount,remark2,v_oid,v_pmode)
		Conn.Execute("Update KS_LogMoney Set PaymentID=1 Where OrderID='" & KS.DelSql(v_oid) & "'")
	  else
	   	response.write("error") '告诉服务器验证失败，要求重发
	    response.end '中断程序
	  end if
	end if
end Sub
%>