//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitOperations {
    function leftShift(int number, uint positions) public pure returns (int) {
        /*
            Shifts all binary digits to the left by `positions` slots and pads all moved bits with zeros.
            Only possible to shift to a positive number (num << -1 is not valid).

            Examples:
            int8(98) << 2 <--> 01100010 << 2 == 10001000 <--> 10001000 == 136 (overflow for int8) <--> int8(136) == -120
            int(98) << 2 <--> 00...0011100010 << 2 == 00...001110001000 <--> 00...001110001000 == 392 == 98 * 2 ^ 2


            int8(-17) << 3 <--> 11101111 << 3 == 01111000 <--> 01111000 == 120
            int(-17) << 3 <--> 11...1111101111 << 3 == 11...1101111000 <-->  11...1110001000 == -136 == -17 * 2 ^ 3
        */

        return number << positions;
    }

    function rightShift(int number, uint positions) public pure returns (int) {
        /*
            Shifts all binary digits to the right by `positions` slots and pads all moved bits with primary bits.
            Only possible to shift to a positive number (num >> -1 is not valid).

            Examples:
            int*(89) >> 2 <--> 00...001100010 >> 2 == 00...0000011000 <--> 00...0000011000 == 24 == floor(98 / 4)
            int*(-17) >> 3 <--> 11...11101111 >> 3 == 11..11111101 <--> 11..11111101 == -3
        */

        return number >> positions;
    }

    function and(int main, int secondary) public pure returns (int) {
        /*
            Performs bitwise AND to two integers (their binary form).

            Example:
            main:      93 (10) = 01011101 (2)
            secondary: 26 (10) = 00011010 (2)
            result:              00011000 (2) = 24 (10)
        */

        return main & secondary;
    }

    function or(int main, int secondary) public pure returns (int) {
        /*
            Performs bitwise OR to two integers (their binary form).

            Example:
            main:      93 (10) = 01011101 (2)
            secondary: 26 (10) = 00011010 (2)
            result:              01011111 (2) = 95 (10)
        */

        return main | secondary;
    }

    function xor(int main, int secondary) public pure returns (int) {
        /*
            Performs bitwise XOR to two integers (their binary form).

            Example:
            main:      93 (10) = 01011101 (2)
            secondary: 26 (10) = 00011010 (2)
            result:              01000111 (2) = 71 (10)
        */

        return main ^ secondary;
    }

    function not(int8 main) public pure returns (int) {
        /*
            Performs bitwise negation.

            May cause overflow for signed int types.

            Example:
            main: 93 (10) = 01011101 (2)
            ~main:          10100010 (2) = 162 (10)
        */

        return ~main;
    }
}

contract Examples {
    function isEven(uint number) public pure returns (bool) {
        /*
            (number & 1) will always return last bit of `number` so we may kind of cast
            bool type to (number & 1) and know if `number` even or odd.

        */

        return number & 1 == 0;
    }

    function isEven(int number) public pure returns (bool) {
        /*
            If `number` is negative, then casting bool type to its last bit will
            result in opposite of its divisability by 2 considering signed 2`s complement
            rules.
        */

        if (number < 0) return number & 1 != 0;
        return number & 1 == 0;
    }

    function multiply(int number, uint k) external pure returns (int) {
        /*
            Left shift of `number` by `k` slots (number << k) is equivalent to (number * 2 ** k)
        */

        return number << k;
    }

    function divide(int number, uint k) external pure returns (int) {
        /*
            Right shift of `number` by `k` slots (number >> k) is equivalent to floor(number / 2**k)
        */

        return number >> k;
    }
}

/*
    Simple contract example for bitwise logics in storing state variables and using them for computations.
*/

contract Subsidizer {
    mapping(string => uint) params; // table of all roles
    mapping(address => uint) recipients; // roles of applicants
    address immutable CEO; // owner
    uint constant sum = 0.1 ether; // sum of subsidy

    constructor() {
        // masks:
        params["male"] = 1 << 0; // 0000000001 (2)
        params["female"] = 1 << 1; // 0000000010 (2)
        params["single"] = 1 << 2; // 0000000100 (2)
        params["married"] = 1 << 3; // 0000001000 (2)
        params["chlid-free"] = 1 << 4; // 0000010000 (2)
        params["1 kid"] = 1 << 5; // 0000100000 (2)
        params["2 kids"] = 1 << 6; // 0001000000 (2)
        params["employed"] = 1 << 7; // 0010000000 (2)
        params["freelance"] = 1 << 8; // 0100000000 (2)
        params["toRecieve"] = 1 << 9; // 1000000000 (2)

        CEO = msg.sender;
    }

    function assignParams(
        address applicant,
        string[] memory qualities
    ) external {
        require(msg.sender == CEO, "you dont have permission!");

        for (uint i; i < 0; i++) {
            recipients[applicant] ^= params[qualities[i]];
        }
    }

    function getFunds() external {
        uint requirement = params["female"] |
            params["married"] |
            params["2 kids"] |
            params["toRecieve"];
        require(recipients[msg.sender] & ~(requirement) == 0, "access denied");
        recipients[msg.sender] -= 2 ** 9;
        payable(msg.sender).transfer(sum);
    }
}
