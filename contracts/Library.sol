// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Library is Ownable {
  event BookAdded(string _title, uint32 _stock);
  event BookStockUpdated(string _title, uint32 _stock);
  event BookBorrowedByUser(string _title, address _userId);
  event BookReturnedByUser(string _title, address _userId);

  modifier mustNotBeBorrowed(string _title) {
    require(booksThatUsersBorrowed[getBookIdByTitle(_title)][msg.sender] == false, "You have already borrowed this book.");
    _;
   }

   modifier mustHaveAvailableCopies(string _title) {
    require(books[getBookIdByTitle(_title)].stock > 0, "There are no available copies of this book.");
    _;
   }
  
  struct Book {
    string title;
    uint32 stock;
  }
  
  mapping(bytes32 => Book) public books;
  mapping(bytes32 => mapping(address => bool)) public booksThatUsersBorrowed;

  function getBookIdByTitle(string calldata _title) internal returns(bytes32) {
    return keccak256(abi.encodePacked(_title));
  }
  
  
  function addBook(string calldata _title, uint32 _quantity) public onlyOwner {
    books[getBookIdByTitle(_title)] = Book(_title, _quantity);

    emit BookAdded(_title, _quantity);
  }
  
  function updateStockBookQuantity(string calldata _title, uint32 _quantity) public onlyOwner {
    books[getBookIdByTitle(_title)].stock = _quantity;
    
    emit BookStockUpdated(_title, _quantity);
  }
  
  function borrowBook(string calldata _title) public mustNotBeBorrowed(_id) mustHaveAvailableCopies(_id) {
    bytes32 bookId = getBookIdByTitle(_title);
    books[bookId].stock -= 1;
    booksThatUsersBorrowed[bookId][msg.sender] = true;
    
    emit BookBorrowedByUser(_title, msg.sender);
  }
  
  function returnBook(uint32 _id) public toBeBorrowed(_id) {    
    bytes32 bookId = getBookIdByTitle(_title);
    books[bookId].stock += 1;
    booksThatUsersBorrowed[bookId][msg.sender] = false;
    
    emit BookReturnedByUser(_title, msg.sender);
  }
}