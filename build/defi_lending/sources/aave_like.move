module deployer_addr::aave_like {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::timestamp;

    struct LendingPool<phantom CoinType> has key {
        total_deposits: u64,
        total_borrows: u64,
        interest_rate: u64,
    }

    struct UserAccount<phantom CoinType> has key {
        deposits: u64,
        borrows: u64,
        last_update_timestamp: u64,
    }

    const E_NOT_INITIALIZED: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_INSUFFICIENT_COLLATERAL: u64 = 3;

    public fun initialize_pool<CoinType>(account: &signer) {
        let pool = LendingPool<CoinType> {
            total_deposits: 0,
            total_borrows: 0,
            interest_rate: 500, // 5% annual interest rate (in basis points)
        };
        move_to(account, pool);
    }

    public entry fun deposit<CoinType>(account: &signer, amount: u64) acquires LendingPool, UserAccount {
        let account_addr = signer::address_of(account);
        
        // Transfer coins from user to the protocol
        let coins = coin::withdraw<CoinType>(account, amount);
        coin::deposit(signer::address_of(account), coins);

        // Update pool state
        let pool = borrow_global_mut<LendingPool<CoinType>>(signer::address_of(account));
        pool.total_deposits = pool.total_deposits + amount;

        // Update user account
        if (!exists<UserAccount<CoinType>>(account_addr)) {
            move_to(account, UserAccount<CoinType> {
                deposits: 0,
                borrows: 0,
                last_update_timestamp: timestamp::now_seconds(),
            });
        };
        let user_account = borrow_global_mut<UserAccount<CoinType>>(account_addr);
        user_account.deposits = user_account.deposits + amount;
        user_account.last_update_timestamp = timestamp::now_seconds();
    }

    public entry fun borrow<CoinType>(account: &signer, amount: u64) acquires LendingPool, UserAccount {
        let account_addr = signer::address_of(account);
        let pool = borrow_global_mut<LendingPool<CoinType>>(signer::address_of(account));
        
        assert!(pool.total_deposits >= amount, E_INSUFFICIENT_BALANCE);
        
        // Check if user has sufficient collateral (simplified)
        let user_account = borrow_global_mut<UserAccount<CoinType>>(account_addr);
        assert!(user_account.deposits * 2 >= user_account.borrows + amount, E_INSUFFICIENT_COLLATERAL);

        // Update pool state
        pool.total_borrows = pool.total_borrows + amount;

        // Update user account
        user_account.borrows = user_account.borrows + amount;
        user_account.last_update_timestamp = timestamp::now_seconds();

        // Transfer coins to the borrower
        let coins = coin::withdraw<CoinType>(account, amount);
        coin::deposit(account_addr, coins);
    }

    public entry fun repay<CoinType>(account: &signer, amount: u64) acquires LendingPool, UserAccount {
        let account_addr = signer::address_of(account);
        
        // Transfer coins from user to the protocol
        let coins = coin::withdraw<CoinType>(account, amount);
        coin::deposit(signer::address_of(account), coins);

        // Update pool state
        let pool = borrow_global_mut<LendingPool<CoinType>>(signer::address_of(account));
        pool.total_borrows = pool.total_borrows - amount;

        // Update user account
        let user_account = borrow_global_mut<UserAccount<CoinType>>(account_addr);
        assert!(user_account.borrows >= amount, E_INSUFFICIENT_BALANCE);
        user_account.borrows = user_account.borrows - amount;
        user_account.last_update_timestamp = timestamp::now_seconds();
    }

    public entry fun withdraw<CoinType>(account: &signer, amount: u64) acquires LendingPool, UserAccount {
        let account_addr = signer::address_of(account);
        let pool = borrow_global_mut<LendingPool<CoinType>>(signer::address_of(account));
        
        assert!(pool.total_deposits >= amount, E_INSUFFICIENT_BALANCE);
        
        // Check if user has sufficient deposits
        let user_account = borrow_global_mut<UserAccount<CoinType>>(account_addr);
        assert!(user_account.deposits >= amount, E_INSUFFICIENT_BALANCE);

        // Update pool state
        pool.total_deposits = pool.total_deposits - amount;

        // Update user account
        user_account.deposits = user_account.deposits - amount;
        user_account.last_update_timestamp = timestamp::now_seconds();

        // Transfer coins to the user
        let coins = coin::withdraw<CoinType>(account, amount);
        coin::deposit(account_addr, coins);
    }
}