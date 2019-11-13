#!/usr/bin/python3
# COMP3311 19T3 Assignment 3

import cs3311
conn = cs3311.connect()

cur = conn.cursor()

query = "select * from code_quota_enrollments"
cur.execute(query)
for code, quota, enrollment in cur.fetchall():
	print(code + ' ' + '{0:.0%}'.format(enrollment/quota))


cur.close()
conn.close()
