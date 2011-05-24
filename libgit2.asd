(asdf:defsystem :libgit2
  :depends-on ("cffi")
  :components ((:file "bindings-package")
               (:file "library")
               (:file "types")
               (:file "bindings")
               (:file "package")
               (:file "libgit2"))
  :serial t)