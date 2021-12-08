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
	Status			 string `json:"Status"`
}

type User struct {
	Name      string `json:"Name"`
	User_ID   string `json:"UserID"`
	Email     string `json:"Email"`
	Org       string `json:"Org"`
	Role       string `json:"Role"`
	Address   string `json:"Address"`
	Password  string `json:"Password"`
}

// QueryResult structure used for handling result of query
type QueryResultAsset struct {
	Key    string `json:"Key"`
	Record *Asset
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultAssets struct {
	Key    string `json:"Key"`
	Record []Asset
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResult2 struct {
	Key    string `json:"Key"`
	Record *CounterNo
}

type QueryResultUser struct {
	Key    string `json:"Key"`
	Record *User
}

type QueryResultSignIn struct {
	Key    string `json:"Key"`
	Record *User
	Status bool `json:"Status"`
}

type QueryResultStatusMessage struct {
	Key    string `json:"Key"`
	Message string `json:"Message"`
	Status bool `json:"Status"`
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
	counterAsBytes, _ := ctx.GetStub().GetState(AssetType)
	counterAsset := CounterNo{}

	json.Unmarshal(counterAsBytes, &counterAsset)
	counterAsset.Counter++
	counterAsBytes, _ = json.Marshal(counterAsset)

	err := ctx.GetStub().PutState(AssetType, counterAsBytes)
	if err != nil {

		fmt.Sprintf("Failed to Increment Counter")

	}

	fmt.Println("Success in incrementing counter  %v", counterAsset)

	return counterAsset.Counter
}

func checkStatus(status string) bool {
	statuses := []string{"Available", "Not Available", "In Use", "Repairing", "Completed"}
	for _, b := range statuses {
        if b == status {
            return true
        }
    }
	return false
}

func (s *SmartContract) InitCounters(ctx contractapi.TransactionContextInterface) error {

	// Initializing Car Counter
	var CarCounter = CounterNo{
		Counter: 0,
	}
	CarCounterBytes, _ := json.Marshal(CarCounter)
	ctx.GetStub().PutState("AssetCounterNo", CarCounterBytes)

	var UserCounter = CounterNo{Counter: 0}
	UserCounterBytes, _ := json.Marshal(UserCounter)
	ctx.GetStub().PutState("UserCounterNo", UserCounterBytes)
		

	return nil
}

func (s *SmartContract) InitCars(ctx contractapi.TransactionContextInterface) error {

	cars := []Asset{
		{ID: "po1", SparepartNumber: "888-1234-123", SparepartName: "Brake", PIC: "Nadeem Abdur Rasheed"},
		{ID: "po2", SparepartNumber: "888-1234-123", SparepartName: "Brake", PIC: "Christopher Richardo"},
		{ID: "po3", SparepartNumber: "777-1234-111", SparepartName: "Front Wheel", PIC: "TB. Naufal Arya Maulana"},
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
	
	return nil
}

// CreateAsset adds a new car to the world state with given details
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, number string, name string, owner string) (bool, error) {
	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, owner)
	if len(entitiesUserEmail) ==  0{
		return false, nil
	}
	
	userOrg := entitiesUserEmail[0].Record.Org
	if userOrg != "manufacturer"{
		return false, nil
	}

	assetCounter := getCounter(ctx, "AssetCounterNo")
	assetCounter++
	
	indexName := "owner~assetid"

	asset := Asset{
		ID: "Asset" +  strconv.Itoa(assetCounter),
		SparepartNumber:   number,
		SparepartName:  name,
		PIC: owner,
		Status: "Available",
	}
	assetAsBytes, _ := json.Marshal(asset)
	assetCheck := []string {};
	if len(assetCheck) > 0 {
		fmt.Printf("Failed to Increment Counter")

		return false, nil;
	} else {
		errPut := ctx.GetStub().PutState("ASSET" + strconv.Itoa(assetCounter), assetAsBytes)
		if errPut != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create asset: %s", asset.SparepartNumber))
		}

		indexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.PIC, "ASSET" + strconv.Itoa(assetCounter)})
		if err != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create asset composite key: %s", asset.SparepartNumber))
		}
		value := []byte{0x00}
		ctx.GetStub().PutState(indexKey, value)

		incrementCounter(ctx, "AssetCounterNo")
		
		return true, errPut;
	}
}

