<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<% Option Explicit %>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.EscapeCls.asp"-->
<!--#include file="../KS_Cls/UploadFunction.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<%
Server.ScriptTimeout=9999999
Response.CharSet="utf-8"
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New UpFileSave
KSCls.Kesion()
Set KSCls = Nothing

Class UpFileSave
        Private KS,KSUser,FileTitles,Title
		Dim FilePath,MaxFileSize,AllowFileExtStr,BasicType,ChannelID,UpType,BoardID,EditorID
		Dim FormName,Path,TempFileStr,FormPath,ThumbFileName,ThumbPathFileName,LoginTF
		Dim UpFileObj,CurrNum,CreateThumbsFlag,FieldName,U_FileSize,FormID,FieldID,MustCheckSpaceSize,AllowNoUserUpload
		Dim DefaultThumb    '设定第几张为缩略图
		Dim ReturnValue
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		
		Function CheckIsLogin(UserName,Pass)
		     If UserName="" Or Pass="" Then Check=false: Exit Function
		     Dim ChkRS:Set ChkRS =Conn.Execute("Select top 1 * From KS_User Where UserName='" & KS.R(UserName) & "'")
			 If ChkRS.EOF And ChkRS.BOF Then
			   CheckIsLogin=false
			 Else
			   If ChkRS("RndPassWord")=Pass Then 
			     CheckIsLogin=true 
				 Response.Cookies(KS.SiteSn)("UserID")=ChkRS("UserID")
				 Response.Cookies(KS.SiteSn)("UserName")=ChkRS("UserName")
				 Response.Cookies(KS.SiteSn)("PassWord")=ChkRS("PassWord")
				 Response.Cookies(KS.SiteSn)("RndPassWord")=ChkRS("RndPassWord")
			   Else 
			    CheckIsLogin=false
			   End If
			 End If
		     ChkRS.Close:Set ChkRS = Nothing
		End Function
		
		Sub Kesion()

		Set UpFileObj = New UpFileClass
		on error resume next
		UpFileObj.GetData
		If ERR.Number<>0 Then Set UpFileObj=Nothing : err.clear:KS.Die "error:" & escape("上传失败，可能您的上传的文件太大!")
		EditorID =UpFileObj.Form("EditorID")
		BasicType=KS.ChkClng(UpFileObj.Form("BasicType")) 
		ChannelID=KS.ChkClng(UpFileObj.Form("ChannelID")) 

		UpType=UpFileObj.Form("UpType")
		CurrNum=0
		CreateThumbsFlag=false
		DefaultThumb=UpFileObj.Form("DefaultUrl")
		if DefaultThumb="" then DefaultThumb=0
		LoginTF=Cbool(KSUser.UserLoginChecked)
		If LoginTF=false Then
		  If cbool(CheckIsLogin(UpFileObj.Form("UserName"),UpFileObj.Form("RndPassWord"))) =true Then  '兼容Firefox
			 LoginTF=Cbool(KSUser.UserLoginChecked)
		  End If
		End If

		FormID=KS.ChkClng(UpFileObj.Form("FormID")) 
		FieldID=KS.ChkClng(UpFileObj.Form("FieldID")) 
		BoardID=KS.ChkClng(UpFileObj.Form("BoardID"))
		
		dim CurrentDir:CurrentDir=UpFileObj.Form("CurrentDir")
        CurrentDir=Trim(Replace(CurrentDir,"../",""))
		CurrentDir=KS.CheckXSS(CurrentDir)
		
	    MustCheckSpaceSize=true : AllowNoUserUpload=0
		Dim RS,FieldName
		If UpType="Pic" And ChannelID<>9994 and channelid<>9993 Then
			If DefaultThumb=1 Then CreateThumbsFlag=true Else CreateThumbsFlag=false
			If ChannelID=9996  Then '圈子图片　
				MaxFileSize = 100    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的动漫类型
				FormPath =KS.ReturnChannelUserUpFilesDir(9996,KSUser.GetUserInfo("UserID"))
            ElseIf ChannelID=9998  Then '相册封面
				MaxFileSize = 100    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的动漫类型
				FormPath =KS.ReturnChannelUserUpFilesDir(9998,KSUser.GetUserInfo("UserID"))
			ElseIf ChannelID=9999  Then   '用户头像
			    session("urel")=""
				MaxFileSize = 150    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的图片
				FormPath = KS.ReturnChannelUserUpFilesDir(9999,KSUser.GetUserInfo("UserID"))
			ElseIf ChannelID=8000  Then  '模板DIY图片
				MaxFileSize = 500    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的图片
				FormPath = KS.ReturnChannelUserUpFilesDir(8000,KSUser.GetUserInfo("UserID"))
			Else
				MaxFileSize = KS.ReturnChannelAllowUpFilesSize(ChannelID)   '设定文件上传最大字节数
				AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,1)
                If KS.C("UserName")="" And KS.C("PassWord")="" Then
					 If KS.C_S(ChannelID,26)=2 Then
					  AllowNoUserUpload=1: MustCheckSpaceSize=false
					  FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"  
					 End If
				Else
					AllowNoUserUpload=0
				    FormPath = KS.ReturnChannelUserUpFilesDir(ChannelID,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
				End If				
			End If
		Elseif UpType="File" Then   '上传附件
			MaxFileSize = KS.ReturnChannelAllowUpFilesSize(ChannelID)   '设定文件上传最大字节数
			AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,0)
			If KS.C("UserName")="" And KS.C("PassWord")="" And KS.ChkClng(KS.C_S(ChannelID,6))>0 Then
				If KS.ChkClng(KS.C_S(ChannelID,26))=2 Then
					  AllowNoUserUpload=1: MustCheckSpaceSize=false
					  FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"  
				End If
			Else
			  AllowNoUserUpload=0
			  FormPath = KS.ReturnChannelUserUpFilesDir(ChannelID,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
			End If
		ElseIf (ChannelID=101 Or FormID<>0) and FieldID<>0 Then  '自定义表单或注册表单自定义字段
		    If ChannelID<>101 Then
			 Set RS=Conn.Execute("select top 1 AnonymousUpload From KS_Form Where ID=" & FormID)
			 If RS.Eof And RS.Bof Then
			   RS.Close:Set RS=Nothing
			   KS.Die "error:" & escape("出错啦!")
			 End If
			 AllowNoUserUpload=rs(0)
			 RS.Close
			 Set RS=Conn.Execute("Select top 1 FieldName,AllowFileExt,MaxFileSize From KS_FormField Where FieldID=" & FieldID)
           Else
		      If KS.Setting(60)="1" Then AllowNoUserUpload=1 Else AllowNoUserUpload=0
			 Set RS=Conn.Execute("Select top 1 FieldName,AllowFileExt,MaxFileSize From KS_Field Where ChannelID=101 and FieldID=" & FieldID)
		   End If
			 If Not RS.Eof Then
				MaxFileSize=RS(2):AllowFileExtStr=RS(1)
				RS.Close
				If ChannelID=101 Then
				    If KS.C("UserName")<>"" Then
				 	FormPath =KS.Setting(3) & KS.Setting(91)& "user/" & KSUser.GetUserInfo("userid") & "/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"        
					Else
				 	FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"        
					End If
				Else
					Set RS=Conn.Execute("Select top 1 UploadDir From KS_Form Where ID=" &FormID)
					If Not RS.Eof Then 
					 FormPath =KS.Setting(3) & KS.Setting(91)&RS(0) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"        
					Else
					 FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"        
					End If
					End If
				If AllowNoUserUpload=1 Then MustCheckSpaceSize=false
			 Else
				KS.Die "error:" & escape("参数有误!")
			 End IF
			 RS.Close:Set RS=Nothing
       ElseIf ChannelID<>0 And BasicType<>0 and FieldID<>0 Then '模型自定义字段
	        Set RS=Conn.Execute("Select top 1 FieldName,AllowFileExt,MaxFileSize From KS_Field Where FieldID=" & FieldID)
		   If Not RS.Eof Then
		    FieldName=RS(0):MaxFileSize=RS(2):AllowFileExtStr=RS(1)
			FormPath = KS.ReturnChannelUserUpFilesDir(ChannelID,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
		   Else
		    KS.Die "error:" & escape("参数有误!")
		   End IF
		   RS.Close:Set RS=Nothing
	   Else
			Select Case BasicType
			  Case 1,3,4,7,9    '下载,影片等
					MaxFileSize = KS.ReturnChannelAllowUpFilesSize(ChannelID)   '设定文件上传最大字节数
					If BasicType=4 Then
					 AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,2)
					ElseIf BasicType=7 Then  '影片
				     AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,2) &"|" & KS.ReturnChannelAllowUpFilesType(ChannelID,3) & "|"& KS.ReturnChannelAllowUpFilesType(ChannelID,4)  
					Else
					 AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,0)
					End If
					If KS.C("UserName")="" And KS.C("PassWord")="" Then
					 If KS.C_S(ChannelID,26)=2 Then
					  AllowNoUserUpload=1: MustCheckSpaceSize=false
					  FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"  
					 End If
					Else
					 AllowNoUserUpload=0
			         FormPath = KS.ReturnChannelUserUpFilesDir(ChannelID,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
					End If
			  Case 2     '图片中心
					CreateThumbsFlag=true
					MaxFileSize = KS.ReturnChannelAllowUpFilesSize(ChannelID)   '设定文件上传最大字节数
					AllowFileExtStr = KS.ReturnChannelAllowUpFilesType(ChannelID,1)
					If KS.C("UserName")="" And KS.C("PassWord")="" Then
					 If KS.C_S(ChannelID,26)=2 Then
					  AllowNoUserUpload=1: MustCheckSpaceSize=false
					  FormPath =KS.Setting(3) & KS.Setting(91)&"Temp/" & Year(Now()) & Right("0" & Month(Now()), 2) & "/"  
					 End If
					Else
					  AllowNoUserUpload=0
					  FormPath = KS.ReturnChannelUserUpFilesDir(ChannelID,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
					End If
					
					
			Case 9995  '音乐
				MaxFileSize = 50000    '设定文件上传最大字节数
				AllowFileExtStr = "mp3"  '取允许上传的动漫类型
				FormPath =KS.ReturnChannelUserUpFilesDir(9995,KSUser.GetUserInfo("UserID"))
			 Case 9997  '相片
				MaxFileSize = KS.ChkClng(KS.SSetting(32))    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的动漫类型
				FormPath = KS.ReturnChannelUserUpFilesDir(9997,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
			Case 9992 '问答附件	
			 	 If KS.ASetting(42)<>"1" Then
				   KS.Die "error:" & escape("对不起，此频道不允许上传附件!")
				ElseIf LoginTF=false or (not KS.IsNul(KS.ASetting(46)) and KS.FoundInArr(KS.ASetting(46),KSUser.GroupID,",")=false) Then
				 KS.Die "error:" & escape("对不起,您没有在此频道上传的权限!")
                 End If

				MaxFileSize =KS.ChkClng(KS.ASetting(44))    '设定文件上传最大字节数
				AllowFileExtStr = KS.ASetting(43)  '取允许上传的类型
				FormPath = KS.ReturnChannelUserUpFilesDir(9997,KSUser.GetUserInfo("UserID")) & Year(Now()) & Right("0" & Month(Now()), 2) & "/"
			 Case 9994  '论坛
			    If BoardID=0 Then
				  KS.Die "error:" & escape("非法参数!")
				End If
				KS.LoadClubBoard
				Dim BNode,BSetting
				Set BNode=Application(KS.SiteSN&"_ClubBoard").DocumentElement.SelectSingleNode("row[@id=" & BoardID &"]") 
				If BNode Is Nothing Then KS.Die "error:" & escape("非法参数!")
				BSetting=BNode.SelectSingleNode("@settings").text
				BSetting=BSetting & "$$$0$0$0$0$0$0$0$0$$$$$$$$$$$$$$$$"
				BSetting=Split(BSetting,"$")
				If KS.ChkClng(BSetting(36))<>1 Then
				  KS.Die "error:" & escape("对不起，系统不允许此频道上传文件,请与网站管理员联系!")
				End If
				If  LoginTF=true  and (KS.IsNul(BSetting(17)) Or KS.FoundInArr(BSetting(17),KSUser.GroupID,",")) Then
				    If KS.ChkClng(BSetting(39))<>0 Then
					 If Conn.Execute("select count(1) From KS_UploadFiles Where ClassID=" & BoardID & " and datediff(" & DataPart_D & ",AddDate," & SQLNowString & ")<1 and username='" & KSUser.UserName &"'")(0)>=KS.ChkClng(BSetting(39)) Then
					  KS.Die "error:" & escape("对不起，本版面每天每人限制只能上传" & KS.ChkClng(BSetting(39))&"个文件!")
					 End If
					End If
					MaxFileSize = KS.ChkClng(BSetting(38))    '设定文件上传最大字节数
					AllowFileExtStr = BSetting(37)  '取允许上传的类型
					FormPath =KS.ReturnChannelUserUpFilesDir(9994,KS.Setting(67))
				Else
				  KS.Die "error:" & escape("对不起，您没有在本论坛上传附件的权限!")
				End If
			Case 9993  '写日志附件
			    If KS.ChkClng(KS.SSetting(26))=0 Then
				  KS.Die "error:" & escape("对不起，系统不允许此频道上传文件,请与网站管理员联系!")
			   ElseIf LoginTF=false or (not KS.IsNul(KS.SSetting(30)) and KS.FoundInArr(KS.SSetting(30),KSUser.GroupID,",")=false) Then 
			    KS.Die "error:" & escape("对不起,您没有在此频道上传的权限!")
			   End If
				MaxFileSize = KS.ChkClng(KS.SSetting(28))    '设定文件上传最大字节数
				AllowFileExtStr = KS.SSetting(27)  '取允许上传的类型
				FormPath =KS.ReturnChannelUserUpFilesDir(9993,KSUser.GetUserInfo("UserID"))
			Case 9991  '微博
			    If KS.ChkClng(KS.SSetting(50))=0 Then
				  KS.Die "error:" & escape("对不起，系统不允许此频道上传文件,请与网站管理员联系!")
			   ElseIf LoginTF=false or (not KS.IsNul(KS.SSetting(53)) and KS.FoundInArr(KS.SSetting(53),KSUser.GroupID,",")=false) Then 
			    KS.Die "error:" & escape("对不起,您没有在此频道上传的权限!")
			   End If
				MaxFileSize = KS.ChkClng(KS.SSetting(51))    '设定文件上传最大字节数
				AllowFileExtStr = "jpg|gif|png"  '取允许上传的类型
				FormPath =KS.ReturnChannelUserUpFilesDir(9994,KS.SSetting(54))
			Case 99999
				MaxFileSize = 1024    '设定文件上传最大字节数
				AllowFileExtStr = "gif|jpg|png|swf|flv|mp3|doc"  '取允许上传的类型
				if CurrentDir<>"" then 
				FormPath =KS.ReturnChannelUserUpFilesDir(99999,KSUser.GetUserInfo("UserID") &"/" & CurrentDir)
				else
				FormPath =KS.ReturnChannelUserUpFilesDir(99999,KSUser.GetUserInfo("UserID"))
				end if
				Formpath=replace(FormPath,"//","/")
			End Select
		End If
		If AllowNoUserUpload="0" And LoginTF=false Then 
		   KS.Die "error:" & escape("对不起，只有登录后才可以使用上传!")
		End If

		FormPath=Replace(FormPath,".","")
		IF Instr(FormPath,KS.Setting(3))=0 Then FormPath=KS.Setting(3) & FormPath
		FilePath=Server.MapPath(FormPath) & "\"
		Call KS.CreateListFolder(FormPath)       '生成上传文件存放目录
		
        If KS.ChkClng(KS.Setting(97))=1 Then FormPath=KS.Setting(2) & FormPath
		ReturnValue = CheckUpFile(KSUser,MustCheckSpaceSize,UpFileObj,FormPath,FilePath,MaxFileSize,AllowFileExtStr,U_FileSize,TempFileStr,FileTitles,CurrNum,CreateThumbsFlag,DefaultThumb,ThumbPathFileName)
		If Not KS.IsNul(UpFileObj.Form("fileNames")) Then FileTitles=unescape(UpFileObj.Form("fileNames")) '防止中文乱码
		If UpFileObj.Form("NoReName")="1" Then  '不更名
		        Dim PhysicalPath,FsoObj:Set FsoObj = KS.InitialObject(KS.Setting(99))
		        PhysicalPath = Server.MapPath(replace(TempFileStr,"|",""))
				TempFileStr= mid(TempFileStr,1, InStrRev(TempFileStr, "/")) &  FileTitles
				If FsoObj.FileExists(PhysicalPath)=true Then
				 FsoObj.MoveFile PhysicalPath,server.MapPath(TempFileStr)
			    End If
		End If
		
		if ReturnValue <> "" then
		     ReturnValue=replace(ReturnValue,"\n","。")
		     If Instr(ReturnValue,"上传失败")<>0 Then
		     KS.Die "error:" & escape("上传失败" & Replace(Split(ReturnValue,"上传失败")(1),"'","\'"))
			 Else
		     KS.Die "error:" & escape(Replace(ReturnValue,"'","\'"))
			 End If
		else 
			 TempFileStr=replace(TempFileStr,"'","\'")
			 If UpType="Field" Then
			 	KS.Die replace(TempFileStr,"|","")
			 Elseif UpType="File" Or UpType="BBSFile" Then   '上传附件
				  Call AddAnnexToDB(ChannelID,KS.C("UserName"),TempFileStr,FileTitles,KS.ChkClng(BoardID),false,EditorID)
			 ElseIf UpType="Pic" Then
			     
				   if basictype=9999 then
			 		Call KSUser.AddToWeibo(KSUser.UserName,"更换了自己的形象照片，[url={$GetSiteUrl}user/weibo.asp?userid=" & KSUser.GetUserInfo("userid") &"]TA的微博[/url] [url={$GetSiteUrl}space/?" & KSUser.GetUserInfo("userid") &"]TA的空间[/url][br][url=" & replace(TempFileStr,"|","") & "][img]" & replace(TempFileStr,"|","") & "[/img][/url]",6)
				  end if
			    
			      If BasicType=1 Or BasicType=5 Or BasicType=3  Or BasicType=8 Then
				   if ThumbPathFileName="" then ThumbPathFileName=replace(TempFileStr,"|","")
			       KS.Die ThumbPathFileName  &"@"& replace(TempFileStr,"|","") 
				  Else
				   if DefaultThumb=1 then
				     KS.Echo ThumbPathFileName
 					 if replace(ThumbPathFileName,"|","")<>replace(TempFileStr,"|","") then
				      Call KS.DeleteFile(replace(TempFileStr,"|",""))  '删除原图片
					 end if
				   Else
				     KS.Echo escape(replace(TempFileStr,"|",""))
				   End If
                   KS.Die ""
				  End If
			 Else
				 Select Case BasicType
				      Case 3 KS.Die escape(replace(TempFileStr,"|","")) & "|" & U_FileSize
					  Case 2         '图片
						   KS.Die replace(TempFileStr,"|","") &  "@" & ThumbPathFileName & "@" & escape(FileTitles)
					  Case 9997    '相片
						   KS.Die replace(TempFileStr,"|","") &  "@" & replace(TempFileStr,"|","") & "@" & escape(FileTitles)
					  Case Else KS.Die escape(replace(TempFileStr,"|",""))
				 End Select
			 End If
		  End iF
		Set UpFileObj=Nothing
 End Sub
End Class

%> 
