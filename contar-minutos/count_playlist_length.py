#! /usr/bin/python
# -*- coding: utf-8 -*-

import sys
import re
import datetime

max_count = start_count = finish_count = ''
if len(sys.argv) == 3:
    max_count = sys.argv[2]
if len(sys.argv) == 4:
    start_count = sys.argv[2]
    finish_count = sys.argv[3]

with open(sys.argv[1]) as playlist_file:
    playlist_lines = playlist_file.readlines()
    total = datetime.timedelta(seconds=0)
    for line in playlist_lines:
        if re.search('\d{1,3}(\.|\:|,){1}\d{1,3}', line):
            if start_count and line[0:len(start_count)] < start_count or \
               finish_count and line[0:len(finish_count)] > finish_count:
                continue
            match = re.search('\d{1,3}(\.|\:|,){1}\d{1,2}', line)
            sep = match.groups()[0]
            match_str = match.group()
            time = datetime.datetime.strptime(match_str, "%M"+sep+"%S")
            total += datetime.timedelta(minutes=time.minute, seconds=time.second)
        if max_count and line[0:len(max_count)] == max_count:
            print 'Hasta el tema %s tengo %s hs' % (max_count, total)
            max_count = '99'
if start_count and finish_count:
    print 'Entre el %s y %s tengo %s hs' % (start_count, finish_count, total)
else:
    print 'En total tengo %s hs' % total
exit(0)
