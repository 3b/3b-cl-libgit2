(defpackage #:libgit2-bindings
  (:use :cffi)
  (:nicknames :%lg2 :%git)
  (:export

   ;;
   #:repository
   #:object
   #:index
   #:otype
   #:repository-open
   #:repository-free
   #:repository-lookup
   #:object-id
   #:object-type
   #:object-owner
   #:commit-id
   #:commit-message-short
   #:commit-message
   #:commit-time
   #:commit-author
   #:signature
   #:name
   #:email
   #:when
   #:commit-set-author
   #:signature-new
   #:signature-dup
   #:signature-free
   #:commit-set-committer
   #:commit-parent
   #:commit-add-parent
   #:commit-parentcount
   #:tree-id
   #:commit-tree
   #:tree-entrycount
   #:tree-lookup
   #:tree-entry-by-index
   #:tree-entry-by-name
   #:tree-entry-name
   #:tree-entry-id
   #:tree-entry-attributes))
