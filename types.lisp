(cl:in-package #:libgit2-bindings)

(defctype size-t :unsigned-long)


(defcstruct repository-struct)
(defctype repository (:pointer repository-struct))

(defcstruct object-struct)
(defctype object (:pointer object-struct))

(defcstruct index-struct)
(defctype index (:pointer index-struct))

(defcstruct person-struct)
(defctype person (:pointer person-struct))

(defcstruct commit-struct)
(defctype commit (:pointer commit-struct))

(defcstruct tree-struct)
(defctype tree (:pointer tree-struct))

(defcstruct tree-entry-struct)
(defctype tree-entry (:pointer tree-entry-struct))

(defcenum otype
  (:any -2)
  (:bad -1)
  (:ext-1 0)
  (:commit 1)
  (:tree 2)
  (:blob 3)
  (:tag 4)
  (:ext-2 5)
  (:ofs-delta 6)
  (:ref-delta 7))

(defcstruct rawobj
  (data (:pointer :void))
  (length size-t)
  (type otype))

(defcstruct odb-struct)
(defctype odb (:pointer odb-struct))

(defcstruct oid-struct
  (id :unsigned-char :count 20))
#++
(cl:defclass oid ()
  ((id :reader id :initform :id)))
#++
(cl:defmethod (cl:setf id) ((value cl:string) (oid oid))
  (cl:setf (cl:slot-value oid 'id)
           (cl:coerce (cl:loop for i below 40 by 2
                               collect (cl:parse-integer value
                                                         :start i
                                                         :end (cl:+ i 2)
                                                         :radix 16))
                      'cl:vector))
  value)
#++
(cl:defmethod (cl:setf id) ((value cl:vector) (oid oid))
  (cl:setf (cl:slot-value oid 'id)
           (cl:make-array 20 :initial-contents value))
  value)
#++
(cl:defmethod cl:initialize-instance :after ((oid oid) cl:&key id)
  (cl:setf (id oid) id))
#++
(cl:defmethod hex ((oid oid) cl:&key (octets 20))
  ;; fixme: probably should limit count by length of output in characters
  ;; rather than by 2-character octets
  (cl:with-output-to-string (s)
    (cl:loop for i across (id oid)
             for j below octets
             do (cl:format s "~2,'0x" i))))

(define-foreign-type oid-type ()
  ()
  (:actual-type :pointer)
  (:simple-parser oid-type))

(cl:defmethod translate-to-foreign (hex-oid (type oid-type))
  (cl:assert (cl:= (cl:length hex-oid) 40))
  (cl:let ((a (foreign-alloc 'oid-struct)))
    (cl:loop for i below 40 by 2
             for j from 0
             do (cl:setf (mem-aref (foreign-slot-value a 'oid-struct 'id)
                                   :unsigned-char j)
                         (cl:parse-integer hex-oid
                                           :start i
                                           :end (cl:+ i 2)
                                           :radix 16)))
    a))

(cl:defmethod translate-from-foreign (pointer (type oid-type))
  (cl:if (null-pointer-p pointer)
      ()
      (cl:with-output-to-string (s)
        #++(cl:format s "~s:" pointer)
        #++(cl:format s "~s:" (mem-aref pointer :pointer))
        (cl:loop
         for i below 20
         do (cl:format s "~2,'0x"
                       (mem-aref (foreign-slot-value pointer 'oid-struct 'id)
                                 :unsigned-char i))))))

(cl:defmethod free-translated-object (pointer (type oid-type) param)
  (cl:declare (cl:ignore param))
  (foreign-free pointer))

(defctype time-t :long)

(define-foreign-type translated-time ()
  ()
  (:actual-type :long)
  (:simple-parser translated-time))
(cl:defparameter +git-time-epoch+ (cl:encode-universal-time 0 0 0 1 1 1970 0))
(cl:defmethod translate-to-foreign (time (type translated-time))
  (cl:- time +git-time-epoch+))
(cl:defmethod translate-from-foreign (time (type translated-time))
  (cl:+ time +git-time-epoch+))


(defcstruct signature
  (name :string)
  (email :string)
  (when translated-time))



(defcenum status
  (:success 0)
  (:error -1)
  (:error-not-oid -2)
  (:error-not-found -3)
  (:error-no-memory -4)
  (:error-os-error -5)
  (:error-obj-type -6)
  (:error-obj-corrupted -7)
  (:error-not-a-repo -8)
  (:error-invalid-type -9)
  (:error-missing-obj-data -10)
  (:error-pack-corrupted -11)
  (:error-flock-fail -12)
  (:error-zlib -13)
  (:error-busy -14)
  (:error-bare-index -15)
  (:error-invalid-refname -16)
  (:error-ref-corrupted -17)
  (:error-too-nested-sym-ref -18)
  (:error-packed-refs-corrupted -19)
  (:error-invalid-path -20)
  (:error-revwalk-over -21))

;;;;;;;;;;;;;;;
#||
(defcstruct reference-struct)
(defctype reference (:pointer reference-struct))



(cffi:defcstruct git-blob
  )
(cffi:defcstruct git-tag
  )


(cffi:defcstruct git-revwalk
  )

(cffi::defctype _-time-t :long)

(cffi::defctype time-t _-time-t)

(cffi::defctype git-time-t time-t)

(cffi:defcstruct git-index-time
  (seconds git-time-t)
  (nanoseconds :unsigned-int))


(cffi::defctype git-off-t :long-long)

(cffi:defcstruct git-index-entry
  (ctime git-index-time)
  (mtime git-index-time)
  (dev :unsigned-int)
  (ino :unsigned-int)
  (mode :unsigned-int)
  (uid :unsigned-int)
  (gid :unsigned-int)
  (file-size git-off-t)
  (oid git-oid)
  (flags :unsigned-short)
  (flags-extended :unsigned-short)
  (path (:pointer :char)))


(cffi:defcstruct git-time
  (time time-t)
  (offset :int))

(cffi:defcstruct git-odb-backend
  )

(cffi:defcenum git-rtype
  (:git-ref-invalid -1)
  (:git-ref-oid 1)
  (:git-ref-symbolic 2))




||#