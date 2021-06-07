const { expect } = require("chai");

describe("Library", function() {
  let library;
  let bookTitle = 'Harry Potter';
  let bookStock = 30;
  let deployer;

  it("Should add Harry Potter to the library.", async function() {
    const [owner] = await ethers.getSigners();
    deployer = owner;

    const Library = await ethers.getContractFactory("Library");
    library = await Library.deploy();
    
    await library.deployed();

    await library.addBook(bookTitle, bookStock);
    const book = await library.getBook(bookTitle);

    expect(book.title).to.equal(bookTitle);
  });

  it("Should borrow the book.", async function() {
    await library.borrowBook(bookTitle);
    const book = await library.getBook(bookTitle);

    expect(book.stock).to.equal(bookStock - 1);
  });

  it("Should return the book.", async function() {
    await library.returnBook(bookTitle);
    const book = await library.getBook(bookTitle);

    expect(book.stock).to.equal(bookStock);
  });

  it("Should update the stock of the book.", async function() {
    const newStock = 40;

    await library.updateBookStock(bookTitle, newStock);
    const book = await library.getBook(bookTitle);

    expect(book.stock).to.equal(newStock);
  });

  it("Should get every user that borrowed the book.", async function() {
    const usersThatBorrowedTheBook = await library.getUsersThatBorrowedTheBook(bookTitle);

    expect(usersThatBorrowedTheBook.length).to.equal(1);
    expect(usersThatBorrowedTheBook[0]).to.equal(deployer.address);
  });

});
