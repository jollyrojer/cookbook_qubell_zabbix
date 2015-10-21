#!/usr/bin/python
import urllib2
import json
import sys

def authenticate(url, username, password):
    values = {'jsonrpc': '2.0',
              'method': 'user.login',
              'params': {
                  'user': username,
                  'password': password
              },
              'id': '0'
              }

    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    output = json.loads(response.read())

    try:
        message = output['result']
    except:
        message = output['error']['data']
        print message
        quit()

    return output['result']


def getGraph(hostname, url, auth, graphtype, dynamic, columns):
    if (graphtype == 0):
        selecttype = ['graphid']
        select = 'selectGraphs'
    if (graphtype == 1):
        selecttype = ['itemid', 'value_type']
        select = 'selectItems'

    values = {'jsonrpc': '2.0',
              'method': 'host.get',
              'params': {
                  select: selecttype,
                  'output': ['hostid', 'host'],
                  'searchByAny': 1,
                  'filter': {
                      'host': hostname
                  }
              },
              'auth': auth,
              'id': '2'
              }

    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    host_get = response.read()

    output = json.loads(host_get)

    graphs = []
    if (graphtype == 0):
        for i in output['result'][0]['graphs']:
            graphs.append(i['graphid'])

    if (graphtype == 1):
        for i in output['result'][0]['items']:
            if int(i['value_type']) in (0, 3):
                graphs.append(i['itemid'])

    graph_list = []
    x = 0
    y = 0

    for graph in graphs:
        graph_list.append({
            "resourcetype": graphtype,
            "resourceid": graph,
            "width": "500",
            "height": "100",
            "x": str(x),
            "y": str(y),
            "colspan": "0",
            "rowspan": "0",
            "elements": "0",
            "valign": "0",
            "halign": "0",
            "style": "0",
            "url": "",
            "dynamic": str(dynamic)
        })
        x += 1
        if x == columns:
            x = 0
            y += 1

    return graph_list


def screenCreate(url, auth, screen_name, graphids, columns):
    if len(graphids) % columns == 0:
        vsize = len(graphids) / columns
    else:
        vsize = (len(graphids) / columns) + 1

    values = {"jsonrpc": "2.0",
              "method": "screen.create",
              "params": [{
                  "name": screen_name,
                  "hsize": columns,
                  "vsize": vsize,
                  "screenitems": []
              }],
              "auth": auth,
              "id": 2
              }

    for i in graphids:
        values['params'][0]['screenitems'].append(i)

    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    host_get = response.read()

    output = json.loads(host_get)

    try:
        message = output['result']['screenids'][0]
    except:
        message = output['error']['data']

    print message


def main():
    if len(sys.argv) < 6:
        print "Not all arguments specified"

    hostname = sys.argv[1]
    screen_name = sys.argv[2]
    url = sys.argv[3]
    username = sys.argv[4]
    password = sys.argv[5]
    columns = 2
    dynamic = 0
    screentype = 0

    auth = authenticate(url, username, password)
    graphids = getGraph(hostname, url, auth, screentype, dynamic, columns)

    screenCreate(url, auth, screen_name, graphids, columns)

if __name__ == '__main__':
    main()
