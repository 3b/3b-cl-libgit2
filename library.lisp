(cl:in-package #:libgit2-bindings)

(define-foreign-library libgit2
  ;;(:darwin (:framework "??"))
  ;;(:windows "??.dll" :calling-convention :??)
  (:unix (:or "libgit2.so" "libgit2.so.0" "libgit2.so.0.4.0")))

(use-foreign-library libgit2)
