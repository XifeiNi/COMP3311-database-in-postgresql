# COMP3311 19T3 Assignment 3
import sys
from collections import defaultdict
import cs3311
class timeslot(object):
	def __init__(self, time, typed, course):
		self.time = time
		self.typed = typed
		self.course = course
	def __str__(self):
		return self.course + ' ' + str(self.typed) + ' ' + str(self.time)
def preprocess(course, ct, fetch):
	course_time = defaultdict(list)
	class_map = defaultdict(list)
	for record in fetch:
		class_map[(record[1], record[2])].append([record[3], record[4], record[5]])
	for key in class_map:
		course_time[key[1]].append(class_map[key])
	ct[course] = course_time

def types(ct):
	ret = 0
	for key in ct:
		ret += len(ct[key])
	return ret	
def dumpCT(ct):
	dump = defaultdict(list)
	count = 0
	for key in ct:
		for typed in ct[key]:
			for slot in ct[key][typed]:
				dump[count].append(timeslot(slot, typed, key))
			count += 1
	return dump
		
def combinations(ct, types):
	if not ct:
		return []
	results = []
	dfs(types, 0, ct, [], results)
	return results

def dfs(num_type,index, ct, curr_com, results):
	if index == num_type:
		results.append(list(curr_com))
		return

	for time_slots in ct[index]:
		curr_com.append(time_slots)
		dfs(num_type, index + 1, ct, curr_com, results)
		curr_com.pop()
			

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
#print(ct)	
dump = dumpCT(ct)

for com in combinations(dump, types(ct)):
	string = ""
	for slot in com:
		string += str(slot)
		string += ','
	print(string)
cur.close()
conn.close()
