
package org.lsst.camera.portal.queries;  

import org.lsst.camera.etraveler.javaclient.EtClientServices;
import org.lsst.camera.etraveler.javaclient.EtClientException;

//import junit.framework.TestCase;
//import org.junit.Before;
//import org.junit.Test;
//import org.junit.Ignore;
//import static org.junit.Assert.*;
import java.util.Map;
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
    //boolean prodServer = false;
    System.out.println("\nRunning testGetRunInfo");
    System.out.println("prodServer is " + prodServer);
    EtClientServices myService = new EtClientServices(db, null, prodServer);

    try {
      Map<String, Object> results = myService.getRunInfo(200);

 //     assertNotNull(results);
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

      //assertNotNull(results);
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
    //boolean prodServer=false;
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
    System.out.println("Arguments are travelerName=" + travelerName +
                       " hardwareType=" + hardwareType +
                       " stepName=" + stepName +
                       " schemaName=null" +
                       " experimentSN=" + experimentSN + 
                       ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getResultsJH(travelerName, hardwareType, stepName,
                               null, null, experimentSN);
      for (String cmp : results.keySet() ) {
        HashMap<String, Object> cmpResults =
          (HashMap<String, Object>) results.get(cmp);
        System.out.println("Results for " + cmp);
        //TestEtClientServices.outputRun(cmpResults);
      }
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
    System.out.println("Arguments are travelerName=" + travelerName +
                       " hardwareType=" + hardwareType +
                       " stepName=" + stepName +
                       " schemaName=" + schemaName +
                       " experimentSN=" + experimentSN + 
                       ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getResultsJH(travelerName, hardwareType, stepName,
                               schemaName, null, experimentSN);
      for (String cmp : results.keySet() ) {
        HashMap<String, Object> cmpResults =
          (HashMap<String, Object>) results.get(cmp);
        System.out.println("Results for " + cmp);
        //TestEtClientServices.outputRun(cmpResults);
      }
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
    statusL.add("stopped");
    statusL.add("new");
    
    EtClientServices myService =
      new EtClientServices(db, null, prodServer, localServer);

    try {
      HashMap<Integer, Object> results =
        myService.getMissingSignatures(statusL);
      return results;
//      for (Integer hid: results.keySet()) {
//        HashMap<String, Object> expData = (HashMap<String, Object>) results.get(hid);
        /* NOTE:  Following is  certainly not quite right. 
               At the very least, printManualSteps won't do the
               right thing since step data is an array list (of maps),
               not a map
         */
//        for (String run : expData.keySet()) {
//          HashMap<String, Object> runData =
//            (HashMap<String, Object>) expData.get(run);
          //for (String key : runData.keySet())  {
          //  if (!key.equals("steps")) {   // general run info
          //    System.out.println(key + ":" + runData.get(key));
          //  }
//          }
//          printMissingSigs((HashMap<String, Object>) runData.get("steps"));
 //       }
      //}
    } catch (Exception ex) {
      System.out.println("Post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }

  

  /* New Stuff
  @Ignore @Test
  public void testGetHardwareHierarchy() throws UnsupportedEncodingException,
                                                EtClientException, IOException {
    boolean prodServer=false;
    boolean localServer=false;
    System.out.println("Running testGetHardwareHierarchy");

    EtClientServices myService =
      new EtClientServices("Raw", null, prodServer, localServer);

    try {
      Map<String, Object> results =
        myService.getHardwareHierarchy("dessert_01", "dessert");

      assertNotNull(results);
      for (String k: results.keySet() ) {
        Object v = results.get(k);
        if (v == null) {
          System.out.println("Key '" + k + "' has value null");
        } else {
          System.out.println("Key '" + k + "' has value: " + v.toString());
        }
      }
      ArrayList< Map<String, Object> > rows =
        (ArrayList<Map<String, Object> >) results.get("hierarchy");
      for (Map <String, Object> row: rows) {
        for (String k: row.keySet() ) {
          System.out.print("Key '" + k + "': " + row.get(k).toString() + " ");
        }
        System.out.println(" ");
      }
    } catch (Exception ex) {
      System.out.println("post failed with message " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    }
    finally {
      myService.close();
    }
  }
  @Test
  public void testGetRunResults() 
    throws UnsupportedEncodingException, EtClientException, IOException {
    System.out.println("\n\nRunning testGetRunResults");
    boolean prodServer=false;
    System.out.println("prodServer is " + prodServer);
    boolean localServer=false;
    System.out.println("localServer is " + localServer);

    EtClientServices myService = new EtClientServices("Dev", null, prodServer, localServer);
    String run="4689D";

    String function="getRunResults";
    System.out.println("Arguments are run=" + run + 
                       ", function=" + function);
    // ", schema=" + schname +", step=" + stepname +
    try {
      Map<String, Object> results = 
        myService.getRunResults(run, null, null);  // , stepname, schname );
      TestEtClientServices.outputRun(results);
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }

  }



  
  
  
  @Test
  public void TestGetRunFilepaths()
    throws UnsupportedEncodingException, EtClientException, IOException {
    boolean prodServer=false;

    System.out.println("\n\nRunning testGetRunFilepaths");
    System.out.println("prodServer is " + prodServer);
    boolean localServer=false;
    System.out.println("localServer is " + localServer);

    EtClientServices myService =
      new EtClientServices("Prod", null, prodServer, localServer);

    String run="72";
    String function="getRunFilepaths";
    try {
      Map<String, Object> results = 
        myService.getRunFilepaths(run, null);

      TestEtClientServices.outputRunFiles(results);
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }

  @Test
  public void testGetFilepathsJH() 
    throws UnsupportedEncodingException, EtClientException, IOException {
    boolean prodServer=false;
    System.out.println("\n\nRunning testGetFilepathsJH");
    System.out.println("prodServer is " + prodServer);
    boolean localServer=false;
    System.out.println("localServer is " + localServer);


    EtClientServices myService =
      new EtClientServices("Prod", null, prodServer, localServer);
    String travelerName="SR-EOT-1";
    String hardwareType="ITL-CCD";
    String stepName="preflight_acq";
    String experimentSN="ITL-3800C-021";
    //String model="3800C";

    String function="getFilepathsJH";
    System.out.println("Arguments are travelerName=" + travelerName +
                       " hardwareType=" + hardwareType +
                       " stepName=" + stepName +
                       //" model=" + model +
                       " experimentSN=" + experimentSN + 
                       ", function=" + function);
    try {
      Map<String, Object> results = 
        myService.getFilepathsJH(travelerName, hardwareType, stepName,
                              null, experimentSN);
      //             model, null);
      for (String cmp : results.keySet() ) {
        HashMap<String, Object> cmpResults =
          (HashMap<String, Object>) results.get(cmp);
        System.out.println("\nResults for " + cmp);
        TestEtClientServices.outputRunFiles((Map<String, Object>)cmpResults.get("steps"));
      }
    } catch (Exception ex) {
      System.out.println("failed with exception " + ex.getMessage());
      throw new EtClientException(ex.getMessage());
    } finally {
      myService.close();
    }
  }

  
  private static void outputRun(Map<String, Object> results ) {
       System.out.println("Outer map has following non-instance key/value pairs");
    for (String k : results.keySet() ) {
      if (!k.equals("steps") ) {
        System.out.println(k + ":" + results.get(k));
      }
    }

    //Map<String, Map<String, ArrayList <Map<String, Object> > > >schemaMap;
    Map<String, Object> stepMap;
    stepMap =
      (Map<String, Object>) results.get("steps");
    for (String name : stepMap.keySet() ) {
      System.out.println("Step name " + name);
      Map<String, Object> perStep = (Map<String, Object>) stepMap.get(name); 
      for (String schname : perStep.keySet()) {
        System.out.println("  Schema name " + schname);
        ArrayList< Map<String, Object> > instances = (ArrayList< Map<String, Object> >) perStep.get(schname);
        System.out.println("  Instance array is of length " + instances.size() );
        System.out.println("  Instance data for this step/schema:");
        for (Object obj : instances) {
          Map <String, Object> m = (Map <String, Object>) obj;
          System.out.println(m);
        }
        System.out.println(" ");
      }
    }
  }

  private static void outputRunFiles(Map<String, Object> results) {
    for (String name : results.keySet() ) {
      System.out.println("Step name " + name);
      ArrayList<Map<String, Object> > instances =
        (ArrayList<Map<String, Object> >) results.get(name);
      System.out.println("  Instance array is of length " + instances.size() );
      System.out.println("  Filepath data for this step:");
      for (Object obj : instances) {
        Map <String, Object> m = (Map <String, Object>) obj;
        System.out.println(m);
      }
      System.out.println(" ");
    }
  }
  */

}


















/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/*
package org.lsst.camera.portal.queries;


import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;

// Other applications will need imports
import org.lsst.camera.etraveler.javaclient.getHarnessed.GetHarnessedData;
import org.lsst.camera.etraveler.javaclient.getHarnessed.GetHarnessedException;
import org.lsst.camera.etraveler.javaclient.getHarnessed.PerSchema;
import org.lsst.camera.etraveler.javaclient.getHarnessed.PerStep;
import org.srs.web.base.db.ConnectionManager;
*/

// Might move this to general-purpose utility to open connection
//import java.sql.DriverManager;

//import org.srs.web.base.db.ConnectionManager;

/*public class eTApi {*/

  //private Connection m_connect = null;

  /**
     Get data for one CCD, one schema
   */
/*
    public static Map getOne(HttpSession session) throws GetHarnessedException, SQLException {
        Connection m_connect=null;
        try {
            System.out.println("Running test getOne");
            m_connect = ConnectionManager.getConnection(session);

            GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

            Map<String, Object> results
                    = getHarnessed.getResultsJH("SR-EOT-1", "ITL-CCD", "read_noise",
                            null, "ITL-3800C-021", null);
            return results;
//            System.out.println("Found results for these components: ");
//            ArrayList<String> cmps = new ArrayList<String>();
//            for (String expSN : results.keySet()) {
//                cmps.add(expSN);
//                System.out.print(" " + expSN);
//            }

//            for (Object expObject : results.values()) {
//                HashMap<String, Object> expMap = (HashMap<String, Object>) expObject;
//                printRunResultsAll(expMap);
//            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (m_connect != null) {
                //Close the connection
                m_connect.close();
            }
        }
 //       return result;
    }
END of new stuff HMK */
  /**
     Get data for all CCDs with specified model, one schema
   */
    /*
  public void getModel() throws GetHarnessedException, SQLException {

    System.out.println("Running test getModel");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    Map<String, Object> results =
      getHarnessed.getResultsJH("SR-EOT-1", "ITL-CCD", "read_noise",
                                "3800C", null, null);
    System.out.println("Found results for these components: ");
    ArrayList<String> cmps = new ArrayList<String>();
    for (String expSN : results.keySet() ) {
      cmps.add(expSN);
      System.out.print(" " + expSN);
    }
    System.out.println("");
    int iExp = 0;
    for (Object expObject : results.values() ) {
      HashMap<String, Object> expMap = (HashMap<String, Object>) expObject;
      printRunResultsAll(expMap);
      iExp++;
      if (iExp > 3) break;
    }
  }
*/
  /**
   *
   * @throws GetHarnessedException
   * @throws SQLException
   */
  /**
     Get data for all CCDs with specified model, one schema, filter on "amp"
   */
    
    /*
  public void getModelAmp3() throws GetHarnessedException, SQLException {

    System.out.println("Running test getModelAmp3");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);
    String tname="SR-EOT-1";
    String htype="ITL-CCD";
    String schname="read_noise";
    String model="3800C";
    Pair<String, Object> filter =
      new ImmutablePair<String, Object>("amp", 3);
    Map<String, Object> results =
      getHarnessed.getResultsJH(tname, htype, schname,
                                model, null, filter);

    printJHResults(results);
  }


  public void getRaftOneCCD() throws GetHarnessedException, SQLException {

    System.out.println("Running test getRaftOneCCD");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    String tname="SR-RTM-EOT-03";
    String htype="LCA-11021_RTM";
    String schname="fe55_raft_analysis";
    String expSN="LCA-11021_RTM-004_ETU2-Dev";
    Pair<String, Object> filter =
      new ImmutablePair<String, Object>("sensor_id", "ITL-3800C-102-Dev");
    System.out.println("Calling getResultsJH with ");
    System.out.println("  traveler name = " + tname);
    System.out.println("  htype name    = " + htype);
    System.out.println("  schema name   = " + schname);
    System.out.println("  experimentSN  = " + expSN);
    System.out.println("  filter        = (" + filter.getLeft() + ", " + filter.getRight() + ")");
    Map<String, Object> results =
      getHarnessed.getResultsJH(tname, htype, schname, null, expSN, filter);
    printJHResults(results);
  }

  public void getRaftVersions() throws GetHarnessedException, SQLException {

    String tname="SR-RTM-EOT-03";
    String htype="LCA-11021_RTM";
    String schname="package_versions";
    String expSN="LCA-11021_RTM-004_ETU2-Dev";
      
    System.out.println("Running test getRaftVersions");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    System.out.println("Calling getResultsJH with ");
    System.out.println("  traveler name = " + tname);
    System.out.println("  htype name    = " + htype);
    System.out.println("  schema name   = " + schname);
    System.out.println("  experimentSN  = " + expSN);
    
    Map<String, Object> results =
      getHarnessed.getResultsJH(tname, htype, schname, null, expSN, null);

    printJHResults(results);
  }

  public void getRaftOneAmp() throws GetHarnessedException, SQLException {
    String tname="SR-RTM-EOT-03";
    String htype="LCA-11021_RTM";
    String schname="fe55_raft_analysis";
    String expSN="LCA-11021_RTM-004_ETU2-Dev";
    
    System.out.println("Running test getRaftOneAmp");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    Pair<String, Object> filter =
      new ImmutablePair<String, Object>("amp", 3);

    System.out.println("Calling getResultsJH with ");
    System.out.println("  traveler name = " + tname);
    System.out.println("  htype name    = " + htype);
    System.out.println("  schema name   = " + schname);
    System.out.println("  experimentSN  = " + expSN);
    System.out.println("  filter        = (" + filter.getLeft() + ", " + filter.getRight() + ")");

    Map<String, Object> results =
      getHarnessed.getResultsJH(tname, htype, schname, null, expSN, filter);
    printJHResults(results);
  }

  public void getRaftRun()  throws GetHarnessedException, SQLException {

    String run="4689D";
    String schname="fe55_raft_analysis";
    System.out.println("Running test getRaftRun");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    Pair<String, Object> filter =
      new ImmutablePair<String, Object>("sensor_id", "ITL-3800C-102-Dev");
    
    System.out.println("Calling getRunResults with ");
    System.out.println("  run           = " + run);
    System.out.println("  schema name   = " + schname);
    System.out.println("  filter        = (" + filter.getLeft() + ", " + filter.getRight() + ")");
    
    Map<String, Object> results =
      getHarnessed.getRunResults(run, schname, filter);
    printRunResultsAll(results);
  }

  public void getVersionsRun() throws GetHarnessedException, SQLException {

    System.out.println("Running test getVersionsRun");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    Map<String, Object> results =
      getHarnessed.getRunResults("4689D", "package_versions", null);
    printRunResultsAll(results);
  }
  
  public void getAllRun() throws GetHarnessedException, SQLException {

    String run="4689D";

    
    System.out.println("Running test getAllRun");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    System.out.println("Calling getRunResults with ");
    System.out.println("  run           = " + run);
    
    Map<String, Object> results =
      getHarnessed.getRunResults("4689D", null);
    printRunResultsAll(results);
  }

  public void getAllRunFiltered() throws GetHarnessedException, SQLException {

    String run="4689D";
    System.out.println("Running test getAllRunRiltered");
    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);

    Pair<String, Object> filter =
      new ImmutablePair<String, Object>("sensor_id", "ITL-3800C-102-Dev");
    System.out.println("Calling getRunResults with ");
    System.out.println("  run           = " + run);
    System.out.println("  filter        = (" + filter.getLeft() + ", " + filter.getRight() + ")");

    Map<String, Object> results =
      getHarnessed.getRunResults(run, filter);
    printRunResultsAll(results);
  }

  public void getRunFilepaths() throws GetHarnessedException, SQLException {

    System.out.println("Running test getRunFilepaths");
    String run="4689D";
    String stepName = null;
    System.out.println("Calling getRunFilepaths for run=" + run + ", all steps");
    Map<String, ArrayList<String>> results = null;

    GetHarnessedData getHarnessed = new GetHarnessedData(m_connect);
    
    results = getHarnessed.getFilepaths(run, stepName);
    for (String s : results.keySet()) {
      ArrayList<String> list = results.get(s);
      System.out.println("\nFor stepname=" + s + " have " + list.size() + " files ");
      for (String path : list) {
        System.out.println("  " + path);
      }
    }
  }
    
  */
/*
  private static void printJHResults(Map<String, Object> results) {
        System.out.println("Found results for these components: ");
    ArrayList<String> cmps = new ArrayList<String>();
    for (String expSN : results.keySet() ) {
      cmps.add(expSN);
      System.out.print(" " + expSN);
    }
    System.out.println("");

    Map<String, Object> first = (Map<String, Object>) results.get(cmps.get(0));
    System.out.println("Component map has the following keys ");
    for (String k : first.keySet() ) {
      System.out.println(" " + k);
    }

    for (Object expObject : results.values() ) {
      HashMap<String, Object> expMap = (HashMap<String, Object>) expObject;
      printRunResultsAll(expMap);
    }

  }
*/
  /* For all-schema data */
/*
  private static void printRunResultsAll(Map<String, Object> results) {
    System.out.println("Outer map has following non-instance key/value pairs");
    for (String k : results.keySet() ) {
      if (!k.equals("steps") ) {
        System.out.println(k + ":" + results.get(k));
      }
    }

    //Map<String, Map<String, ArrayList <Map<String, Object> > > >schemaMap;
    Map<String, PerStep > stepMap;
    stepMap =
      (Map<String, PerStep>) results.get("steps");
    for (String name : stepMap.keySet() ) {
      System.out.println("Step name " + name);
      PerStep perStep = stepMap.get(name); 
      for (String schname : perStep.keySet()) {
        System.out.println("  Schema name " + schname);
        ArrayList<HashMap <String, Object> > instances =
          perStep.get(schname).getArrayList();
        System.out.println("  Instance array is of length " + instances.size() );
        System.out.println("  Instance data for this step/schema:");
        for (Map <String, Object> m : instances) {
          System.out.println(m);
        }
        System.out.println(" ");
      }
    }
  }

}
*/