# COMP3311 19T3 Assignment 3
import sys
from collections import defaultdict
import cs3311
conn = cs3311.connect()

cur = conn.cursor()
default = 'ENGG'
if len(sys.argv) > 1:
	default = sys.argv[1]

cur.callproc('get_building_from_prefix', [default,])

list_building = set()
building_to_course = defaultdict(set)
for code, building in cur.fetchall():
	building_to_course[building].add(code)
	list_building.add(building)
list_b = sorted(list(list_building))
for b in list_b:
	print(b)
	for code in sorted(list(building_to_course[b])):
		print(' ' + code)


cur.close()
conn.close()
