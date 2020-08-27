﻿namespace Tests {
    
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Logical;
    open Qram;    

    // Basic lookup with all addresses checked for single-bit data
    @Test("QuantumSimulator")
    operation QROMOracleSingleBitSingleLookupMatchResults() : Unit {
        let numAddressBits = 3;
        for (add in 1..numAddressBits){
            let data = RandomFullMemory(add, 1);
            for (i in 0..2^numAddressBits-1) {
                CreateQueryMeasureOneAddressQROM(data, i);
            }
        }

    }

    // Basic lookup with all addresses checked for multi-bit data
    @Test("QuantumSimulator")
    operation QROMOracleMultiBitSingleLookupMatchResults() : Unit {
        let numAddressBits = 3;
        let numDataBits = 3;
        for (add in 1..numAddressBits){
            for (bits in 1..numDataBits){
                let data = RandomFullMemory(add, 1);
                for (i in 0..2^numAddressBits-1) {
                    CreateQueryMeasureOneAddressQROM(data, i);
                }
            }
        }
    }

    internal operation CreateQueryMeasureOneAddressQROM(
        data : MemoryBank, 
        queryAddress : Int
    ) 
    : Unit {
        // Get the data value you expect to find at queryAddress
        let expectedValue = DataAtAddress(data, queryAddress);
        // Setup the var to hold the result of the measurement
        mutable result = new Bool[0];

        // Create the new Qrom oracle
        let memory = QromOracle(data::DataSet);

        using((addressRegister, targetRegister) = 
            (Qubit[memory::AddressSize], Qubit[memory::DataSize])
        ){
            // Convert the address Int to a Bool[]
            let queryAddressAsBool = IntAsBoolArray(queryAddress, BitSizeI(queryAddress));
            // Prepare the address register 
            ApplyPauliFromBitString (PauliX, true, queryAddressAsBool, addressRegister);
            // Perform the lookup
            memory::Read(LittleEndian(addressRegister), targetRegister);
            // Get results and make sure its the same format as the data provided i.e. Bool[].
            set result = ResultArrayAsBoolArray(MultiM(targetRegister));
            // Reset all the qubits before returning them
            ResetAll(addressRegister+targetRegister);
        }
        AllEqualityFactB(result, expectedValue, 
            $"Expecting value {expectedValue} at address {queryAddress}, got {result}."); 
    }

}