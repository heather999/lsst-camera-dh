from DataCatalog import DataCatalog
import datacat
from add_dc_metadata import enable_logging, apply_metadata, MyDataCatalog

png_md = {'_flat.png' : ('CCD_MOSAIC', 'FLAT', 'prnu'),
          '_fe55_dists.png' : ('AMP_RESULTS', 'FE55', 'fe55_analysis'),
          '_full_well.png' : ('AMP_RESULTS', 'FLAT', 'flat_pairs'),
          '_gains.png' : ('AMP_RESULTS', 'FE55', 'fe55_analysis'),
          '_linearity.png' : ('AMP_RESULTS', 'FLAT', 'flat_pairs'),
          '_noise.png' : ('AMP_RESULTS', 'FE55', 'read_noise'),
          '_psf_dists.png' : ('AMP_RESULTS', 'FE55', 'fe55_analysis'),
          '_ptcs.png' : ('AMP_RESULTS', 'FLAT', 'ptc'),
          '_qe.png' : ('CCD_RESULTS', 'LAMBDA', 'qe_analysis')}

def png_file_md(datapath, ccd_manu, sensor_id):
    for key, value in png_md.items():
        if datapath.endswith(key):
            data_product, testtype, schema_name = value
            break
    return {
        'ANALYSIS_TYPE' : None,
        'CCD_MANU' : ccd_manu,
        'DATA_PRODUCT' : data_product,
        'DATA_SOURCE' : 'VENDOR',
        'LSST_NUM' : sensor_id,
        'ORIGIN' : 'SLAC',
        'PRODUCER' : 'SR-EOT-02',
        'SCHEMA_NAME' : schema_name,
        'TEST_CATEGORY' : 'EO',
        'TESTTYPE' : testtype,
        }

#enable_logging()

if __name__ == '__main__':
    dc = MyDataCatalog()

    ccds = {'ITL-CCD' : ['ITL-3800C-' + x for x in '033 042 107 126'.split()],
            'e2v-CCD' : ['e2v-CCD250-11093-10-04']}

    for ccd_type, sensor_ids in ccds.items()[1:]:
        print ccd_type
        ccd_manu = ccd_type.split('-')[0]
        for sensor_id in sensor_ids:
            reports = dc.find_eotest_reports(ccd_type, sensor_id, ext='.png')
            for report in reports:
                print report
                try:
                    md = png_file_md(report, ccd_manu, sensor_id)
                except UnboundLocalError:
                    print "skipping"
                    continue
                apply_metadata(report, md)
