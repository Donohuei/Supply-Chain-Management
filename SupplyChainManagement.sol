// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
#eg:
contract SupplyChainManagement {
    enum ProductStatus { Created, InTransit, Delivered }

    struct Product {
        uint256 productId;
        address producer;
        string productName;
        string productDescription;
        uint256 creationTime;
        uint256[] transitTimes;
        ProductStatus status;
    }

    mapping(uint256 => Product) public products;
    uint256 public productIdCounter;

    mapping(uint256 => address[]) public productTransitStops;
    mapping(uint256 => bool) public productAuthenticity;

    event ProductRegistered(uint256 productId, address producer, string productName, string productDescription);
    event ProductTransit(uint256 productId, address transitStop);
    event ProductDelivered(uint256 productId);
    event ProductVerified(uint256 productId, bool isAuthentic);

    modifier onlyProducer() {
        require(products[productIdCounter].producer == msg.sender, "You are not the producer");
        _;
    }

    function registerProduct(string memory _productName, string memory _productDescription) public onlyProducer {
        productIdCounter++;
        products[productIdCounter] = Product({
            productId: productIdCounter,
            producer: msg.sender,
            productName: _productName,
            productDescription: _productDescription,
            creationTime: block.timestamp,
            transitTimes: new uint256[](0),
            status: ProductStatus.Created
        });
        emit ProductRegistered(productIdCounter, msg.sender, _productName, _productDescription);
    }

    function updateProductStatus(uint256 _productId, ProductStatus _status) public {
        require(products[_productId].producer == msg.sender, "You are not the producer");
        require(_status > products[_productId].status, "Invalid status update");

        products[_productId].status = _status;
        if (_status == ProductStatus.InTransit) {
            products[_productId].transitTimes.push(block.timestamp);
            productTransitStops[_productId].push(msg.sender);
            emit ProductTransit(_productId, msg.sender);
        } else if (_status == ProductStatus.Delivered) {
            emit ProductDelivered(_productId);
        }
    }

    function verifyProductAuthenticity(uint256 _productId, bool _isAuthentic) public {
        productAuthenticity[_productId] = _isAuthentic;
        emit ProductVerified(_productId, _isAuthentic);
    }

    function getProductTransitStops(uint256 _productId) public view returns (address[] memory) {
        return productTransitStops[_productId];
    }

    function getProductInformation(uint256 _productId) public view returns (
        address producer,
        string memory productName,
        string memory productDescription,
        uint256 creationTime,
        uint256[] memory transitTimes,
        ProductStatus status,
        bool isAuthentic
    ) {
        Product storage product = products[_productId];
        return (
            product.producer,
            product.productName,
            product.productDescription,
            product.creationTime,
            product.transitTimes,
            product.status,
            productAuthenticity[_productId]
        );
    }
}

