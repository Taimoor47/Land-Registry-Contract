//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract LandBuySell{
    
    struct landregistry {

        string Area;
        string City;
        string State;
        uint LandPrice ;
        uint PropertyPID;
    }

      struct RegisterBuyer{

        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        
    }

      struct RegisterSeller{

        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        
    }


    struct landInspectorDetails{

        string Name;
        uint Age;
        string Designation;

    }

    //Veriables

     address public LandInspector;
     address private sellerId;
     address private buyerId;
     uint private LandId;


    //Mappings
 
    mapping(uint => landregistry) public LandDetails;
    mapping(uint => address) public LandOwner;
    mapping(uint => bool) private RegisterdLand;
    mapping(address => RegisterBuyer) public BuyerDetails;
    mapping(address => bool) public RegisterdBuyer;
    mapping(address => bool) public IsBuyerVerifeid;
    mapping(address => bool) public BuyerRejected;
    mapping(address => RegisterSeller) public SellerDetails;
    mapping(address => bool) public SellerRejected;
    mapping(address => bool) public IsSellerVerified;
    mapping(uint => bool) public Landverified;
    mapping(address => bool) public RegisterdSeller;


    // Landinspector Constructor

       constructor()public{
        LandInspector = msg.sender;
    }

    // Seller Registration, Verification & Rejection functions. Only verified seller can add the Land.
    //Only LandInspector (Contract Deployer) can verify or reject seller,Buyer and Land.
    //You Can check Seller Details. 
    // (Function will not allow to buyer and seller to Register on same address)

        function SellerRegistration(string memory _name,uint _age,string memory _city,uint _cnic,string memory _email)public{
        require(!RegisterdBuyer[msg.sender] == true, "This address rigesterd as a Buyer");
        RegisterdSeller[msg.sender] = true;
        SellerDetails[msg.sender]= RegisterSeller(_name,_age,_city,_cnic,_email);
    }

    //You can check if seller verified or rejected
        function verifySeller(address sellerId)public{
        require(LandInspector == msg.sender && RegisterdSeller[sellerId] );

        IsSellerVerified[sellerId] = true;
        SellerRejected[sellerId] = false;
    }

    function RejectSeller(address sellerId)public{
        require(LandInspector == msg.sender);

         SellerRejected[sellerId] = true;
         IsSellerVerified[sellerId] = false;
    }

    //Only Registered Seller can Upadte.

     function updateSeller(string memory _name,uint _age,string memory _city,uint _cnic,string memory _email)public{
        require(RegisterdSeller[msg.sender] == true, "Seller is Not Registered");
        SellerDetails[msg.sender].Name = _name;
        SellerDetails[msg.sender].Age = _age;
        SellerDetails[msg.sender].City = _city;
        SellerDetails[msg.sender].CNIC = _cnic;
        SellerDetails[msg.sender].Email = _email;
    }
     
    //Only Verified Seller can Register Land
    //Land Functions Defined
    //Anyone can check the current land owner and land details.

    function LandRegistration(uint id,string memory _area,string memory _state,string memory _city,uint _landPrice,uint _propertyPID)public{
        require(IsSellerVerified[msg.sender] == true, "You May not Registered or Verifed");
        RegisterdLand[id] = true;
        LandDetails[id]= landregistry(_area,_state,_city,_landPrice,_propertyPID);
        LandOwner[id] = msg.sender;
    }

    //Only Registered land is verifiable. (Only LandInspector can verify the Land by LandId)

    function verifyLand(uint LandId)public {
        require(LandInspector == msg.sender && RegisterdLand[LandId], 
        "Only LandInspector can verify to Registered Land" );
        Landverified[LandId] = true;
    }

    //Buyer functions. Only Verified Buyer can buy verifed Land. You Can check Buyer's Details
    // (Function will not allow to buyer and seller to Register on same address)
    
    function BuyerRigestration(string memory _name,uint _age,string memory _city,uint _cnic,string memory _email)public{
        require(!RegisterdSeller[msg.sender] == true, "This Address Registered as a Seller");
        RegisterdBuyer[msg.sender] = true;
        BuyerDetails[msg.sender]= RegisterBuyer(_name,_age,_city,_cnic,_email);
    }

    //You can check if buyer is verified or rejected

    function verifyBuyer(address buyerId) public {
        require(LandInspector == msg.sender && RegisterdBuyer[buyerId], 
         "Only LandInspector can verify the Registered Buyer" );
        IsBuyerVerifeid[buyerId] = true;
        BuyerRejected[buyerId] = false;
    }

    function RejectBuyer(address buyerId) public {
        require(LandInspector == msg.sender, "Only LandInspector can reject");
         BuyerRejected[buyerId] = true;
         IsBuyerVerifeid[buyerId] = false;
    }

     function UpdateBuyer(string memory _name,uint _age,string memory _city,uint _cnic,string memory _email)public{
        require(RegisterdBuyer[msg.sender] == true, "Only Registered Buyer can Upadate");
        BuyerDetails[msg.sender].Name = _name;
        BuyerDetails[msg.sender].Age = _age;
        BuyerDetails[msg.sender].City = _city;
        BuyerDetails[msg.sender].CNIC = _cnic;
        BuyerDetails[msg.sender].Email = _email;
    }

    //Land purchase and payment function. Verified Buyer can buy verified land.
    // To buy land just put the land id and land price and the amount automatically
    //  will transferd to seller's address and land ownership will change to seller to buyr's address.
    //function will not allow to pay less amount then land price.
 
    function BuyLand(uint Id) public payable{
        require(Landverified[Id] == true && IsBuyerVerifeid[msg.sender] == true, 
        "May Land or Buyer is not Verified");
        require( msg.value/1**18  >= LandDetails[Id].LandPrice, "You don't have enough amount to buy");
        payable(LandOwner[Id]).transfer(msg.value);
        LandOwner[Id] = msg.sender;
    }

    //transfer Ownership function allow seller/land owner to transfer his ownership to desirable address.

    function TransferOwnership(uint _LnadId,address NewOwner)public{
        require(Landverified[_LnadId] == true , "Land is not verified");
        require(LandOwner[_LnadId] == msg.sender, "You are not the Owner");
        LandOwner[_LnadId] = NewOwner;

    }

    //By fowllowing functions you can check Land city, Area, and Price.


    function getLandCity(uint id) public view returns(string memory){
        return LandDetails[id].City;
    }

    function getLandArea(uint id) public view returns(string memory){
        
        return LandDetails[id].Area;
        
    }
    function GetPrice(uint id) public view returns(uint){
        return LandDetails[id].LandPrice;
    }

}


