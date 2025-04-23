;; Producer Verification Contract
;; Validates legitimate energy generators

(define-data-var admin principal tx-sender)

;; Map to store verified producers
(define-map verified-producers principal
  {
    name: (string-utf8 100),
    capacity: uint,
    location: (string-utf8 100),
    verified: bool
  }
)

;; Request verification as a producer
(define-public (request-verification (name (string-utf8 100)) (capacity uint) (location (string-utf8 100)))
  (begin
    (asserts! (not (is-some (map-get? verified-producers tx-sender))) (err u1))
    (map-set verified-producers tx-sender
      {
        name: name,
        capacity: capacity,
        location: location,
        verified: false
      }
    )
    (ok true)
  )
)

;; Admin function to verify a producer
(define-public (verify-producer (producer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? verified-producers producer)) (err u404))
    (map-set verified-producers producer
      (merge (unwrap-panic (map-get? verified-producers producer)) {verified: true})
    )
    (ok true)
  )
)

;; Check if a producer is verified
(define-read-only (is-verified-producer (producer principal))
  (match (map-get? verified-producers producer)
    producer-data (ok (get verified producer-data))
    (err u404)
  )
)

;; Get producer details
(define-read-only (get-producer-details (producer principal))
  (map-get? verified-producers producer)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
