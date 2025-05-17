;; Agency Verification Contract
;; This contract validates government entities

(define-data-var admin principal tx-sender)

;; Map to store verified agencies
(define-map verified-agencies principal
  {
    name: (string-utf8 100),
    verification-date: uint,
    verification-level: uint,
    active: bool
  }
)

;; Public function to verify a new agency (admin only)
(define-public (verify-agency (agency-principal principal) (agency-name (string-utf8 100)) (verification-level uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-agencies agency-principal
      {
        name: agency-name,
        verification-date: block-height,
        verification-level: verification-level,
        active: true
      }
    ))
  )
)

;; Public function to deactivate an agency (admin only)
(define-public (deactivate-agency (agency-principal principal))
  (let ((agency (unwrap! (map-get? verified-agencies agency-principal) (err u101))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u100))
      (ok (map-set verified-agencies agency-principal
        (merge agency { active: false })
      ))
    )
  )
)

;; Read-only function to check if an agency is verified
(define-read-only (is-verified-agency (agency-principal principal))
  (match (map-get? verified-agencies agency-principal)
    agency (and (get active agency) true)
    false
  )
)

;; Read-only function to get agency details
(define-read-only (get-agency-details (agency-principal principal))
  (map-get? verified-agencies agency-principal)
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
