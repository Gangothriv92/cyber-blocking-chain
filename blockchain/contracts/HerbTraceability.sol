
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract HerbTraceability {

    address public owner;

    struct Herb {
        uint256 id;
        string herbName;
        string scientificName;
        string collectorName;
        string collectionLocation;
        string collectionDate;
        string metadataURI;
        int256 latitude;
        int256 longitude;
        uint256 quantity;
        address registeredBy;
        bool exists;
    }

    struct Stage {
        string stageName;
        string description;
        string location;
        string date;
        string metadataURI;
        int256 latitude;
        int256 longitude;
        address updatedBy;
        uint256 timestamp;
    }

    uint256 public nextHerbId = 1;

    mapping(uint256 => Herb) private herbs;
    mapping(uint256 => Stage[]) private history;
    mapping(address => bool) public authorizedUsers;

    event HerbRegistered(
        uint256 indexed herbId,
        string herbName,
        address indexed collector
    );

    event StageUpdated(
        uint256 indexed herbId,
        string stageName,
        address indexed updatedBy
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAuthorized() {
        require(
            authorizedUsers[msg.sender],
            "Not authorized"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedUsers[msg.sender] = true;
    }

    function authorizeUser(address user)
        external
        onlyOwner
    {
        require(user != address(0), "Invalid address");
        authorizedUsers[user] = true;
    }

    function revokeUser(address user)
        external
        onlyOwner
    {
        require(user != owner, "Cannot revoke owner");
        authorizedUsers[user] = false;
    }

    function registerHerb(
        string memory herbName,
        string memory scientificName,
        string memory collectorName,
        string memory collectionLocation,
        string memory collectionDate,
        uint256 quantity,
        int256 latitude,
        int256 longitude,
        string memory metadataURI
    )
        external
        onlyAuthorized
        returns (uint256)
    {
        require(bytes(herbName).length > 0, "Herb name required");
        require(quantity > 0, "Invalid quantity");

        uint256 id = nextHerbId++;

        herbs[id] = Herb({
            id: id,
            herbName: herbName,
            scientificName: scientificName,
            collectorName: collectorName,
            collectionLocation: collectionLocation,
            collectionDate: collectionDate,
            metadataURI: metadataURI,
            latitude: latitude,
            longitude: longitude,
            quantity: quantity,
            registeredBy: msg.sender,
            exists: true
        });

        emit HerbRegistered(id, herbName, msg.sender);

        return id;
    }

    function addStage(
        uint256 herbId,
        string memory stageName,
        string memory description,
        string memory location,
        string memory date,
        int256 latitude,
        int256 longitude,
        string memory metadataURI
    )
        external
        onlyAuthorized
    {
        require(herbs[herbId].exists, "Herb not found");

        history[herbId].push(
            Stage({
                stageName: stageName,
                description: description,
                location: location,
                date: date,
                metadataURI: metadataURI,
                latitude: latitude,
                longitude: longitude,
                updatedBy: msg.sender,
                timestamp: block.timestamp
            })
        );

        emit StageUpdated(herbId, stageName, msg.sender);
    }

    function getHerb(uint256 herbId)
        external
        view
        returns (Herb memory)
    {
        require(herbs[herbId].exists, "Herb not found");
        return herbs[herbId];
    }

    function getHistory(uint256 herbId)
        external
        view
        returns (Stage[] memory)
    {
        require(herbs[herbId].exists, "Herb not found");
        return history[herbId];
    }

    function getHistoryCount(uint256 herbId)
        external
        view
        returns (uint256)
    {
        require(herbs[herbId].exists, "Herb not found");
        return history[herbId].length;
    }
}
