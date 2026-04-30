(asdf:defsystem "charged-monads"
  :defsystem-depends-on ("coalton-asdf")
  :depends-on ("coalton")
  :pathname "src/"
  :serial t
  :components
  (
    (:ct-file "main")
    (:ct-file "state")
    (:ct-file "statet")
    (:ct-file "contt")
  )
  :in-order-to ((test-op (test-op "charged-monads/tests")))
)

(defsystem "charged-monads/tests"
  :author "Jason Walker"
  :license "MIT"
  :depends-on ("charged-monads"
               "coalton/testing"
               "fiasco")
  :components ((:module "tests"
                :serial t
                :components
                (
                 (:file "state")
                 (:file "package")
                 )))
  :perform (test-op (op c)
            (uiop:with-current-directory ((asdf:system-source-directory c))
              (uiop:symbol-call '#:charged-monads/tests '#:run-tests))))
