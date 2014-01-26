<%@ Page Language="C#" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    System.Xml.XmlDocument doc;
    System.Xml.XmlElement root;
    string strUser = "Unknown";

    protected void Page_Load(object sender, EventArgs e)
    {
        System.Security.Principal.WindowsIdentity identity = null;
        System.Xml.XmlNode node, childNode;

        doc = new System.Xml.XmlDocument();

        root = doc.CreateElement("Report");
        doc.AppendChild(root);

        node = doc.CreateElement("Overview");
        root.AppendChild(node);
        this.AppendReportItem(node, "Originator", Request.UserHostName);
        this.AppendReportItem(node, "Host", Request.Url.Host);
        this.AppendReportItem(node, "Timestamp", DateTime.UtcNow.ToString());

        node = doc.CreateElement("Request");
        root.AppendChild(node);
        this.AppendReportItem(node, "ApplicationPath", Request.ApplicationPath);
        this.AppendReportItem(node, "CurrentExecutionFilePath", Request.CurrentExecutionFilePath);
        this.AppendReportItem(node, "FilePath", Request.FilePath);
        this.AppendReportItem(node, "HttpMethod", Request.HttpMethod);
        this.AppendReportItem(node, "IsAuthenticated", Request.IsAuthenticated.ToString());
        this.AppendReportItem(node, "IsSecureConnection", Request.IsSecureConnection.ToString());
        this.AppendReportItem(node, "Path", Request.Path);
        this.AppendReportItem(node, "PathInfo", Request.PathInfo);
        this.AppendReportItem(node, "PhysicalApplicationPath", Request.PhysicalApplicationPath);
        this.AppendReportItem(node, "PhysicalPath", Request.PhysicalPath);
        this.AppendReportItem(node, "RawUrl", Request.RawUrl);
        this.AppendReportItem(node, "RequestType", Request.RequestType);
        this.AppendReportItem(node, "UserAgent", Request.UserAgent);
        this.AppendReportItem(node, "UserHostAddress", Request.UserHostAddress);
        this.AppendReportItem(node, "UserHostName", Request.UserHostName);
        childNode = doc.CreateElement("AcceptTypes");
        node.AppendChild(childNode);
        foreach (string type in Request.AcceptTypes)
        {
            this.AppendReportItem(childNode, null, type);
        }
        childNode = doc.CreateElement("QueryString");
        node.AppendChild(childNode);
        foreach (string keyVal in Request.QueryString.AllKeys)
        {
            this.AppendReportItem(childNode, keyVal, Request.Params[keyVal]);
        }
        childNode = doc.CreateElement("Params");
        node.AppendChild(childNode);
        foreach (string keyVal in Request.Params.AllKeys)
        {
            this.AppendReportItem(childNode, keyVal, Request.Params[keyVal]);
        }
        childNode = doc.CreateElement("ServerVariables");
        node.AppendChild(childNode);
        foreach (string keyVal in Request.ServerVariables.AllKeys)
        {
            this.AppendReportItem(childNode, keyVal, Request.ServerVariables[keyVal]);
        }
        childNode = doc.CreateElement("UserLanguages");
        node.AppendChild(childNode);
        foreach (string strLanguage in Request.UserLanguages)
        {
            this.AppendReportItem(childNode, null, strLanguage);
        }

        node = doc.CreateElement("WindowsIdentity");
        root.AppendChild(node);
        try
        {
            if ((identity = System.Security.Principal.WindowsIdentity.GetCurrent()) != null)
            {
                this.AppendReportItem(node, "IsAnonymous", (identity.IsAnonymous) ? "true" : "false");
                this.AppendReportItem(node, "IsAuthenticated", (identity.IsAuthenticated) ? "true" : "false");
                this.AppendReportItem(node, "IsGuest", (identity.IsGuest) ? "true" : "false");
                this.AppendReportItem(node, "IsSystem", (identity.IsSystem) ? "true" : "false");
                this.AppendReportItem(node, "Name", identity.Name);

                this.strUser = identity.Name;
            }
            else
                this.strUser = "Anonymous";
        }
        catch (Exception exc)
        {
            this.AppendReportItem(node, "Error", exc.ToString());
        }
        node = doc.CreateElement("Environment");
        root.AppendChild(node);
        this.AppendReportItem(node, "CommandLine", Environment.CommandLine);
        this.AppendReportItem(node, "CurrentDirectory", Environment.CurrentDirectory);
        this.AppendReportItem(node, "UserDomainName", Environment.UserDomainName);
        this.AppendReportItem(node, "UserName", Environment.UserName);
        this.AppendReportItem(node, "CommandLine", Environment.CommandLine);
        childNode = doc.CreateElement("Variables");
        node.AppendChild(childNode);
        foreach (System.Collections.DictionaryEntry de in Environment.GetEnvironmentVariables())
        {
            this.AppendReportItem(childNode, Convert.ToString(de.Key), Convert.ToString(de.Value));
        }
    }

    private void AppendReportItem(System.Xml.XmlNode node, string strName, string strValue)
    {
        System.Xml.XmlElement element;
        System.Xml.XmlAttribute attr;

        element = doc.CreateElement("Item");
        if (strName != null)
        {
            attr = doc.CreateAttribute("Name");
            attr.InnerText = strName;
            element.Attributes.Append(attr);
            element.Attributes.Append(attr);
        }
        if (strValue != null)
            element.InnerText = strValue;
        node.AppendChild(element);
    }

    protected override void RenderChildren(HtmlTextWriter writer)
    {
        System.IO.MemoryStream mstream;
        
        base.RenderChildren(writer);

        mstream = new System.IO.MemoryStream();
        doc.Save(mstream);
        writer.RenderBeginTag(HtmlTextWriterTag.Pre);
        writer.Write("\n" + HttpUtility.HtmlEncode(Encoding.UTF8.GetString(mstream.GetBuffer())));
        writer.RenderEndTag();
        mstream.Close();
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        System.IO.MemoryStream mstream;

        mstream = new System.IO.MemoryStream();
        doc.Save(mstream);
        Response.ContentType = "text/xml";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AddHeader("Content-disposition", "attachment; filename=" + System.Text.RegularExpressions.Regex.Replace(
            System.Text.RegularExpressions.Regex.Replace(Request.Url.Host + "-" + Request.UserHostName + "-" + this.strUser, @"[\s\.]", "_"), 
            @"\\", "_-") + ".xml");
        Response.Write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n");
        Response.Write(Encoding.UTF8.GetString(mstream.GetBuffer()));
        mstream.Close();
        Response.End();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Download Report" /><br />
        <h1>
            Report Details</h1>
        <br />
<script runat="server">
    
</script>
        </div>
    </form>
</body>
</html>
