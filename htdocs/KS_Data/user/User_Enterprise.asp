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
Set KSCls = New User_EditInfo
KSCls.Kesion()
Set KSCls = Nothing

Class User_EditInfo
        Private KS,KSUser
		Private FieldsXml,Action
		Private Sub Class_Initialize()
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
		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		Action=Request("action")
		Call KSUser.Head()
		%>
		<script src="../ks_inc/kesion.box.js" language="JavaScript"></script>

		<div class="tabs">	
			<ul>
			<li><a href="User_EditInfo.asp">基本信息</a></li>
			<li><a href="User_EditInfo.asp?Action=face">个人头像</a></li>
			<li><a href="User_EditInfo.asp?Action=ContactInfo">个人详细资料</a></li>
			<li><a href="User_EditInfo.asp?Action=PassInfo">密码设置</a></li>
	        <li<%if action=""  or action="job" then response.write " class='puton'"%>><a href="user_enterprise.asp">企业基本资料 </a></li>
	        <li<%if action="intro" then response.write " class='puton'"%>><a href="?action=intro">企业简介</a></li>
			<%if action="job" then
			 if KS.C_S(10,21)="0" then response.write "<li class='puton'><a href='?action=job'>企业招聘</a></li>"
			end if%>
				<li style="width:80px" <%If KS.S("Action")="permissions" then response.write " class='puton'"%>><a href="User_EditInfo.asp?Action=permissions">我的权限</a></li>
			</ul>
			
		</div>

		<%
		Dim HasEnterprise:HasEnterprise=Not Conn.execute("select top 1 id from KS_Enterprise where username='" & KSUser.UserName & "'").eof
		Set FieldsXml=LFCls.GetXMLFromFile("SpaceFields")
		Select Case KS.S("Action")
		  Case "BasicInfoSave"
		   Call BasicInfoSave()
		  Case "intro"
		   If (HasEnterprise) then
	        Call KSUser.InnerLocation("企业简介")
		    Call Intro()
		   Else
		    Response.Write "<script>alert('对不起，你还没有填写企业基本信息!')</script>"
	       Call KSUser.InnerLocation("企业基本信息")
		   Call EditBasicInfo()
		   End If
		  case "IntroSave"
		   Call IntroSave()
		  Case "job"
		   If (HasEnterprise) then
	        Call KSUser.InnerLocation("企业招聘")
			If KS.C_S(10,21)="1" Then
			 Response.Redirect("User_JobCompanyZW.asp")
			Else
		    Call Job()
			End If
		   Else
		    Response.Write "<script>alert('对不起，你还没有填写企业基本信息!')</script>"
	       Call KSUser.InnerLocation("企业基本信息")
		   Call EditBasicInfo()
		   End If
		  Case "JobSave"
		   Call JobSave()
		  Case Else
	       Call KSUser.InnerLocation("企业基本信息")
		   Call EditBasicInfo()
		End Select
	   End Sub
	   
	   '基本信息
	   Sub EditBasicInfo()
		   %>
      <script>
       function CheckForm() 
		{ 
			
			if (document.myform.CompanyName.value =="")
			{
			 $.dialog.alert("请填写公司名称！",function(){
			document.myform.CompanyName.focus();
			});
			return false;
			}
			if (document.myform.LegalPeople.value =="")
			{
			$.dialog.alert("请填写企业法人！",function(){
			document.myform.LegalPeople.focus();
			});
			return false;
			}
			if (document.myform.TelPhone.value =="")
			{
			 $.dialog.alert("请输入联系电话！",function(){
			document.myform.TelPhone.focus();
			});
			return false;
			}
		  return true;	
		}
		
    </script>
	<%	   

	 Dim CompanyName,Province,City,Address,ZipCode,ContactMan,Telphone,Fax,WebUrl,Profession,CompanyScale,RegisteredCapital,LegalPeople,BankAccount,AccountNumber,BusinessLicense,Intro,flag,ClassID,SmallClassID,qq,mobile,Email,MapMarker,Business,Foundation,isrz
	 Dim RS:Set RS=Server.CreateObject("ADODB.RECORDSET")
	 RS.Open "Select top 1 * From KS_Enterprise where username='" & KSUser.UserName & "'",conn,1,1
	 IF Not RS.Eof Then
	   CompanyName=RS("CompanyName")
	   Province=RS("Province")
	   City=RS("City")
	   Address=RS("Address")
	   ZipCode=RS("ZipCode")
	   ContactMan=RS("ContactMan")
	   Telphone=RS("TelPhone")
	   Fax=RS("Fax")
	   WebUrl=RS("WebUrl")
	   Profession=RS("Profession")
	   CompanyScale=RS("CompanyScale")
	   RegisteredCapital=RS("RegisteredCapital")
	   LegalPeople=RS("LegalPeople")
	   BankAccount=RS("BankAccount")
	   AccountNumber=RS("AccountNumber")
	   BusinessLicense=RS("BusinessLicense")
	   ClassID=RS("ClassID")
	   SmallClassID=RS("SmallClassID")
	   qq=rs("qq")
	   MapMarker=rs("MapMarker")
	   Email=rs("Email")
	   mobile=rs("mobile")
	   Business=rs("Business")
	   Foundation=rs("Foundation")
	   isrz=ks.chkclng(rs("isrz"))
	   flag=true
	 Else
	   flag=false : isrz=0
	    if KS.SSetting(17)<>"" then
	    if KS.FoundInArr(KS.SSetting(17),KSUser.groupid,",")=false then  Set KSUser=Nothing:call KS.AlertHistory("对不起，你所在的用户组没有权利升级为企业空间！",-1):exit sub
	   end if
	   If IsObject(FieldsXml) Then
	     on error resume next
	     Dim objNode,i,j,objAtr
	     Set objNode=FieldsXml.documentElement 
		 For i=0 to objNode.ChildNodes.length-1 
				set objAtr=objNode.ChildNodes.item(i) 
				' response.write objAtr.Attributes.item(0).Text&"=" &objAtr.Attributes.item(1).Text & " <br>" 
				 Execute(objAtr.Attributes.item(0).Text&"=""" & LFCls.GetSingleFieldValue("select " & objAtr.Attributes.item(1).Text & " From KS_User Where UserName='" & KSUser.UserName & "'") & """") 
		 Next

	   End If
	   
	 End If
	 If ClassID="" or isnull(ClassID) Then  ClassID=0
	 If SmallClassID="" or isnull(ClassID) Then SmallClassID=0

    RS.Close:Set RS=Nothing	
	%>
          <table  cellspacing="1" cellpadding="3"  width="98%" align="center" border="0" class="border">
					  <form action="?Action=BasicInfoSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
					      <input type="hidden" value="<%=KS.S("ComeUrl")%>" name="ComeUrl">
						  <%if isrz=1 then%>
						  <tr class="tdbg">
                            <td class="title" colspan="2">贵公司已经过本站实名认证，以下公司基本资料不能修改，您可以<a href="../company/rz.asp?userid=<%=ksuser.getuserinfo("userid")%>" target="_blank" style="color:#FF0000">点此查看</a>认证页面。</td>
                          </tr>
						  <tr class="tdbg">
                            <td class="clefttitle">公司名称：</td>
                            <td><input name="CompanyName" type="hidden" class="textbox" id="CompanyName" value="<%=CompanyName%>" size="30" maxlength="200" /><%=CompanyName%></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">营业热照：</td>
                            <td><input name="BusinessLicense" class="textbox" type="hidden" id="BusinessLicense" value="<%=BusinessLicense%>" size="30" maxlength="50" /> <%=BusinessLicense%></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">企业法人：</td>
                            <td><input name="LegalPeople" class="textbox" type="hidden" id="LegalPeople" value="<%=LegalPeople%>" size="30" maxlength="50" /><%=LegalPeople%></td>
                          </tr>	
                        <tr class="tdbg">
                            <td class="clefttitle">公司地址：</td>
                            <td><input name="Address" class="textbox" type="hidden" id="Adress" value="<%=Address%>" size="30" maxlength="50" /><%=Address%></td>
                          </tr>	
                         <tr class="tdbg">
                            <td class="clefttitle">注册资金：</td>
                            <td>
							<input type="hidden" name="RegisteredCapital" id="RegisteredCapital" value="<%=RegisteredCapital%>" class="textbox"/><%=RegisteredCapital%></td>
                          </tr>		
                         <tr class="tdbg">
                            <td class="clefttitle">经营范围：</td>
                            <td>
							<textarea name="Business" id="Business" class="textbox" style="display:none;width:300px;height:60px"><%=Business%></textarea><span class="msgtips"><%=Business%></span>	
							 </td>
                          </tr>		
						  <tr class="tdbg">
                            <td class="clefttitle">成立日期：</td>
                            <td>
							<input type="hidden" name="Foundation" id="Foundation" value="<%=Foundation%>" class="textbox"/>
							<%=Foundation%></td>
                          </tr>
						  <tr class="tdbg">
                            <td class="title" colspan="2">贵公司已经过本站实名认证，请如实完善以下信息</td>
                          </tr>
						  <%else%>
                          <tr class="tdbg">
                            <td class="clefttitle">公司名称：</td>
                            <td><input name="CompanyName" type="text" class="textbox" id="CompanyName" value="<%=CompanyName%>" size="30" maxlength="200" />
                                <span style="color: red">* </span> <span class="msgtips">请填写你在工商局注册登记的名称。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">营业热照：</td>
                            <td><input name="BusinessLicense" class="textbox" type="text" id="BusinessLicense" value="<%=BusinessLicense%>" size="30" maxlength="50" /> <span class="msgtips">填写营业执照号码。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">企业法人：</td>
                            <td><input name="LegalPeople" class="textbox" type="text" id="LegalPeople" value="<%=LegalPeople%>" size="30" maxlength="50" />
                            <span style="color: red">* </span> <span class="msgtips">填写公司的法人或是主要负责人。</span></td>
                          </tr>	
                        <tr class="tdbg">
                            <td class="clefttitle">公司地址：</td>
                            <td><input name="Address" class="textbox" type="text" id="Adress" value="<%=Address%>" size="30" maxlength="50" /> <span class="msgtips">填写营业执照上注册的地址</span></td>
                          </tr>	
                         <tr class="tdbg">
                            <td class="clefttitle">注册资金：</td>
                            <td>
							<input type="text" name="RegisteredCapital" id="RegisteredCapital" value="<%=RegisteredCapital%>" class="textbox"/>
							 <span class="msgtips">请选择输入贵公司的注册资金，如100万元。</span></td>
                          </tr>		
                         <tr class="tdbg">
                            <td class="clefttitle">经营范围：</td>
                            <td>
							<textarea name="Business" id="Business" class="textbox" style="width:300px;height:60px"><%=Business%></textarea><span class="msgtips">请填写营业执照上的经营范围</span>	
							 </td>
                          </tr>		
						  <tr class="tdbg">
                            <td class="clefttitle">成立日期：</td>
                            <td>
							<input type="text" name="Foundation" id="Foundation" value="<%=Foundation%>" class="textbox"/>
							<span class="msgtips">请填写营业执照上的成立日期</span></td>
                          </tr>
						<%end if%>  				  					  					  


					  
                         <tr class="tdbg">
                            <td class="clefttitle">公司行业：</td>
                            <td><%
		dim rss,sqls,count
		set rss=server.createobject("adodb.recordset")
		sqls = "select * from KS_enterpriseClass Where parentid<>0 order by orderid"
		rss.open sqls,conn,1,1
		%>
          <script language = "JavaScript">
		var onecount;
		subcat = new Array();
				<%
				count = 0
				do while not rss.eof 
				%>
		subcat[<%=count%>] = new Array("<%= trim(rss("id"))%>","<%=trim(rss("parentid"))%>","<%= trim(rss("classname"))%>");
				<%
				count = count + 1
				rss.movenext
				loop
				rss.close
				%>
		onecount=<%=count%>;
		function changelocation(locationid)
			{
			document.myform.SmallClassID.length = 0; 
			for (var i=0;i < onecount; i++)
				{ 
					if (parseInt(subcat[i][1]) == parseInt(locationid))
					{ 			
						document.myform.SmallClassID.options[document.myform.SmallClassID.length] = new Option(subcat[i][2], subcat[i][0]);
					}        
				}
			}    
		
		</script>
		  <select class="select" name="ClassID" onChange="changelocation(document.myform.ClassID.options[document.myform.ClassID.selectedIndex].value)" size="1">
		  <option value='0'>--请选择行业--</option>
		<% 
		dim rsb,sqlb
		set rsb=server.createobject("adodb.recordset")
        sqlb = "select * from ks_enterpriseClass where parentid=0 order by orderid"
        rsb.open sqlb,conn,1,1
		if rsb.eof and rsb.bof then
		else
		    Dim N
		    do while not rsb.eof
			          N=N+1
					  If N=1 and flag=false Then ClassID=rsb("id")
					  If ClassID=rsb("id") then
					  %>
                    <option value="<%=trim(rsb("id"))%>" selected><%=trim(rsb("ClassName"))%></option>
                    <%else%>
                    <option value="<%=trim(rsb("id"))%>"><%=trim(rsb("ClassName"))%></option>
                    <%end if
		        rsb.movenext
    	    loop
		end if
        rsb.close
			%>
                  </select>
                  <font color=#ff6600>&nbsp;*</font>
                  <select class="select" name="SmallClassID">
				  <option value='0'>--请选择分类--</option>
                    <%dim rsss,sqlss
						set rsss=server.createobject("adodb.recordset")
						sqlss="select * from ks_enterpriseclass where parentid="&ClassID&" order by orderid"
						rsss.open sqlss,conn,1,1
						if not(rsss.eof and rsss.bof) then
						do while not rsss.eof
							  if SmallClassID=rsss("id") then%>
							<option value="<%=rsss("id")%>" selected><%=rsss("ClassName")%></option>
							<%else%>
							<option value="<%=rsss("id")%>"><%=rsss("ClassName")%></option>
							<%end if
							rsss.movenext
						loop
					end if
					rsss.close
					%>
                </select>
							 <span class="msgtips">填写公司所属的行业。</span> 
							  </td>
                          </tr>
						  
                          
                          <tr class="tdbg">
                            <td class="clefttitle">公司规模：</td>
                            <td><select name="CompanyScale" class="select" id="CompanyScale">
							  <option value="1-20人"<%if CompanyScale="1-20人" then response.write " selected"%>>1-20人</option>
                      <option value="21-50人"<%if CompanyScale="21-50人" then response.write " selected"%>>21-50人</option>
                      <option value="51-100人"<%if CompanyScale="51-100人" then response.write " selected"%>>51-100人</option>
                      <option value="101-200人"<%if CompanyScale="101-200人" then response.write " selected"%>>101-200人</option>
                      <option value="201-500人"<%if CompanyScale="201-500人" then response.write " selected"%>>201-500人</option>
                      <option value="501-1000人"<%if CompanyScale="501-1000人" then response.write " selected"%>>501-1000人</option>
                      <option value="1000人以上"<%if CompanyScale="1000人以上" then response.write " selected"%>>1000人以上</option>
						    </select>
							<span class="msgtips">填选择公司的员工人数</span>
							</td>
                          </tr>
                          
                          <tr class="tdbg">
                            <td class="clefttitle">所在地区：</td>
                            <td>
							<script>try{setCookie("pid",'<%=province%>');}catch(e){}</script>
							<script src="../plus/area.asp" language="javascript"></script>
							<script language="javascript">
							  <%if Province<>"" then%>
							  $('#Province').val('<%=province%>');
							  <%end if%>
							  <%if City<>"" Then%>
							  $('#City').val('<%=City%>');
							  <%end if%>
							</script>
							  <span class="msgtips">选择企业所在的省份和城市。</span>
							  </td>
                          </tr>
						  <tr class="tdbg">
                            <td class="clefttitle">电子地图：</td>
                            <td>经纬度：<input value="<%=MapMarker%>" class="textbox" maxlength="255" type='text' name='MapMark' id='MapMark' /> <a href='javascript:void(0)' onclick='addMap()'> <img src='images/edit_add.gif' align='absmiddle' border='0'>添加电子地图标志</a>
	  <script type="text/javascript">
		   var box='';
		  function addMap(){
		   box=$.dialog({title:'电子地图标注',content:'url:../plus/baidumap.asp?from=user&action=getcenter&MapMark='+escape($('#MapMark').val()),width:'830px',height:'430px'}); }
		  </script><span class="msgtips">请选择贵公司所在的位置。</span>
							  </td>
                          </tr>

                          <tr class="tdbg">
                            <td class="clefttitle">联 系 人：</td>
                            <td><input name="ContactMan" class="textbox" type="text" id="ContactMan" value="<%=ContactMan%>" size="30" maxlength="50" /> <span class="msgtips">请正确填写业务联系人的姓名。</span></td>
                          </tr>
                          
       
                          <tr class="tdbg">
                            <td class="clefttitle">邮政编码：</td>
                            <td><input name="ZipCode" class="textbox" type="text" id="ZipCode" value="<%=ZipCode%>" size="10" maxlength="6" /> <span class="msgtips">请填写邮政编码。</span> </td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> QQ号码：</td>
                            <td><input name="qq" class="textbox" type="text" id="qq" value="<%=qq%>" size="10" maxlength="50" />
                            <span style="color: red">* </span> <span class="msgtips">方便业务联系请填写联系QQ。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> 手机号码：</td>
                            <td><input name="Mobile" class="textbox" type="text" id="Mobile" value="<%=Mobile%>" size="30" maxlength="50" />
                           </td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> 联系电话：</td>
                            <td><input name="TelPhone" class="textbox" type="text" id="TelPhone" value="<%=Telphone%>" size="30" maxlength="50" />
                            <span style="color: red">* </span> <span class="msgtips">带区号,公司办公电话，用于业务联系！</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> 传真号码：</td>
                            <td><input name="Fax" class="textbox" type="text" id="Fax" value="<%=Fax%>" size="30" maxlength="50" /> <span class="msgtips">公司的传真号码。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle"> 电子邮箱：</td>
                            <td><input name="Email" class="textbox" type="text" id="Email" value="<%=Email%>" size="30" maxlength="50" /></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">公司网站：</td>
                            <td><input name="WebUrl" class="textbox" type="text" id="WebUrl" value="<%=WebUrl%>" size="30" maxlength="50" /> <span class="msgtips">填写你公司的网址。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">开户银行：</td>
                            <td><input name="BankAccount" class="textbox" type="text" id="BankAccount" value="<%=BankAccount%>" size="30" maxlength="50" /></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">银行账号：</td>
                            <td><input name="AccountNumber" class="textbox" type="text" id="AccountNumber" value="<%=AccountNumber%>" size="30" maxlength="50" /> <span class="msgtips">公司银行帐户，以方便放在您的联系资料中。</span></td>
                          </tr>
                          <tr class="tdbg">
                            <td class="clefttitle">&nbsp;</td>
                            <td><button class="pn" name="Submit" type="submit"><strong>OK,确 认 保 存</strong></button></td>
                          </tr>
		    </form>
            </table>
          <%
  End Sub
  
  Sub Intro()
  %>
   <table  cellspacing="1" cellpadding="3" width="98%" align="center" border="0">
			<form action="?Action=IntroSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
			<input type="hidden" name="from" value="<%=request("from")%>"/>
               <tr class="tdbg">
                  <td class="msgtips">
				  ·请用中文详细说明贵司的成立历史、主营产品、品牌、服务等优势；<br>
 ·如果内容过于简单或仅填写单纯的产品介绍，将有可能无法通过审核。<br>
·联系方式（电话、传真、手机、电子邮箱等）请在基本资料中填写， 此处请勿重复填写。<br>
                    <%
					Dim Intro:Intro=Conn.Execute("Select Intro From ks_Enterprise where username='" & KSUser.UserName & "'")(0)
					If trim(Intro)="" Or IsNull(Intro) Then
						If IsObject(FieldsXml) Then
						 'on error resume next
						 Dim objNode,i,j,objAtr
						 Set objNode=FieldsXml.documentElement 
						 For i=0 to objNode.ChildNodes.length-1 
								set objAtr=objNode.ChildNodes.item(i)
								If lcase(objAtr.Attributes.item(0).Text)="intro" Then 
								 Intro=LFCls.GetSingleFieldValue("select " & objAtr.Attributes.item(1).Text & " From KS_User Where UserName='" & KSUser.UserName & "'") 
								End If
						 Next
				
					   End If
					End If
					
			        Response.Write "<textarea ID='Intro' name='Intro' style='display:none'>" & KS.HTMLCode(Intro) & "</textarea>"
					%> 
					<script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
					<script type="text/javascript">
                CKEDITOR.replace('Intro', {width:"98%",height:"350px",toolbar:"Simple",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
			    </script>  
					</td>
                          </tr>
						  <tr class="tdbg">
                            <td align="center"><button class="pn" name="Submit" type="submit"><strong>OK,确 认 保 存</strong></button></td>
                          </tr>
				</form>
	</table>
  <%
  End Sub
 
 Sub IntroSave()
  Dim Intro
  Intro = Request.Form("Intro")
  Intro=KS.CheckScript(KS.HtmlCode(Intro))
  Intro=KS.HtmlEncode(Intro)
  IF Intro="" Then
  	 Response.Write "<script>$.dialog.tips('对不起，你没有输入公司简介',1,'error.gif',function(){history.back();});</script>"
	 Response.end
  End If
  If IsObject(FieldsXml) Then
	on error resume next
	Dim objNode,i,j,objAtr
	 Set objNode=FieldsXml.documentElement 
	 For i=0 to objNode.ChildNodes.length-1 
		set objAtr=objNode.ChildNodes.item(i)
		If lcase(objAtr.Attributes.item(0).Text)="intro" Then 
		 Conn.Execute("UPDATE KS_User Set " & objAtr.Attributes.item(1).Text & "='" & replace(Intro,"'","''") & "' Where UserName='" & KSUser.UserName & "'")
		End If
	 Next
				
  End If
  
  If KS.C_S(10,21)="1" Then
  Conn.Execute("Update KS_Job_Company Set Intro='" & replace(Intro,"'","''") &"' WHERE UserName='" & KSUser.UserName & "'")
  End If
  Conn.Execute("Update KS_EnterPrise Set Intro='" & replace(Intro,"'","''") &"' WHERE UserName='" & KSUser.UserName & "'")
  Dim EID:EID=Conn.Execute("Select top 1 ID From KS_Enterprise Where UserName='" & KSUser.UserName & "'")(0)
  Call KS.FileAssociation(1033,EID,Intro,1)
  if request("from")="job" then
  Response.Write "<script>$.dialog.tips('企业简介修改成功!',1,'success.gif',function(){;top.location.href='user_jobcompany.asp';});</script>"
  else
  Response.Write "<script>$.dialog.tips('企业简介修改成功!',1,'success.gif',function(){top.location.href='user_enterprise.asp?action=intro';});</script>"
  end if
 End Sub
 
 
  Sub Job()
  %>
   <table  cellspacing="1" cellpadding="3" width="98%" align="center" border="0">
			<form action="?Action=JobSave" method="post" name="myform" id="myform" onSubmit="return CheckForm();">
               <tr class="title">
                   <td height="22" colspan="2" align="center"> 企 业 招 聘</td>
               </tr>
               <tr class="tdbg">
                  <td>
                    <%
					Response.Write "<textarea ID='Job' name='Job' style='display:none'>" & KS.HTMLCode(Conn.Execute("Select top 1 Job From ks_Enterprise where username='" & KSUser.UserName & "'")(0)) & "</textarea>"

					%>  
<script type="text/javascript" src="../editor/ckeditor.js" mce_src="../editor/ckeditor.js"></script>
					<script type="text/javascript">
                CKEDITOR.replace('Job', {width:"98%",height:"350px",toolbar:"Simple",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
			    </script> 					 
					</td>
                          </tr>
						  <tr class="tdbg">
                            <td align="center"><input  class="button" name="Submit" type="submit"  value=" OK,修 改 " />
                              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input  class="button" name="Submit2" type="reset" value=" 重 填 " />                            </td>
                          </tr>
				</form>
	</table>
  <%
  End Sub
 
 Sub JobSave()
  Dim Job
  Job= Request.Form("Job")
  Job=KS.CheckScript(KS.HtmlCode(Job))
  Job=KS.HtmlEncode(Job)
  IF Job="" Then
  	 Response.Write "<script>alert('对不起，你没有招聘信息');history.back();</script>"
	 Response.end
  End If
  Conn.Execute("Update KS_EnterPrise Set Job='" & Job &"' WHERE UserName='" & KSUser.UserName & "'")
  Response.Write "<script>alert('招聘信息修改成功!');history.back();</script>"
 End Sub
 
  
  Sub BasicInfoSave() 
	   Dim CompanyName:CompanyName=KS.LoseHtml(KS.S("CompanyName"))
	   Dim Province:Province=KS.S("Province")
	   Dim City:City=KS.S("City")
	   Dim Address:Address=KS.LoseHtml(KS.S("Address"))
	   Dim ZipCode:ZipCode=KS.LoseHtml(KS.S("ZipCode"))
	   Dim ContactMan:ContactMan=KS.LoseHtml(KS.S("ContactMan"))
	   Dim QQ:QQ=KS.S("QQ")
	   Dim Mobile:mobile=KS.S("Mobile")
	   Dim Email:Email=KS.S("Email")
	   Dim Telphone:TelPhone=KS.LoseHtml(KS.S("TelPhone"))
	   Dim Fax:Fax=KS.LoseHtml(KS.S("Fax"))
	   Dim WebUrl:WebUrl=KS.LoseHtml(KS.S("WebUrl"))
	   Dim Profession:Profession=KS.LoseHtml(KS.S("Profession"))
	   Dim CompanyScale:CompanyScale=KS.LoseHtml(KS.S("CompanyScale"))
	   Dim RegisteredCapital:RegisteredCapital=KS.LoseHtml(KS.S("RegisteredCapital"))
	   Dim LegalPeople:LegalPeople=KS.LoseHtml(KS.S("LegalPeople"))
	   Dim BankAccount:BankAccount=KS.LoseHtml(KS.S("BankAccount"))
	   Dim AccountNumber:AccountNumber=KS.LoseHtml(KS.S("AccountNumber"))
	   Dim BusinessLicense:BusinessLicense=KS.LoseHtml(KS.S("BusinessLicense"))
	   Dim Business:Business=KS.LoseHtml(KS.S("Business"))
	   Dim Foundation:Foundation=KS.LoseHtml(KS.S("Foundation"))
	   Dim ClassID:ClassID=KS.ChkClng(KS.G("ClassID"))
	   Dim SmallClassID:SmallClassID=KS.ChkClng(KS.G("SmallClassID"))
	   Dim MapMarker:MapMarker=KS.G("MapMark")
	   Dim NewReg:NewReg=false
		
	   If CompanyName="" Then Response.Write "<script>alert('公司名称必须输入');history.back();</script>":response.end

            Dim RS: Set RS=Server.CreateObject("Adodb.RecordSet")
			  RS.Open "Select top 1 * From KS_Enterprise Where UserName='" & KSUser.UserName & "'",Conn,1,3
			  IF RS.Eof And RS.Bof Then
				 RS.AddNew
				 RS("UserName")=KSUser.UserName
				 RS("AddDate")=Now
				 RS("Recommend")=0
				 If KS.ChkClng(KS.SSetting(2))=0 then
				 RS("status")=1
				 Else
				 RS("status")=0
				 End If
				 Dim RSS:Set RSS=Server.CreateObject("ADODB.RECORDSET")
				 RSS.Open "select top 1 * from ks_blog where username='" & KSUser.UserName & "'",conn,1,3
				 if RSS.Eof Then
				      RSS.AddNew
					  RSS("UserID")=KS.ChkClng(KSUser.GetUserInfo("UserID"))
					  RSS("UserName")=KSUser.UserName
					  RSS("ClassID") = KS.ChkClng(Conn.Execute("Select Top 1 ClassID From KS_BlogClass")(0))
					  RSS("Announce")="暂无公告!"
					  RSS("ContentLen")=500
					  RSS("Recommend")=0
				 End If
					  If KS.ChkClng(KS.SSetting(2))=0 then
					  RSS("Status")=1
					  else
					  RSS("Status")=0
					  end if
				  RSS("TemplateID")=KS.ChkClng(Conn.Execute("Select Top 1 ID From KS_BlogTemplate Where flag=4 and IsDefault='true'")(0))
     			  RSS("BlogName")=CompanyName
				  RSS.Update
				  RSS.Close
				  Set RSS=Nothing
				  NewReg=true
				 
			  End If
			 
			   If KS.ChkClng(RS("IsRz"))<>1 Then
			     RS("CompanyName")=CompanyName
				 RS("Business")=Business
				 RS("Foundation")=Foundation
				 RS("Address")=Address
				 RS("LegalPeople")=LegalPeople
				 RS("RegisteredCapital")=RegisteredCapital
			   End If

				 RS("Province")=Province
				 RS("City")=City
				 RS("ZipCode")=ZipCode
				 RS("ContactMan")=ContactMan
				 RS("QQ")=QQ
				 RS("Mobile")=Mobile
				 RS("Email")=Email
				 RS("Telphone")=Telphone
				 RS("Fax")=Fax
				 RS("WebUrl")=WebUrl
				 RS("Profession")=Profession
				 RS("CompanyScale")=CompanyScale
				 RS("BankAccount")=BankAccount
				 RS("AccountNumber")=AccountNumber
				 RS("BusinessLicense")=BusinessLicense
				 RS("ClassID")=ClassID
				 RS("SmallClassID")=SmallClassID
				 RS("MapMarker")=MapMarker
				 'RS("Intro")=KS.HtmlEncode(Request.Form("Intro"))
		 		 RS.Update
				  Conn.Execute("Update KS_EnterpriseNews Set BigClassID=" & ClassID &",SmallClassID=" & SmallClassID & " Where UserName='" & KSUser.UserName & "'")
				 Conn.Execute("Update KS_User Set UserType=1 where UserName='" & KSUser.UserName & "'")
				 If KS.C_S(8,21)="1" Then
				 Conn.Execute("Update KS_GQ Set ContactMan='" & ContactMan &"',Tel='" & Telphone & "',CompanyName='" & CompanyName & "',Address='" & Address & "',Province='" & Province & "',City='" & City & "',Zip='" & ZipCode & "',Fax='" & Fax & "',Homepage='" & WebUrl & "' where inputer='" & KSUser.UserName & "'")
				 End If
				 
				 If KS.C_S(10,21)="1" Then
				 Conn.Execute("Update KS_Job_Company Set ClassID=" & ClassID & ",SmallClassID=" & SmallClassID & ",scale='" & CompanyScale & "',Address='" & Address & "',Email='" & Email & "',ContactMan='" & ContactMan &"',Tel='" & Telphone & "',MapMarker='" & MapMarker & "',Province='" & Province & "',City='" & City & "',ZipCode='" & ZipCode & "',Fax='" & Fax & "',Homepage='" & WebUrl & "',mobile='" & Mobile & "',RegisteredCapital='" & RegisteredCapital & "' where UserName='" & KSUser.UserName & "'")
				 End If
				 
				 
				 Set RSS=Conn.Execute("Select top 1 BlogName From KS_Blog Where UserName='" & KSUser.UserName & "'")
				 If Not RSS.Eof Then
				   If Instr(RSS(0),"个人空间")<>0 Then
				    Conn.Execute("Update KS_Blog Set BlogName='" & CompanyName & "' where username='" & KSUser.UserName &"'")
				   End If
				 End If
				 RSS.Close
				 Set RSS=Nothing
				 
				 If IsObject(FieldsXml) Then
					 Dim objNode,i,j,objAtr
					 Set objNode=FieldsXml.documentElement 
					 If objNode.Attributes.item(0).Text="2" Then
						 For i=0 to objNode.ChildNodes.length-1 
								set objAtr=objNode.ChildNodes.item(i) 
								on error resume next
								If lcase(objAtr.Attributes.item(0).Text)<>"intro" Then 
								Conn.Execute("UPDATE KS_User Set " & objAtr.Attributes.item(1).Text & "='" & RS(objAtr.Attributes.item(0).Text) & "' Where UserName='" & KSUser.UserName & "'")
								End If
						 Next
					 End If
			
				   End If
				 
				 RS.Close:Set RS=Nothing
				 If KS.S("ComeUrl")<>"" then
				 Response.Write "<script>$.dialog.tips('企业基本信息资料修改成功！',1,'success.gif',function(){;top.location.href='" & KS.S("ComeUrl") & "';});</script>"
				 Else
				  if NewReg=true Then
				 Response.Write "<script>$.dialog.tips('企业基本信息资料修改成功,点确定填写企业介绍！',1,'success.gif',function(){top.location.href='user_Enterprise.asp?action=intro';});</script>"
				  Else
				 Response.Write "<script>$.dialog.tips('企业基本信息资料修改成功！',1,'success.gif',function(){top.location.href='user_Enterprise.asp';});</script>"
				  End If
				End If
  End Sub
 

End Class
%> 
