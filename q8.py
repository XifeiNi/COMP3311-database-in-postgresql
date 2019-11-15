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
		class_map[(record[1], record[2])].append([record[5], record[3], record[4]])
	for key in class_map:
		course_time[key[1]].append(class_map[key])
	ct[course] = course_time
def clash(combinations, time_slot):
	intervals = []
	combinations.append(time_slot)
	for slot in combinations:
		if slot.typed == 16:
			continue
		for time in slot.time:
			intervals.append(time)
	lastday = 7
	lasttime = 0000
	for interval in sorted(intervals):
		#print(interval[0])
		if interval[0] == lastday and interval[1] < lasttime:
			return False
		lasttime = int(interval[2])
		lastday = int(interval[0])
	return True
				
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
def time_diff(time1, time2):
	return abs(time1 - time2)//100 + abs(time1%100 - time2%100)/60.0;
		
def combinations(ct, types):
	if not ct:
		return []
	results = []
	dfs(types, 0, ct, [], results)
	return results

# combination: list of timeslots
def hoursOnCampus(combination):
	intervals = []
	for slot in combination:
		if slot.typed == 16:
			continue
		for time in slot.time:
			intervals.append(time)
	intervals = sorted(intervals)
	daysMap = defaultdict(list)
	for interval in intervals:
		daysMap[interval[0]].append((interval[1], interval[2]))
	numDays = len(daysMap)
	time = 0
	early = 100
	for day in daysMap:
		diff = time_diff(daysMap[day][-1][1], daysMap[day][0][0])
		time += diff
		time += 1
		early-=day
	return [time, numDays, early]	

def dfs(num_type,index, ct, curr_com, results):
	if index == num_type:
		results.append(list(curr_com))
		return

	for time_slots in ct[index]:
		if clash(list(curr_com), time_slots):
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
	print("time on campus", hoursOnCampus(com))
cur.close()
conn.close()
