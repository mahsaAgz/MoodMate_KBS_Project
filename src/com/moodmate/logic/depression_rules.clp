; Rule to detect severe persistent depression
(defrule assess-severe-depression
    (declare (salience 75))
    ; Find persistent severe depressive pattern
    (emotional-pattern (user_id ?id) 
                      (pattern-type "depressive")
                      (intensity "severe")
                      (persistence ?p1&:(>= ?p1 14)))  ; Two weeks minimum
    ?old-assessment <- (depression-assessment (user_id ?id))  ; Find existing assessment
=>
    (modify ?old-assessment  ; Update existing instead of asserting new
        (risk-level "severe")
        (confidence 95)        ; High confidence due to long persistence
        (evidence (str-cat "Severe depressive pattern persisting for " ?p1 " days"))
        (recommendation "Immediate clinical evaluation needed - Major Depressive Episode indicated")))
        
; Rule to detect persistent moderate depression
(defrule assess-persistent-moderate-depression
    (declare (salience 75))
    ; Find persistent moderate depressive pattern for at least 10 days
    (emotional-pattern (user_id ?id) 
                      (pattern-type "depressive")
                      (intensity "moderate")
                      (persistence ?p1&:(>= ?p1 10)))
    (not (depression-assessment (user_id ?id)))
=>
    (assert (depression-assessment
        (user_id ?id)
        (risk-level "high")
        (confidence (min 90 (+ 70 (* ?p1 2))))  ; Confidence increases with persistence
        (evidence (str-cat "Moderate depressive pattern persisting for " ?p1 " days"))
        (recommendation "Clinical evaluation recommended - Persistent depressive symptoms require assessment"))))

; Rule to detect early depression signs
(defrule assess-early-depression
    (declare (salience 74))
    ; Find shorter duration but significant patterns
    (emotional-pattern (user_id ?id)
                      (pattern-type "depressive")
                      (intensity ?i&:(or (eq ?i "moderate") (eq ?i "severe")))
                      (persistence ?p1&:(and (>= ?p1 3) (< ?p1 7))))  ; 3-7 days
    (not (depression-assessment (user_id ?id)))
=>
    (assert (depression-assessment
        (user_id ?id)
        (risk-level "moderate")
        (confidence (+ 50 (* ?p1 5)))  ; Base confidence plus 5% per day
        (evidence (str-cat "Early depression warning signs for " ?p1 " days"))
        (recommendation "Consider clinical consultation if symptoms persist - Monitor closely"))))
; Rule to print depression assessment
(defrule print-depression-assessment
    (declare (salience 73))
    ?assessment <- (depression-assessment (user_id ?id)
                                        (risk-level ?risk)
                                        (confidence ?conf)
                                        (evidence ?ev)
                                        (recommendation ?rec))
=>
    (printout t crlf "=== Depression Risk Assessment ===" crlf)
    (printout t "Risk Level: " ?risk crlf)
    (printout t "Confidence: " ?conf "%" crlf)
    (printout t "Evidence: " ?ev crlf)
    (printout t "Recommendation: " ?rec crlf)
    (printout t "===================================" crlf))