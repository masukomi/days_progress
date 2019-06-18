#!/usr/bin/env csi -s 
(import chicken.format)
(import chicken.time)
(import chicken.time.posix)
(import chicken.process-context.posix)
(import chicken.file) ; see also chicken.file.posix
(import chicken.load)
(import filepath)
(import srfi-13)
(import simple-loops)
(import ansi-escape-sequences)
;(import listicles)


; DEFAULTS
(define my-utc-offset -4) ; EDT because... *shrug* had to pick something
(define start-hour-local 9)
(define end-hour-local 18) ; 24 hr time
(define start-hour-label "9 EDT")
(define end-hour-label "6 PST")
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
(define current-utc-hour  (vector-ref (seconds->utc-time now-epoch) 2 ))


(define (utc-offset-converter offset hour)
  (+ (* -1 offset) hour))

(define start-hour 
  (utc-offset-converter my-utc-offset start-hour-local)) 
(define end-hour 
  (utc-offset-converter my-utc-offset end-hour-local)) 

(cond 
  ((< current-utc-hour start-hour)
	(printf "~A: " (set-text '(fg-red) start-hour-label)))
  ((= current-utc-hour start-hour)
	(printf "~A: " (set-text '(fg-green) start-hour-label)))
  (else 
	(printf "~A: " start-hour-label)))


(do-for iter-hour ((+ start-hour 1) (- end-hour 1) 1)
		(if (and 
			  (>= current-utc-hour start-hour)
			  (<= current-utc-hour end-hour))
			(if (= current-utc-hour iter-hour)
			  (printf "~A " (set-text '(fg-blue) "|"))
			  (printf "~A " (set-text '(fg-green) "."))

			  )))
(cond 
  ((> current-utc-hour end-hour)
	(printf ":~A" (set-text '(fg-red) end-hour-label)))
  ((= current-utc-hour end-hour)
	(printf ":~A" (set-text '(fg-green) end-hour-label)))
  (else 
	(printf ":~A " end-hour-label)))

; print start hour utc
; iterate between...
; is current-utc-hour != current iter hour
;  ". "
; else 
;  "| "
; print end hour utc
