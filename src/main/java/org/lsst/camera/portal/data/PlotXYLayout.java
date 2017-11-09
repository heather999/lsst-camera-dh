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
public class PlotXYLayout {

    private String title;
    private PlotXaxis xaxis;
    private PlotYaxis yaxis;
   

    public PlotXYLayout() {
        xaxis = new PlotXaxis();
        yaxis = new PlotYaxis();
        title = "";
    }

    public PlotXaxis getXaxis() {
        return xaxis;
    }
    
    public PlotYaxis getYaxis() {
        return yaxis;
    }
    
    public String getTitle() {
        return title;
    }

    public void setTitle(String str) {
         title = str;
    }
   
}
