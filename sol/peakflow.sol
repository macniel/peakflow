pragma solidity >=0.4.22 <0.6.0;

// In Remix address-Parameter in doppelten Hochkommata eingeben: f(address, address) --> f("0xc8f...g5","0xg94..a2")

contract PeakFlow {
    
 struct Patient {
    string name;
    address adresse;
	address lungenarztAdresse;
    uint sollwert;
	uint maxwert;
	string dbschluessel;
 }

 struct Lungenarzt {
   string name;
   address adresse;
   //Die Adressen der Patienten Semikolon separiert
   string patienten;
 }

 mapping(address => Patient) public patienten; 
 mapping(address => Lungenarzt) public lungenaerzte;

 function registerPatient(string memory name, address adresse) public {
   Patient memory p = Patient(name, adresse, 0x0000000000000000000000000000000000000000, 0, 0, '');
   patienten[adresse] = p; 
 }

 function registerLungenarzt(string memory name, address adresse) public {
   Lungenarzt memory a = Lungenarzt(name, adresse, '');
   lungenaerzte[adresse] = a;
 }

 // Funktionen für Patienten
 
 function berechtigeLungenarztFuerPatient(address patient, address lungenarzt) public {
   patienten[patient].lungenarztAdresse = lungenarzt;    
 }
 
 // Das darf in der realen Welt nur der Lungenarzt des Patienten
 function setSollwertFuerPatient(address patient, uint sollwert) public {
   patienten[patient].sollwert = sollwert;    
 }

 // Das darf in der realen Welt nur der Patient
 function setMaxwertFuerPatient(address patient, uint maxwert) public {
   patienten[patient].maxwert = maxwert;    
 }
 
 function setDBSchluesselFuerPatient(address patient,string memory schluessel) public {
   patienten[patient].dbschluessel = schluessel;    
 }

 function getDBSchluesselFuerPatient(address adresse) public view returns(string memory) {
   return patienten[adresse].dbschluessel;    
 }
 
 // Funktionen für Lungenärzte

 // Das darf in der realen Welt nur der Lungenarzt
 function getPatientenAdressListeVonLungenarzt(address lungenarzt) public view returns(string memory) {
   return lungenaerzte[lungenarzt].patienten;    
 }

 // Das darf in der realen Welt nur der Lungenarzt
 function addPatientToAddressListeVonLungenarzt(address lungenarzt, address patient) public {
   bytes memory tempEmptyStringTest = bytes(lungenaerzte[lungenarzt].patienten); 
   if (tempEmptyStringTest.length == 0) {
     lungenaerzte[lungenarzt].patienten =  addressToString(patient);    
   } else {
     string memory helpString = concat(";", addressToString(patient));
     lungenaerzte[lungenarzt].patienten =
      concat(lungenaerzte[lungenarzt].patienten, helpString);
   }  
 }
 
 // Interne Hilfsfunktionen 
 function addressToString(address _address) internal pure returns(string memory) {
    bytes32 _bytes = bytes32(uint256(_address));
    bytes memory HEX = "0123456789abcdef";
    bytes memory _string = new bytes(42);
    _string[0] = '0';
    _string[1] = 'x';
    for(uint i = 0; i < 20; i++) {
        _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
        _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
    }
    return string(_string);
 }
 
 function concat(string memory _base, string memory _value) internal pure returns (string memory) {
   bytes memory _baseBytes = bytes(_base);
   bytes memory _valueBytes = bytes(_value);
   string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
   bytes memory _newValue = bytes(_tmpValue);
   uint i;
   uint j;
   for(i=0; i<_baseBytes.length; i++) {
     _newValue[j++] = _baseBytes[i];
   }
   for(i=0; i<_valueBytes.length; i++) {
     _newValue[j++] = _valueBytes[i];
   }
   return string(_newValue);
 } 
}