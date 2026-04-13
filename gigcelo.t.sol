// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../src/gigcelo.sol";
import "../src/MockERC20.sol";
import  "forge-std/Test.sol";

contract testGigcelo is Test{
    
    Gigcelo gig;
    MockERC20 token;
    address owner = address(1);
    address creator = address(2);
    address worker = address(3);


    function setUp() public{
        vm.startPrank(owner);
        token = new MockERC20();
        gig = new Gigcelo(address(token));

        vm.stopPrank();

        token.mint(creator,100 ether);
    }

    function testCreateTask() public {
        vm.startPrank(creator);

        gig.createTask("Kill Tinubu", 20 ether);

        //(uint256 id,string memory description,uint256 reward ,address taskCreator,,,) = gig.tasks(1);
        (uint256 id,string memory description,uint256 reward,address taskCreator,address worker,bool isCompleted,bool isApproved) = gig.tasks(1);
        //Gigcelo.Task memory task = gig.tasks(1);
    
    vm.stopPrank();

    assertEq(id,1);
    assertEq(description,"Kill Tinubu");
    assertEq(reward,20 ether);
    assertEq(taskCreator,creator);
    }

    function testFundTask() public {
    vm.prank(creator);
    gig.createTask("Task", 10 ether);
    token.mint(creator,10 ether);

    vm.startPrank(creator);
    token.approve(address(gig), 10 ether);
    gig.fundTask(1);
    vm.stopPrank();

    assertEq(token.balanceOf(address(gig)), 10 ether);
}
}
