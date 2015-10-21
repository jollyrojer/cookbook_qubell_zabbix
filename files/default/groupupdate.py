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

def getGroupId(groupname, url, auth):
    values = {'jsonrpc': '2.0',
              'method': 'usergroup.getobjects',
              'params': {
                  'name': groupname
              },
              'auth': auth,
              'id': '2'
             }
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    groupId_get = response.read()
    output = json.loads(groupId_get)
    groupId = output['result'][0]['usrgrpid']

    return groupId

def getHostGroupId(hostgroup, url, auth):
    values = {'jsonrpc': '2.0',
              'method': 'hostgroup.get',
              'params': {
                  'output': 'extend',
                  'filter': {
                      'name': [hostgroup]
                  }
               },
               'auth': auth,
               'id': '3'
             }
     
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    hostgroup_get = response.read()
    output = json.loads(hostgroup_get)
    hostGroupId = output['result'][0]['groupid']

    return hostGroupId

def userGroupUpdate (url, auth, groupId, hostGroupId):
    values = {'jsonrpc': '2.0',
              'method': 'usergroup.massupdate',
              'params': {
                  'usrgrpids': [groupId],
                  'rights': {
                      'permission': 2,
                      'id': hostGroupId
                  }
              },
              'auth': auth,
              'id': '4'
             }
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    GroupUpdate = response.read()
    output = json.loads(GroupUpdate)
    try:
        message = output['result']
    except:
        message = output['error']['data']

    print json.dumps(message)

def main():
    if len(sys.argv) < 6:
        print "Not all arguments specified"

    groupname = sys.argv[1]
    hostgroup = sys.argv[2]
    url = sys.argv[3]
    username = sys.argv[4]
    password = sys.argv[5] 

    auth = authenticate(url, username, password)
    groupId = getGroupId(groupname, url, auth)
    hostGroupId = getHostGroupId(hostgroup, url, auth)
    userGroupUpdate(url, auth, groupId, hostGroupId)

if __name__ == '__main__':
    main()
