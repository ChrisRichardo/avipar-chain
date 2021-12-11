var express = require('express');
var bodyParser = require('body-parser');
var app = express();
app.use(bodyParser.json());
// Setting for Hyperledger Fabric
const { Gateway,Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const helper = require('./helper');
const expressJWT = require('express-jwt');
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const e = require('express');

app.set('secret', 'aviparsecret');
app.use(expressJWT({
    secret: 'aviparsecret', algorithms: ['HS256']
}).unless({
    path: ['/api/createuser','/api/signin', '/api/queryallusers', '/api/initdata']
}));
app.use(bearerToken());

async function getNetwork(org, user){
        let ccp = await helper.getCCP(org);

        const walletPath = await helper.getWalletPath(org)
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);
        // Check to see if we've already enrolled the user.
        var identity = await wallet.get(user);
        if (!identity) {
            if (user == "admin"){
                await helper.enrollAdmin(org);
                identity = await wallet.get(user);
            }else{
                console.log('An identity for the user '+ user +' does not exist in the wallet');
                return
            }
        }
        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: user, discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('mychannel');
        var contract = network.getContract('fabcar');

        var networkObj = {
                gateway: gateway,
                contract: contract
        }
        // Get the contract from the network.
        return networkObj
}

app.use((req, res, next) => {
        if (req.originalUrl.indexOf('/api/createuser') >= 0 || req.originalUrl.indexOf('/api/signin') >= 0 || req.originalUrl.indexOf('/api/queryallusers') >= 0 || req.originalUrl.indexOf('/api/initdata') >= 0) {
                req.username = "admin";
                return next();
        }
        var token = req.token;
        jwt.verify(token, app.get('secret'), (err, decoded) => {
            if (err) {
                console.log(`Error ================:${err}`)
                res.send({
                    success: false,
                    message: 'Failed to authenticate token. Make sure to include the ' +
                        'token returned from /users call in the authorization header ' +
                        ' as a Bearer token'
                });
                return;
            } else {
                req.username = decoded.username;
                req.orgname = decoded.orgName;
                console.log('Decoded from JWT token: username - ' + decoded.username + ', orgname - ' + decoded.orgName);
                return next();
            }
        });
});

