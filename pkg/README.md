## Generate Docs

To generate docs, run this command in a REPL:

```lisp
(asdf:load-system "charged-monads/docs")
```

Once the system has been loaded, regen the docs by running:

```lisp
(charged-monads/docs:write-docs)
```
