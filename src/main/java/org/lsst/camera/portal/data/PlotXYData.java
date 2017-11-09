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
public class PlotXYData {

    private ArrayList<String> x;
    private ArrayList<Double> y;
    private String name;
  //  private Boolean autobinx;
   // private Integer nbinsx;
 //   private String type;
    //private ArrayList<String> text;  // list of labels when hovering

    public PlotXYData() {

        x = new ArrayList<>();
        y = new ArrayList<>();
        //text = new ArrayList<>();
       // type = "";
        //autobinx=null;
     //   nbinsx = null;
    }

    public ArrayList<String> getX() {
        return x;
    }

    public void addX(String i) {
        x.add(i);
    }
    public ArrayList<Double> getY() {
        return y;
    }

    public void addY(Double f) {
        y.add(f);
    }
    
    public void addName(String n) {
        name = n;
    }
    
    public String getName() {
        return name;
    }
    
   // public ArrayList<String> getText() {
   //     return text;
   // }
   // public void addText(String str) {
   //     text.add(str);
   // }
    
    //public void setType(String str) {
    //    type = str;
   // }

    //public String getType() {
    //    return type;
   // }
   
    /*
    public void setAutobinx(Boolean b) {
        autobinx = b;
    }
    public boolean getAutobinx() {
        return autobinx;
    }
    */
    //public Integer getNbinsx() { 
    //    return nbinsx;
   // }
   // public void setNbinsx(Integer i) {
    //    nbinsx = i;
    //}
}
