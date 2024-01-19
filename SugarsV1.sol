//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/access/Ownable.sol";

contract SugarsV1 is Ownable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;

    event Trade(
        address trader,
        address subject,
        bool isBuy,
        uint256 keyAmount,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 subjectEthAmount,
        uint256 supply
    );

    mapping(address => mapping(address => uint256)) public keysBalance;

    mapping(address => uint256) public keysSupply;

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function getPrice(
        uint256 supply,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 sum1 = supply == 0
            ? 0
            : ((supply - 1) * (supply) * (2 * (supply - 1) + 1)) / 6;
        uint256 sum2 = supply == 0 && amount == 1
            ? 0
            : ((supply - 1 + amount) *
                (supply + amount) *
                (2 * (supply - 1 + amount) + 1)) / 6;
        uint256 summation = sum2 - sum1;
        return (summation * 1 ether) / 16;
    }

    function getBuyPrice(
        address keysSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(keysSupply[keysSubject], amount);
    }

    function getSellPrice(
        address keysSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(keysSupply[keysSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(
        address keysSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getBuyPrice(keysSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price + protocolFee + subjectFee;
    }

    function getSellPriceAfterFee(
        address keysSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getSellPrice(keysSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price - protocolFee - subjectFee;
    }

    function buyKeys(address keysSubject, uint256 amount) public payable {
        uint256 supply = keysSupply[keysSubject];
        require(
            supply > 0 || keysSubject == msg.sender,
            "Only the creator of the key can buy the first key"
        );
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            msg.value >= price + protocolFee + subjectFee,
            "Insufficient payment"
        );
        keysBalance[keysSubject][msg.sender] =
            keysBalance[keysSubject][msg.sender] +
            amount;
        keysSupply[keysSubject] = supply + amount;
        emit Trade(
            msg.sender,
            keysSubject,
            true,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply + amount
        );
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = keysSubject.call{value: subjectFee}("");
        require(success1 && success2, "Unable to send funds");
    }

    function sellKeys(
        address keysSubject,
        uint256 amount
    ) public payable {
        uint256 supply = keysSupply[keysSubject];
        require(supply > amount, "Cannot sell the last key");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            keysBalance[keysSubject][msg.sender] >= amount,
            "Insufficient Keys"
        );
        keysBalance[keysSubject][msg.sender] =
            keysBalance[keysSubject][msg.sender] -
            amount;
        keysSupply[keysSubject] = supply - amount;
        emit Trade(
            msg.sender,
            keysSubject,
            false,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply - amount
        );
        (bool success1, ) = msg.sender.call{
            value: price - protocolFee - subjectFee
        }("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = keysSubject.call{value: subjectFee}("");
        require(success1 && success2 && success3, "Unable to send funds");
    }
}