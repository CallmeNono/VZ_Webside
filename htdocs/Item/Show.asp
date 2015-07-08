<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit
response.Buffer=true
%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.StaticCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New InfoCls
KSCls.Kesion()
Set KSCls = Nothing

Class InfoCls
        Private KS
		Private Sub Class_Initialize()
		 Set KS=New PublicCls
		End Sub
        Private Sub Class_Terminate()
		 
		End Sub
		Public Sub Kesion()
		  If KS.C_S(KS.ChkClng(KS.S("m")),7)=2 and KS.C_S(KS.ChkClng(KS.S("m")),48)=1 Then Response.Redirect("../?" & GCls.staticPreContent & "-" & KS.ChkClng(KS.S("D")) &"-" & KS.ChkClng(KS.S("m")) &GCls.StaticExtension)

		 StaticCls.Run()
		 CloseConn
		 Set KS=Nothing
	    End Sub
End Class
%>

 
