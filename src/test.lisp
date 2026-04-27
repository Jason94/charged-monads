(cl:defpackage #:indexed-monads/test
  (:use
   #:coalton
   #:coalton-prelude
   #:coalton/monad/identity
   #:coalton/experimental/do-control-core
   #:io/simple-io
   #:io/term
   #:indexed-monads
   #:indexed-monads/contT
   )
  (:import-from #:coalton/string
   #:parse-int))

(cl:in-package #:indexed-monads/test)

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
    (pure Unit)))))
