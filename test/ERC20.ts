import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ERC20 } from "../typechain-types";
import { Signer } from "ethers";

describe("MyERC20Contract", function () {
  let myERC20Contract: ERC20;
  let someAddress: Signer;
  let someOtherAddress: Signer;

  beforeEach(async function () {
    const ERC20ContractFactory = await hre.ethers.getContractFactory("ERC20");
    myERC20Contract = await ERC20ContractFactory.deploy("MyERC20", "MET");
    await myERC20Contract.waitForDeployment();

    const signers = await hre.ethers.getSigners();
    someAddress = signers[1];
    someOtherAddress = signers[2];
  });

  describe("when i have 10 tokens", function () {
    beforeEach(async function () {
      await myERC20Contract.transfer(someAddress.getAddress(), 10);
    });

    describe("when i transfer 10 tokens", function () {
      it("should transfer tokens correctly", async function () {
        await myERC20Contract.connect(someAddress).transfer(someOtherAddress.getAddress(), 10);
        expect(await myERC20Contract.balanceOf(someOtherAddress.getAddress())).to.equal(10);
      });
    });

    describe("when i transfer 15 tokens", function () {
      it("should revert the transaction", async function () {
        await expect(
          myERC20Contract.connect(someAddress).transfer(someOtherAddress.getAddress(), 15),
        ).to.be.rejectedWith("ERC20: transfer amount exceeds balance");
      });
    });

    describe("when i deposit 10 tokens", function () {
      it("should deposit 10 tokens", async function () {
        await myERC20Contract.connect(someAddress).deposit({ value: 10 });
        expect(await myERC20Contract.balanceOf(someAddress.getAddress())).to.equal(20);
      });
    });

    describe("when i radeem 10 tokens", function () {
      it("should radeem 10 tokens", async function () {
        await myERC20Contract.connect(someAddress).deposit({ value: 10 });
        await myERC20Contract.connect(someAddress).approve(myERC20Contract.getAddress(), 10);
        await myERC20Contract.connect(someAddress).redeem(10);
        expect(await myERC20Contract.balanceOf(someAddress.getAddress())).to.equal(10);
      });
    });
  });
});
