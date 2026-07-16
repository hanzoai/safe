// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "forge-std/Test.sol";

import {
    Safe,
    SafeFactory,
    SafeMLDSASigner,
    SafeCoronaSigner,
    SafePulsarSigner,
    SafeMagnetarSigner,
    ModuleGovernorV1,
    ModuleFractalV1,
    SystemDeployerV1
} from "../contracts/HanzoSafe.sol";

/// @title HanzoSafeTest
/// @notice Smoke-test that the Hanzo white-label wrapper resolves to the audited
///         Lux contracts without holding any local contract code. Same
///         deployment topology as Lux DAO, branded by config/hanzo.json.
contract HanzoSafeTest is Test {
    function testSafeSingletonDeploys() public {
        Safe s = new Safe();
        assertTrue(address(s) != address(0));
    }

    function testSafeFactoryDeploys() public {
        SafeFactory f = new SafeFactory();
        assertEq(f.factoryVersion(), "1.0.0");
    }

    function testQuasarSignerTriadDeploys() public {
        bytes memory coronaPk = new bytes(1500);
        for (uint256 i = 0; i < 1500; i++) coronaPk[i] = bytes1(uint8((i * 7 + 1) & 0xFF));
        SafeCoronaSigner corona = new SafeCoronaSigner(3, 5, coronaPk);
        assertEq(corona.threshold(), 3);

        bytes memory pulsarPk = new bytes(1952);
        for (uint256 i = 0; i < 1952; i++) pulsarPk[i] = bytes1(uint8((i * 11 + 3) & 0xFF));
        SafePulsarSigner pulsar = new SafePulsarSigner(3, 5, pulsarPk);
        assertTrue(pulsar.isQuantumResistant());

        bytes memory magnetarPk = new bytes(32);
        for (uint256 i = 0; i < 32; i++) magnetarPk[i] = bytes1(uint8((i * 13 + 5) & 0xFF));
        SafeMagnetarSigner magnetar = new SafeMagnetarSigner(false, 3, 5, magnetarPk);
        assertFalse(magnetar.enabled());
        assertTrue(magnetar.isOptional());

        SafeMLDSASigner mldsa = new SafeMLDSASigner(pulsarPk);
        assertTrue(mldsa.signer() != address(0));
    }

    function testDAOSingletonsDeploy() public {
        ModuleGovernorV1 governor = new ModuleGovernorV1();
        ModuleFractalV1 fractal = new ModuleFractalV1();
        SystemDeployerV1 deployer = new SystemDeployerV1();

        assertTrue(address(governor) != address(0));
        assertTrue(address(fractal) != address(0));
        assertTrue(address(deployer) != address(0));
    }
}
