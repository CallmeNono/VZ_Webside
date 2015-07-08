<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="function.asp"-->
<!--#include file="../KS_Cls/template.asp"-->
<%

Dim KSCls
Set KSCls = New Ask_Show_List
KSCls.Kesion()
Set KSCls = Nothing

Class Ask_Show_List
        Private classid,cid,topicmode,child,classname,parentstr
		Private SqlStr,Topic,classarr,Catelist,CurrPage,totalPut,MaxPerPage,I,M,PageNum
        Private KS, KSR,KSUser,UserLoginTF
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		  Set KSUser=New UserCls
		  MaxPerPage=15
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		End Sub

		Public Sub Kesion()
		   GetQueryParam
		   UserLoginTF=Cbool(KSUser.UserLoginChecked)
		   GetZJList
		   showmain
		   set topic=nothing
		   set classarr=nothing
		End Sub
		
		Sub ShowMain()
			 Dim FileContent
			 FileContent = KSR.LoadTemplate(KS.ASetting(49))    
			 FCls.RefreshType = "asklist" '设置刷新类型，以便取得当前位置导航等
			 FCls.RefreshFolderID = "0"   '设置当前刷新目录ID 为"0" 以取得通用标签
			 FileContent=KSR.KSLabelReplaceAll(FileContent)
			 Scan FileContent
		End Sub
		
		Sub GetQueryParam()
		  If KS.S("page") <> "" Then
			  CurrPage = CInt(Request("page"))
		  Else
			  CurrPage = 1
		  End If
		End Sub
		
		
		Sub GetZJList()
		    Dim Param,show,OrderStr
			Show=Request("show")
			Param=" Where status=1"
			OrderStr="Order By id"
			if request("t")<>"" then
			 Param=Param & " and typename='" & KS.S("T") & "'"
			end if
			if request("province")<>"" then
			 Param=Param & " and province='" & KS.S("Province") & "'"
			end if
			if request("city")<>"" then
			 Param=Param & " and city='" & KS.S("City") & "'"
			end if
			if request("key")<>"" then
			 Param=Param & " and (username like '%" & KS.S("key") & "%' or realname like '%" & KS.S("KEY") & "%')"
			end if
			if Show<>"" Then
			  If Show="tj" Then
			   Param=Param & " and recommend=1"
			  elseIf Show="new" Then
			   OrderStr="Order By id Desc"
			  end if
			End If
			SQLStr="SELECT id,userid,username,userface,realname,typename,qq,msn,intro FROM KS_AskZJ " & Param & " " & OrderStr
			Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
			RS.Open SQLStr,Conn,1,1
			If Not RS.Eof Then
			                TotalPut= rs.recordcount
							If CurrPage < 1 Then CurrPage = 1
							If CurrPage >1 and (CurrPage - 1) * MaxPerPage < totalPut Then
									RS.Move (CurrPage - 1) * MaxPerPage
							Else
									CurrPage = 1
							End If
							Topic=RS.GetRows(MaxPerPage)
			End If
			RS.Close:Set RS=Nothing
		End Sub
		
	
        Sub ParseArea(sTokenName, sTemplate)
			Select Case sTokenName
				Case "zjlist"
				    If IsArray(Topic) Then 
					 For i=0 To Ubound(Topic,2) 
						Scan sTemplate
					 Next 
				    Else
					
					End If
			End Select 
        End Sub 
		Sub ParseNode(sTokenType, sTokenName)
		 Select Case lcase(sTokenType)
		   case "search" EchoSearchItem sTokenName
		   case "zjlist"  EchoTopicItem sTokenName
		   case "left" EchoTypeList
		   case "foot"
		     echo KS.ShowPage(totalput, MaxPerPage, "", CurrPage,false,false)
		 End Select
		End Sub
		
		Sub EchoTypeList()
		 Dim TypeArr,II
		 If Not KS.IsNul(KS.ASetting(48)) Then
			  TypeArr=Split(KS.ASetting(48),vbcrlf)
			 for ii=0 to Ubound(TypeArr)
					 echo "<li><a href=""?t=" & server.URLEncode(TypeArr(ii)) & """>" & TypeArr(ii) & "</a></li>"
			 next
		 End If
		End Sub
		Sub EchoSearchItem(sTokenName)
		  Select Case sTokenName
		   	Case "typelist" echo "<select name=""t"">" 
			 echo "<option value=''>---分类不限---</option>"
			 Dim TypeArr,II
			 If Not KS.IsNul(KS.ASetting(48)) Then
				  TypeArr=Split(KS.ASetting(48),vbcrlf)
				 for ii=0 to Ubound(TypeArr)
				    if request("t")=TypeArr(ii) Then
						 echo "<option value=""" & TypeArr(ii) & """ selected>" & TypeArr(ii) & "</a></option>"
					else
						 echo "<option value=""" & TypeArr(ii) & """>" & TypeArr(ii) & "</a></option>"
					End If
				 next
			 End If
			echo "</select>"
		   Case "area"
		       echo "<script src=""../plus/area.asp"" language=""javascript""></script>"&vbcrlf
			   echo "<script type=""text/javascript"">"&vbcrlf
			   if request("Province")<>"" then
			            echo "$('#Province').val('" & KS.S("province") &"');"&vbcrlf
			   end if
			   if request("City")<>"" Then
					    echo "$('#City')[0].options[1]=new Option('" & KS.S("City") & "','" & KS.S("City") &"');" &VBCRLF
						echo "$('#City')[0].options(1).selected=true;" &vbcrlf
			   end if
			   echo "</script>"
		  End Select
		End Sub
		Sub EchoTopicItem(sTokenName)
		  Select Case sTokenName
		   	Case "autoid" 
			 If CurrPage=1 Then
			  Echo i+1
			 Else
			  Echo MaxPerPage*(CurrPage-1)+i+1
			 End If
			Case "userid" Echo Topic(1,i) 
			Case "realname" Echo Topic(4,i) 
			Case "typename" Echo Topic(5,i) 
			Case "intro" Echo Topic(8,i) 
			Case "spaceurl" Echo KS.GetSpaceUrl(Topic(1,i))
			Case "userface" 
			 dim face:face=Topic(3,i)
			 if ks.isnul(face) then face="/images/nopic.gif"
			 Echo face
		  End Select
		End Sub

	    '伪静态分页
		Public Function ShowPage()
		           Dim I, pageStr
				   pageStr= ("<div id=""fenye"" class=""fenye""><table border='0' align='right'><tr><td>")
					if (CurrPage>1) then pageStr=PageStr & "<a href=""list-" & classid & "-" & CurrPage-1 & "-" & m & KS.ASetting(17) & """ class=""prev"">上一页</a>"
				   if (CurrPage<>PageNum) then pageStr=PageStr & "<a href=""list-" & classid & "-" & CurrPage+1 & "-" & m & KS.ASetting(17) & """ class=""next"">下一页</a>"
				   pageStr=pageStr & "<a href=""list-" & classid & "-1-" & m & KS.ASetting(17) & """ class=""prev"">首 页</a>"
				 
					Dim startpage,n,j
					 if (CurrPage>=7) then startpage=CurrPage-5
					 if PageNum-CurrPage<5 Then startpage=PageNum-10
					 If startpage<0 Then startpage=1
					 n=0
					 For J=startpage To PageNum
						If J= CurrPage Then
						 PageStr=PageStr & " <a href=""#"" class=""curr""><font color=red>" & J &"</font></a>"
						Else
						 PageStr=PageStr & " <a class=""num"" href=""list-" & classid & "-" & J & "-" & m & KS.ASetting(17)&""">" & J &"</a>"
						End If
						n=n+1 : if n>=10 then exit for
					 Next
					
					 PageStr=PageStr & " <a class=""next"" href=""list-" & classid & "-" & PageNum & "-" & m & KS.ASetting(17)&""">末页</a>"
					 pageStr=PageStr & " <span>共" & totalPut & "条记录,分" & PageNum & "页</span></td></tr></table>"
				     PageStr = PageStr & "</td></tr></table></div>"
			         ShowPage = PageStr
	     End Function
End Class
%>
