
/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');

const getCCP = async (org) => {
    let ccpPath;
    if (org == "cirbus") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'cirbus.example.com', 'connection-cirbus.json');
    } else if (org == "soeing") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'soeing.example.com', 'connection-soeing.json');
    } else if (org == "nataair") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'nataair.example.com', 'connection-nataair.json');
    } else if (org == "lycanairsa") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'lycanairsa.example.com', 'connection-lycanairsa.json');
    } else if (org == "cengkarengairwayengineering") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'cengkarengairwayengineering.example.com', 'connection-cengkarengairwayengineering.json');
    } else if (org == "semco") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'semco.example.com', 'connection-semco.json');
    } else if (org == "aviparairline") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'aviparairline.example.com', 'connection-aviparairline.json');
    } else if (org == "pamulangairway") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'pamulangairway.example.com', 'connection-pamulangairway.json');
    } else {
        return null
    }
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    return ccp
}

const getCaInfo = async (org) => {
    let caInfo
    if (org == "cirbus") {
        caInfo = ccp.certificateAuthorities['ca.orgCirbus.example.com'];
    } else if (org == "soeing") {
        caInfo = ccp.certificateAuthorities['ca.orgSoeing.example.com'];
    } else if (org == "nataair") {
        caInfo = ccp.certificateAuthorities['ca.orgNataAir.example.com'];
    } else if (org == "lycanairsa") {
        caInfo = ccp.certificateAuthorities['ca.orgLycanAirSA.example.com'];
    } else if (org == "cengkarengairwayengineering") {
        caInfo = ccp.certificateAuthorities['ca.orgCengkarengAirwayEngineering.example.com'];
    } else if (org == "semco") {
        caInfo = ccp.certificateAuthorities['ca.orgSemco.example.com'];
    } else if (org == "aviparairline") {
        caInfo = ccp.certificateAuthorities['ca.orgAviparAirline.example.com'];
    } else if (org == "pamulangairway") {
        caInfo = ccp.certificateAuthorities['ca.orgPamulangAirway.example.com'];
    } else
        return null
    return caInfo
}


const getCaUrl = async (org, ccp) => {
    let caURL;
    if (org == "cirbus") {
        caURL = ccp.certificateAuthorities['ca.orgCirbus.example.com'].url;
    } else if (org == "soeing") {
        caURL = ccp.certificateAuthorities['ca.orgSoeing.example.com'].url;
    } else if (org == "nataair") {
        caURL = ccp.certificateAuthorities['ca.orgNataAir.example.com'].url;
    } else if (org == "lycanairsa") {
        caURL = ccp.certificateAuthorities['ca.orgLycanAirSA.example.com'].url;
    } else if (org == "cengkarengairwayengineering") {
        caURL = ccp.certificateAuthorities['ca.orgCengkarengAirwayEngineering.example.com'].url;
    } else if (org == "semco") {
        caURL = ccp.certificateAuthorities['ca.orgSemco.example.com'].url;
    } else if (org == "aviparairline") {
        caURL = ccp.certificateAuthorities['ca.orgAviparAirline.example.com'].url;
    } else if (org == "pamulangairway") {
        caURL = ccp.certificateAuthorities['ca.orgPamulangAirway.example.com'].url;
    } else{
        return null
    }
    return caURL
}

const getWalletPath = async (org) => {
    let walletPath;
    if (org == "cirbus") {
        walletPath = path.join(process.cwd(), 'orgCirbus-wallet');
    } else if (org == "soeing") {
        walletPath = path.join(process.cwd(), 'orgSoeing-wallet');
    } else if (org == "nataair") {
        walletPath = path.join(process.cwd(), 'orgNataAir-wallet');
    } else if (org == "lycanairsa") {
        walletPath = path.join(process.cwd(), 'orgLycanAirSA-wallet');
    } else if (org == "cengkarengairwayengineering") {
        walletPath = path.join(process.cwd(), 'orgCengkarengAirwayEngineering-wallet');
    } else if (org == "semco") {
        walletPath = path.join(process.cwd(), 'orgSemco-wallet');
    } else if (org == "aviparairline") {
        walletPath = path.join(process.cwd(), 'orgAviparAirline-wallet');
    } else if (org == "pamulangairway") {
        walletPath = path.join(process.cwd(), 'orgPamulangAirway-wallet');
    } else
        return null
    return walletPath
}

