/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

type CounterNo struct {
	Counter int `json:"counter"`
}

type Asset struct {
	ID             	 string `json:"ID"`
	Number  		 string `json:"Number"`
	Name 	 		 string `json:"Name"`
	Owner          	 string `json:"Owner"`
	Status			 string `json:"Status"`
	Timestamp        string `json:"Timestamp"`
	Quantity         int    `json:"Quantity"`
	Weight           int    `json:"Weight"`
	Org       	     string `json:"Org"` 
	PurchaseOrderReference    *PurchaseOrder `json:"PurchaseOrderReference"`
	RepairOrderReference      *RepairOrder `json:"RepairOrderReference"`
	PreviousAsset    string `json:"PreviousAsset"`
}

type AssetAvailableQty struct {
	AssetID       	 string `json:"AssetID"`
	Quantity         int    `json:"Quantity"`
}

type PurchaseOrder struct{
	ID             	 string `json:"ID"`
	AssetID          string `json:"AssetID"`
	BuyerEmail	     string `json:"BuyerEmail"`
	Quantity         int    `json:"Quantity"`
	Status			 string `json:"Status"`
	BuyerOrg         string `json:"BuyerOrg"`
	SellerOrg         string `json:"SellerOrg"`
	Timestamp        string `json:"Timestamp"`
}

