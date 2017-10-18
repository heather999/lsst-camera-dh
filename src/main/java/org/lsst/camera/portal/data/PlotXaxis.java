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
public class PlotXaxis {

    private String title;
   

    public PlotXaxis() {
        title = "";
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String str) {
         title = str;
    }
   
}
