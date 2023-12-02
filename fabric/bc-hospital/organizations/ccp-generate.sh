#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${ORGMSP}/$4/" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${ORGMSP}/$4/" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=sardjito
ORGMSP=Sardjito
P0PORT=10051
CAPORT=11051
PEERPEM=organizations/peerOrganizations/sardjito.arsada.org/tlsca/tlsca.sardjito.arsada.org-cert.pem
CAPEM=organizations/peerOrganizations/sardjito.arsada.org/ca/ca.sardjito.arsada.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/sardjito.arsada.org/connection-sardjito.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/sardjito.arsada.org/connection-sardjito.yaml

ORG=dharmais
ORGMSP=Dharmais
P0PORT=10052
CAPORT=11052
PEERPEM=organizations/peerOrganizations/dharmais.arsada.org/tlsca/tlsca.dharmais.arsada.org-cert.pem
CAPEM=organizations/peerOrganizations/dharmais.arsada.org/ca/ca.dharmais.arsada.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/dharmais.arsada.org/connection-dharmais.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/dharmais.arsada.org/connection-dharmais.yaml
