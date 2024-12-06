; Rule to check sleep factors for secondary analysis
(defrule check-sleep-factors
    (declare (salience 86))
    (need-second-factors (user_id ?id) (need TRUE))
    (sleepiness (user_id ?id) (sleepy TRUE))
=>
    (printout t crlf "Checking sleep factors for secondary analysis..." crlf))

; Rule to analyze sleep quality when user is sleepy
(defrule analyze-sleep-quality
    (declare (salience 85))
    (sleepiness (user_id ?id) (sleepy TRUE))
    ?sleep <- (sleep-quality (user_id ?id) 
                          (satisfaction ?sat)
                          (sleep-time ?st)
                          (wake-time ?wt)
                          (sleep-decimal ?sd)
                          (wake-decimal ?wd))
    (not (sleep-score-calculated (user_id ?id)))
=>
    ; Calculate duration considering 24-hour cycle
    (bind ?duration 
        (if (< ?wd ?sd)
            then (+ (- 24 ?sd) ?wd)
            else (- ?wd ?sd)))
    
    ; Calculate satisfaction score (0-40 points)
    (bind ?satisfaction-score (* (/ ?sat 3) 40))
    
    ; Calculate duration score (0-40 points)
    (bind ?duration-score
        (if (< ?duration 6) 
            then 20
            else (if (< ?duration 7)
                    then 30
                    else (if (<= ?duration 9)
                            then 40
                            else 25))))
    
    ; Calculate timing score (0-20 points)
    (bind ?timing-score
        (if (and (>= ?sd 22.0) (<= ?sd 23.5)
                 (>= ?wd 6.0) (<= ?wd 7.5))
            then 20
            else (if (and (>= ?sd 21.0) (<= ?sd 24.0)
                         (>= ?wd 5.0) (<= ?wd 8.0))
                    then 15
                    else 10)))
    
    ; Calculate midpoint
    (bind ?midpoint 
        (if (< ?wd ?sd)
            then (/ (+ (- 24 ?sd) ?wd) 2)
            else (/ (+ ?sd ?wd) 2)))
    
    ; Calculate midpoint score (0-20 points)
    (bind ?midpoint-score
        (if (and (>= ?midpoint 3.0) (<= ?midpoint 4.0))
            then 20
            else (if (and (>= ?midpoint 2.5) (<= ?midpoint 4.5))
                    then 15
                    else 10)))
    
    ; Calculate total score
    (bind ?total-score (round (+ ?satisfaction-score ?duration-score ?timing-score ?midpoint-score)))
    
    ; Finalize analysis and assert score message
    (modify ?sleep (score ?total-score))
    (assert (sleep-score-calculated (user_id ?id)))
    (assert (sleep-recommendation 
        (user_id ?id)
        (message (str-cat "Your sleep score is " ?total-score " out of 100."))))
    (printout t "Sleep analysis completed. Total score: " ?total-score crlf))

; Rule when user is not sleepy
(defrule analyze-non-sleepy
    (declare (salience 84))
    (sleepiness (user_id ?id) (sleepy FALSE))
=>
    (assert (sleep-recommendation 
        (user_id ?id)
        (message "Your alertness is good. Keep maintaining your current sleep schedule.")))
    (printout t "Sleep Analysis Complete" crlf))

; Rule to generate a single focused recommendation
(defrule generate-sleep-recommendation
    (declare (salience 74))  
    ?sleep <- (sleep-quality (user_id ?id) 
                          (satisfaction ?sat)
                          (sleep-time ?st)
                          (wake-time ?wt)
                          (sleep-decimal ?sd)
                          (wake-decimal ?wd)
                          (score ?total-score))
    (sleep-score-calculated (user_id ?id))  
=>
    ; Calculate duration considering 24-hour cycle
    (bind ?duration 
        (if (< ?wd ?sd)
            then (+ (- 24 ?sd) ?wd)
            else (- ?wd ?sd)))
            
    ; Calculate midpoint
    (bind ?midpoint 
        (if (< ?wd ?sd)
            then (/ (+ (- 24 ?sd) ?wd) 2)
            else (/ (+ ?sd ?wd) 2)))

    ; Set recommendation based on highest priority issue
    (bind ?message
        (if (< ?duration 6) 
            then "Try getting at least 7 hours of sleep by going to bed an hour earlier."
            else (if (> ?duration 9) 
                    then "Consider reducing your sleep duration to 8 hours for optimal energy levels."
                    else (if (not (and (>= ?sd 21.0) (<= ?sd 24.0) (>= ?wd 5.0) (<= ?wd 8.0)))
                            then "Adjust your sleep schedule to go to bed between 22:00-23:00 and wake up between 6:00-7:00."
                            else (if (< (* (/ ?sat 3) 40) 30)
                                    then "Improve your sleep quality by maintaining a consistent bedtime routine and optimizing your sleep environment."
                                    else (if (not (and (>= ?midpoint 3.0) (<= ?midpoint 4.0)))
                                            then "Shift your sleep schedule to achieve a mid-sleep time between 3:00-4:00 AM for better circadian alignment."
                                            else (if (>= ?total-score 75)
                                                    then "Your sleep patterns are excellent - maintain your current routine."
                                                    else "Focus on maintaining consistent sleep and wake times while following good sleep hygiene practices.")))))))

    ; Assert the main recommendation
    (assert (sleep-recommendation 
        (user_id ?id)
        (message ?message)))

    ; Print the recommendations
    (printout t crlf "Sleep Recommendations:" crlf)
    (printout t ?message crlf))