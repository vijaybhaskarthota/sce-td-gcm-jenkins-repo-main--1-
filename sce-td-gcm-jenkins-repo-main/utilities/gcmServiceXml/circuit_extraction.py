import os
import pandas as pd
import gcm_service_request as gcm_request


def file_path(net_name, f_type='csv', directory_only=False, sub_folder=False):
    username = os.getlogin()
    file_name = "{}.{}".format(net_name, f_type)
    directory = "C:\\Users\\{}\\OneDrive - Southern California Edison\\Desktop\\GCMXML\\".format(username)
    if not directory_only:
        f_path = "{}{}".format(directory, file_name)
    else:
        if sub_folder:
            f_path = "{}{}".format(directory, net_name)
        else:
            f_path = directory
    return f_path


if __name__ == '__main__':
    tree, ns = gcm_request.get_circuit_changelist('Connectivity')
    circuit_cols = ['CIRCUIT_NAME']
    circuit_df = pd.DataFrame(columns=circuit_cols)
    if tree is not None:
        sub_dict = {}
        ns_ccl = {'ns_': ns}
        tree.write(file_path('{}'.format('Distribution CL'),
                             'xml', False))
        root = tree.getroot()
        count = 0
        for circuit in root.findall('ns_:' + 'Feeder', ns_ccl):
            circuit_name = circuit.find('ns_:' + 'circuitName', ns_ccl).text
            count += 1
            print('{} - Processing {} circuit...'.format(count, circuit_name))
            df_row = {'CIRCUIT_NAME': circuit_name}
            circuit_df = circuit_df._append(df_row, ignore_index=True)
            if os.path.exists(file_path('Distribution Connectivity\\{}'.format(circuit_name), 'xml')):
                print('{} circuit exists in the directory!'.format(circuit_name))
                continue
            circuit_xml, c_ns = gcm_request.get_dist_conn_xml(circuit_name)
            circuit_xml.write(file_path('Distribution Connectivity\\{}'.format(circuit_name),
                             'xml'))
        circuit_df.to_csv(file_path('Modeled Circuits'))



