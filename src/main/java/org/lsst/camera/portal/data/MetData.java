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
    private String description;
    private String specification;
    
    private String vendorVendor;
    private Boolean vendvendStat;
    
    private String vendorLsst;
    private Boolean vendlsstStat;
    
    private String lsstLsst;
    private Boolean lsstlsstStat;
    
    
    public MetData(String sId, String d, String spec) {
        
        this.specId = sId == null || "".equals(sId) ? "NA" : sId;        
        this.description = d == null || "".equals(d) ? "NA" : d;
        this.specification = spec == null || "".equals(spec) ? "NA" : spec;
        
        vendorVendor = "NA";
        vendorLsst = "NA";
        lsstLsst = "NA";
        
        vendvendStat = false;
        vendlsstStat = false;
        lsstlsstStat = false;
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
    public String getDescription() {
        return description;
    }
    public String getSpecification() {
        return specification;
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
