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
Set KSCls = New UserList
KSCls.Kesion()
Set KSCls = Nothing

Class UserList
        Private KS,KSUser
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		 CloseConn
		End Sub
		%>
		<!--#include file="../KS_Cls/UserFunction.asp"-->
		<%
		Public Sub loadMain()
         KSUser.Head()
		 Call KSUser.InnerLocation("所有注册会员")	
		 %>
		 <div class="tabs">	
			<ul>
				<li class='puton'>所有注册会员</li>
			</ul>
			<div style="padding-top:8px">
			·<a href="?ListType=1">按会员ID排序</a> ·<a href="?ListType=2">按注册日期排序</a> ·<a href="?ListType=3">按登录次数排序</a>
			</div>
		</div>
	
	   <style>
	     .ulist{}
		 .ulist li{clear:both;margin-bottom:10px;}
		 .ulist li .l{width:70px;float:left}
		 .ulist li .r{width:700px;padding-bottom:10px;float:left;line-height:20px;border-bottom:1px solid #efefef;}
	   </style>
	   <div class="ulist">
	   <ul>
      <%
	
  		Dim  totalPut,RS,MaxPerPage,SqlStr,ListType,Param
		ListType=KS.ChkClng(KS.S("ListType"))
		MaxPerPage =15

       
			  
			  Set RS=Server.CreateObject("Adodb.Recordset")
			  Param=" where groupid<>1"
			  if KS.S("Username")<>"" then
			   Param= Param & " and username like '%" & KS.R(ks.s("username")) & "%'"
			  end if
			  If KS.S("Tag")<>"" Then
			   Param=Param &" and mylabel like '%" & KS.S("Tag") & "%'"
			  End If
			  
			  dim OrderStr
			  If ListType=1 Then
			   OrderStr = " Order By UserID Desc"
			  ElseIF ListType=2 Then
			   OrderStr = " Order By LastLoginTime Desc"
			  ElseIF ListType=3 Then
			   OrderStr = " Order By LoginTimes Desc"
			  End IF
			   SqlStr="Select * From KS_User " & Param & OrderStr
			  RS.Open SqlStr,Conn,1,1
			       If Not RS.EOF  Then
							totalPut = Conn.Execute("select count(1) from ks_user " & Param)(0)
								If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
								End If
								Dim I,Privacy
			  Do While Not RS.Eof 
			   Privacy=RS("Privacy")
                response.write "<li > " &vbNewLine
              response.write   "<div class='l'><div class=""avatar48""><img onerror=""this.src='images/noavatar_small.gif';""  src=""" & rs("userface") & """></div></div>" & vbnewline
              response.write   "<div class='r'><a href=""../space/?" & RS("Userid") & """ target=""_blank"">" & RS("UserName") & "</a><br/>登录次数：" & RS("LoginTimes") & "次 最后登录时间" & RS("LastLoginTime")  & "<br/>关注 <a target=""_blank"" href=""weibo.asp?userid=" & rs("userid") & "&f=att"">" & rs("attentionnum") & "</a> 人 | 粉丝 <a target=""_blank"" href=""weibo.asp?userid=" & rs("userid") & "&f=fans"">" & rs("fansnum") & "</a> 人 | 广播 <a target=""_blank"" href=""weibo.asp?userid=" & rs("userid") & """>" & rs("msgnum") & "</a> 条"
			  
			  if ks.isnul(rs("mylabel")) then
				response.write "<br/><span class='msgtips'>个性标签：未设置</span>"
				else
				  if request("tag")<>"" then
				    response.write "<br/><span class='msgtips'>个性标签：" & replace(rs("mylabel"),ks.s("tag"),"<span style='color:red;font-weight:bold'>" & ks.s("tag") & "</span>") &"</span>"
				  else
				    response.write "<br/><span class='msgtips'>个性标签：" & rs("mylabel") & "</span>"
				  end if
				end if
			  
			  response.write "</div></li>" & vbcrlf
             RS.MoveNext
			I = I + 1
				If I >= MaxPerPage Then Exit Do
			 Loop
			 
	  End If
	  
	  response.write "</ul>"
	  response.write "</div>"
	Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)
       

		 response.write  "<form action='userlist.asp' name='myform' method='pose'>" & vbcrlf
		 response.write "&nbsp;&nbsp;&nbsp;快速查找用户->&nbsp;用户名:<input class=""textbox"" type=""text"" name=""username"" size=""20"" maxlength=""30"">" & vbcrlf
		 response.write "<input type='submit' class=""button"" value='搜索'>" & vbcrlf
		 response.write "</form>" & vbcrlf
		  RS.Close:Set RS=Nothing
    End Sub
		  
End Class
%> 
