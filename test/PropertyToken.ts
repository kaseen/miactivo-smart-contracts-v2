import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { expect } from 'chai';
import hre from 'hardhat';

describe('PropertyToken', () => {

    const deployFreshContract = async () => {

        const [owner, user] = await hre.ethers.getSigners();
        const premint = 2000;

        const Token = await hre.ethers.getContractFactory('PropertyToken');
        const TokenContract = await Token.deploy('name', 'symbol', premint);
        const tokenAddress = TokenContract.target;

        return { TokenContract, tokenAddress, owner, user, premint };
    }

    it('Ensure that the token contract address holds the full token balance, while the owner\'s balance is zero', async () => {
        const { TokenContract, tokenAddress, owner, premint } = await loadFixture(deployFreshContract);

        expect(await TokenContract.totalSupply()).to.equal(premint);
        expect(await TokenContract.balanceOf(tokenAddress)).to.equal(premint);
        expect(await TokenContract.balanceOf(owner.address)).to.equal(0);
    });

    it('Ensure that the increase and decrease token circulation functions work correctly', async () => {
        const { TokenContract, premint } = await loadFixture(deployFreshContract);

        const amount = 2500;
        await expect(TokenContract.increaseTokenCirculation(amount))
            .to.emit(TokenContract, 'TokenTotalAmountIncreased')
            .withArgs(amount);

        expect(await TokenContract.totalSupply()).to.equal(premint + amount);

        await expect(TokenContract.decreaseTokenCirculation(amount))
            .to.emit(TokenContract, 'TokenTotalAmountDecreased')
            .withArgs(amount);

        expect(await TokenContract.totalSupply()).to.equal(premint);

        await expect(TokenContract.decreaseTokenCirculation(amount))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientTokenSupply');
    });

    it('Ensure that the `BuysTokens` function works correctly', async () => {
        const { TokenContract, tokenAddress, user, premint } = await loadFixture(deployFreshContract);

        const amount = 100;
        await expect(TokenContract.userBuysTokens(user.address, amount))
            .to.emit(TokenContract, 'UserBoughtTokens')
            .withArgs(user.address, amount);

        expect(await TokenContract.balanceOf(tokenAddress)).to.equal(premint - amount);
        expect(await TokenContract.balanceOf(user.address)).to.equal(amount);

        await expect(TokenContract.userBuysTokens(user.address, premint))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientTokenSupply');
    });

    it('Ensure that the `userDepositsTokens` function works correctly', async () => {
        const { TokenContract, user } = await loadFixture(deployFreshContract);

        const amountToBuy = 100;
        const amountToDeposit = 70;

        await expect(TokenContract.userDepositsTokens(user.address, amountToDeposit))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientUserBalance');

        await TokenContract.userBuysTokens(user.address, amountToBuy);

        await expect(TokenContract.userDepositsTokens(user.address, amountToDeposit))
            .to.emit(TokenContract, 'UserDepositedTokens')
            .withArgs(user.address, amountToDeposit);

        await expect(TokenContract.userDepositsTokens(user.address, amountToDeposit))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientUserBalance');
    });

    it('Ensure that the `userRefundsTokens` function works correctly', async () => {
        const { TokenContract, user } = await loadFixture(deployFreshContract);

        const amountToBuy = 100;
        const amountToDepositAndWithdraw = 70;

        await expect(TokenContract.userRefundsTokens(user.address, amountToDepositAndWithdraw))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientUserBalance');

        await TokenContract.userBuysTokens(user.address, amountToBuy);

        await expect(TokenContract.userRefundsTokens(user.address, amountToDepositAndWithdraw))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientUserBalance');

        await TokenContract.userDepositsTokens(user.address, amountToDepositAndWithdraw);

        await expect(TokenContract.userRefundsTokens(user.address, amountToDepositAndWithdraw))
            .to.emit(TokenContract, 'UserWithdrewTokens')
            .withArgs(user.address, amountToDepositAndWithdraw);
        
        await expect(TokenContract.userRefundsTokens(user.address, amountToDepositAndWithdraw))
            .to.be.revertedWithCustomError(TokenContract, 'InsufficientUserBalance');
    });
});