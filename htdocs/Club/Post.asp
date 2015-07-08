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
Set KSCls = New GuestPost
KSCls.Kesion()
Set KSCls = Nothing

Class GuestPost
        Private KS, KSR,KSUser,Templates,Node,BSetting,BoardID,Master
		Private GuestNum,GuestCheckTF,LoginTF,CategoryNode,ShowSign,ShowIP
		Private Sub Class_Initialize()
		 If (Not Response.IsClientConnected)Then
			Response.Clear
			Response.End
		 End If
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		 Set KSR=Nothing
		End Sub

%>
<!--#include file="../KS_Cls/Kesion.IfCls.asp"-->
<!--#include file="../KS_Cls/ClubFunction.asp"-->
<%
	Public Sub Kesion()
			If KS.Setting(56)="0" Then response.write "本站已关闭论坛功能":response.end
			if KS.IsNul(request.ServerVariables("HTTP_REFERER")) Then KS.Die "<script>alert('非法访问发帖页面!');location.href='/';</script>"
			 GuestCheckTF=KS.Setting(52)
			 GuestNum=KS.Setting(54)
		     Dim FileContent,WriteForm,PostType
		          If KS.Setting(114)="" Then Response.Write "请先到""基本信息设置->模板绑定""进行模板绑定操作!":response.end
				   FileContent = KSR.LoadTemplate(KS.Setting(115))
				   If Trim(FileContent) = "" Then FileContent = "模板不存在!"
				   GetClubPopLogin FileContent
				   FCls.RefreshType = "guestwrite" '设置刷新类型，以便取得当前位置导航等
				   FCls.RefreshFolderID = "0" '设置当前刷新目录ID 为"0" 以取得通用标签
				   ShowSign=1:ShowIP=1
				   LoginTF=KSUser.UserLoginChecked
				   BoardID=KS.ChkClng(Request("bid"))
				   PostType=KS.ChkClng(KS.S("PostType"))
				  
				   WriteForm=LFCls.GetConfigFromXML("clubpost","/posttemplate/label","post")
				   WriteForm=Replace(WriteForm,"{$GuestNum}",GuestNum)
				   WriteForm=Replace(WriteForm,"{$BoardID}",BoardID)

				   
				   Session("Rnd")=KS.MakeRandom(20)
				   if mid(KS.Setting(161),3,1)="1" Then
				     Dim Qid:Qid=GetQuestionRnd
					 Dim QuestionArr:QuestionArr=Split(KS.GetCurrQuestion(162),vbcrlf)
					 WriteForm=Replace(WriteForm,"{$Question}",QuestionArr(Qid))
					 Session("Qid")=Qid
				   end If
				   KS.LoadClubBoard
				  If BoardID=0 Then Call KS.ShowTips("error", "对不起，您没有选择版面！") : KS.Die ""
				  
				  If BoardID<>0 Then
				      Set Node=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & BoardID &"]") 
					  If Node Is Nothing Then KS.Die "非法参数!"
					  BSetting=Node.SelectSingleNode("@settings").text
					  Master=Node.SelectSingleNode("@master").text
					  If Node.SelectSingleNode("@parentid").text="0" Then
					    KS.Die "<script>alert('不能在一级栏目下发帖!');history.back();</script>"
					  End If
				 End If
				   BSetting=Bsetting& "$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$"
				   BSetting=Split(BSetting,"$")
				   WriteForm=Replace(WriteForm,"{$CodeTF}",CodeTF)
				   
				   '=================================同步第三方选项=================================
				   If KS.S("Action")<>"edit" and LoginTF Then
				    Dim CheckJS
				    Dim SynchStr:SynchStr=KSUser.ShowSynchronizedOption(CheckJS)
					If SynchStr<>"" Then SynchStr="<b>将本主题同步到：</b>" & SynchStr
				    WriteForm=Replace(WriteForm,"{$SynchronizedOption}",SynchStr)
				   End If
				   '===================================================================================
				   
				   
				   Dim SubjectStr
				   If BoardID<>0 Then
				       '编辑帖子
				       If KS.S("Action")="edit" Then
					      '检查有没有编辑帖子权限
					      Dim TopicID:TopicID=KS.ChkClng(KS.S("TopicID"))
						  Dim ReplyID:ReplyID=KS.ChkClng(KS.S("id"))
						  Dim IsTopic:IsTopic=KS.ChkClng(KS.S("IsTopic"))
						  Dim PostTable,Subject,CategoryId,Content,PostUserName,ShowScore,BInfoID,ClassID
						  if TopicID=0 Or ReplyID=0 Then
						    KS.Die "<script>alert('参数出错!');history.back();</script>"
						  End If
					      Dim RS:Set RS=Conn.Execute("Select top 1 PostTable,Subject,CategoryId,PostType,ShowScore,ChannelID,InfoID From KS_GuestBook Where ID=" & TopicID)
						  If RS.Eof And RS.Bof Then
						    RS.Close : Set RS=Nothing
						    KS.Die "<script>alert('参数出错!');history.back();</script>"
						  End If
						  PostTable=RS("PostTable"):ChannelID=rs("ChannelID") :BInfoID=rs("InfoID")
						  Subject=RS("Subject") : ShowScore=RS("ShowScore")
						  CategoryId=RS("CategoryId") : PostType=RS("PostType")
						  RS.Close
						  
						  
						  RS.Open "Select top 1 * From " & PostTable  & " Where ID=" & ReplyID,conn,1,1
						  If RS.Eof And RS.Bof Then
						    RS.Close : Set RS=Nothing
						    KS.Die "<script>alert('参数出错!');history.back();</script>"
						  End If
						  Content=RS("Content"): If KS.IsNul(Content) Then Content=" " 
						  Content=Split(Content,"$@$")(0)
						  Content=Replace(Content,"[br]",chr(10))
						  
                          Content=Replace(Replace(Content,"{","｛#"),"}","#｝")  '转换科汛标签
                          Subject=Replace(Replace(Subject,"{","｛#"),"}","#｝")  '转换科汛标签
						  PostUserName=RS("UserName"):ShowSign=RS("ShowSign"):ShowIP=RS("ShowIP")
						  RS.Close :Set RS=Nothing
						  
						  '检查编辑权限
						  If CheckIsMater=false Then
						    If KSUser.UserName<>PostUserName Or KS.ChkClng(BSetting(29))=0 Then
							 FileContent=Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error7",true))
							End If
						  End If
						  
						  SubjectStr="<input type='hidden' name='replyId' value='" & ReplyID &"'/>"
						  SubjectStr=SubjectStr & "<input type='hidden' name='IsTopic' value='" & IsTopic &"'/>"
						  SubjectStr=SubjectStr & "<input type='hidden' name='topicId' value='" & topicID &"'/>"
						  SubjectStr=SubjectStr & "<input type='hidden' name='page' value='" & KS.ChkClng(KS.S("Page")) &"'/>"
						  SubjectStr=SubjectStr & "<input type='hidden' name='action' value='edit'/>"
					   End If
					   
				   '=======================绑定模型=======================================
				   Dim UserDefineFieldArr,I,UserDefineFieldValueStr,ModelStr,ChannelID,ModelClassXml,ModelNode,UnitOption
				   If KS.S("Action")="edit" And KS.S("istopic")="1" And KS.ChkClng(ChannelID)<>0 And KS.ChkClng(BInfoID)<>0 Then '自定义字段
					   Dim RSObj:Set RSObj=Conn.Execute("Select top 1 * From " & KS.C_S(KS.ChkClng(ChannelID),2) & " Where ID=" & BinfoID)
					   If Not RSOBj.Eof Then
				        WriteForm=Replace(WriteForm,"{$HtmlTagSupport}"," checked")
					    content=RSObj("ArticleContent")	:ClassID=RSObj("tid")
						Dim FieldXML,FieldNode,FNode,FieldDictionary
						Call LoadModelField(ChannelID,FieldXML,FieldNode)
						  '自定义字段
						   If FieldXML.readystate=4 and FieldXML.parseError.errorCode=0 Then
							Dim DiyNode:Set DiyNode=FieldXML.DocumentElement.selectnodes("fielditem[fieldtype!=0&&fieldtype!=13]")
							If diynode.length>0 Then
								Set FieldDictionary=KS.InitialObject("Scripting.Dictionary")
								For Each FNode In DiyNode
								   FieldDictionary.add lcase(FNode.SelectSingleNode("@fieldname").text),RSObj(FNode.SelectSingleNode("@fieldname").text)
								   If FNode.SelectSingleNode("showunit").text="1" Then
								   FieldDictionary.add lcase(FNode.SelectSingleNode("@fieldname").text) &"_unit",RSObj(FNode.SelectSingleNode("@fieldname").text&"_Unit")
								   End If
								Next
							End If
						  End If
						
					  End If
					 End If
				   If KS.S("Action")<>"edit" Then ChannelID=KS.ChkClng(Bsetting(60))
				   If ChannelID<>0 Then
				        KS.LoadClassConfig()
						Set ModelClassXml=Application(KS.SiteSN&"_class").DocumentElement.SelectNodes("class[@ks14=1 and @ks12=" & channelid&"]")
						
				     ModelStr="<table class=""postmodeltable"" style=""margin:0 2px 5px 0px;border:1px dashed #ccc"" bgcolor=""#F6FAFC"" width=""99%"" cellspacing=""0"" cellpadding=""0"" border=""0"">"
					 If ModelClassXml.length>1 Then
						 ModelStr=ModelStr& "<tr  class=""tdbg"" height=""25""><td class=""clefttitle"" align=""center"">所属分类：</td> <td><script src=""../user/showclass.asp?channelid="& KS.ChkClng(ChannelID) & "&classid=" & ClassID & """></script> </td></tr>"
					 Else
						For Each ModelNode In ModelClassXml
		                    If (ModelNode.SelectSingleNode("@ks18").text=0) OR ((KS.FoundInArr(ModelNode.SelectSingleNode("@ks17").text,KSUser.GroupID,",")=false and ModelNode.SelectSingleNode("@ks18").text=3) ) Then
							  KS.Die ("<script>alert('对不起,您没有本版面发表的权限!');history.back();</script>")  
							Else				   
							  ModelStr=ModelStr& "<input type='hidden' value='" & ModelNode.SelectSingleNode("@ks0").text & "' name='ClassID' id='ClassID'>"
							End If
						  Next
					 End If
					
					 If IsObject(FieldNode) Then
						For Each FNode In FieldNode
								If KS.ChkClng(FNode.SelectSingleNode("fieldtype").text)<>0 Then
									ModelStr=ModelStr & KSUser.GetDiyField(ChannelID,FieldXML,FNode,FieldDictionary)
								End If
						Next
					 End If
					 
					 ModelStr=ModelStr & "</table>"
				     WriteForm=Replace(WriteForm,"{$ShowModelField}",ModelStr)
				   End If 
				   '==================================================================================================
				   
				       If BSetting(59)="1" Then
					   	WriteForm=Replace(WriteForm,"{$Content}",server.HTMLEncode(content))
					   Else
					   	WriteForm=Replace(WriteForm,"{$Content}",content)
					   End If
						WriteForm=Replace(WriteForm,"{$ShowSaleField}",ShowSaleField(ShowScore))

					  
					    If IsTopic=0 And KS.S("Action")="edit" Then
					     SubjectStr=SubjectStr & "<input name=""Subject"" ID=""Subject"" type=""hidden"" maxlength=""150"" value=""" & Subject & """>&nbsp;<strong>编辑<span style='color:red'>“"  &Subject & "” </span>的回复</strong>"	
						Else
												  
                          If BSetting(23)<>"0" Then
						   Dim CategoryStr
						   KS.LoadClubBoardCategory
						   For Each CategoryNode In Application(KS.SiteSN&"_ClubBoardCategory").DocumentElement.SelectNodes("row[@boardid=" &BoardID &"]")
							if trim(CategoryId)=trim(CategoryNode.SelectSingleNode("@categoryid").text) Then
							CategoryStr=CategoryStr & "<option value='" &CategoryNode.SelectSingleNode("@categoryid").text  & "' selected>" & CategoryNode.SelectSingleNode("@categoryname").text &"</option>"
							Else
							CategoryStr=CategoryStr & "<option value='" &CategoryNode.SelectSingleNode("@categoryid").text  & "'>" & CategoryNode.SelectSingleNode("@categoryname").text &"</option>"
							End If
						   Next
						   If Not KS.IsNul(CategoryStr) Then
							  CategoryStr="<input type='hidden' id='SelectCategoryId' value='" &BSetting(24) & "'/><div id='box_CategoryId'><select name=""CategoryId"" id=""CategoryId""><option value='0'>主题分类</option>"  & CategoryStr &"</select></div>"
						   End If
                         End If
						
					     SubjectStr=SubjectStr & "<input class=""textbox"" type=""text"" name=""Subject"" ID=""Subject"" size=""62"" maxlength=""150"" value=""" & Subject & """> <span style=""color:#FF0000"">*</span>"	
						 
						 If KSUser.GetUserInfo("ClubSpecialPower")="0"  Then
						  SubjectStr=SubjectStr & " <span style='color:#999'>你当前级别不支持标题使用HTML语法</span>"
						 Else
						  SubjectStr=SubjectStr & " <span style='color:#999'>支持标题使用HTML语法</span>"
						 End If
					     SubjectStr=CategoryStr  & " " & SubjectStr
						End If
				   End If		
				        	Dim AllowTotalVoteNum:AllowTotalVoteNum=KS.ChkClng(BSetting(64))

					  	  If PostType=1 Then
						     If AllowTotalVoteNum=0 THEN KS.Die "<script>alert('对不起，本版面不允许发布投票帖!');history.back();</script>"
						     SubjectStr=SubjectStr  &LFCls.GetConfigFromXML("clubpost","/posttemplate/label","postvote")
						      Dim VXML,VNode,ItemStr,TypeOption,TimeLimitStr,ShowLimitTime
							 If KS.S("Action")="edit" Then
							   Dim RSV:Set RSV=Conn.Execute("Select top 1 * From KS_Vote Where TopicID=" & TopicID)
							   If Not RSV.Eof Then
							    Set VXML=LFCls.GetXMLFromFile("voteitem/vote_"&rsv("ID"))
								Dim VoteNum:VoteNum=0
								For Each VNode In VXml.DocumentElement.SelectNodes("voteitem")
								 VoteNum=VoteNum+1
								 ItemStr=ItemStr & "<div id=""vote"& VoteNum & """ style=""margin-top:2px""><input type=""hidden"" name=""votenum"" value=""" & VNode.childNodes(1).text &"""/><input type=""text"" name=""voteitem"" onkeyup=""this.value=this.value.replace(/,/g,'，')"" value=""" & VNode.childNodes(0).text & """ size=""43"" class=""textbox"" /></div>"
								Next
								
								SubjectStr=Replace(SubjectStr,"{$CurrVoteNum}",VoteNum)
								SubjectStr=Replace(SubjectStr,"{$MaxAllowVoteNum}",AllowTotalVoteNum)
								If AllowTotalVoteNum<>0 Then
									For I=1 to (AllowTotalVoteNum-VoteNum)
									 ItemStr=ItemStr & "<div id=""vote"& (VoteNum+i) & """ style=""display:none;margin-top:2px""><input type=""text"" name=""voteitem"" onkeyup=""this.value=this.value.replace(/,/g,'，')"" size=""43"" class=""textbox"" /></div>"
									Next
								End If
								
								If RSv("VoteType")="Single" Then
							    TypeOption="<option value=""Single"" selected>单选</option><option value=""Multi"">多选</option>"
								Else
							    TypeOption="<option value=""Single"">单选</option><option value=""Multi""  selected>多选</option>"
							    End If
								If RSV("TimeLimit")="1" Then
								 TimeLimitStr="<label><input type='radio' name='timelimit' onclick=""jQuery('#time').hide();"" value='0'>不启用</label><label><input type='radio' name='timelimit' onclick=""jQuery('#time').show();"" value='1' checked>启用</label>"
								 ShowLimitTime=""
								Else
								 TimeLimitStr="<label><input type='radio' name='timelimit' onclick=""jQuery('#time').hide();"" value='0' checked>不启用</label><label><input type='radio' name='timelimit' onclick=""jQuery('#time').show();"" value='1'>启用</label>"
								 ShowLimitTime=" style='display:none'"
								End If
								If RSv("Nmtp")="1" Then
								 SubjectStr=Replace(SubjectStr,"{$Nmtp}"," checked")
								Else
								 SubjectStr=Replace(SubjectStr,"{$Nmtp}","")
								End If
								SubjectStr=Replace(SubjectStr,"{$ValidDays}",datediff("d",rsv("TimeBegin"),rsv("TimeEnd")))
							   End If
							   RSV.CLose : Set RSV=Nothing
							 Else
							  for i=1 to AllowTotalVoteNum
							    if i<=3 then
							  ItemStr=ItemStr & "<div id=""vote"& i & """ style=""margin-top:2px""><input type=""text"" name=""voteitem"" onkeyup=""this.value=this.value.replace(/,/g,'，')"" size=""43"" class=""textbox"" /></div>"
							    else
							  ItemStr=ItemStr & "<div id=""vote"& i & """ style=""display:none;margin-top:2px""><input type=""text"" name=""voteitem"" onkeyup=""this.value=this.value.replace(/,/g,'，')"" size=""43"" class=""textbox"" /></div>"
								end if
							  next
							  
							  TypeOption="<option value=""Single"">单选</option><option value=""Multi"">多选</option>"
							  TimeLimitStr="<label><input type='radio' name='timelimit' onclick=""jQuery('#time').hide();"" value='0'>不启用</label><label><input type='radio' name='timelimit' onclick=""jQuery('#time').show();"" value='1' checked>启用</label>"
							  ShowLimitTime=""
							  SubjectStr=Replace(SubjectStr,"{$Nmtp}","")
							  SubjectStr=Replace(SubjectStr,"{$CurrVoteNum}",3)
							  SubjectStr=Replace(SubjectStr,"{$MaxAllowVoteNum}",AllowTotalVoteNum)
							  SubjectStr=Replace(SubjectStr,"{$ValidDays}",7)
							 End If
							    SubjectStr=Replace(SubjectStr,"{$VoteTypeOption}",TypeOption)
							    SubjectStr=Replace(SubjectStr,"{$VoteItem}",ItemStr)
							    SubjectStr=Replace(SubjectStr,"{$TimeLimit}",TimeLimitStr)
							    SubjectStr=Replace(SubjectStr,"{$ShowLimitTime}",ShowLimitTime)
							 
						  End If
						If BSetting(59)="1" Then
				   		WriteForm=Replace(WriteForm,"{$HtmlTagSupport}"," checked")
						Else
				   		WriteForm=Replace(WriteForm,"{$HtmlTagSupport}","")
						End If  
						If KS.ChkClng(ShowIP)=1 Then
				   		WriteForm=Replace(WriteForm,"{$ShowIPChecked}"," checked")
						Else
				   		WriteForm=Replace(WriteForm,"{$ShowIPChecked}","")
						End If
						If KS.ChkClng(ShowSign)=1 Then
				   		WriteForm=Replace(WriteForm,"{$ShowSignChecked}"," checked")
						Else
				   		WriteForm=Replace(WriteForm,"{$ShowSignChecked}","")
						End If
				   		WriteForm=Replace(WriteForm,"{$PostSubject}",SubjectStr)
				   		WriteForm=Replace(WriteForm,"{$PostType}",KS.ChkClng(PostType))
                        WriteForm=Replace(WriteForm,"{$ShowSaleField}",ShowSaleField(0))
				   
					   Dim GroupPurview:GroupPurview= True : If Not KS.IsNul(BSetting(2)) and KS.FoundInArr(Replace(BSetting(2)," ",""),KSUser.GroupID,",")=false Then GroupPurview=false
					   Dim LimitPostNum:LimitPostNum=KS.ChkClng(BSetting(13))
				   If KSUser.GroupID<>1 Then  '判断有没有权限
				         Dim CheckResult:CheckResult=CheckPermissions(KSUser,BSetting,"")
						 If CheckResult<>"true" Then
						      FileContent=Replace(FileContent,"{$WriteGuestForm}",CheckResult)
						 ElseIf GroupPurview=false Then  '判断有没有启用用户组
							FileContent=Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error9",true))
					     ElseIf KSUser.GetUserInfo("LockOnClub")="1" Then
							FileContent=Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error6",true))
						 ElseIf  datediff("n",KSUser.GetUserInfo("RegDate"),now)<KS.ChkClng(bsetting(9)) Then
						   FileContent=Replace(Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error5",true)),"{$Minutes}",KS.ChkClng(bsetting(9)))
					     ElseIf LimitPostNum>0 Then
								 Dim PostNum:PostNum=Conn.Execute("Select count(1) From KS_GuestBook Where BoardId=" & BoardID & " and UserName='" & KSUser.UserName &"' And DateDiff(" & DataPart_D & ",AddTime," & SqlNowString & ")<1")(0)
								 If PostNum>=LimitPostNum Then
								   FileContent=Replace(Replace(Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error4",true)),"{$LimitPostNum}",LimitPostNum),"{$PostNum}",PostNum)
								 End If
						End If
				  End If 
				   
				   If (KS.Setting(57)="1" and LoginTF=false) or (BSetting(0)="0" And LoginTF=false) Then
					GCls.ComeUrl=GCls.GetUrl()
 				    FileContent=Replace(FileContent,"{$WriteGuestForm}",GetClubErrTips("error1",true))
                   Else
				    If LoginTF=true Then
					 WriteForm=Replace(WriteForm,"{$UserName}",KSUser.UserName)
					 WriteForm=Replace(WriteForm,"{$User_Enabled}"," readonly ")
					 WriteForm=Replace(WriteForm,"{$UserEmain}",KSUser.GetUserInfo("Email"))
					 WriteForm=Replace(WriteForm,"{$UserHomePage}",KSUser.GetUserInfo("HomePage"))
					 WriteForm=Replace(WriteForm,"{$UserQQ}",KSUser.GetUserInfo("QQ"))
					Else
					 WriteForm=Replace(WriteForm,"{$UserName}","")
					 WriteForm=Replace(WriteForm,"{$User_Enabled}","")
					 WriteForm=Replace(WriteForm,"{$UserEmain}","")
					 WriteForm=Replace(WriteForm,"{$UserHomePage}","http://")
					 WriteForm=Replace(WriteForm,"{$UserQQ}","")
					End If
 				    FileContent=Replace(FileContent,"{$WriteGuestForm}",WriteForm)
 				    FileContent=Replace(FileContent,"{$RndID}",Session("Rnd"))
 				    FileContent=Replace(FileContent,"{$CheckCode}",CheckCode)
				   End If
				   If Request("action")="edit" then
 				    FileContent=Replace(FileContent,"{$GuestTitle}","编辑帖子")
				   else
 				    FileContent=Replace(FileContent,"{$GuestTitle}","发表新主题")
				   end if
				   If KS.ChkClng(BSetting(36))=1 Then
					   If LoginTF=true Then
							If KS.IsNul(BSetting(17)) Or KS.FoundInArr(BSetting(17),KSUser.GroupID,",") Then
							  Dim UpTips:UpTips="允许上传附件类型：" & BSetting(37) & "<br/>附件大小不超过"& BSetting(38) &" KB"
							  If KS.ChkClng(BSetting(39))<>0 Then UpTips=UpTips & "<br/>本版面限制每天每人上传" &BSetting(39) & "个文件"
							  FileContent=Replace(FileContent,"{$ShowUpFilesTips}", Uptips)
							  FileContent=Replace(FileContent,"{$ShowUpFiles}", "<iframe id=""upiframe"" name=""upiframe"" src=""../user/BatchUploadForm.asp?ChannelID=9994&Boardid=" & boardid & """ frameborder=""0"" width=""100%"" height=""20"" scrolling=""no"" src=""about:blank""></iframe>")
							End If
					   End If
				   End If
				   FileContent=KSR.KSLabelReplaceAll(FileContent)
				   FileContent=Replace(Replace(FileContent,"｛#","{"),"#｝","}")  '标签替换回来
				   if instr(FileContent,"{#GetClubPopLogin}")<>0 Then GetClubPopLogin FileContent
				   KS.Echo RexHtml_IF(FileContent)
		End Sub
		
		Function GetQuestionRnd()
		  Dim QuestionArr:QuestionArr=Split(KS.GetCurrQuestion(162),vbcrlf)
		  Dim RandNum,N: N=Ubound(QuestionArr)
          Randomize
          RandNum=Int(Rnd()*N)
          GetQuestionRnd=RandNum
		End Function
		
		Function ShowSaleField(v)
		  IF KS.ChkClng(BSetting(55))=1 Then
		    Select Case KS.ChkClng(BSetting(56))
			  case 0 : ShowSaleField="<strong>主题售价：</strong><input type=""text"" name=""showscore"" value=""" & v & """ size=""3"" style=""text-align:center;border:1px solid #ccc;height:18px;color:#999"">" & KS.Setting(46) &KS.Setting(45) &"<br/>"
			  case 1 : ShowSaleField="<strong>主题售价：</strong><input type=""text"" name=""showscore"" value=""" & v & """ size=""3"" style=""text-align:center;border:1px solid #ccc;height:18px;color:#999"">元人民币<br/>"
			  case 2 : ShowSaleField="<strong>主题售价：</strong><input type=""text"" name=""showscore"" value=""" & v & """ size=""3"" style=""text-align:center;border:1px solid #ccc;height:18px;color:#999"">个积分<br/>"
			End Select
			If KS.ChkClng(BSetting(57))<>0 Then ShowSaleField=ShowSaleField & "(最高限制 " & BSetting(57) &")<br/>"
		  End If
		End Function
		
		Function  CheckCode()
		 IF KS.ChkClng(BSetting(53))=1 Then
  	      CheckCode="if (myform.Verifycode.value==''){alert('请输入附加码！！');myform.Verifycode.focus();return false;}" & vbcrlf
	     End IF
		If mid(KS.Setting(161),3,1)="1" Then
  	      CheckCode=CheckCode &"if (myform.Answer" & Session("Rnd") &".value==''){alert('请输入您的回答！！');myform.Answer" & Session("Rnd") &".focus();return false;}" & vbcrlf
		End If
	   End Function
					  
	   Function CodeTF()
	     IF KS.ChkClng(BSetting(53))<>1 Then CodeTF=" style='display:none'"
	   End Function				  

	   
	   '检查版主或管理员
       function CheckIsMater()
	    If Cbool(LoginTF)=false Then
		  CheckIsMater=false : Exit Function
		Elseif KSUser.GetUserInfo("ClubSpecialPower")=1 Or KSUser.GetUserInfo("ClubSpecialPower")=2 Or KSUser.GroupID=1 Then
		  CheckIsMater=true : Exit function
		else
		  CheckIsMater=KS.FoundInArr(master, KSUser.UserName, ",")
		end if
       End function
	   
End Class
%>
