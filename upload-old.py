#!/bin/env python
import swiftclient
from pprint import pprint
#account is biostat
#User:passwords are:
#bmajoros: ieGh6iePou3hohshahV3oevagh0ai6Ie
#ter18:  eicou6oongo3ZieFeiv4Thotai4EuPho

USER = 'biostat:bmajoros'
KEY = 'ieGh6iePou3hohshahV3oevagh0ai6Ie'
conn = swiftclient.Connection(
	user=USER,
	key=KEY,
	authurl='https://swift.oit.duke.edu/auth/v1.0'
)

#print "Connecting with account info:"
#pprint(conn.get_account())

#print "Creating a container"
container_name = 'ICE'
conn.put_container(container_name)

print "Adding data file to a container"
file_handle = open('/home/bmajoros/1000G/assembly/upload/gencode.gtf.gz',
  'r')
conn.put_object(container_name,
  'gencode.gtf.gz',
  contents = file_handle.read(),
  content_type = 'text/plain')
file_handle.close()

#print "Deleting file from container"
#conn.delete_object("ICE","/home/bmajoros/1000G/assembly/upload/HG00096-1.fasta.gz");

#print "Container Listing:"
#for container in conn.get_account()[1]:
#    print container['name']
#    pprint(container)
#for data in conn.get_container(container_name)[1]:
#    print '{0}\t{1}\t{2}'.format(data['name'], data['bytes'], data['last_modified'])
