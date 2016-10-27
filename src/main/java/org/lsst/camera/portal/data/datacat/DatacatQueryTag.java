package org.lsst.camera.portal.data.datacat;

import java.io.StringWriter;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.srs.datacat.client.Client;
import org.srs.datacat.model.DatasetModel;

/**
 * Implements the data catalog query tag
 *
 * @author tonyj
 */
public class DatacatQueryTag extends SimpleTagSupport {

    private String var;
    private String folderPath;

    @Override
    public void doTag() throws JspException {
        StringWriter writer = new StringWriter();
        try {

            JspFragment f = getJspBody();
            if (f != null) {
                f.invoke(writer);
            }
            String query = writer.toString().trim();
            if (query.length()==0) query = null;
            JspContext pageContext = this.getJspContext();
            Client client = (Client) pageContext.getAttribute("DatacatClient", PageContext.SESSION_SCOPE);
            if (client == null) {
                client = DatacatQuery.getClient((HttpServletRequest) ((PageContext) pageContext).getRequest());
                pageContext.setAttribute("DatacatClient", client, PageContext.SESSION_SCOPE);
            }
            List<DatasetModel> results = client.searchForDatasets(folderPath, null, null, query, null, null, 0, 1000).getResults();
            pageContext.setAttribute(var, results);
        } catch (java.io.IOException ex) {
            throw new JspException("Error in DatacatQueryTag tag", ex);
        }
    }

    public void setVar(String var) {
        this.var = var;
    }

    void setFolderPath(String value) {
        this.folderPath = value;
    }

}
