import requests
import truststore
import xml.etree.ElementTree as et

# Your client ID and secret
client_id = "9445ae4cb9f830555057dcada8bff623"
client_secret = "22e8cfcc654ccf37827ddbe85c537cc0"

# Input parameters

headers = {'X-IBM-Client-Id': client_id,
           'X-IBM-Client-Secret': client_secret,
           'accept': 'application/xml'
}


def get_circuit_changelist(change_type):
    tree = None
    ns_ccl_str = 'http://www.sce.com/2019/07/17/CircuitList'
    ckt_cl_url = 'https://apidpp.sce.com/sce/v3.0.0/gcis/circuits/list'
    ckt_cl_params = {
        'include': 'All',
        'changeset': change_type
    }
    try:
        truststore.inject_into_ssl()
        response = requests.get(ckt_cl_url, headers=headers, params=ckt_cl_params)
        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            xml_data = response.text
            root = et.fromstring(xml_data)
            tree = et.ElementTree(root)
            et.indent(tree, '   ')
            et.register_namespace('', ns_ccl_str)

        else:
            print(f"Error: Request failed with status code {response.status_code}")
        return tree, ns_ccl_str
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {str(e)}")


def get_dist_conn_xml(circuit_name, inc_secondary='Yes'):
    tree = None
    ns_dc_str = 'http://www.sce.com/2019/06/CircuitConnectivity'
    dist_conn_url = 'https://apidpp.sce.com/sce/v3.0.0/connectivity/electrical/distribution/AsBuilt'
    dist_conn_params = {
        'circuitName': circuit_name,
        'includeSecondary': inc_secondary,
        'includeDetail': 'nameplates,deviceSettingsAndLimits'
    }
    try:
        truststore.inject_into_ssl()
        response = requests.get(dist_conn_url, headers=headers, params=dist_conn_params)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            xml_data = response.text
            root = et.fromstring(xml_data)
            tree = et.ElementTree(root)
            et.indent(tree, '   ')
            et.register_namespace('m', ns_dc_str)

        else:
            print(f"Error: Request failed with status code {response.status_code}")
        return tree, ns_dc_str
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {str(e)}")


def get_substation_changelist(change_type):
    tree = None
    ns_scl_str = 'http://www.sce.com/2019/05/SubstationList'
    sub_cl_url = 'https://apidpp.sce.com/sce/v3.0.0/gcis/electrical/substation/list/AsBuilt'
    sub_cl_params = {
        'include': 'All',
        'changeSet': change_type
    }
    try:
        truststore.inject_into_ssl()
        response = requests.get(sub_cl_url, headers=headers, params=sub_cl_params)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            xml_data = response.text
            root = et.fromstring(xml_data)
            tree = et.ElementTree(root)
            et.indent(tree, '   ')
            et.register_namespace('', ns_scl_str)

        else:
            print(f"Error: Request failed with status code {response.status_code}")
        return tree, ns_scl_str
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {str(e)}")


def get_substation_int_xml(sub_mrid):
    tree = None
    ns_si_str = 'http://www.sce.com/2019/05/SubstationInternalConnectivity'
    sub_int_url = 'https://apidpp.sce.com/sce/v3.0.0/gcis/connectivity/electrical/substationInternal'
    sub_int_params = {
        'substationId': sub_mrid,
        'includeDetail': 'Nameplate,deviceSettingsAndLimits'
    }
    try:
        truststore.inject_into_ssl()
        response = requests.get(sub_int_url, headers=headers, params=sub_int_params)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            xml_data = response.text
            root = et.fromstring(xml_data)
            tree = et.ElementTree(root)
            et.indent(tree, '   ')
            et.register_namespace('', ns_si_str)

        else:
            print(f"Error: Request failed with status code {response.status_code}")
        return tree, ns_si_str
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {str(e)}")