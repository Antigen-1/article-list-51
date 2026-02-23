#!/bin/env guile3.0
!#
(import (ice-9 rdelim) (ice-9 popen) (ice-9 match) (ice-9 getopt-long) (ice-9 threads) (sxml simple) (web server) (srfi srfi-28) (srfi srfi-18))

(define (port-string? x) (exact-integer? (read (open-input-string x))))
(define option-spec
    `((port (single-char #\p) (value #t) (predicate ,port-string?))
      (driver (single-char #\d) (value #t) (required? #f))))
(define options (getopt-long (command-line) option-spec))
(define port (option-ref options 'port #f))
(define port-number (read (open-input-string port)))
(define driver (option-ref options 'driver #f))

(define (directory-exists? p)
    (and (file-exists? p) (eq? (stat:type (stat p)) 'directory)))

(define pwd (dirname (current-filename)))
(define venv (in-vicinity pwd "scratcher"))
(define python (in-vicinity venv (in-vicinity "bin" "python3")))
(if (directory-exists? venv)
    #f
    (system* "python3" "-m" "venv" venv))
(system* python "-m" "pip" "install" "-I" "selenium")

(define (read-string k in)
    (with-output-to-string
        (lambda ()
            (let loop ((n 0))
                (if (= n k) #f (begin (write-char (read-char in)) (loop (+ n 1))))))))
(define (string->values str)
    (define in (open-input-string str))
    (let loop ()
        (define v (read in))
        (if (eof-object? v) '() (cons v (loop)))))
(define (parse p)
    (define amount (read (open-input-string (read-line p))))
    (let loop ((n 0))
        (cond ((= n amount) '())
              (else (cons (map (lambda (v) (read-string v p)) (string->values (read-line p))) (loop (+ n 1)))))))

(define (fetch)
    (define in
        (apply open-pipe* OPEN_READ python (in-vicinity pwd "scratcher.py") (if driver (list "-d" driver) '())))
    (dynamic-wind
        (lambda () #f)
        (lambda () (parse in))
        (lambda () (close-pipe in))))

; Cache
(define records (fetch))
(define time (time->seconds (current-time)))
(define sep 3600)
(define update-thread
    (make-thread
        (lambda ()
            (if (>= (- (time->seconds (current-time)) time) sep)
                (begin (set! time (current-time))
                       (set! records (fetch))))
            records)))

(define (generate-rss-feed)
    (with-output-to-string
        (lambda ()
            (sxml->xml
                `(rss (@ (version "2.0")) 
                    (channel (title "51") (link "https://51cg.fun/") (description "My favorite porn website") (ttl 60)
                        ,@(map 
                            (lambda (p)
                                (match p
                                    ((url title date)
                                     `(item (title ,title) (link ,url) (pubDate ,date)))))
                            records)))))))

(define (handler req req-body)
    (values '((content-type . (text/xml)))
            (generate-rss-feed)))

(run-server handler 'http `(#:port ,port-number))