<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
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

input_CharSet="utf-8"  '不可少,否则签名会出错 md5加密要用到

Dim KSUser:Set KSUser=New UserCls
Dim KS:Set KS=New PublicCls
Dim PaymentPlat:PaymentPlat=KS.ChkClng(Request("PaymentPlat"))
If PaymentPlat=0 Then PaymentPlat=7

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

Select Case PaymentPlat
		 Case 7 '支付宝
		  Call alipayBack()
		 Case 9,15  '支付宝非即时到账
		  Call alipayBack9()
End Select 

'支付宝即时到账
Sub alipayBack()
	Dim v_mid, v_oid, v_pmode, v_pstatus, v_pstring, v_amount, v_md5, v_date, v_moneytype
	Dim md5string,alipayNotifyURL
    v_mid = AccountID
	Dim Partner
	Dim ArrMD5Key
	If InStr(MD5Key, "|") > 0 Then
		ArrMD5Key = Split(MD5Key, "|")
		If UBound(ArrMD5Key) = 1 Then
			MD5Key = ArrMD5Key(0)
			Partner = ArrMD5Key(1)
		End If
	End If


	Dim trade_status, sign, MySign, Retrieval,ResponseTxt
	Dim mystr, Count, i, minmax, minmaxSlot, j, mark, temp, value, md5str, notify_id
	
	v_oid = DelStr(Request("out_trade_no"))            '商户定单号
	trade_status = DelStr(Request("trade_status"))
	sign = DelStr(Request("sign"))
	v_amount = DelStr(Request("total_fee"))
	notify_id = Request("notify_id")
	

	alipayNotifyURL = "http://notify.alipay.com/trade/notify_query.do?"
	alipayNotifyURL = alipayNotifyURL & "partner=" & Partner & "&notify_id=" & notify_id
	Set Retrieval = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
    Retrieval.setOption 2, 13056 
    Retrieval.open "GET", alipayNotifyURL, False, "", "" 
    Retrieval.send()
    ResponseTxt = Retrieval.ResponseText
	Set Retrieval = Nothing
	'*****************************************
	
	'获取Get过来的参数
    mystr = GetRequest("form")
    '验证是否有数组传来
	If IsArray(mystr) Then
		'生成签名结果
		mysign = GetMysign(mystr)
	end if	
	'********************************************************

	'记录支付日志,调试时可以开启，确保user/log目录存在，且有写入权限
	'Dim sWord:sWord = "responseTxt="& ResponseTxt &"\n notify_url_log:sign="&request.Form("sign")&"&mysign="&mysign&"&"&CreateLinkstring(mystr)
	'LogResult(sWord)
	
	If ResponseTxt="true" and mysign=Request.Form("sign") Then 
		Call UpdateOrder(v_amount,"在线充值，订单号为:" & v_oid,v_oid,v_pmode)
		Conn.Execute("Update KS_LogMoney Set PaymentID=7 Where OrderID='" & v_oid & "'")
		response.write "success"
	Else
	    response.write "fail"
	End If 
	
End Sub

' 写日志，方便测试（看网站需求，也可以改成存入数据库）
' param sWord 要写入日志里的文本内容
Function LogResult(sWord)
	Randomize
	dim fs:Set fs= createobject("scripting.filesystemobject")
	dim ts:Set ts=fs.createtextfile(server.MapPath("log/"&GetDateTime()&INT((1000+1)*RND)&".txt"),true)
	ts.writeline(sWord)
	ts.close
	Set ts=Nothing
	Set fs=Nothing
End Function
' 获取当前时间
' 格式：年[4位]月[2位]日[2位]小时[2位 24小时制]分[2位]秒[2位]，如：20071001131313
' return 时间格式化结果
Function GetDateTime()
	dim sTime:sTime=now()
	dim sResult:sResult	= year(sTime)&right("0" & month(sTime),2)&right("0" & day(sTime),2)&right("0" & hour(sTime),2)&right("0" & minute(sTime),2)&right("0" & second(sTime),2)
	GetDateTime = sResult
End Function



