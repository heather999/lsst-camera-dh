import os
import datacat

client = datacat.client_from_config_file()

sensor_ids = ['e2v-CCD250-11093-10-04',
              'ITL-3800C-033',
              'ITL-3800C-042',
              'ITL-3800C-107',
              'ITL-3800C-126']

data_product = 'TEST_REPORT'
test_category = 'EO'
origins = ['BNL', 'SLAC', 'e2v technologies (UK)', 'UAITL']

folder_patterns = {'ITL' : ('/LSST/mirror/SLAC-test/test/ITL-CCD/**',
                            #'/LSST/mirror/BNL-test/test/ITL-CCD/**',
                            '/LSST/vendorData/ITL/**'),
                   'e2v' : ('/LSST/mirror/SLAC-test/test/e2v-CCD/**',
                            #'/LSST/mirror/BNL-test/test/e2v-CCD/**',
                            '/LSST/vendorData/e2v/**')}

for sensor_id in sensor_ids:
    vendor = sensor_id.split('-')[0]
    print "%(sensor_id)s:" % locals() 
    for origin in origins:
        query = ' && '.join(['DATA_PRODUCT=="%(data_product)s"',
                             'TEST_CATEGORY=="%(test_category)s"',
                             'ORIGIN=="%(origin)s"',
                             'LSST_NUM=="%(sensor_id)s"'])
        query = query % locals()
        results = []
        for pattern in folder_patterns[vendor]:
            results.extend(client.search(pattern, query=query))
        for result in results:
            print "   %s: %s" % (origin, result.path)
    print
