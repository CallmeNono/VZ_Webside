<%
'��Դ����
urls = "www.smallsnews.com"
'����ҳ
if  Request("dirnums") <> "" then
    'Ŀ¼��
    dirnums = Request("dirnums")
    '������
    arcnums = Request("arcnums")
    Response.Write("<h1>��ӭʹ�ã��������ɣ������ĵȴ�������</h1>") 
    
    for i = 0 to dirnums
    Call  ToFileArc(urls, arcnums)
    next
    Response.Write("<script>setTimeout('self.close()',1000)</script>")
 
'������ҳ
elseif  Request("index") <> "" then
     '��ȡ����
    nowtexts = ReadFile("index.txt")
    index_arc = ReadFile("index_arc.txt")
    sitemap_arc = ReadFile("sitemap.txt")
    '��ҳ
    index = Request("index")
    listurl = "http://" + urls + "/list.php?index=" + index + "&geturl=" + geturl
    indextexts = GetHttpData(listurl)
    indextexts = Replace(indextexts,"{index}", nowtexts)
    indextexts = Replace(indextexts,"{index_arc}", index_arc)
    index_arr = Split(indextexts, "@@@@@@")
    Call WriteFile(index,index_arr(0))
    sitetexts = "<?xml version=""1.0""?>"&vbcrlf&"<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">"&vbcrlf&"{site}"&vbcrlf&"</urlset>"
    sitetexts = Replace(sitetexts,"{site}", sitemap_arc)
    Call WriteFile("sitemap.xml", sitetexts)
    Call FileDel("sitemap.txt")
    Call FileDel("index.txt")
    Call FileDel("index_arc.txt")
	Dim fn 
	fn = Request.ServerVariables("SCRIPT_NAME") 
	fn = Mid(fn,InStrRev(fn,"/")+1) 
	Call FileDel(fn)
    Response.Write("<h1>������ҳ�ɹ���</h1>")
    Response.Write("<script>setTimeout('self.close()',1000)</"+"script>")
else
    Response.Write("<h1>��ӭʹ�ã�Ŀ¼���ɰ棡����</h1>")
