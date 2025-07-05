;; Data Sharing Contract
;; Enables secure research data exchange with access controls

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ACCESS_DENIED (err u403))
(define-constant ERR_INVALID_PERMISSION (err u400))

;; Data Variables
(define-data-var data-entry-counter uint u0)
(define-data-var access-request-counter uint u0)

;; Data Maps
(define-map research-data
  { data-id: uint }
  {
    title: (string-ascii 200),
    description: (string-ascii 1000),
    data-hash: (string-ascii 64),
    owner: principal,
    data-type: (string-ascii 50),
    size-bytes: uint,
    upload-block: uint,
    access-level: (string-ascii 20),
    license-type: (string-ascii 50),
    citation-required: bool
  }
)

(define-map data-permissions
  { data-id: uint, user: principal }
  {
    permission-type: (string-ascii 20),
    granted-by: principal,
    grant-block: uint,
    expiry-block: uint,
    is-active: bool
  }
)

(define-map access-requests
  { request-id: uint }
  {
    data-id: uint,
    requester: principal,
    purpose: (string-ascii 500),
    request-block: uint,
    status: (string-ascii 20),
    reviewed-by: (optional principal),
    review-block: (optional uint)
  }
)

(define-map researcher-data
  { researcher: principal }
  {
    owned-data: (list 100 uint),
    shared-data: (list 100 uint),
    accessed-data: (list 100 uint)
  }
)

;; Read-only functions
(define-read-only (get-research-data (data-id uint))
  (map-get? research-data { data-id: data-id })
)

(define-read-only (get-data-permissions (data-id uint) (user principal))
  (map-get? data-permissions { data-id: data-id, user: user })
)

(define-read-only (get-access-request (request-id uint))
  (map-get? access-requests { request-id: request-id })
)

(define-read-only (get-researcher-data (researcher principal))
  (map-get? researcher-data { researcher: researcher })
)

(define-read-only (can-access-data (data-id uint) (user principal))
  (let
    (
      (data-info (map-get? research-data { data-id: data-id }))
      (permission (map-get? data-permissions { data-id: data-id, user: user }))
    )
    (match data-info
      data-record
        (if (is-eq (get owner data-record) user)
          true
          (match permission
            perm-record
              (and (get is-active perm-record)
                   (or (is-eq (get expiry-block perm-record) u0)
                       (> (get expiry-block perm-record) block-height)))
            false))
      false)
  )
)

;; Public functions
(define-public (upload-data
  (title (string-ascii 200))
  (description (string-ascii 1000))
  (data-hash (string-ascii 64))
  (data-type (string-ascii 50))
  (size-bytes uint)
  (access-level (string-ascii 20))
  (license-type (string-ascii 50))
  (citation-required bool))
  (let
    (
      (data-id (+ (var-get data-entry-counter) u1))
      (current-block block-height)
    )
    (map-set research-data
      { data-id: data-id }
      {
        title: title,
        description: description,
        data-hash: data-hash,
        owner: tx-sender,
        data-type: data-type,
        size-bytes: size-bytes,
        upload-block: current-block,
        access-level: access-level,
        license-type: license-type,
        citation-required: citation-required
      }
    )
    (map-set data-permissions
      { data-id: data-id, user: tx-sender }
      {
        permission-type: "admin",
        granted-by: tx-sender,
        grant-block: current-block,
        expiry-block: u0,
        is-active: true
      }
    )
    (let
      (
        (current-researcher-data (default-to
          { owned-data: (list), shared-data: (list), accessed-data: (list) }
          (map-get? researcher-data { researcher: tx-sender })))
      )
      (map-set researcher-data
        { researcher: tx-sender }
        (merge current-researcher-data {
          owned-data: (unwrap-panic (as-max-len? (append (get owned-data current-researcher-data) data-id) u100))
        })
      )
    )
    (var-set data-entry-counter data-id)
    (ok data-id)
  )
)

(define-public (request-data-access (data-id uint) (purpose (string-ascii 500)))
  (let
    (
      (request-id (+ (var-get access-request-counter) u1))
      (data-info (unwrap! (map-get? research-data { data-id: data-id }) ERR_NOT_FOUND))
      (current-block block-height)
    )
    (asserts! (not (is-eq tx-sender (get owner data-info))) ERR_INVALID_PERMISSION)
    (map-set access-requests
      { request-id: request-id }
      {
        data-id: data-id,
        requester: tx-sender,
        purpose: purpose,
        request-block: current-block,
        status: "pending",
        reviewed-by: none,
        review-block: none
      }
    )
    (var-set access-request-counter request-id)
    (ok request-id)
  )
)

(define-public (grant-data-access
  (data-id uint)
  (user principal)
  (permission-type (string-ascii 20))
  (expiry-blocks uint))
  (let
    (
      (data-info (unwrap! (map-get? research-data { data-id: data-id }) ERR_NOT_FOUND))
      (current-block block-height)
      (expiry-block (if (> expiry-blocks u0) (+ current-block expiry-blocks) u0))
    )
    (asserts! (is-eq tx-sender (get owner data-info)) ERR_UNAUTHORIZED)
    (map-set data-permissions
      { data-id: data-id, user: user }
      {
        permission-type: permission-type,
        granted-by: tx-sender,
        grant-block: current-block,
        expiry-block: expiry-block,
        is-active: true
      }
    )
    (let
      (
        (user-data (default-to
          { owned-data: (list), shared-data: (list), accessed-data: (list) }
          (map-get? researcher-data { researcher: user })))
      )
      (map-set researcher-data
        { researcher: user }
        (merge user-data {
          accessed-data: (unwrap-panic (as-max-len? (append (get accessed-data user-data) data-id) u100))
        })
      )
    )
    (ok true)
  )
)

(define-public (revoke-data-access (data-id uint) (user principal))
  (let
    (
      (data-info (unwrap! (map-get? research-data { data-id: data-id }) ERR_NOT_FOUND))
      (permission (unwrap! (map-get? data-permissions { data-id: data-id, user: user }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get owner data-info)) ERR_UNAUTHORIZED)
    (map-set data-permissions
      { data-id: data-id, user: user }
      (merge permission { is-active: false })
    )
    (ok true)
  )
)

(define-public (review-access-request (request-id uint) (approve bool))
  (let
    (
      (request (unwrap! (map-get? access-requests { request-id: request-id }) ERR_NOT_FOUND))
      (data-info (unwrap! (map-get? research-data { data-id: (get data-id request) }) ERR_NOT_FOUND))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender (get owner data-info)) ERR_UNAUTHORIZED)
    (map-set access-requests
      { request-id: request-id }
      (merge request {
        status: (if approve "approved" "rejected"),
        reviewed-by: (some tx-sender),
        review-block: (some current-block)
      })
    )
    (if approve
      (grant-data-access (get data-id request) (get requester request) "read" u0)
      (ok true))
  )
)
