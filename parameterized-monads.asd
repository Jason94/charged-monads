(asdf:defsystem "parameterized-monads"
  :defsystem-depends-on ("coalton-asdf")
  :depends-on ("coalton")
  :pathname "src/"
  :serial t
  :components
  (
    (:ct-file "main")
	(:ct-file "state")
  )
)