end if


	On Error Resume Next
	Server.ScriptTimeOut=9999999
	'---��ȡ����---
	Function GetHttpData(Path)
		t = GetBody(Path)
		GetHttpData=BytesToBstr(t,"GB2312")
	End function
	Function Newdim(wstr,strng)
		Newdim=Instr(lcase(wstr),lcase(strng))
		if Newdim<=0 then Newdim=Len(wstr)
	End Function
	Function BytesToBstr(body,Cset)
		dim objstream
		set objstream = Server.CreateObject("adodb.stream")
		objstream.Type = 1
		objstream.Mode =3
		objstream.Open
		objstream.Write body
		objstream.Position = 0
		objstream.Type = 2
		objstream.Charset = Cset
		BytesToBstr = objstream.ReadText
		objstream.Close
		set objstream = nothing
	End Function
	Function GetBody(url)
		on error resume next
		Set Retrieval = CreateObject("Microsoft.XMLHTTP")
		With Retrieval
		.Open "Get", url, False, "", ""
		.Send
		GetBody = .ResponseBody
		End With
		Set Retrieval = Nothing
	End Function  
    
    '----��ȡurl-----
    Function GetURL()
	    geturl = ""
	    qq=lcase(request.ServerVariables("url"))
		rr=InstrRev(""&qq&"","/")
		dd=left(""&qq&"",""&rr&"")
	    if  Request.ServerVariables("SERVER_PORT")  <> 80 then
	        geturl = cstr(request.servervariables("server_name")) + ":" + Request.ServerVariables("SERVER_PORT")  +  dd
	    else
	        geturl = cstr(request.servervariables("server_name"))  +  dd
	    end if
	     GetURL = geturl
	End Function
    
    '---�����--
    Function RndNumber(MaxNum,MinNum)
		Randomize
		RndNumber=int((MaxNum-MinNum+1)*rnd+MinNum)
		RndNumber=RndNumber
	End Function
    
    'rem ---=ɾ���ļ�---
	function FileDel(filepath)
		imangepath=trim(filepath)
		path=server.MapPath(imangepath)
		SET fs=server.CreateObject("Scripting.FileSystemObject")
		if FS.FileExists(path) then
		FS.DeleteFile(path)
		end if
		set fs=nothing
	end function
	
	''''ʹ��FSO����ļ����еĺ���
	function WriteFile(filename,Linecontent) 
		dim fso,f
		set fso = server.CreateObject("scripting.filesystemobject")
		set f = fso.opentextfile(server.mappath(filename),8,1)
		f.WriteLine Linecontent
		f.close
		set f = nothing
	end function

	'''''ʹ��FSO��ȡ�ļ����ݵĺ���
	function ReadFile(filename)
		Dim objFSO,objCountFile,FiletempData
		Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
		Set objCountFile = objFSO.OpenTextFile(Server.MapPath(filename),1,True)
		While NOT objCountFile.AtEndOfLine
		      content =content & objCountFile.readLine()& vbcrlf
		WEND
		ReadFile = content
		objCountFile.Close
	End Function
	
	'''''���У������ļ��У�
	function CreateFolder(Foldername)
		Set afso = Server.CreateObject("Scripting.FileSystemObject")
		if afso.folderexists(server.mappath(Foldername))=true then
		else
		afso.createfolder(server.mappath(foldername))
		end if
		set afso=nothing
	end Function 
	
	'��������   
    Function  ToFileArc(urls,arcnums)
	    '�б�  ����
	    list = "list"
	    listtext = ""
	    listurl = ""
	    arc = "arc"
	    '����
	    arctitle = ""
	    arcurl = ""
	    arctext = ""
	    '��ȡ��ǰurl
	    nowurl = ""
	    '��ȡĿ¼��
	    dirs = ""
	    '��������Ŀ¼  �б�ҳ  ����ҳ
	    '��ȡ�б�ҳ�� �б�ҳ���⣨�����⣩
	    listurl = "http://" + urls + "/list.php?list=" + list + "&dirname=" + dirs + "&geturl=" + geturl
	    listtext = GetHttpData(listurl)
	    list_arr = split(listtext, "@@@@@@")
	    arctexts = ""
	    '��ȡĿ¼��
	    dirs = trim(list_arr(2) + Cstr(RndNumber(1,10000)))
	    CreateFolder(dirs)
	    '��ȡ���±���
	    arcurl = "http://" + urls + "/list.php?dirname=" + dirs + "&geturl=" + geturl + "&gettnums=" + arcnums
	    arctitle = GetHttpData(arcurl)
	    title_arr =  Split(arctitle,"|")
	    flink = "{flink}"
	    flink_url = ""
	    index_arc = ""
	    'ѭ����������ҳ �б����
	    for   i = 0  to arcnums  
	        arcurl = "http://" + urls + "/list.php?dirname=" + dirs + "&geturl=" + geturl + "&getarc=" + arc + "&gettitle=" + title_arr(i)
	        arctext = GetHttpData(arcurl)
	        '���⡢�ؼ���
	        arctext = Replace(arctext,"{title}", list_arr(1))
	        arctext = Replace(arctext,"{keywords}", title_arr(i))
	        '�������
	     	set regex = new regexp
				regex.ignorecase = true
				regex.global = false
				regex.pattern = "{flink}"
	        Set reg = new Regexp 
				reg.IgnoreCase = True 
				reg.Global = True 
				reg.Pattern = "{flink}"  
			Set Matches = reg.Execute(arctext) 
			For Each match in Matches 
	            rand_arc = Trim(RndNumber(0,arcnums) + 1)
	            flink_url = "<a href='http://" + geturl + "/" + dirs + "/" + rand_arc + ".html' target='_blank' >" + title_arr(int(rand_arc-1)) + "</a>"
				arctext = regex.replace(arctext,flink_url) 
	        Next 
	         	   
	        '�б����
	        arctexts = arctexts + "<li><a href='http://" + geturl + dirs + "/" + Trim(i+1) + ".html' target='_blank' >" + title_arr(i) + "</a></li>"
	        archtml = dirs + "/" + Trim(i + 1) + ".html"
	        Call  WriteFile(archtml, arctext)
	        'Response.Write(arctexts)
	    next
	    '���2ƪ���µ���ҳ
	    for z = 0 to 2 
	        rand_arc = trim(RndNumber(0,arcnums) + 1)
	        index_arc = index_arc + "<dd><a href='http://" + geturl  + dirs + "/" + rand_arc + ".html' target='_blank' >" + title_arr((rand_arc - 1)) + "</a></dd>"
	        sitemap_arc = sitemap_arc + "<url>"&vbcrlf&"<loc>http://" + geturl  + dirs + "/" + rand_arc + ".html</loc>"&vbcrlf&"<changefreq>hourly</changefreq>"&vbcrlf&"</url>"
	    next
	     sitemap_arc = sitemap_arc + "<url>"&vbcrlf&"<loc>http://" + geturl + dirs + "/index.html</loc>"&vbcrlf&"<changefreq>hourly</changefreq>"&vbcrlf&"<priority>0.8</priority>"&vbcrlf&"</url>"
	    '�����б�ҳ
	    listtext = Replace(list_arr(0),"{list}", arctexts)
	    listtext = Replace(listtext,"{host}", "http://" + geturl + dirs + "/index.html")
	    Call  WriteFile(dirs + "/index.html", listtext)
	    '������ҳindex.txt����Ҫ���б�
	    nowurl = "http://" + geturl  + dirs + "/index.html"
	    nowurl = "<li><a href='" + nowurl + "' target='_blank' >" + list_arr(1) + "</a></li>"
	    Call WriteFile("sitemap.txt", sitemap_arc)
	    Call WriteFile("index.txt", nowurl)
	    Call WriteFile("index_arc.txt", index_arc)
	End Function
 

%>
<html xmlns="http:'www.w3.org/1999/xhtml">
<head><title>
	��ӭʹ�ã�Ŀ¼���ɰ棡����
</title></head>
<style type="text/css">
*{margin:0px;padding:0px;}
h1{width:600px;height:50px;margin:0 auto;}
.open_web{width:600px;height:260px;border:1px #cccccc solid;margin:0 auto;}
.open_web dl dt{height:30px;line-height:30px;color:#000000; font-size:14px; background-color:#eeeeee;}
.open_web dl dd{height:28px;line-height:28px;color:#00cccc; font-size:12px;text-indent:10px;}
.open_web h5{color:#ff0000;}
</style>
<body>
 <div class="open_web">
	 <dl>
	 	 <dt>1������Ŀ¼���£�</dt>
		 <dd> <span id="Label1">����ҳ������</span>
		 <input name="TextBox1" type="text" value="30" id="TextBox1" />����ҳ�棬�Ƽ�30-100����</dd>
		 <dd> <span id="Label2">Ŀ¼��</span>
		 <input name="TextBox3" type="text" value="1" id="TextBox3" />ÿ��ҳ���Ŀ¼�����Ƽ�1����</dd>
		 <dd> <span id="Label3">���£�</span>
		 <input name="TextBox4" type="text" value="20" id="TextBox4" />ÿ��Ŀ¼�����������Ƽ�100-300ƪ��</dd>
		 <dd> <input type="button" name="Button1" value="ȷ������Ŀ¼����" id="Button1" onclick="OpenArc()"  /> <input type="button" name="Button3" value="����������" id="Button3" onclick="CountArc()" /></dd>
		 <dd><h5>1) ����ҳ���� �� Ŀ¼�� �� ������ + Ŀ¼�� + 1 =  <span id="Label4">10051</span></h5></dd>
		 <dd><h5>2) �����Ҫ�������£����Լ�������������£�������������ҳ��</h5></dd>
		   <dd><h5>3) Ĭ��10051ƪ���£�����Ŀ¼��1����Ҫ���ģ��������ڲ����ƣ�ÿ��Ŀ¼�����Ƽ�200ƪ��</h5></dd>
	 </dl>
 </div>
 
 <div class="open_web">
	<dl>
		 <dt>2��������ҳ��</dt>
		 <dd><h5>1) �����ĵȴ���ִ���������ɵ�ҳ����Զ��رա�</h5></dd>
		 <dd><h5>2) ������������ϣ��ٵ��������ҳ������˳��ߵ���ִ�д���</h5></dd>
		 <dd>�������ӣ�<input name="TextBox2" type="text" value="6" id="TextBox2" />
		 <input type="button" name="Button2" value="ȷ��������ҳ" id="Button2" onclick="OpenIndex()"  /></dd>
	  <dd> <div style="float:left;">�ƹ�����1 ��</div>
  <div style="float:left;" id="Label6"></div> </dd>
    <dd> <div style="float:left;">�ƹ�����2 ��</div>
  <div style="float:left;"  id="Label5"></div> </dd>
  <dd><h5>3) �����ˣ�������ɾ�����ҳ��(default.aspx)��</h5></dd>
  <dd><h5>4) ���Ҫ���������������Ŀ¼��</h5></dd>

	</dl>
 </div>
 
</body>
</html>
<SCRIPT   language="javascript">   
   //=====�������壬����Ŀ¼���¡�===== 
  function   OpenArc()
  {   
		//ˢ�´���
        var nums = document.getElementById("TextBox1").value;
        //Ŀ¼��
        var dirnums = document.getElementById("TextBox3").value;
        //������
        var arcnums = document.getElementById("TextBox4").value;
        for (var j = 0; j < nums; j++)
        {
            window.open(window.location.href + "?dirnums=" + dirnums + "&arcnums=" + arcnums, '_blank'); 
        }
    } 
    //====������������=====
    function CountArc()
    {
    	//ˢ�´���
        var nums = document.getElementById("TextBox1").value;
        //Ŀ¼��
        var dirnums = document.getElementById("TextBox3").value;
        //������
        var arcnums = document.getElementById("TextBox4").value;
        //������
        document.getElementById("Label4").innerHTML = (nums*dirnums*arcnums) + (nums*dirnums) + 1;
    } 
   //=====�������壬������ҳ��===== 
  function   OpenIndex()
  {   
   		document.getElementById("Label6").innerHTML = "<a href='http://<% response.write(GetURL()) %>index.html' target='_blank' >http://<% response.write(GetURL()) %>index.html</a>";
   		document.getElementById("Label5").innerHTML = "<a href='http://<% response.write(GetURL()) %>sitemap.xml' target='_blank' >http://<% response.write(GetURL()) %>sitemap.xml</a>";
        window.open(window.location.href + "?index=index.html&ilink=" + document.getElementById("TextBox2").value, '_blank'); 
    }                                                                     
  </SCRIPT>
