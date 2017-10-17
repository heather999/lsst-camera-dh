
package org.lsst.camera.portal.queries;  

import org.lsst.camera.etraveler.javaclient.EtClientServices;
import org.lsst.camera.etraveler.javaclient.EtClientException;

import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.List;
import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

// Could make handling output a little nicer but not as they stand
//import org.lsst.camera.etraveler.javaclient.getHarnessed.PerSchema;
//import org.lsst.camera.etraveler.javaclient.getHarnessed.PerStep;


import java.io.UnsupportedEncodingException;

public class eTApi {

  private HashMap<String, Object> m_params;

  
  public static Map getRunInfo(String db, Boolean prodServer) throws UnsupportedEncodingException,
                                      EtClientException, IOException {
    System.out.println("\nRunning testGetRunInfo");
    System.out.println("prodServer is " + prodServer);
    EtClientServices myService = new EtClientServices(db, null, prodServer);

    try {
      Map<String, Object> results = myService.getRunInfo(200);

      for (String k: results.keySet() ) {
        Object v = results.get(k);
        if (v == null) {
          System.out.println("Key '" + k + "' has value null");
        } else {
          System.out.println("Key '" + k + "' has value: " + v.toString());
        }
      }
      return results;
    } catch (Exception ex) {
      System.out.println("post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    }
    finally {
      myService.close();
    }
  }

  
  
  public static Map getManufacturerId(String db, Boolean prodServer) throws UnsupportedEncodingException,
                                      EtClientException, IOException {

    //boolean prodServer=false;
    System.out.println("\nRunning testGetManufacturerId");
    System.out.println("prodServer is " + prodServer);

    //EtClientServices myService = new EtClientServices("Dev", null, false, true);
    EtClientServices myService = new EtClientServices(db, null, prodServer);

    try {
      Map<String, Object> results =
        myService.getManufacturerId("E2V-CCD250-179", "e2v-CCD");

      for (String k: results.keySet() ) {
        Object v = results.get(k);
        if (v == null) {
          System.out.println("Key '" + k + "' has value null");
        } else {
          System.out.println("Key '" + k + "' has value: " + v.toString());
        }
      }
      return results;
    } catch (Exception ex) {
      System.out.println("post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    }
    finally {
      myService.close();
    }
  }
  
  
  
    public static Map getRunSchemaResults(String db, Boolean prodServer) 
    throws UnsupportedEncodingException, EtClientException, IOException {
   
    System.out.println("\n\nRunning testGetRunSchemaResults");
    System.out.println("prodServer is " + prodServer);
    boolean localServer=false;
    System.out.println("localServer is " + localServer);

    EtClientServices myService =
      new EtClientServices(db, null, prodServer, localServer);
    String run="4689D";
    String schname="fe55_raft_analysis";
    String function="getRunResults";
    System.out.println("Arguments are run=" + run + 
                       ", schema=" + schname +
                       ", step=null" + 
                       ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getRunResults(run, null, schname);
      return results;
     // TestEtClientServices.outputRun(results);
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }

  }
    
    
   public static Map getResultsJH(String db, Boolean prodServer) 
    throws UnsupportedEncodingException, EtClientException, IOException {
    System.out.println("\n\nRunning testGetResultsJH");
    System.out.println("prodServer is " + prodServer);
    boolean localServer=false;
    System.out.println("localServer is " + localServer);

    EtClientServices myService =
      new EtClientServices(db, null, prodServer, localServer);
    String travelerName="SR-EOT-1";
    String hardwareType="ITL-CCD";
    String stepName="read_noise";
    String experimentSN="ITL-3800C-021";

    String function="getResultsJH";
    //System.out.println("Arguments are travelerName=" + travelerName +
    //                   " hardwareType=" + hardwareType +
    //                   " stepName=" + stepName +
    //                   " schemaName=null" +
    //                   " experimentSN=" + experimentSN + 
    //                   ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getResultsJH(travelerName, hardwareType, stepName,
                               null, null, experimentSN);
      //for (String cmp : results.keySet() ) {
       // HashMap<String, Object> cmpResults =
       //   (HashMap<String, Object>) results.get(cmp);
       // System.out.println("Results for " + cmp);
        //TestEtClientServices.outputRun(cmpResults);
      return results;
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }
  
   
  public static Map getResultsJH_schema(String db, Boolean prodServer, String travelerName, String hardwareType,
          String stepName, String schemaName, String experimentSN) 
    throws UnsupportedEncodingException, EtClientException, IOException {

    EtClientServices myService =
      new EtClientServices(db, null, prodServer);
    

    String function="getResultsJH";
   // System.out.println("Arguments are travelerName=" + travelerName +
   //                    " hardwareType=" + hardwareType +
   //                    " stepName=" + stepName +
   //                    " schemaName=" + schemaName +
   //                    " experimentSN=" + experimentSN + 
   //                    ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getResultsJH(travelerName, hardwareType, stepName,
                               schemaName, null, experimentSN);
     // for (String cmp : results.keySet() ) {
     //   HashMap<String, Object> cmpResults =
     //     (HashMap<String, Object>) results.get(cmp);
     //   System.out.println("Results for " + cmp);
        //TestEtClientServices.outputRun(cmpResults);
      //}
      return results;
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }
  
  
  public static Map getMissingSignatures(String db)
    throws UnsupportedEncodingException, EtClientException, IOException {
    boolean prodServer = true;
    boolean localServer = false;
    //String appSuffix="-jrb";
    
    ArrayList<String> statusL = new ArrayList<>();
    statusL.add("inProgress");
    statusL.add("paused");
    
    EtClientServices myService =
      new EtClientServices(db, null, prodServer, localServer);

    try {
      HashMap<Integer, Object> results =
        myService.getMissingSignatures(statusL);
      return results;
    } catch (Exception ex) {
      System.out.println("Post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }


  public static ArrayList<HashMap<String,Object>> getHardwareInstances(String htype, Boolean prodServer, String db, Set labels) throws UnsupportedEncodingException,
                                        EtClientException, IOException {
    
      //boolean localServer = true;
    
    //HashSet<String> labels = new HashSet<String>();
    //labels.add("SnarkRandom:");
    
    EtClientServices myService =
      new EtClientServices(db, null, prodServer);

    try {
      ArrayList< HashMap<String, Object> > results = myService.getHardwareInstances(htype, null, labels);
      for (HashMap<String, Object> cmp : results) {
        System.out.println("\n Next component:");
        for (String key : cmp.keySet()) {
          System.out.println(key + ":" + cmp.get(key));
        }
      }
      return results;
    } catch (Exception ex) {
      System.out.println("Post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }
  
  
 
public static Map getContainingHardware(String db, Boolean prodServer, String experimentSN, String hardwareTypeName) 
            throws UnsupportedEncodingException, EtClientException, IOException {

    EtClientServices myService = new EtClientServices(db, null, prodServer);

    try {
      Map<String, Object> results =
        myService.getContainingHardwareHierarchy(experimentSN, hardwareTypeName);
      return results;   
      
    } catch (Exception ex) {
      System.out.println("post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    }
    finally {
      myService.close();
    }
  }

    public static Map getComponentRuns(String db, String hdwType, String lsstNum, String travName) 
            throws UnsupportedEncodingException, EtClientException, IOException {
        boolean prodServer = true;

        EtClientServices myService
                = new EtClientServices(db, null, prodServer);

        try {
            Map<Integer, Object> results
                    = myService.getComponentRuns(hdwType, lsstNum, travName);
//            for (Integer raid : results.keySet()) {
 //               System.out.println("\n For run with raid " + raid);
 //               HashMap<String, Object> runInfo = (HashMap<String, Object>) results.get(raid);
 //               for (String key : runInfo.keySet()) {
  //                  System.out.println(key + ":" + runInfo.get(key));
  //              }
  //          }
            return results;
        } catch (Exception ex) {
            System.out.println("Post failed with message " + ex.getMessage());
            return null;
        } finally {
            myService.close();
        }

    }

}