type RepairOrder struct{
	ID             	 string `json:"ID"`
	AssetID          string `json:"AssetID"`
	RequesterEmail	 string `json:"RequesterEmail"`
	Status			 string `json:"Status"`
	RequesterOrg     string `json:"RequesterOrg"`
	RepairerOrg      string `json:"RepairerOrg"`
	Timestamp        string `json:"Timestamp"`
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
	RecordQty *AssetAvailableQty
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultAssetHistory struct {
	Key    string `json:"Key"`
	Record []Asset
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultAssetQty struct {
	Key    string `json:"Key"`
	Record *AssetAvailableQty
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultPO struct {
	Key    string `json:"Key"`
	Record *PurchaseOrder
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultRO struct {
	Key    string `json:"Key"`
	Record *RepairOrder
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
	Message string `json:"Message"`
	Status bool `json:"Status"`
}

type QueryResultUsers struct {
	Key    string `json:"Key"`
	Record []User
	Message string `json:"Message"`
	Status bool `json:"Status"`
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
func (s *SmartContract) incrementCounter(ctx contractapi.TransactionContextInterface, AssetType string, ManualIncrement int) int {
	counterAsBytes, _ := ctx.GetStub().GetState(AssetType)
	counterAsset := CounterNo{}

	json.Unmarshal(counterAsBytes, &counterAsset)
	if ManualIncrement != -1 {
		counterAsset.Counter = ManualIncrement
	} else{
		counterAsset.Counter++
	}
	
	counterAsBytes, _ = json.Marshal(counterAsset)

	err := ctx.GetStub().PutState(AssetType, counterAsBytes)
	if err != nil {

		fmt.Sprintf("Failed to Increment Counter")

	}

	fmt.Println("Success in incrementing counter  %v", counterAsset)

	return counterAsset.Counter
}

func checkStatus(status string) bool {
	statuses := []string{"Available", "Not Available", "Requesting Repair", "Repairing"}
	for _, b := range statuses {
        if b == status {
            return true
        }
    }
	return false
}

func parseDateTime (datetime string) time.Time {
	layout := "01/02/2006 15:04:05"
	time, err := time.Parse(layout, datetime)
	if err != nil {
    	fmt.Println(err)
	}

	return time
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

	var POCounter = CounterNo{Counter: 0}
	POCounterBytes, _ := json.Marshal(POCounter)
	ctx.GetStub().PutState("POCounterNo", POCounterBytes)
		
	var ROCounter = CounterNo{Counter: 0}
	ROCounterBytes, _ := json.Marshal(ROCounter)
	ctx.GetStub().PutState("ROCounterNo", ROCounterBytes)

	return nil
}

// InitLedger adds a base set of cars to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// Initializing Car Counter
	s.InitCounters(ctx)
	
	return nil
}

func (s *SmartContract) CreatePurchaseOrder(ctx contractapi.TransactionContextInterface, assetId string, email string, quantity int, timestamp string) (bool, error) {
	status := "Waiting for Buyer Organization"

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, email)
	if !entitiesUserEmail.Status{
		return false, nil
	}

	user := entitiesUserEmail.Record
	if user.Role == "supervisor" {
		status = "Waiting for Seller Organization"
	}

	queryAsset, _ := s.QueryAsset(ctx, assetId)
	asset := queryAsset.Record

	entitiesSellerEmail, _ := s.QueryUserByEmail(ctx, asset.Owner)
	seller := entitiesSellerEmail.Record
	
	poCounter := getCounter(ctx, "POCounterNo")
	poCounter++
	
	indexName := "owner~poid"

	po := PurchaseOrder{
		ID: "PO" +  strconv.Itoa(poCounter),
		AssetID: assetId,
		BuyerEmail: email,
		Status: status,
		Quantity: quantity,
		BuyerOrg: user.Org,
		SellerOrg: seller.Org,
		Timestamp: timestamp,
	}

	poAsBytes, _ := json.Marshal(po)
	errPut := ctx.GetStub().PutState("PO" + strconv.Itoa(poCounter), poAsBytes)
	if errPut != nil {
		return false, fmt.Errorf(fmt.Sprintf("Failed to create asset: %s", po.ID))
	}

	indexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{po.BuyerEmail, "PO" + strconv.Itoa(poCounter)})
	if err != nil {
		return false, fmt.Errorf(fmt.Sprintf("Failed to create asset composite key: %s", po.ID))
	}
	value := []byte{0x00}
	ctx.GetStub().PutState(indexKey, value)

	s.UpdateAssetAvailableQty(ctx, po.AssetID, po.Quantity, -1)

	s.incrementCounter(ctx, "POCounterNo", -1)
	
	return true, errPut;
}

func (s *SmartContract) UpdatePurchaseOrderStatus(ctx contractapi.TransactionContextInterface, poId string, updateBy string, timestamp string) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	queryPO, _ := s.QueryPO(ctx, poId)
	po := queryPO.Record

	entitiesBuyerEmail, _ := s.QueryUserByEmail(ctx, po.BuyerEmail)
	buyer := entitiesBuyerEmail.Record

	entitiesUpdateUserEmail, _ := s.QueryUserByEmail(ctx, updateBy)
	updateUser := entitiesUpdateUserEmail.Record

	queryAsset, _ := s.QueryAsset(ctx, po.AssetID)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.Owner)
	user := entitiesUserEmail.Record

	if updateUser.Role != "supervisor"{
		result.Message = user.Email + " is not Supervisor"
		return &result, nil
	}

	if po.Status == "Waiting for Buyer Organization" && buyer.Org == updateUser.Org {
		po.Status = "Waiting for Seller Organization"
	} else if po.Status == "Waiting for Seller Organization" && user.Org == updateUser.Org {
		s.UpdateAsset(ctx, asset.ID, asset.Name, asset.Number, asset.Status, po.Quantity, asset.Weight, timestamp, updateBy, buyer.Email, po, nil)
		po.Status = "Completed"
	} else if po.Status == "Completed"{
		result.Message = "PO is already completed"
		return &result, nil
	} else {
		result.Message = "PO update failed"
		return &result, nil
	}

	po.Timestamp = timestamp
	poAsBytes, _ := json.Marshal(po)
	ctx.GetStub().PutState(poId, poAsBytes)

	result.Message = "Purchase Order " + poId +  " updated" 
	result.Status = true
	return &result, nil
}

