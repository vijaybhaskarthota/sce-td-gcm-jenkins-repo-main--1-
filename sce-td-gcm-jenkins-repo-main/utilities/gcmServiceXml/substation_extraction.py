import os
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
    tree, ns = gcm_request.get_substation_changelist('Connectivity')
    if tree is not None:
        ns_scl = {'ns_': ns}
        tree.write(file_path('{}'.format('Substation CL'),
                             'xml', False))
        root = tree.getroot()
        count = 0
        for substation in root.findall('ns_:' + 'Substation', ns_scl):
            sub_name = substation.find('ns_:' + 'name', ns_scl).text.upper()
            sub_mrid = substation.find('ns_:' + 'mRID', ns_scl).text
            count += 1
            print('{} - Processing {} substation | {}...'.format(count, sub_name, sub_mrid))
            if os.path.exists(file_path('Substation Internal\\{}'.format(sub_name), 'xml')):
                print('{} substation exists in the directory!'.format(sub_name))
                continue
            sub_xml, s_ns = gcm_request.get_substation_int_xml(sub_mrid)
            if sub_xml is not None:
                sub_xml.write(file_path('Substation Internal\\{}'.format(sub_name),
                                 'xml'))
            else:
                print('Error: {} cannot be processed!'.format(sub_name))