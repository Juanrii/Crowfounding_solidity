// SPDX-License-Identifier: GPL-3.0
 pragma solidity >=0.7.0 < 0.9.0;

 contract Crowfounding {
     // Default: Opened (1)
     enum State { Closed, Opened }

     struct Contribution {
         address contributor;
         uint value;
     }

     // Allow multiple projects
     Project[] public projects;

     // Contributions to project
     mapping(string => Contribution[]) contributions;

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

    //  Project public project;
     
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
     event ProjectCreated(
         string id,
         string name,
         string description,
         uint foundraisingGoal
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
     modifier isAuthor(uint projectIndex) {
         require(
             projects[projectIndex].author == msg.sender,
             "Only the author can change the project state"
         );
         _;
     }
      modifier isNotAuthor(uint projectIndex) {
         require(
             projects[projectIndex].author != msg.sender,
             "The author can not add founds"
         );
         _;
     }

     /**
      * Method available for non-authors
      */
     function fundProject(uint projectIndex) public payable isNotAuthor(projectIndex) {
         // Get project by index
         Project memory project = projects[projectIndex];
         // Check if the state is opened
         require(project.state == State.Opened, "The project is Closed.");
         require(msg.value > 0, "Amount must be greather than 0.");
         // Transfer ehters
         project.author.transfer(msg.value);
         // Accumulate founds
         project.founds += msg.value;
         
         projects[projectIndex] = project;

         // Mapping
         contributions[project.id].push(Contribution(msg.sender, msg.value));
         
         // Shoot event, new project!
         emit ProjectFunded(msg.sender, msg.value, project.id, project.name);
     }
     /**
      * The author can change the status
      */
     function changeProjectState(State newState, uint projectIndex) public isAuthor(projectIndex) {
         Project memory project = projects[projectIndex];
         // Avoid invalid states
         require(newState == State.Opened || newState == State.Closed, "Invalid state");
         // Avoid unnecessary change
         require(project.state != newState, "New state must be different");

         project.state = newState;

         projects[projectIndex] = project;

         // Shoot event, updated state!
         emit ProjectStateChanged(project.id, newState);
     }

     function createProject(string calldata id, string calldata name, string calldata description, uint foundraisingGoal) public {
         require(foundraisingGoal > 0, "Foundraising goal must be greater than 0");
         Project memory project = Project(id, name, description, State.Opened, 0, foundraisingGoal, payable(msg.sender), msg.sender);
         projects.push(project);
         emit ProjectCreated(id, name, description, foundraisingGoal);
     }
 }