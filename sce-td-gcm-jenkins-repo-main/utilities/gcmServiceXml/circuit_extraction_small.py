
import os
import gcm_service_request as gcm_request

ckt_list = {'Abacus', 'BoOtHill', 'ALMOND' }


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
    for circuit_name in ckt_list:
        circuit_name = circuit_name.upper()
        circuit_xml, c_ns = gcm_request.get_dist_conn_xml(circuit_name)
        circuit_xml.write(file_path('Distribution Select\\{}'.format(circuit_name),
                                    'xml'))