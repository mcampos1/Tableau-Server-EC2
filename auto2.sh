#!/bin/bash
tsm licenses activate -t
cat > regi.json << EOF
{
    "first_name" : "Martin",
    "last_name" : "Campos",
    "phone" : "13413243128",
    "email" : "campos_martin@bah.com",
    "company" : "BAH",
    "industry" : "Consulting",
    "company_employees" : "10000",
    "department" : "Engineering",
    "title" : "Devops Engineer",
    "city" : "Arlington",
    "state" : "VA",
    "zip" : "45243",
    "country" : "United States",
    "opt_in" : "true",
    "eula" : "true"
}
EOF
tsm register --file regi.json
cat > local.json << EOF
{
  "configEntities": {
    "identityStore": {
       "_type": "identityStoreType",
       "type": "local"
     }
   }
}
EOF
tsm settings import -f local.json
tsm pending-changes apply
tsm initialize --start-server --request-timeout 1800
tabcmd initialuser --server http://localhost --username 'tableauadmin'
admin123
