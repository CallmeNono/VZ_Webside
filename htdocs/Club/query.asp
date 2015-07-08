<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Template.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New QueryCls
KSCls.Kesion()
Set KSCls = Nothing

Class QueryCls
        Private KS,ChannelID,ModelTable,Param,XML,Node,StartTime
		Private CurrPage,MaxPerPage,TotalPut,PageNum,Key,KeyArr,stype,OrderStr
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  MaxPerPage=20
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/Kesion.IfCls.asp"-->
		<!--#include file="../KS_Cls/ClubFunction.asp"-->
		<%
		
		Public Sub Kesion()
		 Key=KS.CheckXSS(KS.S("Key"))
		 If InStr(Key," ")<>0 Then KeyArr=Split(Key," ")
		 CurrPage=KS.ChkClng(Request("Page"))
		 stype=KS.ChkClng(Request("stype"))
		  If CurrPage<=0 Then CurrPage=1
		 
		Dim RefreshTime:RefreshTime = 2  '设置防刷新时间
		 If Key<>"" and CurrPage=1 Then
			If DateDiff("s", Session("SearchTime"), Now()) < RefreshTime Then
				Response.Write "<META http-equiv=Content-Type content=text/html; charset=utf-8><meta HTTP-EQUIV=REFRESH CONTENT="&RefreshTime&"><br>本页面起用了防刷新机制，请不要在"&RefreshTime&"秒内连续刷新本页面<BR>正在打开页面，请稍后……"
				Response.End
			End If
         End If
			Session("SearchTime")=Now()
		 
		 StartTime = Timer()
		 Dim Template,KSR
		 FCls.RefreshType = "clubsearch"   
		 Set KSR = New Refresh
		   If KS.Setting(171)="" Then KS.Die "请先到""基本信息设置->模板绑定""进行模板绑定操作!"
		   Template = KSR.LoadTemplate(KS.Setting(171))
		  GetClubPopLogin Template
		   
		   If KS.ChkClng(KS.Setting(164))=0 And KS.C("UserName")="" Then
		     GCls.ComeUrl=Gcls.GetUrl() 
		     Templates = Replace(Template,KS.CutFixContent(Template, "[SearchContent]", "[/SearchContent]", 1),GetClubErrTips("error8",true))
		   Else 
			   Call KS.LoadClubBoard()
			   Dim node,Xml,n,Str
			   Set Xml=Application(KS.SiteSN&"_ClubBoard")
			   for each node in xml.documentelement.selectnodes("row[@parentid=0]")
					  Str=Str&("<option value='" & node.SelectSingleNode("@id").text & "'>+" & node.selectsinglenode("@boardname").text &"</option>")
					for each n in xml.documentelement.selectnodes("row[@parentid=" & Node.SelectSingleNode("@id").text & "]")
					  Str=Str&("<option value='" & N.SelectSingleNode("@id").text & "'>&nbsp;|-" & n.selectsinglenode("@boardname").text &"</option>")
					next
				next
				Template=Replace(Template,"{$BoardOption}",Str)
				
				 If Not KS.IsNul(Key) Then
				   If Len(Key)<2 Or Len(Key)>20 Then
				    KS.Die "<script>alert('对不起，关键词长度必须是大于2小于20!');location.href='?';</script>"
					Exit Sub
				   ElseIf stype>7 or stype<=0 Then
				    KS.AlertHintScript "对不起，非法参数"
					Exit Sub
				   Else
				    InitialSearch()
				   End If
				 ElseIf stype>=3 And stype<=6 Then
				   Template = Replace(Template,KS.CutFixContent(Template, "[ShowKeySearch]", "[/ShowKeySearch]", 1),"")
				   InitialSearch()
				 Else
		           Template = Replace(Template,KS.CutFixContent(Template, "[SearchResult]", "[/SearchResult]", 1),"")
				 End If
				 Immediate=false
				 Scan Template
		   End If
		   Templates=RexHtml_IF(Templates)
		   Templates=Replace(Replace(Templates,"[SearchContent]",""),"[/SearchContent]","")
		   Templates=Replace(Replace(Templates,"[SearchResult]",""),"[/SearchResult]","")
		   Templates=Replace(Replace(Templates,"[ShowKeySearch]",""),"[/ShowKeySearch]","")
		   Templates = KSR.KSLabelReplaceAll(Templates)
		   Set KSR = Nothing
		   Templates=Replace(Templates,"{#ExecutTime}","页面执行" & FormatNumber((timer()-StartTime),5,-1,0,-1) & "秒 powered by <a href='http://www.kesion.com' target='_blank'>KesionCMS 9.0</a>")
		   if instr(Templates,"{#GetClubPopLogin}")<>0 Then GetClubPopLogin Templates
		   KS.Echo Templates
		   
	   End Sub
	   Sub ParseArea(sTokenName, sTemplate)
			Select Case sTokenName
				Case "loop"
					If IsObject(XML) Then
					   For Each Node In Xml.DocumentElement.SelectNodes("row")
						Scan sTemplate
					   Next
					Else
					   echo "<tr><td colspan='7' class='border' style='text-align:center'>对不起,根据您的查找条件,找不到任何相关记录!</td></tr>"
					  End If
			End Select 
        End Sub 
		Sub ParseNode(sTokenType, sTokenName)
			Select Case lcase(sTokenType)
			    case "item" EchoItem sTokenName
				case "search" 
				          select case sTokenName
						    case "showpage" echo KS.ShowPage(totalput, MaxPerPage, "", CurrPage,false,false)
							case "totalput" echo TotalPut
							case "leavetime" echo FormatNumber((timer-starttime),5)
							case "keyword" echo Replace(Replace(KS.R(key),"{","｛"),"}","｝")
							case "resulttips"
							 select case stype
							  case 1,2
							    echo "搜索关键词<span style=""color:red"">“" & Replace(Replace(KS.CheckXSS(key),"{","｛"),"}","｝") & "”</span>,共找到条<span style=""color:red"">" & totalput & "</span>记录，搜索结果如下"
							  case 3
							    echo "共找到<span style=""color:red"">" & TotalPut & "</span>篇最新话题"
							  case 4
							    echo "共找到<span style=""color:red"">" & TotalPut & "</span>篇精华帖子"
							  case 5
							    echo "共找到<span style=""color:red"">" & TotalPut & "</span>篇热门帖子"
							  case 6
							    echo "共找到<span style=""color:red"">" & TotalPut & "</span>篇最新回复"
							  end select
							case "searchtype"
							 select case stype
							  case 1,2
							    echo "关键词搜索"
							  case 3
							    echo "最新话题"
							  case 4
							    echo "精华帖子"
							  case 5
							    echo "热门帖子"
							  case 6
							    echo "最新回复"
							  case else
							    echo "论坛搜索"
							  end select
						  end select
			End Select
		End Sub
		Sub EchoItem(sTokenName)
		  Select Case sTokenName
		    case "id" echo GetNodeText("id")
			case "linkurl" 
				    echo KS.GetClubShowURL(GetNodeText("id"))
			case "boardname" 
			Dim BNode:Set BNode=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & KS.ChkClng(GetNodeText("boardid")) &"]")
			If Not BNode Is Nothing Then
				  echo BNode.SelectSingleNode("@boardname").Text 
			End If
			case "boardurl" 
			  echo KS.GetClubListUrl(KS.ChkClng(GetNodeText("boardid")))
			case "addtime"
			  echo KS.GetTimeFormat1(GetNodeText("addtime"),false)
			case "category" 
			  KS.LoadClubBoardCategory
			  Dim CategoryId:CategoryId=KS.ChkClng(GetNodeText("categoryid"))
			  if CategoryId>0  and isobject(Application(KS.SiteSN&"_ClubBoardCategory")) Then
					Dim CategoryNode,categoryName,categoryIco
					Set CategoryNode=Application(KS.SiteSN&"_ClubBoardCategory").DocumentElement.SelectSingleNode("row[@categoryid=" & CategoryId&"]")
					If Not CategoryNode Is Nothing Then
						categoryname=CategoryNode.SelectSingleNode("@categoryname").text : If Instr(categoryname,"[")=0 and categoryname<>"" Then categoryname="[" & categoryname & "]"
						categoryIco=CategoryNode.SelectSingleNode("@ico").text
						echo "<a href=""?" & KS.QueryParam("page,c") &"&c=" &CategoryId&""">" & CategoryName &"</a>"
				    End If
			  End If
			case "subject"
			  echo Replace(Replace(replace(GetNodeText("subject"),key,"<span style='color:red'>" & key & "</span>"),"{","｛"),"}","｝")
			case else
			  echo GetNodeText(sTokenName)
			  
		  End Select
		End Sub
		Function GetNodeText(NodeName)
		 Dim N,Str,I
		 NodeName=Lcase(NodeName)
		 If IsObject(Node) Then
		  set N=node.SelectSingleNode("@" & NodeName)
		  If Not N is Nothing Then Str=N.text
		  If Not KS.IsNul(Key)  And NodeName="subject" Then
		   If IsArray(KeyArr) Then
		     For I=0 To Ubound(KeyArr)
		      Str=Replace(Str,keyArr(i),"<span style='color:red'>" & keyArr(i) & "</span>")
			 NEXT
		   Else
		      Str=Replace(Str,key,"<span style='color:red'>" & key & "</span>")
		   End If
		  End If
		  GetNodeText=Str
		 End If
		End Function
		
		
		Sub InitialSearch()
		  Dim SqlStr,BN,Bids,boardid
		  boardid=KS.ChkClng(Request("boardid"))
		  
		  Param=" Where deltf=0 and Verific<>0"
		  If stype=4 Then  Param=Param &" And IsBest=1"
		  If KS.ChkClng(Request("c"))>0 Then Param=Param &" and CategoryID=" & KS.ChkClng(Request("c"))
		  If Not KS.IsNul(Key) Then
		     If Not IsArray(KeyArr) Then
				select case stype
				 case 2 
				     Param=Param & " And UserName='" & Key & "'"
				 case else
				     Param=Param & " And Subject Like '%" & Key & "%'"
				end select
			 Else
				 Select Case Stype  
				   case 2 Param=Param & " And UserName='" & Key & "'"
				   case else 
				      Dim PP
				     for bn=0 to ubound(KeyArr)
					   If Not KS.IsNul(KeyArr(BN)) Then
					      If KS.IsNul(PP) Then
					       PP=PP & " Subject Like '%" & KeyArr(Bn) & "%'"
						  Else
					       PP=PP & " Or Subject Like '%" & KeyArr(Bn) & "%'"
						  End If
					   End If
					 Next
					 Param=Param & " And (" & PP & ")"
				 End Select
			 End If
         End If
		 
		   If BoardID<>0 Then
		   	   For Each BN In Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectNodes("row[@parentid=" & BoardID & "]")
			   If Bids="" Then
			    Bids=BN.SelectSingleNode("@id").text
			   Else
			    Bids=Bids & "," & BN.SelectSingleNode("@id").text
			   End If
			  Next
			  If Not KS.IsNul(bids) Then  Param=Param & " And boardid in ("&bids&")" Else Param=Param & " And boardid=" & BoardID
		   end if
		 
		  
		  Dim Top,TopStr,OrderStr
		  Select Case Stype
		    case 3 Top=500 :OrderStr=" Order By Id Desc"
			case 4 Top=500 :OrderStr=" Order By ID Desc" 
			case 5 Top=500 :OrderStr=" Order By Hits Desc,Id Desc"
			case 6 Top=500 :OrderStr=" Order By LastReplayTime Desc,Id Desc"
			case Else
			Top=500
			OrderStr=" Order By Id Desc"
		  End Select
		  If Top<>0 Then TopStr=" Top " & Top
		  SqlStr="Select " & TopStr & " ID,Subject,BoardId,UserName,AddTime,LastReplayTime,LastReplayUser,hits,TotalReplay,CategoryId From KS_GuestBook " & Param & OrderStr
		  Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
		  RS.Open SqlStr,conn,1,1
		  If RS.Eof And RS.Bof Then
		  Else
		     TotalPut = Conn.Execute("select Count(1) from KS_GuestBook " & Param)(0)
			 If Top<>0 And TotalPut>Top Then TotalPut=Top
			 If CurrPage >1 and (CurrPage - 1) * MaxPerPage < totalPut Then
					RS.Move (CurrPage - 1) * MaxPerPage
			 Else
					CurrPage = 1
			 End If
			 Set XML=KS.ArrayToXml(RS.GetRows(MaxPerPage),RS,"row","root")
		  End If
		 RS.Close
		 Set RS=Nothing
		End Sub
		
		
		
End Class
%>

 
