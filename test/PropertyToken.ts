import hre from 'hardhat';
import { expect } from 'chai';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';

describe('PropertyToken', () => {

    const deployFreshContract = async () => {

        const [owner, user1, user2] = await hre.ethers.getSigners();

        const premint = 2000;

        const Token = await hre.ethers.getContractFactory('PropertyToken');
        const TokenContract = await Token.deploy('name', 'symbol', premint);

        const tokenAddress = TokenContract.target;

        return { TokenContract, tokenAddress, owner, user1, user2, premint };
    }

    it('Ensure that the token contract address holds the full token balance, while the owner\'s balance is zero', async () => {
        const { TokenContract, tokenAddress, owner, premint } = await loadFixture(deployFreshContract);

        expect(await TokenContract.balanceOf(tokenAddress)).to.equal(premint);
        expect(await TokenContract.balanceOf(owner.address)).to.equal(0);
    });

    it('Ensure that the `userBuysTokens` function works correctly', async () => {
        const { TokenContract, tokenAddress, user1, premint } = await loadFixture(deployFreshContract);

        const amount = 100;
        await TokenContract.userBuysTokens(user1.address, amount);

        expect(await TokenContract.balanceOf(tokenAddress)).to.equal(premint - amount);
        expect(await TokenContract.balanceOf(user1.address)).to.equal(amount);

        await expect(TokenContract.userBuysTokens(user1.address, premint))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientTokenSupply');
    });
});