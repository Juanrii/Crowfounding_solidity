// SPDX-License-Identifier: GPL-3.0
 pragma solidity >=0.7.0 < 0.9.0;

 contract Crowfounding {
     enum State { Closed, Opened }

     // Allow multiple projects
     Project[] public projects;

     // Contributions to project
     mapping(string => uint) projectFounds;

     struct Project {
        string id;
        string name;
        string description;
        State state; //= 1;  1 - Open, 0 - Closed
        uint founds;
        uint foundraisingGoal;
        address payable author;
        address owner;
     }

     Project public project;
     
     event ProjectFunded(
         address from,
         uint amount,
         string projectId,
         string projectName
     );

     event ProjectStateChanged(
         string id,
         State newState
     );

     error StatusNotDefined(int);
     error StatusIsClosed(int);


     // Deprecated, only allow to add one project
     //constructor(string memory _id, string memory _name, string memory _description, uint _foundraisingGoal) {
         // clean up constructor
         //project = Project(_id, _name, _description, State.Opened, 0, _foundraisingGoal, payable(msg.sender), msg.sender);
         /* 
         id = _id;
         name = _name;
         description = _description;
         foundraisingGoal = _foundraisingGoal;
         author = payable(msg.sender);
         owner = msg.sender;
         */
     //}

     modifier onlyOwner() {
         require(
             project.author == msg.sender,
             "Only the author can change the project state"
         );
         _;
     }

      modifier onlyOthers() {
         require(
             project.author != msg.sender,
             "The author can not add founds"
         );
         _;
     }

     function fundProject() public payable onlyOthers{
         require(project.state == State.Opened, "The project is Closed.");
         require(msg.value > 0, "Amount must be greather than 0.");
         project.author.transfer(msg.value);
         project.founds += msg.value;
         emit ProjectFunded(msg.sender, msg.value, project.id, project.name);
     }

     function changeProjectState(State newState) public onlyOwner{
         require(newState == State.Opened || newState == State.Closed, "Invalid state");
         require(project.state != newState, "New state must be different");
         project.state = newState;
         emit ProjectStateChanged(project.id, newState);
     }

     function createProject() public {

     }
 }