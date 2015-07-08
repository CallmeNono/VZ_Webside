<%
Dim ACls
Set ACls = New AskCls
Call ACls.run()
Class AskCls
        Private KS
		Private Sub Class_Initialize()
		 If (Not Response.IsClientConnected)Then
			Response.Clear
			Response.End
		 End If
		  Set KS=New PublicCls
		  If  KS.ASetting(0)<>"1" then Call KS.ShowTips("error","<li>对不起，本站没有开启问吧！</li>"):KS.Die ""
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set ACls=Nothing
		End Sub
		
		Sub Run()
		 Call KS.LoadCategoryList()
		End Sub

		
	
	Public Function IndexMenulist()
		Dim Parentlist,Node,strTempMenu
		 If IsObject(Application(KS.SiteSN&"_askclasslist")) Then
			Set Parentlist = Application(KS.SiteSN&"_askclasslist")
			If Not Parentlist Is Nothing Then
				Dim classid,ClassName,Childs,i,depth,strLinks,rootid
				Childs = Parentlist.documentElement.SelectNodes("row").Length
				i = 0
				For Each Node in Parentlist.documentElement.SelectNodes("row[@depth=0]")
					ClassName = Node.selectSingleNode("@classname").text
					classid = Node.selectSingleNode("@classid").text
					depth = Node.selectSingleNode("@depth").text
					rootid = Node.selectSingleNode("@rootid").text
					If KS.ASetting(16)="1" Then
					strLinks = "<a href=""" & KS.Setting(3) & KS.ASetting(1) & "list-" & classid & KS.ASetting(17) & """>"
					Else
					strLinks = "<a href=""" & KS.Setting(3) & KS.ASetting(1) & "showlist.asp?id=" & classid & """>"
					End If
					strLinks = strLinks & ClassName
					strLinks = strLinks & "&raquo;</a> "

					strTempMenu = strTempMenu & "<dt>" & strLinks & "<span class=""num"">(" & conn.execute("select count(1) from ks_asktopic WHERE classid in (SELECT classid FROM KS_AskClass WHERE ','+parentstr+'' like '%,"&classid&",%') And isTop=0 And LockTopic=0")(0) & ")</span></dt>" & vbCrLf
					strTempMenu = strTempMenu & GetChildList(classid,4)
				Next
				Set Parentlist = Nothing
			End If
		End If
		IndexMenulist = strTempMenu
	End Function
	Public Function GetChildList(cid,m)
		Dim Childlist,Node,strTemp,i,ParentLinks
		Dim classid,ClassName,strLinks
		If IsObject(Application(KS.SiteSN&"_askclasslist")) Then
			Set Childlist = Application(KS.SiteSN&"_askclasslist")
			If Not Childlist Is Nothing Then
				i = 0
				strTemp = "<dd>"
				For Each Node in Childlist.documentElement.SelectNodes("row[@parentid="&cid&"]")
					i = i + 1
					ClassName = Node.selectSingleNode("@classname").text
					classid = Node.selectSingleNode("@classid").text
					   If KS.ASetting(16)="1" Then
						strLinks = "<a href=""" & KS.Setting(3) & KS.ASetting(1) & "list-" & classid & KS.ASetting(17) & """>"
					   Else
						strLinks = "<a href=""" & KS.Setting(3) & KS.ASetting(1) & "showlist.asp?id=" & classid & """>"
					   End If
						strLinks = strLinks & ClassName & "</a>"
						if i<>Childlist.documentElement.SelectNodes("row[@parentid="&cid&"]").length then  strlinks=strlinks & "|"
						strTemp = strTemp & strLinks
					'If i mod m=0 Then strTemp =strTemp & "<br />"
				Next
				Set Childlist = Nothing
				strTemp = strTemp & ParentLinks & "</dd>" & vbCrLf
			End If
			Set Childlist = Nothing
		End If
		GetChildList = strTemp
	End Function
	
	Function ReturnAskConfig(sTokenName)
	    select case lcase(sTokenName)
		   case "sitetitle" ReturnAskConfig=KS.ASetting(2)
		   case "menulist"  ReturnAskConfig=IndexMenulist
		   case "resolvednum" ReturnAskConfig=conn.execute("select count(topicid) from KS_asktopic where topicmode=1")(0)
		   case "unresolvednum" ReturnAskConfig=conn.execute("select count(topicid) from KS_asktopic where topicmode=0")(0)
		   case "totalnum" ReturnAskConfig=conn.execute("select count(topicid) from KS_asktopic where topicmode=1")(0)+conn.execute("select count(topicid) from KS_asktopic where topicmode=0")(0)
		end select
	End Function
				
End Class
%>