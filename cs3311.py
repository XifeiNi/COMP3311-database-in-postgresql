# COMP3311 19T3 Database connector

import psycopg2

def connect():
    conn = None
    try:
        conn = psycopg2.connect("dbname='a3'")
        conn.set_client_encoding('UTF8')
    except Exception as e:
        print("Unable to connect to the database")
    return conn
