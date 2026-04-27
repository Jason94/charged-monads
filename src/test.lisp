(cl:defpackage #:indexed-monads/test
  (:use
   #:coalton
   #:coalton-prelude
   #:coalton/monad/identity
   #:indexed-monads
   #:indexed-monads/contT
   ))

(cl:in-package #:indexed-monads/test)

(coalton
 (eval-cont
  (do
   (pure "1"))))