func (s *SmartContract) CreateRepairOrder(ctx contractapi.TransactionContextInterface, assetId string, email string, timestamp string) (bool, error) {
	status := "Waiting for Requester Organization"

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, email)
	if !entitiesUserEmail.Status{
		return false, nil
	}

	user := entitiesUserEmail.Record
	if user.Role == "supervisor" {
		status = "Waiting for Repairer Organization"
	}

	roCounter := getCounter(ctx, "ROCounterNo")
	roCounter++
	
	indexName := "owner~roid"

	ro := RepairOrder{
		ID: "RO" +  strconv.Itoa(roCounter),
		AssetID: assetId,
		RequesterEmail: email,
		Status: status,
		RequesterOrg: user.Org,
		RepairerOrg: "mro",
		Timestamp: timestamp,
	}

	roAsBytes, _ := json.Marshal(ro)
	errPut := ctx.GetStub().PutState("RO" + strconv.Itoa(roCounter), roAsBytes)
	if errPut != nil {
		return false, fmt.Errorf(fmt.Sprintf("Failed to create RO: %s", ro.ID))
	}

	indexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{ro.RequesterEmail, "RO" + strconv.Itoa(roCounter)})
	if err != nil {
		return false, fmt.Errorf(fmt.Sprintf("Failed to create RO composite key: %s", ro.ID))
	}
	value := []byte{0x00}
	ctx.GetStub().PutState(indexKey, value)

	s.UpdateAsset(ctx, assetId, "", "", "Requesting Repair", -1, -1, timestamp, email, "", nil, &ro)

	s.incrementCounter(ctx, "ROCounterNo", -1)
	
	return true, errPut;
}

func (s *SmartContract) UpdateRepairOrderStatus(ctx contractapi.TransactionContextInterface, roId string, updateBy string, timestamp string) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	queryRO, _ := s.QueryRO(ctx, roId)
	ro := queryRO.Record

	entitiesRequesterEmail, _ := s.QueryUserByEmail(ctx, ro.RequesterEmail)
	requester := entitiesRequesterEmail.Record

	entitiesUpdateUserEmail, _ := s.QueryUserByEmail(ctx, updateBy)
	updateUser := entitiesUpdateUserEmail.Record

	queryAsset, _ := s.QueryAsset(ctx, ro.AssetID)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.Owner)
	user := entitiesUserEmail.Record

	if updateUser.Role != "supervisor"{
		result.Message = user.Email + " is not Supervisor"
		return &result, nil
	}

	if ro.Status == "Waiting for Requester Organization" && requester.Org == updateUser.Org {
		ro.Status = "Waiting for Repairer Organization"
	} else if ro.Status == "Waiting for Repairer Organization" && ro.RepairerOrg == updateUser.Org {
		s.UpdateAsset(ctx, asset.ID, asset.Name, asset.Number, "Repairing", asset.Quantity, asset.Weight, timestamp, updateBy, "", nil, ro)
		ro.Status = "Repairing"
	} else if ro.Status == "Repairing" && ro.RepairerOrg == updateUser.Org {
		tempStatus := "Available"
		if user.Org == "airline"{
			tempStatus = "Not Available"
		} 
		s.UpdateAsset(ctx, asset.ID, asset.Name, asset.Number, tempStatus, asset.Quantity, asset.Weight, timestamp, updateBy, "", nil, ro)
		ro.Status = "Completed"
	}else if ro.Status == "Completed"{
		result.Message = "RO is already completed"
		return &result, nil
	} else {
		result.Message = "RO update failed"
		return &result, nil
	}

	ro.Timestamp = timestamp
	roAsBytes, _ := json.Marshal(ro)
	ctx.GetStub().PutState(roId, roAsBytes)

	result.Message = "Repair Order " + roId +  " updated" 
	result.Status = true
	return &result, nil
}

