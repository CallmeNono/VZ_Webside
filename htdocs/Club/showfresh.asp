<!--#include file="../conn.asp"-->
<!--#include file="../ks_cls/kesion.commoncls.asp"-->
<!--#include file="../ks_cls/kesion.label.commoncls.asp"-->
<!--#include file="../ks_cls/ubbfunction.asp"-->
<%
Const CacheTime=360   '缓存更新时间,单位秒
Dim KS:Set KS=New PublicCls
Dim Node,DateStr,Title,Action,OTitle
Action=KS.G("Action")
if isdate(Application(KS.SiteSn &"NewFreshTime"))=false then Application(KS.SiteSn &"NewFreshTime")="1999-1-1 00:00:00"
If Not IsObject(Application(KS.SiteSN & "NewFreshXML")) or (DateDiff("s",Application(KS.SiteSn &"NewFreshTime"),Now)>=KS.ChkClng(CacheTime)) Then
	Application(KS.SiteSn &"NewFreshTime")=Now
    LoadNewData
End If

If Action="scroll" Then
 ShowByScroll
Else
 ShowData
End If

Sub ShowByScroll()
%>
 document.write ('<style>#an li{white-space:nowrap;}#anc{height:31px;overflow:hidden;}</style>');
 document.write ('<div id="an"><dl class="cl"><dt style="height:31px;text-align:center;width:60px;float:left"><strong><a href="../user/weibo.asp"><img src="<%=KS.GetDomain%><%=KS.Setting(66)%>/images/newicon.gif" align="absmiddle" /> 广播：</a></strong></dt>');
 document.write ('<dt style="border:0px solid red;width:525px;_width:522px;overflow:hidden"><div id="anc" class="xi2"><ul id="ancl">');
