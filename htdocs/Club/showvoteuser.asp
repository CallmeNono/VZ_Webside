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
%>
<html>
<head>
<title>查看投票用户列表</title>
<style type="text/css">
body {
	margin: 0px auto; font: 12px/1.5em Arial Helvetica "sans-serif"; height: 100%;  font-size:12px;
}
html, body, h1, h2, h3, h4, ul, li, dl,input{ font-family:Arial, Helvetica, sans-serif; list-style:none; margin:0px;padding:0px; }
div, p{ font-family:Arial, Helvetica, sans-serif;  }

td,th{font-size:12px}

a {
	color:#555; padding:0px; text-decoration:none
}
a:link {
	background: none transparent scroll repeat 0% 0%;color:#555;
}
a:hover {
	color: #ff0000; text-decoration: underline
}
.tableborder1{margin:4px;background:#f1f1f1;}
.tableborder1 td,th{background:#fff}
#fenye{clear:both;}
#fenye a{text-decoration:non;}
#fenye .prev,#fenye .next{width:52px; text-align:center;}
#fenye a.curr{width:22px;background:#1f3a87; border:1px solid #dcdddd; color:#fff; font-weight:bold; text-align:center;}
#fenye a.curr:visited {color:#fff;}
#fenye a{margin:5px 4px 0 0; color:#1E50A2;background:#fff; display:inline-table; border:1px solid #dcdddd; float:left; text-align:center;height:22px;line-height:22px}
#fenye a.num{width:22px;}
#fenye a:visited{color:#1f3a87;} 
#fenye a:hover{color:#fff; background:#1E50A2; border:1px solid #1E50A2;float:left;}
#fenye span{display:block;margin:10px}
</style>
</head>
<body>
<table cellpadding="3" cellspacing="1" align="center" class="tableborder1" style="width:98%">
<tr>
<th height="24">用户</th>
<th>所选项目</th>
</tr>
<%
Dim XML,VoteOptions,optionArr,I,MaxPerPage,TotalPut
Dim KS:Set KS=New PublicCls
Dim VoteID:VoteID=KS.ChkClng(KS.S("voteid"))
If VoteID=0 Then KS.Die "error!"
MaxPerPage=100
Dim RS:Set RS=Server.CreateObject("adodb.recordset")
RS.Open "Select UserName,VoteTime,VoteOptions From KS_PhotoVote Where ChannelID=-1 And InfoID='" &VoteID&"'",conn,1,1
IF RS.Eof And RS.Bof Then
      RS.Close:Set RS=Nothing
      KS.Die "<tr><td colspan=2 style='text-align:center;height:30px'>没有投票记录!</td></tr></table>"
Else
		TotalPut= Conn.Execute("Select count(*) from KS_PhotoVote Where ChannelID=-1 And InfoID='" &VoteID&"'")(0)

        If CurrentPage > 1 and  (CurrentPage - 1) * MaxPerPage < totalPut Then
             RS.Move (CurrentPage - 1) * MaxPerPage
        End If
		Set XML=LFCls.GetXMLFromFile("voteitem/vote_"&VoteID)
		dim n:n=0
		Do While Not RS.Eof 
		  VoteOptions=RS("VoteOptions")
		  If Not KS.IsNul(VoteOptions) Then
		   optionArr=split(VoteOptions,",")
		   Dim Str,Node
		   str=""
		   For I=0 To Ubound(optionArr)
			  Set Node=XML.DocumentElement.SelectSingleNode("voteitem[@id=" & OptionArr(i) & "]")
			  if str="" then str=Node.childNodes(0).text else str=str & "<br/>" & Node.childNodes(0).text
		   Next
		  End If
		  KS.Echo "<tr><td><a href='" & KS.Setting(3) & "space/?" & rs("username") & "' target='_blank'>" & rs("username") & "</a></td><td>" & str & "</td></tr>"
		  n=n+1
		  if n>maxperpage then exit do
		RS.MoveNext
		Loop

    End IF

%>
</table>
<%
Response.Write KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,false)
RS.Close
Set RS=Nothing
Set KS=Nothing
CloseConn
%>
</body>
</html>