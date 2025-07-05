;; Funding Distribution Contract
;; Allocates grants based on merit and review scores

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_AMOUNT (err u400))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_ROUND_CLOSED (err u403))

;; Data Variables
(define-data-var funding-round-counter uint u0)
(define-data-var total-funding-pool uint u0)
(define-data-var min-score-threshold uint u6) ;; Minimum average score of 6/10

;; Data Maps
(define-map funding-rounds
  { round-id: uint }
  {
    total-budget: uint,
    allocated-amount: uint,
    remaining-budget: uint,
    start-block: uint,
    end-block: uint,
    status: (string-ascii 20)
  }
)

(define-map funding-allocations
  { allocation-id: uint }
  {
    round-id: uint,
    proposal-id: uint,
    researcher: principal,
    amount-allocated: uint,
    allocation-block: uint,
    disbursement-status: (string-ascii 20)
  }
)

(define-map researcher-funding
  { researcher: principal }
  {
    total-received: uint,
    active-grants: (list 10 uint),
    completed-projects: uint
  }
)

(define-data-var allocation-counter uint u0)

;; Read-only functions
(define-read-only (get-funding-round (round-id uint))
  (map-get? funding-rounds { round-id: round-id })
)

(define-read-only (get-funding-allocation (allocation-id uint))
  (map-get? funding-allocations { allocation-id: allocation-id })
)

(define-read-only (get-researcher-funding (researcher principal))
  (map-get? researcher-funding { researcher: researcher })
)

(define-read-only (get-total-funding-pool)
  (var-get total-funding-pool)
)

(define-read-only (get-funding-round-counter)
  (var-get funding-round-counter)
)

;; Public functions
(define-public (create-funding-round (budget uint) (duration-blocks uint))
  (let
    (
      (round-id (+ (var-get funding-round-counter) u1))
      (current-block block-height)
      (end-block (+ current-block duration-blocks))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (> budget u0) ERR_INVALID_AMOUNT)
    (map-set funding-rounds
      { round-id: round-id }
      {
        total-budget: budget,
        allocated-amount: u0,
        remaining-budget: budget,
        start-block: current-block,
        end-block: end-block,
        status: "active"
      }
    )
    (var-set funding-round-counter round-id)
    (var-set total-funding-pool (+ (var-get total-funding-pool) budget))
    (ok round-id)
  )
)

(define-public (allocate-funding
  (round-id uint)
  (proposal-id uint)
  (researcher principal)
  (amount uint))
  (let
    (
      (allocation-id (+ (var-get allocation-counter) u1))
      (funding-round (unwrap! (map-get? funding-rounds { round-id: round-id }) ERR_NOT_FOUND))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status funding-round) "active") ERR_ROUND_CLOSED)
    (asserts! (<= current-block (get end-block funding-round)) ERR_ROUND_CLOSED)
    (asserts! (>= (get remaining-budget funding-round) amount) ERR_INSUFFICIENT_FUNDS)
    (map-set funding-allocations
      { allocation-id: allocation-id }
      {
        round-id: round-id,
        proposal-id: proposal-id,
        researcher: researcher,
        amount-allocated: amount,
        allocation-block: current-block,
        disbursement-status: "allocated"
      }
    )
    (map-set funding-rounds
      { round-id: round-id }
      (merge funding-round {
        allocated-amount: (+ (get allocated-amount funding-round) amount),
        remaining-budget: (- (get remaining-budget funding-round) amount)
      })
    )
    (let
      (
        (researcher-info (default-to
          { total-received: u0, active-grants: (list), completed-projects: u0 }
          (map-get? researcher-funding { researcher: researcher })))
      )
      (map-set researcher-funding
        { researcher: researcher }
        {
          total-received: (+ (get total-received researcher-info) amount),
          active-grants: (unwrap-panic (as-max-len? (append (get active-grants researcher-info) allocation-id) u10)),
          completed-projects: (get completed-projects researcher-info)
        }
      )
    )
    (var-set allocation-counter allocation-id)
    (ok allocation-id)
  )
)

(define-public (update-disbursement-status (allocation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (allocation (unwrap! (map-get? funding-allocations { allocation-id: allocation-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set funding-allocations
      { allocation-id: allocation-id }
      (merge allocation { disbursement-status: new-status })
    )
    (ok true)
  )
)

(define-public (close-funding-round (round-id uint))
  (let
    (
      (funding-round (unwrap! (map-get? funding-rounds { round-id: round-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set funding-rounds
      { round-id: round-id }
      (merge funding-round { status: "closed" })
    )
    (ok true)
  )
)

(define-public (set-min-score-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (and (<= new-threshold u10) (>= new-threshold u1)) ERR_INVALID_AMOUNT)
    (var-set min-score-threshold new-threshold)
    (ok true)
  )
)
