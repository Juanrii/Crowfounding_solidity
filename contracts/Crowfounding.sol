// SPDX-License-Identifier: GPL-3.0
 pragma solidity >=0.7.0 < 0.9.0;

 contract Crowfounding {
     // Default: Opened (1)
     enum State { Closed, Opened }

     // Allow multiple projects
     Project[] public projects;

     // Contributions to project
     mapping(string => uint) projectFounds;

     struct Project {
        string id;
        string name;
        string description;
        State state;
        uint founds;
        uint foundraisingGoal;
        address payable author;
        address owner;
     }

     Project public project;
     
     // Events
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

     // Handle errors
     error StatusNotDefined(int);
     error StatusIsClosed(int);

     /* Deprecated, now we create multiple projects
     constructor(string memory _id, string memory _name, string memory _description, uint _foundraisingGoal) {
         // clean up constructor
         project = Project(_id, _name, _description, State.Opened, 0, _foundraisingGoal, payable(msg.sender), msg.sender);
         
        //  id = _id;
        //  name = _name;
        //  description = _description;
        //  foundraisingGoal = _foundraisingGoal;
        //  author = payable(msg.sender);
        //  owner = msg.sender;   
     }*/

     // Modifiers. Restrictions!
     modifier isAuthor() {
         require(
             project.author == msg.sender,
             "Only the author can change the project state"
         );
         _;
     }
      modifier isNotAuthor() {
         require(
             project.author != msg.sender,
             "The author can not add founds"
         );
         _;
     }

     /**
      * Method available for non-authors
      */
     function fundProject() public payable isNotAuthor {
         // Check if the state is opened
         require(project.state == State.Opened, "The project is Closed.");
         require(msg.value > 0, "Amount must be greather than 0.");
         // Transfer ehters
         project.author.transfer(msg.value);
         // Accumulate founds
         project.founds += msg.value;
         
         // Shoot event, new project!
         emit ProjectFunded(msg.sender, msg.value, project.id, project.name);
     }
     /**
      * The author can change the status
      */
     function changeProjectState(State newState) public isAuthor {
         // Avoid invalid states
         require(newState == State.Opened || newState == State.Closed, "Invalid state");
         // Avoid unnecessary change
         require(project.state != newState, "New state must be different");

         project.state = newState;
         // Shoot event, updated state!
         emit ProjectStateChanged(project.id, newState);
     }

     function createProject() public {
         // TODO: Implement method for create multiple projects. 
         // Use Project[] array and mapping.
     }
 }