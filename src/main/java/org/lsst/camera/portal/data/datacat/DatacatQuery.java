package org.lsst.camera.portal.data.datacat;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import javax.servlet.http.HttpServletRequest;
import org.glassfish.jersey.filter.LoggingFilter;
import org.srs.datacat.client.Client;
import org.srs.datacat.client.ClientBuilder;
import org.srs.datacat.client.auth.HeaderFilter;
import org.srs.datacat.client.exception.DcException;
import org.srs.datacat.model.DatasetModel;

/**
 *
 * @author bvan
 */
public class DatacatQuery {

    public static Client getClient(HttpServletRequest request) throws IOException{
        String datacatUrl = "http://srs.slac.stanford.edu/datacat-v0.4/r";
        try {
            String userName = (String) request.getSession().getAttribute("userName"); // From LoginFilter
            Map<String, Object> headers = new HashMap<>();

            String srsClientId = System.getProperty("org.lsst.camera.portal.srs_client_id");
            if(srsClientId != null){
                headers.put("x-client-id", srsClientId); // This web applications has a clientId which should be trusted
            } else {
                headers.put("x-cas-username", userName); // This machine should be trusted (this won't work locally)
            }

            return ClientBuilder.newBuilder()
                    .setUrl(datacatUrl)
                    .addClientRequestFilter(new LoggingFilter())
                    .addClientRequestFilter(new HeaderFilter(headers))
                    .build();
        } catch(URISyntaxException ex) {
            throw new IOException(ex);
        }
    }

    public static List<DatasetModel> getDatasets(HttpServletRequest request) throws IOException{
        Client dcClient = getClient(request);

        List<String> sensorIds = Arrays.asList(
                "e2v-CCD250-11093-10-04",
                "ITL-3800C-033",
                "ITL-3800C-042",
                "ITL-3800C-107",
                "ITL-3800C-126");

        String dataProduct = "TEST_REPORT";
        String testCategory = "EO";
        List<String> origins = Arrays.asList("BNL", "SLAC", "e2v technologies (UK)", "UAITL");

        HashMap<String, List<String>> folderPatterns = new HashMap<>();
        folderPatterns.put("ITL", Arrays.
                asList("/LSST/mirror/SLAC-test/test/ITL-CCD/**", "/LSST/vendorData/ITL/**"));
        folderPatterns.put("e2v", Arrays.
                asList("/LSST/mirror/SLAC-test/test/e2v-CCD/**", "/LSST/vendorData/e2v/**"));

        try {
            List<DatasetModel> allResults = new ArrayList<>();
            for(String sensorId: sensorIds){
                String vendor = sensorId.split("-")[0];

                for(String origin: origins){
                    String queryFormat = "DATA_PRODUCT=='%s' && TEST_CATEGORY=='%s' && ORIGIN=='%s' && LSST_NUM=='%s'";

                    String query = String.format(queryFormat, dataProduct, testCategory, origin, sensorId);

                    List<DatasetModel> results = new ArrayList<>();
                    for(String pattern: folderPatterns.get(vendor)){
                        results.addAll(dcClient.searchForDatasets(pattern, null, null, query, null, null, 0, 1000).getResults());
                    }

                    for(DatasetModel result: results){
                        System.out.println(String.format("   %s: %s", origin, result.getPath()));
                    }
                    allResults.addAll(results);
                }

            }
            return allResults;

        } catch(DcException ex) {
            ex.printStackTrace();;
            throw ex;
        }
    }

    public static List<DatasetModel> findDatasets(HttpServletRequest request, String sensorId,
            Map<String, String> dataId, List<String> folderPatterns, List<String> show) throws IOException{

        Client dcClient = getClient(request);
        StringBuilder query = new StringBuilder();

        query.append(String.format("LSST_NUM=='%s'", sensorId));
        for(Entry<String, String> e: dataId.entrySet()){
            query.append(" && ")
                    .append(String.format("%s=='%s'", e.getKey(), e.getValue()));
        }
        List<DatasetModel> allResults = new ArrayList<>();
        String[] showArr = show != null && !show.isEmpty() ? show.toArray(new String[0]) : null;
        for(String folderPattern: folderPatterns){
            allResults.addAll(
                    dcClient.
                    searchForDatasets(folderPattern, null, null, query.toString(), null, showArr).
                    getResults()
            );
        }
        return allResults;
    }

    public static List<DatasetModel> getReportDatasets(HttpServletRequest request) throws IOException{
        String e2v_sensor = "e2v-CCD250-11093-10-04";
        List<String> folder_patterns = Arrays.
                asList("/LSST/mirror/SLAC-test/test/e2v-CCD/**", "/LSST/vendorData/e2v/**");
        Map<String, String> dataId = new HashMap<>();
        dataId.put("DATA_PRODUCT", "TEST_REPORT");
        dataId.put("EST_CATEGORY", "EO");
        
        // Actual type should be DatasetWithViewModel
        List<DatasetModel> reportDatasets = findDatasets(request, e2v_sensor,
                dataId,
                folder_patterns,
                Arrays.asList("ORIGIN"));

        return reportDatasets;
    }

    public static List<DatasetModel> getMosaicDatasets(HttpServletRequest request) throws IOException{

        String e2v_sensor = "e2v-CCD250-11093-10-04";

        Map<String, String> dataId = new HashMap<>();
        dataId.put("DATA_PRODUCT", "CCD_MOSAIC");
        dataId.put("PRODUCER", "SR-EOT-02");
        dataId.put("TEST_CATEGORY", "EO");

        // Actual type should be DatasetWithViewModel
        List<DatasetModel> mosaicDatasets = findDatasets(request, e2v_sensor,
                dataId,
                Arrays.asList("/LSST/mirror/SLAC-test/test/e2v-CCD/**"),
                Arrays.asList("SCHEMA_NAME", "TESTTYPE")
        );
        return mosaicDatasets;
    }
    
    
    public static List<DatasetModel> getAmpResultDatasets (HttpServletRequest request) throws IOException{

        String e2v_sensor = "e2v-CCD250-11093-10-04";

        Map<String, String> dataId = new HashMap<>();
        dataId.put("DATA_PRODUCT", "AMP_RESULTS");
        dataId.put("ORIGIN", "SLAC");
        dataId.put("PRODUCER", "SR-EOT-02");
        dataId.put("TEST_CATEGORY", "EO");

        // Actual type is DatasetWithViewModel
        List<DatasetModel> ampResultDatasets = findDatasets(request, e2v_sensor,
                dataId,
                Arrays.asList("/LSST/mirror/SLAC-test/test/e2v-CCD/**"),
                Arrays.asList("SCHEMA_NAME", "TESTTYPE")
        );
        return ampResultDatasets;
    }

}