app.get('/api/queryallusers', async function (req, res)  {
        try {         
            var networkObj = await getNetwork(req.body.org, req.username);

            const result = await networkObj.contract.evaluateTransaction('queryAllUsers');
            console.log(JSON.parse(result));
            console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
    });

app.get('/api/queryallassets', async function (req, res)  {
        try {         
            var networkObj = await getNetwork(req.orgname, req.username);

            const result = await networkObj.contract.evaluateTransaction('queryAllAssets');
            console.log(JSON.parse(result));
            console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
    });

 app.get('/api/queryallpo', async function (req, res)  {
        try {         
            var networkObj = await getNetwork(req.orgname, req.username);

            const result = await networkObj.contract.evaluateTransaction('queryAllPO');
            console.log(JSON.parse(result));
            console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
});

app.get('/api/queryallcounters', async function (req, res)  {
        try {
    const ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'manufacturer.example.com', 'connection-manufacturer.json');
            const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    // Create a new file system based wallet for managing identities.
            const walletPath = path.join(process.cwd(), 'wallet');
            const wallet = await Wallets.newFileSystemWallet(walletPath);
            console.log(`Wallet path: ${walletPath}`);
    
            // Check to see if we've already enrolled the user.
            const identity = await wallet.get('appUser');
            if (!identity) {
                console.log('An identity for the user "appUser" does not exist in the wallet');
                console.log('Run the registerUser.js application before retrying');
                return;
            }
      // Create a new gateway for connecting to our peer node.
            const gateway = new Gateway();
            await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });
    
            // Get the network (channel) our contract is deployed to.
            const network = await gateway.getNetwork('mychannel');
    
            // Get the contract from the network.
            const contract = network.getContract('fabcar');
    
            // Evaluate the specified transaction.
            // queryCar transaction - requires 1 argument, ex: ('queryCar', 'CAR4')
            // queryAllCars transaction - requires no arguments, ex: ('queryAllCars')
            const result = await contract.evaluateTransaction('queryAllCounters');
            console.log(JSON.parse(result)[0]["Record"]);
            console.log(`Counter has been evaluated, result is: ${result.toString()}`);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
    });
    
app.post('/api/asset/add', async function (req, res) {
    try {
        var todayDateTime = new Date();   
        var timestamp = todayDateTime.getUTCFullYear() +"-"+ (todayDateTime.getUTCMonth()+1) +"-"+ todayDateTime.getUTCDate() + " " + todayDateTime.getUTCHours() + ":" + todayDateTime.getUTCMinutes() + ":" + todayDateTime.getUTCSeconds();

        var networkObj = await getNetwork(req.orgname, req.username);

        var resultBuf = await networkObj.contract.submitTransaction('createAsset', req.body.number, req.body.name, req.username, req.body.quantity, req.body.weight, timestamp, "");
        var result= JSON.parse(resultBuf.toString())
        if(result.toString() == "false"){
                message = "Asset existed";
        } else{
                message = "Asset has been created";
        }
        console.log(message);
        res.send(message);
// Disconnect from the gateway.
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
})

app.get('/api/queryassetowned', async function (req, res) {
        try {
            var networkObj = await getNetwork(req.orgname, req.username);
            const result = await networkObj.contract.evaluateTransaction('queryAssetByOwner', req.username);
            var message;
            if(result.toString() != "[]"){
                message = `Transaction has been evaluated, result is: ${result.toString()}`;
            } else{
                message = "Assets not existed"
            }
            console.log(message);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
});
    
app.get('/api/asset/detail/:asset_index', async function (req, res) {
    try {
        var networkObj = await getNetwork(req.orgname, req.username);

        var resultBuf = await networkObj.contract.submitTransaction('queryAsset', req.params.asset_index);
        var result= JSON.parse(resultBuf.toString())
        if(result.Status == false){
            res.status(400).json({response: result.Message});
            console.log(result.Message);
        } else{        
            console.log(result.Record);
            res.status(200).json({response: result.Record});
            console.log(result.Message);
        }
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})

app.get('/api/asset/history/:asset_index', async function (req, res) {
    try {
        var networkObj = await getNetwork(req.orgname, req.username);

        var resultBuf = await networkObj.contract.submitTransaction('queryAssetHistory', req.params.asset_index, "");
        var result= JSON.parse(resultBuf.toString())
        if(result.Status == false){
            res.status(400).json({response: result.Message});
            console.log(result.Message);
        } else{        
            console.log(result.Record);
            res.status(200).json({response: result.Record});
            console.log(result.Message);
        }
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})

app.post('/api/order/add/:asset_index', async function (req, res) {
    try {
        var todayDateTime = new Date();   
        var timestamp = [(todayDateTime.getMonth()+1).padLeft(),
        todayDateTime.getDate().padLeft(),
        todayDateTime.getFullYear()].join('/') +' ' +
       [todayDateTime.getHours().padLeft(),
        todayDateTime.getMinutes().padLeft(),
        todayDateTime.getSeconds().padLeft()].join(':');

        var networkObj = await getNetwork(req.orgname, req.username);

        var result = await networkObj.contract.submitTransaction('createPurchaseOrder', req.params.asset_index, req.body.owner, req.body.quantity, timestamp);
        
        var message;
        if(result.toString() == "false"){
            message = "PO Creation failed";
            res.status(400).json({response: message});
        } else{
            message = "PO Creation suceeded";
            res.status(200).json({response: result.Message});
        }
        console.log(message);
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})

app.put('/api/order/update/:asset_index', async function (req, res) {
    try {
        var todayDateTime = new Date();   
        var timestamp = [(todayDateTime.getMonth()+1).padLeft(),
        todayDateTime.getDate().padLeft(),
        todayDateTime.getFullYear()].join('/') +' ' +
       [todayDateTime.getHours().padLeft(),
        todayDateTime.getMinutes().padLeft(),
        todayDateTime.getSeconds().padLeft()].join(':');

        var networkObj = await getNetwork(req.orgname, req.username);

        var result = await networkObj.contract.submitTransaction('updatePurchaseOrderStatus', req.params.asset_index, req.body.updateby, timestamp);
        
        var message;
        if(result.toString() == "false"){
            message = "PO Creation failed";
            res.status(400).json({response: message});
        } else{
            message = "PO Creation suceeded";
            res.status(200).json({response: result.Message});
        }
        console.log(message);
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})

app.put('/api/asset/transfer/:asset_index', async function (req, res) {
    try {
        var networkObj = await getNetwork(req.orgname, req.username);

        var resultBuf = await networkObj.contract.submitTransaction('transferAssetOwner', req.params.asset_index, req.body.owner, timestamp);
        var result= JSON.parse(resultBuf.toString())
        if(result.Status == false){
            res.status(400).json({response: result.Message});
        } else{        
            res.status(200).json({response: result.Message});
        }
        console.log(result.Message);
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})

app.put('/api/asset/update/:asset_index', async function (req, res) {
    try {
        var todayDateTime = new Date();   
        var timestamp = [(todayDateTime.getMonth()+1).padLeft(),
        todayDateTime.getDate().padLeft(),
        todayDateTime.getFullYear()].join('/') +' ' +
       [todayDateTime.getHours().padLeft(),
        todayDateTime.getMinutes().padLeft(),
        todayDateTime.getSeconds().padLeft()].join(':');

        var networkObj = await getNetwork(req.orgname, req.username);
        var resultBuf = await networkObj.contract.submitTransaction('updateAsset', req.params.asset_index, req.body.name, req.body.number, req.body.status, req.body.quantity, req.body.weight, timestamp, req.username, req.body.newOwner);
        var result= JSON.parse(resultBuf.toString())
        if(result.Status == false){
            res.status(400).json({response: result.Message});
        } else{        
            res.status(200).json({response: result.Message});
        }
        console.log(result.Message);
        await networkObj.gateway.disconnect();
} catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    } 
})


app.post('/api/signin/', async function (req, res) {
        try {
            var networkObjQuery = await getNetwork("manufacturer", "admin");
            var resultBuf = await networkObjQuery.contract.evaluateTransaction('queryUserByEmail', req.body.email);
            var result= JSON.parse(resultBuf.toString());
            await networkObjQuery.gateway.disconnect();
            console.log(result);
            if(result.Status == false){
                message = "User not existed"
                res.status(400).json({response: message});
            } else {
                console.log(result.Record);
                var networkObj = await getNetwork(result.Record.Org, req.username);
                    
                var resultBuf2 = await networkObj.contract.submitTransaction('signIn', req.body.email, req.body.password);
                var result2= JSON.parse(resultBuf2.toString())
                console.log(result2);
                var message;
                if(result2.Status == false){
                    message = "Wrong user credential"
                    res.status(400).json({response: message});
                } else{
                    var token = jwt.sign({
                            exp: Math.floor(Date.now() / 1000) + 30000,
                            username: req.body.email,
                            orgName: result.Record.Org
                        }, app.get('secret'));                
                    message = req.body.email + ' signed in using ' + token;
                    res.status(200).json({response: token});
                }
                console.log(message);
                
        // Disconnect from the gateway.
                await networkObj.gateway.disconnect();
            }
    } catch (error) {
            console.error(`Failed to submit transaction: ${error}`);
            process.exit(1);
        }
})

app.post('/api/createuser/', async function (req, res) {
        try {
            var networkObj = await getNetwork(req.body.org, "admin");

            var result = await networkObj.contract.submitTransaction('createUser', req.body.name, req.body.email, req.body.org, req.body.role, req.body.address, req.body.password);
            var message;
            if(result.toString() == "false"){
                message = "Email existed";
                res.status(400).json({response: message});
            } else{
                var registeredUserEmail = await helper.registerUser(req.body.email, req.body.org);
                var token = jwt.sign({
                        exp: Math.floor(Date.now() / 1000) + 30000,
                        username: req.body.email,
                        orgName: req.body.org
                }, app.get('secret'));
                
                message = 'User ' + req.body.email+ ' has been created and the user token is ' + token;
                res.status(200).json({response: token});
            }
            console.log(message);
           
    // Disconnect from the gateway.
            await networkObj.gateway.disconnect();
    } catch (error) {
            console.error(`Failed to submit transaction: ${error}`);
            process.exit(1);
        }
})

app.get('/api/user/:user_email', async function (req, res) {
        try {
            var networkObj = await getNetwork();
            const result = await networkObj.contract.evaluateTransaction('queryUserByEmail', req.params.user_email);
            var message;
            if(result.toString() != "[]"){
                message = `Transaction has been evaluated, result is: ${result.toString()}`;
            } else{
                message = "User not existed"
            }
            console.log(message);
            res.status(200).json({response: result.toString()});
    } catch (error) {
            console.error(`Failed to evaluate transaction: ${error}`);
            res.status(500).json({error: error});
            process.exit(1);
        }
});
    
    
app.get('/api/initdata', async function (req, res)  {
    try {
        var todayDateTime = new Date();   
        var timestamp = [(todayDateTime.getMonth()+1).padLeft(),
        todayDateTime.getDate().padLeft(),
        todayDateTime.getFullYear()].join('/') +' ' +
       [todayDateTime.getHours().padLeft(),
        todayDateTime.getMinutes().padLeft(),
        todayDateTime.getSeconds().padLeft()].join(':');

        var networkObj = await getNetwork("manufacturer", "admin");
        
        var users = [
            ["Payo", "payo@gmail.com", "manufacturer", "supervisor", "Cilegon", "payo"],
            ["Chris", "chris@gmail.com", "vendor", "supervisor", "Daan Mogot", "chris"],
            ["Nadim", "nadim@gmail.com", "mro", "supervisor", "Pamulang", "nadim"],
            ["Christest", "christest@gmail.com", "airline", "supervisor", "Test", "123"],
        ]
        for (var user of users){
            await networkObj.contract.submitTransaction('createUser', user[0], user[1], user[2], user[3], user[4], user[5]);
            await helper.registerUser(user[1], user[2]);
        }
        
        var assets = [
            ["SPR001", "Buntut", "payo@gmail.com", 10, 2],
            ["SPR002", "Ekor", "payo@gmail.com", 50, 5],
        ]
        for (var asset of assets){
            console.log(asset);
            await networkObj.contract.submitTransaction('createAsset', asset[0], asset[1], asset[2], asset[3], asset[4], timestamp, "");
        }
        
        console.log("Init data success");
        res.status(200).json({response: "Init data success"});
        await networkObj.gateway.disconnect();
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        res.status(500).json({error: error});
        process.exit(1);
     }
});

Number.prototype.padLeft = function(base,chr){
    var  len = (String(base || 10).length - String(this).length)+1;
    return len > 0? new Array(len).join(chr || '0')+this : this;
}

app.listen(8080);