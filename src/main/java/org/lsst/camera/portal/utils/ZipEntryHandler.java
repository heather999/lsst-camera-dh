package org.lsst.camera.portal.utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.sql.Timestamp;
import java.util.zip.ZipEntry;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Handler for entries within a zip file.
 * @author tonyj
 */
public class ZipEntryHandler extends SimpleTagSupport {

    private String name;
    private String urlPath;
    private Timestamp ts;
    private String comment;

    /**
     * Called by the container to invoke this tag. The implementation of this
     * method is provided by the tag library developer, and handles all tag
     * processing, body iteration, etc.
     * @throws javax.servlet.jsp.JspException
     */
    @Override
    public void doTag() throws JspException {
        try {
            ZipFileHandler zip = (ZipFileHandler) findAncestorWithClass(this, ZipFileHandler.class);
            if (zip == null) {
                throw new JspException("entry tag not nested inside zip tag");
            }
            final ZipEntry entry = new ZipEntry(name);
            if (ts != null) entry.setTime(ts.getTime());
            if (comment != null) entry.setComment(comment);
            OutputStream out = zip.addEntry(entry);
            URL url = new URL(urlPath);
            byte[] buffer = new byte[32768];
            try (InputStream in = url.openStream()) {
                for (;;) {
                    int l = in.read(buffer);
                    if (l < 0) {
                        break;
                    }
                    out.write(buffer, 0, l);
                }
            }
        } catch (IOException x) {
            throw new JspException("Error processing zip entry", x);
        }

    }

    public void setName(String name) {
        this.name = name;
    }

    public void setUrl(String url) {
        this.urlPath = url;
    }
    
    public void setCreateDate(Timestamp ts) {
        this.ts = ts;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
