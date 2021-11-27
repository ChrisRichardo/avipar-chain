/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

type CounterNo struct {
	Counter int `json:"counter"`
}

// Car describes basic details of what makes up a car
type Asset struct {
	ID             	 string `json:"ID"`
	SparepartNumber  string `json:"SparepartNumber"`
	SparepartName 	 string `json:"SparepartName"`
	PIC          	 string `json:"PIC"`
	From          	 string `json:"From"`
	To          	 string `json:"To"`
}

type User struct {
	Name      string `json:"Name"`
	User_ID   string `json:"UserID"`
	Email     string `json:"Email"`
	User_Type string `json:"UserType"`
	Address   string `json:"Address"`
	Password  string `json:"Password"`
}

// QueryResult structure used for handling result of query
type QueryResult struct {
	Key    string `json:"Key"`
	Record *Asset
}

type QueryResult2 struct {
	Key    string `json:"Key"`
	Record *CounterNo
}

//getCounter to the latest value of the counter based on the Asset Type provided as input parameter
func getCounter(ctx contractapi.TransactionContextInterface, AssetType string) int {
	counterAsBytes, _ := ctx.GetStub().GetState(AssetType)
	counterAsset := CounterNo{}

	json.Unmarshal(counterAsBytes, &counterAsset)
	fmt.Sprintf("Counter Current Value %d of Asset Type %s", counterAsset.Counter, AssetType)

	return counterAsset.Counter
}

//incrementCounter to the increase value of the counter based on the Asset Type provided as input parameter by 1
func incrementCounter(ctx contractapi.TransactionContextInterface, AssetType string) int {
	counterAsBytes, _ := ctx.GetStub().GetState("CarCounterNo")
	counterAsset := CounterNo{}

	json.Unmarshal(counterAsBytes, &counterAsset)
	counterAsset.Counter++
	counterAsBytes, _ = json.Marshal(counterAsset)

	err := ctx.GetStub().PutState("CarCounterNo", counterAsBytes)
	if err != nil {

		fmt.Sprintf("Failed to Increment Counter")

	}

	fmt.Println("Success in incrementing counter  %v", counterAsset)

	return counterAsset.Counter
}

func (s *SmartContract) InitCounters(ctx contractapi.TransactionContextInterface) error {

	// Initializing Car Counter
	var CarCounter = CounterNo{
		Counter: 3,
	}
	CarCounterBytes, _ := json.Marshal(CarCounter)
	ctx.GetStub().PutState("CarCounterNo", CarCounterBytes)

	return nil
}

func (s *SmartContract) InitCars(ctx contractapi.TransactionContextInterface) error {

	cars := []Asset{
		{ID: "po1", SparepartNumber: "888-1234-123", SparepartName: "Brake", PIC: "Nadeem Abdur Rasheed", From: "A", To: "B"},
		{ID: "po2", SparepartNumber: "888-1234-123", SparepartName: "Brake", PIC: "Christopher Richardo", From: "B", To: "C"},
		{ID: "po3", SparepartNumber: "777-1234-111", SparepartName: "Front Wheel", PIC: "TB. Naufal Arya Maulana", From: "C", To: "B"},
	}

	for i, car := range cars {
		fmt.Println("i is ", i)
		carAsBytes, _ := json.Marshal(car)
		ctx.GetStub().PutState("ASSET" + strconv.Itoa(i+1), carAsBytes)
		fmt.Println("Added", car)
		i = i + 1
	}

	return nil
}


// InitLedger adds a base set of cars to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// Initializing Car Counter
	s.InitCounters(ctx)
	s.InitCars(ctx)
	
	return nil
}

// CreateCar adds a new car to the world state with given details
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, carNumber string, make string, model string, colour string, ownerID string) error {
	fmt.Printf("Test Create Car")
	// carCounter := getCounter(ctx, "CarCounterNo")
	// carCounter++

	id,_ := s.IncrementCarCounter(ctx)

	car := Asset{
		ID: "CARA" +  strconv.Itoa(id),
		SparepartNumber:   make,
		SparepartName:  model,
		PIC: colour,
		From: ownerID,
		To: make,
	}

	carAsBytes, _ := json.Marshal(car)

	return ctx.GetStub().PutState(carNumber, carAsBytes)
}

// QueryCar returns the car stored in the world state with given id
func (s *SmartContract) QueryCar(ctx contractapi.TransactionContextInterface, carNumber string) (*Asset, error) {
	carAsBytes, err := ctx.GetStub().GetState(carNumber)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if carAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", carNumber)
	}

	car := new(Asset)
	_ = json.Unmarshal(carAsBytes, car)

	return car, nil
}

// QueryAllCars returns all cars found in world state
func (s *SmartContract) QueryAllCars(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := "ASSET0"
	endKey := "ASSET8"

	carCounter := getCounter(ctx, "CarCounterNo")
	carCounter++

	incrementCounter(ctx, "CarCounterNo")

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		car := new(Asset)
		_ = json.Unmarshal(queryResponse.Value, car)

		queryResult := QueryResult{Key: queryResponse.Key, Record: car}
		results = append(results, queryResult)
	}

	counterAsBytes, err := ctx.GetStub().GetState("CarCounterNo")
	if err != nil {
		return nil, err
	}

	counter := new(CounterNo)
	_ = json.Unmarshal(counterAsBytes, counter)

	fmt.Printf("Car Counter No is : $d", counter.Counter)

	return results, nil
}


// QueryAllCars returns all cars found in world state
func (s *SmartContract) QueryAllCounters(ctx contractapi.TransactionContextInterface) ([]QueryResult2, error) {
	results := []QueryResult2{}

	counterAsBytes, err := ctx.GetStub().GetState("CarCounterNo")
	if err != nil {
		return nil, err
	}

	counter := new(CounterNo)
	_ = json.Unmarshal(counterAsBytes, counter)
	
	queryResult := QueryResult2{Key: "CarCounterNo", Record: counter}
	results = append(results, queryResult)

	return results, nil
}

// ChangeCarOwner updates the owner field of car with given id in world state
func (s *SmartContract) ChangeCarOwner(ctx contractapi.TransactionContextInterface, carNumber string, newOwner string) error {
	car, err := s.QueryCar(ctx, carNumber)

	if err != nil {
		return err
	}

	car.PIC = newOwner

	carAsBytes, _ := json.Marshal(car)

	return ctx.GetStub().PutState(carNumber, carAsBytes)
}

func (s *SmartContract) IncrementCarCounter(ctx contractapi.TransactionContextInterface) (int,error) {
	counterAsBytes, _ := ctx.GetStub().GetState("CarCounterNo")
	counterAsset := CounterNo{}

	json.Unmarshal(counterAsBytes, &counterAsset)
	counterAsset.Counter++
	counterAsBytes, _ = json.Marshal(counterAsset)

	err := ctx.GetStub().PutState("CarCounterNo", counterAsBytes)
	if err != nil {

		fmt.Sprintf("Failed to Increment Counter")

	}

	fmt.Println("Success in incrementing counter  %v", counterAsset)

	return counterAsset.Counter, nil
}


func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting fabcar chaincode: %s", err.Error())
	}
}