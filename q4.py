# COMP3311 19T3 Assignment 3
import sys
from collections import defaultdict
import cs3311
conn = cs3311.connect()

cur = conn.cursor()

prefix = 'ENGG'
if len(sys.argv) > 1:
	prefix = sys.argv[1]

cur.callproc('get_enrolments_from_prefix', [prefix,])

termcourse = defaultdict(list)
for code, term, enrolments in cur.fetchall():
	termcourse[term].append((code, enrolments))

if len(termcourse['5192']) > 0:
	print('19T0')
	for code, number in sorted(termcourse['5192']):
		print(' ' + code + '(' + str(number) + ')')
if len(termcourse['5193']) > 0:
        print('19T1')
        for code, number in sorted(termcourse['5193']):
                print(' ' + code + '(' + str(number) + ')')
if len(termcourse['5196']) > 0:
        print('19T2')
        for code, number in sorted(termcourse['5196']):
                print(' ' + code + '(' + str(number) + ')')
if len(termcourse['5199']) > 0:
        print('19T3')
        for code, number in sorted(termcourse['5199']):
                print(' ' + code + '(' + str(number) + ')')


cur.close()
conn.close()
