;; Consumer Identity Contract
;; Manages energy user profiles

(define-data-var admin principal tx-sender)

;; Map to store consumer profiles
(define-map consumers principal
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    max-consumption: uint,
    active: bool
  }
)

;; Register as a consumer
(define-public (register-consumer (name (string-utf8 100)) (location (string-utf8 100)) (max-consumption uint))
  (begin
    (asserts! (not (is-some (map-get? consumers tx-sender))) (err u1))
    (map-set consumers tx-sender
      {
        name: name,
        location: location,
        max-consumption: max-consumption,
        active: true
      }
    )
    (ok true)
  )
)

;; Update consumer profile
(define-public (update-consumer-profile (name (string-utf8 100)) (location (string-utf8 100)) (max-consumption uint))
  (begin
    (asserts! (is-some (map-get? consumers tx-sender)) (err u404))
    (map-set consumers tx-sender
      {
        name: name,
        location: location,
        max-consumption: max-consumption,
        active: true
      }
    )
    (ok true)
  )
)

;; Deactivate consumer account
(define-public (deactivate-consumer)
  (begin
    (asserts! (is-some (map-get? consumers tx-sender)) (err u404))
    (map-set consumers tx-sender
      (merge (unwrap-panic (map-get? consumers tx-sender)) {active: false})
    )
    (ok true)
  )
)

;; Admin function to deactivate a consumer
(define-public (admin-deactivate-consumer (consumer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? consumers consumer)) (err u404))
    (map-set consumers consumer
      (merge (unwrap-panic (map-get? consumers consumer)) {active: false})
    )
    (ok true)
  )
)

;; Check if a consumer is active
(define-read-only (is-active-consumer (consumer principal))
  (match (map-get? consumers consumer)
    consumer-data (ok (get active consumer-data))
    (err u404)
  )
)

;; Get consumer details
(define-read-only (get-consumer-details (consumer principal))
  (map-get? consumers consumer)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
