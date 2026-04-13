// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IERC20{
    function transfer(address to,uint256 amount) external returns( bool);
    function transferFrom( address from, address to, uint256 amount) external returns (bool);
    }

contract Gigcelo{
    IERC20 public cUSD;
    address public owner;

    struct Task{
        uint256 id;
        string description;
        uint256 reward;
        address creator;
        address worker;
        bool isCompleted;
        bool isApproved;
    }

    uint256 public taskIdCount;
    mapping(uint256 => Task) public tasks;

modifier onlyOwner() {
    require (msg.sender == owner,"Not owner");
    _;
}
constructor(address _cUSD){
    cUSD = IERC20(_cUSD);
    owner = msg.sender;
}
event TaskCreated(uint256 id,string description,uint256 reward );
event TaskFunded(uint256 id, uint256 amount);
event TaskSubmitted(uint256 id,address worker);
event PayApproved(uint256 id, address worker, uint256 amount);

function createTask(string memory _description, uint _reward) external{
    taskIdCount++;
    tasks[taskIdCount] = Task({
        id:taskIdCount,
        description:_description,
        reward: _reward,
        creator:msg.sender,
        worker:address(0),
        isCompleted: false,
        isApproved: false
    });
    emit TaskCreated(taskIdCount,_description,_reward);

}

function fundTask(uint256 _taskId) external {
    Task storage task = tasks[_taskId];
    require(task.reward > 0,"Invalid task");
    require(cUSD.transferFrom(msg.sender, address(this), task.reward),"Transfer Failed");

    emit TaskFunded(_taskId,task.reward);

}

function submitTask(uint256 _taskId) external{
    require(_taskId > 0, "Invalid task");
    Task storage task = tasks[_taskId];

    require(!task.isCompleted,"Already completed");

    task.worker = msg.sender;
    task.isCompleted = true;

emit TaskSubmitted(_taskId, msg.sender);
}


function approvePay(uint256 _taskId) external onlyOwner{
    require(_taskId > 0, "Invalid Id");
    Task storage task = tasks[_taskId];

    require(task.isCompleted,"Not Completed");
    require(!task.isApproved,"Already Approved"); 
    require(task.worker != address(0),"Invalid Worker");

    task.isApproved = true;

    require(cUSD.transfer(task.worker,task.reward),"Payment Failed");

    emit PayApproved(_taskId, task.worker,task.reward);

}
}