func (s *SmartContract) QueryAsset(ctx contractapi.TransactionContextInterface, assetId string) (*QueryResultAsset, error) {
	result := QueryResultAsset{}
	result.Key = assetId
	result.Status = false

	assetAsBytes, err := ctx.GetStub().GetState(assetId)
	if err != nil || assetAsBytes == nil {
		result.Message = "Asset " + assetId + " not existed"
		return &result, nil
	}

	asset := new(Asset)
	_ = json.Unmarshal(assetAsBytes, asset)

	result.Record = asset
	result.Status = true
	result.Message = "Asset " + assetId + " retrieved"
	return &result, nil
}

func (s *SmartContract) QueryAllAssets(ctx contractapi.TransactionContextInterface) ([]QueryResultAsset, error) {
	assetCounter := getCounter(ctx, "AssetCounterNo")
	assetCounter++

	startKey := "ASSET0"
	endKey := "ASSET" + strconv.Itoa(assetCounter)

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResultAsset{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		asset := new(Asset)
		_ = json.Unmarshal(queryResponse.Value, asset)

		queryResult := QueryResultAsset{Key: queryResponse.Key, Record: asset}
		results = append(results, queryResult)
	}

	return results, nil
}

func (s *SmartContract) QueryAssetByOwner(ctx contractapi.TransactionContextInterface, owner string) ([]QueryResultAsset, error) {
	indexName := "owner~assetid"

	resultsIterator, err := ctx.GetStub().GetStateByPartialCompositeKey(indexName, []string{owner})
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResultAsset{}

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()

		_, compositeKeyParts, err := ctx.GetStub().SplitCompositeKey(queryResponse.Key)
		if err != nil {
			return nil, fmt.Errorf("Split composite key error")
		}

		returnedAssetId := compositeKeyParts[1]

		userAsBytes, _ := ctx.GetStub().GetState(returnedAssetId)

		asset := new(Asset)
		_ = json.Unmarshal(userAsBytes, asset)

		queryResult := QueryResultAsset{Key: returnedAssetId, Record: asset}
		results = append(results, queryResult)
	}
	return results, nil
}

func (s *SmartContract) QueryAssetHistory(ctx contractapi.TransactionContextInterface, assetId string) (QueryResultAssets, error) {
	result := QueryResultAssets{}
	result.Key = assetId
	result.Status = false

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(assetId)
	if err != nil {
		result.Message = "Can't get history for " + assetId
		return result, nil
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse,_ := resultsIterator.Next()

		asset := new(Asset)
		_ = json.Unmarshal(queryResponse.Value, asset)

		result.Record = append(result.Record, *asset)
	}

	result.Status = true
	result.Message = "History for " + assetId + " retrieved"
	return result, nil
}

func (s *SmartContract) QueryAllUsers(ctx contractapi.TransactionContextInterface) ([]QueryResultUser, error) {
	userCounter := getCounter(ctx, "UserCounterNo")
	userCounter++

	startKey := "USER0"
	endKey := "USER" + strconv.Itoa(userCounter)

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResultUser{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		user := new(User)
		_ = json.Unmarshal(queryResponse.Value, user)

		queryResult := QueryResultUser{Key: queryResponse.Key, Record: user}
		results = append(results, queryResult)
	}

	return results, nil
}

func (s *SmartContract) QueryUserByEmail(ctx contractapi.TransactionContextInterface, email string) ([]QueryResultUser, error) {
	indexName := "email~userid"

	resultsIterator, err := ctx.GetStub().GetStateByPartialCompositeKey(indexName, []string{email})
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResultUser{}

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()

		_, compositeKeyParts, err := ctx.GetStub().SplitCompositeKey(queryResponse.Key)
		if err != nil {
			return nil, fmt.Errorf("Split composite key error")
		}

		returnedUserId := compositeKeyParts[1]

		userAsBytes, _ := ctx.GetStub().GetState(returnedUserId)

		user := new(User)
		_ = json.Unmarshal(userAsBytes, user)

		queryResult := QueryResultUser{Key: returnedUserId, Record: user}
		results = append(results, queryResult)
	}
	return results, nil
}

func (s *SmartContract) SignIn(ctx contractapi.TransactionContextInterface, email string, password string) (*QueryResultSignIn, error) {
	result := QueryResultSignIn{}
	result.Status = false

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, email)
	if len(entitiesUserEmail) ==  0{
		return &result, nil
	}

	result.Record = entitiesUserEmail[0].Record
	result.Key = entitiesUserEmail[0].Key

	// check if password matched
	if result.Record.Password != password {
		return &result,nil
	}
	result.Status = true

	return &result, nil
}

