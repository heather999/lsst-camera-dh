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
public class PlotXYObject {

    private PlotXYData data;
    private PlotXYLayout layout;
    

    public PlotXYObject() {

        data = new PlotXYData();
        layout = new PlotXYLayout();
        
    }

    public PlotXYData getData() {
        return data;
    }

  public PlotXYLayout getLayout() {
      return layout;
  }
  
}
