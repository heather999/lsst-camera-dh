import fnmatch
from DataCatalog import DataCatalog
import datacat

def enable_logging():
    import logging
    import httplib
    logging.basicConfig()
    logger = logging.getLogger('requests')
    logger.setLevel(logging.DEBUG)
    httplib.HTTPConnection.debuglevel = 2

def apply_metadata(dataset_path, md):
    patch_dict = {'versionMetadata' : md}
    client = datacat.client_from_config_file()
    client.patch_dataset(dataset_path, patch_dict)

class MyDataCatalog(DataCatalog):
    def __init__(self, experiment='LSST', site='SLAC'):
        super(MyDataCatalog, self).__init__(experiment=experiment, site=site)
    def find_files(self, folder, fnpattern='*.pdf'):
        dataset_paths = []
        try:
            query = ''
            datasets = self.find_datasets(query, folder=folder)
        except datacat.error.DcException:
            datasets = []
        for dataset in datasets:
            if fnmatch.fnmatch(dataset.name, fnpattern):
                dataset_paths.append(dataset.path)
        return dataset_paths
    def find_vendor_reports(self, vendor, sensor_id):
        fnpatterns = {'e2v' : (None, '*EO_Test_Sheet.xls'),
                      'ITL' : ('LsstReport', '*.pdf')}
        folder = '/LSST/vendorData/%(vendor)s/%(sensor_id)s/Dev' % locals()
        results = self.find_files(folder, fnpattern=fnpatterns[vendor][1])
        prefix = fnpatterns[vendor][0]
        if prefix is not None:
            results = [x for x in results if x.find(prefix) != -1]
        return results
    def find_eotest_reports(self, ccd_type, sensor_id, fnpattern='*.pdf'):
        folder = '/LSST/mirror/SLAC-test/test/%(ccd_type)s/%(sensor_id)s/test_report_offline/v0' % locals()
        return self.find_files(folder, fnpattern=fnpattern)

eotest_report_md = lambda ccd_manu, sensor_id : {'CCD_MANU' : ccd_manu,
                                                 'LSST_NUM' : sensor_id,
                                                 'DATA_PRODUCT' : 'TEST_REPORT',
                                                 'PRODUCER' : 'SR-EOT-02',
                                                 'DATA_SOURCE' : 'VENDOR',
                                                 'ORIGIN' : 'SLAC',
                                                 'TEST_CATEGORY' : 'EO'}

e2v_eo_report_md = lambda sensor_id : {'CCD_MANU' : 'e2v',
                                       'LSST_NUM' : sensor_id,
                                       'DATA_PRODUCT' : 'TEST_REPORT',
                                       'DATA_SOURCE' : 'VENDOR',
                                       'ORIGIN' : 'e2v technologies (UK)',
                                       'TEST_CATEGORY' : 'EO'}

ITL_eo_report_md = lambda sensor_id : {'CCD_MANU' : 'ITL',
                                       'LSST_NUM' : sensor_id,
                                       'DATA_PRODUCT' : 'TEST_REPORT',
                                       'DATA_SOURCE' : 'VENDOR',
                                       'ORIGIN' : 'UAITL',
                                       'TEST_CATEGORY' : 'EO'}
vendor_md = {'e2v' : e2v_eo_report_md,
             'ITL' : ITL_eo_report_md}

#enable_logging()

if __name__ == '__main__':
    dc = MyDataCatalog()

    ccds = {'ITL-CCD' : ['ITL-3800C-' + x for x in '033 042 107 126'.split()],
            'e2v-CCD' : ['e2v-CCD250-11093-10-04']}

    print "eotest Reports:"
    for ccd_type, sensor_ids in ccds.items():
        print ccd_type
        ccd_manu = ccd_type.split('-')[0]
        for sensor_id in sensor_ids:
            reports = dc.find_eotest_reports(ccd_type, sensor_id)
            for report in reports:
                print report
#                apply_metadata(report, eotest_report_md(ccd_manu, sensor_id))
        print

    print
    print "Vendor Reports:"
    vendor_reports = {'e2v' : ccds['e2v-CCD'],
                      'ITL' : ccds['ITL-CCD']}
    for vendor, sensor_ids in vendor_reports.items():
        print vendor
        for sensor_id in sensor_ids:
            reports = dc.find_vendor_reports(vendor, sensor_id)
            for report in reports:
                print report
#                apply_metadata(report, vendor_md[vendor](sensor_id))
        print
