// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;


import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Presale is OwnableUpgradeable {

    mapping(address => uint256) _userInfo;
    mapping(address => bool) _whitelistInfo;
    address [1000000] _users;
    address _owner;
    address private _tokenAddr; 
    uint256 private _softCap;
    uint256 private _hardCap;
    uint256 private _startTime;
    uint256 private _endTime;
    uint256 private _count;
    uint256 private _maxBid;
    uint256 private _minBid;
    uint256 private _tokenRate;
    bool private _isCanceled;
    uint8 _type;
    bool private _whitelisting;
    bool private _public;
    
    uint256 private _publicTime;

    modifier IsAvailable (uint256 price_) {
        require( price_ >= _minBid && price_ <= _maxBid, "Invalid Number" );
        _;
    }

    modifier IsBid (address userAddr_) {
        require( _userInfo[userAddr_] == 0, "You should bid only once" );
        _;
    }

    modifier IsNotCanceled() {
        require( _isCanceled == false, "Presale is finished" );
        _;
    }

    modifier IsCanceled() {
        require(_isCanceled == true, "Presale is not finished");
        _;
    }

    modifier checkWhitelist(address userAddr_) {
        if(_whitelisting == true) {
            require(_whitelistInfo[userAddr_] == true, "You are not in Whitelist");
            _;
        } else {
            _;
        }
    }

    modifier IsWhitelist() { 
        require(_whitelisting == true, "Whitelist didn't set");
        _;
    }

    modifier IsPublic() {
        require(_public == true, "Public didn't set");
        _;
    }

    modifier IsNotPublic() {
        require(_public == false, "Public already set");
        _;
    }

    constructor(
        uint256 softCap_, uint256 hardCap_, uint256 startTime_, uint256 tokenRate_, address tokenAddr_
    ) {
        _softCap = softCap_;
        _hardCap = hardCap_;
        _startTime = startTime_;
        _tokenRate = tokenRate_;
        _tokenAddr = tokenAddr_;
        _isCanceled = false;
    }

    function initialize(address owner_, uint256 softCap_, uint256 hardCap_, uint256 max_, uint256 min_, uint256 startTime_, uint256 endTime_, uint256 tokenRate_, address tokenAddr_, bool isWhitelist) external initializer {
        _softCap = softCap_;
        _hardCap = hardCap_;
        _startTime = startTime_;
        _endTime = endTime_;
        _tokenRate = tokenRate_;
        _tokenAddr = tokenAddr_;
        _public = true;
        _isCanceled = false;
        _maxBid = max_;
        _minBid = min_;
        _whitelisting = isWhitelist;
        OwnableUpgradeable.__Ownable_init();
        transferOwnership(owner_);
    }

    function Bid() public payable checkWhitelist(msg.sender) IsNotCanceled IsAvailable(msg.value) {
        if(_userInfo[msg.sender] > 0) {
            _userInfo[msg.sender] += msg.value;
        } else {
            _users[ _count ] = msg.sender;
            _userInfo[ msg.sender ] = msg.value;
            _count ++;
        }
    }

    function Finalize() public IsNotCanceled onlyOwner {
        // payable(serviceFeeReceiver_).transfer(serviceFee_);
        payable(msg.sender).transfer(address(this).balance);
        ERC20 tok = ERC20(_tokenAddr);
        for(uint256 i = 0 ; i < _count ; i ++) {
            tok.transferFrom(address(this), _users[i], _userInfo[_users[i]] * _tokenRate / (10 ** 18));
        }
        _isCanceled = true;
    }

    function Cancel() public IsNotCanceled onlyOwner {
//        ERC20 tok = ERC20(_tokenAddr);
        for(uint256 i = 0 ; i < _count ; i ++) {
            payable(_users[i]).transfer(_userInfo[_users[i]]);
        }
        _count = 0;
        _isCanceled = true;
    }

    function withdraw() public IsCanceled onlyOwner {
        ERC20 tok = ERC20(_tokenAddr);
        tok.transferFrom(address(this), _owner, tok.balanceOf(address(this)));
    }

    function checkPresale() public view onlyOwner returns (uint8) {
        uint256 balance = address(this).balance;
        if(balance < _softCap) {
            return 0;
        }
        if(balance >= _hardCap) {
            return 2;
        }
        return 1;
    }

    function getStartTime() public view virtual returns(uint256) {
        return _startTime;
    }

    function getEndTime() public view virtual returns(uint256) {
        return _endTime;
    }

    function getUserState(address userAddr_) public view virtual returns(bool) {
        if(_userInfo[userAddr_] != 0) return false;
        return true;
    }

    function getTotalSupply() public view virtual returns(uint256) {
        return address(this).balance;
    }

    function getTokenTotalSupply() public view virtual returns(uint256) {
        return ERC20(_tokenAddr).totalSupply();
    }

    function setRange(uint256 min_, uint256 max_) public onlyOwner{
        _minBid = min_;
        _maxBid = max_;
    }

    function setWhitelist() public onlyOwner {
        _whitelisting = true;
        _public = false;
    }

    function disableWhitelist() public IsWhitelist onlyOwner {
        _whitelisting = false;
    }
    
    function addWhitelistAddr(address user) public IsWhitelist onlyOwner {
        _whitelistInfo[user] = true;
    }
    
    function addWhitelistAddrArray(address[] memory user) public IsWhitelist onlyOwner {
        for(uint i = 0 ; i < user.length ; i ++) {
            addWhitelistAddr(user[i]);
        }
    }

    function removeWhitelistAddr(address user) public onlyOwner {
        require(_whitelistInfo[user] == true, "User not found");
        _whitelistInfo[user] = false;
    }

    function removeWhitelistAddrArray(address[] memory user) public IsWhitelist onlyOwner {
        for(uint i = 0 ; i < user.length ; i ++) {
            removeWhitelistAddr(user[i]);
        }
    }

    function setPublic(uint256 date_) public IsNotPublic onlyOwner {
        _public = true;
        _whitelisting = false;
        _publicTime = date_;
    }

    function setDisablePublic() public IsPublic onlyOwner {
        _public = false;
    }

    function getIsWhitelist() public view virtual returns (bool) {
        return _whitelisting;
    }
}