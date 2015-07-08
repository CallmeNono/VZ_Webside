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
Set KSCls = New User_Favorite
KSCls.Kesion()
Set KSCls = Nothing

Class User_Favorite
        Private KS,KSUser
		Private CurrentPage,totalPut
		Private RS,MaxPerPage
		Private ChannelID
		Private TempStr,SqlStr
		Private InfoIDArr,InfoID
		Private Sub Class_Initialize()
			MaxPerPage =10
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/UserFunction.asp"-->
		<%
       Public Sub loadMain()
		  Call KSUser.Head()
		  Call KSUser.InnerLocation("我的收藏夹")
	  	  KSUser.CheckPowerAndDie("s16")
		
		%>
		
		  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
            <tr>
              <td valign="top">
				<%
				Select Case KS.S("Action")
				 Case "Add"
				   Dim RSAdd
				   InfoID=KS.ChkClng(KS.S("InfoID"))
				   ChannelID=KS.ChkClng(KS.S("ChannelID"))
				   If InfoID=0 Or Channelid=0 Then
				     Response.Write "<script>alert('您没有选择要收藏的信息！');history.back();</script>"
					 Response.End()
				   End If

				   Set RSAdd=Server.CreateObject("Adodb.Recordset")
				   RSADD.Open "Select top 1 * From KS_Favorite Where ChannelID=" & ChannelID & " And InfoID=" & InfoID & " And UserName='" & KSUser.UserName & "'",Conn,1,3
				   IF RSADD.Eof And RSADD.Bof Then
				      RSADD.AddNew
					    RSAdd(1)=KSUser.UserName
						RSAdd(2)=ChannelID
						RSAdd(3)=InfoID
						RSAdd(4)=Now
					  RSAdd.Update
				   End IF
				   RSADD.Close:SET RSADD=Nothing
				 Case "Cancel"
				  InfoID=KS.S("InfoID")
				  InfoID=Replace(InfoID," ","")
				  InfoID=KS.FilterIDs(InfoID)
				  If InfoID="" Then
				   Response.Write "<script>alert('您没有选择要取消收藏的信息！');history.back();</script>"
				   Response.End
				  End If
				  Conn.Execute("Delete From KS_Favorite Where ID In(" & InfoID & ") And UserName='" & KSUser.UserName & "'")
				End Select
			 
			   		       If KS.S("page") <> "" Then
						          CurrentPage = CInt(KS.S("page"))
							Else
								  CurrentPage = 1
							End If
                                    
									Dim Param:Param=" Where UserName='"& KSUser.UserName &"'"
                                    
									If ChannelID="" or not isnumeric(ChannelID) Then ChannelID=0
                                    IF ChannelID<>0 Then  Param= Param & " and ChannelID=" & ChannelID
								   %>
			<div class="tabs">						  
			<ul>
				<li class='puton'><a href="User_Favorite.asp">我收藏的信息(<%=Conn.Execute("Select count(id) from KS_Favorite" & Param & " and channelid<>6")(0)%>)</a></li>
				<%If KS.C_S(6,21)="1" Then%>
				<li><a href="User_MusicBox.asp">我收藏的音乐(<span class="red"><%=Conn.Execute("Select count(id) from KS_Favorite" & Param & " and channelid=6")(0)%></span>)</a></li>
				<%end if%>
			</ul>					   
			 </div>					    
				<table width="100%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">

					<%
						Set RS=Server.CreateObject("AdodB.Recordset")
						 SqlStr="Select ID,ChannelID,InfoID,AddDate From KS_Favorite "& Param &" and  Channelid<>6 order by id desc"
						 RS.open SqlStr,conn,1,1

						 If RS.EOF And RS.BOF Then
								  Response.Write "<tr class='tdbg'><td height=25 align=center colspan=5 valign=top>您的收藏夹没有内容!</td></tr>"
								 Else
									totalPut = RS.RecordCount
									If CurrentPage < 1 Then	CurrentPage = 1
			
								If CurrentPage >1 and  (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
								Else
										CurrentPage = 1
										
								End If
								Call ShowContent
				End If

					 %>
					
          </table>
		  </td>
		  </tr>
</table>
		
		  <%
  End Sub
    
  Sub ShowContent()
     Dim I,SQL,K
    Response.Write "<FORM Action=""User_Favorite.asp?Action=Cancel&ChannelID=" & ChannelID& "&Page=" & CurrentPage & """ name=""myform"" method=""post"">"
	SQL=RS.GetRows(-1)
	For K=0 To Ubound(SQL,2)
		%>
                <tr>
                     <td  class="splittd">
						<%
						Select Case KS.C_S(SQL(1,K),6)
						   Case 1 SqlStr="Select top 1 ID,Title,Tid,ReadPoint,InfoPurview,Fname,Changes,AddDate,hits From " & KS.C_S(SQL(1,K),2) &" Where ID=" & SQL(2,K)
						   Case 2 SqlStr="Select top 1 ID,Title,Tid,ReadPoint,InfoPurview,Fname,0,AddDate,hits From " & KS.C_S(SQL(1,K),2) &" Where ID=" & SQL(2,K)
						   Case 3 SqlStr="Select top 1 ID,Title,Tid,ReadPoint,InfoPurview,Fname,0,AddDate,hits From " & KS.C_S(SQL(1,K),2) &" Where ID=" & SQL(2,K)
						   Case 4 SqlStr="Select top 1 ID,Title,Tid,ReadPoint,InfoPurview,Fname,0,AddDate,hits From " & KS.C_S(SQL(1,K),2) &" Where ID=" & SQL(2,K)
						   Case 5 SqlStr="Select top 1 ID,Title,Tid,0,0,Fname,0,AddDate,hits From KS_Product Where ID=" & SQL(2,K)
						   Case 7 SqlStr="Select top 1 ID,Title,Tid,0,0,Fname,0,AddDate,hits From KS_Movie Where ID=" & SQL(2,K)
						   Case 8 SqlStr="Select top 1 ID,Title,Tid,0,0,Fname,0,AddDate,hits From KS_GQ Where ID=" & SQL(2,K)
                           Case 9 SqlStr="Select top 1 ID,Title,0,0,0,0,0,date,hits From KS_SJ Where ID=" & SQL(2,K)
						   Case else SqlStr="Select top 1 ID From KS_Article Where 1=0"
						  End Select
						  
						  Dim Url,RSF:Set RSF=Conn.Execute(SqlStr)
						  If Not RSF.Eof Then
						   If SQL(1,K)=9 then
						    url="../html/sj/" & RSF(0) & ".htm"
						   else
						    url=KS.GetItemUrl(SQL(1,K),RSF(2),RSF(0),RSF(5))
						   end if
						   Response.Write "<div class=""ContentTitle""><input id=""InfoID"" type=""checkbox"" value=""" & SQL(0,K) & """  name=""InfoID""> <img src=""images/fav.gif""><a href=""" & url & """ target=""_blank"">" & RSF(1) & " </a></div>"
						   Response.Write "<div class=""Contenttips"">"
						   Response.Write "<span>类型：" & KS.C_S(SQL(1,K),3) & " 收藏时间:" & KS.GetTimeFormat(SQL(3,K)) & " 信息最后更新：" & KS.GetTimeFormat(RSF(7)) & " 人气：" & RSF(8)
						  End If
											
											
											%>
                                            </span> 
											</div> 
											</td>
											
                                            <td class="splittd" align="center">
											<a class="box" href="User_Favorite.asp?Action=Cancel&Page=<%=CurrentPage%>&InfoID=<%=SQL(0,K)%>" onclick = "return (confirm('确定取消该<%=KS.C_S(SQL(1,K),3)%>的收藏吗?'))">取消收藏</a>
											</td>
                                          </tr>

                                      <%
	  Next
			
%>
								<tr>
								  <td height="30" valign=top colspan="3"><INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中本页显示的所有收藏<INPUT  class="button" onClick="return(confirm('确定取消选定的收藏吗?'));" type=submit value="取消选定的收藏" name=submit1>
								  </td>
								  </FORM>
								</tr>
                                <tr>
                                  <td height="30" align='right' colspan=3>
										<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>
                                       
							      </td>
                                </tr>
			<%
  End Sub

End Class
%> 
