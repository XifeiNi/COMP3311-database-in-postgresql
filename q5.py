# COMP3311 19T3 Assignment 3
import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()
coursecode = 'COMP1521'
if len(sys.argv) > 1:
	coursecode = sys.argv[1]

cur.callproc('get_class_from_course', [coursecode,])
for result in sorted(cur.fetchall()):
	print(result[0])

cur.close()
conn.close()
