(defpackage #:charged-monads/docs
  (:use #:cl)
  (:export #:write-docs))

(in-package #:charged-monads/docs)

(defun write-docs (&key
                     (pathname (merge-pathnames #p"docs/index.html"
                                               (asdf:system-source-directory "charged-monads")))
                     (packages (mapcar
                                (lambda (p)
                                  (coalton/doc/model::make-coalton-package
                                   (find-package p)
                                   :reexported-symbols t))
                                (list
                                 'charged-monads
                                 'charged-monads/state
                                 'charged-monads/stateT
                                 'charged-monads/contT
                                 )))
                     (remote-path "https://github.com/Jason94/charged-monads/tree/master"))
  (coalton/doc:write-documentation
   pathname
   packages
   :local-path (namestring (asdf:system-source-directory "charged-monads"))
   :remote-path remote-path
   :backend :html))
