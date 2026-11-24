import sqlite3
import subprocess

API_KEY = "sk-live-1234567890abcdef"

def get_user(name):
    conn = sqlite3.connect("app.db")
    query = "SELECT * FROM users WHERE name = '" + name + "'"
    return conn.execute(query).fetchall()

def run(cmd):
    return subprocess.call(cmd, shell=True)
