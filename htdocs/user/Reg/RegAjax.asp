<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../../Conn.asp"-->
<!--#include file="../../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="../../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../../KS_Cls/Kesion.EscapeCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
response.cachecontrol="no-cache"
response.addHeader "pragma","no-cache"
response.expires=-1
response.expiresAbsolute=now-1
Response.CharSet="utf-8"
Dim KSCls
Set KSCls = New Ajax_Check
KSCls.Kesion()
Set KSCls = Nothing

Class Ajax_Check
        Private KS
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		End Sub
		Public Sub Kesion()
		  If Request.ServerVariables("HTTP_REFERER")="" Then KS.Die "error!"
		  Select Case KS.S("Action")
		   Case "checkusername"   Call CheckUserName()
		   Case "checkmobile"     Call CheckMobile()
		   Case "checkemail"     Call CheckEmail()
		   Case "checkcode"	    Call CheckCode()
		   Case "getregform"    Call GetRegForm()
		   Case "getcityoption"  Call getCityOption()
		  End Select
		End Sub
		
		Sub CheckUserName()
			dim username:username=KS.DelSQL(UnEscape(Request("username")))
			if username="" then
			 KS.Echo escape("err|请输入会员名！")
			elseif isnumeric(username) then
			 KS.Echo escape("err|会员名不能是纯数字!")
			elseif KS.HasChinese(username) and KS.ChkClng(KS.Setting(175))="0" then
			 KS.Echo escape("err|会员名不能含有中文！")
			elseif InStr(UserName, "=") > 0 Or InStr(UserName, ".") > 0 Or InStr(UserName, "%") > 0 Or InStr(UserName, Chr(32)) > 0 Or InStr(UserName, "?") > 0 Or InStr(UserName, "&") > 0 Or InStr(UserName, ";") > 0 Or InStr(UserName, ",") > 0 Or InStr(UserName, "'") > 0 Or InStr(UserName, ",") > 0 Or InStr(UserName, Chr(34)) > 0 Or InStr(UserName, Chr(9)) > 0 Or InStr(UserName, "") > 0 Or InStr(UserName, "$") > 0 Or InStr(UserName, "*") Or InStr(UserName, "|") Or InStr(UserName, """") > 0 Then
			KS.Echo escape("err|用户名中含有非法字符!")
			elseif KS.StrLength(username)<KS.ChkClng(KS.Setting(29)) or KS.StrLength(username)>KS.ChkClng(KS.Setting(30)) then
			 KS.Echo escape("err|输入的会员名长度应为<font color=#ff6600>" & KS.Setting(29) &"-" & KS.Setting(30) & "位</font>！")
			elseif KS.FoundInArr(KS.Setting(31), UserName, "|") = True Then
			 KS.Echo escape("err|您输入的用户名为系统禁止注册的用户名</font>！")
			elseif conn.Execute("Select top 1 Userid From KS_User where username='"&username&"'" ).eof Then
			 KS.Echo escape("ok|恭喜,该会员名可以正常注册！")
			else
			 KS.Echo escape("err|该会员名已经有人使用!")
			end if
		End Sub
		Sub CheckMobile()
			dim mobile:mobile=KS.DelSQL(unescape(Request("mobile")))
			if mobile="" then
			 KS.Echo escape("err|请输入您的手机号码！")
			elseif ks.setting(129)="0" or conn.Execute("Select userid From KS_User where mobile='"&mobile&"'" ).eof Then
			 KS.Echo escape("ok|该手机号码可以正常注册!")
			else
			 KS.Echo escape("err|该手机号码已经有人使用，请重新选择。")
			end if
		End Sub
		Sub CheckEmail()
			dim email:email=KS.DelSQL(unescape(Request("email")))
			if email="" then
			 KS.Echo escape("err|请输入电子邮箱！")
			elseif instr(email,"@")=0 or instr(email,".")=0 then
			 KS.Echo escape("err|您输入电子邮箱有误！")
			elseif ks.setting(28)=1 or conn.Execute("Select userid From KS_User where email='"&email&"'" ).eof Then
			 KS.Echo escape("ok|该邮箱可以正常注册!")
			else
			 KS.Echo escape("err|该邮箱已经有人使用，请重新选择。")
			end if
		End Sub
		Sub CheckCode()
		  dim code:code=unescape(KS.S("code"))
		  IF lcase(Trim(code))<>lcase(Trim(Session("Verifycode"))) And KS.ChkCLng(KS.Setting(27))=1 then 
		   	 KS.Echo escape("err|验证码有误，请重新输入！")
		  Else
		   	 KS.Echo escape("ok|验证码已输入！")
		  End IF
		End Sub
		
		Sub GetRegForm()
		 Dim GroupID:GroupID=KS.ChkClng(Request("GroupID"))
		 Dim SQL,K,N,InputStr,O_Arr,O_Len,F_V,O_Value,O_Text,BRStr,CanReg
         Dim FieldsList,Template
		 If GroupID=0 Then GroupID=2
		 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select top 1 FormField,Template From KS_UserForm Where ID=" & KS.ChkCLng(KS.U_G(GroupID,"formid")),conn,1,1
		 If Not RS.Eof Then
		  FieldsList=RS(0) : Template=RS(1)
		 Else
		   RS.Close : Set RS=Nothing
		   KS.Die "参数传递出错了!"
		 End If
		 RS.Close
		   RS.Open "Select top 200 FieldID,FieldType,FieldName,DefaultValue,Width,Height,Options,EditorType,ShowUnit,UnitOptions,MaxLength from KS_Field Where ChannelID=101 Order By OrderID",conn,1,1
		   If Not RS.EOf Then SQL=RS.GetRows(-1):RS.Close():Set RS=Nothing
		   For K=0 TO Ubound(SQL,2)
		     If KS.FoundInArr(FieldsList,SQL(0,k),",") Then
			  InputStr=""
			  If lcase(replace(SQL(2,K),"&",""))="provincecity" Then
				Dim RSP:Set RSP=Conn.Execute("Select top 300 ID,City From KS_Province Where parentid=0 Order By OrderID,id")
				Dim XML,Node
				If Not RSP.Eof Then
				 Set XML=KS.RsToXml(RSP,"row","")
				End If
				RSP.Close:Set RSP=Nothing
				  InputStr="<select name=""Province"" class=""select"" onchange=""loadCity(this.value)"" id=""Province"">" &vbcrlf
				  InputStr=InputStr &"<option value=''>请选择省份...</option>" & vbcrlf
				If IsObject(XML) Then
				  For Each Node in XML.DocumentElement.SelectNodes("row")
				   InputStr=InputStr &"<option value='" & Node.SelectSingleNode("@city").text &"'>" & Node.SelectSingleNode("@city").text &"</option>"
				  Next
				End If
				 InputStr=InputStr&"</select>"
				 InputStr=InputStr &"&nbsp;<select class=""select"" name=""City"" ID=""City""><option value=''>请选择城市...</option></select>" & vbcrlf
				 Set XML=Nothing
			  Else
			  Select Case SQL(1,K)
			    Case 2:InputStr="<textarea style=""width:" & SQL(4,K) & "px;height:" & SQL(5,K) & "px"" rows=""5"" class=""textbox"" name=""" & SQL(2,K) & """>" & SQL(3,K) & "</textarea>"
				Case 3,11
				    If SQL(1,K)=11 Then
					  InputStr= "<select style=""width:" & SQL(4,K) & """ name=""" & SQL(2,K) & """ onchange=""fill" & SQL(2,K) &"(this.value)""><option value=''>---请选择---</option>"
	
					Else
					  InputStr = "<select  style=""width:" & SQL(4,K) & """ name=""" &SQL(2,K) & """>"
					End If
				  O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
				  For N=0 To O_Len
					 F_V=Split(O_Arr(N),"|")
					 If Ubound(F_V)=1 Then
						O_Value=F_V(0):O_Text=F_V(1)
					 Else
						O_Value=F_V(0):O_Text=F_V(0)
					 End If						   
					 If SQL(3,K)=O_Value Then
						InputStr=InputStr & "<option value=""" & O_Value& """ selected>" & O_Text & "</option>"
					 Else
						InputStr=InputStr & "<option value=""" & O_Value& """>" & O_Text & "</option>"
					 End If
				  Next
					InputStr=InputStr & "</select>"
					'联动菜单
					If SQL(1,K)=11  Then
						Dim JSStr
						InputStr=InputStr &  GetLDMenuStr(101,SQL(2,k),JSStr) & "<script type=""text/javascript"">" &vbcrlf & JSStr& vbcrlf &"</script>"
					End If
				Case 6
					 O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
					 If O_Len>1 And Len(SQL(6,K))>50 Then BrStr="<br>" Else BrStr=""
					 For N=0 To O_Len
						F_V=Split(O_Arr(N),"|")
						If Ubound(F_V)=1 Then
						 O_Value=F_V(0):O_Text=F_V(1)
						Else
						 O_Value=F_V(0):O_Text=F_V(0)
						End If						   
					    If SQL(3,K)=O_Value Then
							InputStr=InputStr & "<input type=""radio"" name=""" & SQL(2,K) & """ value=""" & O_Value& """ checked>" & O_Text & BRStr
						Else
							InputStr=InputStr & "<input type=""radio"" name=""" & SQL(2,K) & """ value=""" & O_Value& """>" & O_Text & BRStr
						 End If
			         Next
			  Case 7
					O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
					 For N=0 To O_Len
						  F_V=Split(O_Arr(N),"|")
						  If Ubound(F_V)=1 Then
							O_Value=F_V(0):O_Text=F_V(1)
						  Else
							O_Value=F_V(0):O_Text=F_V(0)
						  End If						   
						  If KS.FoundInArr(SQL(3,K),O_Value,",")=true Then
								 InputStr=InputStr & "<input type=""checkbox"" name=""" & SQL(2,K) & """ value=""" & O_Value& """ checked>" & O_Text
						 Else
						  InputStr=InputStr & "<input type=""checkbox"" name=""" & SQL(2,K) & """ value=""" & O_Value& """>" & O_Text
						 End If
				   Next
			  Case 10
			        InputStr=InputStr & "<textarea id=""" & SQL(2,K) &"_ck"" name=""" & SQL(2,K) &""">"& Server.HTMLEncode(SQL(3,K)) &"</textarea>"
			        'InputStr=InputStr & "<textarea style=""display:none"" id=""" & SQL(2,K) &""" name=""" & SQL(2,K) &""">"& Server.HTMLEncode(SQL(3,K)) &"</textarea><script type=""text/javascript"">CKEDITOR.replace('" & SQL(2,K) &"', {width:""" & SQL(4,K) &""",height:""" & SQL(5,K) & """,toolbar:""" & SQL(7,K) & """});<//script>"
					
					
			  Case Else
			       Dim MaxLength:MaxLength=KS.ChkClng(SQL(10,K))
				   If MaxLength=0 Then MaxLength=255
			    If KS.Setting(149)="1" and lcase(SQL(2,K))="mobile" Then
			    InputStr=""
				ElseIf SQL(1,K)="9" And KS.Setting(60)="1" Then
					InputStr=InputStr & "<table cellspacing=""0"" cellpadding=""0""><tr><td><input type=""text"" maxlength=""" & MaxLength &""" class=""textbox"" style=""width:" & SQL(4,K) & "px"" name=""" & SQL(2,K) & """ value=""" & SQL(3,K) & """>&nbsp;</td><td width=""170""><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='" & KS.GetDomain & "user/User_UpFile.asp?FieldName=" & SQL(2,K) & "&Type=Field&FieldID=" & SQL(0,K) & "&ChannelID=101' frameborder=0 scrolling=no width='170' height='30'></iframe></td></table>"
               Else
			       InputStr="<input type=""text"" maxlength=""" & MaxLength &""" style=""width:" & SQL(4,K) & "px"" class=""input"" name=""" & SQL(2,K) & """ value=""" & SQL(3,K) & """>"
			    End If
				
				
				
			  End Select
			  End If
			  
			  If SQL(8,K)="1" Then 
					  InputStr=InputStr & " <select name=""" & SQL(2,K) & "_Unit"" id=""" & SQL(2,K) & "_Unit"">"
					  If Not KS.IsNul(SQL(9,k)) Then
				       Dim KK,UnitOptionsArr:UnitOptionsArr=Split(SQL(9,k),vbcrlf)
					   For KK=0 To Ubound(UnitOptionsArr)
					      InputStr=InputStr & "<option value='" & UnitOptionsArr(KK) & "'>" & UnitOptionsArr(KK) & "</option>"                 
					   Next
					  End If
					  InputStr=InputStr & "</select>"
			End If
			  
			  'if SQL(1,K)=9 Then InputStr=InputStr & "<div><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_UpFile.asp?UPType=Field&FieldID=" & SQL(2,K) & "&ChannelID=101' frameborder=0 scrolling=no width='100%' height='26'></iframe></div>"
			  If KS.Setting(149)="0" and lcase(SQL(2,K))="mobile" Then
			   Template=Replace(Template,"{@NoDisplay(" & SQL(2,K) & ")}","")
			  ElseIf Instr(Template,"{@NoDisplay(" & SQL(2,K) & ")}")<>0 Then
			   Template=Replace(Template,"{@NoDisplay(" & SQL(2,K) & ")}"," style='display:none'")
			  End If
			   Template=Replace(Template,"[@" & replace(SQL(2,K),"&","") & "]",InputStr)
			  End If
		   Next
		    Template=Replace(Template,"{@NoDisplay}","")
			ks.die template
			KS.Die Escape(Template)
		End Sub
		

		   '取得联动菜单
		   Function GetLDMenuStr(ChannelID,byVal ParentFieldName,JSStr)
		     Dim OptionS,OArr,I,VArr,V,F,Str
		     Dim RSL:Set RSL=Conn.Execute("Select Top 1 FieldName,Title,Options,Width From KS_Field Where ChannelID=" & ChannelID & " and ParentFieldName='" & ParentFieldName & "'")
			 If Not RSL.Eof Then
			     Str=Str & " <select name='" & RSL(0) & "' id='" & RSL(0) & "' onchange='fill" & RSL(0) & "(this.value)' style='width:" & RSL(3) & "px'><option value=''>--请选择--</option>"
				 JSStr=JSStr & "var sub" &ParentFieldName & " = new Array();"
				  Options=RSL(2)
				  OArr=Split(Options,Vbcrlf)
				  For I=0 To Ubound(OArr)
				    Varr=Split(OArr(i),"|")
					If Ubound(Varr)=1 Then 
					 V=Varr(0):F=Varr(1)
					Else
					 V=trim(OArr(i))
					 F=trim(OArr(i))
					End If
				    JSStr=JSStr & "sub" & ParentFieldName&"[" & I & "]=new Array('" & V & "','" & F & "')" &vbcrlf
				  Next
				 Str=Str & "</select>"
				 JSStr=JSStr & "function fill"& ParentFieldName&"(v){" &vbcrlf &_
							   "$('#"& RSL(0)&"').empty();" &vbcrlf &_
							   "$('#"& RSL(0)&"').append('<option value="""">--请选择--</option>');" &vbcrlf &_
							   "for (i=0; i<sub" &ParentFieldName&".length; i++){" & vbcrlf &_
							   " if (v==sub" &ParentFieldName&"[i][0]){document.getElementById('" & RSL(0) & "').options[document.getElementById('" & RSL(0) & "').length] = new Option(sub" &ParentFieldName&"[i][1], sub" &ParentFieldName&"[i][1]);}}" & vbcrlf &_
							   "}"

				 GetLDMenuStr=str & GetLDMenuStr(ChannelID,RSL(0),JSStr)
			 Else
			     JSStr=JSStr & "function fill" & ParentFieldName &"(v){}"				 
			 End If
			     
		   End Function
		
		
		Sub getCityOption()
		  Dim Province,XML,Node
		  Province=replace(KS.DelSQL(UnEscape(Request("Province"))),"'","")
		  Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		  RS.Open "Select top 200 a.ID,a.City From KS_Province a Inner Join KS_Province b On A.ParentID=B.ID Where B.City='" & Province & "' order by a.orderid,a.id",conn,1,1
		  If Not RS.Eof Then
		    Set XML=KS.RsToXml(Rs,"row","")
		  End If
		  RS.Close : Set RS=Nothing
		  If IsObject(XML) Then
		   For Each Node In XML.DocumentElement.SelectNodes("row")
  		    KS.Echo "<option value=""" & node.SelectSingleNode("@city").text &""">" & node.SelectSingleNode("@city").text &"</option>"
		   Next
		  End If
		  Set XML=Nothing
		End Sub
End Class
%> 
