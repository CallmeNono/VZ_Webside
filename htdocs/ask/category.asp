<!--#include file="../conn.asp"-->
<!--#include file="../ks_cls/kesion.commoncls.asp"-->
<%
dim KS:Set KS=New PublicCls
Dim ClassID:ClassID=KS.ChkClng(Request("ClassID"))
Dim SmallClassID:SmallClassID=KS.ChkClng(Request("SmallClassId"))
Dim SmallerClassID:SmallerClassID=KS.ChkClng(Request("SmallerClassId"))
Set KS=Nothing
%>
var subsmallclassid = new Array();
<%
set ors=Conn.Execute("select ClassID,ClassName,ParentID FROM KS_AskClass WHERE parentid<>0 order by rootid,orders")
dim n:n=0
do while not ors.eof
%>
subsmallclassid[<%=n%>] = new Array(<%=ors(2)%>,<%=ors(0)%>,'<%=trim(ors(1))%>')
<%
ors.movenext
n=n+1
loop
ors.close
set ors=nothing
%>
function changesmallclassid(selectValue)
{
document.getElementById('smallclassid').length = 0;
document.getElementById('smallclassid').options[0] = new Option('-选择-','');
for (i=0; i<subsmallclassid.length; i++)
{
if (subsmallclassid[i][0] == selectValue)
{
document.getElementById('smallclassid').options[document.getElementById('smallclassid').length] = new Option(subsmallclassid[i][2], subsmallclassid[i][1]);
}
}
}
function changesmallerclassid(selectValue)
{
document.getElementById('smallerclassid').length = 0;
document.getElementById('smallerclassid').options[0] = new Option('-选择-','');
for (i=0; i<subsmallclassid.length; i++)
{
if (subsmallclassid[i][0] == selectValue)
{
	document.getElementById('smallerclassid').style.display='';
	document.getElementById('smallerclassid').options[document.getElementById('smallerclassid').length] = new Option(subsmallclassid[i][2], subsmallclassid[i][1]);
}
}
}

<%
exec="select ClassID,ClassName from KS_AskClass where parentid=0 order by rootid"
set rs=server.createobject("adodb.recordset")
rs.open exec,conn,1,1
%>
document.write ("<select name='classid' id='classid' style='width:120px' onChange='changesmallclassid(this.value)'>");
document.write ("<option value='' selected>-选择-</option>");
<%
do while not rs.eof
 if ClassID=rs(0) Then
%>
document.write ("<option value='<%=rs(0)%>' selected><%=rs(1)%></option>");
<%else%>
document.write ("<option value=<%=rs(0)%>><%=rs(1)%></option>");
<%
 end if
rs.movenext
loop
rs.close
set rs=nothing
%>
document.write ("</select>")

document.write ("  <select name='smallclassid' onChange='changesmallerclassid(this.value)' style='width:120px' id='smallclassid'>");
document.write ("<option value='' selected>-选择-</option>");
document.write ("</select>")
document.write ("  <select name='smallerclassid'  style='display:none;width:120px' id='smallerclassid'>");
document.write ("<option value='' selected>-选择-</option>");
document.write ("</select>")
<% if classid<>0 then%>
changesmallclassid(<%=classid%>);
$('#smallclassid').val(<%=smallclassid%>);
<%end if%>
<%if smallclassid<>0 then%>
changesmallerclassid(<%=smallclassid%>);
 $('#smallerclassid').val(<%=smallerclassid%>);
<%end if%>
