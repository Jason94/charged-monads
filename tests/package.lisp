(defpackage #:charged-monads/tests
  (:use #:coalton #:coalton-prelude #:coalton-testing)
  (:export #:run-tests))
(in-package #:charged-monads/tests)

(named-readtables:in-readtable coalton:coalton)

(fiasco:define-test-package #:charged-monads/fiasco-test-package)

(coalton-fiasco-init #:charged-monads/fiasco-test-package)

(cl:defun run-tests ()
  (fiasco:run-package-tests
   :packages '(
               #:charged-monads/tests/state-fiasco
               )
   :interactive cl:t))