func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, number string, name string, owner string, quantity int, weight int,timestamp string, previousAsset string, poReference *PurchaseOrder, roReference *RepairOrder, manualCounter int) (bool, error) {
	status := "Available"

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, owner)
	if !entitiesUserEmail.Status{
		return false, nil
	}
	
	userOrg := entitiesUserEmail.Record.Org
	if poReference == nil && (userOrg != "manufacturer" && (userOrg != "airline" && previousAsset != "")) {
		return false, nil
	}

	if userOrg == "airline"{
		status = "Not Available"
	}

	assetCounter := getCounter(ctx, "AssetCounterNo")
	if manualCounter != -1{
		assetCounter = manualCounter
	} 
	
	assetCounter++

	asset := Asset{
		ID: "ASSET" +  strconv.Itoa(assetCounter),
		Number:   number,
		Name:  name,
		Owner: owner,
		Status: status,
		Quantity: quantity,
		Weight: weight,
		Timestamp: timestamp,
		Org: userOrg,
		PurchaseOrderReference: poReference,
		RepairOrderReference: roReference,
		PreviousAsset: previousAsset,
	}

	assetAsBytes, _ := json.Marshal(asset)
	assetCheck := []string {};
	if len(assetCheck) > 0 {
		fmt.Printf("Failed to Increment Counter")

		return false, nil;
	} else {
		errPut := ctx.GetStub().PutState("ASSET" + strconv.Itoa(assetCounter), assetAsBytes)
		if errPut != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create asset: %s", asset.Number))
		}

		assetAvailableQty := AssetAvailableQty{
			AssetID: asset.ID,
			Quantity: quantity,
		}
		assetAvailableQtyAsBytes, _ := json.Marshal(assetAvailableQty)
		errPut = ctx.GetStub().PutState("ASSETQTY" + asset.ID, assetAvailableQtyAsBytes)
		if errPut != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create asset: %s", asset.Number))
		}

		indexName := "owner~assetid"
		indexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.Owner, "ASSET" + strconv.Itoa(assetCounter)})
		if err != nil {
			return false, fmt.Errorf(fmt.Sprintf("Failed to create asset composite key: %s", asset.Number))
		}
		value := []byte{0x00}
		ctx.GetStub().PutState(indexKey, value)

		s.incrementCounter(ctx, "AssetCounterNo", -1)
		
		return true, errPut;
	}
}

func (s *SmartContract) CreateAssetAPI(ctx contractapi.TransactionContextInterface, number string, name string, owner string, quantity int, weight int,timestamp string, previousAsset string) (bool, error) {
	return s.CreateAsset(ctx, number, name, owner, quantity, weight, previousAsset, timestamp, nil, nil, -1);
}

func (s *SmartContract) QueryRO(ctx contractapi.TransactionContextInterface, roId string) (*QueryResultRO, error) {
	result := QueryResultRO{}
	result.Key = roId
	result.Status = false

	roAsBytes, err := ctx.GetStub().GetState(roId)
	if err != nil || roAsBytes == nil {
		result.Message = "PO " + roId + " not existed"
		return &result, nil
	}

	ro := new(RepairOrder)
	_ = json.Unmarshal(roAsBytes, ro)

	result.Record = ro
	result.Status = true
	result.Message = "RO " + ro.ID + " retrieved"
	return &result, nil
}

func (s *SmartContract) QueryPO(ctx contractapi.TransactionContextInterface, poId string) (*QueryResultPO, error) {
	result := QueryResultPO{}
	result.Key = poId
	result.Status = false

	poAsBytes, err := ctx.GetStub().GetState(poId)
	if err != nil || poAsBytes == nil {
		result.Message = "PO " + poId + " not existed"
		return &result, nil
	}

	po := new(PurchaseOrder)
	_ = json.Unmarshal(poAsBytes, po)

	result.Record = po
	result.Status = true
	result.Message = "PO " + po.ID + " retrieved"
	return &result, nil
}

func (s *SmartContract) QueryAllRO(ctx contractapi.TransactionContextInterface) ([]QueryResultRO, error) {
	assetCounter := getCounter(ctx, "ROCounterNo")
	assetCounter++

	startKey := "RO0"
	endKey := "RO" + strconv.Itoa(assetCounter)

	resultsIterator, _ := ctx.GetStub().GetStateByRange(startKey, endKey)

	defer resultsIterator.Close()

	results := []QueryResultRO{}

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()

		ro := new(RepairOrder)
		_ = json.Unmarshal(queryResponse.Value, ro)

		queryResult := QueryResultRO{Key: queryResponse.Key, Record: ro}
		results = append(results, queryResult)
	}
	return results, nil
}

