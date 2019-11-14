# COMP3311 19T3 Assignment 3
import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()
cur.execute("select count(room_id) from unsw_rooms")
all_unsw_rooms = cur.fetchall()[0][0]
if len(sys.argv) > 1:
	if sys.argv[1] == '19T1':
		cur.execute("select * from room_status_t1")
	elif sys.argv[1] == '19T2':
		cur.execute("select * from room_status_t2")
	else:
		cur.execute("select * from room_status_t3")
else:
	cur.execute("select * from room_status_t1")
count = 0
for tup in cur.fetchall():
	if tup[1] == 0:
		count += 1
print('{:.1%}'.format(count/all_unsw_rooms))	

cur.close()
conn.close()
