;; Protection Shield Protocol
;; Constants
(define-constant protocol-admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-invalid-request (err u101))
(define-constant err-insufficient-funds (err u102))
(define-constant err-not-protected (err u103))
(define-constant err-invalid-parameters (err u104))
(define-constant max-shield-amount u1000000000) ;; Maximum shield amount
(define-constant max-protection-period u52560) ;; Maximum protection period (about 1 year in blocks)
(define-constant min-fee u1000) ;; Minimum fee amount

;; Data Maps
(define-map protection-plans
    principal
    {
        shield-amount: uint,
        fee: uint,
        deadline: uint
    })

(define-map protection-requests
    principal
    {
        request-amount: uint, 
        approved: bool
    })

;; Variables
(define-data-var protection-treasury uint u0)

;; Admin Functions
(define-public (establish-plan (shield-amount uint) (fee uint) (period uint))
    (let ((deadline (+ block-height period)))
        (begin
            (asserts! (is-eq tx-sender protocol-admin) err-admin-only)
            (asserts! (<= shield-amount max-shield-amount) err-invalid-parameters)
            (asserts! (>= fee min-fee) err-invalid-parameters)
            (asserts! (<= period max-protection-period) err-invalid-parameters)
            (map-set protection-plans tx-sender
                {
                    shield-amount: shield-amount,
                    fee: fee,
                    deadline: deadline
                })
            (ok true))))

;; User Functions
(define-public (buy-protection (shield-amount uint) (period uint))
    (let 
        ((plan-fee (* shield-amount (/ u1 u100) period))
         (deadline (+ block-height period)))
        (begin
            (asserts! (<= shield-amount max-shield-amount) err-invalid-parameters)
            (asserts! (<= period max-protection-period) err-invalid-parameters)
            (asserts! (>= plan-fee min-fee) err-invalid-parameters)
            
            ;; Safe arithmetic operations with checks
            (asserts! (>= (+ (var-get protection-treasury) plan-fee) 
                         (var-get protection-treasury)) 
                     err-invalid-parameters)
            
            (try! (stx-transfer? plan-fee tx-sender (as-contract tx-sender)))
            (var-set protection-treasury (+ (var-get protection-treasury) plan-fee))
            (map-set protection-plans tx-sender
                {
                    shield-amount: shield-amount,
                    fee: plan-fee,
                    deadline: deadline
                })
            (ok true))))

(define-public (submit-request (request-amount uint))
    (let 
        ((plan (unwrap! (map-get? protection-plans tx-sender) (err err-not-protected))))
        (begin
            (asserts! (<= request-amount (get shield-amount plan)) (err err-invalid-request))
            (asserts! (is-ok (as-contract (stx-transfer? request-amount tx-sender tx-sender))) (err err-insufficient-funds))
            (var-set protection-treasury (- (var-get protection-treasury) request-amount))
            (map-set protection-requests tx-sender
                {
                    request-amount: request-amount,
                    approved: true
                })
            (ok true))))

;; Read-Only Functions
(define-read-only (get-plan-info (holder principal))
    (map-get? protection-plans holder))

(define-read-only (get-request-info (requester principal))
    (map-get? protection-requests requester))

(define-read-only (get-treasury-balance)
    (var-get protection-treasury))