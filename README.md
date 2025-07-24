# Protection Shield Protocol

A decentralized protection system built on the Stacks blockchain using Clarity smart contracts. This protocol enables users to purchase financial protection plans and submit requests for payouts when needed.

## Overview

The Protection Shield Protocol operates as a community-driven protection fund where users can:
- Purchase protection plans by paying fees into a shared treasury
- Submit payout requests up to their coverage limits
- Benefit from transparent, automated claim processing

## Features

- **Flexible Protection Plans**: Choose your own shield amount and protection period
- **Automated Fee Calculation**: Fees are calculated based on coverage amount and duration
- **Transparent Treasury**: All funds are managed on-chain with full visibility
- **Instant Payouts**: Approved requests are processed immediately
- **Admin Controls**: Protocol administrator can establish special plans

## Contract Constants

- **Maximum Shield Amount**: 1,000,000,000 STX
- **Maximum Protection Period**: 52,560 blocks (~1 year)
- **Minimum Fee**: 1,000 microSTX

## Key Functions

### For Users

**`buy-protection(shield-amount, period)`**
- Purchase a protection plan
- Fee = (shield-amount × 1% × period)
- Funds are transferred to the protocol treasury

**`submit-request(request-amount)`**
- Submit a payout request
- Must not exceed your shield amount
- Funds are transferred from treasury to user instantly

### For Admin

**`establish-plan(shield-amount, fee, period)`**
- Admin can create custom protection plans
- Allows for special pricing or terms

### Read-Only Functions

**`get-plan-info(holder)`**
- View protection plan details for any user

**`get-request-info(requester)`**
- View payout request history for any user

**`get-treasury-balance()`**
- Check current treasury balance

## How It Works

1. **Purchase Protection**: Users pay fees based on desired coverage and duration
2. **Build Treasury**: All fees accumulate in the shared protection treasury
3. **Submit Requests**: Protected users can request payouts up to their coverage limit
4. **Instant Payouts**: Valid requests are processed immediately from the treasury

## Data Structure

### Protection Plans
```clarity
{
    shield-amount: uint,    // Maximum coverage amount
    fee: uint,              // Fee paid for protection
    deadline: uint          // Block height when protection expires
}
```

### Protection Requests
```clarity
{
    request-amount: uint,   // Amount requested
    approved: bool          // Request approval status
}
```

## Error Codes

- `u100`: Admin-only function called by non-admin
- `u101`: Invalid payout request (exceeds coverage)
- `u102`: Insufficient funds in treasury
- `u103`: User not protected (no active plan)
- `u104`: Invalid parameters (exceeds limits)

## Security Features

- **Overflow Protection**: Safe arithmetic operations with checks
- **Access Control**: Admin functions restricted to protocol administrator
- **Parameter Validation**: All inputs validated against defined limits
- **Fund Safety**: Treasury balance tracked and verified

## Usage Example

```clarity
;; Purchase protection for 100,000 STX over 1000 blocks
(contract-call? .protection-shield buy-protection u100000 u1000)

;; Submit request for 50,000 STX payout
(contract-call? .protection-shield submit-request u50000)

;; Check your protection plan
(contract-call? .protection-shield get-plan-info tx-sender)
```

## Deployment

Deploy this contract to the Stacks blockchain. The deploying address automatically becomes the protocol administrator with special privileges to establish custom protection plans.

## Important Notes

- Protection plans expire after the specified period
- Users can only have one active protection plan at a time
- Payout requests are processed instantly if treasury has sufficient funds
- All operations are transparent and verifiable on-chain