func (s *SmartContract) QueryAllPO(ctx contractapi.TransactionContextInterface) ([]QueryResultPO, error) {
	assetCounter := getCounter(ctx, "POCounterNo")
	assetCounter++

	startKey := "PO0"
	endKey := "PO" + strconv.Itoa(assetCounter)

	resultsIterator, _ := ctx.GetStub().GetStateByRange(startKey, endKey)

	defer resultsIterator.Close()

	results := []QueryResultPO{}

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()

		po := new(PurchaseOrder)
		_ = json.Unmarshal(queryResponse.Value, po)

		queryResult := QueryResultPO{Key: queryResponse.Key, Record: po}
		results = append(results, queryResult)
	}
	return results, nil
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

	assetQtyAsBytes, _ := ctx.GetStub().GetState("ASSETQTY" + assetId)

	assetQty := new(AssetAvailableQty)
	_ = json.Unmarshal(assetQtyAsBytes, assetQty)

	result.Record = asset
	result.RecordQty = assetQty
	result.Status = true
	result.Message = "Asset " + assetId + " retrieved"
	return &result, nil
}

func (s *SmartContract) QueryAssetAvailableQty(ctx contractapi.TransactionContextInterface, assetId string) (*QueryResultAssetQty, error) {
	result := QueryResultAssetQty{}
	result.Key = assetId
	result.Status = false

	assetAsBytes, err := ctx.GetStub().GetState("ASSETQTY" + assetId)
	if err != nil || assetAsBytes == nil {
		result.Message = "Asset " + assetId + " not existed"
		return &result, nil
	}

	asset := new(AssetAvailableQty)
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

	resultsIterator, _ := ctx.GetStub().GetStateByRange(startKey, endKey)

	startQtyKey := "ASSETQTYASSET0"
	endQtyKey := "ASSETQTYASSET" + strconv.Itoa(assetCounter)

	resultsQtyIterator, err := ctx.GetStub().GetStateByRange(startQtyKey, endQtyKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()
	defer resultsQtyIterator.Close()

	results := []QueryResultAsset{}

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()
		queryQtyResponse, err := resultsQtyIterator.Next()
		if err != nil {
			return nil, err
		}

		asset := new(Asset)
		_ = json.Unmarshal(queryResponse.Value, asset)

		assetQty := new(AssetAvailableQty)
		_ = json.Unmarshal(queryQtyResponse.Value, assetQty)

		queryResult := QueryResultAsset{Key: queryResponse.Key, Record: asset, RecordQty: assetQty}
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

		assetAsBytes, _ := ctx.GetStub().GetState(returnedAssetId)

		asset := new(Asset)
		_ = json.Unmarshal(assetAsBytes, asset)

		assetQtyAsBytes, _ := ctx.GetStub().GetState("ASSETQTY" + returnedAssetId)

		assetQty := new(AssetAvailableQty)
		_ = json.Unmarshal(assetQtyAsBytes, assetQty)

		queryResult := QueryResultAsset{Key: returnedAssetId, Record: asset, RecordQty: assetQty}
		results = append(results, queryResult)
	}
	return results, nil
}

