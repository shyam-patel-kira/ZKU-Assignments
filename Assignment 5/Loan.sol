/// solidity versio user
pragma solidity >=0.5.0 <0.7.0;

/// import the required library
import "@aztec/protocol/contracts/ERC1724/ZkAssetMintable.sol";
import "@aztec/protocol/contracts/libs/NoteUtils.sol";
import "@aztec/protocol/contracts/interfaces/IZkAsset.sol";
import "./LoanUtilities.sol";

/// Loan contract inherits from ZkAssetMintable contract
contract Loan is ZkAssetMintable {
    using SafeMath for uint256;
    using NoteUtils for bytes;
    using LoanUtilities for LoanUtilities.LoanVariables;
    LoanUtilities.LoanVariables public loanVariables;

    IZkAsset public settlementToken;
    /// [0] interestRate
    /// [1] interestPeriod
    /// [2] duration
    /// [3] settlementCurrencyId
    /// [4] loanSettlementDate
    /// [5] lastInterestPaymentDate address public borrower;
    address public lender;
    address public borrower;

    mapping(address => bytes) lenderApprovals;

    event LoanPayment(string paymentType, uint256 lastInterestPaymentDate);
    event LoanDefault();
    event LoanRepaid();

    /// A note struct which stores an address and bytes32 datatype (cypher)
    struct Note {
        address owner;
        bytes32 noteHash;
    }

    /// this function takes a note as input and returns the owner and the notehash as a Note struct
    function _noteCoderToStruct(bytes memory note)
        internal
        pure
        returns (Note memory codedNote)
    {
        (address owner, bytes32 noteHash, ) = note.extractNote();
        return Note(owner, noteHash);
    }

    constructor(
        bytes32 _notional,
        uint256[] memory _loanVariables,
        address _borrower,
        address _aceAddress,
        address _settlementCurrency
    ) public ZkAssetMintable(_aceAddress, address(0), 1, true, false) {
        loanVariables.loanFactory = msg.sender;
        loanVariables.notional = _notional;
        loanVariables.id = address(this);
        loanVariables.interestRate = _loanVariables[0];
        loanVariables.interestPeriod = _loanVariables[1];
        loanVariables.duration = _loanVariables[2];
        loanVariables.borrower = _borrower;
        borrower = _borrower;
        loanVariables.settlementToken = IZkAsset(_settlementCurrency);
        loanVariables.aceAddress = _aceAddress;
    }

    /// this function populate the lenderApprovals mappings with the address of the function caller and a constant byte
    function requestAccess() public {
        lenderApprovals[msg.sender] = "0x";
    }

    /// this function populate the lenderApprovals mappings with a lendr address and a _sharedSecret
    function approveAccess(address _lender, bytes memory _sharedSecret) public {
        lenderApprovals[_lender] = _sharedSecret;
    }

    function settleLoan(
        bytes calldata _proofData,
        bytes32 _currentInterestBalance,
        address _lender
    ) external {
        //// a onlyLoanDapp check to make sure the lender(msg.sender) is not the loan dapp
        //// i.e the address that called the constructor
        LoanUtilities.onlyLoanDapp(msg.sender, loanVariables.loanFactory);

        ////  then process the loan settlement
        LoanUtilities._processLoanSettlement(_proofData, loanVariables);

        //// loanVariable attributes are then updated like
        //// the loanSettlementDate, lastInterestPaymentDate
        //// currentInterestBalance and lender
        loanVariables.loanSettlementDate = block.timestamp;
        loanVariables.lastInterestPaymentDate = block.timestamp;
        loanVariables.currentInterestBalance = _currentInterestBalance;
        loanVariables.lender = _lender;
        lender = _lender;
    }

    /// The confidentialMint function takes as input the a proof and proofdata
    /// performs an onlyLoanDapp check to make sure the lender(msg.sender)is not the loan dapp i.e the contract creator
    /// checks the the sender is the owner
    /// checks that the length of the _proofData is not zero
    /// confidential mint is done on the proof data, output _proofOutputs
    /// a tuple that includes the newTotal is extracted from the _proofOutputs first element
    /// a tuple that includes the mintedNotes is extracted from the _proofOutputs second element
    /// the noteHash and metadata is extracted from the newTotal
    /// logging is done
    function confidentialMint(uint24 _proof, bytes calldata _proofData)
        external
    {
        LoanUtilities.onlyLoanDapp(msg.sender, loanVariables.loanFactory);
        require(
            msg.sender == owner,
            "only owner can call the confidentialMint() method"
        );
        require(_proofData.length != 0, "proof invalid");
        /// overide this function to change the mint method to msg.sender
        bytes memory _proofOutputs = ace.mint(_proof, _proofData, msg.sender);

        (, bytes memory newTotal, , ) = _proofOutputs
            .get(0)
            .extractProofOutput();

        (, bytes memory mintedNotes, , ) = _proofOutputs
            .get(1)
            .extractProofOutput();

        (, bytes32 noteHash, bytes memory metadata) = newTotal.extractNote();

        logOutputNotes(mintedNotes);
        emit UpdateTotalMinted(noteHash, metadata);
    }

    /// The confidentialMint function takes as input the 2 proofs and _interestDurationToWithdraw
    /// proof1 is validation cehck is done by calling the _validateInterestProof function. its outputs _proof1OutputNotes
    /// add the lastInterestPaymentDate to the _interestDurationToWithdraw and makes sure its lesser than the current time
    /// _processInterestWithdrawal function takes the proof2, _proof1OutputNotes and the loanVariables as input
    ///
    /// and returns the newCurrentInterestNoteHash
    /// currentInterestBalance is updated with the newCurrentInterestNoteHash
    /// lastInterestPaymentDate is updated by incrementing with _interestDurationToWithdraw
    /// LoanPayment event is emitted with 'INTEREST' and loanVariables.lastInterestPaymentDate
    function withdrawInterest(
        bytes memory _proof1,
        bytes memory _proof2,
        uint256 _interestDurationToWithdraw
    ) public {
        (, bytes memory _proof1OutputNotes) = LoanUtilities
            ._validateInterestProof(
                _proof1,
                _interestDurationToWithdraw,
                loanVariables
            );

        require(
            _interestDurationToWithdraw.add(
                loanVariables.lastInterestPaymentDate
            ) < block.timestamp,
            " withdraw is greater than accrued interest"
        );

        bytes32 newCurrentInterestNoteHash = LoanUtilities
            ._processInterestWithdrawal(
                _proof2,
                _proof1OutputNotes,
                loanVariables
            );

        loanVariables.currentInterestBalance = newCurrentInterestNoteHash;
        loanVariables.lastInterestPaymentDate = loanVariables
            .lastInterestPaymentDate
            .add(_interestDurationToWithdraw);

        emit LoanPayment("INTEREST", loanVariables.lastInterestPaymentDate);
    }

    /// The adjustInterestBalance function takes as input a _proofData
    /// the function onlyBorrower checks if thhe sender is the borrower

    /// _processAdjustInterest function returns the newCurrentInterestBalance which is then updated in the loanVariables
    function adjustInterestBalance(bytes memory _proofData) public {
        LoanUtilities.onlyBorrower(msg.sender, borrower);

        bytes32 newCurrentInterestBalance = LoanUtilities
            ._processAdjustInterest(_proofData, loanVariables);
        loanVariables.currentInterestBalance = newCurrentInterestBalance;
    }

    /// The repayLoan function takes as input the 2 proofs
    /// the function onlyBorrower checks if thhe sender is the borrower
    /// updates the remainingInterestDuration by adding the loanSettlementDate to the duration and subtracting the lastInterestPaymentDate
    /// proof1 is validation cehck is done by calling the _validateInterestProof function. its outputs _proof1OutputNotes
    /// check if the load has matured, loanSettlementDate + duration must be lesser than the current time
    ///_processLoanRepayment proccessing loan repayment
    /// LoanRepaid event is emitted

    function repayLoan(bytes memory _proof1, bytes memory _proof2) public {
        LoanUtilities.onlyBorrower(msg.sender, borrower);

        uint256 remainingInterestDuration = loanVariables
            .loanSettlementDate
            .add(loanVariables.duration)
            .sub(loanVariables.lastInterestPaymentDate);

        (, bytes memory _proof1OutputNotes) = LoanUtilities
            ._validateInterestProof(
                _proof1,
                remainingInterestDuration,
                loanVariables
            );

        require(
            loanVariables.loanSettlementDate.add(loanVariables.duration) <
                block.timestamp,
            "loan has not matured"
        );

        LoanUtilities._processLoanRepayment(
            _proof2,
            _proof1OutputNotes,
            loanVariables
        );

        emit LoanRepaid();
    }

    /// The confidentiamarkLoanAsDefaultlMint function takes as input the 2 proofs and _interestDurationToWithdraw
    /// _validateDefaultProofs checks if the noteHash in _proof2InputNotes the same with _proof1OutputNotes noteHash and currentInterestBalance
    /// LoanDefault event is emitted

    function markLoanAsDefault(
        bytes memory _proof1,
        bytes memory _proof2,
        uint256 _interestDurationToWithdraw
    ) public {
        require(
            _interestDurationToWithdraw.add(
                loanVariables.lastInterestPaymentDate
            ) < block.timestamp,
            "withdraw is greater than accrued interest"
        );
        LoanUtilities._validateDefaultProofs(
            _proof1,
            _proof2,
            _interestDurationToWithdraw,
            loanVariables
        );
        emit LoanDefault();
    }
}
