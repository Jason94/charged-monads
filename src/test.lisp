(cl:defpackage #:charged-monads/test
  (:use
   #:coalton
   #:coalton-prelude
   #:coalton/monad/identity
   #:coalton/experimental/do-control-core
   #:io/simple-io
   #:io/term
   #:charged-monads
   #:charged-monads/contT
   #:charged-monads/state
   )
  (:import-from #:coalton/string
   #:parse-int))

(cl:in-package #:charged-monads/test)

(cl:defun test1 ()
  (coalton
   (run-io!
    (eval-contT
     (do
      (pt-lift (write "Enter a number: "))
      (input <- (pt-lift read-line))
       (call-cc
        (fn (resume)
          (do
           (let result? = (parse-int input))
           (do-when-match result? (None)
             (pt-lift (write-line "Not a valid number"))
             (resume Unit))
            (do-when-match result? (Some x)
              (do-when (< x 0)
                (pt-lift (write-line "Number less than zero"))
                (resume Unit))
              (pt-lift (write-line "Number >= 0"))))))
       (pure Unit))))))

(coalton-toplevel
  (declare test-shift (Void -> List Integer))
  (define (test-shift)
   (do-reset
     (x <- (shift
            (fn (k)
              (make-list (k 1) (k 2) (k 3)))))
     (pure (* 10 x)))))

(coalton (test-shift))

;; (coalton
;;  (the (List String)
;;       (reset
;;        (pure (make-list "10")))))

        ;; (x <- (shift
        ;;        (fn (k)
        ;;          (make-list (k 1) (k 2) (k 3)))))
        ;; (pure (* x 10)))))

(cl:defun test-st ()
  (coalton
    (run-state 0
      (pt-do
        get
        (modify (fn (x) (<> "100" (show-as-string x))))
        (let y = 10)
        (put y)
        ))))
