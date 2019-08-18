pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

// Der experimentelle ABIEncoderV2 wird verwendet, damit die Funktion getSchluessel(address adresse)
// das Array string[] memory zurückgeben kann. 

contract PeakFlow {

// Der Patient entzieht seinem Lungenfacharzt die Berechtigung - 
 // das muss nicht extra implementiert werden, da der Patient den vorhandenen
// Wert überschreiben kann. Es wäre allerdings schön, wenn der Lungenarzt
// beim Abruf der Schlüsseliste einen Hinweis erhielte, welcher Patient ihn
// verlassen hat.

 // This declares a new complex type which will
// be used for variables later.
// It will represent a single Patient.   
 struct Patient {
    string name;
    address adresse;
                address lungenarztAdresse;
    uint sollwert;
                uint maxwert;
                string[] schluessel;
                bool exists;
}

// This declares a state variable that
// stores a `Patient` struct for each possible address.
mapping(address => Patient) public patienten;

 //Der Patient registriert sich per Name und adresse (=public key)
function registerPatient(string memory name, address adresse) public {
    Patient memory p = Patient(name, adresse, 0x0000000000000000000000000000000000000000, 0, 0, new string[](0) ,true);
    patienten[adresse] = p; 
 }

 // Es darf nur ein registrierter Patient einen Lungenarzt eintragen.
modifier isRegisteredPatient(address adresse) {
    require(patienten[adresse].exists);
    _;
}

 // Es darf nur ein registrierter Lungenarzt eingetragen werden.
modifier isRegisteredLungenarzt(address adresse) {
    require(lungenaerzte[adresse].exists);
    _;
}

  // Berechtigt ist nur der Lungenarzt des jeweiligem Patienten.
modifier isLungenarztDesPatienten(address adresseLungenarzt, address adressePatient) {
    require(patienten[adressePatient].lungenarztAdresse == adresseLungenarzt);
    _;
}

 // Der Patient berechtigt seinen Lungenfacharzt
function berechtigeLungenarzt(address adresse) public 
    isRegisteredPatient(msg.sender)
    isRegisteredLungenarzt(adresse)
{
      patienten[msg.sender].lungenarztAdresse = adresse;    
 }

 // Der Patient ändert via Sense-it App seinen maxwert
function setMaxwert(uint maxwert) public 
    isRegisteredPatient(msg.sender)
{
      patienten[msg.sender].maxwert = maxwert;    
 }

 // Der Patient erweitert via Sense-it App die Liste seiner Schlüssel zu den csv-Dateien
function addSchluessel(string memory schluessel) public 
    isRegisteredPatient(msg.sender)
{
      patienten[msg.sender].schluessel.push(schluessel);    
 }

 // Der Lungenarzt registriert sich per Name, adresse (=public key) und Fachrichtung 
 struct Lungenarzt {
    string name;
    address adresse;
    address[] patienten;
    bool exists;
}

 mapping(address => Lungenarzt) public lungenaerzte;

function registerLungenarzt(string memory name, address adresse) public {
    Lungenarzt memory a = Lungenarzt(name, adresse, new address[](0) ,true);
    lungenaerzte[adresse] = a;
}

 // Der Lungenarzt darf die Liste seiner Patienten auslesen
function getPatientenAdressListe() public view  
 isRegisteredLungenarzt(msg.sender)
returns(address[] memory)
{
    return lungenaerzte[msg.sender].patienten;    
 }

 // Der Lungenarzt darf die Schlüssellisten seiner Patienten auslesen
function getSchluessel(address adresse) public view  
 isLungenarztDesPatienten(msg.sender, adresse)
returns(string[] memory)
{
    return patienten[adresse].schluessel;    
 }

// Der Lungenarzt darf seiner Patientenliste einen Patienten hinzufügen
function addPatient(address adresse) public 
    isRegisteredPatient(adresse)
    isRegisteredLungenarzt(msg.sender)
{
    lungenaerzte[msg.sender].patienten.push(adresse);    
 }

 // Der Lungenarzt darf den Sollwert seines Patienten ändern
function setSollwert(address adresse, uint sollwert) public 
    isRegisteredPatient(adresse)
    isRegisteredLungenarzt(msg.sender)
    isLungenarztDesPatienten(msg.sender, adresse)
{
    patienten[adresse].sollwert = sollwert;    
 }
}
