import os
import datacat

client = datacat.client_from_config_file()

sensor_ids = ['e2v-CCD250-11093-10-04',
              'ITL-3800C-033',
              'ITL-3800C-042',
              'ITL-3800C-107',
              'ITL-3800C-126']

data_product = 'CCD_MOSAIC'
#data_product = 'AMP_RESULTS'
schema_name = 'prnu'
origin = 'SLAC'
test_category = 'EO'
testtype = 'FLAT'

folder_patterns = {'ITL' : ('/LSST/mirror/SLAC-test/test/ITL-CCD/**',),
                   'e2v' : ('/LSST/mirror/SLAC-test/test/e2v-CCD/**',)}

for sensor_id in sensor_ids:
    vendor = sensor_id.split('-')[0]
    print "%(sensor_id)s:" % locals() 
    query = ' && '.join([
            'DATA_PRODUCT=="%(data_product)s"',
            'LSST_NUM=="%(sensor_id)s"',
            'ORIGIN=="%(origin)s"',
#            'SCHEMA_NAME=="%(schema_name)s"',
            'TEST_CATEGORY=="%(test_category)s"',
            'TESTTYPE=="%(testtype)s"'
            ])
    query = query % locals()
    print query
    results = []
    try:
        for pattern in folder_patterns[vendor]:
            results.extend(client.search(pattern, query=query))
        for result in results:
            print "   %s: %s" % (origin, result.path)
    except Exception, eobj:
        print 'Caught Exception:', type(eobj)
        continue
    print
