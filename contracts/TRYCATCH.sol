//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    Caller contract is designed to cover all possible types of errors and all possible 
    use cases for try-catch.
*/

contract Caller {
    string public latestError; // for visual perception of handled errors
    uint public attempts; // counter for attempts
    address public ledger; // ledger address
    address fetchedUser; // address fetched from ledger

    error AccessDenied(string); // external call to `this` contract custom error

    // events for handling errors in cobsole
    event Failure(bytes);
    event FailureStr(string);
    event Success(address);

    /*
        Try to pass different combinations of parameters and watch console event output
    */

    function accessLedger(uint key, uint id) external {
        // handling via try-catch
        try Ledger(ledger).getUser(key, id) returns (address user) {
            fetchedUser = user;
        } catch Error(string memory data) {
            emit FailureStr(data);
            latestError = "Error";
        } catch Panic(uint code) {
            emit Failure(abi.encodePacked(code));
            latestError = "Panic";
        } catch (bytes memory data) {
            emit Failure(data);
            latestError = "Unnamed";
        }
        attempts++;
    }

    function callLedger(uint key, uint id) external {
        // handling via staticcall
        (bool success, bytes memory data) = ledger.staticcall(
            abi.encodeWithSignature("getUser(uint256,uint256)", key, id)
        );
        if (!success) emit Failure(data);
        else fetchedUser = address(bytes20(uint160(uint(bytes32(data))))); // required type cast
        attempts++;
    }

    // dummy function to be called within `this` contract
    function getFetchedUser(uint code) external view returns (address) {
        if (code != 123) revert AccessDenied("invalid code!");
        return fetchedUser;
    }

    // try-catch handling calls to `this` contract
    function readFetchedUser(uint code) external {
        try this.getFetchedUser(code) returns (address user) {
            emit Success(user);
        } catch (bytes memory data) {
            emit Failure(data);
        }
    }

    /*
        In order for an error to be thrown while creating contract with salt,
        you should pass used salt. So that catching an error requires at least 2 
        function calls with, for example, salt == 1 (if there is no problem with gas limits) 
    */
    function createLedger(uint salt) external {
        // handling create2 contract creation via try-catch
        try new Ledger{salt: bytes32(salt)}() returns (Ledger ledgerContract) {
            ledger = address(ledgerContract);
        } catch (bytes memory data) {
            emit Failure(data);
        }
    }
}

contract Ledger {
    address[2] users = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    ];
    uint constant key = 123; // code for ledger access

    function getUser(uint _key, uint id) external view returns (address) {
        require(_key == key, "access denied");
        return users[id];
    }
}
