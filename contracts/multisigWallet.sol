// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract MultisigWallet {

    address[] approvers;
    uint minApprovals;
    Transfer[] transfers;
    
    constructor(address[] memory _approvers, uint _minApprovals) payable {
        approvers = _approvers;
        minApprovals = _minApprovals;
    }

    // Creamos las funciones para leer los datos del SC.
    function getApprovers() external view onlyApprover() returns(address[] memory) {
        return approvers;
    }

    function getMinApprovals() external view onlyApprover() returns(uint)  {
        return minApprovals;
    }

    // Implementar la funcionalidad de las transferencias.

    struct Transfer {
        uint id;
        uint amount; // wei
        address payable to;
        uint approvals;
        bool sent;
    }

    // Creamos la función para crear el transfer

    function createTransfer(uint _amount, address payable to) external onlyApprover() {
        transfers.push(Transfer(
            transfers.length,
            _amount,
            to,
            0,
            false
        ));
    }

    function getTransfers() external view onlyApprover() returns(Transfer[] memory)  {
        return transfers;
    }


    // Vamos a gestionar los approvals

    mapping(address => mapping(uint => bool)) approvals;


    // Creamos la función para aprobar una transferencia

    function approveTransfer(uint transferId) external onlyApprover() {
        require(approvals[msg.sender][transferId] == false, "No se puede aprobar 2 veces la misma transaccion");
        require(transfers[transferId].sent == false, "Transaccion ya realizada.");

        approvals[msg.sender][transferId] = true; 
        transfers[transferId].approvals++;

        if(transfers[transferId].approvals >= minApprovals){
            transfers[transferId].sent = true;
            address payable to = transfers[transferId].to;
            to.transfer(transfers[transferId].amount);
        }
    }


    // Creamos un modificador para gestionar el acceso a las funcionalidades del SC

    modifier onlyApprover() {
        bool allowed = false;
        for(uint i=0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
                break;
            }
        }
        require(allowed == true, "Solamente las addresses admin pueden interactuar.");
        _;
    }
}
