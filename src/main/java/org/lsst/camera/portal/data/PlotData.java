/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.ArrayList;

/**
 *
 * @author heather
 */
public class PlotData {

    private ArrayList<Integer> x;
    private String type;
    

    public PlotData() {

        x = new ArrayList<>();
        type = "histogram";
    }

    public ArrayList<Integer> getX() {
        return x;
    }

    public void addX(Integer i) {
        x.add(i);
    }

    public String getType() {
        return type;
    }
   
}
