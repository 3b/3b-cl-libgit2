(in-package :libgit2)

(defparameter *repository* nil)


(defmacro check-git-error (form &body handlers)
  (let ((error-code (gensym)))
    `(restart-case
         (let ((,error-code ,form))
           (case ,error-code
             (:success ,error-code)
             ,@handlers
             (t (error "libgit2 error ~s from ~s" ,error-code ',(car form)))))
       (continue () :report "Continue" ))))

(defun repository-open (path)
  ;; todo: wrap it in something and add finalizer where possible...
  (cffi:with-foreign-object(repo '%git:repository)
    (check-git-error (%git:repository-open repo path))
    (cffi:mem-aref repo '%git:repository)))

(defmacro with-git-repository ((path &optional (var '*repository*)) &body body)
  `(let ((,var nil))
     (unwind-protect
          (progn
            (setf ,var (repository-open ,path))
            ,@body)
       (when ,var (%git:repository-free ,var)))))


(defclass git-object ()
  ;; keep a pointer to the repo, so it can be kept alive as long as there
  ;; are objects using it, in case it switches to finalizers
  ;; fixme: probably should check for repo that has been explicitly closed
  ;;   before accessing foreign pointers in objects?
  ((repo :initarg :repo :reader repo)
   (pointer :initarg :pointer :reader pointer)))

(defmethod object-id ((object git-object))
  (%git:object-id (pointer object)))

(defmethod object-type ((object git-object))
  (%git:object-type (pointer object)))

(defmethod object-owner ((object git-object))
  (repo object)
  #++(%git:object-owner (pointer object)))


(defclass git-commit (git-object)
  ())
(defmethod commit-id ((object git-commit))
  (%git:commit-id (pointer object)))
(defmethod commit-message-short ((object git-commit))
  (%git:commit-message-short (pointer object)))
(defmethod commit-message ((object git-commit))
  (%git:commit-message (pointer object)))
(defmethod commit-time ((object git-commit))
  (%git:commit-time (pointer object)))


(defmethod commit-author ((object git-commit))
  (let ((a (%git::commit-author (pointer object))))
    (prog1
        (list (cffi:foreign-slot-value a '%git::signature '%git::name)
           (cffi:foreign-slot-value a '%git::signature '%git::email)
           (cffi:foreign-slot-value a '%git::signature '%git::when))
      ;; not sure if a needs freed or not?
      #++(%git:signature-free a))))

(defmethod (setf commit-author) (value (object git-commit))
  (destructuring-bind (name email &optional (when (get-universal-time)))
      value
    (let ((s (%git:signature-new name email when
                                 (- (* 60 (nth-value 8 (decode-universal-time
                                                        when)))))))
      (%git:commit-set-author (pointer object) s)
      (%git:signature-free s))))

(defmethod commit-committer ((object git-commit))
  (let ((a (%git::commit-committer (pointer object))))
    (prog1
        (list (cffi:foreign-slot-value a '%git::signature '%git::name)
              (cffi:foreign-slot-value a '%git::signature '%git::email)
              (cffi:foreign-slot-value a '%git::signature '%git::when))
      ;; not sure if a needs freed or not? - apparently not
      #++(%git:signature-free a))))

(defmethod (setf commit-committer) (value (object git-commit))
  (destructuring-bind (name email &optional (when (get-universal-time)))
      value
    (let ((s (%git:signature-new name email when
                                 (- (* 60 (nth-value 8 (decode-universal-time
                                                        when)))))))
      (%git:commit-set-committer (pointer object) s)
      (%git:signature-free s))))

(defun commit-parents (commit)
  (loop for i below (%git:commit-parentcount (pointer commit))
     collect (make-instance 'git-commit
                            :pointer (%git:commit-parent (pointer commit) i))))


(defclass git-tree (git-object)
  ())
(defmethod tree-id ((object git-tree))
  (%git:tree-id (pointer object)))
(defmethod tree-entry-count ((object git-tree))
  (%git:tree-entrycount (pointer object)))

(defmethod tree-entry-count ((object git-tree))
  (%git:tree-entrycount (pointer object)))

(defmethod tree-entries ((object git-tree))
  (loop for i below (tree-entry-count object)
     collect (%git:tree-entry-by-index (pointer object) i)))

(defmethod commit-tree ((object git-commit))
  (make-instance 'git-tree
                 :repo (repo object)
                 :pointer (%git:commit-tree (pointer object))))


(defun lookup (repo id &key (type :any))
  (cffi:with-foreign-object (object '%git::commit)
    (check-git-error (%git:repository-lookup object repo id type))
    (case (%git:object-type (cffi:mem-aref object :pointer))
      (:commit
       (make-instance 'git-commit
                      :repo repo
                      :pointer (cffi:mem-aref object :pointer)))
      (:tree
       (make-instance 'git-tree
                      :repo repo
                      :pointer (cffi:mem-aref object :pointer)))
      (t (make-instance 'git-object
                        :repo repo
                        :pointer (cffi:mem-aref object :pointer))))))

(defun lookup-commit (repo id)
  (cffi:with-foreign-object (object '(:pointer %git::commit))
    (check-git-error (%git:repository-lookup object repo id :commit))
    (make-instance 'git-commit
                   :repo repo
                   :pointer (cffi:mem-aref object '%git::commit))))

(defun dump-tree (tree)
  (format t " tree = ~s (~s)~%" tree (tree-id tree))
  (format t "   count = ~s~%" (tree-entry-count tree) )
  (loop for e in (tree-entries tree)
     for i from 0
     do (format t "    ~s = ~s / ~s / ~6,'0o~%" i (%git:tree-entry-name e)
                (%git:tree-entry-id e)
                (%git:tree-entry-attributes e)))
)

(defun dump-commit (c)
  (format t " i= ~s~%" (commit-id c))
  (format t " m= ~s~%" (commit-message-short c))
  (format t " mm= ~s~%" (commit-message c))
  (format t " @ ~s~%" (reverse (multiple-value-list (decode-universal-time (commit-time c)))))
  (format t " a= ~s~%" (commit-author c))
  (format t " c= ~s~%" (commit-committer c))
  (dump-tree (commit-tree c))
  (loop for p in (commit-parents c)
       for i from 0
     do (format t "parent ~s :~%" i)
       (dump-commit p)
       (format t "<<<<<~%"))

)

#++
(with-git-repository ("/tmp/foo/bar/.git" repo)
  (format t "repo = ~s~%" repo)
  (let ((o (lookup repo "1907b540bb65c09cc8ba2f3547cfdd8a40f994bc" :type :commit)))
    (format t "lookup = ~s~%" o)
    (format t " = ~s / ~s / ~s~%" (object-type o)
            (object-owner o)
            (object-id o)))

  (let ((o (lookup-commit repo "1907b540bb65c09cc8ba2f3547cfdd8a40f994bc")))
    (dump-commit o)
    (setf (commit-author o) (list "foo" "bar" (get-universal-time)))
    (format t " a= ~s~%" (commit-author o))
    (format t " i= ~s~%" (commit-id o))
    (%git::object-write (pointer o))

)
)
