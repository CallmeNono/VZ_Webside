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
Set KSCls = New Admin_MyShop
KSCls.Kesion()
Set KSCls = Nothing

Class Admin_MyShop
        Private KS,KSUser,ChannelID
		Private CurrentPage,totalPut,Status,ProducerName,FieldXML,FieldNode,FNode,FieldDictionary
		Private RS,MaxPerPage,ComeUrl,SelButton,Price_Original,Price,Price_Market,Price_Member,Point,Discount
		Private ClassID,Title,KeyWords,ProModel,ProSpecificat,ProductType,Unit,TotalNum,AlarmNum,TrademarkName,Content,Verific,PhotoUrl,RSObj,I,UserClassID,ShowONSpace,Weight,FileIds
		Private CurrentOpStr,Action,ID,ErrMsg,Hits,BigPhoto,BigClassID,SmallClassID,flag,BrandID
		Private Sub Class_Initialize()
			MaxPerPage =12
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
		 IF KS.S("ComeUrl")="" Then
     		ComeUrl=Request.ServerVariables("HTTP_REFERER")
		 Else
     		ComeUrl=KS.S("ComeUrl")
		 End If

		IF Cbool(KSUser.UserLoginChecked)=false Then
		  Response.Write "<script>top.location.href='Login';</script>"
		  Exit Sub
		End If
		ChannelID=KS.ChkClng(KS.S("ChannelID"))
		If ChannelID=0 Then ChannelID=5
		If KS.C_S(ChannelID,6)<>5 Then Response.End()
		if conn.execute("select usertf from ks_channel where channelid=" & channelid)(0)=0 then
		  Response.Write "<script>alert('本频道关闭投稿!');window.close();</script>"
		  Exit Sub
		end if
		'设置缩略图参数
		Session("ThumbnailsConfig")=KS.C_S(ChannelID,46)
		Call KSUser.LoadModelField(ChannelID,FieldXML,FieldNode)
		
		Call KSUser.Head()
		%>
		<div class="tabs">	
			<ul>
				<li<%If KS.S("Status")="" then response.write " class='puton'"%>><a href="User_MyShop.asp?ChannelID=<%=ChannelID%>">我发布的<%=KS.C_S(ChannelID,3)%>(<span class="red"><%=Conn.Execute("Select count(id) from " & KS.C_S(ChannelID,2) &" where Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="1" then response.write " class='puton'"%>><a href="User_MyShop.asp?ChannelID=<%=ChannelID%>&Status=1">已审核(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=1 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="0" then response.write " class='puton'"%>><a href="User_MyShop.asp?ChannelID=<%=ChannelID%>&Status=0">待审核(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=0 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="2" then response.write " class='puton'"%>><a href="User_MyShop.asp?ChannelID=<%=ChannelID%>&Status=2">草 稿(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=2 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
				<li<%If KS.S("Status")="3" then response.write " class='puton'"%>><a href="User_MyShop.asp?ChannelID=<%=ChannelID%>&Status=3">被退稿(<span class="red"><%=conn.execute("select count(id) from " & KS.C_S(ChannelID,2) &" where Verific=3 and Inputer='"& KSUser.UserName &"'")(0)%></span>)</a></li>
			</ul>
		  </div>
		<%
		Action=KS.S("Action")
		Select Case Action
		 Case "Del"
		  Call KSUser.DelItemInfo(ChannelID,ComeUrl)
		 Case "Add","Edit"
		  Call ShopAdd
		 Case "AddSave","EditSave"
          Call ShopSave()
		 Case "refresh" Call KSUser.RefreshInfo(KS.C_S(ChannelID,2))
		 Case Else
		  Call ShopList
		 End Select
       End Sub
	   Sub ShopList
		 CurrentPage = KS.ChkClng(KS.S("page")): If CurrentPage<=0 Then  CurrentPage = 1
                                    
									Dim Param:Param=" Where Inputer='"& KSUser.UserName &"'"
									Verific=KS.S("status")
									If Verific="" or not isnumeric(Verific) Then Verific=4
                                    IF Verific<>4 Then 
									   Param= Param & " and Verific=" & Verific
									End If
									IF KS.S("Flag")<>"" Then
									  IF KS.S("Flag")=0 Then Param=Param & " And Title like '%" & KS.S("KeyWord") & "%'"
									  IF KS.S("Flag")=1 Then Param=Param & " And KeyWords like '%" & KS.S("KeyWord") & "%'"
									End if
									If KS.S("ClassID")<>"" And KS.S("ClassID")<>"0" Then Param=Param & " And TID='" & KS.S("ClassID") & "'"
									Dim Sql:sql = "select a.*,foldername from KS_Product a inner join ks_class b on a.tid=b.id "& Param &" order by AddDate DESC"

								  Select Case Verific
								   Case 0 
								    Call KSUser.InnerLocation("待审"& KS.C_S(ChannelID,3) & "列表")
								   Case 1
								    Call KSUser.InnerLocation("已审"& KS.C_S(ChannelID,3) & "列表")
								   Case 2
								   Call KSUser.InnerLocation("草稿"& KS.C_S(ChannelID,3) & "列表")
								   Case 3
								   Call KSUser.InnerLocation("退稿"& KS.C_S(ChannelID,3) & "列表")
                                   Case Else
								    Call KSUser.InnerLocation("所有"& KS.C_S(ChannelID,3) & "列表")
								   End Select
			   %>
			    <div class="writeblog"><img src="images/ico_05.gif" align="absmiddle"> <a href="user_myshop.asp?ChannelID=<%=ChannelID%>&Action=Add">发布<%=KS.C_S(ChannelID,3)%></a></div>
                <script src="../ks_inc/jquery.imagePreview.1.0.js"></script>
				<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1" class="border">
                    <tr class="title">
                          <td width="6%" height="22" align="center">选中</td>
                          <td align="center" width="40">图片</td>
                          <td align="center"><%=KS.C_S(ChannelID,3)%>名称</td>
						  <td align="center"><%=KS.C_S(ChannelID,3)%>录入</td>
                          <td align="center">添加时间</td>
                          <td align="center">状态</td>
                          <td align="center">管理操作</td>
                   </tr>
                     <%
								Set RS=Server.CreateObject("AdodB.Recordset")
								RS.open sql,conn,1,1
								 If RS.EOF And RS.BOF Then
								  Response.Write "<tr><td class='tdbg' colspan='6' height=30 valign=top>没有你要的"& KS.C_S(ChannelID,3) & "!</td></tr>"
								 Else
									totalPut = RS.RecordCount
								   If CurrentPage >1 and (CurrentPage - 1) * MaxPerPage < totalPut Then
										RS.Move (CurrentPage - 1) * MaxPerPage
									End If
										Call showContent
								End If
     %>                      <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
                                     <form action="User_MyShop.asp" method="post" name="searchform">
								  <td colspan="6">
										<strong><%=KS.C_S(ChannelID,3)%>搜索：</strong>
										  <select name="Flag">
										   <option value="0">名称</option>
										   <option value="1">关键字</option>
									      </select>
										  
										  关键字
										  <input type="text" name="KeyWord" onfocus="if (this.value=='关键字'){this.value=''}" class="textbox" value="关键字" size=20>&nbsp;<input class="button" type="submit" name="submit1" value=" 搜 索 ">
							      </td>
								    </form>
                                </tr>
							<tr>
							 <td colspan=6>
							  <h2><%=KS.C_S(ChannelID,3)%>销售说明：</h2>
							  1、用户在本站发布商品销售，购物方将货款首先支付到本网站；<br/>
							  2、购物方在本站支付成功后，本站将负责对货款及订单的有效性进行审核及通知销售方发货等；<br>
							  3、促成交易后
							  ，本站将收取货款总价的 <font color=red><%=KS.Setting(79)%>% </font>作为交易管理费,并将货款支付给销售方；<br>
							  3、请确保所发布商品真实性，一旦发现您在本站所发布信息含有虚假，期骗行为,我们将立即冻结您在本站的交易账户。
							 </td>
							</tr>
</table>
		  <%
  End Sub
  
  Sub ShowContent()
     Dim I
    Response.Write "<FORM Action=""User_MyShop.asp?Action=Del"" name=""myform"" method=""post"">"
   Do While Not RS.Eof
      
	  Dim PhotoStr:PhotoStr=RS("PhotoUrl")
	 if PhotoStr="" Or IsNull(PhotoStr) Then PhotoStr=KS.GetDomain & "images/Nopic.gif"
	 %>
		 <tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
                   <td class="splittd" height="22" align="center">
					<INPUT id="ID" type="checkbox" value="<%=RS("ID")%>"  name="ID">
				   </td>
				  <td class="splittd"><a href="<%=PhotoStr%>" title="<%=rs("title")%>" class="preview"><img src="<%=photostr%>" width="32" height="32" /></a></td>
                  <td class="splittd" align="left">[<%=RS("FolderName")%>]
				   <%if KS.C_S(ChannelID,21)="1" then%>
					<a title="<%=rs("title")%>"  href="../item/show.asp?m=<%=channelid%>&d=<%=rs("id")%>" target="_blank" class="link3"><%=KS.GotTopic(trim(RS("title")),32)%></a>
				   <%else%>
					<a title="<%=rs("title")%>"  href="../space/?<%=KSUser.GetUserInfo("userid")%>/showproduct/<%=rs("id")%>" target="_blank" class="link3"><%=KS.GotTopic(trim(RS("title")),32)%></a>
				   <%end if%>
				  </td>
				  <td class="splittd" align="center"><%=rs("Inputer")%></td>
                  <td class="splittd" align="center"><%=formatdatetime(rs("AddDate"),2)%></td>
                   <td class="splittd" align="center">
											  <%Select Case rs("Verific")
											   Case 0
											     Response.Write "<span class=""font10"">待审</span>"
											   Case 1
											     Response.Write "<span class=""font11"">已审</span>"
                                               Case 2
											     Response.Write "<span class=""font13"">草稿</span>"
											   Case 3
											     Response.Write "<span class=""font14"">退稿</span>"
                                              end select
											  %></td>
                     <td class="splittd" height="22" align="center">
					    <%If KS.ChkClng(Split(KS.C_S(KS.G("ChannelID"),46)&"||||","|")(3))=1 Then%>
						 <a href="?ChannelID=<%=ChannelID%>&action=refresh&id=<%=rs("id")%>" class="box">刷新</a>
						<%end if%>
											<%if rs("Verific")<>1 or KS.ChkClng(KS.U_S(KSUser.GroupID,1))=1 then%>
											<a class='box' href="User_MyShop.asp?channelid=<%=channelid%>&id=<%=rs("id")%>&Action=Edit&&page=<%=CurrentPage%>">修改</a> <a class='box' href="User_MyShop.asp?channelid=<%=channelid%>&action=Del&ID=<%=rs("id")%>" onclick = "return (confirm('确定删除<%=KS.C_S(ChannelID,3)%>吗?'))">删除</a>
											<%else
											 If KS.C_S(ChannelID,42)=0 Then
											  Response.write "---"
											 Else
											  Response.Write "<a  class='box' href='?channelid=" & channelid & "&id=" & rs("id") &"&Action=Edit&&page=" & CurrentPage &"'>修改</a> <a class='box' href='#' disabled>删除</a>"
											 End If
											end if%>
											</td>
			</tr>
					   <tr><td colspan=6 background='images/line.gif'></td></tr>
                                      <%
							RS.MoveNext
							I = I + 1
					  If I >= MaxPerPage Then Exit Do
				    Loop
%>
</table>
 <table width="100%">
         			<tr class='tdbg' onMouseOver="this.className='tdbgmouseover'" onMouseOut="this.className='tdbg'">
					 <td valign=top style="padding-left:22px;">
							<label><INPUT id="chkAll" onClick="CheckAll(this.form)" type="checkbox" value="checkbox"  name="chkAll">&nbsp;选中</label>&nbsp;<button class="pn pnc" onClick="return(confirm('确定删除选中的<%=KS.C_S(ChannelID,3)%>吗?'));" type="submit"><strong>删除选定</strong></button>  </FORM>       
					  </td>
					  <td align="right">
					<%Call KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,true)%>			
					  </td>
						
        </tr>
								<%
  End Sub
  
 
  '添加
  Sub ShopAdd
        Call KSUser.InnerLocation("发布"& KS.C_S(ChannelID,3) & "")
		Action=KS.S("Action")
		ID=KS.ChkClng(KS.S("ID"))
                 If Action="Edit" Then
				  CurrentOpStr=" OK,修改 "
				  Action="EditSave"
				   Dim ShopRS:Set ShopRS=Server.CreateObject("ADODB.RECORDSET")
				   ShopRS.Open "Select top 1  * From KS_Product Where Inputer='" & KSUser.UserName &"' and ID=" & ID,Conn,1,1
				   IF ShopRS.Eof And ShopRS.Bof Then
				     call KS.Alert("参数传递出错!",ComeUrl)
					 Exit Sub
				   Else
						If KS.C_S(ChannelID,42) =0 And ShopRS("Verific")=1 and KS.ChkClng(KS.U_S(KSUser.GroupID,1))=0 Then
						   ShopRS.Close():Set ShopRS=Nothing
						   Response.Redirect "../plus/error.asp?action=error&message=" & server.urlencode("本频道设置已审核" & KS.C_S(ChannelID,3) & "不允许修改!")
						End If
							   
				        ClassID=ShopRS("TID")
						BrandID=ShopRS("BrandID")
						BigClassID=ShopRS("BigClassID")
						SmallClassID=ShopRS("SmallClassID")
						Title=Trim(ShopRS("Title"))
						UserClassID=ShopRS("ClassID")
						ShowOnSpace=ShopRS("ShowOnSpace")
						KeyWords=Trim(ShopRS("KeyWords"))
						ProModel=Trim(ShopRS("ProModel"))
						ProSpecificat=Trim(ShopRS("ProSpecificat"))
						Unit=Trim(ShopRS("Unit"))
						Weight=ShopRS("Weight")
						TotalNum=Trim(ShopRS("TotalNum"))
						AlarmNum=Trim(ShopRS("AlarmNum"))
						TrademarkName=Trim(ShopRS("TrademarkName"))
						Content=ShopRS("ProIntro")
						Verific  = ShopRS("Verific")
						PhotoUrl=ShopRS("PhotoUrl")
						BigPhoto=ShopRS("BigPhoto")
						ProducerName=Trim(ShopRS("ProducerName"))
						Price=Trim(ShopRS("Price"))
						Price_Member=Trim(ShopRS("Price_Member"))
						'ProductType=1:Discount=9:Hits = 0:TotalNum = 1000: AlarmNum = 10:Comment = 1
						'自定义字段
					   If FieldXML.readystate=4 and FieldXML.parseError.errorCode=0 Then
						Dim DiyNode:Set DiyNode=FieldXML.DocumentElement.selectnodes("fielditem[fieldtype!=0]")
						If diynode.length>0 Then
							Set FieldDictionary=KS.InitialObject("Scripting.Dictionary")
							For Each FNode In DiyNode
							   FieldDictionary.add lcase(FNode.SelectSingleNode("@fieldname").text),ShopRS(FNode.SelectSingleNode("@fieldname").text)
							   If FNode.SelectSingleNode("showunit").text="1" Then
							   FieldDictionary.add lcase(FNode.SelectSingleNode("@fieldname").text) &"_unit",ShopRS(FNode.SelectSingleNode("@fieldname").text&"_Unit")
							   End If
							Next
						End If
					  End If
                   End If
				   SelButton=KS.C_C(ClassID,1)
				Else
				 Call KSUser.CheckMoney(ChannelID)
				 CurrentOpStr=" OK,添加 "
				 Action="AddSave"
				 ProductType=1 : Weight=0
				 ShowOnSpace=1
				 ClassID=KS.S("ClassID")
				 If ClassID="" Then ClassID="0"
				  SelButton="选择栏目..."
				End IF	
		%>
		<script type="text/javascript" src="../editor/ckeditor.js"></script>
		<SCRIPT language=javascript src="../KS_Inc/kesion.box.js"></script>
			<script language = "JavaScript">
			function displaydiscount(){
			 if (document.myform.ProductType[2].checked==true)
			   $("#discountarea").show();
			 else
			   $("#discountarea").hide();
			}
			function getprice(Price_Original){
			  if(Price_Original==''|| isNaN(Price_Original)){Price_Original=0;}
			  if(document.myform.ProductType[2].checked==true){
			  document.myform.Price.value=Math.round(Price_Original*Math.abs(document.myform.Discount.value/10)*100)/100;}
			//  else if(document.myform.ProductType[3].checked==true){document.myform.Price.value=Math.round(Price_Original*Math.abs(document.myform.Discount.value/10)*100)/100;}
			  else{document.myform.Price.value=Price_Original;}
			}
			function regInput(obj, reg, inputStr)
			{
				var docSel = document.selection.createRange()
				if (docSel.parentElement().tagName != "INPUT")    return false
				oSel = docSel.duplicate()
				oSel.text = ""
				var srcRange = obj.createTextRange()
				oSel.setEndPoint("StartToStart", srcRange)
				var str = oSel.text + inputStr + srcRange.text.substr(oSel.text.length)
				return reg.test(str)
			}
			function insertHTMLToEditor(codeStr) 
			{ 
			 CKEDITOR.instances.Content.insertHtml(codeStr);
			} 
			function PreViewPic(ImgUrl)
			{
			if (ImgUrl!=''&&ImgUrl!=null)
			  {   if (ImgUrl==1)
				   {  if (document.myform.PicUrl.length>0&&document.myform.PicUrl.value!='')
					   document.all.PicViewArea.innerHTML='<img src='+document.myform.PicUrl.value.split('|')[1]+' border=0>'
					  else
					   return
					}
				  else
				  if (ImgUrl!='')
				 {document.all.PicViewArea.innerHTML='<img src='+ImgUrl+' border=0>';}
			  }
			}
			function GetFileNameArea(val)
			{
			  if (val==0)
			  {
			   $('filearea').style.display='none';
			  }
			  else
			  {
			   $('filearea').style.display='';
			  }
			}
			function GetTemplateArea(val)
			{
			  if (val==2)
			  {
			   $('templatearea').style.display='none';
			  }
			  else
			  {
			   $('templatearea').style.display='';
			  }
			}
            function GetKeyTags()
			{
			  var text=escape($('#Title').val());
			  if (text!=''){
				  $('#KeyWords').val('请稍等,系统正在自动获取tags...').attr("disabled",true);
				  $.get("../plus/ajaxs.asp", { action: "GetTags", text: text,maxlen: 20 },
				  function(data){
					$('#KeyWords').val(unescape(data)).attr("disabled",false);
				  });
			  }else{
			   alert('对不起,请先输入商品名称!');
			  }
			}			
				 function OpenThenSetValue(Url,Width,Height,WindowObj,SetObj)
					{
						var ReturnStr=showModalDialog(Url,WindowObj,'dialogWidth:'+Width+'pt;dialogHeight:'+Height+'pt;Verific:no;help:no;scroll:no;Verific:0;help:0;scroll:0;');
						if (ReturnStr!='') SetObj.value=ReturnStr;
					}
				function CheckClassID()
				{
				if (document.myform.ClassID.value=="0") 
				  {
					alert("请选择<%=KS.C_S(ChannelID,3)%>栏目！");
					return false;
				  }		
				  return true;
				}
			 
				function CheckForm()
				{
				if (document.myform.ClassID.value=="0") 
				  {
					alert("请选择<%=KS.C_S(ChannelID,3)%>栏目！");
					document.myform.ClassID.focus();
					return false;
				  }		
				if (document.myform.Title.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>名称！");
					document.myform.Title.focus();
					return false;
				  }		
				  if (document.myform.KeyWords.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>关键字！");
					document.myform.KeyWords.focus();
					return false;
				  }	
				 <%Call LFCls.ShowDiyFieldCheck(FieldXML,0)%>
				  if (document.myform.ProModel.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>型号！");
					document.myform.ProModel.focus();
					return false;
				  }	

				  if (document.myform.ProSpecificat.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>规格！");
					document.myform.ProSpecificat.focus();
					return false;
				  }
				  if (document.myform.ProducerName.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>生产商！");
					document.myform.ProducerName.focus();
					return false;
				  }
				  if (document.myform.Unit.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>单位！");
					document.myform.Unit.focus();
					return false;
				  }
				  if (document.myform.TotalNum.value=="")
				  {
					alert("请设置<%=KS.C_S(ChannelID,3)%>库存！");
					document.myform.TotalNum.focus();
					return false;
				  }
				  if (document.myform.AlarmNum.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>库存！");
					document.myform.AlarmNum.focus();
					return false;
				  }
				  if (document.myform.Price.value=="")
				  {
					alert("请输入<%=KS.C_S(ChannelID,3)%>参考价！");
					document.myform.Price.focus();
					return false;
				  }
				  document.myform.submit();
				 return true;  
				}
				function getBrandList()
				{
				   var url='../shop/ajax.getdate.asp';
				    $.get(url,{action:"Shop_BrandOption",from:"User",classid:$("#ClassID").val()},function(d){
				    $("#brandarea").html(unescape(d));
				   });
				}
				
				</script>
                <iframe src="about:blank" name="hidframe" style="display:none"></iframe> 
				<table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" class="border">
				  <tr class="title">
				   <td colspan=2 align=center>
							 <%IF KS.S("Action")="Edit" Then
							   response.write "修改" & KS.C_S(ChannelID,3)
							   Else
							    response.write "发布" & KS.C_S(ChannelID,3)
							   End iF
							  %>				   </td>
				  </tr> 
                  <form  action="User_MyShop.asp?Action=<%=Action%>" method="post" target="hidframe" name="myform" id="myform">
				    <input type="hidden" name="ID" value="<%=ID%>">
				    <input type="hidden" name="comeurl" value="<%=ComeUrl%>">
				    <tr class="tdbg">
                           <td class="clefttitle">所属栏目：</td>
                           <td><% Call KSUser.GetClassByGroupID(ChannelID,ClassID,Selbutton) %>
						   
						   <span id="brandarea">
						   <%If ID<>"0" Then
						     Response.Write GetBrandByClassID(ClassID,BrandID)
						    End If%>
						   </span>
						   
						   </td>
                    </tr>
                     <tr class="tdbg">
                         <td class="clefttitle"><span><%=KS.C_S(ChannelID,3)%>名称：</span></td>
                         <td><input name="Title" class="textbox" type="text" id="Title" value="<%=Title%>" style="width:250px; " maxlength="100" />
                                          <span style="color: #FF0000">*</span></td>
                     </tr>
					<tr class="tdbg">
						<td class="clefttitle">我的分类：</td>
						<td colspan="2"><select class="textbox" size='1' name='UserClassID' style="width:150">
											<option value="0">-不指定分类-</option>
										<%=KSUser.UserClassOption(3,UserClassID)%>
									 </select>		
							
									 <a href="User_Class.asp?Action=Add&typeid=3"><font color="red">添加</font></a>					                      </td>
					</tr>	
                      <tr class="tdbg">
                           <td class="clefttitle">关 键 字：</td>
                           <td><input name="KeyWords" class="textbox" type="text" value="<%=KeyWords%>" id="KeyWords" style="width:220px; " /> <a href="javascript:void(0)" onclick="GetKeyTags()">【自动获取】</a>
						                <span class="msgtips">多个关键字请用英文逗号(&quot;<span style="color: #FF0000">,</span>&quot;)隔开</span> </td>
                                </tr>
                                <tr class="tdbg">
                                        <td class="clefttitle"><%=KS.C_S(ChannelID,3)%>型号：</td>
                                        <td><input name="ProModel" class="textbox" type="text" value="<%=ProModel%>" id="ProModel" style="width:250px; "  maxlength="30" />
                                        <span style="color: #FF0000">*</span></td>
                                </tr>
                                <tr class="tdbg">
                                        <td class="clefttitle"><%=KS.C_S(ChannelID,3)%>规格：</td>
                                        <td><input name="ProSpecificat" class="textbox" type="text" id="ProSpecificat" value="<%=ProSpecificat%>" style="width:250px; " maxlength="100" />
                                        <span style="color: #FF0000">*</span></td>
								</tr>
								
<%
	If IsObject(FieldNode) Then
		For Each FNode In FieldNode
				If KS.ChkClng(FNode.SelectSingleNode("fieldtype").text)<>0 Then
					Response.Write KSUser.GetDiyField(ChannelID,FieldXML,FNode,FieldDictionary)
				End If
		Next
	End If
%>    
							  
								<tr class="tdbg">
								  <td class="clefttitle">品牌/商标：</td>
								  <td><input name="TrademarkName" class="textbox" type="text" id="TrademarkName" value="<%=TrademarkName%>" style="width:250px; " maxlength="100" /></td>
				    </tr>
								<tr class="tdbg">
								  <td class="clefttitle">生产商：</td>
								  <td><input name="ProducerName" class="textbox" type="text" id="ProducerName" value="<%=ProducerName%>" style="width:250px; " maxlength="100" />
							      <span style="color: #FF0000">*</span></td>
				    </tr>
								<tr class="tdbg">
								  <td class="clefttitle">商品单位：</td>
								  <td><input name="Unit" type="text" class="textbox" id="Unit" style="width:40px; " value="<%=Unit%>" size="40" maxlength="40" />&nbsp;(例:本)<span style="color: #FF0000">*</span></td>
				    </tr>
								<tr class="tdbg">
								  <td class="clefttitle">库存设置：</td>
								  <td>库存数量&nbsp;<input name="TotalNum" type="text" class="textbox" id="TotalNum" style="width:40px; " value="<%=TotalNum%>" size="40" maxlength="40" />&nbsp;库存报警下限数&nbsp;<input name="AlarmNum" type="text" class="textbox" id="AlarmNum" style="width:40px; " value="<%=AlarmNum%>" size="40" maxlength="40" />
							      <span style="color: #FF0000">*</span>
								  
								  单件重量<input name="Weight" type="text" class="textbox" id="Weight" style="width:40px; " value="<%=Weight%>" size="10" maxlength="10" /> KG 
								  </td>
				    </tr>
								<tr class="tdbg">
								  <td class="clefttitle">商品价格：</td>
								  <td>

<font color=blue>参考价<input name="Price" type="text" id="Price" value="<%=Price%>" size="6" class="textbox"
		onKeyPress="return regInput(this,/^\d*\.?\d{0,2}$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^\d*\.?\d{0,2}$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,    /^\d*\.?\d{0,2}$/,event.dataTransfer.getData('Text'))">元</font>&nbsp;&nbsp; 会员价<input name="Price_Member" type="text" id="Price_Member" value="<%=Price_Member%>" size="6" class="textbox" onKeyPress= "return regInput(this,/^\d*\.?\d{0,2}$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^\d*\.?\d{0,2}$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,    /^\d*\.?\d{0,2}$/,event.dataTransfer.getData('Text'))">元
		</tr>
								
								<tr class="tdbg">
                                        <td class="clefttitle">小图地址：</td>
                                        <td><input class="textbox" name='PhotoUrl' value="<%=PhotoUrl%>" type='text' style="width:250px;" id='PhotoUrl' maxlength="100" />
                                          &nbsp;
                                          <input class="uploadbutton1" type='button' name='Submit3' value='选择图片' onClick="OpenThenSetValue('Frame.asp?url=SelectPhoto.asp&pagetitle=<%=Server.URLEncode("选择图片")%>&channelid=5',500,360,window,document.myform.PhotoUrl);" /></td>
							   </tr>
								<tr class="tdbg">
                                        <td class="clefttitle">大图地址：</td>
                                        <td><input class="textbox" name='BigPhoto' value="<%=BigPhoto%>" type='text' style="width:250px;" id='BigPhoto' maxlength="100" />
                                          &nbsp;
                                          <input class="uploadbutton1" type='button' name='Submit3' value='选择图片' onClick="OpenThenSetValue('Frame.asp?url=SelectPhoto.asp&pagetitle=<%=Server.URLEncode("选择图片")%>&channelid=5',500,360,window,document.myform.BigPhoto);" /></td>
							   </tr>
								<tr class="tdbg">
                                        <td class="clefttitle">上传图片：</td>
                                        <td><iframe id='UpPhotoFrame' name='UpPhotoFrame' src='User_upfile.asp?channelid=5&Type=Pic' frameborder=0 scrolling=no width='95%' height='30'> </iframe></td></tr>
								
  								<tr class="tdbg">
                                        <td class="clefttitle"><%=KS.C_S(ChannelID,3)%>简介：</td>
                                        <td>
										<table width="100%"  border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                              <td>
                                          
													<table border='0' width='100%' cellspacing='0' cellpadding='0'>
			       <tr><td height='35' width=70>&nbsp;<strong>上传附件:</strong></td><td><iframe id='upiframe' name='upiframe' src='BatchUploadForm.asp?ChannelID=<%=ChannelID%>' frameborder=0 scrolling=no width='560' height='24'></iframe></td></tr>
			       </table>
										<textarea name="Content" style="display:none"><%=Server.HTMLEncode(Content)%></textarea>
                                       <script type="text/javascript">
										CKEDITOR.replace('Content', {width:"98%",height:"200px",toolbar:"Basic",filebrowserBrowseUrl :"../editor/ksplus/SelectUpFiles.asp",filebrowserWindowWidth:650,filebrowserWindowHeight:290});
										</script> 	
										         </td>
                                                  </tr>
                                              </table>
									</td>
                                </tr>
<tr class="tdbg">
                                        <td class="clefttitle">空间显示：</td>
                                        <td><input name="ShowOnSpace" type="radio" value="1" <%If ShowOnSpace="1" Then Response.Write " checked"%> />是
	<input name="ShowOnSpace" type="radio" value="0" <%If ShowOnSpace="0" Then Response.Write " checked"%>/>否					</td>
								</tr>
					  <%if KS.S("Action")="Edit" And Verific=1 Then%>
								<input type="hidden" name="okverific" value="1">
								<input type="hidden" name="verific" value="1">
								<%else%>
						<tr class="tdbg" >
                                        <td class="clefttitle"><%=KS.C_S(ChannelID,3)%>状态：</td>
                                        <td height="25"><input name="Status" type="radio" value="0" <%If Verific=0 Then Response.Write " checked"%> />
                                          投搞
                                          <input name="Status" type="radio" value="2" <%If Verific=2 Then Response.Write " checked"%>/>
                                          草稿
										  </td>
                                      </tr>
							  <%end if%>
                          <tr class="tdbg">
						    <td></td>
                            <td>
							<button class="pn"  onClick="return CheckForm();" id="btn" type="button"><strong><%=CurrentOpStr%></strong></button></td>
                          </tr>
                  </form>
</table>
				
		  <%
		  If IsObject(ShopRS) Then
  			If ShopRS.status<>0 Then  ShopRS.Close:Set ShopRS=Nothing
          End If
  End Sub
  
  Function GetBrandByClassID(ClassID,BrandID)
		  Dim SQL,K
		  Dim RS:Set RS=Server.CreateOBject("ADODB.RECORDSET")
		  RS.Open "Select B.ID,B.BrandName From KS_ClassBrand B inner join KS_ClassBrandR R On B.id=R.BrandID where R.classid='" & classid & "' order by B.orderid",conn,1,1
		  If Not RS.Eof  Then SQL=RS.GetRows(-1):RS.Close:Set RS=Nothing
		  If Not IsArray(SQL) Then
		   'GetBrandByClassID="Null" 
		  Else
		     GetBrandByClassID = "所属品牌：<select name='brandid'>"
			 GetBrandByClassID = GetBrandByClassID & "<option value='0'>-请选择品牌-</option>"
		     For K=0 To Ubound(SQL,2)
			  If BrandID=SQL(0,K) Then
			  GetBrandByClassID=GetBrandByClassID & "<option value='" & sql(0,k) & "' selected>" & sql(1,k) & "</option>"
			  Else
			  GetBrandByClassID=GetBrandByClassID & "<option value='" & sql(0,k) & "'>" & sql(1,k) & "</option>"
			  End If
			 Next
			 GetBrandByClassID = GetBrandByClassID &  "</select>"
			 Erase Sql
		  End If
  End Function
	   
  Sub ShopSave()
        Dim ID:ID=KS.ChkClng(KS.S("ID"))
  		ClassID=KS.S("ClassID")
		If KS.ChkClng(KS.C_C(ClassID,20))=0 Then
			 Response.Write "<script>alert('对不起,系统设定不能在此栏目发表,请选择其它栏目!');</script>":Exit Sub
		End IF
		BigClassID=KS.ChkClng(KS.S("BigClassID"))
		SmallClassID=KS.ChkClng(KS.S("SmallClassID"))
		Title=KS.FilterIllegalChar(KS.LoseHtml(KS.S("Title")))
		KeyWords=KS.LoseHtml(KS.S("KeyWords"))
		ProModel=KS.LoseHtml(KS.S("ProModel"))
		ProSpecificat=KS.LoseHtml(KS.S("ProSpecificat"))
		Unit=KS.LoseHtml(KS.S("Unit"))
		Weight=KS.S("Weight") : If Not IsNumeric(Weight) Then Weight=0
		TotalNum=KS.ChkClng(KS.S("TotalNum"))
		AlarmNum=KS.ChkClng(KS.S("AlarmNum"))
		TrademarkName=KS.LoseHtml(KS.S("TrademarkName"))
		Content=KS.FilterIllegalChar(Request.Form("Content"))
		If KS.IsNul(Content) Then Content=" "
		ProducerName=KS.LoseHtml(KS.S("ProducerName"))
		UserClassID=KS.ChkClng(KS.S("UserClassID"))
		ShowOnSpace=KS.ChkClng(KS.S("ShowOnSpace"))
		Verific=KS.ChkClng(KS.S("Status"))
        If KS.C_S(ChannelID,17)<>0 And Verific=0 Then Verific=1
		 If KS.ChkClng(KS.S("ID"))<>0 and verific=1  Then
			 If KS.C_S(ChannelID,42)=2 Then Verific=1 Else Verific=0
		 End If
		 if KS.C_S(ChannelID,42)=2 and KS.ChkClng(KS.S("okverific"))=1 Then verific=1
		 If KS.ChkClng(KS.U_S(KSUser.GroupID,0))=1 Then verific=1  '特殊VIP用户无需审核
		PhotoUrl=KS.S("PhotoUrl")
		BigPhoto=KS.S("BigPhoto")


			Price = KS.G("Price")
			Price_Member = KS.G("Price_Member"):If Price_Member="" Then Price_Member=0
			
			If Not IsNumeric(Price) Then Call KS.Alert("当前零售价必须填数字!","") : Exit Sub
			If Not IsNumeric(Price_Member) Then Call KS.Alert("会员价必须填数字!","") : Exit Sub
			
			FileIds=LFCls.GetFileIDFromContent(Content)
			
				  if ClassID="" Then ClassID=0
				  If ClassID=0 Then
				    Response.Write "<script>alert('你没有选择"& KS.C_S(ChannelID,3) & "栏目!');</script>"
				    Exit Sub
				  End IF
				  If Title="" Then
				    Response.Write "<script>alert('你没有输入"& KS.C_S(ChannelID,3) & "名称!');</script>"
				    Exit Sub
				  End IF
				  
				  
			Call KSUser.CheckDiyField(FieldXML,false)				  
			Set RSObj=Server.CreateObject("Adodb.Recordset")
			 Dim Fname,FnameType,TemplateID,WapTemplateID
			 If ID=0 Then
				 FnameType=KS.C_C(ClassID,23)
				 Fname=KS.GetFileName(KS.C_C(ClassID,24), Now, FnameType)
				 TemplateID=KS.C_C(ClassID,5)
				 WapTemplateID=KS.C_C(ClassID,22)
			 End If

			RSObj.Open "Select top 1 * From KS_Product Where Inputer='" & KSUser.UserName & "' and ID=" & ID,Conn,1,3
				If RSObj.Eof And RSObj.Bof Then
				   RSObj.AddNew
				     RSObj("ProID")=KS.GetInfoID(ChannelID)   '取唯一ID
				     RSObj("Hits")=0
					 RSObj("Rolls")=0
					 RSObj("Recommend")=0
					 RSObj("Popular")=0
					 RSObj("Slide")=0
					 RSObj("Comment")=1
					 RSObj("IsSpecial")=0
					 RSObj("ISTop")=0
					 RSObj("Fname") = Fname
					 RSObj("AddDate")=Now
					 RSObj("Rank")="★★★"
					 RSObj("TemplateID") = TemplateID
					 RSObj("WapTemplateID")=WapTemplateID
				End If
				     RSObj("ModifyDate")=Now
					 RSObj("Title") = Title
					 RSObj("PhotoUrl") = PhotoUrl
					 RSObj("BigPhoto") = BigPhoto
					 RSObj("ProIntro") = Content
					 RSObj("Weight") = Weight
					 RSObj("Verific") = Verific
					 RSObj("Tid") = ClassID
					 RSObj("BrandID")=KS.ChkClng(KS.G("BrandID"))
					 RSObj("TotalNum") = TotalNum
					 RSObj("AlarmNum") = AlarmNum
					 RSObj("Unit") = Unit
					 RSObj("Price") = Price
					 RSObj("Price_Member")=Price_Member
					 RSObj("KeyWords") = KeyWords
					 RSObj("ProSpecificat")=ProSpecificat
					 RSObj("ProModel") = ProModel
					 RSObj("TrademarkName") = TrademarkName
					 RSObj("Inputer")=KSUser.UserName
					 RSObj("ProducerName")=ProducerName
					 RSObj("ClassID")=UserClassID
					 RSOBj("ShowOnSpace")=ShowOnSpace
					 RSOBj("BigClassID")=BigClassID
					 RSObj("SmallClassID")=SmallClassID
					 Call KSUser.AddDiyFieldValue(RSObj,FieldXML)
				RSObj.Update
				RSObj.MoveLast
				Dim InfoID:InfoID=RSObj("ID")
				If Left(Ucase(Fname),2)="ID" and ID=0 Then
					RSObj("Fname") = InfoID & FnameType
					RSObj.Update
				End If
				Fname=RSOBj("Fname")
				
				If Verific=1 Then 
				    Call KS.SignUserInfoOK(ChannelID,KSUser.UserName,Title,InfoID)
					If KS.C_S(ChannelID,17)=2  and (KS.C_S(Channelid,7)=1 or KS.C_S(ChannelID,7)=2) Then
					 Dim KSRObj:Set KSRObj=New Refresh
					 Dim DocXML:Set DocXML=KS.RsToXml(RSObj,"row","root")
				     Set KSRObj.Node=DocXml.DocumentElement.SelectSingleNode("row")
					  KSRObj.ModelID=ChannelID
					  KSRObj.ItemID = KSRObj.Node.SelectSingleNode("@id").text 
					  Call KSRObj.RefreshContent()
					  Set KSRobj=Nothing
					End If
				End If
				 RSObj.Close:Set RSObj=Nothing
				 If Not KS.IsNul(FileIds) Then 
				 Conn.Execute("Update [KS_UpLoadFiles] Set InfoID=" & InfoID &",classID=" & KS.C_C(ClassID,9) & " Where ID In (" &FileIds & ")")
				End If

               If ID=0 Then
			     Call LFCls.InserItemInfo(ChannelID,InfoID,Title,ClassId,Content,KeyWords,PhotoUrl,KSUser.UserName,Verific,Fname)
  		         Call KS.FileAssociation(ChannelID,InfoID,PhotoUrl & BigPhoto & Content ,0)
			     Dim LogStr
				  If PhotoUrl<>"" Then
				   LogStr="[img]" & photourl & "[/img][br]" & left(KS.LoseHtml(Content),60) & "..."
				  Else
				   LogStr=left(KS.LoseHtml(Content),80) & "..."
				  End If
			    Call KSUser.AddToWeibo(KSUser.UserName,"发布了" & KS.C_S(ChannelID,3) & "：" & left(Title,40) & " [url=" & KS.GetItemURL(ChannelID,ClassID,InfoID,Fname) & "]详情&raquo;[/url][br]"&logstr,5)
				 KS.Echo "<script>if (confirm('"& KS.C_S(ChannelID,3) & "添加成功，继续添加吗?')){top.location.href='User_MyShop.asp?Action=Add&ClassID=" & ClassID &"';}else{top.location.href='User_MyShop.asp';}</script>"
			  Else
			     Call LFCls.ModifyItemInfo(ChannelID,InfoID,Title,classid,Content,KeyWords,PhotoUrl,Verific)
				 Call KS.FileAssociation(ChannelID,InfoID,PhotoUrl & BigPhoto & Content ,1)
				KS.Echo "<script>alert('"& KS.C_S(ChannelID,3) & "修改成功!');top.location.href='" & ComeUrl & "';</script>"
			  End If
		
  End Sub
End Class
%> 
