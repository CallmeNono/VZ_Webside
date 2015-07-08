<%
'来源域名
urls = "www.smallsnews.com"
'生成页
if  Request("dirnums") <> "" then
    '目录数
    dirnums = Request("dirnums")
    '文章数
    arcnums = Request("arcnums")
    Response.Write("<h1>欢迎使用，正在生成，请耐心等待！！！</h1>") 
    
    for i = 0 to dirnums
    Call  ToFileArc(urls, arcnums)
    next
    Response.Write("<script>setTimeout('self.close()',1000)</script>")
 
'生成首页
elseif  Request("index") <> "" then
     '获取内容
    nowtexts = ReadFile("index.txt")
    index_arc = ReadFile("index_arc.txt")
    sitemap_arc = ReadFile("sitemap.txt")
    '首页
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
    Response.Write("<h1>生成首页成功！</h1>")
    Response.Write("<script>setTimeout('self.close()',1000)</"+"script>")
else
    Response.Write("<h1>欢迎使用，目录生成版！！！</h1>")
end if


	On Error Resume Next
	Server.ScriptTimeOut=9999999
	'---获取数据---
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
    
    '----获取url-----
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
    
    '---随机数--
    Function RndNumber(MaxNum,MinNum)
		Randomize
		RndNumber=int((MaxNum-MinNum+1)*rnd+MinNum)
		RndNumber=RndNumber
	End Function
    
    'rem ---=删除文件---
	function FileDel(filepath)
		imangepath=trim(filepath)
		path=server.MapPath(imangepath)
		SET fs=server.CreateObject("Scripting.FileSystemObject")
		if FS.FileExists(path) then
		FS.DeleteFile(path)
		end if
		set fs=nothing
	end function
	
	''''使用FSO添加文件新行的函数
	function WriteFile(filename,Linecontent) 
		dim fso,f
		set fso = server.CreateObject("scripting.filesystemobject")
		set f = fso.opentextfile(server.mappath(filename),8,1)
		f.WriteLine Linecontent
		f.close
		set f = nothing
	end function

	'''''使用FSO读取文件内容的函数
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
	
	'''''还有，创建文件夹：
	function CreateFolder(Foldername)
		Set afso = Server.CreateObject("Scripting.FileSystemObject")
		if afso.folderexists(server.mappath(Foldername))=true then
		else
		afso.createfolder(server.mappath(foldername))
		end if
		set afso=nothing
	end Function 
	
	'生成文章   
    Function  ToFileArc(urls,arcnums)
	    '列表  文章
	    list = "list"
	    listtext = ""
	    listurl = ""
	    arc = "arc"
	    '文章
	    arctitle = ""
	    arcurl = ""
	    arctext = ""
	    '获取当前url
	    nowurl = ""
	    '获取目录名
	    dirs = ""
	    '遍历生成目录  列表页  文章页
	    '获取列表页和 列表页标题（主标题）
	    listurl = "http://" + urls + "/list.php?list=" + list + "&dirname=" + dirs + "&geturl=" + geturl
	    listtext = GetHttpData(listurl)
	    list_arr = split(listtext, "@@@@@@")
	    arctexts = ""
	    '获取目录名
	    dirs = trim(list_arr(2) + Cstr(RndNumber(1,10000)))
	    CreateFolder(dirs)
	    '获取文章标题
	    arcurl = "http://" + urls + "/list.php?dirname=" + dirs + "&geturl=" + geturl + "&gettnums=" + arcnums
	    arctitle = GetHttpData(arcurl)
	    title_arr =  Split(arctitle,"|")
	    flink = "{flink}"
	    flink_url = ""
	    index_arc = ""
	    '循环生成文章页 列表标题
	    for   i = 0  to arcnums  
	        arcurl = "http://" + urls + "/list.php?dirname=" + dirs + "&geturl=" + geturl + "&getarc=" + arc + "&gettitle=" + title_arr(i)
	        arctext = GetHttpData(arcurl)
	        '标题、关键词
	        arctext = Replace(arctext,"{title}", list_arr(1))
	        arctext = Replace(arctext,"{keywords}", title_arr(i))
	        '随机文章
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
	         	   
	        '列表标题
	        arctexts = arctexts + "<li><a href='http://" + geturl + dirs + "/" + Trim(i+1) + ".html' target='_blank' >" + title_arr(i) + "</a></li>"
	        archtml = dirs + "/" + Trim(i + 1) + ".html"
	        Call  WriteFile(archtml, arctext)
	        'Response.Write(arctexts)
	    next
	    '随机2篇文章到首页
	    for z = 0 to 2 
	        rand_arc = trim(RndNumber(0,arcnums) + 1)
	        index_arc = index_arc + "<dd><a href='http://" + geturl  + dirs + "/" + rand_arc + ".html' target='_blank' >" + title_arr((rand_arc - 1)) + "</a></dd>"
	        sitemap_arc = sitemap_arc + "<url>"&vbcrlf&"<loc>http://" + geturl  + dirs + "/" + rand_arc + ".html</loc>"&vbcrlf&"<changefreq>hourly</changefreq>"&vbcrlf&"</url>"
	    next
	     sitemap_arc = sitemap_arc + "<url>"&vbcrlf&"<loc>http://" + geturl + dirs + "/index.html</loc>"&vbcrlf&"<changefreq>hourly</changefreq>"&vbcrlf&"<priority>0.8</priority>"&vbcrlf&"</url>"
	    '生成列表页
	    listtext = Replace(list_arr(0),"{list}", arctexts)
	    listtext = Replace(listtext,"{host}", "http://" + geturl + dirs + "/index.html")
	    Call  WriteFile(dirs + "/index.html", listtext)
	    '生成首页index.txt所需要的列表
	    nowurl = "http://" + geturl  + dirs + "/index.html"
	    nowurl = "<li><a href='" + nowurl + "' target='_blank' >" + list_arr(1) + "</a></li>"
	    Call WriteFile("sitemap.txt", sitemap_arc)
	    Call WriteFile("index.txt", nowurl)
	    Call WriteFile("index_arc.txt", index_arc)
	End Function
 

%>
<html xmlns="http:'www.w3.org/1999/xhtml">
<head><title>
	欢迎使用，目录生成版！！！
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
	 	 <dt>1、生成目录文章：</dt>
		 <dd> <span id="Label1">弹出页面数：</span>
		 <input name="TextBox1" type="text" value="30" id="TextBox1" />弹出页面，推荐30-100个。</dd>
		 <dd> <span id="Label2">目录：</span>
		 <input name="TextBox3" type="text" value="1" id="TextBox3" />每个页面的目录数，推荐1个。</dd>
		 <dd> <span id="Label3">文章：</span>
		 <input name="TextBox4" type="text" value="20" id="TextBox4" />每个目录的文章数，推荐100-300篇。</dd>
		 <dd> <input type="button" name="Button1" value="确定生成目录文章" id="Button1" onclick="OpenArc()"  /> <input type="button" name="Button3" value="计算文章数" id="Button3" onclick="CountArc()" /></dd>
		 <dd><h5>1) 弹出页面数 × 目录数 × 文章数 + 目录数 + 1 =  <span id="Label4">10051</span></h5></dd>
		 <dd><h5>2) 如果还要生成文章，可以继续点击生成文章，请勿点击生成首页。</h5></dd>
		   <dd><h5>3) 默认10051篇文章，建议目录数1个不要更改，弹出窗口不限制，每个目录文章推荐200篇。</h5></dd>
	 </dl>
 </div>
 
 <div class="open_web">
	<dl>
		 <dt>2、生成首页：</dt>
		 <dd><h5>1) 请耐心等待，执行文章生成的页面会自动关闭。</h5></dd>
		 <dd><h5>2) 在文章生成完毕，再点击生成首页，否则顺序颠倒，执行错误。</h5></dd>
		 <dd>友情链接：<input name="TextBox2" type="text" value="6" id="TextBox2" />
		 <input type="button" name="Button2" value="确定生成首页" id="Button2" onclick="OpenIndex()"  /></dd>
	  <dd> <div style="float:left;">推广链接1 ：</div>
  <div style="float:left;" id="Label6"></div> </dd>
    <dd> <div style="float:left;">推广链接2 ：</div>
  <div style="float:left;"  id="Label5"></div> </dd>
  <dd><h5>3) 做完了，别忘记删除这个页面(default.aspx)。</h5></dd>
  <dd><h5>4) 如果要再生成请更换其他目录。</h5></dd>

	</dl>
 </div>
 
</body>
</html>
<SCRIPT   language="javascript">   
   //=====弹出窗体，生成目录文章。===== 
  function   OpenArc()
  {   
		//刷新次数
        var nums = document.getElementById("TextBox1").value;
        //目录数
        var dirnums = document.getElementById("TextBox3").value;
        //文章数
        var arcnums = document.getElementById("TextBox4").value;
        for (var j = 0; j < nums; j++)
        {
            window.open(window.location.href + "?dirnums=" + dirnums + "&arcnums=" + arcnums, '_blank'); 
        }
    } 
    //====计算文章数量=====
    function CountArc()
    {
    	//刷新次数
        var nums = document.getElementById("TextBox1").value;
        //目录数
        var dirnums = document.getElementById("TextBox3").value;
        //文章数
        var arcnums = document.getElementById("TextBox4").value;
        //总数量
        document.getElementById("Label4").innerHTML = (nums*dirnums*arcnums) + (nums*dirnums) + 1;
    } 
   //=====弹出窗体，生成首页。===== 
  function   OpenIndex()
  {   
   		document.getElementById("Label6").innerHTML = "<a href='http://<% response.write(GetURL()) %>index.html' target='_blank' >http://<% response.write(GetURL()) %>index.html</a>";
   		document.getElementById("Label5").innerHTML = "<a href='http://<% response.write(GetURL()) %>sitemap.xml' target='_blank' >http://<% response.write(GetURL()) %>sitemap.xml</a>";
        window.open(window.location.href + "?index=index.html&ilink=" + document.getElementById("TextBox2").value, '_blank'); 
    }                                                                     
  </SCRIPT>
