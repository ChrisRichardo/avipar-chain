#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
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
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=Cirbus
P0PORT=6051
CAPORT=6054
PEERPEM=organizations/peerOrganizations/cirbus.example.com/tlsca/tlsca.cirbus.example.com-cert.pem
CAPEM=organizations/peerOrganizations/cirbus.example.com/ca/ca.cirbus.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/cirbus.example.com/connection-cirbus.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/cirbus.example.com/connection-cirbus.yaml

ORG=Soeing
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/soeing.example.com/tlsca/tlsca.soeing.example.com-cert.pem
CAPEM=organizations/peerOrganizations/soeing.example.com/ca/ca.soeing.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/soeing.example.com/connection-soeing.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/soeing.example.com/connection-soeing.yaml

ORG=NataAir
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/nataair.example.com/tlsca/tlsca.nataair.example.com-cert.pem
CAPEM=organizations/peerOrganizations/nataair.example.com/ca/ca.nataair.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/nataair.example.com/connection-nataair.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/nataair.example.com/connection-nataair.yaml

ORG=LycanAirSA
P0PORT=10051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/lycanairsa.example.com/tlsca/tlsca.lycanairsa.example.com-cert.pem
CAPEM=organizations/peerOrganizations/lycanairsa.example.com/ca/ca.lycanairsa.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/lycanairsa.example.com/connection-lycanairsa.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/lycanairsa.example.com/connection-lycanairsa.yaml

ORG=CengkarengAirwayEngineering
P0PORT=26051
CAPORT=26054
PEERPEM=organizations/peerOrganizations/cengkarengairwayengineering.example.com/tlsca/tlsca.cengkarengairwayengineering.example.com-cert.pem
CAPEM=organizations/peerOrganizations/cengkarengairwayengineering.example.com/ca/ca.cengkarengairwayengineering.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/cengkarengairwayengineering.example.com/connection-cengkarengairwayengineering.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/cengkarengairwayengineering.example.com/connection-cengkarengairwayengineering.yaml

ORG=Semco
P0PORT=27051
CAPORT=27054
PEERPEM=organizations/peerOrganizations/semco.example.com/tlsca/tlsca.semco.example.com-cert.pem
CAPEM=organizations/peerOrganizations/semco.example.com/ca/ca.semco.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/semco.example.com/connection-semco.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/semco.example.com/connection-semco.yaml

ORG=AviparAirline
P0PORT=28051
CAPORT=28054
PEERPEM=organizations/peerOrganizations/aviparairline.example.com/tlsca/tlsca.aviparairline.example.com-cert.pem
CAPEM=organizations/peerOrganizations/aviparairline.example.com/ca/ca.aviparairline.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/aviparairline.example.com/connection-aviparairline.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/aviparairline.example.com/connection-aviparairline.yaml

ORG=PamulangAirway
P0PORT=29051
CAPORT=29054
PEERPEM=organizations/peerOrganizations/pamulangairway.example.com/tlsca/tlsca.pamulangairway.example.com-cert.pem
CAPEM=organizations/peerOrganizations/pamulangairway.example.com/ca/ca.pamulangairway.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pamulangairway.example.com/connection-pamulangairway.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pamulangairway.example.com/connection-pamulangairway.yaml
