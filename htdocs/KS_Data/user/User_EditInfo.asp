<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../Plus/md5.asp"-->
<!--#include file="../API/cls_api.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 9.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New User_EditInfo
KSCls.Kesion()
Set KSCls = Nothing

Class User_EditInfo
        Private KS,KSUser
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Session(KS.SiteSN&"UserInfo")=empty
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/UserFunction.asp"-->
		<%
       Public Sub loadMain()
		
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		Call KSUser.Head()
		%>
		<div  class="tabs">						  
			<ul>
				<li <%If KS.S("Action")="" then response.write " class='puton'"%>><a href="User_EditInfo.asp">基本信息</a></li>
				<li <%If KS.S("Action")="face" then response.write " class='puton'"%>><a href="User_EditInfo.asp?Action=face">个人头像</a></li>
				<li<%If KS.S("Action")="ContactInfo" then response.write " class='puton'"%>><a href="User_EditInfo.asp?Action=ContactInfo">个人详细资料</a></li>
				<li<%If KS.S("Action")="PassInfo" then response.write " class='puton'"%>><a href="User_EditInfo.asp?Action=PassInfo">密码设置</a></li>
				
				<%If KSUser.GetUserInfo("usertype")="1" Then%>
				 <li><a href="User_enterprise.asp">企业基本资料</a></li>
				 <li><a href="User_enterprise.asp?action=intro">企业简介</a></li>
				<%else%>
				 <li><a href="user_enterprise.asp">升级为企业用户</a></li>
				<%End If%>
				<li style="width:80px" <%If KS.S("Action")="permissions" then response.write " class='select'"%>><a href="User_EditInfo.asp?Action=permissions">我的权限</a></li>
			</ul>
		</div>

		<%
		Select Case KS.S("Action")
		  case "face"
	       Call KSUser.InnerLocation("修改个人形象照片")
		   Call ChangeFace()
		  Case "ContactInfo"
	       Call KSUser.InnerLocation("修改详细信息")
		   Call ContactInfo()
		  Case "PassInfo"
	       Call KSUser.InnerLocation("修改密码")
		   Call PassInfo()
		  Case "PassSave"
		   Call PassSave()
		  Case "PassQuestionSave"
		   Call PassQuestionSave()
		  Case "BasicInfoSave"
		   Call BasicInfoSave()
		  Case "ContactInfoSave"
		   Call ContactInfoSave()
		  Case "permissions"
		   Call permissions()
		  Case Else
	       Call KSUser.InnerLocation("修改基本信息")
		   Call EditBasicInfo()
		End Select
	   End Sub
	   
	   Sub permissions()
	    Call KSUser.InnerLocation("会员等级权限")
		%>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1">
			<tr>
				<td colspan="10" height="45">
				 <%if KSUser.getUserInfo("realname")<>"" then%>
				<font color="red"><%=KSUser.getUserInfo("realname")%></font>
				 <%else%>
				<font color="red"><%=KSUser.UserName%></font>
				<%end if%>,  您的会员等级：<font color=blue><%=KS.U_G(KSUser.GroupID,"groupname")%></font>
				累计在本站商城消费：<font color=red><%=KSUser.GetConsumMoney(KSUser.UserName)%></font> 元<font color=#999999>（累计消费不计运费及税费且只累计结清无退款的订单）</font>。
				</td>
			</tr>
			<%
			 dim i,rs,sql,GroupSetting
			 set rs=server.CreateObject("adodb.recordset")
			 rs.open "select id,groupname,Descript,GroupSetting from ks_usergroup where [type]<=1 and id<>1 order by id",conn,1,1
			 if not rs.eof then
			    sql=rs.getrows(-1)  
			 else
			   ks.die ""
			 end if
			 
			%>
		    <tr class="title" align="center">
			 <td height="35">项目</td>
			 <%
			  for i=0 to ubound(sql,2)
			   if KS.ChkClng(KSUser.GroupID)=ks.chkclng(sql(0,i)) then
			   response.write "<td style='background:#ff6600;color:#fff;font-weight:bold'>" & sql(1,i) &"</td>"
			   else
			   response.write "<td>" & sql(1,i) &"</td>"
			   end if
			  next
			 %>
		    </tr>				
		    <tr align="center" class='splittd'>
			 <td class="splittd"  height="50">
			   <strong>达到此级别的条件</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			   response.write "<td class='splittd'>" & sql(2,i) &"</td>"
			  next
			 %>
		    </tr>
		    <tr align="center" class='splittd' style="background:#f1f1f1;">
			 <td nowrap="nowrap" class="splittd"  height="50">
			   <strong>购物优惠</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			   GroupSetting=split(sql(3,i),",")
			   if GroupSetting(17)="0" or not isnumeric(GroupSetting(17)) then
			   response.write "<td class='splittd'>无</td>"
			   else
			   response.write "<td class='splittd'>正价产品<font color=red> " & GroupSetting(17) &" </font>折(特价秒杀或特殊标记商品除外)</td>"
			   end if
			  next
			 %>
		    </tr>
		    <tr align="center" class='splittd'>
			 <td class="splittd" height="50" style="width:130px" >
			   <strong>积分策略</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			    GroupSetting=split(sql(3,i),",")
			   if GroupSetting(18)="0" or GroupSetting(18)="1" or not isnumeric(GroupSetting(18)) then
			   response.write "<td class='splittd'>享受实际价格的<font color=red> 1 </font>倍积分</td>"
			   else
			   response.write "<td class='splittd'>享受实际价格的<font color=green> " & GroupSetting(18) & " </font>倍积分(特价秒杀或特殊标记商品除外)</td>"
			   end if
			  next
			 %>
		    </tr>
		    <tr align="center" class='splittd' style="background:#f1f1f1;">
			 <td  class="splittd"  height="50">
			   <strong>永久享受推荐奖积分</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			   GroupSetting=split(sql(3,i),",")
			   if KS.ChkClng(GroupSetting(19))=1 then
			   response.write "<td class='splittd'><font color=green>√</font></td>"
			   else
			   response.write "<td class='splittd'><font color=red>X</font></td>"
			   end if
			  next
			 %>
		    </tr>	
		    <tr align="center" class='splittd'>
			 <td class="splittd" height="50" style="width:130px" >
			   <strong>享受推荐奖积分百分比</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			    GroupSetting=split(sql(3,i),",")
			   if KS.ChkClng(GroupSetting(19))=1 and ks.chkclng(GroupSetting(20))>0 then
			   response.write "<td class='splittd'><font color=green>" & GroupSetting(20) & " %</font></td>"
			   else
			   response.write "<td class='splittd'><font color=red>X</font></td>"
			   end if
			  next
			 %>
		    </tr>
		    <tr align="center" class='splittd' style="background:#f1f1f1;">
			 <td  class="splittd"  height="50">
			   <strong>独享VIP会员专用客服通道</strong>
			 </td>
			 <%
			  for i=0 to ubound(sql,2)
			   GroupSetting=split(sql(3,i),",")
			   if KS.ChkClng(GroupSetting(21))=1 then
			   response.write "<td class='splittd'><font color=green>√</font></td>"
			   else
			   response.write "<td class='splittd'><font color=red>X</font></td>"
			   end if
			  next
			 %>
		    </tr>	
					
            </table>
			
		<%
	   End Sub
	   
	   '基本信息
	   Sub EditBasicInfo()
		   %>
          <script type="text/javascript">
	
       	 <!----检查用户名，电子邮箱结束-->
      function CheckForm() 
		{ 
			
			if (document.myform.RealName.value =="")
			{
			$.dialog.alert("请填写您的真实姓名！",function(){
			document.myform.RealName.focus();
			});
			return false;
			}
			if (document.myform.Sex.value =="")
			{
			 $.dialog.alert("请选择您的性别！",function(){
			document.myform.Sex.focus();
			});
			return false;
			}

		  return true;	
		}
    </script>
	  
          <iframe src="about:blank" name="hidiframe" width="0" height="0"></iframe>
          <table  cellspacing="1" cellpadding="3"  width="98%" align="center" border="0" class="border">
					  <form target="hidiframe" action="User_EditInfo.asp?Action=BasicInfoSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();">

                          <tr class="tdbg">
                            <td  class="clefttitle">会员名称：</td>
                            <td><input  class="textbox" type="hidden" name="username" size="30" value="<%=KSUser.username%>" disabled="disabled" /> <%=KSUser.username%></td>
                          </tr>
                          
                          <tr class="tdbg">
                            <td  class="clefttitle">真实姓名：</td>
                            <td>
							<%if KSUser.GetUserInfo("issfzrz")="1" then%>
							<input name="RealName" class="textbox" type="hidden" id="RealName" value="<%=KSUser.GetUserInfo("RealName")%>" size="30" maxlength="50" /><%=KSUser.GetUserInfo("RealName")%> 
							身份证号：<%=KSUser.GetUserInfo("idcard")%>
							<span class="msgtips">*已经过实名认证</span>
							<%else%>
							<input name="RealName" class="textbox" type="text" id="RealName" value="<%=KSUser.GetUserInfo("RealName")%>" size="30" maxlength="50" />
                              <span style="color: red">* </span> <span class="msgtips">请务必填写真实姓名</span>
							<%end if%></td>
                          </tr>
                          <tr class="tdbg">
                            <td  class="clefttitle">性&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 别：</td>
                            <td> <label><input type="radio" name="Sex" value="男" <%if KSUser.GetUserInfo("Sex")="男" then response.write " checked"%> />先生</label>
							
							<label><input type="radio" name="Sex" value="女" <%if KSUser.GetUserInfo("Sex")="女" then response.write " checked"%> />女士</label>
                                </td>
            
                          <tr class="tdbg">
                            <td  class="clefttitle"> 出生日期：</td>
                            <td><%dim birthday:birthday=KSUser.GetUserInfo("Birthday")
							    if not isdate(birthday) then birthday=now
								dim i
								%>
								<select name="b1" class="select">
								  <option value='0'>年</option>
								 <%for i=year(now) to 1950 step -1
								   if year(birthday)=i then
								       response.write "<option selected value='" & i &"'>" & i &"年</option>"
								   else
									   response.write "<option value='" & i &"'>" & i &"年</option>"
								   end if
								   next
								 %>
								</select>
								<select name="b2" class="select">
								  <option value='0'>月</option>
								 <%for i=1 to 12 
								    if month(birthday)=i then
								     response.write "<option selected value='" & i &"'>" & i &"月</option>"
								    else
									  response.write "<option value='" & i &"'>" & i &"月</option>"
									end if
								   next
								 %>
								</select>
								<select name="b3" class="select">
								  <option value='0'>日</option>
								 <%for i=1 to 31 
								   if day(Birthday)=i then
								    response.write "<option selected value='" & i &"'>" & i &"日</option>"
								   else
								   response.write "<option value='" & i &"'>" & i &"日</option>"
								   end if
								   next
								 %>
								</select>
								
                              
                                <span style="color: red">*</span> <span class="msgtips">请选择您的出生年月</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td  class="clefttitle">邮箱地址：</td>
                            <td>
							<%if KSUser.GetUserInfo("isemailrz")="1"  and KSUser.GetUserInfo("email")<>"" then%>
							<%=KSUser.GetUserInfo("email")%><span class="msgtips">*已经过Email认证</span>
							<%else%>
							<input name="Email" class="textbox" type="text" id="Email" value="<%=KSUser.GetUserInfo("Email")%>" size="30" maxlength="50" />
                                <span style="color: red">*</span> <span class="msgtips">请填写正确的邮箱地址，如：kesioncms@hotmail.com</span>
							<%end if%></td>
                          </tr>
                          <tr class="tdbg">
                            <td  class="clefttitle">手机号码：</td>
                            <td>
							<%if KSUser.GetUserInfo("ismobilerz")="1"  and KSUser.GetUserInfo("Mobile")<>"" then%>
							 <%=KSUser.GetUserInfo("Mobile")%><span class="msgtips">*已经过手机认证</span>
							<%else%>
							<input name="Mobile" class="textbox" type="text" id="Mobile" value="<%=KSUser.GetUserInfo("Mobile")%>" size="30" maxlength="50" />
                                <span style="color: red">*</span> <span class="msgtips">请填写常用的手机号。</span>
							<%end if%>	
								</td>
                          </tr>
                          <tr class="tdbg">
                            <td  class="clefttitle">隐私设定：</td>
                            <td> <input type="radio" <%if KSUser.GetUserInfo("Privacy")="0" Then Response.Write "checked=""checked"""%> value="0" name="Privacy" />
                              公开全部信息(包括真实姓名/电话号码/生日等) <br />
                             <input type="radio" value="1" name="Privacy" <%if KSUser.GetUserInfo("Privacy")="1" Then Response.Write "checked=""checked"""%>/>
                              公开部分信息(只公开QQ/Email等网上联络的信息) <br />
                              <input type="radio" value="2" name="Privacy" <%if KSUser.GetUserInfo("Privacy")="2" Then Response.Write "checked=""checked"""%>/>
                              完全保密(别人只能查看你的昵称) </td>
                          </tr>
                          <tr class="tdbg">
                            <td  class="clefttitle">个人签名：</td>
                            <td><textarea name="Sign" class="textbox" cols="60" rows="5" id="Sign" style="width:300px; height:60px"><%= KSUser.GetUserInfo("Sign")%></textarea></td>
                          </tr>
                          <tr class="tdbg">
                            <td height="30">&nbsp;</td>
                            <td><button type="submit"  class="pn"><strong>OK,修 改</strong></button></td>
                          </tr>
		    </form>
            </table>
          <%
  End Sub
  
  Sub ChangeFace()
  %>
   <br/>
  <table cellspacing="1" cellpadding="3"  width="90%" align="center" border="0">
   <tr class="tdbg">
             <td colspan="2" height="22"><span style="font-weight: bold;color:green;font-size:14px"> 
	  个人头像支持jpg、gif、png格式的图片,大小限制150k，建议尺寸为120*120。</span></td>
	</tr>
	<tr>  <td align="left" valign="top">
							<%dim userfacesrc:userfacesrc=KSUser.GetUserInfo("UserFace")
							 if KS.IsNul(userfacesrc) then userfacesrc="../Images/Face/boy.gif"
							 if left(userfacesrc,1)<>"/" and lcase(left(userfacesrc,4))<>"http" then userfacesrc="../" & userfacesrc
							%>
							<div class="ar_r_t"><div class="ar_l_t"><div class="ar_r_b"><div class="ar_l_b"><img width="120" height="120" src="<%=UserFaceSrc%>" name=showimages onerror="this.onerror=null;this.src='images/noavatar_middle.gif'" id="imgIcon"></div></div></div></div>
							
						
			 <br/>
			
			  
      </td>
			   <td valign="top">
			    
			   <br>
			    <table width="100%" border="0">
				<tr>
				 <td colspan="2">
			   头像地址：
			   <input class="textbox" name="UserFace" type="text" id="PhotoUrl" value="<%=Replace(userfacesrc,"../","")%>" size="40" maxlength="50" />
			    </td>
				</tr>
				<tr>
				<td width="410" height="40"><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_UpFile.asp?Type=Pic&ChannelID=9999&MaxFileSize=150&ext=*.jpg;*.gif;*.png' frameborder="0" scrolling="No" align="center" width='400' height='40'></iframe>
				</td>
				
			    </tr>
			   </table>
			   <script type="text/javascript">
			    function setface(){
				 var v=$('#PhotoUrl').val();
				 if (v.substring(0,1)!='/' && v.substring(0,4)!='http') v='../'+v;
				document.myform.showimages.src=v;
				}
			   </script>
		 
		  <span class="msgtips">温馨提醒：头像上传后，您可能需要刷新一下本页面(按F5键)，才能查看最新的头像效果！</span>
		  <br/><br/>
		  <!--
		  <button type="submit"  class="pn"><strong>OK,保存我的头像</strong></button>
		  -->
	  </td>
    </tr>
	</table>
	<%if KS.G("PhotoUrl")<>"" Then%>
	      <strong style="padding-left:30px;font-size:14px;color:#996633"><img src='images/icon7.png' />&nbsp;现在可以对您上传的照片进行处理：</strong>
		 <iframe src="facecut.asp?photourl=<%=KS.G("PhotoUrl")%>" id="facecut" name="facecut" width="730" frameborder="0" scrolling="no" height="550"></iframe>
    <%end if%>
  <%
  End Sub
  
  
  '联系信息
  Sub ContactInfo()
  %>		<script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
          <table  cellspacing="1" cellpadding="3" width="98%" align="center" border="0">
					  <form action="User_EditInfo.asp?Action=ContactInfoSave" method="post" name="myform" id="myform">
					  <input type="hidden" value="<%=KS.S("ComeUrl")%>" name="comeurl">
						  <tr>
						    <td colspan="2">
							<% 
							Dim RSU:Set RSU=Server.CreateObject("ADODB.RECORDSET")
							RSU.Open "Select top 1 * From KS_User Where UserName='" & KSUser.UserName & "'",conn,1,1
							If RSU.Eof Then
							  RSU.Close:Set RSU=Nothing
							  Response.Write "<script>alert('非法参数！');history.back();</script>"
							  Response.End()
							End If
							
						  Dim Template:Template=LFCls.GetSingleFieldValue("Select top 1 Template From KS_UserForm Where ID=" & KS.ChkClng(KS.U_G(KSUser.GroupID,"formid")))

						   Dim FieldsList:FieldsList=LFCls.GetSingleFieldValue("Select top 1 FormField From KS_UserForm Where ID=" & KS.ChkClng(KS.U_G(KSUser.GroupID,"formid")))
						   Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
						   RS.Open "Select FieldID,FieldType,FieldName,DefaultValue,Width,Height,Options,EditorType,ShowUnit,UnitOptions,MaxLength from KS_Field Where ChannelID=101 Order By OrderID",conn,1,1
						   Dim SQL,K,N,InputStr,O_Arr,O_Len,F_V,O_Value,O_Text,BRStr,FieldStr,Height,Width
						   If Not RS.EOf Then SQL=RS.GetRows(-1):RS.Close():Set RS=Nothing
						   For K=0 TO Ubound(SQL,2)
						     Width=KS.ChkClng(SQL(4,K)) : If Width<300 Then Width=300
						     Height=KS.ChkClng(SQL(5,K)) : If Height=0 Then Height=50
						     FieldStr=FieldStr & "|" & lcase(SQL(2,K))
							 If KS.FoundInArr(FieldsList,SQL(0,k),",") Then
							  InputStr=""
							  If lcase(replace(SQL(2,K),"&",""))="provincecity" Then
								 InputStr="<script>try{setCookie(""pid"",'" & rsu("province") & "');}catch(e){}</script>" & vbcrlf
								 InputStr="<script src='../plus/area.asp'></script><script language=""javascript"">" &vbcrlf
								 If RSU("Province")<>"" And Not ISNull(RSU("Province")) Then
						         InputStr=InputStr & "$('#Province').val('" & RSU("province") &"');" &vbcrlf
								 End If
						         If RSU("City")<>"" And Not ISNull(RSU("City")) Then
								  InputStr=InputStr & "$('#City').val('" & RSU("City") & "');" &Vbcrlf
						         end if
						          InputStr=InputStr & "</script>" &vbcrlf
							  Else
							  Select Case SQL(1,K)
								Case 2:InputStr="<textarea rows=""5"" style=""width:" & Width & "px;height:" & Height & "px"" name=""" & SQL(2,K) & """ class=""textarea"">" &RSU(SQL(2,K)) & "</textarea>"
								Case 3,11
								  If SQL(1,K)=11 Then
					               InputStr= "<select style=""width:" & SQL(4,K) & """ name=""" & SQL(2,K) & """ onchange=""fill" & SQL(2,K) &"(this.value)""><option value=''>---请选择---</option>"
								  Else
								   InputStr="<select style=""width:" & SQL(4,K) & """ name=""" & SQL(2,K) & """>"
								  End If
								  O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
								  For N=0 To O_Len
									 F_V=Split(O_Arr(N),"|")
									 If Ubound(F_V)=1 Then
										O_Value=F_V(0):O_Text=F_V(1)
									 Else
										O_Value=F_V(0):O_Text=F_V(0)
									 End If						   
									 If Trim(RSU(SQL(2,K)))=O_Value Then
										InputStr=InputStr & "<option value=""" & O_Value& """ selected>" & O_Text & "</option>"
									 Else
										InputStr=InputStr & "<option value=""" & O_Value& """>" & O_Text & "</option>"
									 End If
								  Next
									InputStr=InputStr & "</select>"
									'联动菜单
									If SQL(1,K)=11  Then
										Dim JSStr
										InputStr=InputStr &  GetLDMenuStr(RSU,101,SQL,SQL(2,k),JSStr) & "<script type=""text/javascript"">" &vbcrlf & JSStr& vbcrlf &"</script>"
									End If
								Case 6
									 O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
									 If O_Len>1 And Len(SQL(6,K))>50 Then BrStr="<br>" Else BrStr=""
									 For N=0 To O_Len
										F_V=Split(O_Arr(N),"|")
										If Ubound(F_V)=1 Then
										 O_Value=F_V(0):O_Text=F_V(1)
										Else
										 O_Value=F_V(0):O_Text=F_V(0)
										End If
										If Trim(RSU(SQL(2,K)))=O_Value Then
											InputStr=InputStr & "<input type=""radio"" name=""" & SQL(2,K) & """ value=""" & O_Value& """ checked>" & O_Text & BRStr
										Else
											InputStr=InputStr & "<input type=""radio"" name=""" & SQL(2,K) & """ value=""" & O_Value& """>" & O_Text & BRStr
										 End If
									 Next
							  Case 7
									O_Arr=Split(SQL(6,K),vbcrlf): O_Len=Ubound(O_Arr)
									 For N=0 To O_Len
										  F_V=Split(O_Arr(N),"|")
										  If Ubound(F_V)=1 Then
											O_Value=F_V(0):O_Text=F_V(1)
										  Else
											O_Value=F_V(0):O_Text=F_V(0)
										  End If						   
										  If KS.FoundInArr(Trim(RSU(SQL(2,K))),O_Value,",")=true Then
												 InputStr=InputStr & "<input type=""checkbox"" name=""" & SQL(2,K) & """ value=""" & O_Value& """ checked>" & O_Text
										 Else
										  InputStr=InputStr & "<input type=""checkbox"" name=""" & SQL(2,K) & """ value=""" & O_Value& """>" & O_Text
										 End If
								   Next
							  Case 10
							        Dim H_Value:H_Value=RSU(SQL(2,K))
									If IsNull(H_Value) Then H_Value=" "
									InputStr=InputStr & "<textarea  style=""display:none"" id=""" & SQL(2,K) &""" name=""" & SQL(2,K) &""">"& Server.HTMLEncode(H_Value) &"</textarea><script type=""text/javascript"">CKEDITOR.replace('" & SQL(2,K) &"', {width:""" & Width &""",height:""" & Height & """,toolbar:""" & SQL(7,K) & """,filebrowserBrowseUrl :""../editor/ksplus/SelectUpFiles.asp"",filebrowserWindowWidth:650,filebrowserWindowHeight:290});</script>"
									
							  Case Else
							      Dim MaxLength:MaxLength=KS.ChkClng(SQL(10,K))
				                  If MaxLength=0 Then MaxLength=255
								  InputStr="<input type=""text"" MaxLength="""& MaxLength & """ class=""textbox"" style=""width:" & SQL(4,K) & """ name=""" & lcase(SQL(2,K)) & """ value=""" & RSU(SQL(2,K)) & """>"
							  End Select
							  End If
							
							  If SQL(8,K)="1" Then 
								  InputStr=InputStr & " <select name=""" & SQL(2,K) & "_Unit"" id=""" & SQL(2,K) & "_Unit"">"
								  If Not KS.IsNul(SQL(9,k)) Then
								   Dim KK,UnitOptionsArr:UnitOptionsArr=Split(SQL(9,k),vbcrlf)
								   For KK=0 To Ubound(UnitOptionsArr)
								      If Trim(RSU(SQL(2,K) & "_Unit"))=Trim(UnitOptionsArr(KK)) Then
									  InputStr=InputStr & "<option value='" & UnitOptionsArr(KK) & "' selected>" & UnitOptionsArr(KK) & "</option>"                 
									  Else
									  InputStr=InputStr & "<option value='" & UnitOptionsArr(KK) & "'>" & UnitOptionsArr(KK) & "</option>"                 
									  End If
								   Next
								  End If
								  InputStr=InputStr & "</select>"
			                  End If

							  
							  if SQL(1,K)=9 Then InputStr=InputStr & "<div><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_UpFile.asp?Type=Field&FieldID=" & SQL(0,K) & "&ChannelID=101' frameborder=0 scrolling=no width='100%' height='30'></iframe></div>"
							  
							  
				              If Instr(Template,"{@NoDisplay(" & SQL(2,K) & ")}")<>0 Then
							   Template=Replace(Template,"{@NoDisplay(" & SQL(2,K) & ")}"," style='display:none'")
							  End If
							  Template=Replace(Template,"[@" & replace(SQL(2,K),"&","") & "]",InputStr)
							 End If
						   Next
							
							
							Response.Write Template
							%>
							</td>
						  </tr>
                         
                          <tr class="tdbg">
                            <td class='clefttitle' height="30">&nbsp;</td>
                            <td> <button type="submit" onClick="return(CheckForm())" class="pn"><strong>保存我的个人资料</strong></button> </td>
                          </tr>
		    </form>
            </table>
		
          <script type="text/javascript">
		   <%if rsu("issfzrz")="1" then%>
		   $("input[name=realname]").attr("disabled",true).next().html('*已实名认证，不可更改').addClass("msgtips");
		   $("input[name=idcard]").attr("disabled",true).next().html('*已实名认证，不可更改');
		   <%
		  
		   end if
