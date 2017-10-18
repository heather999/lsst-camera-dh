/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import java.util.ArrayList;

/**
 *
 * @author heather
 */
//@JsonInclude(Include.NON_NULL)
public class PlotData {

    private ArrayList<Integer> x;
    private Boolean autobinx;
    private Integer nbinsx;
    private String type;
    

    public PlotData() {

        x = new ArrayList<>();
        type = "";
        //autobinx=null;
        nbinsx = null;
    }

    public ArrayList<Integer> getX() {
        return x;
    }

    public void addX(Integer i) {
        x.add(i);
    }
    
    public void setType(String str) {
        type = str;
    }

    public String getType() {
        return type;
    }
   
    /*
    public void setAutobinx(Boolean b) {
        autobinx = b;
    }
    public boolean getAutobinx() {
        return autobinx;
    }
    */
    public Integer getNbinsx() { 
        return nbinsx;
    }
    public void setNbinsx(Integer i) {
        nbinsx = i;
    }
}
