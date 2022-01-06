// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "contracts/IERC20.sol";

interface OSMInterface{
    function getCurrencyValue(string memory currency_name) external view returns(uint256);
}

interface governanceInterface{

    /* get USP reserve ratio */
    function getUSPReserveRatio() view external returns (uint amount);

    /* get USP loan daily interest rate */
    function getUSPLoanInterestRate() view external returns (uint amount);

    /* get USP loan pledge rate */
    function getUSPLoanPledgeRate() view external returns (uint amount);

    /* get USP loan pledge rate warning value */
    function getUSPLoanPledgeRateWarningValue() view external returns (uint amount);

    /* get USP loan liquidation rate */
    function getUSPLoanLiquidationRate() view external returns (uint amount);
}

contract USP is IERC20 {
    
    address private owner;
    address private auditor;
    address private OSM;
    address private governance;
    string public constant name = "usp token";
    uint8 public constant decimals = 18;
    string public constant symbol = "USP";
    string unit="UNIT";
    string usp="USP";
    uint256 private _totalSupply;
    mapping(address => uint256) user_balances;
    mapping(address => mapping(address => uint256)) _approve;
    
    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyAuditor(){
        require(msg.sender == auditor);
        _;
    }

    
    //set auditor address
    function setAuditor(address newAuditor)public onlyOwner returns(bool){
        auditor = newAuditor;
        return true;
    }

    //set OSM address
    function setOSM(address newOSM)public onlyAuditor returns(bool){
        OSM = newOSM;
        return true;
    }

    //set governance address
    function setGovernance(address newGovernance)public onlyAuditor returns(bool){
        governance = newGovernance;
        return true;
    }

    receive () external payable{}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    // query balance of address
    function balanceOf(address tokenOwner) external view override returns (uint256 balance) {
        return user_balances[tokenOwner];
    }
    
    function transfer(address to, uint256 tokens) external override returns (bool success) {
	require(user_balances[msg.sender] > tokens,"balances not enough");
        user_balances[msg.sender] -= tokens;
        user_balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }
    
    // The remaining number of tokens authorized to spender by the tokenowner
    function allowance(address tokenOwner, address spender) external view override returns (uint256 remaining) {
        return _approve[tokenOwner][spender];
    }
  
    // tokenOwner delegate spender use tokens
    function approve(address spender, uint256 tokens) external override returns (bool success) {
        _approve[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // transfer tokens from >> to
    function transferFrom(address from, address to, uint256 tokens) external override returns (bool success) {
        _approve[from][msg.sender] -= tokens;
        user_balances[from] -= tokens;
        user_balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
    
    //query OSM rate
    function mintRate(uint256 amount)public view returns(uint256){
        return getOSMValue(unit) * amount / getOSMValue(usp);
    }

    //based OSM rate, use unit change usp
    function mint()public payable returns(bool) {
        uint exchange_tokens = mintRate(msg.value);
        if(_totalSupply < 500000000000000000000000000){
            _totalSupply = _totalSupply + exchange_tokens;
            user_balances[msg.sender] = user_balances[msg.sender] + exchange_tokens;
        }

        emit Transfer(address(0), msg.sender, exchange_tokens);
        return true;
    }
    //based OSM rate, unit<-usp reback
    function mintBack(uint256 tokens) public payable returns(bool){
        require(_totalSupply > 50000000000000000000000000);
        require((_totalSupply - 50000000000000000000000000) *getOSMValue(usp) /getOSMValue(unit) >= tokens, "overflow the mintbak threshold");
        uint exchange_tokens = getOSMValue(usp) * tokens / getOSMValue(unit);
        user_balances[msg.sender] -= tokens;
        _totalSupply -= tokens;
        payable(msg.sender).transfer(exchange_tokens);
        return true;
    }
    
    //burn usp by auditor 
    function burn(address account, uint256 tokens) public onlyOwner returns (bool) {
        require(tokens <= user_balances[account]);
        _totalSupply -= tokens;
        user_balances[account] -= tokens;
        
        emit Transfer(account, address(0), tokens);
        return true;
    }
    
    uint256 public usp_bank_balances;
    uint256 private userCurrentTime;
    address[] private depositeUsers;
    mapping(address => bool) depositers;
    mapping(address => uint256) userDepositeBalances;
    mapping(address => uint256) userPastTime;
    mapping(address => uint256) userDepositePoint;
    
    function isDepositer(address pAddr)internal view returns(bool){
        return depositers[pAddr];
    }
    
    //deposite the usp to the bank contract
    function deposite(uint256 tokens) public returns(bool){
        require(tokens >= 1000000000);
        require(tokens <= user_balances[msg.sender]);
        if(!isDepositer(msg.sender)){
            depositers[msg.sender]=true;
            depositeUsers.push(msg.sender);
        }
        user_balances[msg.sender] -= tokens;
        userDepositeBalances[msg.sender] += tokens;
        usp_bank_balances += tokens;
        if(userPastTime[msg.sender]== 0){
            userPastTime[msg.sender] = block.timestamp;
        }
        return true;
    }
    
    //require account deposite point
    function queryDepositePoint()public view returns(uint point){
        return userDepositePoint[msg.sender];
    }

    //distribute deposite interest by auditor
    function distributeDepositeInterest()public onlyAuditor returns(bool){
        require(loansTotalInterest>0, "no loans interest");
        uint point_total = 0;
        for(uint i=0; i < depositeUsers.length; i++){
            point_total += userDepositePoint[depositeUsers[i]];
        }
        for(uint m=0; m < depositeUsers.length; m++){
            userDepositeBalances[depositeUsers[m]] += (loansTotalInterest *userDepositePoint[depositeUsers[m]] /point_total);
        }
        loansTotalInterest = 0;
        return true;
    }

    //query deposite balance
    function queryDepositeBalance()public view returns(uint256){
        return userDepositeBalances[msg.sender];
    }
    
    //withdrawal the usp from bank
    function withdrawal(uint256 tokens) public returns(bool){
        require(userDepositeBalances[msg.sender] >= tokens);
        userDepositeBalances[msg.sender] -= tokens;
        usp_bank_balances -= tokens;
        user_balances[msg.sender] += tokens;

        return true;
    }
    
    struct loanList{
        uint timestamp;
        uint initialDebt;
        uint mortgage;
        uint debt;
        uint liquidationState;
    }

    uint256 userLoansCurrentTime; 
    uint256 loansTotalInterest;  //every loans provide total interest per day
    uint256 interestMint; 
    address[] private loanUsers; //loan user list
    mapping(address => bool) loaners;
    mapping(address => loanList[]) loanAccount;
    
    //query loan rate
    function loansRate(uint256 tokens)public view returns(uint256){
        governanceInterface getRatio = governanceInterface(governance);
        uint exchange_amount = getOSMValue(unit) * tokens /getOSMValue(usp) *10000 /getRatio.getUSPLoanPledgeRate();
        return exchange_amount;
    }

    function isLoanuser(address pAddr)internal view returns(bool){
        return loaners[pAddr];
    }
    
    //use unit loan the usp
    function loans()public payable returns(uint){
        governanceInterface getRatio = governanceInterface(governance);
        require (msg.value <= (usp_bank_balances *(10000 - getRatio.getUSPReserveRatio()) *getRatio.getUSPLoanPledgeRate() *getOSMValue(usp) /getOSMValue(unit) /100000000), "loan overflow");
        require(msg.value >= 1000000000);
        if(!isLoanuser(msg.sender)){
            loaners[msg.sender]=true;
            loanUsers.push(msg.sender);
        }
        uint loanAmount = loansRate(msg.value);
        loanList memory acc;
        acc.timestamp = block.timestamp;
        acc.initialDebt = loanAmount;
        acc.mortgage = msg.value;
        acc.debt = loanAmount *(10000 + getRatio.getUSPLoanInterestRate()) /10000; 
        acc.liquidationState = 0;
        loanAccount[msg.sender].push(acc);
        usp_bank_balances -= loanAmount;
        user_balances[msg.sender] += loanAmount;
        loansTotalInterest += (loanAmount *getRatio.getUSPLoanInterestRate() /10000); 
        _totalSupply += (loanAmount *getRatio.getUSPLoanInterestRate() /10000);
        interestMint += (loanAmount *getRatio.getUSPLoanInterestRate() /10000);
        return loansTotalInterest;
    }

    //based osm, liquidation by Auditor,state: 0:normal, 1:warning, 2:liquidated or complete the payment
    function liquidation()public onlyAuditor returns(uint){
        //calculate loan interest bu Auditor
        userLoansCurrentTime = block.timestamp;
        governanceInterface getRatio = governanceInterface(governance);
        for(uint a=0; a<loanUsers.length; a++){
            for(uint b=0; b<loanAccount[loanUsers[a]].length; b++){
                uint k = (userLoansCurrentTime - loanAccount[loanUsers[a]][b].timestamp) /2 minutes;
                loanAccount[loanUsers[a]][b].timestamp += k *2 minutes;
                if(loanAccount[loanUsers[a]][b].liquidationState != 2){
                    while(k>0){
                        loansTotalInterest += (loanAccount[loanUsers[a]][b].debt *getRatio.getUSPLoanInterestRate() /10000);
                        interestMint += (loanAccount[loanUsers[a]][b].debt *getRatio.getUSPLoanInterestRate() /10000);
                        _totalSupply += (loanAccount[loanUsers[a]][b].debt *getRatio.getUSPLoanInterestRate() /10000);
                        loanAccount[loanUsers[a]][b].debt += (loanAccount[loanUsers[a]][b].debt *getRatio.getUSPLoanInterestRate() /10000);
                        k--;
                    }
                }
            }
        }
        //calculate everyone deposite point
        for(uint c=0; c<depositeUsers.length; c++){
            userCurrentTime = block.timestamp;
            uint o = (userCurrentTime - userPastTime[depositeUsers[c]]) /2 minutes;
            userDepositePoint[depositeUsers[c]] += userDepositeBalances[depositeUsers[c]] *o;
            userPastTime[depositeUsers[c]] += o *2 minutes;
        }
        //check every account liquidation state
        for(uint m=0; m < loanUsers.length; m++){
            for(uint n=0; n < loanAccount[loanUsers[m]].length; n++){
                if((loanAccount[loanUsers[m]][n]).liquidationState != 2){
                    if(getOSMValue(unit) * (loanAccount[loanUsers[m]][n]).mortgage <= getOSMValue(usp) * (loanAccount[loanUsers[m]][n]).debt *getRatio.getUSPLoanPledgeRateWarningValue() /10000){
                        if(getOSMValue(unit) * (loanAccount[loanUsers[m]][n]).mortgage >= getOSMValue(usp) * (loanAccount[loanUsers[m]][n]).debt *getRatio.getUSPLoanLiquidationRate() /10000){
                            (loanAccount[loanUsers[m]][n]).liquidationState=1;
                        }
                        if(getOSMValue(unit) * (loanAccount[loanUsers[m]][n]).mortgage < getOSMValue(usp) * (loanAccount[loanUsers[m]][n]).debt *getRatio.getUSPLoanLiquidationRate() /10000){
                            (loanAccount[loanUsers[m]][n]).liquidationState=2;
                        }
                    }else{
                            (loanAccount[loanUsers[m]][n]).liquidationState=0;
                    }
                }
            }
        }
        return loansTotalInterest;
    }

    //add acount unit which get warning
    function addLoans(uint number)public payable returns(bool){
        require(loanAccount[msg.sender][number].liquidationState !=2, "your loan is liquidated");
        loanAccount[msg.sender][number].mortgage += msg.value;
        governanceInterface getRatio = governanceInterface(governance);
        if(loanAccount[msg.sender][number].mortgage * getOSMValue(unit) *10000 /getRatio.getUSPLoanPledgeRateWarningValue() >= loanAccount[msg.sender][number].debt * getOSMValue(usp)){
            (loanAccount[msg.sender][number]).liquidationState=0;
        }else{
            (loanAccount[msg.sender][number]).liquidationState=1;
        }
        return true;
    }
    
    //reback acount loan
    function loansBack(uint number, uint tokens)public payable returns(bool){
        require(user_balances[msg.sender] >= tokens, "balance not enough");
        require(loanAccount[msg.sender][number].liquidationState != 2, "your loan is liquidated");
        uint backPercent = 0;
        uint loandebt = 0;
        if(loanAccount[msg.sender][number].debt >= loanAccount[msg.sender][number].initialDebt){
            loandebt = loanAccount[msg.sender][number].debt - loanAccount[msg.sender][number].initialDebt;
            if(loanAccount[msg.sender][number].debt <= tokens){
                user_balances[msg.sender] -= loanAccount[msg.sender][number].debt;
                backPercent = 10000;
                interestMint -= loandebt;
                _totalSupply -= loandebt;
                usp_bank_balances += (tokens - loandebt);
                loanAccount[msg.sender][number].debt = 0;
            }else{
                user_balances[msg.sender] -= tokens;
                backPercent = tokens *10000 /loanAccount[msg.sender][number].debt;
                if((loanAccount[msg.sender][number].debt - loanAccount[msg.sender][number].initialDebt) <= tokens){
                    interestMint -= loandebt;
                    _totalSupply -= loandebt;
                    usp_bank_balances += (tokens - loandebt);
                    loanAccount[msg.sender][number].debt -= tokens;
                }else{
                    interestMint -= tokens;
                    _totalSupply -= tokens;
                    loanAccount[msg.sender][number].debt -= tokens;
                }
            } 
        }else{
            if(loanAccount[msg.sender][number].debt <= tokens){
                user_balances[msg.sender] -= loanAccount[msg.sender][number].debt;
                backPercent = 10000;
                usp_bank_balances += tokens;
                loanAccount[msg.sender][number].debt = 0;
            }else{
                user_balances[msg.sender] -= tokens;
                backPercent = tokens *10000 /loanAccount[msg.sender][number].debt;
                usp_bank_balances += tokens;
                loanAccount[msg.sender][number].debt -= tokens;
            }
        }
        payable(msg.sender).transfer(loanAccount[msg.sender][number].mortgage *backPercent /10000);
        loanAccount[msg.sender][number].mortgage -= (loanAccount[msg.sender][number].mortgage *backPercent /10000);
        if(loanAccount[msg.sender][number].mortgage == 0){
            loanAccount[msg.sender][number].liquidationState = 2;
        }
        return true;
    }
    
    //query acount loan list
    function queryLoan()public view returns(loanList[] memory){
        return loanAccount[msg.sender];
    }
    
    //query OSM value internal function 
    function getOSMValue(string memory currencyName)internal view returns(uint){
        OSMInterface getValue = OSMInterface(OSM);
        require(getValue.getCurrencyValue(currencyName)>0, "OSM value must bigger than zero");
        return getValue.getCurrencyValue(currencyName);
    }
}
