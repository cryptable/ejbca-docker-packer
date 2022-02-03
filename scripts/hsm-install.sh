#!/bin/sh

if [ ${HSM_SIMULATOR} = "false" ]; then

  sudo cat <<EOF > /opt/ejbca/docker-ejbca/utimaco/cs_pkcs11_R3.cfg
[Global]
# Path to the logfile (name of logfile is attached by the API)
# For unix:
#Logpath = /tmp
# For windows:
#Logpath = C:/ProgramData/Utimaco/PKCS11_R3

# Loglevel (0 = NONE; 1 = ERROR; 2 = WARNING; 3 = INFO; 4 = TRACE)
Logging = 0
# Maximum size of the logfile in bytes (file is rotated with a backupfile if full)
Logsize = 10mb

# Created/Generated keys are stored in an external or internal database
KeysExternal = false

# If true, every session establishs its own connection
SlotMultiSession = true

# Maximum number of slots that can be used
SlotCount = 10

# If true, leading zeroes of decryption operations will be kept
KeepLeadZeros = false

# Configures load balancing mode ( == 0 ) or failover mode ( > 0 )
# In failover mode, n specifies the interval in seconds after which a reconnection attempt to the failed CryptoServer is started.
FallbackInterval = 0

# Prevents expiring session after inactivity of 15 minutes
KeepAlive = false

# Timeout of the open connection command in ms
ConnectionTimeout = 5000

# Timeout of command execution in ms
CommandTimeout = 60000

# List of official PKCS#11 mechanisms which should be customized
#CustomMechanisms = { CKM_AES_CBC CKM_AES_ECB }

# Enforce thread-safety by using the operating system locking primitives
#ForceOSLocking = true

#[CryptoServer]
# Device specifier (here: CryptoServer is internal PCI device)
# For unix:
#Device = /dev/cs2
# For windows:
#Device = PCI:0  

[CryptoServer]
# Device specifier (here: CryptoServer is CSLAN with IP address 192.168.0.1) 
Device = ${HSM_DEVICE}

#[CryptoServer]
# Device specifier (here: CryptoServer is logical failover device of CSLANs with IP address 192.168.0.2 and IP address 192.168.0.3) 
#Device = { 192.168.0.2 192.168.0.3 }

#[CryptoServer]
# Device specifier Simulator 
#Device = { 3001@127.0.0.1 3003@127.0.0.1 }

#[Slot]
# Slotsection for slot with number 0
#SlotNumber = 0

#[KeyStorage]

# Legacy SDB file
#KeyStorageType = Legacy
# Path to the external keystore
# If KeyStore is defined the external keystore will be created and used at the defined location
# For unix:
#KeyStore = /tmp/P11.pks
# For windows:
#KeyStore = C:/ProgramData/Utimaco/PKCS11_R3/P11.pks

# Database via ODBC
#KeyStorageType = odbc
#KeyStorageConfig = "DSN=PSQL Ucapi External Storage"

fi
EOF

else

  sudo mkdir /opt/ejbca/docker-hsm
  sudo cp -r /tmp/docker-config/docker-hsm/* /opt/ejbca/docker-hsm
  cd /opt/ejbca/docker-hsm
  sudo docker build -t utimacohsm .

  sudo cat <<EOF > /opt/ejbca/docker-ejbca/utimaco/cs_pkcs11_R3.cfg
[Global]
# Path to the logfile (name of logfile is attached by the API)
# For unix:
#Logpath = /tmp
# For windows:
#Logpath = C:/ProgramData/Utimaco/PKCS11_R3

# Loglevel (0 = NONE; 1 = ERROR; 2 = WARNING; 3 = INFO; 4 = TRACE)
Logging = 0
# Maximum size of the logfile in bytes (file is rotated with a backupfile if full)
Logsize = 10mb

# Created/Generated keys are stored in an external or internal database
KeysExternal = false

# If true, every session establishs its own connection
SlotMultiSession = true

# Maximum number of slots that can be used
SlotCount = 10

# If true, leading zeroes of decryption operations will be kept
KeepLeadZeros = false

# Configures load balancing mode ( == 0 ) or failover mode ( > 0 )
# In failover mode, n specifies the interval in seconds after which a reconnection attempt to the failed CryptoServer is started.
FallbackInterval = 0

# Prevents expiring session after inactivity of 15 minutes
KeepAlive = false

# Timeout of the open connection command in ms
ConnectionTimeout = 5000

# Timeout of command execution in ms
CommandTimeout = 60000

# List of official PKCS#11 mechanisms which should be customized
#CustomMechanisms = { CKM_AES_CBC CKM_AES_ECB }

# Enforce thread-safety by using the operating system locking primitives
#ForceOSLocking = true

#[CryptoServer]
# Device specifier (here: CryptoServer is internal PCI device)
# For unix:
#Device = /dev/cs2
# For windows:
#Device = PCI:0  

[CryptoServer]
# Device specifier (here: CryptoServer is CSLAN with IP address 192.168.0.1) 
Device = 3001@hsm

#[CryptoServer]
# Device specifier (here: CryptoServer is logical failover device of CSLANs with IP address 192.168.0.2 and IP address 192.168.0.3) 
#Device = { 192.168.0.2 192.168.0.3 }

#[CryptoServer]
# Device specifier Simulator 
#Device = { 3001@127.0.0.1 3003@127.0.0.1 }

#[Slot]
# Slotsection for slot with number 0
#SlotNumber = 0

#[KeyStorage]

# Legacy SDB file
#KeyStorageType = Legacy
# Path to the external keystore
# If KeyStore is defined the external keystore will be created and used at the defined location
# For unix:
#KeyStore = /tmp/P11.pks
# For windows:
#KeyStore = C:/ProgramData/Utimaco/PKCS11_R3/P11.pks

# Database via ODBC
#KeyStorageType = odbc
#KeyStorageConfig = "DSN=PSQL Ucapi External Storage"

fi
EOF

cat <<EOF > /opt/ejbca/docker-ejbca/utimaco/web.properties
httpserver.pubhttp=80
httpserver.pubhttps=443
httpserver.privhttps=443
httpserver.external.privhttps=8443
web.reqcertindb=false
web.docbaseuri=disabled

cryptotoken.p11.lib.34.name=Utimaco
cryptotoken.p11.lib.34.file=/usr/lib64/libcs_pkcs11_R3.so
cryptotoken.p11.lib.34.canGenerateKeyMsg=ClientToolBox must be used to generate keys for this HSM provider.
cryptotoken.p11.lib.34.canGenerateKey=true
EOF

fi