RSU.Close:Set RSU=Nothing		   
		   %>
		   //检查日期
		   function CheckDT(str)     
		   {     
				 var r = str.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/);     
				 if(r==null)
				 {
					 return false;     
				 }
				 else
				 {
					var d= new Date(r[1], r[3]-1, r[4]);     
					return (d.getFullYear()==r[1]&&(d.getMonth()+1)==r[3]&&d.getDate()==r[4]); 
				}    
			}
		  //检查电话
		  function CheckPhone(Str) 
			{ 
			   var i,j,strTemp;
			   Str=Str.replace('-','');
			   strTemp="0123456789";
				if (Str.length<10||Str.length>12)
				{
				return false;
				}
			 
			   for (i=0;i<Str.length;i++)
				{
				 j=strTemp.indexOf(Str.substring(i, i+1)); 
				 if (j==-1)
				  {
				   return false;
				  }
				}
			   return true;
			}
			//检查手机
			function CheckMobile(MobileStr) 
			{ 
			   var i,j,strTemp;
			   strTemp="0123456789";
			   var flags;
			   
			   if(MobileStr.substring(0,2)!="18"&&MobileStr.substring(0,2)!="13"&&MobileStr.substring(0,2)!="15"&&MobileStr.substring(0,1)!="0")
				{
				 return false;
				}
			   
			  
				if (MobileStr.length!=11)
				{
				return false;
				}
			   
			   for (i=0;i<MobileStr.length;i++)
				{
				 j=strTemp.indexOf(MobileStr.substring(i, i+1)); 
				 if (j==-1)
				  {
				   return false;
				  }
				}
			   return true;
			}


			
           //检查是否全数字
		   function CheckAllNum(str)
			{
			   var i,j,strTemp;
			   strTemp="0123456789";
			   for (i=0;i<str.length;i++)
				{
				 j=strTemp.indexOf(str.substring(i, i+1)); 
				 if (j==-1)
				  {
				   return false;
				  }
				}
			   return true;
			}
			//检查邮箱是否合法
			function emailCheck (emailStr) {
			var emailPat=/^(.+)@(.+)$/;
			var matchArray=emailStr.match(emailPat);
			if (matchArray==null) {
			 return false;
			}
			return true;
			}
            
			function CheckForm()
			{
			  var obj=document.myform;
			<%if instr(FieldStr,"birthday")<>0 then%>
			 if (CheckDT(obj.birthday.value)==false)
			 {
			  alert('出生日期格式不正确！格式应为yyyy-mm-dd');
			  obj.birthday.focus();
			  return false;
			 }
			<%end if
			if InStr(FieldStr,"officetel")<>0 then%>
			 if (obj.officetel.value!='' && CheckPhone(obj.officetel.value)==false)
			 {
			   alert('办公电话格式不正确！');
			   obj.officetel.focus();
			   return false;
			 }
			<%end if
			if InStr(FieldStr,"hometel")<>0 then%>
			 if (obj.hometel.value!='' && CheckPhone(obj.hometel.value)==false)
			 {
			   alert('电话号码格式不正确！');
			   obj.hometel.focus();
			   return false;
			 }
			<%end if
			if InStr(FieldStr,"fax")<>0 then%>
			 if (obj.fax.value!='' && CheckPhone(obj.fax.value)==false)
			 {
			   alert('传真号码格式不正确！');
			   obj.fax.focus();
			   return false;
			 }
			<%end if
			if InStr(FieldStr,"mobile")<>0 then%>
			 if (obj.mobile.value!='' && CheckMobile(obj.mobile.value)==false)
			 {
			   alert('手机号码格式不正确！');
			   obj.mobile.focus();
			   return false;
			 }
			<%end if

			if instr(FieldStr,"uc")<>0 then%>
			if (obj.uc.value!='' && (CheckAllNum(obj.uc.value)==false ||obj.uc.value.length<5))
			 {
			   alert('UC号码格式不正确，不能含有字符且不能少于5位！');
			   obj.uc.focus();
			   return false;
			 }
			<%
			end if
			if instr(FieldStr,"qq")<>0 then%>
			if (obj.qq.value!='' && (CheckAllNum(obj.qq.value)==false ||obj.qq.value.length<5))
			 {
			   alert('qq号码格式不正确，不能含有字符且不能少于5位！');
			   obj.qq.focus();
			   return false;
			 }
			<%
			end if
			if instr(FieldStr,"icq")<>0 then%>
			if (obj.icq.value!='' && (CheckAllNum(obj.icq.value)==false ||obj.icq.value.length<5))
			 {
			   alert('icq号码格式不正确，不能含有字符且不能少于5位！');
			   obj.icq.focus();
			   return false;
			 }
			<%
			end if
			if instr(FieldStr,"zip")<>0 then%>
			if (obj.zip.value!='' && (CheckAllNum(obj.zip.value)==false ||obj.zip.value.length<6))
			 {
			   alert('邮政编码格式不正确！');
			   obj.zip.focus();
			   return false;
			 }
			<%
			end if
			if instr(FieldStr,"msn")<>0 then%>
			if (obj.msn.value!='' && emailCheck(obj.msn.value)==false)
			 {
			   alert('MSN格式不正确！');
			   obj.msn.focus();
			   return false;
			 }
			<%
			end if
			%>
			}
		 </script>
		<%
		  
  End Sub
  
		   '取得联动菜单
		   Function GetLDMenuStr(RSU,ChannelID,F_Arr,byVal ParentFieldName,JSStr)
		     Dim OptionS,OArr,I,VArr,V,F,Str
		     Dim RSL:Set RSL=Conn.Execute("Select Top 1 FieldName,Title,Options,Width From KS_Field Where ChannelID=" & ChannelID & " and ParentFieldName='" & ParentFieldName & "'")
			 If Not RSL.Eof Then
			     Str=Str & " <select name='" & RSL(0) & "' id='" & RSL(0) & "' onchange='fill" & RSL(0) & "(this.value)' style='width:" & RSL(3) & "px'><option value=''>--请选择--</option>"
				 JSStr=JSStr & "var sub" &ParentFieldName & " = new Array();"
				  Options=RSL(2)
				  OArr=Split(Options,Vbcrlf)
				  For I=0 To Ubound(OArr)
				    Varr=Split(OArr(i),"|")
					If Ubound(Varr)=1 Then 
					 V=Varr(0):F=Varr(1)
					Else
					 V=trim(OArr(i))
					 F=trim(OArr(i))
					End If
				    JSStr=JSStr & "sub" & ParentFieldName&"[" & I & "]=new Array('" & V & "','" & F & "')" &vbcrlf
				  Next
				 Str=Str & "</select>"
				 JSStr=JSStr & "function fill"& ParentFieldName&"(v){" &vbcrlf &_
							   "$('#"& RSL(0)&"').empty();" &vbcrlf &_
							   "$('#"& RSL(0)&"').append('<option value="""">--请选择--</option>');" &vbcrlf &_
							   "for (i=0; i<sub" &ParentFieldName&".length; i++){" & vbcrlf &_
							   " if (v==sub" &ParentFieldName&"[i][0]){document.getElementById('" & RSL(0) & "').options[document.getElementById('" & RSL(0) & "').length] = new Option(sub" &ParentFieldName&"[i][1], sub" &ParentFieldName&"[i][1]);}}" & vbcrlf &_
							   "}"
				 Dim DefaultVAL:DefaultVAL=RSU(trim(RSL(0)))
                 If Not KS.IsNul(DefaultVAL) Then
				  str=str & "<script>$(document).ready(function(){fill"&ParentFieldName&"($('select[name=" &ParentFieldName&"] option:selected').val()); $('#"& RSL(0)&"').val('" & DefaultVAL & "');})</script>" &vbcrlf
				 End If
				 GetLDMenuStr=str & GetLDMenuStr(RSU,ChannelID,F_Arr,RSL(0),JSStr)
			 Else
			     JSStr=JSStr & "function fill" & ParentFieldName &"(v){}"				 
			 End If
			     
		   End Function
  
  
  '设置密码
  Sub PassInfo()
  		   %>
          <script type="text/javascript">
	      function CheckForm() 
		{  <%if KS.ChkClng(KSUser.GetUserInfo("isapi"))<>1 then%>
			if (document.myform.oldpassword.value =="")
			{
			 $.dialog.alert("请填写您的旧密码！",function(){
			document.myform.oldpassword.focus();
			});
			return false;
			}
		   <%end if%>
			if (document.myform.newpassword.value =="")
			{
			$.dialog.alert("请输入您的新密码！",function(){
			document.myform.newpassword.focus();
			});
			return false;
			}
			if (parseInt(document.myform.newpassword.value.length)<6)
			{
			 $.dialog.alert("密码长度必须大于等于6！",function(){
			document.myform.newpassword.focus();
			});
			return false;
			}
			if (document.myform.renewpassword.value =="")
			{
			 $.dialog.alert("请输入您的新确认密码！",function(){
			document.myform.renewpassword.focus();
			});
			return false;
			}
			if (document.myform.newpassword.value !=document.myform.renewpassword.value)
			{
			 $.dialog.alert("两次输入的密码不一致！",function(){
			document.myform.renewpassword.focus();
			});
			return false;
			}
          return true;			
		}
	      function CheckForm1() 
		{ 
			if (document.myform1.Password.value =="")
			{
			 $.dialog.alert("请填写您的登录密码！",function(){
			document.myform1.Password.focus();
			});
			return false;
			}
			if (document.myform1.Question.value =="")
			{
			 $.dialog.alert("请输入您的密码问题！",function(){
			document.myform1.Question.focus();
			});
			return false;
			}
			if (document.myform1.Answer.value =="")
			{
			 $.dialog.alert("请输入您的问题答案！",function(){
			document.myform1.Answer.focus();
			});
			return false;
			}

          return true;			
		}
    </script>
          <table  cellspacing="1" cellpadding="3" class="border" width="98%" align="center" border="0">
					  <form action="User_EditInfo.asp?Action=PassSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
                          <tr>
                            <td height="28" class="usertitle" colspan="2"> 修改密码 </td>
                          </tr>
						  <%if KS.ChkClng(KSUser.GetUserInfo("isapi"))=1 then%>
                          <tr class="tdbg">
                            <td colspan="2" style="color:green;font-size:14px">温馨提示：您是通过第三方网站账号登录本站的，您可以设置新密码，下次就可以直接使用用户名 <span style='color:red'><%=KSUser.UserName%></span> 和以下设置的密码登录本站了。</td>
                          </tr>
						  <%else%>
                          <tr class="tdbg">
                            <td class="clefttitle">旧 密 码： </td>
                            <td><input name="oldpassword" class="textbox" type="password" id="oldpassword" size="30" maxlength="50" />
                            <span style="color: red">*</span>  <span class="msgtips">您的旧登录密码，必须正确填写。</span></td>
                          </tr>
						  <%end if%>
                          <tr class="tdbg">
                            <td class="clefttitle">新 密 码：</td>
                            <td><input name="newpassword" class="textbox" type="password" id="newpassword" size="30" maxlength="50" />
                            <span style="color: red">* </span> <span class="msgtips">请输入您的新密码！</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">确认密码：</td>
                            <td><input name="renewpassword" class="textbox" type="password" id="renewpassword" size="30" maxlength="50" />
                              <span style="color: red">* </span> <span class="msgtips">同上。</span></td>
                          </tr>
                          
						<tr class="tdbg">
                            <td  class="clefttitle" height="30">&nbsp;</td>
                            <td><button type="submit" class="pn"><strong>OK,修改密码</strong></button></td>
                        </tr>
		    </form>
            </table>
          <br>
          <table  cellspacing="1" cellpadding="3" class="border" width="98%" align="center" border="0">
					  <form action="User_EditInfo.asp?Action=PassQuestionSave" method="post" name="myform1" id="myform1" onSubmit="return CheckForm1();">
                          <tr>
                            <td height="22" colspan="2" class="usertitle">更改找回密码设置</td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">登录密码：</td>
							<td><input name="Password" class="textbox" type="password" id="Password" size="30" maxlength="50" />
                              <span style="color: red">* </span> <span class="msgtips">同上。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">密码问题：</td>
                            <td><input name="Question" class="textbox" type="text" id="Question" value="<%=KSUser.GetUserInfo("Question")%>" size="30" maxlength="50" />
                            <span style="color: red">* </span>  <span class="msgtips">当密码忘记时，取回密码的提示问题。</span></td>
						</tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> 问题答案：</td>
                            <td><input name="Answer" class="textbox" type="text" id="Answer" value="<%=KSUser.GetUserInfo("Answer")%>" size="30" maxlength="50" />
                            <span style="color: red">* </span>  <span class="msgtips">当密码忘记时，取回密码提示问题的答案。</span></td>
						</tr>
                          
						<tr class="tdbg">
                            <td  class="clefttitle">&nbsp;</td>
                            <td><button type="submit" class="pn"><strong>OK,修改密保</strong></button>                          </td>
                        </tr>
		    </form>
            </table>
          <%
  End SUb
  
  
  
  Sub BasicInfoSave() 
				 Dim RealName:RealName=KS.S("RealName")
				 Dim Sex:Sex=KS.S("Sex")
				 Dim Birthday:Birthday=KS.S("B1")&"-" & KS.S("B2") &"-" & KS.S("B3")
				 Dim Sign:Sign=KS.S("Sign")	
				 Dim Mobile:Mobile=KS.S("Mobile")	
				 Dim Privacy:Privacy=KS.S("Privacy")
			If Not IsDate(Birthday) Then
				 Response.Write "<script>$.dialog.tips('出生日期格式有误!',1,'error.gif',function(){});</script>"
				 response.end
			 end if
				
						   '过滤
            dim kk,sarr
            sarr=split(WordFilter,"|")
            for kk=0 to ubound(sarr)
               if instr(Sign,sarr(kk))<>0 then 
                  ks.die  "<script>$.dialog.tips('签名含有非常关键词:" & sarr(kk) &",请不要非法提交恶意信息!',1,'error.gif',function(){});</script>" 
               end if
            next
			
			if (KS.ChkClng(KS.U_S(KSUser.GroupID,26))>0 and len(sign)>KS.ChkClng(KS.U_S(KSUser.GroupID,26))) then
                  ks.die  "<script>$.dialog.tips('签名字数不能大于" & KS.U_S(KSUser.GroupID,26) &"!',1,'error.gif',function(){});</script>" 
			end if

				
				if KSUser.GetUserInfo("isemailrz")<>"1" Then
					  Dim Email:Email=KS.S("Email")
					 if KS.IsValidEmail(Email)=false then
						 Response.Write("<script>$.dialog.tips('请输入正确的电子邮箱!',1,'error.gif',function(){parent.document.getElementById('Email').focus();});</script>")
						 Exit Sub
					 end if
					 Dim EmailMultiRegTF:EmailMultiRegTF=KS.ChkClng(KS.Setting(28))
					If EmailMultiRegTF=0 Then
						Dim EmailRSCheck:Set EmailRSCheck = Conn.Execute("select top 1 UserID from KS_User where UserName<>'" & KSUser.UserName & "' And Email='" & Email & "'")
						If Not (EmailRSCheck.BOF And EmailRSCheck.EOF) Then
							EmailRSCheck.Close:Set EmailRSCheck = Nothing
							Response.Write("<script>$.dialog.tips('您注册的Email已经存在！请更换Email再试试！',1,'error.gif',function(){parent.document.getElementById('Email').focus();});</script>")
							Exit Sub
						End If
						EmailRSCheck.Close:Set EmailRSCheck = Nothing
					 End If
               end if
				 
			'-----------------------------------------------------------------
			'系统整合
			'-----------------------------------------------------------------
			Dim API_KS,API_SaveCookie,SysKey
			If API_Enable Then
				Set API_KS = New API_Conformity
				API_KS.NodeValue "action","update",0,False
				API_KS.NodeValue "username",KSUser.UserName,1,False
				Md5OLD = 1
				SysKey = Md5(API_KS.XmlNode("username") & API_ConformKey,16)
				Md5OLD = 0
				API_KS.NodeValue "syskey",SysKey,0,False
				API_KS.NodeValue "truename",RealName,1,False
				API_KS.NodeValue "gender",sex,0,False
				API_KS.SendHttpData
				If API_KS.Status = "1" Then
					Response.Write "<script>alert('" &  API_KS.Message  & "');</script>"
					Exit Sub
				End If
				Set API_KS = Nothing
			End If
			'-----------------------------------------------------------------

            Dim RS: Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select top 1 * From KS_User Where UserName='" & KSUser.UserName & "'",Conn,1,3
			  IF RS.Eof And RS.Bof Then
				 RS.Close:Set RS=Nothing:Response.End
			  Else
				 RS("RealName")=RealName
				 RS("Sex")=Sex
				 RS("Birthday")=Birthday
				 if rs("isemailrz")<>1 then RS("Email")=Email
				 if rs("ismobilerz")<>1 then RS("Mobile")=Mobile
				 RS("Sign")=Sign
				 RS("Privacy")=Privacy
				 If Not KS.IsNul(RS("userface")) Then
				   If Instr(lcase(RS("userface")),"boy.jpg")<>0 Or Instr(lcase(RS("userface")),"girl.jpg")<>0 Then
				    If Sex="男" Then 
					  rs("userface")=KS.GetDomain & "Images/Face/boy.jpg"
					Else
					  rs("userface")=KS.GetDomain & "Images/face/girl.jpg"
					End If
				   End If
				 End If
		 		 RS.Update
				 RS.Close:Set RS=Nothing
				 Session(KS.SiteSN&"UserInfo")=""
				 Response.Write "<script>$.dialog.tips('会员基本信息资料修改成功！',1,'success.gif',function(){top.location.reload();});</script>"
				 Response.End()
			  End if
			
  End Sub
  
  
  '保存联系信息
  Sub ContactInfoSave()
         Dim SQL,K,SQLStr
		 Dim FieldsList:FieldsList=LFCls.GetSingleFieldValue("Select FormField From KS_UserForm Where ID=" & KS.U_G(KSUser.GroupID,"formid"))
		 If FieldsList="" Then FieldsList="0"
	     Set RS = Server.CreateObject("ADODB.RECORDSET")
		 If KS.FilterIDs(FieldsList)="" Then
		 SQLStr="Select FieldName,MustFillTF,Title,FieldType,ShowUnit,UnitOptions,ParentFieldName From KS_Field Where ChannelID=101 and ShowOnUserForm=1 and (ParentFieldName<>'0' and ParentFieldName is not null)"
		 Else
		 SQLStr="Select FieldName,MustFillTF,Title,FieldType,ShowUnit,UnitOptions,ParentFieldName From KS_Field Where ChannelID=101 and ShowOnUserForm=1 and (FieldID In(" & KS.FilterIDs(FieldsList) & ") or (ParentFieldName<>'0' and ParentFieldName is not null))"
		 End If
		 RS.Open SQLStr,Conn,1,1
		 If Not RS.Eof Then SQL=RS.GetRows(-1)
		 RS.Close
		  For K=0 To UBound(SQL,2)
			  If SQL(6,K)="0" Then
				   If SQL(1,K)="1" Then 
					 if lcase(SQL(0,K))<>"province&city" and KS.S(SQL(0,K))="" then
						Response.Write "<script>$.dialog.tips('" & SQL(2,K) & "必须填写!',1,'error.gif',function(){history.back();});</script>"
						Response.End()
					 elseif KS.S("province")="" or ks.s("city")="" then
						Response.Write "<script>$.dialog.tips('地区必须选择!',1,'error.gif',function(){history.back();});</script>"
						Response.End()
					 end if
				   End If
	
				   
				   
				   If SQL(3,K)="4" And Not Isnumeric(KS.S(SQL(0,K))) Then 
					 Response.Write "<script>$.dialog.tips('" & SQL(2,K) & "必须填写数字!',1,'error.gif',function(){history.back();});</script>"
					 Response.End()
				   End If
				   If SQL(3,K)="5" And Not IsDate(KS.S(SQL(0,K))) Then 
					 Response.Write "<script>$.dialog.tips('" & SQL(2,K) & "必须填写正确的日期!',1,'error.gif',function(){history.back();});</script>"
					 Response.End()
				   End If
				   If SQL(3,K)="8" And Not KS.IsValidEmail(KS.S(SQL(0,K))) and SQL(1,K)="1" Then 
					Response.Write "<script>$.dialog.tips('" & SQL(2,K) & "必须填写正确的Email格式!',1,'error.gif',function(){history.back();});</script>"
					Response.End()
				   End If
			  End If 
			 Next

  
		 Dim RealName:RealName=KS.S("RealName")
		 Dim Sex:Sex=KS.S("Sex")
		 Dim Birthday:Birthday=KS.S("Birthday")
		 Dim IDCard:IDCard=KS.S("IDCard")
		 Dim OfficeTel:OfficeTel=KS.S("OfficeTel")
		 Dim HomeTel:HomeTel=KS.S("HomeTel")
		 Dim Mobile:Mobile=KS.S("Mobile")
		 Dim Fax:Fax=KS.S("Fax")
		 Dim province:province=KS.S("province")
		 Dim city:city=KS.S("city")
		 Dim Address:Address=KS.S("Address")
		 Dim ZIP:ZIP=KS.S("ZIP")
		 Dim HomePage:HomePage=KS.S("HomePage")		 	 	 
		 Dim QQ:QQ=KS.S("QQ")		 
		 Dim ICQ:ICQ=KS.S("ICQ")		 
		 Dim MSN:MSN=KS.S("MSN")		 
		 Dim UC:UC=KS.S("UC")		 
		 Dim Sign:Sign=KS.S("Sign")	
		 Dim Privacy:Privacy=KS.ChkClng(KS.S("Privacy"))
		 
		   '过滤
            dim kk,sarr
            sarr=split(WordFilter,"|")
            for kk=0 to ubound(sarr)
               if instr(Sign,sarr(kk))<>0 then 
                  ks.die  "<script>$.dialog.tips('签名含有非常关键词:" & sarr(kk) &",请不要非法提交恶意信息!',1,'error.gif',function(){history.back();});</script>"
               end if
            next
			
			'-----------------------------------------------------------------
			'系统整合
			'-----------------------------------------------------------------
			Dim API_KS,API_SaveCookie,SysKey
			If API_Enable Then
				Set API_KS = New API_Conformity
				API_KS.NodeValue "action","update",0,False
				API_KS.NodeValue "username",KSUser.UserName,1,False
				Md5OLD = 1
				SysKey = Md5(API_KS.XmlNode("username") & API_ConformKey,16)
				Md5OLD = 0
				API_KS.NodeValue "syskey",SysKey,0,False
				API_KS.NodeValue "email",KSUser.GetUserInfo("Email"),1,False
				API_KS.NodeValue "mobile",Mobile,1,False
				API_KS.NodeValue "homepage",homepage,1,False
				API_KS.NodeValue "address",Address,1,False
				API_KS.NodeValue "zipcode",zip,1,False
				API_KS.NodeValue "qq",qq,1,False
				API_KS.NodeValue "icq",icq,1,False
				API_KS.NodeValue "msn",msn,1,False
				API_KS.SendHttpData
				If API_KS.Status = "1" Then
					Response.Write "<script>alert('" &  API_KS.Message  & "');</script>"
					Exit Sub
				End If
				Set API_KS = Nothing
			End If
			 
              Dim RS,UpFiles
			  Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select * From KS_User Where UserName='" & KSUser.UserName & "'",Conn,1,3
			  IF RS.Eof And RS.Bof Then
				 Response.End
			  Else
			     
				 If BirthDay<>"" Then RS("Birthday")=Birthday
				 If Sign<>"" Then RS("Sign")=Sign
				 
				 If Sex<>"" Then 
				   RS("Sex")=Sex
					   If Not KS.IsNul(RS("userface")) Then
					   If Instr(lcase(RS("userface")),"boy.jpg")<>0 Or Instr(lcase(RS("userface")),"girl.jpg")<>0 Then
						If Sex="男" Then 
						  rs("userface")=KS.GetDomain & "Images/Face/boy.jpg"
						Else
						  rs("userface")=KS.GetDomain & "Images/face/girl.jpg"
						End If
					   End If
					 End If
				 End If
				 If RealName<>"" Then RS("RealName")=RealName
				 If IDCard<>"" Then	 RS("IDCard")=IDCard
				 
				 RS("Email")=KSUser.GetUserInfo("Email")
				 RS("OfficeTel")=OfficeTel
				 RS("HomeTel")=HomeTel
				 RS("Mobile")=Mobile
				 RS("Fax")=Fax
				 RS("Province")=Province
				 RS("City")=City
				 RS("Address")=Address
				 RS("Zip")=Zip
				 RS("HomePage")=HomePage
				 RS("QQ")=QQ
				 RS("ICQ")=ICQ
				 RS("MSN")=MSN
				 RS("UC")=UC
				 RS("Privacy")=Privacy
				 '自定义字段
				 For K=0 To UBound(SQL,2)
				  If left(Lcase(SQL(0,K)),3)="ks_" Then
				   RS(SQL(0,K))=KS.S(SQL(0,K))
				   	If SQL(3,K)="9" or SQL(3,K)="10" Then
					   UpFiles=UpFiles & KS.S(SQL(0,K))
					End If
				  End If
				  If SQL(4,K)="1" Then
				   RS(SQL(0,K)&"_Unit")=KS.S(SQL(0,K)&"_Unit")
				  End If
				 Next
		 		 RS.Update
				 
				 Call KS.FileAssociation(1023,RS("UserID"),UpFiles,1)
				 
				 Dim FieldsXml:Set FieldsXml=LFCls.GetXMLFromFile("SpaceFields")
				 If IsObject(FieldsXml) Then
				   	 Dim objNode,i,j,objAtr
					 Set objNode=FieldsXml.documentElement 
					If objNode.Attributes.item(0).Text<>"0" Then
					   If Not Conn.Execute("Select UserName From KS_EnterPrise Where UserName='" & KSUser.UserName & "'").Eof Then
						 For i=0 to objNode.ChildNodes.length-1 
								set objAtr=objNode.ChildNodes.item(i) 
								on error resume next
								Conn.Execute("UPDATE KS_EnterPrise Set " & objAtr.Attributes.item(0).Text & "='" & RS(objAtr.Attributes.item(1).Text) & "' Where UserName='" & KSUser.UserName & "'")
						 Next
					   End If
					End If
				 End If

				 
				 If KS.C_S(8,21)="1" Then
				  Conn.Execute("Update KS_GQ Set ContactMan='" & RealName &"',Tel='" &OfficeTel & "',Address='" & Address & "',Province='" & Province & "',City='" & City & "',Zip='" & Zip & "',Fax='" & Fax & "',Homepage='" & HomePage & "' where inputer='" & KSUser.UserName & "'")
				 End If
				 Session(KS.SiteSN&"UserInfo")=""
				 If KS.S("ComeUrl")<>"" Then
				 Response.Write "<script>$.dialog.tips('恭喜，详细信息修改成功！',1,'success.gif',function(){location.href='" & KS.S("ComeURL") &"';});</script>"
				 Else
				 Response.Write "<script>$.dialog.tips('恭喜，详细信息修改成功！',1,'success.gif',function(){location.href='" & Request.ServerVariables("HTTP_REFERER") &"';});</script>"
				 End If
				 Response.End()
			  End if
			RS.Close:Set RS=Nothing
  End Sub
  '保存密码设置
  Sub PassSave()
		     Dim Oldpassword:Oldpassword=KS.R(KS.S("Oldpassword"))
			 Dim NewPassWord:NewPassWord=KS.R(KS.S("NewPassWord"))
			 Dim ReNewPassWord:ReNewPassWord=KS.S("ReNewPassWord")
			 Dim IsApi:IsApi=KS.ChkClng(KSUser.GetUserInfo("isapi"))
			 If Oldpassword = "" and IsApi<>1 Then
				 Response.Write("<script>$.dialog.tips('请输入旧登录密码!',1,'error.gif',function(){history.back();});</script>")
				 Response.End
              End IF
			 If NewPassWord = "" Then
				 Response.Write("<script>$.dialog.tips('请输入登录密码!',1,'error.gif',function(){history.back();});</script>")
				 Response.End
			 ElseIF ReNewPassWord="" Then
				 Response.Write("<script>$.dialog.tips('请输入确认密码',1,'error.gif',function(){history.back();});</script>")
				 Response.End
			 ElseIF NewPassWord<>ReNewPassWord Then
				 Response.Write("<script>$.dialog.tips('两次输入的密码不一致',1,'error.gif',function(){history.back();});</script>")
				 Response.End
			 End If
			 
			 OldPassWord =MD5(OldPassWord,16)
			 NewPassWord =MD5(NewPassWord,16)
			 
			 Dim SQLStr
			 If IsApi=1 Then
			   SQLStr= "Select PassWord,isApi From KS_User Where UserName='" & KSUser.UserName & "'"
			 Else
			   SQLStr= "Select PassWord,isApi From KS_User Where UserName='" & KSUser.UserName & "' And PassWord='" & OldPassWord & "'"
			 End If
			 
             Dim RS:Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open SQLStr,Conn,1,3
			  IF RS.Eof And RS.Bof Then
			  	 Response.Write("<script>$.dialog.tips('您输入的旧密码有误！',1,'error.gif',function(){history.back();});</script>")
				 Response.End
			  Else
			  	'-----------------------------------------------------------------
				'系统整合
				'-----------------------------------------------------------------
				Dim API_KS,API_SaveCookie,SysKey
				If API_Enable Then
					Set API_KS = New API_Conformity
					API_KS.NodeValue "action","update",0,False
					API_KS.NodeValue "username",KSUser.UserName,1,False
					Md5OLD = 1
					SysKey = Md5(API_KS.XmlNode("username") & API_ConformKey,16)
					Md5OLD = 0
					API_KS.NodeValue "syskey",SysKey,0,False
					API_KS.NodeValue "password",KS.R(KS.S("NewPassWord")),1,False
					API_KS.SendHttpData
					If API_KS.Status = "1" Then
						Response.Write "<script>alert('" &  API_KS.Message  & "');</script>"
						Exit Sub
					End If
					Set API_KS = Nothing
				End If
				'-----------------------------------------------------------------

			  
			     RS(0)=NewPassWord
				 If IsApi=1 Then
				  RS(1)=2
				 End If
				 RS.Update
				 Response.Cookies(KS.SiteSn)("PassWord") = NewPassWord
				 Session(KS.SiteSN&"UserInfo")=""
			  End if
			  
			 RS.Close:Set RS=Nothing
  %>
          <table class="border" cellspacing="1" cellpadding="2" width="98%" align="center" border="0">
            <tbody>
			  <tr class="title">
			   <td height="25" align=center>密码修改成功</td>
		      </tr>
              <tr class="tdbg">
                <td height="42" align="center">您的会员登录密码修改成功！新密码 <font color="red"><%=KS.R(KS.S("NewPassWord"))%></font> 请牢记。 </td>
              </tr>
              <tr class="tdbg">
                <td height="42" align="center"><input type="button" onClick="location.href='index.asp'" class="button" value="进入会员首页">&nbsp;&nbsp;<input type="button" onClick="top.location.href='userlogout.asp'" value="退出重新登录" class="button"></td>
              </tr>
            </tbody>
          </table>
          <%
  End Sub
  '提示问题保存
  Sub PassQuestionSave()
				 Dim PassWord:PassWord=KS.S("PassWord")
				 Dim Question:Question=KS.S("Question")
				 Dim Answer:Answer=KS.S("Answer")
				
                 PassWord=MD5(PassWord,16)
              Dim RS: Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select * From KS_User Where UserName='" & KSUser.UserName & "' And PassWord='" & PassWord & "'",Conn,1,3
			  IF RS.Eof And RS.Bof Then
				rs.close:set rs=nothing
				Response.Write "<script>$.dialog.tips('您输入的登录密码不正确!',1,'error.gif',function(){history.back();});</script>"
				Exit Sub
			  Else
			     RS("Question")=Question
				 RS("Answer")=Answer
		 		 RS.Update
				 RS.Close:Set RS=Nothing
				 Response.Write "<script>$.dialog.tips('你的密码找回资料修改成功！',1,'success.gif',function(){location.href='" & Request.ServerVariables("Http_referer") &"';});</script>"
				 Response.End()
			  End if
			
  End Sub
End Class
%> 
