pragma solidity ^0.4.21;
// pragma experimental ABIEncoderV2;

contract DataPublication {
    string constant ERR_NO_REGISTERED = "ERR_NO_REGISTERED";
    string constant ERR_HAS_REGISTERED_NAME = "ERR_HAS_REGISTERED_NAME";
    string constant ERR_HAS_REGISTERED_ADDR = "ERR_HAS_REGISTERED_ADDR";
    string constant ERR_NOT_REGISTRANT = "ERR_NOT_REGISTRANT";
    string constant ERR_HAS_RELEASED = "ERR_HAS_RELEASED";
    string constant ERR_INVALID_NAME = "ERR_INVALID_NAME";

    mapping(string => address) nameToAddr;
    mapping(address => string) addrToName;
    
    struct YearPublication {
        string title;
        int[12] data;
    }
    mapping(string => mapping(uint => YearPublication)) yearDataByMonth;
    mapping(string => uint[]) publicationYears;
    
    function register(string name) public returns(bool succ, string err) {
        if(hasRegister(name)) {
            succ = false;
            err = ERR_HAS_REGISTERED_NAME;
            return;
        } else if(hasRegisterAddr(msg.sender)) {
            succ = false;
            err = ERR_HAS_REGISTERED_ADDR;
        } else if(bytes(name).length == 0) {
            succ = false;
            err = ERR_INVALID_NAME;
        } else {
            nameToAddr[name] = msg.sender;
            addrToName[msg.sender] = name;
            succ = true;
        }
    }

    function releaseYearByMonth(string name, uint year, string title, int[12] data) public returns(bool succ, string err) {
        YearPublication storage dataSet = yearDataByMonth[name][year];
        if(!hasRegister(name)) {
            succ = false;
            err = ERR_NO_REGISTERED;
            return;
        }
        if (!correctAccount(name, msg.sender)) {
            succ = false;
            err = ERR_NOT_REGISTRANT;
            return;
        }
        if(bytes(dataSet.title).length != 0) {
            succ = false;
            err = ERR_HAS_RELEASED;
            return;
        }
        dataSet.title = title;
        dataSet.data = data;
        succ = true;
        err = "";
        
        uint256 pos = publicationYears[name].length;
        publicationYears[name].length += 1;
        publicationYears[name][pos] = year;
    }
    
        
    function getYearByMonth(string name, uint year) public view returns(string title, int[12] data) {
        // if there is no data, the first return value will be ""
        title = yearDataByMonth[name][year].title;
        data = yearDataByMonth[name][year].data;
    }
    function getPublicationYears(string name) public view returns(uint[] data, string err) {
        if(!hasRegister(name)) {
            data = new uint[](0);
            err = ERR_NO_REGISTERED;
        } else {
            data = publicationYears[name];
            err = "";
        }
    }
    function getName(address a) public view returns(string name) {
        return addrToName[a];
    }
    
    // ==============================
    function hasRegister(string name) private view returns(bool) {
        return nameToAddr[name] != address(0);
    }
    function hasRegisterAddr(address addr) private view returns(bool) {
        return bytes(addrToName[addr]).length != 0;
    }
    function correctAccount(string name, address addr) private view returns(bool) {
        return nameToAddr[name] == addr;
    }
}