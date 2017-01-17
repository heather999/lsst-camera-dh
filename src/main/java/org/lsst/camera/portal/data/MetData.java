/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
/**
 *
 * @author heather
 */
public class MetData {

    private String specId;
    private String vendvendDescription;
    private String vendlsstDescription;
    private String vendvendSpecification;
    private String vendlsstSpecification;

    private String vendorVendor;
    private Boolean vendvendStat;
    
    private String vendorLsst;
    private Boolean vendlsstStat;
    
    private String lsstLsst;
    private Boolean lsstlsstStat;
    
    
    public MetData(String sId, String d, String spec) {
        
        this.specId = sId == null || "".equals(sId) ? "NA" : sId;        
        this.vendvendDescription = d == null || "".equals(d) ? "NA" : d;
        this.vendvendSpecification = spec == null || "".equals(spec) ? "NA" : spec;
        
        vendlsstSpecification = "";
        
        vendorVendor = "NA";
        vendorLsst = "NA";
        lsstLsst = "";
        
        vendvendStat = null;
        vendlsstStat = null;
        lsstlsstStat = null;
    }
    
    public void setVendlsstDescription(String d) {
         this.vendlsstDescription = d == null || "".equals(d) ? "NA" : d;
    }
 
    public void setVendlsstSpecification(String spec) {
         this.vendlsstSpecification = spec == null || "".equals(spec) ? "NA" : spec;
    }

    public void setVendorLsst(String vl, Boolean vlStat) {
        vendorLsst = vl == null || "".equals(vl) ? "NA" : vl;
        vendlsstStat = vlStat;
    }
    
    public void setVendorVendor(String vv, Boolean vvStat) {
        vendorVendor = vv == null || "".equals(vv) ? "NA" : vv;
        vendvendStat = vvStat;
    }
    
     public void setLsstLsst(String ll, Boolean llStat) {
        lsstLsst = ll == null || "".equals(ll) ? "NA" : ll;
        lsstlsstStat = llStat;
    }

    public String getSpecId() {
         return specId;
    }
    public String getVendvendDescription() {
        return vendvendDescription;
    }
    public String getVendvendSpecification() {
        return vendvendSpecification;
    }
    
    public String getVendlsstDescription() {
        return vendlsstDescription;
    }
    public String getVendlsstSpecification() {
        return vendlsstSpecification;
    }
    
    public String getVendorVendor () {
        return vendorVendor;
    }
    public Boolean getVendvendStat () {
        return vendvendStat;
    }
    
    public String getVendorLsst() {
        return vendorLsst;
    }
    public Boolean getVendlsstStat() {
        return vendlsstStat;
    }
    
    public String getLsstLsst() {
        return lsstLsst;
    }
    public Boolean getLsstlsstStat() {
        return lsstlsstStat;
    }
     
}
