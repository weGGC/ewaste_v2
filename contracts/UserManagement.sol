// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagement {
    enum Role { Producer, Recycler, Logistics, Regulator, None }

    struct User {
        string name;
        Role role;
        bool isRegistered;
        uint256 registeredAt;
        string contactInfo;
    }

    mapping(address => User[]) private users;
    address public admin;
    
    // Events
    event UserRegistered(address indexed user, string name, Role role, uint256 timestamp);
    event UserLoggedIn(address indexed user, string name, Role role);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerUser(string memory _name, Role _role, string memory _contactInfo) external {
        // Check if user already has any role
        if (users[msg.sender].length > 0) {
            revert("Account already registered with a role. Multiple roles are not allowed.");
        }
        
        uint256 timestamp = block.timestamp;
        users[msg.sender].push(User(_name, _role, true, timestamp, _contactInfo));
        emit UserRegistered(msg.sender, _name, _role, timestamp);
    }
    
    // Admin function to register a user with a different address
    function registerUserWithAddress(address _userAddress, string memory _name, Role _role, string memory _contactInfo) external onlyAdmin {
        // Check if user already has any role
        if (users[_userAddress].length > 0) {
            revert("Account already registered with a role. Multiple roles are not allowed.");
        }
        
        uint256 timestamp = block.timestamp;
        users[_userAddress].push(User(_name, _role, true, timestamp, _contactInfo));
        emit UserRegistered(_userAddress, _name, _role, timestamp);
    }

    function loginUser(string memory _role) external view returns (string memory, Role, string memory) {
        if (users[msg.sender].length == 0) {
            revert("User not registered.");
        }
        
        Role roleEnum = getRoleFromString(_role);
        User memory user = users[msg.sender][0];
        
        if (user.role != roleEnum) {
            revert("User is not registered with this role.");
        }
        
        return (user.name, user.role, user.contactInfo);
    }

    function getUserCount(address _user) external view returns (uint) {
        return users[_user].length;
    }

    function getUserRole(address _user) public view returns (Role) {
        if (users[_user].length > 0) {
            return users[_user][0].role; // Returns the only role for the user
        }
        return Role.None; // Return None if no role is found
    }

    function getUserByRole(address _user, string memory _role) external view returns (string memory, Role, string memory) {
        if (users[_user].length == 0) {
            revert("User not registered.");
        }
        
        Role roleEnum = getRoleFromString(_role);
        User memory user = users[_user][0];
        
        if (user.role != roleEnum) {
            revert("User is not registered with this role.");
        }
        
        return (user.name, user.role, user.contactInfo);
    }

    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        address oldAdmin = admin;
        admin = _newAdmin;
        emit AdminChanged(oldAdmin, _newAdmin);
    }

    function getRoleFromString(string memory _role) private pure returns (Role) {
        if (keccak256(bytes(_role)) == keccak256(bytes("Producer"))) {
            return Role.Producer;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Recycler"))) {
            return Role.Recycler;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Logistics"))) {
            return Role.Logistics;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Regulator"))) {
            return Role.Regulator;
        } else {
            return Role.None;
        }
    }
}