import { PeakflowApp } from "./peakflow.mjs";

export class MainApp extends HTMLElement {
   
    static get observedAttributes() { return ['wallet'] }

    get balanceButton() {
        return this.querySelector('#getBalance');
    }

    get balanceOutput() {
        return this.querySelector('#balance output');
    }

    get initPeakflowButton() {
        return this.querySelector('#initPeakflow');
    }

    constructor() {
        super();
        this.render();
    }

    attributeChangedCallback(name, oldValue, newValue) {
        if ( name === 'wallet' ) {
            this.wallet = newValue;
            console.log('wallet adress is now: ', newValue);
            console.log(this.wallet);
        }
        this.render();
    }

    render() {
        let mutatedHtml = '';
        mutatedHtml += `
            <div id="balance">Your Balance: <output></output>
            <button id="getBalance">Balance()</button><button id="initPeakflow">Start Peakflow</button>
        `;
        if(this.peakflowInitialised) {
            mutatedHtml += '<peakflow-app wallet=' + this.wallet + '></peakflow-app>';
        }
        mutatedHtml +`</div>
        `;
        this.innerHTML = mutatedHtml;
        this.initEvents();
    }

    initEvents() {
        this.balanceButton.addEventListener('click', () => {
            this.balanceButtonOnClick()
        });
        this.initPeakflowButton.addEventListener('click', () => {
            this.peakflowInitialised = true;
            this.render();
        })
    }

    balanceButtonOnClick() {
        console.log(this.wallet);
        fetch('./api/balance?wallet=' + this.wallet).then( response => response.text() ).then(walletBalance => {
            this.balanceOutput.textContent = walletBalance;
        });
    }

}

if (!customElements.get('main-app')) {
    customElements.define('main-app', MainApp);
}
