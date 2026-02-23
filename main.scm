(import (ice-9 rdelim) (ice-9 popen) (ice-9 match) (sxml simple) (web server))

(define (read-string k in)
    (with-output-to-string
        (lambda ()
            (let loop ((n 0))
                (if (= n k) #f (begin (write-char (read-char in)) (loop (+ n 1))))))))
(define (parse p)
    (let loop ()
        (define head (read-line p))
        (cond ((eof-object? head) '())
              (else (let* ((head-port (open-input-string head))
                           (l1 (read head-port))
                           (l2 (read head-port))
                           (s1 (read-string l1 p))
                           (s2 (read-string l2 p)))
                        (cons (list s1 s2) (loop)))))))

(define (fetch)
    (define port
        (open-pipe* OPEN_READ "python" (in-vicinity (dirname (current-filename)) "scratcher.py")))
    (dynamic-wind
        (lambda () #f)
        (lambda () (parse port))
        (lambda () (close-pipe port))))

(define (generate-rss-feed)
    (with-output-to-string
        (lambda ()
            (sxml->xml
                `(rss (@ (version "2.0")) 
                    (channel (title "51") (link "https://51cg.fun/") (description "My favorite porn website")
                        ,@(map 
                            (lambda (p)
                                (match p
                                    ((url title)
                                     `(item (title ,title) (link ,url)))))
                            (fetch))))))))

(define (handler req req-body)
    (values '((content-type . (text/xml)))
            (generate-rss-feed)))

(run-server handler)