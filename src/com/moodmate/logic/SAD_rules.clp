; Rule to detect severe SAD pattern
(defrule assess-severe-sad
    (declare (salience 75))
    ; Depressive pattern
    (emotional-pattern (user_id ?id) 
                      (day ?e_day)
                      (pattern-type "depressive")
                      (intensity "severe")
                      (persistence ?p1&:(> ?p1 5)))  ; Persists more than 5 days
    ; Poor weather conditions
    (daily-weather (user_id ?id)
                  (day ?w_day)
                  (condition ?c&:(or (eq ?c "cloudy") (eq ?c "rainy"))))
    (test (= ?e_day ?w_day))
    (not (sad-assessment (user_id ?id)))
=>
    (assert (sad-assessment
        (user_id ?id)
        (risk-level "high")
        (evidence (str-cat "Severe depressive pattern during " ?c " weather persisting over 5 days"))
        (recommendation "Clinical evaluation recommended for Seasonal Affective Disorder"))))

; Rule to detect moderate SAD risk
(defrule assess-moderate-sad
    (declare (salience 74))
    ; Depressive or apathy pattern
    (or (emotional-pattern (user_id ?id) 
                          (day ?e_day)
                          (pattern-type "depressive")
                          (intensity "moderate"))
        (emotional-pattern (user_id ?id)
                          (day ?e_day)
                          (pattern-type "apathy")
                          (persistence ?p&:(> ?p 3))))
    ; Poor weather conditions
    (daily-weather (user_id ?id)
                  (day ?w_day)
                  (condition ?c&:(or (eq ?c "cloudy") (eq ?c "rainy"))))
    (test (= ?e_day ?w_day))
    (not (sad-assessment (user_id ?id)))
=>
    (assert (sad-assessment
        (user_id ?id)
        (risk-level "moderate")
        (evidence (str-cat "Moderate mood changes during " ?c " weather"))
        (recommendation "Monitor mood patterns and consider light therapy"))))

; Rule to detect weather sensitivity
(defrule assess-weather-sensitivity
    (declare (salience 74))
    ; Mood changes correlating with weather
    (daily-weather (user_id ?id)
                  (day ?w_day)
                  (condition "cloudy"))
    (daily-emotion-summary (user_id ?id)
                          (day ?e_day)
                          (emotion-name "sad")
                          (avg-percentage ?s&:(> ?s 40)))
    (test (= ?e_day ?w_day))
    (not (sad-assessment (user_id ?id)))
=>
    (assert (sad-assessment
        (user_id ?id)
        (risk-level "low")
        (evidence "Increased sadness during cloudy weather")
        (recommendation "Consider tracking mood-weather patterns and maintaining regular outdoor activity"))))

; Rule to print SAD assessment remains the same
(defrule print-sad-assessment
    (declare (salience 73))
    ?assessment <- (sad-assessment (user_id ?id)
                                 (risk-level ?risk)
                                 (evidence ?ev)
                                 (recommendation ?rec))
=>
    (printout t crlf "=== Seasonal Affective Disorder Assessment ===" crlf)
    (printout t "Risk Level: " ?risk crlf)
    (printout t "Evidence: " ?ev crlf)
    (printout t "Recommendation: " ?rec crlf)
    (printout t "==========================================" crlf))