#!/usr/bin/env csi -s 
(import ansi-escape-sequences)
(import chicken.file) ; see also chicken.file.posix
(import chicken.format)
(import chicken.load)
(import chicken.process-context)
(import chicken.process-context.posix)
(import chicken.string) ; string-translate*
(import chicken.time)
(import chicken.time.posix)
(import filepath)
(import shell)
(import simple-loops)
(import srfi-13)
;(import listicles)


; DEFAULTS
;
;
(define my-utc-offset (string->number
											 	(string-translate* (capture "date \"+%z\"") '(
													("\n". "")
													("0" . "")
												))
											 ))
(define my-current-tz (string-translate*
											 (capture "date \"+%Z\"") '(
													("\n". "")
													("0" . "")
												))
	)
(define start-hour-local 9)
(define my-end-hour-local 999) ;won't be used by default
(define end-hour-local 18) ; 24 hr time
(define day-cutover-hour-local 4)
(define start-hour-label (conc "9 " my-current-tz ))
(define end-hour-label (conc "6 " my-current-tz))
;;;
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


(if (and 
		(file-exists? config-file-path)
		(file-readable? config-file-path))
	(load config-file-path)
	(print "Please create days_progress config file\n\tSee README.md for details"))

; now
(define now-epoch (current-seconds))

(define current-utc-hour 
  (if (not (get-environment-variable "DP_TEST_HOUR"))
	(vector-ref (seconds->utc-time now-epoch) 2 )
	(string->number (get-environment-variable "DP_TEST_HOUR"))))

; (printf "DEBUGGING:~% DP_TEST_HOUR: ~A~%" (get-environment-variable "DP_TEST_HOUR"))

(define (utc-offset-converter offset hour)
  (let ((new-hour (+ (* -1 offset) hour)))
	(if (<= new-hour 23)
	  new-hour
	  (- new-hour 24))
	))

(define start-hour 
  (utc-offset-converter my-utc-offset start-hour-local)) 
(define end-hour 
  (utc-offset-converter my-utc-offset end-hour-local)) 
(define my-end-hour
  (utc-offset-converter my-utc-offset my-end-hour-local ))


(define day-cutover-hour
  (if (< day-cutover-hour-local start-hour-local)
  	(utc-offset-converter my-utc-offset day-cutover-hour-local)
	(- start-hour 1)
	))

; dots end 1hr before end-hour, thus +23 and -1
(define iterable-end-hour 
	(if (< end-hour start-hour)
	  (+ end-hour 23)
	  (- end-hour 1)))

; display the start label
(cond 
  ( (and (< current-utc-hour start-hour)
		(> current-utc-hour day-cutover-hour)
		)
	(printf "~A: " (set-text '(fg-red) start-hour-label)))
  ((= current-utc-hour start-hour)
	(printf "~A: " (set-text '(fg-green) start-hour-label)))
  (else 
	(printf "~A: " start-hour-label)))

; display the dots
(do-for iter-hour ((+ start-hour 1) iterable-end-hour 1)
		(let* (	(testable-iter-hour 
					(if (<= iter-hour 23)
					  iter-hour
					  (- iter-hour 24)))
				(hour-string (if (= current-utc-hour testable-iter-hour) "| " ". "))
				(color 
					(if (= testable-iter-hour my-end-hour)
						'(fg-yellow)
						(if (= current-utc-hour testable-iter-hour)
							'(fg-blue)
							'(fg-green)
						  )
					  )
				  )
			   )
			(printf "~A" (set-text color hour-string))
		))

; display the end label
; (printf "DEBUGGING~%start-hour: ~A~%end-hour: ~A~%current-utc-hour: ~A~%day-cutover-hour: ~A~%" start-hour end-hour current-utc-hour day-cutover-hour)
(cond 
  ((> current-utc-hour day-cutover-hour); early, not late
   (printf ":~A" end-hour-label))
  ((> current-utc-hour end-hour)
	(printf ":~A" (set-text '(fg-red) end-hour-label)))
  ((= current-utc-hour end-hour)
	(printf ":~A" (set-text '(fg-green) end-hour-label)))
  (else 
	(printf ":~A" end-hour-label)))

; print start hour utc
; iterate between...
; is current-utc-hour != current iter hour
;  ". "
; else 
;  "| "
; print end hour utc
