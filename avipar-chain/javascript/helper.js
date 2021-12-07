
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
    if (org == "manufacturer") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'manufacturer.example.com', 'connection-manufacturer.json');
    } else if (org == "vendor") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'vendor.example.com', 'connection-vendor.json');
    } else if (org == "airline") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'airline.example.com', 'connection-airline.json');
    } else if (org == "mro") {
        ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'mro.example.com', 'connection-mro.json');
    } else {
        return null
    }
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    return ccp
}

const getCaInfo = async (org) => {
    let caInfo
    if (org == "manufacturer") {
        caInfo = ccp.certificateAuthorities['ca.orgManufacturer.example.com'];
    } else if (org == "vendor") {
        caInfo = ccp.certificateAuthorities['ca.orgVendor.example.com'];
    } else if (org == "airline") {
        caInfo = ccp.certificateAuthorities['ca.orgAirline.example.com'];
    } else if (org == "mro") {
        caInfo = ccp.certificateAuthorities['ca.orgMRO.example.com'];
    } else
        return null
    return caInfo
}


const getCaUrl = async (org, ccp) => {
    let caURL;
    if (org == "manufacturer") {
        caURL = ccp.certificateAuthorities['ca.orgManufacturer.example.com'].url;
    } else if (org == "vendor") {
        caURL = ccp.certificateAuthorities['ca.orgVendor.example.com'].url;
    } else if (org == "airline") {
        caURL = ccp.certificateAuthorities['ca.orgAirline.example.com'].url;
    } else if (org == "mro") {
        caURL = ccp.certificateAuthorities['ca.orgMRO.example.com'].url;
    } 
    else{
        return null
    }
    return caURL
}

const getWalletPath = async (org) => {
    let walletPath;
    if (org == "manufacturer") {
        walletPath = path.join(process.cwd(), 'orgManufacturer-wallet');
    } else if (org == "vendor") {
        walletPath = path.join(process.cwd(), 'orgVendor-wallet');
    } else if (org == "airline") {
        walletPath = path.join(process.cwd(), 'orgAirline-wallet');
    } else if (org == "mro") {
        walletPath = path.join(process.cwd(), 'orgMRO-wallet');
    } else
        return null
    return walletPath
}

const getAffiliation = async (org) => {
    let affiliation;
    if (org == "manufacturer") {
        affiliation = 'manufacturer.department1';
    } else if (org == "vendor") {
        affiliation = 'vendor.department1';
    } else if (org == "airline") {
        affiliation = 'airline.department1';
    } else if (org == "mro") {
        affiliation = 'mro.department1';
    } else
        return null
    return affiliation;
}


const getMSP = async (org) => {
    let msp;
    if (org == "manufacturer") {
        msp = 'ManufacturerMSP';
    } else if (org == "vendor") {
        msp = 'VendorMSP';
    } else if (org == "airline") {
        msp = 'AirlineMSP';
    } else if (org == "mro") {
        msp = 'MROMSP' ;
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