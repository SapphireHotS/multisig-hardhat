const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MultisigWallet", function () {
  let signers = [];
  let multisigContract;

  beforeEach(async function() {
    signers = await ethers.getSigners();
    const Multisig = await ethers.getContractFactory('MultisigWallet', {signer: signers[0]});
    const multisig = await Multisig.deploy([signers[0].address, signers[1].address, signers[2].address], 2);
    multisigContract = await multisig.deployed();
  });

  it("Debería de tener un mínimo de 2 aprobaciones", async function() {
    const minApprovers = await multisigContract.getMinApprovals();
    console.log('Lectura minApprovers: ', minApprovers);
    expect(minApprovers).to.equal(2);
  });

  it("Debería de tener 3 approvers", async function() {
    const approvers = await multisigContract.getApprovers();
    console.log(approvers);

    expect(approvers[0]).to.equal(signers[0].address);
    expect(approvers[1]).to.equal(signers[1].address);
    expect(approvers[2]).to.equal(signers[2].address);
    expect(approvers).to.have.lengthOf(3);
  });
});
