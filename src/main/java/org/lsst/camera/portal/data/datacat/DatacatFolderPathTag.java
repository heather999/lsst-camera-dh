package org.lsst.camera.portal.data.datacat;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 *
 * @author tonyj
 */
public class DatacatFolderPathTag extends SimpleTagSupport {

    private String value;

    @Override
    public void doTag() throws JspException {
        DatacatQueryTag query = (DatacatQueryTag) findAncestorWithClass(this,DatacatQueryTag.class);
        query.setFolderPath(value);
    }

    public void setValue(String value) {
        this.value = value;
    }
    
}
