/*
 25 Feb 2016 Chee
 */
package org.lsst.camera.portal.data.examples;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;

import org.lsst.camera.portal.data.TravelerStatus;
import org.lsst.camera.portal.data.HardwareStatus;
import org.lsst.camera.portal.data.HdwStatusLoc;
import org.lsst.camera.portal.data.Activity;
import org.lsst.camera.portal.data.TravelerInfo;
import org.lsst.camera.portal.data.ReportData;
import org.lsst.camera.portal.data.TestReportPathData;
import org.lsst.camera.portal.data.ComponentData;
import org.lsst.camera.portal.data.CatalogFileData;
import org.srs.web.base.db.ConnectionManager;

import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.JexlBuilder;

public class TestJexl {
    private final Map<String, double[]> data;

    TestJexl(Map<String,double[]> data) {
        this.data = data;
    }
        
        
    public static void main(String[] args) {

        JexlEngine jexl = new JexlBuilder().create();

        Map<String, double[]> data = new HashMap<>();
        data.put("ccd-007",new double[]{3.48,3.56,9.00});
        
        
        MapContext mc = new MapContext();
        mc.set("u", new TestJexl(data));
        

        JexlExpression func = jexl.createExpression("u.format(\"%3.3g\",u.min(u.fetch(\"ccd-007\")))+\" - \"+u.format(\"%3.3g\",u.max(u.fetch(\"ccd-007\")))+\" e- rms\"");

        System.out.println(func.evaluate(mc));
    }
    
    public double[] fetch(String SpecId) {
        System.out.println(SpecId);
        return data.get(SpecId);
    }
    
    public double min(double [] args) {
        double min = Double.NaN;
        for (double a : args) {
            if (!(a>min)) min=a;
        }
        return min;
    }
    public double max(double [] args) {
        double max = Double.NaN;
        for (double a : args) {
            if (!(a<max)) max=a;
        }
        return max;
    }    
    public String format(String format, double arg) {
        return String.format(format, arg);
    }
}