func (s *SmartContract) QueryAssetHistory(ctx contractapi.TransactionContextInterface, assetId string, limitTimestamp string) (QueryResultAssetHistory, error) {
	result := QueryResultAssetHistory{}
	result.Key = assetId
	result.Status = false

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(assetId)
	if err != nil {
		result.Message = "Can't get history for " + assetId
		return result, nil
	}

	limitTime := time.Time{}
	if limitTimestamp != ""{
		limitTime = parseDateTime(limitTimestamp);
	}
	
	currentAsset := new(Asset)
	for resultsIterator.HasNext() {
		queryResponse,_ := resultsIterator.Next()

		asset := new(Asset)
		_ = json.Unmarshal(queryResponse.Value, asset)

		if limitTimestamp != "" {
			assetTime := parseDateTime(asset.Timestamp)
			if assetTime.After(limitTime) || assetTime.Equal(limitTime){
				continue
			}
		} 
		currentAsset = asset
		result.Record = append(result.Record, *asset)
	}

	firstAsset := currentAsset
	if firstAsset.PreviousAsset != "" {
		previousResult, _ := s.QueryAssetHistory(ctx, firstAsset.PreviousAsset, firstAsset.Timestamp)
		result.Record = append(result.Record, previousResult.Record...)
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

func (s *SmartContract) QueryUserByEmail(ctx contractapi.TransactionContextInterface, email string) (QueryResultUser, error) {
	result := QueryResultUser{}
	result.Key = email
	result.Status = false

	indexName := "email~userid"

	resultsIterator, _ := ctx.GetStub().GetStateByPartialCompositeKey(indexName, []string{email})
	if !resultsIterator.HasNext() {
		result.Message = "Email not exist"
		return result, nil
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse, _ := resultsIterator.Next()

		_, compositeKeyParts, err := ctx.GetStub().SplitCompositeKey(queryResponse.Key)
		if err != nil {
			result.Message = "Split composite key error"
			return result, nil
		}

		returnedUserId := compositeKeyParts[1]

		userAsBytes, _ := ctx.GetStub().GetState(returnedUserId)

		user := new(User)
		_ = json.Unmarshal(userAsBytes, user)

		result.Record = user
	}

	result.Message = "Email exist"
	result.Status = true
	return result, nil
}

func (s *SmartContract) SignIn(ctx contractapi.TransactionContextInterface, email string, password string) (*QueryResultSignIn, error) {
	result := QueryResultSignIn{}
	result.Status = false

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, email)
	if !entitiesUserEmail.Status{
		return &result, nil
	}

	result.Record = entitiesUserEmail.Record
	result.Key = entitiesUserEmail.Key

	// check if password matched
	if result.Record.Password != password {
		return &result,nil
	}
	result.Status = true

	return &result, nil
}

func (s *SmartContract) UpdateAssetAvailableQty(ctx contractapi.TransactionContextInterface, assetId string, quantity int, forceQuantity int) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	entitiesAssetQty, _ := s.QueryAssetAvailableQty(ctx, assetId)
	assetQty := entitiesAssetQty.Record
	if forceQuantity == -1 {
		assetQty.Quantity = assetQty.Quantity - quantity
	} else {
		assetQty.Quantity = forceQuantity
	}
	
	assetQtyAsBytes, _ := json.Marshal(assetQty)
	ctx.GetStub().PutState("ASSETQTY" + assetId, assetQtyAsBytes)

	result.Message = "Asset quantity for " + assetId +  " updated" 
	result.Status = true
	return &result, nil
}

func (s *SmartContract) TransferAssetOwner(ctx contractapi.TransactionContextInterface, assetId string, newOwner string, timestamp string) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	queryAsset, _ := s.QueryAsset(ctx, assetId)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.Owner)
	userOrg := entitiesUserEmail.Record.Org

	entitiesNewUserEmail, _ := s.QueryUserByEmail(ctx, newOwner)
	if !entitiesNewUserEmail.Status {
		result.Message = "New Owner not existed"
		return &result, nil
	}

	newUserOrg := entitiesNewUserEmail.Record.Org
	
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

	ownerAssetidIndexKey, _ := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.Owner, assetId})
	err := ctx.GetStub().DelState(ownerAssetidIndexKey)
	if err != nil {
		result.Message = "Failed to delete composite key " + ownerAssetidIndexKey
		return &result, nil
	}

	asset.Owner = newOwner
	asset.Org = newUserOrg
	asset.Timestamp = timestamp
	assetAsBytes, _ := json.Marshal(asset)
	ctx.GetStub().PutState(assetId, assetAsBytes)

	newOwnerAssetidIndexKey, err := ctx.GetStub().CreateCompositeKey(indexName, []string{asset.Owner, assetId})
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

