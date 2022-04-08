pragma solidity >=0.5.0 <0.7.0;

import "@aztec/protocol/contracts/interfaces/IAZTEC.sol";
import "@aztec/protocol/contracts/libs/NoteUtils.sol";
import "@aztec/protocol/contracts/ERC1724/ZkAsset.sol";
import "./ZKERC20/ZKERC20.sol";
import "./Loan.sol";

/// Loan LoanDapp inherits from IAZTEC contract
contract LoanDapp is IAZTEC {
    using NoteUtils for bytes;

    event SettlementCurrencyAdded(uint256 id, address settlementAddress);

    event LoanApprovedForSettlement(address loanId);

    event LoanCreated(
        address id,
        address borrower,
        bytes32 notional,
        string borrowerPublicKey,
        uint256[] loanVariables,
        uint256 createdAt
    );

    event ViewRequestCreated(
        address loanId,
        address lender,
        string lenderPublicKey
    );

    event ViewRequestApproved(
        uint256 accessId,
        address loanId,
        address user,
        string sharedSecret
    );

    event NoteAccessApproved(
        uint256 accessId,
        bytes32 note,
        address user,
        string sharedSecret
    );

    address owner = msg.sender;
    address aceAddress;
    address[] public loans;
    mapping(uint256 => address) public settlementCurrencies;

    uint24 MINT_PRO0F = 66049;
    uint24 BILATERAL_SWAP_PROOF = 65794;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyBorrower(address _loanAddress) {
        Loan loanContract = Loan(_loanAddress);
        require(msg.sender == loanContract.borrower());
        _;
    }

    constructor(address _aceAddress) public {
        aceAddress = _aceAddress;
    }

    /// the _getCurrencyContract function takes as input a _settlementCurrencyId
    /// checks if the _settlementCurrencyId exist in the settlementCurrencies mapping
    /// and returns the address
    function _getCurrencyContract(uint256 _settlementCurrencyId)
        internal
        view
        returns (address)
    {
        require(
            settlementCurrencies[_settlementCurrencyId] != address(0),
            "Settlement Currency is not defined"
        );
        return settlementCurrencies[_settlementCurrencyId];
    }

    /// the _generateAccessId takes as input _note and _user
    /// and returns an hash of the teo input which is converted to uint
    function _generateAccessId(bytes32 _note, address _user)
        internal
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(_note, _user)));
    }

    /// the _approveNoteAccess internal function takes as input _note, _userAddress and _sharedSecret
    /// generates an access id
    /// and emits the NoteAccessApproved event
    function _approveNoteAccess(
        bytes32 _note,
        address _userAddress,
        string memory _sharedSecret
    ) internal {
        uint256 accessId = _generateAccessId(_note, _userAddress);
        emit NoteAccessApproved(accessId, _note, _userAddress, _sharedSecret);
    }

    /// the _createLoan private function takes as input _notional, _loanVariables array and _proofData
    /// creates a Loan with these inputs and the loan address is added it to the loans array
    /// and returns the new loans address
    function _createLoan(
        bytes32 _notional,
        uint256[] memory _loanVariables,
        bytes memory _proofData
    ) private returns (address) {
        address loanCurrency = _getCurrencyContract(_loanVariables[3]);

        Loan newLoan = new Loan(
            _notional,
            _loanVariables,
            msg.sender,
            aceAddress,
            loanCurrency
        );

        loans.push(address(newLoan));
        Loan loanContract = Loan(address(newLoan));

        loanContract.setProofs(1, uint256(-1));
        loanContract.confidentialMint(MINT_PROOF, bytes(_proofData));

        return address(newLoan);
    }

    /// the addSettlementCurrency function takes an id and an adress
    /// check that the msg.sender is the owner
    /// add the address to the settlementCurrencies mapping it to the id
    /// emit the SettlementCurrencyAdded event
    function addSettlementCurrency(uint256 _id, address _address)
        external
        onlyOwner
    {
        settlementCurrencies[_id] = _address;
        emit SettlementCurrencyAdded(_id, _address);
    }

    /// the createLoan function takes as input _notional, _viewingKey, _borrowerPublicKey, _loanVariables
    /// calls the _createLoan internal function which returns the createdload address
    /// the LoanCreated event is emitted
    /// _approveNoteAccess internal function returns an accessId and emit the NoteAccessApproved event
    function createLoan(
        bytes32 _notional,
        string calldata _viewingKey,
        string calldata _borrowerPublicKey,
        uint256[] calldata _loanVariables,
        /// [0] interestRate
        /// [1] interestPeriod
        /// [2] loanDuration
        /// [3] settlementCurrencyId
        bytes calldata _proofData
    ) external {
        address loanId = _createLoan(_notional, _loanVariables, _proofData);

        emit LoanCreated(
            loanId,
            msg.sender,
            _notional,
            _borrowerPublicKey,
            _loanVariables,
            block.timestamp
        );

        _approveNoteAccess(_notional, msg.sender, _viewingKey);
    }

    /// the approveLoanNotional takes as input _noteHash, _signature, _loanId
    /// the LoanApprovedForSettlement event is emitted
    function approveLoanNotional(
        bytes32 _noteHash,
        bytes memory _signature,
        address _loanId
    ) public {
        Loan loanContract = Loan(_loanId);
        loanContract.confidentialApprove(_noteHash, _loanId, true, _signature);
        emit LoanApprovedForSettlement(_loanId);
    }

    /// the submitViewRequest function takes as input the loadId and _lenderPublicKey
    /// and these data including the sender address is emitted
    function submitViewRequest(
        address _loanId,
        string calldata _lenderPublicKey
    ) external {
        emit ViewRequestCreated(_loanId, msg.sender, _lenderPublicKey);
    }

    /// the approveViewRequest function takes as input the loadId, _lender, _notionalNote, _sharedSecret
    /// accessId is generated
    /// and these data is emitted
    function approveViewRequest(
        address _loanId,
        address _lender,
        bytes32 _notionalNote,
        string calldata _sharedSecret
    ) external onlyBorrower(_loanId) {
        uint256 accessId = _generateAccessId(_notionalNote, _lender);

        emit ViewRequestApproved(accessId, _loanId, _lender, _sharedSecret);
    }

    event SettlementSuccesfull(
        address indexed from,
        address indexed to,
        address loanId,
        uint256 timestamp
    );

    struct LoanPayment {
        address from;
        address to;
        bytes notional;
    }

    mapping(uint256 => mapping(uint256 => LoanPayment)) public loanPayments;

    /// the settleInitialBalance function takes as input the _loanId, _proofData, _currentInterestBalance
    /// loads the loancontract with the loadId
    /// settles the load
    /// and some transaction data is emitted
    function settleInitialBalance(
        address _loanId,
        bytes calldata _proofData,
        bytes32 _currentInterestBalance
    ) external {
        Loan loanContract = Loan(_loanId);
        loanContract.settleLoan(
            _proofData,
            _currentInterestBalance,
            msg.sender
        );
        emit SettlementSuccesfull(
            msg.sender,
            loanContract.borrower(),
            _loanId,
            block.timestamp
        );
    }

    /// the approveNoteAccess function takes as input the _note, _viewingKey, _sharedSecret, _sharedWith
    /// checks the the bytes length of the _viewkingkey is not zero, then calls _approveNoteAccess which generates an accessID
    /// checks the the bytes length of the _sharedSecret is not zero, then calls _approveNoteAccess which generates an accessID
    function approveNoteAccess(
        bytes32 _note,
        string calldata _viewingKey,
        string calldata _sharedSecret,
        address _sharedWith
    ) external {
        if (bytes(_viewingKey).length != 0) {
            _approveNoteAccess(_note, msg.sender, _viewingKey);
        }

        if (bytes(_sharedSecret).length != 0) {
            _approveNoteAccess(_note, _sharedWith, _sharedSecret);
        }
    }
}
