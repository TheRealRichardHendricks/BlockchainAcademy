// Blockchain academy module 3

pragma solidity >= 0.4.22 < 0.6.0; 

contract ICOCampaign {
    
    address payable contractOwner;
    uint public campaignDuration;  // u blokovima se meri vreme
    uint public campaignGoal;      // koliki nam je cilj da sakupimo (ako se ne naglasi skupljaju se weii... 1 ether = 10^21 wei)
    uint public currentlyRaised;   // koliko smo skupili do sada (in wei)
    
    struct ContributorStruct {
        address payable contributor;
        uint amount;
    }
    
    constructor (uint duration, uint _campaignGoal) public payable {
        contractOwner = msg.sender;
        campaignDuration = block.number + duration; 
        campaignGoal = _campaignGoal;
    }
    
    ContributorStruct[] public contributorStructs;  // niz kontribjutora...jer naravno vise ljudi ulaze
    
    function contributeETH() public payable returns(bool isSuccessful) {
        
        if (msg.sender == contractOwner) return false; // da ne bi mogli sami sebi da uplacujemo pare
        currentlyRaised += msg.value;
        ContributorStruct memory newContributor;    // trosi manje gasa nego da ga skladistimo na blockchainu
        newContributor.contributor = msg.sender;
        newContributor.amount = msg.value;
        contributorStructs.push(newContributor);
    }  
    
    function withdrawFunds() public payable returns(bool isSuccessful) {
        
        if (msg.sender == contractOwner) return false;
        if (isSuccess()) return false;              // ako je kampanja zavrsena ne mozemo da uradimo withdraw
        uint ethToReturn = address(this).balance;   // balance je integer i zato mora da se kastuje u konkretnu adresu na koju cemo slati sredstva
        address(contractOwner).transfer(ethToReturn);
        return true;
    }
    
    function isSuccess() public view returns(bool isDone) {
        // view ne trosi gas za razliku od constant
        
        if (currentlyRaised >= campaignGoal)
            return true;
    }
    
    function returnFunds() public payable returns(bool success) {
        
        if (msg.sender != contractOwner) { revert(); }
        if (hasFailed()) { revert(); }
        uint contributorCount = contributorStructs.length;
        
        for(uint i=0; i<contributorCount-1; i++) {
            contributorStructs[i].contributor.transfer(contributorStructs[i].amount);
        }
        
        return true;
    }
    
    function hasFailed() public view returns(bool success) {
        
        bool hasFailed = (currentlyRaised < campaignGoal) && (block.number > campaignDuration);
        return hasFailed;
    }
 
}
