# COMP3311 19T3 Assignment 3
import sys
from collections import defaultdict
import cs3311
def preprocess(course, ct, fetch):
	course_time = defaultdict(list)
	class_map = defaultdict(list)
	for record in fetch:
		class_map[(record[1], record[2])].append([record[3], record[4], record[5]])
	for key in class_map:
		course_time[key[1]].append(class_map[key])
	ct[course] = course_time

conn = cs3311.connect()
cur = conn.cursor()

courses = ['MATH1131', 'COMP1511']
if len(sys.argv) > 1:
	courses = []
	for i in range(1, len(sys.argv)):
		courses.append(sys.argv[i])

ct = defaultdict(list)
for course in courses:
	cur.callproc('get_course_record', [course,])
	preprocess(course, ct, cur.fetchall())
print(ct)	


cur.close()
conn.close()
