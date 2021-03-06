// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

contract AddressArrayContract {
    struct AddressArray {
        address[] addrs;
        mapping(address => bool) setted;
    }

    function add(AddressArray storage _addressArr, address _addr)  internal returns (bool){
        require(
            _addressArr.setted[_addr] == false,
            "onlyNotSetedAddress: _addr is seted"
        );
        _addressArr.addrs.push(_addr);
        _addressArr.setted[_addr]=true;
        return true;
    }

    function remove(AddressArray storage _addressArr, address _addr) internal returns (bool){
        require(
            _addressArr.setted[_addr] == true,
            "onlyNotSetedAddress: _addr is not seted"
        );
        _addressArr.setted[_addr] = false;
        return true;
    }

    function Addrs(AddressArray storage _addressArr) internal view returns (address [] memory){
        return _addressArr.addrs;
    }

    function setted(AddressArray storage _addressArr, address _addr) internal view returns (bool){
        return _addressArr.setted[_addr];
    }
}
