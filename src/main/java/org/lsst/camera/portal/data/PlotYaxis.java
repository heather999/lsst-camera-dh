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
public class PlotYaxis {

    private String title;
    private String type;
   

    public PlotYaxis() {
        title = "";
        type = "";
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String str) {
         title = str;
    }
    
    public void setType(String str ) {
        type = str;
    }
    public String getType() {
        return type;
    }
   
}
