## cert conversion see: htcondor/documentation/grid_certificate_conversion_p12-2-pem.pdf
# openssl pkcs12 -in usercert.p12 -nokeys -clcerts -out ~/.globus/usercert.pem
# openssl pkcs12 -in usercert.p12 -nocerts  -out ~/.globus/userkey.pem
## remove passwort from keyfile:
# openssl pkcs12 -export -in pem_with_pass.pem -out pem_without_pass.p12
# openssl rsa -in userkey.pem -out /etc/ssl/private/userkey.nocrypt.key
