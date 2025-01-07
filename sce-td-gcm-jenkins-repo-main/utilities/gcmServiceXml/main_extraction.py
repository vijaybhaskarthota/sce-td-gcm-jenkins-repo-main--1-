
import xml.etree.ElementTree as et
import os
import gcm_service_request as gcm_request

test_sub_list = {'Kramer'}


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
    tree, ns = gcm_request.get_substation_changelist('connectivity')
    if tree is not None:
        sub_dict = {}
        ns_scl = {'ns_': ns}
        tree.write(file_path('Substation Changelist\\{}'.format('Substation Internal CL'),
                             'xml', False, True))
        root = tree.getroot()
        for substation in root.findall('ns_:' + 'Substation', ns_scl):
            sub_name = substation.find('ns_:' + 'name', ns_scl).text.upper()
            sub_mrid = substation.find('ns_:' + 'mRID', ns_scl).text
            sub_dict[sub_name] = sub_mrid
        for sub_in in test_sub_list:
            sub_in = sub_in.upper()
            print('Checking {} in Substation List...'.format(sub_in))
            if sub_in in sub_dict:
                print('Substation found. Requesting substation payload...')
                sub_tree, ns_sub = gcm_request.get_substation_int_xml(sub_dict[sub_in])
                sub_tree.write(file_path('Substation Internal\\{}'.format(sub_in),
                                         'xml', False, True))
            else:
                print('{} not found in Substation List! Please check input spelling'.format(sub_in))