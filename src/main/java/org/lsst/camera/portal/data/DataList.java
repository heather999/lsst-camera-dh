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
public class DataList extends ArrayList {

    //private ArrayList<Object> list = new ArrayList<Object>();
    //private String lsstId;

    public void setChild(Object object) {
        this.add(object);
    }

    //public String getlsstId() {
    //    return this.lsstId;
    //}
    
    public ArrayList<Object> getList() {
        return this;
    }
   
}