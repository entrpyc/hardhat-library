// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8 .0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Library is Ownable {
  event BookAdded(string _title, uint32 _stock);
  event BookStockUpdated(string _title, uint32 _stock);
  event BookBorrowedByUser(string _title, address _userId);
  event BookReturnedByUser(string _title, address _userId);

  modifier mustNotBeBorrowed(string calldata _title) {
    require(booksThatUsersBorrowed[getBookIdByTitle(_title)][msg.sender] == false, "You have already borrowed this book.");
    _;
  }


  modifier mustBeBorrowed(string calldata _title) {
    require(booksThatUsersBorrowed[getBookIdByTitle(_title)][msg.sender] == true, "You haven't borrowed this book.");
    _;
  }

  modifier mustHaveAvailableCopies(string calldata _title) {
    require(books[getBookIdByTitle(_title)].stock > 0, "There are no available copies of this book.");
    _;
  }

  struct Book {
    string title;
    uint32 stock;
    address[] usersThatBorrowedTheBook;
  }

  mapping(bytes32 => Book) public books;
  mapping(bytes32 => mapping(address => bool)) public booksThatUsersBorrowed;

  function getBookIdByTitle(string calldata _title) internal pure returns(bytes32) {
    return keccak256(abi.encodePacked(_title));
  }


  function addBook(string calldata _title, uint32 _quantity) public onlyOwner {
    books[getBookIdByTitle(_title)] = Book(_title, _quantity, new address[](0));

    emit BookAdded(_title, _quantity);
  }

  function updateStockBookQuantity(string calldata _title, uint32 _quantity) public onlyOwner {
    books[getBookIdByTitle(_title)].stock = _quantity;

    emit BookStockUpdated(_title, _quantity);
  }

  function borrowBook(string calldata _title) public mustNotBeBorrowed(_title) mustHaveAvailableCopies(_title) {
    bytes32 bookId = getBookIdByTitle(_title);
    books[bookId].stock -= 1;
    books[bookId].usersThatBorrowedTheBook.push(msg.sender);
    booksThatUsersBorrowed[bookId][msg.sender] = true;

    emit BookBorrowedByUser(_title, msg.sender);
  }

  function returnBook(string calldata _title) public mustBeBorrowed(_title) {
    bytes32 bookId = getBookIdByTitle(_title);
    books[bookId].stock += 1;
    booksThatUsersBorrowed[bookId][msg.sender] = false;

    emit BookReturnedByUser(_title, msg.sender);
  }
}