<%
If IsObject(Application(KS.SiteSN & "NewFreshXML")) Then
  Dim KSR,UserFace,username,Url,n:n=0
  Set KSR=New Refresh
  For Each Node In Application(KS.SiteSN & "NewFreshXML").DocumentElement.SelectNodes("row")
    DateStr=KS.GetTimeFormat(Node.SelectSingleNode("@adddate").text)
	Title=KS.LoseHtml(ubbcode(Node.SelectSingleNode("@note").text,0))
	OTitle=Replace(Replace(Title,"'","\'"),chr(10),"")
	If len(Title)>32 Then Title=left(title,32) & "..."
	Title=Replace(Replace(Title,"'","\'"),chr(10),"")

	username=Node.SelectSingleNode("@username").text

            KS.Echo "document.write('<li><a href=""../user/weibo.asp?userid=" & Node.SelectSingleNode("@userid").text &""" target=""_blank"" style=""color:green"">" & UserName & "</a>说：<span title="""& OTitle&""">" & Title & "</span> <font style=""color:#999;"">" & DateStr & "</font> <a href=""javascript:;"" onclick=""addatt(" &  Node.SelectSingleNode("@userid").text & ",false);"">[关注TA]</a>&nbsp;&nbsp;&nbsp;<a href=\'javascript:;\' onclick=""trans(" & Node.SelectSingleNode("@id").text & ");"">转播(" & Node.SelectSingleNode("@transnum").text & ")</a></li>');"&vbcrlf
  Next
End If
%>

 document.write ('</ul></div></dt></dl></div>');
 showfresh();
	function showfresh() {
	var ann = new Object();
	ann.anndelay = 3000;ann.annst = 0;ann.annstop = 0;ann.annrowcount = 0;ann.anncount = 0;ann.annlis = document.getElementById('anc').getElementsByTagName("li");ann.annrows = new Array();
	ann.showfreshScroll = function () {
		if(this.annstop) { this.annst = setTimeout(function () { ann.showfreshScroll(); }, this.anndelay);return; }
		if(!this.annst) {
			var lasttop = -1;
			for(i = 0;i < this.annlis.length;i++) {
				if(lasttop != this.annlis[i].offsetTop) {
					if(lasttop == -1) lasttop = 0;
					this.annrows[this.annrowcount] = this.annlis[i].offsetTop - lasttop;this.annrowcount++;
				}
				lasttop = this.annlis[i].offsetTop;
			}
			if(this.annrows.length == 1) {
				document.getElementById('an').onmouseover = $('an').onmouseout = null;
			} else {
				this.annrows[this.annrowcount] = this.annrows[1];
				document.getElementById('ancl').innerHTML += document.getElementById('ancl').innerHTML;
				this.annst = setTimeout(function () { ann.showfreshScroll(); }, this.anndelay);
				document.getElementById('an').onmouseover = function () { ann.annstop = 1; };
				document.getElementById('an').onmouseout = function () { ann.annstop = 0; };
			}
			this.annrowcount = 1;
			return;
		}
		if(this.annrowcount >= this.annrows.length) {
			document.getElementById('anc').scrollTop = 0;
			this.annrowcount = 1;
			this.annst = setTimeout(function () { ann.showfreshScroll(); }, this.anndelay);
		} else {
			this.anncount = 0;
			this.showfreshScrollnext(this.annrows[this.annrowcount]);
		}
	};
	ann.showfreshScrollnext = function (time) {
		document.getElementById('anc').scrollTop++;
		this.anncount++;
		if(this.anncount != time) {
			this.annst = setTimeout(function () { ann.showfreshScrollnext(time); }, 10);
		} else {
			this.annrowcount++;
			this.annst = setTimeout(function () { ann.showfreshScroll(); }, this.anndelay);
		}
	};
	ann.showfreshScroll();
}
<%
End Sub


Sub ShowData()
%>
var zzi = 0;
function showzzmb() {
if(zzi== 0) {
$("#zzmb_"+ zzi).hide();
zzi++;
$("#zzmb_"+ zzi).show();

} else {
$("#zzmb_"+ zzi).hide();
zzi = 0;
$("#zzmb_"+ zzi).show();
}
$("#zzmbpage").html(zzi + 1 +"/2");
}
<%
If IsObject(Application(KS.SiteSN & "NewFreshXML")) Then
  Dim KSR,UserFace,username,Url,n:n=0
  	
	KS.Echo "document.write('<div class=""zzblog"">');" &vbcrlf
  Set KSR=New Refresh
  For Each Node In Application(KS.SiteSN & "NewFreshXML").DocumentElement.SelectNodes("row")
    UserFace=KS.GetDomain & "UploadFiles/User/" & Node.SelectSingleNode("@userid").text & "/upface/" & Node.SelectSingleNode("@userid").text & ".jpg"
    DateStr=KS.GetTimeFormat(Node.SelectSingleNode("@adddate").text)
	Title=KS.LoseHtml(ubbcode(Node.SelectSingleNode("@note").text,0))
	If len(Title)>21 Then Title=left(title,21) & "..."
	Title=Replace(Replace(KSR.ReplaceEmot(Title),"'","\'"),chr(10),"<br/>")
	N=n+1
	If N=1 Then 
	 KS.Echo "document.write('  <ul id=""zzmb_0"">');" &vbcrlf
	ElseIf N=6 Then
	 KS.Echo "document.write('  </ul><ul id=""zzmb_1"" style=""display:none"">');" &vbcrlf
	End If
	 UserName=Node.SelectSingleNode("@username").text

            KS.Echo "document.write('<li><span><a href="""& url &""" target=""_blank""><img src=""" & UserFace & """ onerror=""this.onerror=null;this.src=\'../images/face/boy.jpg\';""title=""" & username & """></a><br/><a href=""" & url & """ target=""_blank"" title=""" & username & """>" & Left(UserName,6) & "</a></span><div class=""zzlist""><p>" & Title & "</p></div><div class=""zzjh""><a href=""javascript:;"" onclick=""addatt(" &  Node.SelectSingleNode("@userid").text & ",false);"">关注TA</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\'javascript:;\' onclick=""trans(" & Node.SelectSingleNode("@id").text & ");""><font style=""color:#999;"">转播</font> (" & Node.SelectSingleNode("@transnum").text & ")</a></div></li>');"&vbcrlf
        
	
  Next
  KS.Echo "document.write('</ul>');"&vbcrlf
  KS.Echo "document.write('</div>');"&vbcrlf
  Set KSR=Nothing
  If N>5 Then
   KS.Echo "document.write('<div class=""fypage"" style=""width:110px;clear:both"">');" &vbcrlf
   KS.Echo "document.write('<a href=""javascript:;"" class=""n_link"" title=""后一页"" onclick=""showzzmb();""><em>后一页</em></a> <a href=""javascript:;"" class=""p_link"" title=""前一页"" onclick=""showzzmb();""><em>前一页</em></a><font style=""float:right; margin-right:5px; color:#999; font-size:10px;"" id=""zzmbpage"">1/2</font></div>');" &vbcrlf
  End If
End If
End Sub

Sub LoadNewData()
	Dim SQL,RS
	SQL="select top 10 b.id,a.userid,a.username,a.transtime,a.msg,b.adddate,b.copyfrom,b.note,b.cmtnum,b.username as busername,b.userid as buserid,b.transnum,a.type,a.id as rid from ks_userlogr a left join ks_userlog b on a.msgid=b.id where a.status=1 order by a.id desc"
	Set RS=Server.CreateObject("adodb.recordset")
	RS.Open SQL,Conn,1,1
	If Not RS.Eof Then
	  Set Application(KS.SiteSN & "NewFreshXML")=KS.RsToXml(rs,"",row)
	End If
	RS.Close :Set RS=Nothing
End Sub
%>