const getAffiliation = async (org) => {
    let affiliation;
    if (org == "cirbus") {
        affiliation = 'cirbus.department1';
    } else if (org == "soeing") {
        affiliation = 'soeing.department1';
    } else if (org == "nataair") {
        affiliation = 'nataair.department1';
    } else if (org == "lycanairsa") {
        affiliation = 'lycanairrsa.department1';
    } else if (org == "cengkarengairwayengineering") {
        affiliation = 'cengkarengairwayengineering.department1';
    } else if (org == "semco") {
        affiliation = 'semco.department1';
    } else if (org == "aviparairline") {
        affiliation = 'aviparairline.department1';
    } else if (org == "pamulangairway") {
        affiliation = 'pamulangairway.department1';
    } else
        return null
    return affiliation;
}


const getMSP = async (org) => {
    let msp;
    if (org == "cirbus") {
        msp = 'CirbusMSP';
    } else if (org == "soeing") {
        msp = 'SoeingMSP';
    } else if (org == "nataair") {
        msp = 'NataAirMSP';
    } else if (org == "lycanairsa") {
        msp = 'LycanAirSAMSP' ;
    } else if (org == "cengkarengairwayengineering") {
        msp = 'CengkarengAirwayEngineeringMSP';
    } else if (org == "semco") {
        msp = 'SemcoMSP';
    } else if (org == "aviparairline") {
        msp = 'AviparAirlineMSP' ;
    } else if (org == "pamulangairway") {
        msp = 'PamulangAirwayMSP';
    } else
        return null
    return msp;
}

async function registerUser (email, org){
    try {
        let ccp = await getCCP(org);
        const caURL = await getCaUrl(org, ccp)
        const ca = new FabricCAServices(caURL);
    
        const walletPath = await getWalletPath(org)
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

	    const user = email;
        // Check to see if we've already enrolled the user.
        const userIdentity = await wallet.get(user);
        if (userIdentity) {
            console.log('An identity for the user ' + user + ' already exists in the wallet');
            return;
        }

        // Check to see if we've already enrolled the admin user.
        let adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            await enrollAdmin(org);
            adminIdentity = await wallet.get('admin');
        }
         // Get the CA client object from the gateway for interacting with the CA.
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin');
        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({
            affiliation: await getAffiliation(org),
            enrollmentID: user,
            role: 'client'
        }, adminUser);

        console.log("secret is" + secret);

        const enrollment = await ca.enroll({
            enrollmentID: user,
            enrollmentSecret: secret
        });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: await getMSP(org),
            type: 'X.509',
        };
        await wallet.put(user, x509Identity);
        console.log(`Successfully enrolled user ${user} and imported it into the wallet`);
        return secret;
    } catch (error) {
        console.error(`Failed to register user ${user}: ${error}`);
        process.exit(1);
    }
}

async function enrollAdmin(org){
    try {
        let ccp = await getCCP(org);
        const caURL = await getCaUrl(org, ccp)
        const ca = new FabricCAServices(caURL);
    
        const walletPath = await getWalletPath(org)
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identity = await wallet.get('admin');
        if (identity) {
            console.log('An identity for the admin user "admin" already exists in the wallet');
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: await getMSP(org),
            type: 'X.509',
        };
        await wallet.put('admin', x509Identity);
        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
        process.exit(1);
    }
}

module.exports = {
    registerUser: registerUser,
    getCCP: getCCP,
    getWalletPath: getWalletPath,
    enrollAdmin: enrollAdmin
}