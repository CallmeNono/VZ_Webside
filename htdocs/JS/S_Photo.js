﻿document.writeln('<table width=\"98%\" border=\"0\" align=\"center\">')
document.writeln('<form id=\"SearchForm\" name=\"SearchForm\" method=\"get\" action=\"/item/index.asp\">')
document.writeln('  <tr>')
document.writeln('    <td align=\"center\"><select name=\"t\">')
document.writeln('          <option value=\"1\">名 称</option>')
document.writeln('          <option value=\"2\">简 介</option>')
document.writeln('          <option value=\"3\">作 者</option>')
document.writeln('          <option value=\"4\">录入者</option>')
document.writeln('          <option value=\"5\">关键字</option>')
document.writeln('      </select>')
document.writeln('        <select name=\"tid\" style=\"width:150px\">')
document.writeln('          <option value=\"0\" selected=\"selected\">所有栏目</option>')
document.writeln('<option value=\'20097082279507\'>图片频道 </option><option value=\'20111594223610\'>──概念家居 </option><option value=\'20119640140844\'>──奢华尚品 </option><option value=\'20110146528845\'>──饰品布艺 </option><option value=\'20115271973099\'>──家饰生活 </option><option value=\'20112631609733\'>──现代简约 </option><option value=\'20117149780649\'>──中式风格 </option><option value=\'20112354156485\'>──混搭风格 </option><option value=\'20115768945465\'>──欧式风格 </option><option value=\'20118061712905\'>──动漫图库 </option>        </select>')
document.writeln('        <input name=\"key\" type=\"text\" class=\"textbox\"  value=\"关键字\" onfocus=\"this.select();\"/>')
document.writeln('        <input name=\"ChannelID\" value=\"2\" type=\"hidden\" />')
document.writeln('        <input type=\"submit\" class=\"inputButton\" name=\"sbtn\" value=\"搜 索\" /></td>')
document.writeln('  </tr>')
document.writeln('</form>')
document.writeln('</table>')