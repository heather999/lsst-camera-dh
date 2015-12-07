import os
import fnmatch
from DataCatalog import DataCatalog
import datacat
from add_dc_metadata import enable_logging, apply_metadata, MyDataCatalog

origins = dict([('e2v', 'e2v technologies (UK)'), ('ITL', 'UAITL')])

met_file_patterns = dict([('e2v', ['*_flatness.csv', '*_flatness.xls',
                                   '*CT100*.csv']),
                          ('ITL', ['*_Z_Metrology.txt',
                                   '*_Z_MetrologyData.txt'])])

def met_file_md(datapath, sensor_id):
    ccd_manu = sensor_id.split('-')[0]
    origin = origins[ccd_manu]
    return {
        'CCD_MANU' : ccd_manu,
        'DATA_PRODUCT' : 'MET_SCAN',
        'DATA_SOURCE' : 'VENDOR',
        'LSST_NUM' : sensor_id,
        'ORIGIN' : origin,
        'TEST_CATEGORY' : 'MET',
        }

#enable_logging()

if __name__ == '__main__':
    dc = MyDataCatalog()

    ccds = {'ITL-CCD' : ['ITL-3800C-' + x for x in '033 042 107 126'.split()],
            'e2v-CCD' : ['e2v-CCD250-11093-10-04']}

    for ccd_type, sensor_ids in ccds.items():
        print ccd_type
        ccd_manu = ccd_type.split('-')[0]
        for sensor_id in sensor_ids:
            folder = os.path.join('LSST/vendorData', ccd_manu, sensor_id, 'Dev')
            for fnpattern in met_file_patterns[ccd_manu]:
                reports = dc.find_files(folder, fnpattern=fnpattern)
                for report in reports:
                    print report
                    try:
                        md = met_file_md(report, sensor_id)
                    except UnboundLocalError:
                        print "skipping"
                        continue
                    apply_metadata(report, md)