func (s *SmartContract) TransferAssetOwner(ctx contractapi.TransactionContextInterface, assetId string, newOwner string) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	queryAsset, _ := s.QueryAsset(ctx, assetId)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.PIC)
	userOrg := entitiesUserEmail[0].Record.Org

	entitiesNewUserEmail, _ := s.QueryUserByEmail(ctx, newOwner)
	if len(entitiesNewUserEmail) ==  0{
		result.Message = "New Owner not existed"
		return &result, nil
	}

	newUserOrg := entitiesNewUserEmail[0].Record.Org
	
	if userOrg == "manufacturer" && newUserOrg != "vendor"{
		result.Message = "Only Vendor able to buy from Manufacturer"
		return &result, nil
	} else if userOrg == "vendor" && newUserOrg != "mro"{
		result.Message = "Only MRO able to buy from Vendor"
		return &result, nil

	} else if userOrg == "mro" && newUserOrg != "airline"{
		result.Message = "Only Airline able to buy from MRO"
		return &result, nil
		
	} else if userOrg == "airline"{
		result.Message = "You are not able to buy spare parts from Airline"
		return &result, nil
	}

	indexName := "owner~assetid"

	ownerAssetidIndexKey, _ := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.PIC, assetId})
	err := ctx.GetStub().DelState(ownerAssetidIndexKey)
	if err != nil {
		result.Message = "Failed to delete composite key " + ownerAssetidIndexKey
		return &result, nil
	}

	asset.PIC = newOwner
	assetAsBytes, _ := json.Marshal(asset)
	ctx.GetStub().PutState(assetId, assetAsBytes)

	newOwnerAssetidIndexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.PIC, assetId})
	if err != nil {
		result.Message = "Failed to create new composite key " + newOwnerAssetidIndexKey
		return &result, nil
	}
	value := []byte{0x00}
	ctx.GetStub().PutState(newOwnerAssetidIndexKey, value)

	result.Message = "Spare part transfered to " + newOwner
	result.Status = true
	return &result, nil
}

func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, assetId string, name string, number string, status string, updateBy string) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	statusCheck := checkStatus(status)
	if !statusCheck {
		result.Message = "Status " + status + " not valid"
		return &result, nil
	}

	queryAsset, _ := s.QueryAsset(ctx, assetId)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.PIC)
	userOrg := entitiesUserEmail[0].Record.Org

	entitiesUpdateUserEmail, _ := s.QueryUserByEmail(ctx, updateBy)
	updateUserOrg := entitiesUpdateUserEmail[0].Record.Org
	
	if userOrg != updateUserOrg{
		result.Message = "You are not from " + userOrg + " organization"
		return &result, nil
	}

	if name != "" {
		asset.SparepartName = name
	}
	if number != "" {
		asset.SparepartNumber = number
	}
	if status != "" {
		asset.Status = status
	}

	assetAsBytes, _ := json.Marshal(asset)
	ctx.GetStub().PutState(assetId, assetAsBytes)

	result.Message = "Spare part " + assetId +  " updated" 
	result.Status = true
	return &result, nil
}


func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, name string, email string, org string, role string, address string, password string) (bool, error) {
	userCounter := getCounter(ctx, "UserCounterNo")
	userCounter++

	indexName := "email~userid"

	var comAsset = User{Name: name, User_ID: "User" + strconv.Itoa(userCounter), Email: email, Org: org, Role: role, Address: address, Password: password}
	comAssetAsBytes, _ := json.Marshal(comAsset)

	emailCheck, _ := s.QueryUserByEmail(ctx, email)
	if len(emailCheck) > 0 {
		fmt.Printf("Failed to Increment Counter")

		return false, nil;
	} else {
		errPut := ctx.GetStub().PutState("USER" + strconv.Itoa(userCounter), comAssetAsBytes)
		if errPut != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to register user: %s", comAsset.User_ID))
		}

		emailUseridIndexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{comAsset.Email, "USER" + strconv.Itoa(userCounter)})
		if err != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create user composite key: %s", comAsset.User_ID))
		}
		value := []byte{0x00}
		ctx.GetStub().PutState(emailUseridIndexKey, value)

		//TO Increment the User Counter
		incrementCounter(ctx, "UserCounterNo")
		
		return true, errPut;
	}
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