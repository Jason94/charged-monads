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
   #:charged-monads/stateT
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
   (pt-do-reset
     (x <- (shift
            (fn (k)
              (make-list (k 1) (k 2) (k 3)))))
     (pt-pure (* 10 x)))))

(coalton-toplevel
  (inline)
  (declare or-def (:a * Optional :a -> :a))
  (define (or-def def val?)
    "Get the value of OPT if it is Some, or use DEF as the default."
    (match val?
      ((Some val) val)
      ((None) def)))

  (declare test-state (Void -> Integer * Unit))
  (define (test-state)
    (run-state Unit
      (pt-do
        ;; Change to string state
        (put "100")
        ;; Modify to (Optional Integer) state
        (modify parse-int)
        ;; Modify to Integer state
        (modify (fn (x?) (or-def 0 x?)))))))

(coalton-toplevel
  (define-type-alias App (PtStateT IO))

  (declare prompt (App (List String) (List String) Unit))
  (define prompt
    (do
     (pt-lift (write-line "Enter an integer:"))
     (input <- (pt-lift read-line))
     (modify-stateT (fn (st) (Cons input st)))))

  (declare sum-prompts (App (List String) Integer Unit))
  (define sum-prompts
    (pt-do
      ;; Convert List String -> List Integer
      (modify-stateT (fn (strs)
                       (map (fn (str)
                              (or-def 0 (parse-int str)))
                            strs)))
      ;; Convert List Integer -> Integer
      (modify-stateT sum)))

  (declare reset-app (App :s1 (List String) :s1))
  (define reset-app
    (pt-do
      (old-state <- (get-stateT))
      (put-stateT Nil)
      (pure old-state)))

  (declare test-app (Void -> App :s (List String) Integer))
  (define (test-app)
    "Test app prompts the user for three integers, adds them, then displays their sum."
    (pt-do
      reset-app
      prompt
      prompt
      prompt
      sum-prompts
      (total <- (get-stateT))
      (pt-lift (write-line (<> "Your total: "
                               (show-as-string total))))
      (pt-lift (write-line "Repeat? (y/n)"))
      (repeat? <- (pt-lift read-line))
      (if (== "y" repeat?)
          (test-app)
          reset-app)))

  (declare test-stateT (Void -> Integer))
  (define (test-stateT)
    (run-io! (eval-stateT Unit (test-app))))
  )
