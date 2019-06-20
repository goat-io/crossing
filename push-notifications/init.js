db_name = "push-notifications"
user = "user"
pass = "Pepito.P0"

db = db.getSiblingDB(db_name)
db.createUser({
  user: user,
  pwd: pass,
  roles: [{ role: "readWrite", db: db_name }]
})