'支付宝非即时到账
Sub alipayBack9()
    Dim PaySuccess,ResponseTxt,returnTxt
	Dim v_mid, v_oid, v_pmode, v_pstatus, v_pstring, v_amount, v_md5, v_date, v_moneytype
	Dim md5string,alipayNotifyURL
    v_mid = AccountID
	Dim Partner
	Dim ArrMD5Key
	If InStr(MD5Key, "|") > 0 Then
		ArrMD5Key = Split(MD5Key, "|")
		If UBound(ArrMD5Key) = 1 Then
			MD5Key = ArrMD5Key(0)
			Partner = ArrMD5Key(1)
		End If
	End If
    Dim trade_status, sign, MySign, Retrieval,trade_no
    Dim mystr, Count, i, minmax, minmaxSlot, j, mark, temp, value, md5str, notify_id
    sign = DelStr(Request("sign"))
    notify_id = Request("notify_id")
    alipayNotifyURL = "https://www.alipay.com/cooperate/gateway.do?"
    alipayNotifyURL = alipayNotifyURL & "service=notify_verify&partner=" & Partner & "&notify_id=" & notify_id
	Set Retrieval = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
    Retrieval.Open "GET", alipayNotifyURL, False, "", ""
    Retrieval.Send
    ResponseTxt = Retrieval.ResponseText
    Set Retrieval = Nothing
                
    '获取Get过来的参数
    mystr = GetRequest("form")
    '验证是否有数组传来
	If IsArray(mystr) Then
		mysign = GetMysign(mystr) '生成签名结果
	end if	
	
	'记录支付日志
	'Dim sWord:sWord = "responseTxt="& ResponseTxt &"\n notify_url_log:sign="&request.Form("sign")&"&mysign="&mysign&"&"&CreateLinkstring(mystr)
	'LogResult(sWord)
	
	
    If ResponseTxt = "true" And sign = MySign Then
	  call alipayprocess()
	Else
	  response.write "fail"
	End If

End Sub

sub alipayprocess()
    Dim v_pmode
    Dim trade_status:trade_status = DelStr(Request("trade_status"))
	Dim v_oid:v_oid = DelStr(Request("out_trade_no"))            '商户定单号
	Dim trade_no:trade_no= KS.S("trade_no")		'获取支付宝交易号
    Dim v_amount:v_amount = Request("price")
	if not isnumeric(v_amount) or v_amount="" then  v_amount=request("total_fee")
	if not isnumeric(v_amount) or v_amount="" then  v_amount=0
  
   if trade_status<>"" then
    Conn.Execute("Update KS_Order Set alipaytradestatus='" &trade_status & "' Where OrderID='" & v_oid & "'") '更新支付记录状态和发货状态
   end if
  
    '等待买家付款
    Select Case trade_status
    Case "WAIT_BUYER_PAY"
			Conn.Execute("Update KS_Order Set alipaytradeno='" &trade_no & "' Where OrderID='" & KS.R(v_oid) & "'") '只更新订单状态
			KS.Die "success"
    '买家付款成功,等待卖家发货
    Case "WAIT_SELLER_SEND_GOODS"
			Conn.Execute("Update KS_Order Set alipaytradeno='" &trade_no & "',Status=1,MoneyReceipt=" &v_amount & " Where OrderID='" & KS.R(v_oid) & "'") '只更新订单状态，不更新发货状态和订单状态
			Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
			RS.Open "Select top 1 * From KS_Order Where OrderID='" & KS.R(v_oid) & "'",Conn,1,3
			If Not RS.Eof Then
			  rs("PaymentPlatId")=PaymentPlat
			  RS.Update
			End If
			RS.Close:Set RS=Nothing
			KS.Die "success"
    '等待买家确认收货
    Case "WAIT_BUYER_CONFIRM_GOODS"
            Conn.Execute("Update KS_Order Set Status=1,DeliverStatus=1 Where OrderID='" & v_oid & "'") '更新支付记录状态和发货状态，不更新订单状态
            KS.Die "success"
    '交易成功结束
    Case "TRADE_FINISHED"
			Conn.Execute("Update KS_Order Set alipaytradeno='" &trade_no & "',DeliverStatus=2 Where OrderID='" & KS.R(v_oid) & "'") '只更新订单状态
        Call UpdateOrder(v_amount,"在线充值，订单号为:" & v_oid,v_oid,v_pmode)
		KS.Die "success"
    '其他交易状态通知情况
    Case Else
        
    End Select
	
end sub


Function DelStr(Str)
		If IsNull(Str) Or IsEmpty(Str) Then
			Str	= ""
		End If
		DelStr	= Replace(Str,";","")
		DelStr	= Replace(DelStr,"'","")
		DelStr	= Replace(DelStr,"&","")
		DelStr	= Replace(DelStr," ","")
		DelStr	= Replace(DelStr,"　","")
		DelStr	= Replace(DelStr,"%20","")
		DelStr	= Replace(DelStr,"--","")
		DelStr	= Replace(DelStr,"==","")
		DelStr	= Replace(DelStr,"<","")
		DelStr	= Replace(DelStr,">","")
		DelStr	= Replace(DelStr,"%","")
End Function


%>