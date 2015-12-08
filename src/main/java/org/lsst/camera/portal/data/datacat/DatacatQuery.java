package org.lsst.camera.portal.data.datacat;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
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

    public static Client getClient(String datacatUrl, HttpServletRequest request) throws IOException{
        try {
            String userName = (String) request.getSession().getAttribute("userName"); // From LoginFilter
            Map<String, Object> headers = new HashMap<>();
            headers.put("x-cas-username", userName); // This machine must be trusted (this won't work locally)
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
        String datacatUrl = "http://srs.slac.stanford.edu/datacat-v0.4/r";
        Client dcClient = getClient(datacatUrl, request);

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

                    String query = String.
                            format(queryFormat, dataProduct, testCategory, origin, sensorId);

                    List<DatasetModel> results = new ArrayList<>();
                    for(String pattern: folderPatterns.get(vendor)){
                        results.addAll(dcClient.
                                searchForDatasets(pattern, null, null, query, null, null, 0, 1000).
                                getResults());
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

}