const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');

var privateKey = fs.readFileSync(path.join(__dirname, 'server.key'), 'utf8');
var certificate = fs.readFileSync(path.join(__dirname, '\server.cert'), 'utf8');
var credentials = {key: privateKey, cert: certificate};

const contractAddress = '0x82e70519cd51dd635c844b4056435258f7abaa9a';
const contractAbi = JSON.parse(fs.readFileSync('./sol/peakflow.abi'));
console.log('contract ABI loaded');

let app = express();
const Web3 = require('web3');

const w3 = new Web3(new Web3.providers.WebsocketProvider('wss://rinkeby.infura.io/ws'));
const peakflow = new w3.eth.Contract(contractAbi, contractAddress);
console.log('Connected to rinkeby and created contract interface');

app.get('/api/balance', async (req, res) => {
    const walletAddress = req.query['wallet'];
    if ( walletAddress != null ) {
    const balance = await w3.eth.getBalance(walletAddress);
    res.send(Web3.utils.fromWei(balance, 'ether'));
    } else {
        res.sendStatus(400);
    }
});

app.get('/api/patienten', async (req, res) => {
    const from = req.query.wallet;
    let patienten = await peakflow.methods.getPatientenAdressListeVonLungenarzt(from).call();
    console.log('get patients>', patienten);
    res.send(JSON.stringify(patienten));
});
app.use(bodyParser.json());
app.post('/api/patienten', async(req, res) => {
    const from = req.query.wallet;
    let result = await peakflow.methods.addPatientToAddressListeVonLungenarzt(from, req.body.address).call();
    console.log('add patient>', result);
    res.send(JSON.stringify(result));
});

app.use(bodyParser.json());
app.post('/api/register', async(req, res) => {
    const patient = req.body.address;
    const name = req.body.name;
    let result = await peakflow.methods.registerPatient(name, patient).call();
    console.log('register patient>', result);
    res.send(JSON.stringify(result));
});

app.use('/', express.static('./public'));
var httpServer = http.createServer(app);
httpServer.listen(8080, () => {
    'App is listening on 8080'
});
https.createServer(credentials, app).listen(8443, () => {
    'App is listening on 8443'
});