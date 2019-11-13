# COMP3311 19T3 Assignment 3
import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()

same = 2
if len(sys.argv) > 1:
	same = sys.argv[1]


cur.callproc('get_x_same_subject', [same,])
for record in cur.fetchall():
	print(record[0])

cur.close()
conn.close()
