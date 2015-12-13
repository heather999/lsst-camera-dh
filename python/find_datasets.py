import os
import datacat

def find_datasets(dataId, folder_patterns, show=None):
    """
    @return A list of datasets for a given set of key value pairs.
    @param dataId A dictionary containing the Data Catalog metadata
                  key/value pairs for identifying the desired data files.
    @param folder_patterns A list or tuple of Data Catalog folder patterns
                  to search.
    @param show[None] A list or tuple of metadata key names for the 
                  key/value pairs to return that are associated with each
                  dataset.
    """
    query_components = ['%(key)s=="%(value)s"' % locals() 
                        for key, value in dataId.items()]
    query = ' && '.join(query_components)
    client = datacat.client_from_config_file()
    results = []
    for pattern in folder_patterns:
        results.extend(client.search(pattern, query=query, show=show))
    return results

if __name__ == '__main__':
    #
    # The following are *example* usages of the find_datasets function.
    #
    e2v_sensor = 'e2v-CCD250-11093-10-04'
    folder_patterns = ('/LSST/mirror/SLAC-test/test/e2v-CCD/**',
                       '/LSST/vendorData/e2v/**')
    #
    # Find test reports for an e2v sensor
    #
    report_datasets = find_datasets(dict(LSST_NUM=e2v_sensor,
                                         DATA_PRODUCT='TEST_REPORT',
                                         TEST_CATEGORY='EO'),
                                    folder_patterns,
                                    show=('ORIGIN',))
    print 'EO test reports for', e2v_sensor, ':'
    for dataset in report_datasets:
        print dataset.metadata['ORIGIN'], ':', dataset.path
    print
    #
    # Find test report plots for SLAC offline analysis for an e2v sensor.
    #
    mosaic_datasets = find_datasets(dict(LSST_NUM=e2v_sensor,
                                         DATA_PRODUCT='CCD_MOSAIC',
                                         ORIGIN='SLAC',
                                         PRODUCER='SR-EOT-02',
                                         TEST_CATEGORY='EO'),
                                    ('/LSST/mirror/SLAC-test/test/e2v-CCD/**',),
                                    show=('SCHEMA_NAME', 'TESTTYPE'))
    print 'EO test ccd mosaics for', e2v_sensor, ':'
    for dataset in mosaic_datasets:
        print dataset.metadata['TESTTYPE'], dataset.metadata['SCHEMA_NAME'], \
            ':', dataset.path
    print

    amp_result_datasets = find_datasets(dict(LSST_NUM=e2v_sensor,
                                             DATA_PRODUCT='AMP_RESULTS',
                                             ORIGIN='SLAC',
                                             PRODUCER='SR-EOT-02',
                                             TEST_CATEGORY='EO'),
                                        ('/LSST/mirror/SLAC-test/test/e2v-CCD/**',),
                                        show=('SCHEMA_NAME', 'TESTTYPE'))
    print 'EO test amp result plots for', e2v_sensor, ':'
    for dataset in amp_result_datasets:
        print dataset.metadata['TESTTYPE'], dataset.metadata['SCHEMA_NAME'], \
            ':', dataset.path
