export class PeakflowApp extends HTMLElement {
    
    static get observedAttributes() { return ['wallet'] }

    getData() {
        console.log('connected component');
        fetch('/api/patienten?wallet=' + this.wallet).then( response => response.json() ).then((patientenListe) => {

            this.patientenListe = patientenListe;
            this.render();
        });
    }

    adoptedCallback() {
        console.log('adopted');
    }

    constructor() {
        super();
        this.patientenListe = [];
        this.render();
    }

    

    attributeChangedCallback(name, oldValue, newValue) {
        if ( name === 'wallet' ) {
            this.wallet = newValue;
            console.log('wallet adress is now: ', newValue);
            console.log(this.wallet);
            this.getData();
            this.render();
        }
        
    }

    get addPatientButton() {
        return this.querySelector('#addPatient');
    }

    get patientAddress() {
        return this.querySelector('#patient').value;
    }

    resetPatientAddress() {
        this.querySelector('#patient').value = '';
    }

    render() {
        
        let mutatedHtml = '<table><tr><th>Patienten-Adresse</th><th>Zugriff?</th></tr>';
        if ( this.patientenListe.length > 0 ) {
        this.patientenListe.forEach( patient => {
            mutatedHtml += `<tr><td>${patient}</td></tr>`;
        });
        } else {
            mutatedHtml += `<tr><td colspan="2">Keine Patienten verfügbar</td></tr>`;
        }
    
        mutatedHtml += '</table>';
        mutatedHtml += `<input id="patient"><button id="addPatient">Add</button>`;

        this.innerHTML = mutatedHtml;

        this.initEvents();
    }

    async addPatientToList(address) {
        return fetch('./api/patienten?wallet=' + this.wallet, 
        {
            method: 'POST', 
            body: JSON.stringify({
                address: address,
            }),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        }).then(response => response.json());
    }

    initEvents() {
        this.addPatientButton.addEventListener('click', async () => {
            if ( this.patientAddress != '' ) {

                await this.addPatientToList(this.patientAddress);

                this.render();
                this.resetPatientAddress();
                
            }
        })
    }

}

if (!customElements.get('peakflow-app')) {
    customElements.define('peakflow-app', PeakflowApp);
}