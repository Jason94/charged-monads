(defpackage :charged-monads/tests/state
  (:use #:coalton #:coalton-prelude #:coalton-testing
        #:charged-monads
        #:charged-monads/state
        ))
(in-package :charged-monads/tests/state)

(named-readtables:in-readtable coalton:coalton)

(fiasco:define-test-package #:charged-monads/tests/state-fiasco)
(coalton-fiasco-init #:charged-monads/tests/state-fiasco)

(define-test test-run-pure ()
  (let (values state result) = (run-state 0 (pure "Value")))
  (is (== 0 state))
  (is (== "Value" result)))

(define-test test-run-get ()
  (let (values state result) = (run-state 0 get))
  (is (== 0 state))
  (is (== 0 result)))

(define-test test-run-put-same-type ()
  (let (values state result) = (run-state 0 (put 1)))
  (is (== 1 state))
  (is (== Unit result)))

(define-test test-run-put-change-type ()
  (let (values state result) = (run-state 0 (put "State")))
  (is (== "State" state))
  (is (== Unit result)))

(define-test test-modify-same-type ()
  (let (values state result) =
    (run-state 0 (modify (fn (x)
                           (+ x 100)))))
  (is (== 100 state))
  (is (== Unit result)))

(define-test test-modify-change-type ()
  (let (values state result) =
    (run-state 0 (modify (fn (x)
                           (show-as-string x)))))
  (is (== "0" state))
  (is (== Unit result)))

(define-test test-map-value-change ()
  (let (values state result) =
    (run-state 0 (map (fn (str) (<> str "-mapped"))
                      (pure "Value"))))
  (is (== 0 state))
  (is (== "Value-mapped" result)))

(define-test test-map-state-type-change ()
  (let (values state result) =
    (run-state 0 (map (fn (str) (<> str "-mapped"))
                      (pt-do
                        (modify show-as-string)
                        get))))
  (is (== "0" state))
  (is (== "0-mapped" result)))

(define-test test-lifta2-no-state-change ()
  (let (values state result) =
    (run-state 0
               (lifta2 (fn (a b)
                         (<> (show-as-string (+ a 10)) b))
                       (pure 20)
                       (pure "-b"))))
  (is (== 0 state))
  (is (== "30-b" result)))

(define-test test-lifta2-state-change ()
  (let (values state result) =
    (run-state 0
               (lifta2 (fn (a b)
                         (<> (show-as-string (+ a 10)) b))
                       (do
                         (modify (fn (x) (+ x 40)))
                         (pure 20))
                       (map show-as-string get))))
  (is (== 40 state))
  (is (== "3040" result)))

(define-test test-bind-no-state-change ()
  (let (values state result) =
    (run-state 0
               (>>= (pure "test")
                    (fn (str)
                      (do
                       (x <- get)
                       (pure (<> (show-as-string x) str)))))))
  (is (== 0 state))
  (is (== "0test" result)))

(define-test test-bind-state-change ()
  (let (values state result) =
    (run-state 0
               (>>= (do
                     (put 10)
                     (pure "test"))
                    (fn (str)
                      (do
                       (x <- get)
                       (modify (fn (x) (* 2 x)))
                       (pure (<> (show-as-string x) str)))))))
  (is (== 20 state))
  (is (== "10test" result)))
