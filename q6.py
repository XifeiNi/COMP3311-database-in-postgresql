# COMP3311 19T3 Assignment 3

import cs3311
conn = cs3311.connect()

cur = conn.cursor()

query = "update meetings set weeks_binary = get_binary_string(weeks)"
cur.execute(query)

cur.close()
conn.close()
