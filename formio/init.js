db_name = 'goat'
user = 'user'
pass = 'user'

db = db.getSiblingDB(db_name)
db.createUser({'user': user, 'pwd': pass, 'roles': [{'role': 'readWrite', 'db': db_name}]})