#!/usr/bin/env python3
# https://github.com/jacksitlab/YCast/blob/master/ycast.py
import os
import sys
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer
import xml.etree.cElementTree as etree
import re
import os.path

import yaml
import json

YCAST_LOCATION = 'ycast'

regexCategory = r"category\/([a-zA-Z0-9-]+)$"
regexStation = r"category\/([a-zA-Z0-9-]+)\/([a-zA-Z0-9-]+)$"

stations = {}
#empty => autodetect (yaml, then json)
#yaml  => yaml
#json  => json
filetype='auto'

def get_stations():
    global stations
    global filetype
    ycast_dir = os.path.dirname(os.path.realpath(__file__))
    fn_json=ycast_dir + '/stations.json'
    fn_yaml=ycast_dir + '/stations.yml'
    try:
        if (filetype == 'auto' and os.path.isfile(fn_yaml)) or filetype=='yaml':
            with open(fn_yaml, 'r') as f:
                stations = yaml.load(f)
        elif  (filetype == 'auto' and os.path.isfile(fn_json)) or filetype=='json':
            with open(fn_json, 'r') as f:
                stations = json.load(f)
    except FileNotFoundError:
        print("ERROR: Station configuration not found. Please supply a proper stations.yml.")
        sys.exit(1)

def set_stations():
    global stations
    ycast_dir = os.path.dirname(os.path.realpath(__file__))
    try:
        if (filetype == 'auto' and os.path.isfile(fn_yaml)) or filetype=='yaml':
            with open(fn_yaml, 'r') as f:
                stations = yaml.dump(stations,f)
        elif  (filetype == 'auto' and os.path.isfile(fn_json)) or filetype=='json':
            with open(fn_json, 'r') as f:
                stations = json.dump(stations,f)

    except FileNotFoundError:
        print("ERROR: Station configuration not found. Please supply a proper stations.yml.")
        sys.exit(1)

def text_to_url(text):
    return text.replace(' ', '%20')


def url_to_text(url):
    return url.replace('%20', ' ')


