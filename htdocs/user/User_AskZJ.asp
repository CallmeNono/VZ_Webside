<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.UpFileCls.asp"-->
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
		Select Case KS.S("Action")
		  Case "BasicInfoSave"
		   Call BasicInfoSave()
		  Case Else
	       Call KSUser.InnerLocation("申请问答专家认证")
		   Call EditBasicInfo()
		End Select
	   End Sub
	   
	  
	   
	   '基本信息
	   Sub EditBasicInfo()
	     Dim RealName,Province,City,birthday,qq,msn,Tel,DanWei,SCFL,Intro,IDCard,TypeName,HasApply,Status,UserFace,Ryz,sex,BigClassID,SmallClassID,SmallerClassID
	     dim rs:set rs=server.createobject("adodb.recordset")
		 rs.open "select top 1 * from ks_askzj where userid=" & KSUser.GetUserInfo("userid"),conn,1,1
		 If not RS.Eof Then
		   RealName = RS("RealName")
		   Birthday = RS("Birthday")
		   QQ       = RS("qq")
		   Msn      = RS("Msn")
		   UserFace = RS("UserFace")
		   Tel      = RS("Tel")
		   DanWei   = RS("DanWei")
		   SCFL     = RS("SCFL")
		   Intro    = RS("Intro")
		   IDCard   = RS("IDCard")
		   TypeName = RS("TypeName")
		   status   = RS("Status")
		   UserFace = RS("UserFace")
		   IDCard   = RS("IDCard")
		   RYZ      = RS("RYZ")
		   sex      = RS("Sex")
		   Province = RS("Province")
		   City     = RS("City")
		   BigClassID = RS("BigClassID")
		   SmallClassID=RS("SmallClassID")
		   SmallerClassID=RS("SmallerClassID")
		   HasApply=true
		 Else
		   HasApply=false
		   BigClassID=SmallClassID=SmallerClassID=0
		   RealName=KSUser.GetUserInfo("realname")
		   birthday=KSUser.GetUserInfo("Birthday")
		   Province=KSUser.GetUserInfo("Province")
		   City    =KSUser.GetUserInfo("City")
		   QQ=KSUser.GetUserInfo("qq")
		   MSN=KSUser.GetUserInfo("msn")
		   Tel=KSUser.GetUserInfo("officetel")
		   'IDCard=KSUser.GetUserInfo("IDCard")
		   SEX=KSUser.GetUserInfo("sex")
		 End If
		 If Request("t")<>"" Then TypeName=KS.S("t")
		 If KS.IsNul(UserFace) Then
		   IF KSUser.GetUserInfo("sex")="男" Then
		     UserFace="/images/face/boy.jpg"
		   Else
		      UserFace="/images/face/girl.jpg"
		   End If
		 End If
		 RS.Close
		 Set RS=Nothing
		  %>
          <script type="text/javascript">
      function CheckForm() 
		{ 

			if (document.myform.RealName.value =="")
			{
			alert("请填写您的真实姓名！");
			document.myform.RealName.focus();
			return false;
			}
			if (document.myform.birthday.value =="")
			{
			alert("请输入您的出生年月！");
			document.myform.birthday.focus();
			return false;
			}
			if (document.myform.Tel.value =="")
			{
			alert("请输入您的联系电话！");
			document.myform.Tel.focus();
			return false;
			}
			if (document.myform.SCFL.value =="")
			{
			alert("请输入您的擅长分类！");
			document.myform.SCFL.focus();
			return false;
			}
		  return true;	
		}
    </script>
	  <style type="text/css">
	   .typelist{margin-top:10px}
	   .typelist ul{}
	   .typelist ul li{width:160px;float:left;border:1px dashed #ccc;margin:2px;padding:2px;text-align:center}
	   .typelist ul li a{font-weight:Bold}
	   .typelist ul li a.curr{color:#ff6600}
	  </style>
	    <%
		If Not KS.IsNul(KS.ASetting(48)) Then
			 TypeArr=Split(KS.ASetting(48),vbcrlf)
			  response.write "<div class=""typelist""><ul>"
			 for ii=0 to Ubound(TypeArr)
					 IF Trim(TypeName)=Trim(TypeArr(ii)) Then
							   response.write "<li><a href='?t=" & typeArr(ii) & "' class='curr'>申请认证" & typeArr(ii) & "</a></li>"
					 Else
							   response.write "<li><a href='?t=" & typeArr(ii) & "'>申请认证" & typeArr(ii) & "</a></li>"
					 End If
			 next
			 response.write "</ul></div>"
		 End If
		%>
		<div class="clear"></div>
	 	<div  class="tabs">						  
			<ul>
				<li class='puton'><a href="#">申请问答专家认证</a></li>
			</ul>
		</div>

          <%
		  if HasApply=true and status<>"1"Then
		  %>
		  <div style="line-height:26px;padding:20px;font-size:14px;">亲爱的<font color=red><%=KSUser.UserName%></font>,<br/>您已提交过问答专家认证申请， 但还没有经过本站管理员审核，请耐心等待审核。<br/>在未通过审核前您可以<input type='button' value='点此' onclick="$('#shows').toggle();" class="button" />完善修改以下资料！
		  </div>
		   
		  <%elseif HasApply=true and status="1" then%>
		  
		  <div style="margin-top:16px;height:40px;font-size:14px;font-weight:bold;color:blue;text-align:center">恭喜，您已通过问答专家认证审核，以下是您提供的资料,如需修改请电话联系本站管理员！
		  </div>
		  <table cellspacing="1" cellpadding="1"  width="98%" align="center" border="0">
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>问答分类：</td>
                            <td colspan="3">
							<%dim rsc
							  if bigclassid<>0 then
							   set rsc=conn.execute("select top 1 classname from ks_askclass where classid=" & bigclassid)
							   if not rsc.eof then
							    response.write rsc(0)
							   end if
							   rsc.close
							  end if
							  if smallclassid<>0 then
							   set rsc=conn.execute("select top 1 classname from ks_askclass where classid=" & smallclassid)
							   if not rsc.eof then
							    response.write rsc(0)
							   end if
							   rsc.close
							  end if
							  if smallerclassid<>0 then
							   set rsc=conn.execute("select top 1 classname from ks_askclass where classid=" & smallerclassid)
							   if not rsc.eof then
							    response.write rsc(0)
							   end if
							   rsc.close
							  end if
							%>
							</td>
						 </tr>
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>真实姓名：</td>
                            <td><%=RealName%></td>
                            <td  class="clefttitle" style='text-align:right'>出生年月：</td>
                            <td> <%=Birthday%></td>
						 </tr>
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>QQ号码：</td>
                            <td><%=QQ%>
                              </td>
                            <td  class="clefttitle" style='text-align:right'>MSN：</td>
                            <td> <%=MSN%></td>
						 </tr>
                         
						 <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>电话/手机：</td>
                            <td><%=Tel%></td>
                            <td  class="clefttitle" style='text-align:right'>城市：</td>
                            <td> <%=province%><%=City%></td>
						 </tr>
						 <tr class="tdbg">
						    <td  class="clefttitle" style='text-align:right'>擅长分类：</td>
                            <td><%=SCFL%> </td>
							<td  class="clefttitle" style='text-align:right'>性别：</td>
                            <td> <%=sex%></td>
                          </tr>
                          
                          <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>所在单位：</td>
                            <td><%=DanWei%></td>
							<td  class="clefttitle" style='text-align:right'>认证分类：</td>
                            <td><%=TypeName%>
                            </td>
                          </tr>
						  
						  <tr class="tdbg">
						    <td  class="clefttitle" style='text-align:right'>身 份 证：</td>
                            <td><%if Not KS.IsNul(IDCard) Then
							 response.write "已上传,<a style='color:red' href='" & IDCard &"' target='_blank'>浏览</a>"
							end if%>
                            </td>
							<td  class="clefttitle" style='text-align:right'>执 业 证：</td>
                            <td><%if Not KS.IsNul(RYZ) Then
							 response.write "已上传,<a style='color:red' href='" & RYZ &"' target='_blank'>浏览</a>"
							end if%>
                            </td>
                          </tr>
						  
                          <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>个人简介：</td>
                            <td colspan=3><%= Intro%></td>
                          </tr>
						  <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>个人照片：</td>
                            <td  colspan=3 id="newPreview">
							<img src="<%=UserFace%>" width="80" height="80"/>
                             </td>
							
						 </tr>
                         
            </table>
		  
		  
		 <%end if%>
		 <%if status<>"1" then%>
          <table  id='shows' <%if HasApply=true and status<>"1" Then response.write " style='display:none'"%>  cellspacing="1" cellpadding="3"  width="98%" align="center" border="0">
					  <form action="?Action=BasicInfoSave" method="post" name="myform" id="myform" enctype="multipart/form-data" onSubmit="return CheckForm();">
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'><span style="color: red">* </span> 真实姓名：</td>
                            <td><input name="RealName" class="textbox" type="text" id="RealName" value="<%=RealName%>" size="30" maxlength="50" /></td>
                            <td  class="clefttitle" style='text-align:right'><span style="color: red">* </span> 出生年月：</td>
                            <td> <%
							    if isdate(birthday) then birthday=formatdatetime(birthday,2)
								%><input type="text" name="birthday" id="birthday" class="textbox" value="<%=Birthday%>"/></td>
						 </tr>
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>QQ号码：</td>
                            <td><input name="QQ" class="textbox" type="text" id="QQ" value="<%=QQ%>" size="30" maxlength="50" />
                              </td>
                            <td  class="clefttitle" style='text-align:right'>MSN：</td>
                            <td> <input type="text" name="msn" class="textbox" value="<%=MSN%>"/></td>
						 </tr>
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>性别：</td>
                            <td colspan=3><input name="Sex" type="radio" value="男" <% if Sex="男" then response.write " checked"%>/>男  <input name="Sex" type="radio" value="女" <% if Sex="女" then response.write " checked"%>/>女
                              </td>
						 </tr>
                         <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>上传照片：</td>
                            <td style='text-align:left' colspan="3">
							  <table border="0" width="100%" cellpadding="0" cellspacing="0">
							   <tr>
							    <td id="newPreview" width="100" style="text-align:center">
							     <img src="<%=UserFace%>" width="80" height="80"/>
							    </td>
                                <td>
							 <script type="text/javascript" language="javascript">
								<!--
								function PreviewImg(imgFile){
								    $("#newPreview").html('');
									var newPreview = document.getElementById("newPreview");    
									var imgDiv = document.createElement("div");
									document.body.appendChild(imgDiv);
									imgDiv.style.width = "80px";    imgDiv.style.height = "80px";
									imgDiv.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod = scale)";   
									imgDiv.filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src = imgFile.value;
									newPreview.appendChild(imgDiv);    
									newPreview.style.width = "100px";
									newPreview.style.height = "100px";
								}
								-->
								</script>

							 	<input type="file" name="photourl1" size="40" onchange="javascript:PreviewImg(this);"  class="textbox">
							<br>
							<span class="msgtips">注意事项：上传头像请为真实照片，大小不超过100k,且为gif、jpg或png格式，<br/>
							推荐上传150*150的头像。</span>
							</td>
						  </tr>
						 </table>
							
							 </td>
                           
						 </tr>
						 <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'><span style="color: red">* </span>电话/手机：</td>
                            <td><input name="Tel" class="textbox" type="text" id="Tel" value="<%=Tel%>" size="30" maxlength="50" />
                              </td>
                            <td  class="clefttitle" style='text-align:right'>城市：</td>
                            <td> <script src="../plus/area.asp" language="javascript"></script>
							<script language="javascript">
							  <%if Province<>"" then%>
							  $('#Province').val('<%=province%>');
								  <%end if%>
							  <%if City<>"" Then%>
							  $('#City')[0].options[1]=new Option('<%=City%>','<%=City%>');
							  $('#City')[0].options(1).selected=true;
							  <%end if%>
							</script></td>
						 </tr>
						 <tr class="tdbg">
						    <td  class="clefttitle" style='text-align:right'><span style="color: red">* </span>擅长分类：</td>
                            <td><input name="SCFL" class="textbox" type="text" id="SCFL" value="<%=SCFL%>" size="20" maxlength="50" /><span class="msgtips">如：内分泌科、消化内科等。</span>
                            </td>
							<td class="clefttitle" style='text-align:right'>问答分类：</td>
							<td><script src="../<%=KS.ASetting(1)%>category.asp?classid=<%=BigClassID%>&smallclassid=<%=SmallClassID%>&SmallerClassID=<%=SmallerClassID%>" language="javascript"></script>
							
							</td>
                          </tr>
                          
                          
                          <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>所在单位：</td>
                            <td><input name="DanWei" class="textbox" type="text" id="DanWei" value="<%=DanWei%>" size="30" maxlength="50" /></td>
							<%If Not KS.IsNul(KS.ASetting(48)) Then%>
							<td  class="clefttitle" style='text-align:right'>认证分类：</td>
                            <td><select name="TypeName">
							<option value='0'>--选择认证分类--</option>
							<%
							 dim ii,TypeArr
							 If Not KS.IsNul(KS.ASetting(48)) Then
							 TypeArr=Split(KS.ASetting(48),vbcrlf)
							 for ii=0 to Ubound(TypeArr)
							   IF Trim(TypeName)=Trim(TypeArr(ii)) Then
							   response.write "<option selected>" & typeArr(ii) & "</option>"
							   Else
							   response.write "<option>" & typeArr(ii) & "</option>"
							   End If
							 next
							 End If
							%>
							</select>
                            </td>
							<%end if%>
                          </tr>
						  
						  <tr class="tdbg">
						    <td  class="clefttitle" style='text-align:right'>上传身份证：</td>
                            <td colspan=3><input name="Photo2" class="textbox" type="file" id="Photo2" size=40 /> <span style="color: red">* </span><%if Not KS.IsNul(IDCard) Then
							 response.write "已上传,<a style='color:red' href='" & IDCard &"' target='_blank'>浏览</a>"
							end if%>
                            </td>
                          </tr>
						  <tr class="tdbg">
						    <td  class="clefttitle" style='text-align:right'>上传执业证：</td>
                            <td colspan=3><input name="Photo3" class="textbox" type="file" id="Photo3" size=40 /> <span style="color: red">* </span> <%if Not KS.IsNul(RYZ) Then
							 response.write "已上传,<a style='color:red' href='" & RYZ &"' target='_blank'>浏览</a>"
							end if%>
                            </td>
                          </tr>
						  
						  
						  
                          <tr class="tdbg">
                            <td  class="clefttitle" style='text-align:right'>个人简介：</td>
                            <td colspan=3><textarea name="Intro" class="textbox" cols="80" rows="7" id="Intro" style="width:500px; height:80px"><%= Intro%></textarea></td>
                          </tr>
                          <tr class="tdbg">
						    <td  class="clefttitle"></td>
                            <td colspan=3><button type="submit"  class="pn"><strong>OK,请交申请</strong></button></td>
                          </tr>
		    </form>
            </table>
	<%end if%>
          <%
  End Sub
  
  Sub BasicInfoSave()
            Dim fobj:Set FObj = New UpFileClass
		    FObj.GetData
            Dim MaxFileSize:MaxFileSize = 500   '设定文件上传最大字节数
			Dim AllowFileExtStr:AllowFileExtStr = "gif|jpg|png"
			Dim FormPath:FormPath =KS.ReturnChannelUserUpFilesDir(999,KSUser.GetUserInfo("Userid"))
			Call KS.CreateListFolder(FormPath) 
			Dim ReturnValue:ReturnValue = FObj.UpSave(FormPath,MaxFileSize,AllowFileExtStr,"askrz")
			Select Case ReturnValue
			  Case "errext" Call KS.AlertHistory("文件上传失败,文件类型不允许\n允许的类型有" + AllowFileExtStr + "\n",-1):response.end
	          Case "errsize"  Call KS.AlertHistory("文件上传失败,文件超过允许上传的大小\n允许上传 " & MaxFileSize & " KB的文件\n",-1):response.End()
			End Select
			
 
			 Dim RealName:RealName=KS.DelSql(Fobj.Form("RealName"))
			 Dim Birthday:Birthday=KS.DelSql(Fobj.Form("Birthday"))
			 Dim QQ:QQ=KS.DelSql(Fobj.Form("QQ"))
			 Dim MSN:MSN=KS.DelSql(Fobj.Form("MSN"))
			 Dim Intro:Intro=KS.DelSql(Fobj.Form("Intro"))
			 Dim Tel:Tel=KS.DelSql(Fobj.Form("Tel"))
			 Dim Province:Province=KS.DelSql(Fobj.Form("Province"))
			 Dim City:City=KS.DelSql(Fobj.Form("City"))
			 Dim SCFL:SCFL=KS.DelSql(Fobj.Form("SCFL"))
			 Dim DanWei:DanWei=KS.DelSql(Fobj.Form("DanWei"))
			 Dim Sex:Sex=KS.DelSql(Fobj.Form("Sex"))
			 Dim TypeName:TypeName=KS.DelSql(Fobj.Form("TypeName"))
			 Dim ClassID:ClassID=KS.ChkClng(Fobj.Form("ClassID"))
			 Dim SmallClassID:SmallClassID=KS.ChkCLng(Fobj.Form("smallclassid"))
			 Dim SmallerClassID:SmallerClassID=KS.ChkCLng(Fobj.Form("SmallerClassID"))

            Dim RS: Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select top 1 * From KS_ASKZJ Where UserName='" & KSUser.UserName & "'",Conn,1,3
			  IF RS.Eof And RS.Bof Then
				 RS.AddNew
				 RS("AddDate")=Now
				 RS("Status")=0
				 RS("UserName")=KSUser.UserName
				 RS("UserID")=KSUser.GetUserInfo("UserID")
			  End If
				 RS("RealName")=RealName
				 RS("Birthday")=Birthday
				 RS("BigClassID")=ClassID
				 RS("SmallClassID")=SmallClassID
				 RS("SmallerClassID")=SmallerClassID
				 RS("qq")=qq
				 RS("Msn")=Msn
				 RS("Sex")=Sex
				 RS("Tel")=Tel
				 RS("Province")=Province
				 RS("City")=City
				 RS("SCFL")=SCFL
				 RS("DanWei")=DanWei
				 If Not KS.IsNul(ReturnValue) Then
				    Dim PArr:PArr=Split(ReturnValue,"|")
					If Parr(0)<>"" Then
					  RS("UserFace")=Parr(0)
					End If
					If Parr(1)<>"" Then
					  RS("IDCard")=Parr(1)
					End If
					If Parr(2)<>"" Then
					  RS("RYZ")=Parr(2)
					End If
				 End If
				 
				 RS("TypeName")=TypeName
				 RS("Intro")=Intro
		 		 RS.Update
				 RS.Close:Set RS=Nothing
				
				 Response.Write "<script>alert('恭喜，您的申请已提交成功！');location.href='" & Request.ServerVariables("Http_referer") & "';</script>"
				 Response.End()
			
  End Sub
  

End Class
%> 
