# TwPay KES API Testing Guide

## Table of Contents
- [USSD Charge (STK Push)](#1-ussd-charge-stk-push)
- [Single Transfer (B2C Payout)](#2-single-transfer-b2c-payout)
- [Validation Rules](#validation-rules)
- [Error Scenarios](#error-scenarios)
- [Testing Checklist](#testing-checklist)

---

**Base URL (MerchantIntegration):** `https://localhost:{port}/api/v1/pay`

### Channel Codes

| Code    | Provider     |
|---------|--------------|
| `63902` | M-PESA       |
| `63903` | Airtel Money |
| `63907` | T-KASH       |
| `0`     | SasaPay      |

---

### 1. USSD Charge (STK Push)

Triggers an STK Push prompt on the customer's phone to collect payment.

**Endpoint:** `POST /api/v1/pay/ussd-charge`

#### Request Body

| Field            | Type     | Required | Description                                                   |
|------------------|----------|----------|---------------------------------------------------------------|
| `transactionRef` | `string` | Yes      | Unique reference (alphanumeric, hyphens, underscores, spaces) |
| `customerEmail`  | `string` | Yes      | Customer email address                                        |
| `amount`         | `decimal`| Yes      | Amount to charge (must be > 0)                                |
| `currency`       | `string` | Yes      | `"KES"`                                                       |
| `bankAccount`    | `string` | Yes      | Channel code (see table above)                                |
| `phoneNumber`    | `string` | Yes      | Customer phone in `254...` format                             |
| `fullName`       | `string` | No       | Customer full name                                            |

---

#### Sample: M-PESA STK Push
```json
POST /api/v1/pay/ussd-charge

{
  "transactionRef": "TXN-MPESA-001",
  "customerEmail": "customer@example.com",
  "amount": 100.00,
  "currency": "KES",
  "bankAccount": "63902",
  "phoneNumber": "254712345678",
  "fullName": "Jane Wanjiku"
}
```

**Expected Response:**
```json
{
  "status": true,
  "message": "MPESA STK sent. Enter your PIN",
  "data": {
    "transactionRef": "TXN-MPESA-001",
    "responseCode": "0",
    "paymentId": "a4184244-7c47-4e2e-951f-5344f58b216e"
  }
}
```

---

#### Sample: Airtel Money STK Push
```json
POST /api/v1/pay/ussd-charge

{
  "transactionRef": "TXN-AIRTEL-001",
  "customerEmail": "customer@example.com",
  "amount": 200.00,
  "currency": "KES",
  "bankAccount": "63903",
  "phoneNumber": "254733456789",
  "fullName": "Peter Ochieng"
}
```

---

#### Sample: T-KASH STK Push
```json
POST /api/v1/pay/ussd-charge

{
  "transactionRef": "TXN-TKASH-001",
  "customerEmail": "customer@example.com",
  "amount": 150.00,
  "currency": "KES",
  "bankAccount": "63907",
  "phoneNumber": "254720123456",
  "fullName": "Mary Akinyi"
}
```

---

#### Sample: SasaPay STK Push
```json
POST /api/v1/pay/ussd-charge

{
  "transactionRef": "TXN-SASA-001",
  "customerEmail": "customer@example.com",
  "amount": 50.00,
  "currency": "KES",
  "bankAccount": "0",
  "phoneNumber": "254712345678",
  "fullName": "Jane Wanjiku"
}
```

---

### 2. Single Transfer (B2C Payout)

Sends money from the merchant SasaPay account to a mobile money number.

**Endpoint:** `POST /api/v1/pay/single-transfer`

#### Request Body

| Field           | Type     | Required | Description                                                   |
|-----------------|----------|----------|---------------------------------------------------------------|
| `bankAccount`   | `string` | Yes      | Channel code (see table above)                                |
| `accountNumber` | `string` | Yes      | Recipient phone number in `254...` format                     |
| `accountName`   | `string` | Yes      | Recipient name                                                |
| `amount`        | `decimal`| Yes      | Amount to transfer (must be > 0)                              |
| `description`   | `string` | Yes      | Purpose of transfer                                           |
| `currency`      | `string` | Yes      | `"KES"`                                                       |
| `reference`     | `string` | Yes      | Unique reference (alphanumeric, hyphens, underscores, spaces) |
| `narration`     | `string` | No       | Additional notes                                              |

> **Note:** Ensure your SasaPay merchant account (MerchantCode: `678787`) has sufficient balance. Fund it via C2B STK Push collection first, then use Internal Fund Movement to move funds from Working Account to Utility Account.

---

#### Sample: M-PESA B2C Payout
```json
POST /api/v1/pay/single-transfer

{
  "bankAccount": "63902",
  "accountNumber": "254712345678",
  "accountName": "Jane Wanjiku",
  "amount": 1000.00,
  "description": "Salary disbursement",
  "currency": "KES",
  "reference": "PAY-KES-001",
  "narration": "March salary"
}
```

**Expected Response:**
```json
{
  "status": true,
  "message": "Transfer initiated successfully",
  "data": {
    "reference": "PAY-KES-001",
    "transactionId": "TXN-xxxx-xxxx",
    "amount": 1000.00,
    "currency": "KES",
    "accountNumber": "254712345678",
    "accountName": "Jane Wanjiku",
    "bankAccount": "63902",
    "transferStatus": "pending"
  }
}
```

---

#### Sample: Airtel Money B2C Payout
```json
POST /api/v1/pay/single-transfer

{
  "bankAccount": "63903",
  "accountNumber": "254733456789",
  "accountName": "Peter Ochieng",
  "amount": 500.00,
  "description": "Refund",
  "currency": "KES",
  "reference": "PAY-KES-002"
}
```

---

#### Sample: SasaPay B2C Payout
```json
POST /api/v1/pay/single-transfer

{
  "bankAccount": "0",
  "accountNumber": "254712345678",
  "accountName": "Mary Akinyi",
  "amount": 250.00,
  "description": "Commission payout",
  "currency": "KES",
  "reference": "PAY-KES-003",
  "narration": "Q1 commission"
}
```

---

## Validation Rules

| Field            | Rule                                                          |
|------------------|---------------------------------------------------------------|
| `transactionRef` | `^[a-zA-Z0-9-_\s]*$` — alphanumeric, `-`, `_`, spaces       |
| `reference`      | `^[a-zA-Z0-9-_\s]*$` — alphanumeric, `-`, `_`, spaces       |
| `customerEmail`  | `^[a-zA-Z0-9@_.\s]*$` — basic email chars                   |
| `amount`         | `^[1-9]\d*(\.\d+)?$` — positive number, no leading zero     |

## Error Scenarios

| Scenario                        | HTTP | Response Message                          |
|---------------------------------|------|-------------------------------------------|
| Missing required field          | 400  | `"One or more validation errors occurred"` |
| Invalid amount (0 or negative)  | 400  | `"Amount must be greater than 0"`          |
| Invalid reference characters    | 400  | `"Reference contains invalid characters"`  |
| SasaPay insufficient balance    | 400  | `"Insufficient balance to send KES X.XX"`  |
| Provider timeout                | 408  | `"Request timed out"`                      |
| Integration service unreachable | 500  | `"An error occurred processing request"`   |

---

## Testing Checklist

### USSD Charge (STK Push)
- [ ] M-PESA (`63902`) → STK Push sent to phone
- [ ] Airtel Money (`63903`) → STK Push sent
- [ ] T-KASH (`63907`) → STK Push sent
- [ ] SasaPay (`0`) → STK Push sent
- [ ] Missing `transactionRef` → 400 validation error
- [ ] Invalid amount `0` → 400 validation error
- [ ] Missing `phoneNumber` → verify behavior

### Single Transfer (B2C Payout)
- [ ] M-PESA B2C (`63902`) → B2C initiated via SasaPay
- [ ] Airtel Money B2C (`63903`) → B2C initiated
- [ ] SasaPay B2C (`0`) → B2C initiated
- [ ] Missing `currency` → 400 validation error
- [ ] Invalid `reference` with special chars → 400 validation error
- [ ] Insufficient SasaPay balance → 400 with balance error

---

## SasaPay Configuration

```
BaseUrl:      https://api.sasapay.app
MerchantCode: 678787
Auth Route:   /api/v1/auth/token/
C2B Route:    /api/v1/payments/request-payment/
B2C Route:    /api/v1/payments/b2c/
```
