<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.IfCls.asp"-->
<!--#include file="config.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New SiteIndex
KSCls.Kesion()
Set KSCls = Nothing

Class SiteIndex
        Private KS, KSR,str,c_str,curr_tips,pid,ads_str,s_str,ID,ClassName,S,showStr
		Private TotalPut,MaxPerPage,CurrentPage,Key,Template
		Private url,spaceurl,msgurl,contacturl,node,logo
		Private Sub Class_Initialize()
		 If (Not Response.IsClientConnected)Then
			Response.Clear
			Response.End
		 End If
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		  MaxPerPage=10
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		End Sub
		Public Sub Kesion()
			If KS.S("page") <> "" Then
			  CurrentPage = CInt(Request("page"))
			Else
			  CurrentPage = 1
			End If
			If CurrentPage < 1 Then CurrentPage = 1

			Key=KS.CheckXSS(KS.S("Key"))
			If Request("province")<>"" Or Request("City")<>"" Then
			 ClassName=KS.CheckXSS(KS.S("Province")&KS.S("City")) 
			ElseIf Key<>"" Then
			 ClassName=Key
			Else
			 ClassName="供求搜索"
			End If
			
			 Template = KSR.LoadTemplate(KS.Setting(3) & KS.Setting(90) & "企业空间/gq_list.html")
			 FCls.RefreshType = "enterpriseprolist" '设置刷新类型，以便取得当前位置导航等
			 FCls.RefreshFolderID = ID '设置当前刷新目录ID 为"0" 以取得通用标签
			 Fcls.Locationstr=className
			  getcategory
			  call GetProductList()
			  call getsearchlist()
			 Template=Replace(Template,"{$ShowClassName}",ClassName)
			 Template=Replace(Template,"{$ShowProductList}",c_str)
			 Template=Replace(Template,"{$ShowSearch}",s_str)
			 Template=Replace(Template,"{$ShowPage}",KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,false))
			 Template=KSR.KSLabelReplaceAll(Template)
		 Response.Write Template  
		End Sub
		
		Sub getcategory()
		 Dim RS,SQL,I,str
		 Set RS=Server.CreateObject("ADODB.RECORDSET")
		 RS.Open "Select ID,City From KS_Province Where ParentID=0 Order By OrderID,ID",conn,1,1
		 If Not RS.Eof Then
		   SQL=RS.GetRows(-1)
		 End If
		 RS.Close
		 Set RS=Nothing
		 For I=0 To Ubound(SQL,2)
		   str=str & "<li><a href='?province=" & server.URLEncode(sql(1,i)) & "'>" & SQL(1,I) & "(" & conn.execute("select count(1) from ks_gq where province='" & sql(1,i) & "'")(0) & ")</a></li>"
		 Next
		 Template=Replace(Template,"{$ShowArea}",str)
		End Sub
		
		
		Sub GetSearchList()
		  s_str="<form action='?' name='psform' method='get'>"
		  s_str=s_str & "<input type='text' name='key' size='30'>"
		  s_str=s_str & "&nbsp;<select name='t'><option value='0'>显示所有产品</option><option value='1'>显示今日最新</option><option value='3'>显示最近3天</option><option value='5'>显示最近5天</option><option value='7'>显示最近7天</option><option value='15'>显示最近15天</option><option value='30'>显示最近30天</option><option value='90'>显示最近三个月</option><option value='180'>显示最近半年</option></select>"
		  s_str=s_str & "&nbsp;<select name='pid'>"
		  
		  
		Dim Node,K,SQL,NodeText,Pstr,TJ,SpaceStr,TreeStr
		KS.LoadClassConfig()
		For Each Node In Application(KS.SiteSN&"_class").DocumentElement.SelectNodes("class[@ks14=1 and @ks12=8]")
		       SpaceStr=""
			   If trim(pid)=trim(Node.SelectSingleNode("@ks9").text) then pstr=" selected" else pstr=""
			  TJ=Node.SelectSingleNode("@ks10").text
			  If TJ>1 Then
				 For k = 1 To TJ - 1
					SpaceStr = SpaceStr & "──"
				 Next
				s_str=s_str & "<option value='" & Node.SelectSingleNode("@ks9").text & "'" &pstr &">" & SpaceStr & Node.SelectSingleNode("@ks1").text & " </option>"
			  Else
				s_str=s_str & "<option value='" & Node.SelectSingleNode("@ks9").text & "'" &pstr &">" & Node.SelectSingleNode("@ks1").text & " </option>"
			  End If
		Next
		  
		  
		  s_str=s_str & "</select>&nbsp;<input onclick=""if(document.psform.key.value==''){alert('请输入关键字!');document.psform.key.focus();return false;}"" type='image' src='../images/btn.gif' align='absmiddle'>"
		  s_str=s_str & "</form>"
		End Sub
		
		
		
		Sub GetProductList()
		  c_str="<div class=""productorder""><a href='?"&KS.QueryParam("page,popular,recommend") & "'>默认排序</a> <a href='?recommend=1&"& KS.QueryParam("page,popular,recommend") & "'>推荐产品</a> <a href='?popular=1&"&KS.QueryParam("page,popular,recommend") & "'>热门产品</a> &nbsp;&nbsp;&nbsp;&nbsp;<strong>分类筛选:</strong>"
		  Dim RST:Set RST=Conn.Execute("select * from KS_GQType order by typeid")
		  If Not RST.Eof Then
		     do while not rst.eof
		     c_str=c_str & "<a href='?typeid=" & rst("typeid") &"' style='color:" & rst("typecolor") & "'>" & rst("typename") & "</a> "
			 rst.movenext
			 loop
		  End If
		  RST.Close:Set RST=Nothing
		  c_str=c_str &"</div>"

		 Dim Param:Param=" where a.verific=1 and a.deltf=0"
		 If Key<>"" Then 
		  Param=Param & " and a.title like '%" & Key & "%'"
		 Else
		  Param=Param & " and tid in(select id from ks_class where ts like '%" & id & "%')"
		 End If
		 If KS.ChkClng(request.QueryString("typeid"))<>0 then Param=Param & " and a.typeid=" & KS.ChkClng(request.QueryString("typeid"))
		 If KS.S("Recommend")="1" Then Param =Param & " and a.recommend=1"
		 If KS.S("Popular")="1" Then Param=Param & " and a.popular=1"
		 
		 If KS.ChkClng(KS.S("T"))<>0 Then
			  Param=Param & " and datediff("& DataPart_D&",a.AddDate," &SqlNowString & ")<" & KS.ChkClng(KS.S("T"))
		 End If
		 If KS.S("Province")<>"" Then
		      Param=Param & " and province='" & KS.S("Province") & "'"
		 End If
		 If KS.S("City")<>"" Then
		      Param=Param & " and city='" & KS.S("City") & "'"
		 End If
		 
		 Dim RS,SqlStr,OrderStr,XML,Node
		 OrderStr=" order by a.istop desc,a.id desc"
		 SqlStr="select b.BlogName,b.userid,[domain],a.inputer,a.id,a.price,a.title,a.tid,a.fname,a.gqcontent,a.PhotoUrl,a.recommend,a.popular,a.typeid,a.province,a.city,a.adddate from KS_GQ a inner join ks_blog b on a.inputer=b.username "&param& OrderStr
		 Set RS=Server.CreateObject("adodb.recordset")
		 rs.open SqlStr,conn,1,1
		 IF RS.Eof And RS.Bof Then
			  totalput=0
			  exit sub
		  Else
						TotalPut= Conn.Execute("Select count(id) from KS_GQ a " & Param)(0)
						If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
							RS.Move (CurrentPage - 1) * MaxPerPage
						Else
							CurrentPage = 1
						End If
						Set XML=KS.ArrayToXml(RS.GetRows(MaxPerPage),RS,"row","")
						If IsObject(XML) Then
							Call ShowByList(Xml)
						End If
		End IF
			
			
			RS.Close
			Set RS=Nothing
		End Sub
		
		Sub GetUrl()
		    Dim PreUrl
			If KS.SSetting(14)<>"0" and node.selectsinglenode("@domain").text <>"" then 
			  if instr(node.selectsinglenode("@domain").text,".")<>0 then
			   spaceurl="http://" & node.selectsinglenode("@domain").text
			  else
			   SpaceUrl="http://" & node.selectsinglenode("@domain").text &"."& KS.SSetting(16)
			  end if
			  PreUrl=SpaceUrl
			Else
			  If KS.SSetting(21)="1" Then 
			   SpaceUrl="../space/" & node.selectsinglenode("@userid").text
			  Else
			   SpaceUrl="../space/?" & node.selectsinglenode("@userid").text
			  End If
			  PreUrl="../space"
			End If
			  url=KS.GetItemURL(8,node.selectsinglenode("@tid").text,node.selectsinglenode("@id").text,node.selectsinglenode("@fname").text)
			  If KS.SSetting(21)="1" Then 
			  msgUrl=PreUrl & "/message-" & node.selectsinglenode("@userid").text 
			  contacturl=PreUrl & "/info-" & node.selectsinglenode("@userid").text 
			 Else 
			  msgUrl=PreUrl & "/?" & node.selectsinglenode("@userid").text & "/message"
			  contacturl=PreUrl & "/?" & node.selectsinglenode("@userid").text & "/info"
			 End If
		End Sub
		
		
		Sub ShowByList(Xml)
		 Dim I,n
		 c_str=c_str & "<table width=""100%"" class=""product_list"" border=""0"" align=""center"" cellpadding=""1"" cellspacing=""1"">" & vbcrlf
         c_str=c_str & "<tr bgcolor=""#E7E7E7"">"
         c_str=c_str & "<td width=""100"" height=""26"" align=""center"">产品图片</td>"
         c_str=c_str & "<td align=""center"">产品/公司</td>"
         c_str=c_str & "<td width=""115"" align=""center"">留言询价</div></td>"
         c_str=c_str & "</tr>"
		 For Each Node In XML.DocumentElement.SelectNodes("row")
		 logo=trim(Node.SelectSingleNode("@photourl").text)
		 if KS.isnul(logo) then 
		  logo="/images/nopic.gif"
		 end if
		 dim str:str=""
		 if node.selectsinglenode("@recommend").text="1" then str="<font color=green>荐</font>"
		 if node.selectsinglenode("@popular").text="1" then str= str & " <font color=red>热</font>"
		
		 GetUrl
         n=n+1
		 if n mod 2=0 then
		 c_str=c_str & "<tr bgcolor=""#f6f6f6"">"
		 else
         c_str=c_str & "<tr>"
		 end if
         c_str=c_str & "<td height=""125"" align=""center"" class=""pic""><a href='" & url & "' target='_blank'><img onerror=""this.src='../images/nopic.gif'"" src=""" & logo & """ width=80 height=80 border='0'/></a></td>"
         c_str=c_str & "<td  valign='top' style=""padding:5px;WORD-BREAK: break-all""><a class=""company_title"" href=""" & url & """ target=""_blank"" class='productname'>" & KS.GetGQTypeName(Node.SelectSingleNode("@typeid").text) & node.selectsinglenode("@title").text &"</a>  <span class='adate'>" & formatdatetime(Node.SelectSingleNode("@adddate").text,2) & "" & str & "     </span><br/><span class='attribute'>类别：" & KS.C_C(Node.SelectSingleNode("@tid").text,1) & " 地区：" & Node.SelectSingleNode("@province").text & Node.SelectSingleNode("@city").text & "<br/>描述：" & KS.Gottopic(KS.LoseHtml(KS.HtmlCode(node.selectsinglenode("@gqcontent").text)),120) & "...</span>"
		 If Not KS.IsNul(node.selectsinglenode("@blogname").text) Then
		 c_str=c_str & "<br/><span class='company_name'><a href='" & SpaceUrl & "' target='_blank'>" & node.selectsinglenode("@blogname").text  &"</a></span> ( <img src=""../images/lx.gif"" align=""absmiddle"" /> <a href='" & contacturl & "' target='_blank'>查看该公司联系方式</a> )"
		 End If
		 c_str=c_str &"</td>"
         c_str=c_str & "<td align=""center""><a class=""liuyan"" href='" & msgUrl &"' target='_blank'>留言询价</a><br/><br/><img src=""../images/icon7.png"" align=""absmiddle""> <a href='../User/User_Favorite.asp?Action=Add&ChannelID=8&InfoID=" & node.selectsinglenode("@id").text & "' target='_blank'>收藏</a> <img src=""../images/icon11.png"" align=""absmiddle""> <a href='../plus/Comment.asp?ChannelID=8&InfoID=" & node.selectsinglenode("@id").text & "' target='_blank'>评论</a></td>"
         c_str=c_str & "</tr>"
		 I=I+1
		 Next
         c_str=c_str & "</table>"
		End Sub
		
End Class
%>