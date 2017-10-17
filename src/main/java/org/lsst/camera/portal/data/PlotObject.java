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
public class PlotObject {

    private PlotData data;
    private PlotLayout layout;
    

    public PlotObject() {

        data = new PlotData();
        layout = new PlotLayout();
        
    }

    public PlotData getData() {
        return data;
    }

    
  public void addXData(Integer i) {
      data.addX(i);
  }

  public PlotLayout getLayout() {
      return layout;
  }
  
}
