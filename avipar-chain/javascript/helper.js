
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
    }  else{
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
    } else
        return null
    return walletPath
}

const getAffiliation = async (org) => {
    return org == "manufacturer" ? 'manufacturer.department1' : ("vendor" ? 'vendor.department1' : 'airline.department1')
}


const getMSP = async (org) => {
    return org == "manufacturer" ? 'ManufacturerMSP' : ("vendor" ? 'VendorMSP' : 'AirlineMSP')
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
        const adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            console.log('Run the enrollAdmin.js application before retrying');
            return;
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

module.exports = {
    registerUser: registerUser,
    getCCP: getCCP,
    getWalletPath: getWalletPath,
}