class YCastServer(BaseHTTPRequestHandler):
    def do_GET(self):
        get_stations()
        self.address = 'http://' + self.headers['Host']
        if 'loginXML.asp?token=0' in self.path:
            self.send_xml('<EncryptedToken>0000000000000000</EncryptedToken>')
        elif self.path.startswith('/admin/'):
            if self.path=='/admin/' or self.path=='/admin/index.html':
                self.send_file('index.html')
            elif self.path.startswith('/admin/css/') or self.path.startswith('/admin/js/'):
                self.send_file(self.path[len('/admin/'):])
            elif self.path == '/admin/stations':
                self.send_json(json.dumps(stations))
        elif self.path == '/' \
                or self.path == '/' + YCAST_LOCATION \
                or self.path == '/' + YCAST_LOCATION + '/'\
                or self.path.startswith('/setupapp'):
            xml = self.create_root()
            for category in sorted(stations, key=str.lower):
                if(category != "root"):
                    self.add_dir(xml, category, self.address + '/' + YCAST_LOCATION + '/' + text_to_url(category))
            if 'root' in stations:
                for station in sorted(stations['root'], key=str.lower):
                    self.add_station(xml, station, stations['root'][station])
            else:
                print ("no root found")
            self.send_xml(etree.tostring(xml).decode('utf-8'))
        elif self.path.startswith('/' + YCAST_LOCATION + '/'):
            category = url_to_text(self.path[len(YCAST_LOCATION) + 2:].partition('?')[0])
            if category not in stations:
                self.send_error(404)
                return
            xml = self.create_root()
            for station in sorted(stations[category], key=str.lower):
                self.add_station(xml, station, stations[category][station])
            self.send_xml(etree.tostring(xml).decode('utf-8'))
        else:
            self.send_error(404)
    def do_POST(self):
        if self.path.startswith('/admin/'):
            path=self.path[len('/admin/'):]
            print (path)
            matches = re.match(regexCategory, path)
            if matches:
                self.setCategory(matches.group(1))
                set_stations()
                self.send_json(json.dumps(stations))
            else:
                matches = re.match(regexStation, path)
                if matches:
                    body = self.rfile.read(int(self.headers.get('Content-Length'))).decode('utf-8')
                    o=json.loads(body)
                    self.setStation(matches.group(1),matches.group(2),o['url'])
                    set_stations()
                    self.send_json(json.dumps(stations))
                else:
                    self.send_error(404)
        else:
            self.send_error(404)

    def do_DELETE(self):
        if self.path.startswith('/admin/'):
            path=self.path[len('/admin/'):]
            print (path)
            matches = re.match(regexCategory, path)
            if matches:
                self.unsetCategory(matches.group(1))
                set_stations()
                self.send_json(json.dumps(stations))
            else:
                matches = re.match(regexStation, path)
                if matches:
                    self.unsetStation(matches.group(1),matches.group(2))
                    set_stations()
                    self.send_json(json.dumps(stations))
                else:
                    self.send_error(404)
                
        else:
            self.send_error(404)

    def send_json(self, content):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Content-length', len(content))
        self.end_headers()
        self.wfile.write(bytes(content, 'utf-8'))

    def send_xml(self, content):
        xml_data = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>'
        xml_data += content
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.send_header('Content-length', len(xml_data))
        self.end_headers()
        self.wfile.write(bytes(xml_data, 'utf-8'))

    def send_file(self,filename):
        ycast_dir = os.path.dirname(os.path.realpath(__file__))
        fn=ycast_dir + '/public_html/'+filename
        print("try to send "+fn)
        if not os.path.isfile(fn):
            self.send_error(404)
        else:
            html_data=''
            try:
                with open(fn, 'r') as f:
                    html_data=f.read()
            except FileNotFoundError:
                print("ERROR: Station configuration not found. Please supply a proper stations.yml.")
            self.send_response(200)
            self.send_header('Content-type', self.getContentTypeByFilename(filename))
            self.send_header('Content-length', len(html_data))
            self.end_headers()
            self.wfile.write(bytes(str(html_data),'utf-8'))
 
    def getContentTypeByFilename(self,filename):
        if filename.endswith('.html') or filename.endswith('htm'):
            return 'text/html'
        elif filename.endswith('.css'):
            return 'text/css'
        elif filename.endswith('.js'):
            return 'application/javascript'
        elif filename.endswith('.json'):
            return 'application/json'
        else:
            return 'plain/text'

    def setCategory(self,cat):
        if not cat in stations:
            stations[cat]=dict()

    def setStation(self,cat,name,url):
        if not cat in stations:
            self.setCategory(cat)
        stations[cat][name]=url

    def unsetCategory(self,cat):
        stations.pop(cat)

    def unsetStation(self,cat,name):
        if not cat in stations:
            return
        stations[cat].pop(name)

    def create_root(self):
        return etree.Element('ListOfItems')

    def add_dir(self, root, name, dest):
        item = etree.SubElement(root, 'Item')
        etree.SubElement(item, 'ItemType').text = 'Dir'
        etree.SubElement(item, 'Title').text = name
        etree.SubElement(item, 'UrlDir').text = dest
        return item

    def add_station(self, root, name, url):
        item = etree.SubElement(root, 'Item')
        etree.SubElement(item, 'ItemType').text = 'Station'
        etree.SubElement(item, 'StationName').text = name
        etree.SubElement(item, 'StationUrl').text = url
        return item


parser = argparse.ArgumentParser(description='vTuner API emulation')
parser.add_argument('-l', action='store', dest='address', help='Listen address', default='0.0.0.0')
parser.add_argument('-p', action='store', dest='port', type=int, help='Listen port', default=80)
parser.add_argument('-t', action='store', dest='filetype', type=str, help='Filetype of stations info file(yaml|json|auto)', default='auto')

arguments = parser.parse_args()
get_stations()
try:
    filetype=arguments.filetype
    server = HTTPServer((arguments.address, arguments.port), YCastServer)
except PermissionError:
    print("ERROR: No permission to create socket. Are you trying to use ports below 1024 without elevated rights?")
    sys.exit(1)
print('YCast server listening on %s:%s' % (arguments.address, arguments.port))
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
print('YCast server shutting down')
server.server_close()
