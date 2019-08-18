const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');

var privateKey = fs.readFileSync(path.join(__dirname, 'server.key'), 'utf8');
var certificate = fs.readFileSync(path.join(__dirname, '\server.cert'), 'utf8');
var credentials = {key: privateKey, cert: certificate};

const contractAddress = '0x06A8D9c857F5b83cEccdD9171A350cb51295e75c';
const contractAbi = JSON.parse(fs.readFileSync('./sol/peakflow.abi'));
console.log('contract ABI loaded');

let app = express();
const Web3 = require('web3');

const w3 = new Web3(new Web3.providers.WebsocketProvider('wss://rinkeby.infura.io/ws'));
const peakflow = new w3.eth.Contract(contractAbi, contractAddress);
console.log('Connected to rinkeby and created contract interface');

app.get('/api/balance', async (req, res) => {
    console.log('GET: get Balance');
    const walletAddress = req.query['wallet'];
    if ( walletAddress != null ) {
    const balance = await w3.eth.getBalance(walletAddress);
    res.send(Web3.utils.fromWei(balance, 'ether'));
    } else {
        res.sendStatus(400);
    }
});

app.get('/api/patienten', async (req, res) => {

    console.log('GET: get patienten');
    const from = req.query.wallet;
    let patienten = await peakflow.methods.getPatientenAdressListe().call();
    console.log(patienten);
    res.send(JSON.stringify([]));
});
app.use(bodyParser.json());
app.post('/api/patienten', async(req, res) => {
    console.log(req.body.address, req.query.wallet);
    let result = await peakflow.methods.addPatient({adresse: req.body.patientAdresse}).call();
    console.log(result);
});

app.use('/', express.static('./public'));
var httpServer = http.createServer(app);
httpServer.listen(8080, () => {
    'App is listening on 8080'
});
https.createServer(credentials, app).listen(8443, () => {
    'App is listening on 8443'
});