(cl:in-package #:libgit2-bindings)


(defcfun ("git_repository_open" repository-open) status
  (repository (:pointer repository))
  (path :string))

(defcfun ("git_repository_open2" repository-open2) status
  (repository (:pointer repository))
  (directory :string)
  (object-directory :string)
  (index-file :string)
  (work-file :string))

(defcfun ("git_repository_lookup" repository-lookup) status
  (object (:pointer object))
  (repository repository)
  (id oid-type)
  (type otype))

(defcfun ("git_repository_database" repository-database) odb
  (repository repository))

(defcfun ("git_repository_index" repository-index) (:pointer index)
  (repository repository))

(defcfun ("git_repository_newobject" repository-newobject) status
  (object (:pointer object))
  (repository repository)
  (type otype))

(defcfun ("git_repository_free" repository-free) :void
  (repository repository))





(defcfun ("git_object_write" object-write) status
  (object object))

(defcfun ("git_object_free" object-free) :void
  (object object))

#++
(defcfun ("git_object__size" object-size) size-t
  (type otype))

(defcfun ("git_object_type" object-type) otype
  (object object))

(defcfun ("git_object_id" object-id) oid-type
  (object object))

(defcfun ("git_object_owner" object-owner) repository
  (object object))

#++
(defcfun ("git_object_string2type" object-string-2type) otype
  (string :string))

#++
(defcfun ("git_object_type2string" object-type-2string) :string
  (type otype))


(defcfun ("git_index_open_bare" index-open-bare) status
  (index :pointer)
  (index-path :pointer))

(defcfun ("git_object_typeisloose" object-typeisloose) status
  (type otype))





(defcfun ("git_signature_new" signature-new) (:pointer signature)
  (name :string)
  (email :string)
  (time translated-time)
  (offset :int))

(defcfun ("git_signature_dup" signature-dup) (:pointer signature)
  (signature (:pointer signature)))

(defcfun ("git_signature_free" signature-free) :void
  (signature (:pointer signature)))




(defcfun ("git_commit_new" commit-new) status
  (commit (:pointer commit))
  (repo repository))

#+missing?
(defcfun ("git_commit_lookup" commit-lookup) status
  (commit (:pointer commit))
  (repo repository)
  (id oid-type))

(defcfun ("git_commit_author" commit-author) signature
  (commit commit))

(defcfun ("git_commit_set_author" commit-set-author) :void
  (commit commit)
  (author signature))

(defcfun ("git_commit_committer" commit-committer) signature
  (commit commit))

(defcfun ("git_commit_set_committer" commit-set-committer) :void
  (commit commit)
  (committer signature))


(defcfun ("git_commit_id" commit-id) oid-type
  (commit commit))

(defcfun ("git_commit_message_short" commit-message-short) :string
  (commit commit))
(defcfun ("git_commit_message" commit-message) :string
  (commit commit))

(defcfun ("git_commit_set_message" commit-set-message) :void
  (commit commit)
  (message :string))

(defcfun ("git_commit_parent" commit-parent) commit
  (commit commit)
  (n :unsigned-int))

(defcfun ("git_commit_add_parent" commit-add-parent) status
  (commit commit)
  (new-parent commit))

(defcfun ("git_commit_parentcount" commit-parentcount) :unsigned-int
  (commit commit))


(defcfun ("git_commit_tree" commit-tree) tree
  (commit commit))

(defcfun ("git_commit_set_tree" commit-set-tree) :void
  (commit commit)
  (tree tree))

(defcfun ("git_commit_time" commit-time) translated-time
  (commit commit))

(defcfun ("git_commit_time_offset" commit-time-offset) :int
  (commit commit))






(defcfun ("git_tree_lookup" tree-lookup) status
  (tree tree)
  (repo repository)
  (id oid-type))

(defcfun ("git_tree_new" tree-new) status
  (tree tree)
  (repo repo))

(defcfun ("git_tree_id" tree-id) oid-type
  (tree tree))

(defcfun ("git_tree_entrycount" tree-entrycount) size-t
  (tree tree))

(defcfun ("git_tree_add_entry" tree-add-entry) status
  (entry-out (:pointer tree-entry))
  (tree tree)
  (id oid-type)
  (filename :string)
  (attributes :int))

(defcfun ("git_tree_remove_entry_byindex" tree-remove-entry-by-index) status
  (tree tree)
  (idx :int))

(defcfun ("git_tree_remove_entry_byname" tree-remove-entry-by-name) status
  (tree tree)
  (filename :string))
#++
(defcfun ("git_tree_clear_entries" tree-clear-entries) :void
  (tree tree))

(defcfun ("git_tree_entry_byindex" tree-entry-by-index) tree-entry
  (tree tree)
  (idx :int))

(defcfun ("git_tree_entry_byname" tree-entry-by-name) tree-entry
  (tree tree)
  (filename :string))




(defcfun ("git_tree_entry_name" tree-entry-name) :string
  (entry tree-entry))

(defcfun ("git_tree_entry_set_name" tree-entry-set-name) :void
  (entry tree-entry)
  (name :string))

(defcfun ("git_tree_entry_id" tree-entry-id) oid-type
  (entry tree-entry))

(defcfun ("git_tree_entry_set_id" tree-entry-set-id) :void
  (entry tree-entry)
  (oid oid-type))


(defcfun ("git_tree_entry_2object" tree-entry-to-object) status
  (object (:pointer object))
  (entry tree-entry))



(defcfun ("git_tree_entry_attributes" tree-entry-attributes) :unsigned-int
  (entry tree-entry))

(defcfun ("git_tree_entry_set_attributes" tree-entry-set-attributes) :void
  (entry tree-entry)
  (attr :int))



