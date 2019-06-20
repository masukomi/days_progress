#!/usr/bin/env csi -s 

(import chicken.format)
(import chicken.process)
(import chicken.process-context)
(import chicken.process-context.posix)
(import chicken.irregex)
(import shell)
(import srfi-13)
(import test)

(import filepath)

(define home (vector-ref
							(list->vector 
							  (user-information
								(current-user-id))) 5))

(define config-file-path (string-join 
						   (list
							  home
							  ".config"
							  "days_progress"
							  "days_progress_config.scm")
								(make-string 1 (filepath:path-separator)  )))
(define backup-config-file-path (string-concatenate (list config-file-path ".bak")))

(printf "backing up ~A ~%to ~A~%~%" 
	   config-file-path
	   backup-config-file-path
	   )

; todo
; mv config-file-path to backup-config-file-path
; TODO: CORRECT THIS vvv isn't evaluating variables 
(system (string-join (list 
					 "mv" config-file-path backup-config-file-path)
				   " "))
; cp ./days_progress_config.scm to config-file-path
(system (string-join (list 
					"cp" "days_progress_config.scm" config-file-path)
				  " "))
; (print "recompiling (non-static)...")
; (run (csc days_progress.scm))
; tells days_progress that the current UTC hour is 
; whatever hour you pass in, then runs it and captures the output
(define (capture-for-hour hour)
	(set-environment-variable! "DP_TEST_HOUR" (number->string hour))
	(capture (csi -s days_progress.scm)))
(define (capture-for-hour-no-esc hour)
	(irregex-replace/all '(: "\x1b[" (+ digit) "m" )
						 (capture-for-hour hour) "")
  )
; test docs here: http://wiki.call-cc.org/eggref/5/test

(test "just dots (before start ignore color)" "9 EDT: . . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 4))

(test "start hour" "9 EDT: . . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 13))
(test "10 AM" "9 EDT: | . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 14)) ; 14 UTC=10 EDT

; test that when the hour is in the middle of the day 
; there is a bar in the correct place
(test "3 PM" "9 EDT: . . . . . | . . . . :6 PDT"
	  (capture-for-hour-no-esc 19)) ; 19 UTC=15 EDT

(test "end hour" "9 EDT: . . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 1)) ; 1 UTC=6 PDT=9 EDT

(test "working too early (ignore color)" "9 EDT: . . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 9)) ; cutoff is 4 start is 13
(test "working too early (w/ color)" "\x1b[31m9 EDT\x1b[0m: \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m :6 PDT"
	  (capture-for-hour 9)) ; cutoff is 4 start is 13

(test "working too late (ignore color)" "9 EDT: . . . . . . . . . . :6 PDT"
	  (capture-for-hour-no-esc 2)) ; end is 1 cutoff is 4 start is 13

(test "working too late (w/ color)"
	  "9 EDT: \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m \x1b[32m.\x1b[0m :\x1b[31m6 PDT\x1b[0m"
	  (capture-for-hour 2)) ; end is 1 cutoff is 4 start is 13



(test-exit)