func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, assetId string, name string, number string, status string, quantity int, weight int, timestamp string, updateBy string, newOwner string, poReference *PurchaseOrder, roReference *RepairOrder) (*QueryResultStatusMessage, error) {
	result := QueryResultStatusMessage{}
	result.Status = false;

	statusCheck := checkStatus(status)
	if !statusCheck {
		result.Message = "Status " + status + " not valid"
		return &result, nil
	}

	queryAsset, _ := s.QueryAsset(ctx, assetId)
	asset := queryAsset.Record

	entitiesUserEmail, _ := s.QueryUserByEmail(ctx, asset.Owner)
	userOrg := entitiesUserEmail.Record.Org

	entitiesUpdateUserEmail, _ := s.QueryUserByEmail(ctx, updateBy)
	updateUserOrg := entitiesUpdateUserEmail.Record.Org

	if newOwner != "" {
		entitiesNewOwnerEmail, _ := s.QueryUserByEmail(ctx, newOwner)
		newOwnerOrg := entitiesNewOwnerEmail.Record.Org

		tempQuantity := quantity
		quantity = asset.Quantity - quantity
		if quantity < 0 {
			result.Message = "Spare part doesn't have enough quantity"
			return &result, nil
		} else if quantity == 0 {
			status = "Not Available"
		}
		if newOwnerOrg == "airline"{
			assetCounter := getCounter(ctx, "AssetCounterNo")
			for i := 0; i < tempQuantity; i++ {
    			s.CreateAsset(ctx, asset.Number, asset.Name, newOwner, 1, asset.Weight, timestamp, assetId, poReference, roReference, assetCounter)
				assetCounter++
			}
			s.incrementCounter(ctx, "AssetCounterNo", assetCounter)
		} else{
			s.CreateAsset(ctx, asset.Number, asset.Name, newOwner, tempQuantity, asset.Weight, timestamp, assetId, poReference, roReference, -1)
		}
	}
	
	if roReference == nil && (newOwner == "" && userOrg != updateUserOrg){
		result.Message = "You are not from " + userOrg + " organization"
		return &result, nil
	}

	if name != "" {
		asset.Name = name
	}
	if number != "" {
		asset.Number = number
	}
	if status != "" {
		asset.Status = status
	}
	if quantity != -1 {
		asset.Quantity = quantity
		s.UpdateAssetAvailableQty(ctx,assetId, quantity, quantity)
	}
	if weight != -1 {
		asset.Weight = weight
	}
	asset.PreviousAsset = "";
	asset.PurchaseOrderReference = poReference;
	asset.RepairOrderReference = roReference;
	asset.Timestamp = timestamp
	assetAsBytes, _ := json.Marshal(asset)
	ctx.GetStub().PutState(assetId, assetAsBytes)

	result.Message = "Spare part " + assetId +  " updated" 
	result.Status = true
	return &result, nil
}

func (s *SmartContract) UpdateAssetAPI(ctx contractapi.TransactionContextInterface, assetId string, name string, number string, status string, quantity int, weight int, timestamp string, updateBy string, newOwner string) (*QueryResultStatusMessage, error) {
	return s.UpdateAsset(ctx, assetId, name, number, status, quantity, weight, timestamp, updateBy, newOwner, nil, nil)
}

func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, name string, email string, org string, role string, address string, password string) (bool, error) {
	userCounter := getCounter(ctx, "UserCounterNo")
	userCounter++

	indexName := "email~userid"

	var comAsset = User{Name: name, User_ID: "USER" + strconv.Itoa(userCounter), Email: email, Org: org, Role: role, Address: address, Password: password}
	comAssetAsBytes, _ := json.Marshal(comAsset)

	emailCheck, _ := s.QueryUserByEmail(ctx, email)
	if emailCheck.Status == true {
		fmt.Printf("Email Existed")

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
		s.incrementCounter(ctx, "UserCounterNo", -1)
		
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