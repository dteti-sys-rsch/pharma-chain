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

ORG=prudential
ORGMSP=Prudential
P0PORT=10053
CAPORT=11053
PEERPEM=organizations/peerOrganizations/prudential.aaui.org/tlsca/tlsca.prudential.aaui.org-cert.pem
CAPEM=organizations/peerOrganizations/prudential.aaui.org/ca/ca.prudential.aaui.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/prudential.aaui.org/connection-prudential.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/prudential.aaui.org/connection-prudential.yaml

ORG=manulife
ORGMSP=Manulife
P0PORT=10054
CAPORT=11054
PEERPEM=organizations/peerOrganizations/manulife.aaui.org/tlsca/tlsca.manulife.aaui.org-cert.pem
CAPEM=organizations/peerOrganizations/manulife.aaui.org/ca/ca.manulife.aaui.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/manulife.aaui.org/connection-manulife.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/manulife.aaui.org/connection-manulife.yaml
