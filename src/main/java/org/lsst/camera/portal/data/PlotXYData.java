/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author heather
 */
//@JsonInclude(Include.NON_NULL)
public class PlotXYData {


    public class Line {
        public String width="2";
        public String dash="solid";
        public void setDash(String d) {dash=d;}
        public String getDash() {return dash;}
        public void setWidth(String w) {width=w;}
        public String getWidth() {return width;}
    }
    
    private ArrayList<String> x;
    private ArrayList<Double> y;
    private ArrayList<String> text = null;
    private String name;
    private String mode="lines+markers";
    private Line line;
  //  private Boolean autobinx;
   // private Integer nbinsx;
 //   private String type;
    //private ArrayList<String> text;  // list of labels when hovering

    public PlotXYData() {

        x = new ArrayList<>();
        y = new ArrayList<>();
        line = new Line();
        //line = new Line();

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

    public ArrayList<String>getText() {
        return text;
    }

    public void addText(String t) {
        if (text == null)  text = new ArrayList<>();
        text.add(t);
    }
    
    public void addName(String n) {
        name = n;
    }
    
    public String getName() {
        return name;
    }

    public PlotXYData.Line getLine() {return line;}


    public void setMode(String m) {
        mode=m;
    }

    public String getMode() {
        return mode;
    }
    
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
